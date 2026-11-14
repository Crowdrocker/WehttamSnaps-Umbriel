#!/usr/bin/env bash

# File paths mapped cleanly to your GNU Stow directory structure
HUD_CONF="$HOME/.config/MangoHud/MangoHud.conf"

case "$1" in
    "minimal"|"fps")
        echo "📊 Switching MangoHUD to compact FPS profile..."
        sed -i 's/^legacy_layout=.*/legacy_layout=1/' "$HUD_CONF"
        ;;
    "cyberpunk"|"full")
        echo "🪐 Switching MangoHUD to full Cyberpunk specs profile..."
        sed -i 's/^legacy_layout=.*/legacy_layout=0/' "$HUD_CONF"
        ;;
esac

# Send a live reload signal to MangoHUD so it updates inside your running game instantly
pkill -HUP mangohud || true
notify-send "J.A.R.V.I.S." "MangoHUD profile shifted to: $1" -i speedometers
