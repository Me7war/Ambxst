#!/usr/bin/env bash
set -euo pipefail

############################################
#                  HEADER
############################################

print_header() {
  clear
cat <<'EOF'

    █████╗ ███╗   ███╗██████╗ ███████╗██╗  ██╗████████╗███████╗
   ██╔══██╗████╗ ████║██╔══██╗██╔════╝██║  ██║╚══██╔══╝██╔════╝
   ███████║██╔████╔██║██████╔╝█████╗  ███████║   ██║   ███████╗
   ██╔══██║██║╚██╔╝██║██╔═══╝ ██╔══╝  ██╔══██║   ██║   ╚════██║
   ██║  ██║██║ ╚═╝ ██║██║     ███████╗██║  ██║   ██║   ███████║
   ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝
                   Ported by Ghosty
         Axtremely Complete Ubuntu Installer
                Forked to Ubuntu 24.04 LTS

EOF
}

############################################
#           CORE CONFIGURATION
############################################

REMOTE_REPO_FILE="https://raw.githubusercontent.com/Me7war/Ambxst/refs/heads/main/repo"
INSTALL_PATH="${HOME}/.local/src/ambxst"
BIN_DIR="/usr/local/bin"

# Feature toggles
INSTALL_FLATPAK_APPS=1
INSTALL_TESSERACT_ALL=0
BUILD_QUICKSHELL=1
INSTALL_MATUGEN=1
INSTALL_WL_CLIP_PERSIST=1
INSTALL_PYTHON_TOOLS=1

############################################
#           COLORS / LOGGING
############################################

GREEN='\033[0;32m' BLUE='\033[0;34m' YELLOW='\033[1;33m' RED='\033[0;31m' NC='\033[0m'
log_center() { printf "   %b%s%b\n" "${BLUE}" "$1" "${NC}"; }
log_ok()     { printf "   %b✔ %s%b\n" "${GREEN}" "$1" "${NC}"; }
log_warn()   { printf "   %b⚠ %s%b\n" "${YELLOW}" "$1" "${NC}"; }
log_err()    { printf "   %b✖ %s%b\n" "${RED}" "$1" "${NC}"; }

############################################
#         PACKAGE FILTERING (Ubuntu)
############################################

declare -A BINARY_CHECK=(
  ["qs"]="qs"
  ["matugen"]="matugen"
  ["wl-clip-persist"]="wl-clip-persist"
)

filter_packages() {
  local pkgs=("$@")
  local to_install=()

  for pkg in "${pkgs[@]}"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
      log_center "Skipping $pkg (already installed)"
    else
      to_install+=("$pkg")
    fi
  done

  echo "${to_install[@]}"
}

############################################
#         USER INTERACTION
############################################

MODE=""
ask_mode() {
  print_header
  log_center "Choose prompt mode:"
  echo "     1) Prompt for each step"
  echo "     2) Yes to all (automatic)"
  echo "     3) Exit"
  echo ""
  read -rp "   Select [1/2/3]: " choice
  case "$choice" in
    1) MODE="prompt" ;;
    2) MODE="auto" ;;
    *) log_err "Aborted."; exit 1 ;;
  esac
}

confirm_step() {
  [[ "$MODE" == "auto" ]] && return 0
  read -rp "   $1 [y/N]: " yn
  [[ "$yn" =~ ^[Yy]$ ]]
}

############################################
#         REQUIREMENTS
############################################

require_user() {
  if [[ "$EUID" -eq 0 ]]; then
    log_err "Run as your user (not root). sudo will be used where needed."
    exit 1
  fi
}

require_ubuntu_24() {
  [[ ! -r /etc/os-release ]] && { log_err "Cannot detect OS."; exit 1; }
  source /etc/os-release
  if [[ "$ID" != "ubuntu" || ! "$VERSION_ID" =~ ^24\.04 ]]; then
    log_err "This script targets Ubuntu 24.04.* LTS."
    exit 1
  fi
  log_center "Detected Ubuntu ${VERSION_ID} (${VERSION_CODENAME})"
}

############################################
#         INSTALL HELPERS
############################################

apt_install_filtered() {
  read -ra to_install <<< "$(filter_packages "$@")"
  if [[ ${#to_install[@]} -gt 0 ]]; then
    sudo apt update -y
    sudo apt install -y --no-install-recommends "${to_install[@]}"
  else
    log_center "Nothing to install (all already present)"
  fi
}

enable_universe_and_hyprland_ppa() {
  if confirm_step "Enable universe & add Hyprland PPA?"; then
    apt_install_filtered software-properties-common
    sudo add-apt-repository -y universe
    sudo add-apt-repository -y ppa:cppiber/hyprland
    sudo apt update -y
  fi
}

############################################
#       REMOTE REPO URL
############################################

fetch_repo_url() {
  log_center "Fetching repo URL from remote..."
  if command -v curl >/dev/null 2>&1; then
    REPO_URL="$(curl -fsSL "$REMOTE_REPO_FILE")"
  else
    log_err "curl is required"
    exit 1
  fi
  [[ -z "$REPO_URL" ]] && { log_err "Empty repo URL"; exit 1; }
  log_ok "Repo URL: $REPO_URL"
}

############################################
#       DOTFILES IMPORT
############################################

ask_dotfile() {
  if confirm_step "Import custom dotfiles from raw URL?"; then
    read -rp "Enter raw dots file URL (must begin with !GSH): " DOT_RAW
  fi
}

import_dots() {
  [[ -z "${DOT_RAW:-}" ]] && return
  tmp="$(mktemp)"
  curl -fsSL "$DOT_RAW" > "$tmp"
  if grep -q "^!GSH" "$tmp"; then
    bash "$tmp"
  else
    log_err "Invalid dots file (missing !GSH header)"
  fi
  rm -f "$tmp"
}

############################################
#         INSTALL STEPS
############################################

install_base_deps() {
  log_center "Installing base dependencies..."
  enable_universe_and_hyprland_ppa
  apt_install_filtered git curl unzip build-essential python3-pip pipx
}

install_hyprland_from_ppa() {
  log_center "Installing Hyprland packages from PPA..."
  apt_install_filtered hyprland hyprcursor hyprgraphics hyprland-plugins hyprland-protocols hyprland-qt-support hyprland-qtutils fuzzel glaze gtk-layer-shell
}

install_core_deps() {
  log_center "Installing core runtime tools..."
  apt_install_filtered kitty tmux network-manager-gnome blueman pipewire wireplumber easyeffects playerctl brightnessctl ddcutil grim slurp wl-clipboard wtype jq
}

install_ocr_and_fonts() {
  log_center "Installing OCR & fonts..."
  apt_install_filtered tesseract-ocr
  if [[ "$INSTALL_TESSERACT_ALL" -eq 1 ]]; then
    apt_install_filtered tesseract-ocr-all
  fi
  apt_install_filtered fonts-noto-cjk breeze-icon-theme hicolor-icon-theme
}

install_build_tools() {
  if [[ "$BUILD_QUICKSHELL" -eq 1 ]]; then
    log_center "Building Quickshell..."
    apt_install_filtered cmake ninja-build qtbase5-dev qtwayland5-dev libxcb-dri3-dev libinput-dev
    git clone --recursive https://git.outfoxxed.me/outfoxxed/quickshell "${HOME}/quickshell-src"
    mkdir -p "${HOME}/quickshell-src/build"
    cd "${HOME}/quickshell-src/build"
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${HOME}/.local" ..
    make -j"$(nproc)"
    make install
    cd - >/dev/null
  fi

  if [[ "$INSTALL_MATUGEN" -eq 1 ]]; then
    log_center "Installing Rust toolchain & matugen..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "${HOME}/.cargo/env"
    cargo install matugen || log_warn "matugen install failed"
  fi

  if [[ "$INSTALL_WL_CLIP_PERSIST" -eq 1 ]]; then
    log_center "Building wl-clip-persist..."
    git clone https://github.com/Linus789/wl-clip-persist "${HOME}/wlclip-src"
    cd "${HOME}/wlclip-src"
    cargo build --release
    install -Dm755 "target/release/wl-clip-persist" "${HOME}/.local/bin/wl-clip-persist"
    cd - >/dev/null
  fi

  if [[ "$INSTALL_PYTHON_TOOLS" -eq 1 ]]; then
    log_center "Installing Python tools via pipx..."
    pipx ensurepath >/dev/null 2>&1 || true
    pipx install "litellm[proxy]" --python "$(command -v python3)" >/dev/null 2>&1 || true
  fi
}

install_flatpak_apps() {
  [[ "$INSTALL_FLATPAK_APPS" -eq 0 ]] && return
  if confirm_step "Install Flatpak applications?"; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install -y flathub be.alexandervanhee.gradia || true
    sudo flatpak install -y flathub com.dec05eba.gpu_screen_recorder || true
  fi
}

setup_services() {
  log_center "Configuring system services..."
  sudo systemctl enable --now NetworkManager || log_warn "NetworkManager service"
}

setup_launcher() {
  log_center "Creating launcher..."
  sudo mkdir -p "$BIN_DIR"
  sudo tee "$BIN_DIR/ambxst" >/dev/null <<EOF
#!/usr/bin/env bash
export PATH="\$HOME/.local/bin:\$PATH"
exec "${INSTALL_PATH}/cli.sh" "\$@"
EOF
  sudo chmod +x "$BIN_DIR/ambxst"
  log_ok "Launcher created"
}

############################################
# Run installation
############################################

require_user
require_ubuntu_24
ask_mode
fetch_repo_url
ask_dotfile

install_base_deps
install_hyprland_from_ppa
install_core_deps
install_ocr_and_fonts
install_build_tools
install_flatpak_apps
setup_services
setup_launcher
import_dots

log_ok "Installation complete!"
echo "Run: ambxst"

