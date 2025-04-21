# List of Cursor extensions
$extensions = @(
    "ms-vscode-remote.remote-ssh",
    "pkief.material-icon-theme"
)

echo "Starting Cursor extension installation..."

# Install each extension
foreach ($extension in $extensions) {
    echo "Installing extension '$extension'..."
    cursor --install-extension $extension
}

echo "All extensions have been installed successfully."
