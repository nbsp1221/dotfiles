#!/bin/bash

# List of Cursor extensions
extensions=(
  "arcanis.vscode-zipfs"
  "dbaeumer.vscode-eslint"
  "streetsidesoftware.code-spell-checker"
)

echo "Starting Cursor extension installation..."

# Install each extension
for extension in "${extensions[@]}"; do
  echo "Installing extension '$extension'..."
  cursor --install-extension "$extension"
done

echo "All extensions have been installed successfully." 
