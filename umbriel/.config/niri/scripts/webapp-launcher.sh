#!/usr/bin/env bash

# ==============================================================================
# ---  WehttamSnaps Niri Configuration - Isolated Webapp Launcher
# ---  Author: Matthew (Crowdrocker)
# ---  Target: Handles modular containerized sandboxes via Brave Browser
# ==============================================================================

# Target Webapp Key Selector
APP_KEY=$(echo "$1" | tr '[:upper:]' '[:lower:]')

case "$APP_KEY" in
    "twitch")
        echo "📺 Launching Twitch isolated container..."
        brave --app="https://twitch.tv" --profile-directory="Twitch" &
        ;;
    "youtube")
        echo "🎥 Launching YouTube isolated container..."
        brave --app="https://youtube.com" --profile-directory="YouTube" &
        ;;
    "spotify")
        echo "🎵 Launching Spotify Webapp container..."
        brave --app="https://spotify.com" --profile-directory="Spotify" &
        ;;
    "discord")
        echo "💬 Launching Discord communication hub..."
        brave --app="https://discord.com" --profile-directory="Discord" &
        ;;
    *)
        echo "⚠️ Target webapp layer unknown: '$1'"
        echo "Usage: webapp-launcher.sh [twitch|youtube|spotify|discord]"
        exit 1
        ;;
esac

exit 0
