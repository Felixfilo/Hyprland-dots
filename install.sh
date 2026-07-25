#!/usr/bin/env bash
# ==============================================================================
#  Custom Hyprland Dotfiles Installer
#  Includes: Hyprland, Rofi, Wallust, Waybar, Terminals, Starship, Fastfetch,
#            ble.sh (Bash Line Editor: Syntax Highlighting & Auto-suggestions),
#            Zsh plugins (zsh-autosuggestions, zsh-syntax-highlighting).
# ==============================================================================

set -e

GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}====================================================${RESET}"
echo -e "${GREEN}    Custom Hyprland Setup & Dependency Installer   ${RESET}"
echo -e "${BLUE}====================================================${RESET}"
echo

# 1. Check for AUR Helper (yay or paru)
AUR_HELPER=""
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
else
    echo -e "${RED}[!] Neither yay nor paru was found.${RESET}"
    echo -e "${YELLOW}[*] Installing yay AUR helper...${RESET}"
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin
    makepkg -si --noconfirm
    cd "$SCRIPT_DIR"
    AUR_HELPER="yay"
fi

echo -e "${GREEN}[+] Using AUR Helper:${RESET} $AUR_HELPER"

# 2. Package List Definition
CORE_PACKAGES=(
    hyprland
    swww
    wallust
    rofi
    waybar
    swaync
    hyprlock
    hypridle
    hyprsunset
    cliphist
    wl-clipboard
    grim
    slurp
    swappy
    pamixer
    pavucontrol
    brightnessctl
    playerctl
    thunar
    ghostty
    kitty
    wlogout
    nwg-look
    adw-gtk-theme
    darkman
    kvantum
    kvantum-qt5
    qt5ct
    qt6ct
    xdg-desktop-portal-hyprland
    jq
    imagemagick
    fastfetch
    starship
    btop
    cava
    zsh-autosuggestions
    zsh-syntax-highlighting
    gawk
    make
)

FONT_PACKAGES=(
    adobe-source-code-pro-fonts
    noto-fonts-emoji
    otf-font-awesome
    ttf-fira-code
    ttf-jetbrains-mono
    ttf-jetbrains-mono-nerd
    ttf-victor-mono
    noto-fonts
)

# 3. Install System & Hyprland Packages
echo -e "\n${YELLOW}[1/5] Installing essential Hyprland packages...${RESET}"
$AUR_HELPER -S --needed --noconfirm "${CORE_PACKAGES[@]}"

# 4. Install Fonts
echo -e "\n${YELLOW}[2/5] Installing required fonts...${RESET}"
$AUR_HELPER -S --needed --noconfirm "${FONT_PACKAGES[@]}"

# 5. Install ble.sh (Bash Line Editor for Command Highlighting & Auto-suggestions)
echo -e "\n${YELLOW}[3/5] Setting up ble.sh (Syntax Coloring & Auto-suggestions for Bash)...${RESET}"
if [ ! -f "$HOME/.local/share/blesh/ble.sh" ]; then
    echo -e "${YELLOW}[*] Downloading and building ble.sh...${RESET}"
    rm -rf /tmp/ble.sh
    git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh
    make -C /tmp/ble.sh install PREFIX="$HOME/.local"
    rm -rf /tmp/ble.sh
    echo -e "${GREEN}[+] ble.sh installed successfully!${RESET}"
else
    echo -e "${GREEN}[+] ble.sh is already installed.${RESET}"
fi

# 6. Configure Shells (Bash & Zsh)
echo -e "\n${YELLOW}[4/5] Configuring ~/.bashrc and ~/.zshrc...${RESET}"

# Setup Bash
BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ]; then
    if ! grep -q "blesh/ble.sh" "$BASHRC"; then
        echo -e "\n# Load ble.sh (Command Highlighting & Auto-suggestions)" >> "$BASHRC"
        echo '[ -f "$HOME/.local/share/blesh/ble.sh" ] && source "$HOME/.local/share/blesh/ble.sh"' >> "$BASHRC"
    fi
    if ! grep -q "fastfetch" "$BASHRC"; then
        echo -e "\n# Fastfetch auto-run" >> "$BASHRC"
        echo 'if command -v fastfetch &>/dev/null; then fastfetch; fi' >> "$BASHRC"
    fi
    if ! grep -q "starship init" "$BASHRC"; then
        echo -e "\n# Starship Prompt Init" >> "$BASHRC"
        echo 'eval "$(starship init bash)"' >> "$BASHRC"
    fi
    echo -e "${GREEN}[+] Configured ble.sh, Starship & Fastfetch in ~/.bashrc${RESET}"
fi

# Setup Zsh
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    if ! grep -q "zsh-autosuggestions" "$ZSHRC"; then
        echo -e "\n# Zsh Plugins" >> "$ZSHRC"
        echo '[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' >> "$ZSHRC"
        echo '[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> "$ZSHRC"
    fi
    if ! grep -q "fastfetch" "$ZSHRC"; then
        echo 'if command -v fastfetch &>/dev/null; then fastfetch; fi' >> "$ZSHRC"
    fi
    if ! grep -q "starship init" "$ZSHRC"; then
        echo 'eval "$(starship init zsh)"' >> "$ZSHRC"
    fi
    echo -e "${GREEN}[+] Configured Zsh Auto-suggestions & Syntax Highlighting in ~/.zshrc${RESET}"
fi

# Enforce Global Dark Mode Preference
echo -e "\n${YELLOW}[*] Enforcing global dark mode preference...${RESET}"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || true

# 7. Deploy Dotfiles (with safety backup)
echo -e "\n${YELLOW}[5/5] Deploying custom configuration files...${RESET}"

BACKUP_DIR="$HOME/.config/hypr-backup-$(date +%Y%m%d_%H%M%S)"

confirm_deploy() {
    read -p "Do you want to deploy these custom dotfiles to ~/.config and ~/.blerc now? [y/N]: " choice
    case "$choice" in
        [yY][eE][sS]|[yY])
            echo -e "${YELLOW}[*] Backing up existing configs to $BACKUP_DIR...${RESET}"
            mkdir -p "$BACKUP_DIR"
            [ -d "$HOME/.config/hypr" ] && cp -r "$HOME/.config/hypr" "$BACKUP_DIR/"
            [ -d "$HOME/.config/rofi" ] && cp -r "$HOME/.config/rofi" "$BACKUP_DIR/"
            [ -d "$HOME/.config/wallust" ] && cp -r "$HOME/.config/wallust" "$BACKUP_DIR/"
            [ -d "$HOME/.config/fastfetch" ] && cp -r "$HOME/.config/fastfetch" "$BACKUP_DIR/"
            [ -d "$HOME/.config/kitty" ] && cp -r "$HOME/.config/kitty" "$BACKUP_DIR/"
            [ -d "$HOME/.config/ghostty" ] && cp -r "$HOME/.config/ghostty" "$BACKUP_DIR/"
            [ -d "$HOME/.config/waybar" ] && cp -r "$HOME/.config/waybar" "$BACKUP_DIR/"
            [ -d "$HOME/.config/swaync" ] && cp -r "$HOME/.config/swaync" "$BACKUP_DIR/"
            [ -f "$HOME/.config/starship.toml" ] && cp "$HOME/.config/starship.toml" "$BACKUP_DIR/"
            [ -f "$HOME/.blerc" ] && cp "$HOME/.blerc" "$BACKUP_DIR/"

            echo -e "${GREEN}[+] Copying custom dotfiles into ~/.config/...${RESET}"
            mkdir -p "$HOME/.config/hypr" "$HOME/.config/rofi" "$HOME/.config/wallust" "$HOME/.config/fastfetch" "$HOME/.config/kitty" "$HOME/.config/ghostty" "$HOME/.config/waybar" "$HOME/.config/swaync"
            cp -r "$SCRIPT_DIR/hypr/"* "$HOME/.config/hypr/"
            cp -r "$SCRIPT_DIR/rofi/"* "$HOME/.config/rofi/"
            cp -r "$SCRIPT_DIR/wallust/"* "$HOME/.config/wallust/"
            cp -r "$SCRIPT_DIR/fastfetch/"* "$HOME/.config/fastfetch/"
            cp -r "$SCRIPT_DIR/kitty/"* "$HOME/.config/kitty/"
            cp -r "$SCRIPT_DIR/ghostty/"* "$HOME/.config/ghostty/"
            [ -d "$SCRIPT_DIR/waybar" ] && cp -r "$SCRIPT_DIR/waybar/"* "$HOME/.config/waybar/"
            [ -d "$SCRIPT_DIR/swaync" ] && cp -r "$SCRIPT_DIR/swaync/"* "$HOME/.config/swaync/"
            cp "$SCRIPT_DIR/starship.toml" "$HOME/.config/starship.toml"
            [ -f "$SCRIPT_DIR/shell/blerc" ] && cp "$SCRIPT_DIR/shell/blerc" "$HOME/.blerc"
            chmod +x "$HOME/.config/hypr/scripts/"*.sh 2>/dev/null || true

            echo -e "${GREEN}====================================================${RESET}"
            echo -e "${GREEN}    Custom Hyprland Dotfiles Successfully Deployed! ${RESET}"
            echo -e "${GREEN}====================================================${RESET}"
            ;;
        *)
            echo -e "${BLUE}[i] Deployment skipped. Files remain safely in $SCRIPT_DIR${RESET}"
            ;;
    esac
}

confirm_deploy
