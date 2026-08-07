import wave
import struct
import os

"""
TamaPokeWear — Sound Generation Script
========================================
Generates all UI sound effects as WAV files using Game-Boy-style square-wave synthesis.
No external libraries required — only Python's built-in `wave` and `struct`.

Usage:
  python3 tools/generate_sounds.py

Output:
  assets/sounds/tap.wav
  assets/sounds/eat.wav
  assets/sounds/play.wav
  assets/sounds/heart.wav
  assets/sounds/hatch.wav
  assets/sounds/evolve.wav
  assets/sounds/medal.wav
  assets/sounds/deny.wav
  assets/sounds/bye.wav
  assets/sounds/level.wav
"""

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(SCRIPT_DIR, '..')
OUT_SOUNDS = os.path.join(ROOT, 'assets', 'sounds')

SAMPLE_RATE = 16000
AMP = 5000


def play_tone(f, ms):
    """Generate a square-wave tone at frequency f Hz for ms milliseconds."""
    samples = []
    total = int(SAMPLE_RATE * ms / 1000)
    half = int(SAMPLE_RATE / (2 * f)) if f > 0 else 0

    phase = 0
    high = True

    for idx in range(total):
        s = 0
        if f > 0:
            s = AMP if high else -AMP
            # Attack (first 64 samples — fade in)
            if idx < 64:
                s = int(s * idx / 64)
            # Decay (last 96 samples — fade out)
            elif idx > total - 96:
                s = int(s * (total - idx) / 96)

            phase += 1
            if phase >= half:
                phase = 0
                high = not high

        samples.append(struct.pack('<h', s))  # 16-bit mono sample

    return b''.join(samples)


def generate_sfx(notes, filename):
    """Compose a sequence of (frequency, duration_ms) tones and save as WAV."""
    data = b''
    for f, ms in notes:
        data += play_tone(f, ms)

    with wave.open(filename, 'w') as w:
        w.setnchannels(1)       # mono
        w.setsampwidth(2)       # 16-bit
        w.setframerate(SAMPLE_RATE)
        w.writeframes(data)
    print(f"  Generated {os.path.basename(filename)}")


# Sound definitions: list of (frequency_hz, duration_ms) tuples.
# Silence = frequency 0.
SFX = {
    'tap':    [(880, 35)],
    'eat':    [(660, 45), (0, 12), (660, 45)],
    'play':   [(784, 45), (988, 60)],
    'heart':  [(1047, 55), (1319, 90)],
    'hatch':  [(523, 80), (659, 80), (784, 110), (1047, 170)],
    'evolve': [(523, 80), (659, 80), (784, 80), (1047, 90), (1319, 230)],
    'medal':  [(784, 70), (0, 25), (784, 70), (0, 25), (1047, 200)],
    'deny':   [(300, 110), (200, 170)],
    'bye':    [(784, 150), (659, 150), (523, 280)],
    'level':  [(784, 70), (1047, 130)],
}


if __name__ == '__main__':
    os.makedirs(OUT_SOUNDS, exist_ok=True)

    # Remove placeholder dummy file if it exists
    dummy = os.path.join(OUT_SOUNDS, 'dummy.txt')
    if os.path.exists(dummy):
        os.remove(dummy)

    print(f"TamaPokeWear — Generating {len(SFX)} sound effects")
    print(f"  Output -> {os.path.abspath(OUT_SOUNDS)}")
    print()

    for name, notes in SFX.items():
        generate_sfx(notes, os.path.join(OUT_SOUNDS, f'{name}.wav'))

    print()
    print("All sounds generated successfully!")
    print("Next step: run   flutter pub get && flutter run")
