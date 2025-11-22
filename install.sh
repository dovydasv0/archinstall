#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "### Starting Arch Linux Hyprland Setup (with Walker) ###"

# 1. Update System and Install Base Build Tools
echo "--- Updating system and installing base-devel ---"
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm base-devel git

# 2. Install AUR Helper (Yay)
# Required for Ghostty and Walker
if ! command -v yay &> /dev/null; then
    echo "--- Installing yay (AUR Helper) ---"
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd ..
    rm -rf yay-bin
else
    echo "--- Yay is already installed ---"
fi

# 3. Install Core Suite (Repo Packages)
echo "--- Installing Core Applications ---"
# Removed wofi, kept the rest
sudo pacman -S --needed --noconfirm hyprland zsh dolphin neovim tmux

# 4. Install AUR Packages (Ghostty & Walker)
echo "--- Installing Ghostty and Walker from AUR ---"
# We install walker-bin to avoid long compilation times with Go
yay -S --needed --noconfirm ghostty walker-bin

# 5. Install Essential Environment 'Glue'
echo "--- Installing Desktop Environment Dependencies ---"

DEPS=(
    waybar                        # Status bar
    dunst                         # Notifications
    pipewire                      # Audio server
    pipewire-pulse                # Audio compatibility
    wireplumber                   # Audio session manager
    xdg-desktop-portal-hyprland   # Screensharing/Portals
    polkit-gnome                  # GUI Password prompts
    qt5-wayland                   # Qt5 support (Dolphin)
    qt6-wayland                   # Qt6 support (Dolphin)
    hyprpaper                     # Wallpaper utility
    ttf-jetbrains-mono-nerd       # Font for Ghostty/Waybar icons
    network-manager-applet        # Wi-Fi tray icon
    unzip                         # Archive tool
    ripgrep                       # Search tool for Neovim
    fd                            # Find tool for Neovim
    # gtk4                        # Walker usually pulls this in, but good to have
)

sudo pacman -S --needed --noconfirm "${DEPS[@]}"

# 6. Change Default Shell to Zsh
echo "--- Changing default shell to Zsh ---"
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    chsh -s /usr/bin/zsh
fi

echo "### Setup Complete! ###"
echo "Please reboot your system."
