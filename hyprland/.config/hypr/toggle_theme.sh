#!/bin/bash

# Configuration files
HELIX_CONFIG="$HOME/.config/helix/config.toml"
WEZTERM_CONFIG="$HOME/.config/wezterm/wezterm.lua"

# State
STATE_FILE="$HOME/.cache/theme-mode"
CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "dark")

if [ "$1" == "--restore" ]; then
    NEW_STATE="$CURRENT_STATE"
    echo "Restoring $NEW_STATE mode..."
else
    if [ "$CURRENT_STATE" == "dark" ]; then
        NEW_STATE="light"
    else
        NEW_STATE="dark"
    fi
    echo "Switching to $NEW_STATE mode..."
fi

if [ "$NEW_STATE" == "light" ]; then
    # Helix: Use github_light_high_contrast
    sed -i 's/^theme = "github_dark_high_contrast_custom"/theme = "github_light_high_contrast"/' "$HELIX_CONFIG"
    sed -i 's/^theme = "[^"]*"/theme = "github_light_high_contrast"/' "$HELIX_CONFIG"

    # WezTerm: background to white
    sed -i 's/background = "#0a0c10"/background = "#ffffff"/' "$WEZTERM_CONFIG"
    
    # GTK / System
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
    gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"
    
    [ "$1" != "--restore" ] && notify-send "Theme" "Switched to Light Mode"
else
    # Helix: Use github_dark_high_contrast_custom
    sed -i 's/^theme = "github_light_high_contrast"/theme = "github_dark_high_contrast_custom"/' "$HELIX_CONFIG"
    sed -i 's/^theme = "[^"]*"/theme = "github_dark_high_contrast_custom"/' "$HELIX_CONFIG"

    # WezTerm: background to dark
    sed -i 's/background = "#ffffff"/background = "#0a0c10"/' "$WEZTERM_CONFIG"

    # GTK / System
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"

    [ "$1" != "--restore" ] && notify-send "Theme" "Switched to Dark Mode"
fi

# Store state
echo "$NEW_STATE" > "$STATE_FILE"
