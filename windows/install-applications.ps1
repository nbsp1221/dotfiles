# Update all installed applications
Write-Host "Updating all installed applications..."
winget upgrade --all --silent --accept-package-agreements --accept-source-agreements

# List of programs to install
$apps = @(
    "AgileBits.1Password",
    "Alex313031.Thorium.AVX2",
    "Anthropic.Claude",
    "Anysphere.Cursor",
    "astral-sh.uv",
    "Bandisoft.Bandizip",
    "CPUID.CPU-Z",
    "CPUID.HWMonitor",
    "CrystalDewWorld.CrystalDiskInfo",
    "CrystalDewWorld.CrystalDiskMark",
    "Daum.PotPlayer",
    "DBeaver.DBeaver.Community",
    "Discord.Discord",
    "Kakao.KakaoTalk",
    "Microsoft.PowerToys",
    "Microsoft.VisualStudioCode",
    "Microsoft.WindowsTerminal",
    "Notion.Notion",
    "Obsidian.Obsidian",
    "OpenJS.NodeJS.LTS",
    "OpenWhisperSystems.Signal",
    "Python.Python.3.13",
    "SlackTechnologies.Slack",
    "Telegram.TelegramDesktop",
    "Valve.Steam",
    "voidtools.Everything"
)

# Install each app if not already installed
Write-Host "Starting installation of applications..."
foreach ($app in $apps) {
    # Check if app is already installed using direct WinGet execution
    $null = winget list --id "$app" --exact 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "$app is already installed. Skipping..."
    }
    else {
        Write-Host "Installing $app..."
        winget install --id="$app" --silent --accept-package-agreements --accept-source-agreements
    }
}

# Install Bun (WinGet has bunx issues)
Write-Host "Installing Bun using official installer..."
irm https://bun.sh/install.ps1 | iex

# Refresh environment variables
Write-Host "Refreshing environment variables..."
$userPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
$machinePath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
$env:Path = $userPath + ";" + $machinePath

# Install Gemini CLI
Write-Host "Installing Gemini CLI..."
npm install -g @google/gemini-cli

# Finish
Write-Host "All applications have been installed successfully!"
