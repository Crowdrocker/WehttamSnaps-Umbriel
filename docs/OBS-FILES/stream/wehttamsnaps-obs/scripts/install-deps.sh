#!/usr/bin/env bash
# wehttamsnaps — one-shot Arch/CachyOS dependency installer for the OBS setup.
# Idempotent: safe to re-run. Uses pacman; AUR helpers (yay/paru) used only for
# packages not in the official repos.
set -euo pipefail

c() { printf '\033[1;36m>>>\033[0m %s\n' "$*"; }
e() { printf '\033[1;31m!!\033[0m %s\n' "$*" >&2; }

if ! command -v pacman >/dev/null; then
    e "This installer is for Arch/CachyOS (pacman). Aborting."
    exit 1
fi

AURHELPER=""
for h in yay paru; do
    if command -v "$h" >/dev/null; then AURHELPER="$h"; break; fi
done

# ---- core OBS + streaming stack ----
c "Installing OBS Studio + obs-websocket + capture/portal stack…"
sudo pacman -S --needed --noconfirm \
    obs-studio \
    obs-websocket \
    pipewire pipewire-pulse wireplumber \
    pavucontrol \
    qpwgraph \
    xdg-desktop-portal xdg-desktop-portal-wlr \
    ffmpeg \
    vulkan-radeon libva mesa-vdpau \
    $(pacman -Sq lib32-vulkan-radeon lib32-libva 2>/dev/null || true) \
    jq curl python python-pillow python-numpy \
    slurp grim wlr-randr

# ---- vainfo (verify the RX 580 encoder) ----
c "Installing libva-utils (vainfo) to verify the VA-API encoder…"
sudo pacman -S --needed --noconfirm libva-utils

# ---- audio noise suppression (RNNoise) ----
c "Installing RNNoise for PipeWire noise suppression…"
sudo pacman -S --needed --noconfirm rnnoise lsp-plugins 2>/dev/null || true
# optional GUIs:
sudo pacman -S --needed --noconfirm easyeffects noisetorch 2>/dev/null || true

# ---- streaming extras (optional, AUR) ----
if [ -n "$AURHELPER" ]; then
    c "Optional AUR packages via $AURHELPER (amdgpu_top, streamlink, obs-vkcapture)…"
    $AURHELPER -S --needed --noconfirm amdgpu_top streamlink obs-vkcapture 2>/dev/null || \
        e "Some AUR packages skipped — install manually if you want them."
else
    e "No AUR helper (yay/paru) found. Optional extras (amdgpu_top, streamlink,"
    e "obs-vkcapture) are in the AUR — install yay/paru first if you want them."
fi

# ---- set the VA-API driver env if missing ----
c "Ensuring LIBVA_DRIVER_NAME=radeonsi is set for the session…"
ENVDIR="/etc/environment.d"
ENVF="$ENVDIR/radeonsi.conf"
if ! grep -qs 'LIBVA_DRIVER_NAME=radeonsi' "$ENVF" 2>/dev/null; then
    sudo mkdir -p "$ENVDIR"
    echo 'LIBVA_DRIVER_NAME=radeonsi' | sudo tee "$ENVF" >/dev/null
    c "Wrote $ENVF (log out/in or reboot for it to take effect)."
else
    c "Already set in $ENVF."
fi

# ---- verify ----
c "Verifying VA-API encoder support on the RX 580…"
if command -v vainfo >/dev/null; then
    if vainfo 2>/dev/null | grep -qE 'VAProfileH264High.*VAEntrypointEncSlice'; then
        c "✓ H.264 VA-API encode available."
    else
        e "✗ H.264 VA-API encode NOT found. Check the guide §3.7 troubleshooting."
    fi
    if vainfo 2>/dev/null | grep -qE 'VAProfileHEVCMain.*VAEntrypointEncSlice'; then
        c "✓ HEVC VA-API encode available (use for local recording)."
    fi
    if vainfo 2>/dev/null | grep -qE 'VAProfileVP9Profile0.*VAEntrypointEnc'; then
        c "✓ VP9 VA-API encode available (unexpected on Polaris — bonus)."
    else
        c "  (VP9 encode not exposed on Polaris — expected; use H.264 for stream.)"
    fi
else
    e "vainfo not runnable yet — re-run after logging back in."
fi

c "Done. Next steps:"
c "  1. Log out/in (or reboot) so LIBVA_DRIVER_NAME takes effect."
c "  2. Open OBS, import scene-collection/wehttamsnaps.json."
c "  3. Follow docs/WEHTTAMSNAPS-OBS-GUIDE.md sections 3-5 for encoder + audio."
