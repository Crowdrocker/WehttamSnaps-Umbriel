import sounddevice as sd
from faster_whisper import WhisperModel

model = WhisperModel("base.en", device="cpu", compute_type="int8")

def listen_and_transcribe(seconds: int = 4, samplerate: int = 16000) -> str:
    audio = sd.rec(int(seconds * samplerate), samplerate=samplerate, channels=1, dtype="float32")
    sd.wait()
    segments, _ = model.transcribe(audio.flatten(), beam_size=1, vad_filter=True)
    return " ".join(seg.text.strip() for seg in segments).strip()
