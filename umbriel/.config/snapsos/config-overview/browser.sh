#!/usr/bin/env bash
set -euo pipefail

STRING="${1:-}"
COMPOSITOR="${2:-umbriel}"
LIST_FILE="$HOME/.config/snapsos/config-overview/options.list"

# Normalize line: strip comments/whitespace, extract TOML header or key before '=' or '{'
CLEAN=$(echo "$STRING" | sed 's/#.*//; s|//.*||' | xargs || true)

if [[ "$CLEAN" =~ ^\[+([^]]+)\]+ ]]; then
    KEY="${BASH_REMATCH[1]}"
elif [[ "$CLEAN" == *"="* ]]; then
    KEY=$(echo "$CLEAN" | cut -d '=' -f1 | xargs)
else
    KEY=$(echo "$CLEAN" | awk '{print $1}' | tr -d '{};')
fi

LINK=""
if [[ -n "$KEY" && -f "$LIST_FILE" ]]; then
    LINK=$(grep -E "^[[:space:]]*${KEY}[[:space:]]*\|" "$LIST_FILE" | head -n 1 | cut -d '|' -f4 | xargs || true)
fi

if [[ -z "$LINK" ]]; then
    if [[ "$COMPOSITOR" == "niri" ]]; then
        LINK="https://github.io"
    else
        LINK="https://noctalia.dev"
    fi
fi

firefox --new-tab "$LINK" >/dev/null 2>&1 &

