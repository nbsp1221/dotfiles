#!/bin/bash

set -e

# Essential packages
ESSENTIAL_PACKAGES=(
  apt-transport-https
  btop
  build-essential
  ca-certificates
  cpu-x
  curl
  git
  gnupg
  htop
  micro
  nano
  neofetch
  net-tools
  pkg-config
  python3
  python3-dev
  python3-pip
  python3-setuptools
  python3-venv
  software-properties-common
  tmux
  tree
  unzip
  vim
  wget
  zip
  zsh
)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

#================================================================================
# System Update and Essential Packages Installation
#================================================================================

log "Updating system and installing essential packages..."

sudo apt update
sudo apt upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt install -y "${ESSENTIAL_PACKAGES[@]}"
sudo apt autoremove -y
sudo apt clean

success "System update and essential packages installation completed."

#================================================================================
# Programming Languages and Runtime
#================================================================================

log "Installing programming languages and runtime..."

# Install uv
# https://docs.astral.sh/uv/getting-started/installation
command -v uv > /dev/null 2>&1 || {
  curl -LsSf https://astral.sh/uv/install.sh | sh
}

# Install fnm and Node.js
command -v fnm > /dev/null 2>&1 || {
  curl -fsSL https://fnm.vercel.app/install | bash
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "`fnm env`"
  fnm install --lts
  fnm use lts-latest
  fnm default lts-latest
  npm install -g corepack
  corepack enable
}

# Install Bun
command -v bun > /dev/null 2>&1 || {
  curl -fsSL https://bun.sh/install | bash
  export PATH="$HOME/.bun/bin:$PATH"
}

# Install Rust
# https://www.rust-lang.org/tools/install
command -v rustc > /dev/null 2>&1 || {
  curl --proto '=https' --tlsv1.3 https://sh.rustup.rs -sSf | sh -s -- -y
  source "$HOME/.cargo/env"
}

success "Programming languages and runtime installation completed."

#================================================================================
# Useful Utilities
#================================================================================

log "Installing useful utilities..."

# Install GitHub CLI
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian
command -v gh > /dev/null 2>&1 || {
  sudo mkdir -p -m 755 /etc/apt/keyrings
  out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg
  cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  sudo mkdir -p -m 755 /etc/apt/sources.list.d
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install -y gh
}

# Install Docker
command -v docker > /dev/null 2>&1 || {
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker $(whoami)
}

log "Useful utilities installation completed."

#================================================================================
# AI Tools
#================================================================================

log "Installing AI tools..."

# Install Codex
command -v codex > /dev/null 2>&1 || {
  npm install -g @openai/codex
}

# Install Claude Code
command -v claude > /dev/null 2>&1 || {
  npm install -g @anthropic-ai/claude-code
}

# Install Gemini CLI
command -v gemini > /dev/null 2>&1 || {
  npm install -g @google/gemini-cli
}

log "AI tools installation completed."
