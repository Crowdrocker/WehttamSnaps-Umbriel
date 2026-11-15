#!/usr/bin/env bash
set -euo pipefail

CONFDIR="$HOME/.config/niri/config.d"
APP="${EDITOR:-nano}"

if [[ ! -d "$CONFDIR" ]]; then
    echo "⚠️  Directory $CONFDIR not found! Falling back to base niri folder."
    CONFDIR="$HOME/.config/niri"
fi

echo "🌊 Niri Config Directory: $CONFDIR"

selected=$(find "$CONFDIR" -maxdepth 2 -type f -name "*.kdl" | sed "s|$CONFDIR/||" | sort | \
    fzf --layout=reverse \
        --prompt="Niri Config > " \
        --preview="bat --color=always --style=numbers \"$CONFDIR/{}\"")

if [[ -n "${selected:-}" ]]; then
    target="$CONFDIR/$selected"
    before_hash=$(sha256sum "$target" | awk '{print $1}')

    "$APP" "$target"

    after_hash=$(sha256sum "$target" | awk '{print $1}')
    if [[ "$before_hash" != "$after_hash" ]] && command -v niri &>/dev/null; then
        echo "🔍 Validating Niri configuration..."
        niri validate
    fi
else
    echo "No file selected."
fi



