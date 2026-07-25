# Personal Hyprland Dotfiles Setup

This is your custom, modular Hyprland configuration. It preserves your preferred **Rofi setups**, **keybindings**, **animations**, **Starship prompt**, **Fastfetch**, **Slide-down Dropdown Terminal**, **ble.sh Terminal Auto-suggestions & Command Syntax Highlighting**, and **wallpaper-responsive color themes (Wallust)** without unnecessary bloat.

---

## 📁 Directory Structure

```
Hyprland-dots/
├── hypr/                      # Hyprland modular configs & helper scripts
├── rofi/                      # Rofi launcher themes & menus
├── wallust/                   # Wallust templates & configuration
├── fastfetch/                 # Fastfetch system info configurations
├── kitty/                     # Kitty terminal config & themes
├── ghostty/                   # Ghostty terminal config
├── shell/                     # Shell configs (.blerc & .bashrc templates)
│   ├── blerc                  # ble.sh syntax highlighting & auto-suggestion colors
│   └── bashrc
├── starship.toml              # Custom Starship shell prompt config
└── install.sh                 # Complete automated package & dotfiles installer
```

---

## 💻 Terminal Auto-Suggestions & Command Coloring

Your terminal setup includes **`ble.sh` (Bash Line Editor)** & **Zsh plugins**:
- **Real-time Syntax Highlighting**:
  - Valid commands (builtins, aliases, executables) turn **Electric Cyan** (`#2ac3de`).
  - Errors and typos turn **Neon Pink** (`#ff2a6d`).
  - Strings and quotes turn **Green** (`#9ece6a`).
- **Real-time Auto-suggestions**: Ghost text suggestions appear in **Muted Slate** (`#565f89`) as you type. Press `Right Arrow` or `Tab` to complete.
- **Configured in**: `~/.blerc` (deployed automatically by `install.sh`).

---

## 🚀 How to Install & Deploy

To install all dependencies and deploy your custom configs:

```bash
cd ~/Hyprland-dots
./install.sh
```
