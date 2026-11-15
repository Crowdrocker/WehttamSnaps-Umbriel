Hypr config · SH
#!/bin/bash

# Hyprland config picker. Prefers a modular folder, falls back to ~/.config/hypr
CONFDIR="$HOME/.config/hypr/conf"
app=micro

if [ ! -d "$CONFDIR" ]; then
    CONFDIR="$HOME/.config/hypr"
fi
echo "Hyprland Config Directory: $CONFDIR"

# List files and preview them with bat
selected=$(ls -1 "$CONFDIR" | fzf --layout=reverse --preview="bat --color=always \"$CONFDIR/{}\"")

echo "Selected configuration module: $selected"

if [ -n "$selected" ]; then
    $app "$CONFDIR/$selected"
    echo "Opened $CONFDIR/$selected in $app"
else
    echo "No file selected."
fi


