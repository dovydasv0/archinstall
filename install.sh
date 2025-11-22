#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "### Starting Arch Linux Hyprland Setup (VM Safe Mode) ###"

# 1. Update System and Install Base Build Tools
echo "--- Updating system and installing base-devel ---"
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm base-devel git

# 2. Install AUR Helper (Yay)
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

# 3. Install Core Suite
echo "--- Installing Core Applications ---"
# We add 'mesa' here to ensure basic graphics libraries exist
sudo pacman -S --needed --noconfirm hyprland zsh dolphin neovim tmux mesa

# 4. Install Ghostty and Walker (AUR)
echo "--- Installing Ghostty and Walker ---"
yay -S --needed --noconfirm ghostty walker-bin

# 5. Install Essential Glue (Audio, Fonts, Portals)
echo "--- Installing Dependencies ---"
DEPS=(
    waybar
    dunst
    pipewire
    pipewire-pulse
    wireplumber
    xdg-desktop-portal-hyprland
    polkit-gnome
    qt5-wayland
    qt6-wayland
    hyprpaper
    ttf-jetbrains-mono-nerd
    network-manager-applet
)
sudo pacman -S --needed --noconfirm "${DEPS[@]}"

# 6. Change Shell to Zsh
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "--- Changing default shell to Zsh ---"
    chsh -s /usr/bin/zsh
fi

# 7. CREATE HYPRLAND CONFIG WITH VM FIX
# We pre-generate the config file with the critical fix for VirtualBox
echo "--- Generating Hyprland Config for VM ---"
mkdir -p ~/.config/hypr

# If config doesn't exist, create it with the VM fix
if [ ! -f ~/.config/hypr/hyprland.conf ]; then
cat <<EOT > ~/.config/hypr/hyprland.conf
# --- VM SPECIFIC FIXES ---
env = WLR_NO_HARDWARE_CURSORS,1
env = WLR_RENDERER_ALLOW_SOFTWARE,1

# --- STARTUP ---
exec-once = dunst
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = waybar
exec-once = walker --gapplication-service

# --- INPUT ---
input {
    kb_layout = us
    follow_mouse = 1
}

# --- KEYBINDINGS ---
\$mainMod = SUPER
bind = \$mainMod, T, exec, ghostty
bind = \$mainMod, Q, killactive
bind = \$mainMod, M, exit
bind = \$mainMod, E, exec, dolphin
bind = \$mainMod, SPACE, exec, walker

# --- DISPLAY ---
monitor=,preferred,auto,1
EOT
    echo "Created ~/.config/hypr/hyprland.conf with VM fixes."
else
    echo "Config already exists. Please manually add 'env = WLR_RENDERER_ALLOW_SOFTWARE,1' to it."
fi

echo "### Setup Complete! ###"
echo "Type 'Hyprland' to start."
