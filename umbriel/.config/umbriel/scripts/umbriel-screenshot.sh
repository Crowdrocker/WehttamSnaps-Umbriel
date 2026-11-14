#!/usr/bin/env bash

MODE="${1:-full}" # full | region | window
DIR="$HOME/Pictures/Screenshots"
DEVICE_NAME=""
SOUND="/usr/share/wehttamsnaps/sounds/jarvis/jarvis-screenshot.mp3"

mkdir -p "$DIR"
TIME=$(date +"%d-%m-%Y_%H-%M-%S")
FILE="$DIR/Screenshot_${TIME}.png"

if [ -z "$WAYLAND_DISPLAY" ]; then
    notify-send "❌ Not running in Wayland"
    exit 1
fi

case "$MODE" in
    "region")
        GEOM=$(slurp 2>/dev/null)
        if [ -z "$GEOM" ]; then
            notify-send "Screenshot cancelled"
            paplay /usr/share/sounds/freedesktop/stereo/dialog-error.oga &
            exit 0
        fi
        grim -g "$GEOM" "$FILE"
        ;;
    "window")
        # Extract focused window geometry (X,Y WxH) from Umbriel IPC
        GEOM=$(umbriel focused-window 2>/dev/null | grep -oE '[0-9]+,[0-9]+ [0-9]+x[0-9]+' | head -n 1)
        if [ -z "$GEOM" ]; then
            notify-send "⚠️ Window geometry not found" "Select window manually"
            GEOM=$(slurp 2>/dev/null) || exit 0
        fi
        grim -g "$GEOM" "$FILE"
        ;;
    "full"|*)
        grim "$FILE"
        ;;
esac

if [ ! -f "$FILE" ]; then
    notify-send "❌ Screenshot failed"
    paplay /usr/share/sounds/freedesktop/stereo/dialog-error.oga &
    exit 1
fi

# Copy to clipboard & play J.A.R.V.I.S. sound
wl-copy < "$FILE"
[ -f "$SOUND" ] && paplay "$SOUND" &

# Send to phone via KDE Connect
if ! pgrep -x kdeconnectd >/dev/null; then
    kdeconnectd &
    sleep 2
fi

if [ -n "$DEVICE_NAME" ]; then
    DEVICE_ID=$(kdeconnect-cli -a | grep "$DEVICE_NAME" | cut -d':' -f1)
else
    DEVICE_ID=$(kdeconnect-cli -a --id-only | head -n 1)
fi

if [ -n "$DEVICE_ID" ]; then
    if kdeconnect-cli -d "$DEVICE_ID" --share "$FILE"; then
        notify-send "Sent to your phone" "$(basename "$FILE")"
    else
        notify-send "Send failed" "Saved locally"
    fi
else
    notify-send "⚠️ No device found" "Saved locally"
    paplay /usr/share/sounds/freedesktop/stereo/message.oga &
fi
