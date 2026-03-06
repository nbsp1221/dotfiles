#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

# Logging functions
function Write-Log {
    param([string]$Message)
    Write-Host "[INFO] " -ForegroundColor Cyan -NoNewline
    Write-Host $Message
}
function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
    Write-Host $Message
}
function Write-Failure {
    param([string]$Message)
    Write-Host "[FAILURE] " -ForegroundColor Red -NoNewline
    Write-Host $Message
}

# Check if a command exists
function Test-CommandExists {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

# Refresh environment variables in current session
function Update-SessionEnvironment {
    $originalPSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath", "Process")
    $scopeList = @("Machine")

    if ($env:USERNAME -ne "SYSTEM") {
        $scopeList += "User"
    }

    foreach ($scope in $scopeList) {
        $envNames = [System.Environment]::GetEnvironmentVariables($scope).Keys
        foreach ($name in $envNames) {
            $value = [System.Environment]::GetEnvironmentVariable($name, $scope)
            if ($null -ne $value) {
                Set-Item -Path "Env:$name" -Value $value
            }
        }
    }

    $paths = "Machine", "User" | ForEach-Object {
        ([System.Environment]::GetEnvironmentVariable("PATH", $_)) -split ";"
    } | Where-Object { $_ } | Select-Object -Unique

    $env:PATH = $paths -join ";"
    $env:PSModulePath = $originalPSModulePath
}

#================================================================================
# Install fonts
#================================================================================

$FONT_PACKAGES = @(
    @{
        Name         = "Pretendard"
        Version      = "1.3.9"
        Url          = "https://github.com/orioncactus/pretendard/releases/download/v1.3.9/Pretendard-1.3.9.zip"
        SourceDir    = "public/static"
        FilePatterns = @("*.otf")
    }
)

function New-FontResourceType {
    if ("FontResource.FontInstaller" -as [type]) {
        return
    }

    $fontCSharpCode = @'
    using System;
    using System.IO;
    using System.Runtime.InteropServices;

    namespace FontResource {
        public class FontInstaller {
            private static readonly IntPtr HWND_BROADCAST = new IntPtr(0xffff);

            [DllImport("gdi32.dll")]
            private static extern int AddFontResource(string lpFilename);

            [return: MarshalAs(UnmanagedType.Bool)]
            [DllImport("user32.dll", SetLastError = true)]
            private static extern bool PostMessage(IntPtr hWnd, WM Msg, IntPtr wParam, IntPtr lParam);

            public enum WM : uint {
                FONTCHANGE = 0x001D
            }

            public static int AddFont(string fontFilePath) {
                FileInfo fontFile = new FileInfo(fontFilePath);
                if (!fontFile.Exists) { throw new FileNotFoundException("Font file not found"); }
                int retVal = AddFontResource(fontFilePath);
                PostMessage(HWND_BROADCAST, WM.FONTCHANGE, IntPtr.Zero, IntPtr.Zero);
                return retVal;
            }
        }
    }
'@

    Add-Type -TypeDefinition $fontCSharpCode -ErrorAction Stop
}

function Get-FontDisplayName {
    param(
        [Parameter(Mandatory)]
        [System.IO.FileInfo] $File
    )

    try {
        $folderObj = (New-Object -ComObject Shell.Application).Namespace($File.DirectoryName)
        if ($null -ne $folderObj) {
            $fileObj = $folderObj.Items().Item($File.Name)
            $fontName = $folderObj.GetDetailsOf($fileObj, 21)
            if ($fontName) {
                return $fontName
            }
        }
    }
    catch {
        # Fall back to filename without extensions
    }

    return $File.BaseName
}

function Install-FontFiles {
    [CmdletBinding()]
    param(
        [string[]] $Path,
        [switch] $Recurse,
        [switch] $Force
    )

    $fontTypeSuffix = @{
        ".fon" = ""
        ".fnt" = ""
        ".ttf" = " (TrueType)"
        ".ttc" = " (TrueType)"
        ".otf" = " (OpenType)"
    }

    $fontFolder = "$env:WINDIR\Fonts"
    $fontRegistryPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"

    if (-not (Test-Path -Path $fontFolder)) {
        $null = New-Item -Path $fontFolder -ItemType Directory -Force
    }

    $fontFiles = @()
    foreach ($pathItem in $Path) {
        if (Test-Path -Path $pathItem -PathType Container) {
            $fontFiles += Get-ChildItem -Path $pathItem -File -Recurse:$Recurse -Include *.fon,*.fnt,*.ttf,*.ttc,*.otf
        }
        else {
            $fontFiles += Get-ChildItem -Path $pathItem -File -ErrorAction Stop
        }
    }

    if ($fontFiles.Count -eq 0) {
        return
    }

    New-FontResourceType

    foreach ($fontFile in $fontFiles) {
        $extension = $fontFile.Extension.ToLower()
        if (-not $fontTypeSuffix.ContainsKey($extension)) {
            continue
        }

        try {
            $destPath = Join-Path -Path $fontFolder -ChildPath $fontFile.Name
            Copy-Item -Path $fontFile.FullName -Destination $destPath -Force -ErrorAction Stop
            $retVal = [FontResource.FontInstaller]::AddFont($destPath)
            if ($retVal -eq 0) {
                Write-Failure "Font install failed: $($fontFile.FullName)"
                continue
            }

            $fontName = Get-FontDisplayName -File $fontFile
            $regName = "$fontName$($fontTypeSuffix[$extension])"
            $regValue = $fontFile.Name
            New-ItemProperty -Path $fontRegistryPath -Name $regName -Value $regValue -PropertyType String -Force | Out-Null
        }
        catch {
            Write-Failure "Font install error: $($fontFile.FullName) - $($_.Exception.Message)"
        }
    }
}

function Install-FontPackages {
    param(
        [hashtable[]] $Packages
    )

    $tempRoot = Join-Path $env:TEMP "font-packages"
    if (-not (Test-Path -Path $tempRoot)) {
        $null = New-Item -Path $tempRoot -ItemType Directory -Force
    }

    foreach ($pkg in $Packages) {
        $name = $pkg.Name
        $url = $pkg.Url
        $downloadFile = Join-Path $tempRoot (Split-Path -Path $url -Leaf)
        $extractDir = Join-Path $tempRoot $name

        Write-Log "Downloading font package: $name"
        Invoke-WebRequest -Uri $url -OutFile $downloadFile

        if ($downloadFile.ToLower().EndsWith(".zip")) {
            if (Test-Path -Path $extractDir) {
                Remove-Item -Path $extractDir -Recurse -Force
            }

            Expand-Archive -Path $downloadFile -DestinationPath $extractDir -Force

            $searchRoot = $extractDir
            if ($pkg.ContainsKey("SourceDir") -and $pkg.SourceDir) {
                $searchRoot = Join-Path $extractDir $pkg.SourceDir
            }

            if (-not (Test-Path -Path $searchRoot)) {
                Write-Failure "Font package path not found: $searchRoot"
                continue
            }

            if (-not ($pkg.ContainsKey("FilePatterns") -and $pkg.FilePatterns)) {
                Write-Failure "FilePatterns is required for package: $name"
                continue
            }

            $fontFiles = Get-ChildItem -Path $searchRoot -File -Recurse -Include $pkg.FilePatterns
            if ($fontFiles.Count -eq 0) {
                Write-Failure "No font files found for package: $name"
                continue
            }

            Install-FontFiles -Path $fontFiles.FullName
        }
        else {
            Install-FontFiles -Path $downloadFile
        }
    }
}

Write-Log "Installing fonts..."
Install-FontPackages -Packages $FONT_PACKAGES
Write-Success "Fonts installation completed."

#================================================================================
# Enable Windows Optional Features
#================================================================================

function Assert-WindowsOptionalFeature {
    param(
        [string]$FeatureName,
        [string]$DisplayName
    )

    Write-Log "Enabling $DisplayName..."

    $feature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName
    if ($feature.State -eq "Enabled") {
        Write-Host "$DisplayName is already enabled. Skipping..."
        return
    }

    $result = Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -All -NoRestart
    if ($result.RestartNeeded) {
        Write-Success "$DisplayName enabled. Restart is required to apply changes."
    }
    else {
        Write-Success "$DisplayName enabled successfully."
    }
}

Assert-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -DisplayName "Windows Sandbox"

# List of programs to install via WinGet
$WINGET_APPS = @(
    "AgileBits.1Password",
    "astral-sh.uv",
    "Bandisoft.Bandizip",
    "CPUID.CPU-Z",
    "CPUID.HWMonitor",
    "CrystalDewWorld.CrystalDiskInfo",
    "CrystalDewWorld.CrystalDiskMark",
    "Daum.PotPlayer",
    "DBeaver.DBeaver.Community",
    "Discord.Discord",
    "Git.Git",
    "GitHub.cli",
    "ImputNet.Helium",
    "Kakao.KakaoTalk",
    "Microsoft.PowerShell",
    "Microsoft.PowerToys",
    "Microsoft.VisualStudioCode",
    "Microsoft.WindowsTerminal",
    "Notion.Notion",
    "Obsidian.Obsidian",
    "Rustlang.Rustup",
    "Schniz.fnm",
    "TechPowerUp.GPU-Z",
    "Telegram.TelegramDesktop",
    "Valve.Steam",
    "voidtools.Everything"
)

#================================================================================
# Update all installed applications
#================================================================================

Write-Log "Updating all installed applications..."

winget upgrade --all --silent --accept-package-agreements --accept-source-agreements

Write-Success "All installed applications updated."

#================================================================================
# Install applications
#================================================================================

Write-Log "Installing applications via WinGet..."

foreach ($app in $WINGET_APPS) {
    $null = winget list --id "$app" --exact 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "$app is already installed. Skipping..."
    }
    else {
        Write-Host "Installing $app..."
        winget install --id="$app" --silent --accept-package-agreements --accept-source-agreements
    }
}

Write-Success "Applications installation completed."

#================================================================================
# Install programming languages and runtime
#================================================================================

Write-Log "Installing programming languages and runtime..."

Update-SessionEnvironment

# fnm is installed via WinGet, configure and install Node.js here
if (Test-CommandExists "fnm") {
    fnm env --use-on-cd | Out-String | Invoke-Expression

    if (-not (Test-CommandExists "node")) {
        Write-Host "Installing Node.js LTS via fnm..."
        fnm install --lts
        fnm use lts-latest
        fnm default lts-latest

        Write-Host "Enabling corepack..."
        npm install -g corepack
        corepack enable
    }
    else {
        Write-Host "Node.js is already installed. Skipping..."
    }
}

# WinGet has bunx issues, use official installer instead
if (-not (Test-CommandExists "bun")) {
    Write-Host "Installing Bun..."
    irm https://bun.sh/install.ps1 | iex
    Update-SessionEnvironment
}
else {
    Write-Host "Bun is already installed. Skipping..."
}

Write-Success "Programming languages and runtime installation completed."

#================================================================================
# Install AI tools
#================================================================================

Write-Log "Installing AI tools..."

Update-SessionEnvironment

if (-not (Test-CommandExists "codex")) {
    Write-Host "Installing Codex..."
    npm install -g @openai/codex
}
else {
    Write-Host "Codex is already installed. Skipping..."
}

if (-not (Test-CommandExists "gemini")) {
    Write-Host "Installing Gemini CLI..."
    npm install -g @google/gemini-cli
}
else {
    Write-Host "Gemini CLI is already installed. Skipping..."
}

Write-Success "AI tools installation completed."
