# Update all installed applications
echo "Updating all installed applications..."
winget upgrade --all --silent --accept-package-agreements --accept-source-agreements

# List of programs to install
$apps = @(
    'AgileBits.1Password',
    'Alex313031.Thorium.AVX2',
    'Anthropic.Claude',
    'Anysphere.Cursor',
    'Bandisoft.Bandizip',
    'CPUID.CPU-Z',
    'CPUID.HWMonitor',
    'CrystalDewWorld.CrystalDiskInfo',
    'CrystalDewWorld.CrystalDiskMark',
    'Daum.PotPlayer',
    'Discord.Discord',
    'Kakao.KakaoTalk',
    'Microsoft.PowerToys',
    'Microsoft.WindowsTerminal',
    'Notion.Notion',
    'OpenJS.NodeJS',
    'SlackTechnologies.Slack',
    'Telegram.TelegramDesktop',
    'Valve.Steam',
    'voidtools.Everything'
)

# Install each app if not already installed
echo "Starting installation of applications..."
foreach ($app in $apps) {
    $installed = winget list | Select-String -Pattern "(?i)$app"
    if ($installed) {
        echo "$app is already installed. Skipping..."
    }
    else {
        echo "Installing $app..."
        winget install --id=$app --silent --accept-package-agreements --accept-source-agreements
    }
}

# Finish
echo "All applications have been installed successfully!"
