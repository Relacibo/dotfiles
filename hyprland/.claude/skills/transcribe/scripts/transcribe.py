# /// script
# requires-python = ">=3.10"
# dependencies = ["faster-whisper>=1.1"]
# ///
"""Transcribe an audio/video file with faster-whisper.

Usage: uv run transcribe.py <media> [--lang de] [--model large-v3-turbo] [--out transcript.txt]
Models are downloaded once from Hugging Face into ~/.cache/huggingface (download is verified).
"""
import argparse
import subprocess
import sys
from pathlib import Path


def load_audio(src: Path):
    # 16 kHz mono float32, loudness-normalised: helps a lot with quiet or noisy recordings.
    # Decoded by ffmpeg and handed over as an array, so faster-whisper's PyAV decoder is never used.
    import numpy as np

    raw = subprocess.run(
        ["ffmpeg", "-v", "error", "-i", str(src), "-vn", "-ar", "16000", "-ac", "1",
         "-af", "loudnorm", "-f", "f32le", "-"],
        check=True, capture_output=True,
    ).stdout
    return np.frombuffer(raw, dtype=np.float32)


def ts(sec: float) -> str:
    m, s = divmod(int(sec), 60)
    return f"{m:02d}:{s:02d}"


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("media", type=Path)
    p.add_argument("--lang", default="de", help="language code, 'auto' to detect")
    p.add_argument("--model", default="large-v3-turbo")
    p.add_argument("--out", type=Path, help="write transcript here as well")
    a = p.parse_args()

    from faster_whisper import WhisperModel

    audio = load_audio(a.media)
    model = WhisperModel(a.model, device="cpu", compute_type="int8")
    segments, info = model.transcribe(
        audio,
        language=None if a.lang == "auto" else a.lang,
        vad_filter=True,               # skip silence, fewer hallucinated repeats
        condition_on_previous_text=False,  # stops "Das ist ein sehr wichtiges Thema" loops
    )
    lines = [f"[{ts(s.start)}-{ts(s.end)}] {s.text.strip()}" for s in segments]

    text = "\n".join(lines)
    print(f"# language={info.language} p={info.language_probability:.2f} duration={info.duration:.0f}s", file=sys.stderr)
    print(text)
    if a.out:
        a.out.write_text(text + "\n")


if __name__ == "__main__":
    main()
