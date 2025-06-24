# Update all installed applications
Write-Host "Updating all installed applications..."
winget upgrade --all --silent --accept-package-agreements --accept-source-agreements

# List of programs to install
$apps = @(
    "AgileBits.1Password",
    "Alex313031.Thorium.AVX2",
    "Anthropic.Claude",
    "Anysphere.Cursor",
    "Bandisoft.Bandizip",
    "CPUID.CPU-Z",
    "CPUID.HWMonitor",
    "CrystalDewWorld.CrystalDiskInfo",
    "CrystalDewWorld.CrystalDiskMark",
    "Daum.PotPlayer",
    "Discord.Discord",
    "Kakao.KakaoTalk",
    "Microsoft.PowerToys",
    "Microsoft.VisualStudioCode",
    "Microsoft.WindowsTerminal",
    "Notion.Notion",
    "Obsidian.Obsidian",
    "OpenJS.NodeJS.LTS",
    "OpenWhisperSystems.Signal",
    "Oven-sh.Bun",
    "Python.Python.3.13",
    "SlackTechnologies.Slack",
    "Telegram.TelegramDesktop",
    "Valve.Steam",
    "voidtools.Everything"
)

# Install each app if not already installed
Write-Host "Starting installation of applications..."
foreach ($app in $apps) {
    # Check if app is already installed using direct winget execution
    $null = winget list --id "$app" --exact 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "$app is already installed. Skipping..."
    }
    else {
        Write-Host "Installing $app..."
        winget install --id="$app" --silent --accept-package-agreements --accept-source-agreements
    }
}

# Finish
Write-Host "All applications have been installed successfully!"
