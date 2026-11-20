import sys
import time
from stt import listen_and_transcribe
from brain import parse_intent
from executor import execute_action, play_sfx
from tts import speak

WAKE_WORD = "jarvis"

def run_once():
    play_sfx("open-terminal")
    time.sleep(0.6)
    text = listen_and_transcribe(seconds=4)
    if not text:
        return
    print(f"Heard: {text}")
    action_data = parse_intent(text)
    reply = execute_action(action_data)
    print(f"Reply: {reply}")
    speak(reply)

def run_loop():
    print("J.A.R.V.I.S. Voice Control Active...")
    while True:
        text = listen_and_transcribe(seconds=4)
        if not text:
            continue
        print(f"Heard: {text}")
        if WAKE_WORD in text.lower():
            command = text.lower().split(WAKE_WORD, 1).strip(" ,.!?")
            if not command:
                play_sfx("open-terminal")
                speak("Yes, Matthew?")
                command = listen_and_transcribe(seconds=5)
            if command:
                action_data = parse_intent(command)
                reply = execute_action(action_data)
                print(f"Reply: {reply}")
                speak(reply)

if __name__ == "__main__":
    if "--once" in sys.argv:
        run_once()
    else:
        run_loop()
