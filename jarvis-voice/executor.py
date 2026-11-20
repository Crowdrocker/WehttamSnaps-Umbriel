import os
import shutil
import subprocess
import obsws_python as obs

OBS_HOST = "192.168.1.18"  # AM4 Windows 11 streaming PC IP (or "localhost")
OBS_PORT = 4455
OBS_PASSWORD = "REPLACE_WITH_OBS_WEBSOCKET_PASSWORD"

SOUND_BIN = shutil.which("sound-system") or "/usr/bin/sound-system"

def play_sfx(cue: str) -> None:
    if os.path.exists(SOUND_BIN) or shutil.which("sound-system"):
        subprocess.Popen([SOUND_BIN, cue], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def execute_action(data: dict) -> str:
    intent = data.get("intent", "chat")
    target = data.get("target", "")
    reply = data.get("reply", "Done.")

    if intent == "obs_scene":
        try:
            client = obs.ReqClient(host=OBS_HOST, port=OBS_PORT, password=OBS_PASSWORD, timeout=3)
            client.set_current_program_scene(target)
        except Exception as e:
            return f"OBS WebSocket connection failed: {e}"

    elif intent == "audio_mute":
        sink = "@DEFAULT_AUDIO_SOURCE@" if "mic" in target.lower() else target
        subprocess.run(["wpctl", "set-mute", sink, "toggle"], check=False)

    elif intent == "workflow_mode":
        if target in ("gamemode", "workmode"):
            play_sfx(target)

    elif intent == "photo_workflow":
        if target == "import_photos":
            subprocess.Popen(["dolphin", os.path.expanduser("~/Pictures")], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    elif intent == "launch_app":
        app_map = {
            "darktable": ["darktable"],
            "upscayl": ["upscayl"],
            "gimp": ["gimp"],
            "steam": ["steam"],
            "obs": ["obs"],
            "dolphin": ["dolphin"],
            "game_launcher": [os.path.expanduser("~/.local/bin/game-launcher")],
        }
        cmd = app_map.get(target.lower())
        if cmd and (shutil.which(cmd[0]) or os.path.exists(cmd[0])):
            cue = "steam-launch" if target.lower() == "steam" else "open-terminal"
            play_sfx(cue)
            subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    return reply
