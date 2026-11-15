#!/usr/bin/env bash

# ── COLOR DEFINITIONS (Cyberpunk Neon Palette) ──
C_CYAN="\e[1;36m"
C_MAGENTA="\e[1;35m"
C_GREEN="\e[1;32m"
C_DIM="\e[90m"
C_NC="\e[0m"

# Print Header Block (79 columns wide to match table)
echo -e "${C_CYAN}╭─────────────────────────────────────────────────────────────────────────────╮${C_NC}"
echo -e "${C_CYAN}│${C_NC}  ${C_MAGENTA}🪐 WEHTTAMSNAPS COMPACT SYSTEM CORE INTERFACE ACTIVATED${C_NC}                    ${C_CYAN}│${C_NC}"
echo -e "${C_CYAN}╰─────────────────────────────────────────────────────────────────────────────╯${C_NC}"

# Section 1: Window Management & Display Navigation
printf "  ${C_CYAN}%-14s${C_NC} %-20s │ ${C_MAGENTA}%-18s${C_NC} %-20s\n" \
    "Mod+Return/T" "Ghostty Terminal" \
    "Mod+Alt+H"    "Focus Game Monitor" \
    "Mod+E"        "Yazi File Manager" \
    "Mod+Alt+L"    "Focus Stream Monitor" \
    "Mod+Q"        "Close Active Win" \
    "Mod+Alt+Shift+H/L" "Throw Window L/R" \
    "Mod+Shift+R"  "Hard-Reload Umbriel" \
    "Mod+Alt+G"    "Game Launcher Menu"

echo -e "  ${C_DIM}─────────────────────────────────────────────────────────────────────────────${C_NC}"

# Section 2: PipeWire Audio Matrix Profile Shifts
printf "  ${C_CYAN}%-14s${C_NC} %-20s │ ${C_MAGENTA}%-18s${C_NC} %-20s\n" \
    "set-game"     "Mix Streaming Bal" \
    "Mod+Ctrl+T"   "Twitch Container" \
    "set-chill"    "Mix Ambient Mode" \
    "Mod+Ctrl+Y"   "YouTube Container" \
    "audio-reset"  "Flush Sound Pipes" \
    "Mod+Ctrl+D"   "Discord Container" \
    "audio-graph"  "Open qpwgraph Panel" \
    "Mod+Ctrl+S"   "Spotify Container"

echo -e "  ${C_DIM}─────────────────────────────────────────────────────────────────────────────${C_NC}"

# Section 3: Custom Shell Utilities (Nano-First)
printf "  ${C_GREEN}%-10s${C_NC} %-24s │ ${C_GREEN}%-18s${C_NC} %-20s\n" \
    "y"        "Yazi + Auto-CD" \
    "snv"      "Sudo Nano Editor" \
    "nvm"      "Nano Current Dir" \
    "sys"      "Btop System Monitor"

echo ""
