# ⚙️ retn0's dotfiles

This repository contains a collection of personal configurations and automation scripts for various tools and environments. While these are tailored to my personal workflow, they might be helpful for others setting up similar development environments.

## 🪟 Windows

> [!WARNING]
> The installation script will automatically install **ALL** configured applications and update existing ones. Applications already installed will be skipped. Review the script content before execution to customize the application list.

### Prerequisites

To run PowerShell scripts, you need to enable script execution by running the following command in PowerShell as Administrator:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
```

### Quick Installation

For the fastest setup, you can directly execute the installation script from the internet:

```powershell
irm https://raw.githubusercontent.com/nbsp1221/dotfiles/main/windows/install-applications.ps1 | iex
```

### Manual Installation

If you prefer to review the script before execution:

1. Clone this repository:
   ```bash
   git clone https://github.com/nbsp1221/dotfiles.git
   cd dotfiles
   ```

2. Run the installation script:
   ```powershell
   .\windows\install-applications.ps1
   ```

### What Gets Installed

The script installs a curated set of applications using winget. Check the `windows/install-applications.ps1` file to see the complete list of applications that will be installed.
