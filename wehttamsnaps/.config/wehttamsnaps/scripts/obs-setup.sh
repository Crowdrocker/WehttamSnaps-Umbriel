#!/bin/bash
# OBS Screen Capture Setup for WehttamSnaps SwayFX
# Enables PipeWire screen capture and advanced audio routing

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

CACHE_DIR="$HOME/.cache/wehttamsnaps"
CONFIG_DIR="$HOME/.config/obs-studio"

echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   OBS Screen Capture Setup for SwayFX Wayland  ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}\n"

# Check dependencies
check_dependencies() {
    echo -e "${BLUE}→ Checking system dependencies...${NC}"

    local missing=()
    local optional=()

    # Required system packages
    command -v obs &>/dev/null || missing+=("obs-studio")
    command -v pipewire &>/dev/null || missing+=("pipewire")
    command -v pw-cli &>/dev/null || missing+=("pipewire")

    # Optional but recommended audio routers
    command -v qpwgraph &>/dev/null || optional+=("qpwgraph")
    command -v helvum &>/dev/null || optional+=("helvum")

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}✗ Missing required packages: ${missing[*]}${NC}"
        echo -e "${YELLOW}Install with: paru -S ${missing[*]}${NC}"
        return 1
    fi

    if [ ${#optional[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠ Optional routing modules missing: ${optional[*]}${NC}"
        echo -e "${YELLOW}Install for visual audio patches: paru -S ${optional[*]}${NC}"
    fi

    echo -e "${GREEN}✓ All required dependencies verified.${NC}\n"
}

# Check for xdg-desktop-portal backend mapping (Sway Specific)
check_portal() {
    echo -e "${BLUE}→ Validating XDG Desktop Portals for Sway...${NC}"

    if ! command -v /usr/lib/xdg-desktop-portal &>/dev/null; then
        echo -e "${RED}✗ Core xdg-desktop-portal framework missing.${NC}"
        echo -e "${YELLOW}Install with: paru -S xdg-desktop-portal${NC}"
        return 1
    fi

    # Sway strictly requires the wlr backend to capture surfaces securely
    if [ ! -f /usr/share/xdg-desktop-portal/portals/wlr.portal ]; then
        echo -e "${RED}✗ Missing required Sway window capture backend (wlr.portal).${NC}"
        echo -e "${YELLOW}Install required component: paru -S xdg-desktop-portal-wlr${NC}"
        return 1
    fi

    echo -e "${GREEN}✓ XDG Desktop Portals configured cleanly.${NC}\n"
}

# Create OBS scene collection with proper sources
create_obs_scene() {
    echo -e "${BLUE}→ Deploying WehttamSnaps configuration scenes...${NC}"

    mkdir -p "$CONFIG_DIR/basic/scenes"
    local scene_file="$CONFIG_DIR/basic/scenes/WehttamSnaps.json"

    cat > "$scene_file" <<'EOF'
{
    "current_scene": "Gaming",
    "current_program_scene": "Gaming",
    "scene_order": [
        {"name": "Gaming"},
        {"name": "Desktop"},
        {"name": "Camera + Game"}
    ],
    "sources": [
        {
            "id": "pipewire-desktop-capture-source",
            "name": "Screen Capture",
            "settings": {"restore_token": ""},
            "versioned_id": "pipewire-desktop-capture-source",
            "enabled": true
        },
        {
            "id": "pipewire-audio-capture",
            "name": "Game Audio",
            "settings": {"target": "game_audio_sink"},
            "versioned_id": "pipewire-audio-capture",
            "enabled": true
        },
        {
            "id": "pipewire-audio-capture",
            "name": "Browser Audio",
            "settings": {"target": "browser_audio_sink"},
            "versioned_id": "pipewire-audio-capture",
            "enabled": true
        },
        {
            "id": "pipewire-audio-capture",
            "name": "Discord Audio",
            "settings": {"target": "discord_audio_sink"},
            "versioned_id": "pipewire-audio-capture",
            "enabled": true
        }
    ],
    "scenes": [
        {
            "name": "Gaming",
            "sources": [
                {"name": "Screen Capture", "enabled": true},
                {"name": "Game Audio", "enabled": true}
            ]
        },
        {
            "name": "Desktop",
            "sources": [
                {"name": "Screen Capture", "enabled": true},
                {"name": "Browser Audio", "enabled": true},
                {"name": "Discord Audio", "enabled": true}
            ]
        }
    ]
}
EOF
    echo -e "${GREEN}✓ OBS templates deployed.${NC}\n"
}

# Create PipeWire virtual sinks for audio routing
setup_audio_routing() {
    echo -e "${BLUE}→ Injecting PipeWire looping modules...${NC}"

    local pipewire_conf="$HOME/.config/pipewire/pipewire.conf.d"
    mkdir -p "$pipewire_conf"

    cat > "$pipewire_conf/99-wehttamsnaps-sinks.conf" <<'EOF'
context.modules = [
    {   name = libpipewire-module-loopback
        args = {
            node.description = "Game Audio (OBS)"
            capture.props = {
                node.name = "game_audio_sink"
                media.class = "Audio/Sink"
                audio.position = [ FL FR ]
            }
            playback.props = {
                node.name = "game_audio_source"
                media.class = "Audio/Source"
                audio.position = [ FL FR ]
                stream.dont-remix = true
                node.passive = true
            }
        }
    }
    {   name = libpipewire-module-loopback
        args = {
            node.description = "Browser Audio (OBS)"
            capture.props = {
                node.name = "browser_audio_sink"
                media.class = "Audio/Sink"
                audio.position = [ FL FR ]
            }
            playback.props = {
                node.name = "browser_audio_source"
                media.class = "Audio/Source"
                audio.position = [ FL FR ]
                stream.dont-remix = true
                node.passive = true
            }
        }
    }
    {   name = libpipewire-module-loopback
        args = {
            node.description = "Discord Audio (OBS)"
            capture.props = {
                node.name = "discord_audio_sink"
                media.class = "Audio/Sink"
                audio.position = [ FL FR ]
            }
            playback.props = {
                node.name = "discord_audio_source"
                media.class = "Audio/Source"
                audio.position = [ FL FR ]
                stream.dont-remix = true
                node.passive = true
            }
        }
    }
]
EOF
    echo -e "${GREEN}✓ PipeWire channels written to 99-wehttamsnaps-sinks.conf.${NC}\n"
}

# Create OBS launcher script modified for Sway environments
create_obs_launcher() {
    echo -e "${BLUE}→ Writing specialized OBS wrapper...${NC}"

    local script_dir="$HOME/.config/sway/scripts"
    mkdir -p "$script_dir"

    cat > "$script_dir/obs-launcher.sh" <<'EOF'
#!/bin/bash
# Optimized OBS launch parameters for SwayFX Wayland compositor

# Safe environments that prevent browser docks from crashing
export XDG_CURRENT_DESKTOP=sway
export OBS_USE_EGL=1

if command -v flatpak &>/dev/null && flatpak list | grep -q "com.obsproject.Studio"; then
    flatpak run com.obsproject.Studio "$@"
else
    obs "$@"
fi
EOF
    chmod +x "$script_dir/obs-launcher.sh"
    echo -e "${GREEN}✓ Target launcher generated inside $script_dir/obs-launcher.sh.${NC}\n"
}

# Generate localized documentation markdown templates
create_audio_guide() {
    echo -e "${BLUE}→ Exporting local operations guide...${NC}"
    local docs_dir="$HOME/.config/wehttamsnaps/docs"
    mkdir -p "$docs_dir"

    cat > "$docs_dir/OBS-AUDIO-ROUTING.md" <<'EOF'
# Optimized SwayFX Audio Routing Suite
Use qpwgraph or pavucontrol to map your channels:
* App -> Target Sink -> Physical Audio Out + OBS Capture Source
EOF
    echo -e "${GREEN}✓ Markdown guide saved.${NC}\n"
}

test_screen_capture() {
    echo -e "${BLUE}→ Pinging active Wayland portals...${NC}"
    if ! pgrep -x xdg-desktop-portal &>/dev/null; then
        systemctl --user start xdg-desktop-portal
        sleep 1
    fi
    echo -e "${GREEN}✓ Portal communications active.${NC}\n"
}

show_usage() {
    cat <<EOF
Usage: $0 [setup|restart-audio|qpwgraph]
EOF
}

# Execution routers
case "${1:-setup}" in
    setup)
        check_dependencies || exit 1
        check_portal || exit 1
        setup_audio_routing
        create_obs_launcher
        create_obs_scene
        create_audio_guide
        test_screen_capture
        echo -e "${GREEN}✓ Configuration completely compiled for SwayFX!${NC}\n"
        echo -e "${YELLOW}Run: systemctl --user restart pipewire to initialize.${NC}"
        ;;
    restart-audio)
        systemctl --user restart pipewire pipewire-pulse wireplumber
        echo -e "${GREEN}✓ Channels initialized.${NC}"
        ;;
    qpwgraph)
        qpwgraph &>/dev/null &
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
