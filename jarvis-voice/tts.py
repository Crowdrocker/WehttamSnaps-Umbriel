import os
import shutil
import subprocess

VENV_PIPER = os.path.expanduser("~/jarvis-voice/.venv/bin/piper")
PIPER_BIN = VENV_PIPER if os.path.exists(VENV_PIPER) else shutil.which("piper")

VOICE_CANDIDATES = [
    os.path.expanduser("~/.local/share/piper/voices/en_US-ryan-medium.onnx"),
    os.path.expanduser("~/.local/share/piper-voices/en_US-ryan-medium.onnx"),
]
VOICE_MODEL = next((p for p in VOICE_CANDIDATES if os.path.exists(p)), VOICE_CANDIDATES[0])

def speak(text: str) -> None:
    if not text:
        return

    subprocess.Popen(["notify-send", "J.A.R.V.I.S.", text], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    if PIPER_BIN and os.path.exists(VOICE_MODEL):
        piper_proc = subprocess.Popen(
            [PIPER_BIN, "--model", VOICE_MODEL, "--output-raw"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
        pw_proc = subprocess.Popen(
            ["pw-play", "--rate", "22050", "--channels", "1", "--format", "s16", "-"],
            stdin=piper_proc.stdout,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        if piper_proc.stdin:
            piper_proc.stdin.write(text.encode("utf-8"))
            piper_proc.stdin.close()
        if piper_proc.stdout:
            piper_proc.stdout.close()
        pw_proc.wait()
