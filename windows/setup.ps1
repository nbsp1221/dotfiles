#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

# Colors
$ESC = [char]27
$RED = "$ESC[0;31m"
$GREEN = "$ESC[0;32m"
$BLUE = "$ESC[0;34m"
$NC = "$ESC[0m"

# Logging functions
function Log { param([string]$Message) Write-Host "${BLUE}[INFO]${NC} $Message" }
function Success { param([string]$Message) Write-Host "${GREEN}[SUCCESS]${NC} $Message" }
function Error { param([string]$Message) Write-Host "${RED}[ERROR]${NC} $Message" }

# Check if a command exists
function Test-CommandExists {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

# Refresh environment variables in current session
function Update-SessionEnvironment {
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
    $env:Path = "$machinePath;$userPath"
}

# List of programs to install via WinGet
$WINGET_APPS = @(
    "AgileBits.1Password",
    "Alex313031.Thorium.AVX2",
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
    "Kakao.KakaoTalk",
    "Microsoft.PowerShell",
    "Microsoft.PowerToys",
    "Microsoft.VisualStudioCode",
    "Microsoft.WindowsTerminal",
    "Notion.Notion",
    "Obsidian.Obsidian",
    "Rustlang.Rustup",
    "Schniz.fnm",
    "Telegram.TelegramDesktop",
    "Valve.Steam",
    "voidtools.Everything"
)

#================================================================================
# Update all installed applications
#================================================================================

Log "Updating all installed applications..."

winget upgrade --all --silent --accept-package-agreements --accept-source-agreements

Success "All installed applications updated."

#================================================================================
# Install applications
#================================================================================

Log "Installing applications via WinGet..."

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

Success "Applications installation completed."

#================================================================================
# Install programming languages and runtime
#================================================================================

Log "Installing programming languages and runtime..."

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

Success "Programming languages and runtime installation completed."

#================================================================================
# Install AI tools
#================================================================================

Log "Installing AI tools..."

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

Success "AI tools installation completed."
