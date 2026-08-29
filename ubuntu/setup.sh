#!/bin/bash

set -euo pipefail

readonly SCRIPT_NAME="${0##*/}"
readonly ARCH="$(dpkg --print-architecture)"

SYSTEM_SETUP=""
ALLOW_ROOT="false"
SUDO_CMD=()

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log () { printf '%b[INFO]%b %s\n' "${BLUE}" "${NC}" "$*"; }
success () { printf '%b[SUCCESS]%b %s\n' "${GREEN}" "${NC}" "$*"; }
warn () { printf '%b[WARN]%b %s\n' "${YELLOW}" "${NC}" "$*" >&2; }
error () { printf '%b[ERROR]%b %s\n' "${RED}" "${NC}" "$*" >&2; }

command_exists() {
  command -v "${1}" > /dev/null 2>&1
}

append_line_if_missing() {
  local file="${1}"
  local line="${2}"

  if grep -Fqx -- "${line}" "${file}" 2> /dev/null; then
    return
  fi

  printf '\n%s\n' "${line}" >> "${file}"
}

confirm() {
  local prompt="${1}"
  local default="${2:-no}"
  local answer
  local suffix

  case "${default}" in
    yes)
      suffix="[Y/n]"
      ;;
    no)
      suffix="[y/N]"
      ;;
    *)
      error "Invalid confirm default: ${default}"
      exit 1
      ;;
  esac

  if ! ( : < /dev/tty > /dev/tty ) 2> /dev/null; then
    return 2
  fi

  while true; do
    printf '%s %s ' "${prompt}" "${suffix}" > /dev/tty
    IFS= read -r answer < /dev/tty || return 2

    case "${answer}" in
      [yY] | [yY][eE][sS])
        return 0
        ;;
      [nN] | [nN][oO])
        return 1
        ;;
      "")
        [[ "${default}" == "yes" ]]
        return
        ;;
      *)
        printf '%s\n' "Please answer yes or no." > /dev/tty
        ;;
    esac
  done
}

print_help() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [options]

Options:
  --sudo        Run setup steps that require sudo
  --no-sudo     Skip setup steps that require sudo
  --allow-root  Allow running this script as root
  --help        Show this help message
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --sudo)
        if [[ "${SYSTEM_SETUP}" == "false" ]]; then
          error "Cannot use --sudo and --no-sudo together."
          exit 1
        fi
        SYSTEM_SETUP="true"
        shift
        ;;
      --no-sudo)
        if [[ "${SYSTEM_SETUP}" == "true" ]]; then
          error "Cannot use --sudo and --no-sudo together."
          exit 1
        fi
        SYSTEM_SETUP="false"
        shift
        ;;
      --allow-root)
        ALLOW_ROOT="true"
        shift
        ;;
      --help)
        print_help
        exit 0
        ;;
      --)
        shift
        break
        ;;
      --*)
        error "Unknown option: ${1}"
        printf 'Run "%s --help" for usage.\n' "${SCRIPT_NAME}" >&2
        exit 1
        ;;
      *)
        error "Unexpected argument: ${1}"
        printf 'Run "%s --help" for usage.\n' "${SCRIPT_NAME}" >&2
        exit 1
        ;;
    esac
  done

  if [[ $# -gt 0 ]]; then
    error "Unexpected argument: ${1}"
    printf 'Run "%s --help" for usage.\n' "${SCRIPT_NAME}" >&2
    exit 1
  fi
}

confirm_root_execution() {
  if (( EUID != 0 )); then
    return
  fi

  warn "You are running this script as root."
  warn "User-space tools will be installed under /root."

  if [[ "${ALLOW_ROOT}" == "true" ]]; then
    warn "Continuing as root because --allow-root was provided."
    return
  fi

  if confirm "Continue as root?" "no"; then
    warn "Continuing as root."
    return
  else
    case "${?}" in
      1)
        error "Aborted."
        ;;
      2)
        error "Root execution requires --allow-root in non-interactive mode."
        ;;
    esac
    exit 1
  fi
}

choose_system_setup() {
  if [[ -n "${SYSTEM_SETUP}" ]]; then
    return
  fi

  if confirm "Run setup steps that require sudo?" "no"; then
    SYSTEM_SETUP="true"
    return
  else
    case "${?}" in
      1)
        SYSTEM_SETUP="false"
        ;;
      2)
        error "Non-interactive usage requires --sudo or --no-sudo."
        exit 1
        ;;
    esac
  fi
}

set_sudo_command() {
  if (( EUID == 0 )); then
    SUDO_CMD=()
    if [[ "${SYSTEM_SETUP}" == "true" ]]; then
      log "Running as root. System setup steps will run directly without sudo."
    fi
    return
  fi

  if [[ "${SYSTEM_SETUP}" != "true" ]]; then
    SUDO_CMD=()
    return
  fi

  if ! command_exists sudo; then
    error "sudo is required when using --sudo."
    exit 1
  fi

  sudo -n true 2> /dev/null || sudo -v
  SUDO_CMD=(sudo)
}

SYSTEM_PACKAGES=(
  btop
  build-essential
  ca-certificates
  curl
  fd-find
  git
  gnupg
  jq
  lsof
  pkg-config
  python3
  python3-pip
  python3-venv
  ripgrep
  rsync
  shellcheck
  tmux
  unzip
  wget
  zip
  zsh
)

install_system_packages() {
  log "Installing system packages..."

  "${SUDO_CMD[@]}" apt-get update
  "${SUDO_CMD[@]}" env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
  "${SUDO_CMD[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y "${SYSTEM_PACKAGES[@]}"
  "${SUDO_CMD[@]}" apt-get autoremove -y
  "${SUDO_CMD[@]}" apt-get clean

  success "System packages installed."
}

install_github_cli() {
  if command_exists gh; then
    log "GitHub CLI is already installed."
    return
  fi

  local keyring="/etc/apt/keyrings/githubcli-archive-keyring.gpg"
  local source_list="/etc/apt/sources.list.d/github-cli.list"

  log "Installing GitHub CLI..."

  "${SUDO_CMD[@]}" mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | "${SUDO_CMD[@]}" tee "${keyring}" > /dev/null
  "${SUDO_CMD[@]}" chmod go+r "${keyring}"
  "${SUDO_CMD[@]}" mkdir -p -m 755 /etc/apt/sources.list.d
  printf 'deb [arch=%s signed-by=%s] https://cli.github.com/packages stable main\n' "${ARCH}" "${keyring}" | "${SUDO_CMD[@]}" tee "${source_list}" > /dev/null
  "${SUDO_CMD[@]}" apt-get update
  "${SUDO_CMD[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y gh

  success "GitHub CLI installed."
}

install_docker() {
  if command_exists docker; then
    log "Docker is already installed."
    return
  fi

  local codename
  local docker_user
  local keyring="/etc/apt/keyrings/docker.asc"
  local source_file="/etc/apt/sources.list.d/docker.sources"

  log "Installing Docker..."

  "${SUDO_CMD[@]}" mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | "${SUDO_CMD[@]}" tee "${keyring}" > /dev/null
  "${SUDO_CMD[@]}" chmod a+r "${keyring}"
  codename="$(. /etc/os-release && printf '%s\n' "${UBUNTU_CODENAME:-${VERSION_CODENAME}}")"
  printf 'Types: deb\nURIs: https://download.docker.com/linux/ubuntu\nSuites: %s\nComponents: stable\nArchitectures: %s\nSigned-By: %s\n' "${codename}" "${ARCH}" "${keyring}" | "${SUDO_CMD[@]}" tee "${source_file}" > /dev/null
  "${SUDO_CMD[@]}" apt-get update
  "${SUDO_CMD[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
  docker_user="${SUDO_USER:-$(id -un)}"
  "${SUDO_CMD[@]}" groupadd -f docker
  "${SUDO_CMD[@]}" usermod -aG docker "${docker_user}"

  configure_docker_address_pool

  success "Docker installed."
  warn "User ${docker_user} was added to the docker group."
  warn "You may need to log out and back in before Docker works without sudo."
}

configure_docker_address_pool() {
  "${SUDO_CMD[@]}" mkdir -p -m 755 /etc/docker
  "${SUDO_CMD[@]}" tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "default-address-pools": [
    {"base": "172.17.0.0/16", "size": 24},
    {"base": "172.18.0.0/16", "size": 24},
    {"base": "172.19.0.0/16", "size": 24},
    {"base": "172.20.0.0/14", "size": 24},
    {"base": "172.24.0.0/14", "size": 24},
    {"base": "172.28.0.0/14", "size": 24},
    {"base": "192.168.0.0/16", "size": 24}
  ]
}
EOF

  if [[ -d /run/systemd/system ]]; then
    "${SUDO_CMD[@]}" systemctl restart docker
  fi
}

install_system_tools() {
  if [[ "${SYSTEM_SETUP}" != "true" ]]; then
    log "Skipping system setup steps."
    return
  fi

  install_system_packages
  install_github_cli
  install_docker
}

install_oh_my_zsh() {
  if [[ -d "${HOME}/.oh-my-zsh" ]]; then
    log "Oh My Zsh is already installed."
    return
  fi

  log "Installing Oh My Zsh..."

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME=""/' "${HOME}/.zshrc"

  success "Oh My Zsh installed."
}

install_zsh_plugins() {
  local plugins_dir="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins"
  local zshrc="${HOME}/.zshrc"
  local plugin

  mkdir -p "${plugins_dir}"

  for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    if [[ -d "${plugins_dir}/${plugin}" ]]; then
      log "${plugin} is already installed."
    else
      log "Installing ${plugin}..."
      git clone "https://github.com/zsh-users/${plugin}.git" "${plugins_dir}/${plugin}"
      success "${plugin} installed."
    fi
  done

  if grep -q '^plugins=(' "${zshrc}"; then
    sed -i -E '
      /^plugins=\(/ {
        s/[[:space:]]*zsh-autosuggestions[[:space:]]*/ /g
        s/[[:space:]]*zsh-syntax-highlighting[[:space:]]*/ /g
        s/[[:space:]]+/ /g
        s/[[:space:]]*\)/ zsh-autosuggestions zsh-syntax-highlighting)/
        s/\([[:space:]]*/(/
      }
    ' "${zshrc}"
  else
    append_line_if_missing "${zshrc}" 'plugins=(zsh-autosuggestions zsh-syntax-highlighting)'
  fi
}

install_starship() {
  if command_exists starship; then
    log "Starship is already installed."
  else
    log "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b "${HOME}/.local/bin"

    success "Starship installed."
  fi

  append_line_if_missing "${HOME}/.zshrc" 'eval "$(starship init zsh)"'
}

install_zellij() {
  if command_exists zellij; then
    log "Zellij is already installed."
    return
  fi

  local zellij_arch

  case "${ARCH}" in
    amd64)
      zellij_arch="x86_64"
      ;;
    arm64)
      zellij_arch="aarch64"
      ;;
    *)
      error "Unsupported architecture for Zellij: ${ARCH}"
      return 1
      ;;
  esac

  log "Installing Zellij..."
  curl -fsSL "https://github.com/zellij-org/zellij/releases/latest/download/zellij-${zellij_arch}-unknown-linux-musl.tar.gz" | tar -xz -C "${HOME}/.local/bin"
  chmod 0755 "${HOME}/.local/bin/zellij"

  success "Zellij installed."
}

install_node() {
  export PATH="${HOME}/.local/share/fnm:${PATH}"

  if command_exists fnm; then
    log "fnm is already installed."
  else
    log "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash
    success "fnm installed."
  fi

  eval "$(fnm env --shell bash)"

  append_line_if_missing "${HOME}/.zshenv" 'export PATH="$HOME/.local/share/fnm:$PATH"'
  append_line_if_missing "${HOME}/.zshrc" 'eval "$(fnm env --use-on-cd --shell zsh)"'

  if command_exists node; then
    log "Node.js is already installed."
    return
  fi

  log "Installing the latest Node.js LTS..."
  fnm install --lts --corepack-enabled
  fnm default lts-latest

  success "Node.js LTS installed."
}

install_bun() {
  export BUN_INSTALL="${BUN_INSTALL:-${HOME}/.bun}"
  export PATH="${BUN_INSTALL}/bin:${PATH}"

  if command_exists bun; then
    log "Bun is already installed."
  else
    log "Installing Bun..."
    curl -fsSL https://bun.com/install | bash
    success "Bun installed."
  fi

  append_line_if_missing "${HOME}/.zshenv" 'export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"'
  append_line_if_missing "${HOME}/.zshenv" 'export PATH="${BUN_INSTALL}/bin:$PATH"'
}

install_uv() {
  if command_exists uv; then
    log "uv is already installed."
    return
  fi

  log "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh

  success "uv installed."
}

install_rust() {
  export PATH="${HOME}/.cargo/bin:${PATH}"

  if command_exists rustup; then
    log "Rust is already installed."
  else
    log "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    success "Rust installed."
  fi

  source "${HOME}/.cargo/env"
  append_line_if_missing "${HOME}/.zshenv" 'export PATH="$HOME/.cargo/bin:$PATH"'
}

install_codex() {
  if command_exists codex; then
    log "Codex is already installed."
    return
  fi

  local codex_home="${CODEX_HOME:-${HOME}/.codex}"
  local config_file="${codex_home}/config.toml"

  log "Installing Codex CLI..."

  curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=true sh
  mkdir -p "${codex_home}"

  printf '%s\n' \
    'approval_policy = "on-request"' \
    'sandbox_mode = "danger-full-access"' \
    '' \
    '[tui]' \
    'status_line = ["model-with-reasoning", "current-dir", "context-remaining", "five-hour-limit", "weekly-limit", "codex-version"]' \
    'status_line_use_colors = true' \
    > "${config_file}"

  success "Codex CLI installed."
}

install_claude_code() {
  if command_exists claude; then
    log "Claude Code is already installed."
    return
  fi

  log "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | CLAUDE_INSTALL_ALLOW_SUDO=1 bash

  success "Claude Code installed."
}

install_repomix() {
  if command_exists repomix; then
    log "Repomix is already installed."
    return
  fi

  log "Installing Repomix..."
  npm install --global repomix

  success "Repomix installed."
}

install_user_tools() {
  mkdir -p "${HOME}/.local/bin"
  export PATH="${HOME}/.local/bin:${PATH}"

  install_oh_my_zsh
  install_zsh_plugins
  install_starship
  install_zellij
  install_node
  install_bun
  install_uv
  install_rust

  install_codex
  install_claude_code
  install_repomix

  append_line_if_missing "${HOME}/.zshenv" 'export PATH="$HOME/.local/bin:$PATH"'
}

main() {
  parse_args "$@"
  confirm_root_execution
  choose_system_setup
  set_sudo_command

  install_system_tools
  install_user_tools
}

main "$@"
