#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/jarvis-voice"
VOICE_DIR="$HOME/.local/share/piper-voices"

echo "🤖 Setting up J.A.R.V.I.S. Voice Control..."

# 1. Install system dependencies based on distro
if command -v pacman &>/dev/null; then
    sudo pacman -S --needed --noconfirm python portaudio pipewire-alsa libnotify ollama curl
elif command -v zypper &>/dev/null; then
    sudo zypper --non-interactive install python3 portaudio-devel pipewire-tools libnotify-tools curl
    command -v ollama &>/dev/null || curl -fsSL https://ollama.com | sh
elif command -v dnf &>/dev/null; then
    sudo dnf install -y python3 portaudio-devel pipewire-utils libnotify curl
    command -v ollama &>/dev/null || curl -fsSL https://ollama.com | sh
fi

# 2. Enable Ollama & pull qwen2.5:3b
sudo systemctl enable --now ollama || true
ollama pull qwen2.5:3b

# 3. Link or sync Python modules to ~/jarvis-voice
mkdir -p "$TARGET_DIR"
cp "$SCRIPT_DIR"/*.py "$TARGET_DIR/"

# 4. Build Python virtual environment & install packages
python3 -m venv "$TARGET_DIR/.venv"
"$TARGET_DIR/.venv/bin/pip" install --upgrade pip
"$TARGET_DIR/.venv/bin/pip" install faster-whisper sounddevice piper-tts numpy requests obsws-python

# 5. Download Piper TTS voice model (en_US-ryan-medium)
mkdir -p "$VOICE_DIR"
if [[ ! -f "$VOICE_DIR/en_US-ryan-medium.onnx" ]]; then
    echo "🗣️  Downloading Piper voice model (en_US-ryan-medium)..."
    curl -fL "https://huggingface.co" \
        -o "$VOICE_DIR/en_US-ryan-medium.onnx"
    curl -fL "https://huggingface.co.json" \
        -o "$VOICE_DIR/en_US-ryan-medium.onnx.json"
fi

echo "✅ J.A.R.V.I.S. Voice Control ready! Test with:"
echo "   $TARGET_DIR/.venv/bin/python $TARGET_DIR/main.py --once"
