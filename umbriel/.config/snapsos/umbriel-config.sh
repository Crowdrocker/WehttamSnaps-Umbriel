#!/usr/bin/env bash
set -euo pipefail

CONFDIR="$HOME/.config/umbriel/config.d"
APP="${EDITOR:-nano}"

if [[ ! -d "$CONFDIR" ]]; then
    echo "⚠️  Directory $CONFDIR not found! Falling back to base umbriel folder."
    CONFDIR="$HOME/.config/umbriel"
fi

echo "🪐 Umbriel Config Directory: $CONFDIR"

selected=$(find "$CONFDIR" -maxdepth 2 -type f \( -name "*.toml" -o -name "*.glsl" \) | sed "s|$CONFDIR/||" | sort | \
    fzf --layout=reverse \
        --prompt="Umbriel Config > " \
        --header="Select a module to edit (Note: 10–80 are managed by iNiR; put overrides in 90-user-extra.toml)" \
        --preview="bat --color=always --style=numbers \"$CONFDIR/{}\"")

if [[ -n "${selected:-}" ]]; then
    target="$CONFDIR/$selected"
    before_hash=$(sha256sum "$target" | awk '{print $1}')

    "$APP" "$target"

    after_hash=$(sha256sum "$target" | awk '{print $1}')
    if [[ "$before_hash" != "$after_hash" ]]; then
        echo "🔍 Validating Umbriel configuration..."
        if umbriel config validate; then
            echo "✅ Valid! Reloading Umbriel live..."
            umbriel msg config-reload
        else
            echo "❌ Validation failed! Review errors above before reloading."
        fi
    else
        echo "No changes saved to $selected."
    fi
else
    echo "No file selected."
fi



