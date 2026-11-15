#!/usr/bin/env bash
set -euo pipefail

STRING="${1:-}"
COMPOSITOR="${2:-umbriel}"
LIST_FILE="$HOME/.config/snapsos/config-overview/options.list"

echo "## ${COMPOSITOR^^} Config Key Explainer"
echo ""

CLEAN=$(echo "$STRING" | sed 's/#.*//; s|//.*||' | xargs || true)

if [[ -z "$CLEAN" ]]; then
    echo "Comment or blank line selected."
    exit 0
fi

# Extract key from TOML table header, TOML key=val, or KDL block/property
if [[ "$CLEAN" =~ ^\[+([^]]+)\]+ ]]; then
    KEY="${BASH_REMATCH[1]}"
elif [[ "$CLEAN" == *"="* ]]; then
    KEY=$(echo "$CLEAN" | cut -d '=' -f1 | xargs)
else
    KEY=$(echo "$CLEAN" | awk '{print $1}' | tr -d '{};')
fi

MATCH=$(grep -E "^[[:space:]]*${KEY}[[:space:]]*\|" "$LIST_FILE" | head -n 1 || true)

if [[ -n "$MATCH" ]]; then
    EXAMPLE=$(echo "$MATCH" | cut -d '|' -f2 | xargs)
    EXPLAINER=$(echo "$MATCH" | cut -d '|' -f3 | xargs)
    LINK=$(echo "$MATCH" | cut -d '|' -f4 | xargs)
    EXTRA=$(echo "$MATCH" | cut -d '|' -f5 | xargs)

    echo "Key:         $KEY"
    echo "Example:     $EXAMPLE"
    echo "Description: $EXPLAINER"
    echo "Docs URL:    $LINK"
    echo ""
    echo "Extra Information:"
    case "$EXTRA" in
        window_rule)
            echo "Window rules match apps by app_id or title regex and apply overrides:"
            echo "  - default_floating = true / false"
            echo "  - default_fullscreen = true / false"
            echo "  - default_scratchpad = \"games\""
            echo "  - default_workspace = \"Gaming\""
            echo "  - default_column_width = { proportion = 0.8 }"
            echo "  - opacity = 0.95 | border_color = \"#89dceb\""
            ;;
        scratchpad)
            echo "Named scratchpads create persistent toggleable overlay windows:"
            echo "  - Declare [[scratchpad]] with name = \"games\" before referencing in keybinds."
            echo "  - Optional command = \"...\" spawns the app automatically if not running."
            echo "  - Toggle via keybind: action = \"scratchpad-toggle games\""
            ;;
        effects)
            echo "Umbriel supports custom GLSL shaders for borders and window animations:"
            echo "  - Load shader presets via [include.optional] files = [\".../effect.toml\"]"
            echo "  - Set border = \"spectrum\" or open/close = \"tv-glitch\" under [effects]"
            ;;
        layout)
            echo "Umbriel uses an infinite scrolling strip layout per monitor/workspace:"
            echo "  - preset_column_widths cycles window widths with Mod+R"
            echo "  - focus_ring / border control active and inactive window outlines"
            echo "  - gaps sets inner spacing between tiled columns"
            ;;
        keybinds)
            echo "Umbriel binds keys under [keybinds] using Mod (Super), Alt, Shift, Ctrl:"
            echo "  - \"Mod+Return\" = { action = \"spawn ghostty\" }"
            echo "  - \"Mod+Q\" = { action = \"close-window\", repeat = false }"
            echo "  - Set repeat = false on toggles and launchers to prevent double-triggers."
            ;;
        *)
            echo "Press Alt+B to open the official documentation in Firefox."
            ;;
    esac
else
    echo "Key: $KEY"
    echo "No specific entry found in options.list for '$KEY'."
    echo "Press Alt+B to open the main ${COMPOSITOR^} documentation in Firefox."
fi
