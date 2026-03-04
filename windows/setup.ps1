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
