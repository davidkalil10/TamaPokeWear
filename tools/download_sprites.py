import os
import sys
import urllib.request
import xml.etree.ElementTree as ET
from PIL import Image

"""
TamaPokeWear — Sprite Download Script
======================================
Downloads and converts PMD SpriteCollab animated sprites into the GIF files
used by this Flutter app.

Source: https://github.com/PMDCollab/SpriteCollab (CC BY-NC 4.0)
Per-species/per-author credits:
  https://github.com/PMDCollab/SpriteCollab/blob/master/tracker.json

Requirements:
  pip install Pillow

Usage:
  python3 tools/download_sprites.py           # all 151 normal + shiny
  python3 tools/download_sprites.py 4 25      # specific dex numbers only
  python3 tools/download_sprites.py normal    # only normal variants (no shinies)

Output folders (relative to project root):
  assets/sprites/normal/  -> NNN_action.gif (e.g. 004_idle.gif)
  assets/sprites/shiny/   -> NNN_action.gif
  assets/sprites/thumbs/  -> NNN.png (40x40 thumbnail from idle frame 0)
"""

# ── Paths (relative to project root) ──────────────────────────────────────────
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(SCRIPT_DIR, '..')

OUT_NORMAL = os.path.join(ROOT, 'assets', 'sprites', 'normal')
OUT_SHINY  = os.path.join(ROOT, 'assets', 'sprites', 'shiny')
OUT_THUMBS = os.path.join(ROOT, 'assets', 'sprites', 'thumbs')
CACHE      = os.path.join(SCRIPT_DIR, '.pmd_cache')

BASE = 'https://raw.githubusercontent.com/PMDCollab/SpriteCollab/master/sprite'

# Frame timing multiplier (the original PMD rhythm feels fast on a small screen)
SLOW = 1.4

# Actions to export: (SpriteCollab action name, output suffix, spritesheet row)
ACTIONS = [
    ('Idle',   'idle',   0),
    ('Walk',   'walk',   6),   # row 6 = leftward walk in PMD sheets
    ('Sleep',  'sleep',  0),
    ('Eat',    'eat',    0),
    ('Attack', 'attack', 0),
    ('Pose',   'pose',   0),
]

# ── Helpers ────────────────────────────────────────────────────────────────────

def fetch(url, dest):
    if os.path.exists(dest):
        return True
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        data = urllib.request.urlopen(req, timeout=30).read()
        open(dest, 'wb').write(data)
        return True
    except Exception as e:
        print(f"    Failed to fetch {url}: {e}")
        return False


def load_animdata(folder):
    path = os.path.join(folder, 'AnimData.xml')
    anims = {}
    tree = ET.parse(path)
    for a in tree.getroot().find('Anims'):
        name = a.find('Name').text
        copy = a.find('CopyOf')
        if copy is not None:
            anims[name] = ('copy', copy.text)
            continue
        if a.find('FrameWidth') is None:
            continue
        anims[name] = (int(a.find('FrameWidth').text), int(a.find('FrameHeight').text),
                       [int(d.text) for d in a.find('Durations')], name)
    # Resolve aliases (CopyOf)
    for k, v in list(anims.items()):
        if isinstance(v, tuple) and v[0] == 'copy':
            anims[k] = anims.get(v[1])
    return anims


def pack(dexnum, shiny=False):
    sub = '/0000/0001' if shiny else ''
    folder = os.path.join(CACHE, f'{dexnum:04d}{"s" if shiny else ""}')
    base = f'{BASE}/{dexnum:04d}{sub}'

    if not fetch(f'{base}/AnimData.xml', os.path.join(folder, 'AnimData.xml')):
        raise RuntimeError('No AnimData.xml at remote URL')

    anims = load_animdata(folder)
    out_dir = OUT_SHINY if shiny else OUT_NORMAL
    os.makedirs(out_dir, exist_ok=True)

    exported = []
    for anim_name, suffix, row in ACTIONS:
        if anim_name not in anims or anims[anim_name] is None:
            continue
        fw, fh, durs, srcname = anims[anim_name]
        png_cache = os.path.join(folder, f'{srcname}-Anim.png')
        if not fetch(f'{base}/{srcname}-Anim.png', png_cache):
            continue

        im = Image.open(png_cache).convert('RGBA')
        rows = im.size[1] // fh
        r = row if rows > row else 0
        nf = min(len(durs), im.size[0] // fw, 24)

        frames = []
        for i in range(nf):
            fr = im.crop((i * fw, r * fh, (i + 1) * fw, (r + 1) * fh))
            frames.append(fr)

        if not frames:
            continue

        ms = [max(70, round(d * 1000 / 60 * SLOW)) for d in durs[:nf]]
        out_path = os.path.join(out_dir, f'{dexnum:03d}_{suffix}.gif')

        frames[0].save(
            out_path,
            save_all=True,
            append_images=frames[1:],
            duration=ms,
            loop=0,
            disposal=2,
            transparency=0
        )
        exported.append(suffix)

        # Generate thumbnail from normal idle (frame 0 as PNG)
        if not shiny and anim_name == 'Idle':
            os.makedirs(OUT_THUMBS, exist_ok=True)
            thumb_path = os.path.join(OUT_THUMBS, f'{dexnum:03d}.png')
            frames[0].save(thumb_path)

    if exported:
        print(f"  #{dexnum:03d} {'shiny' if shiny else 'normal'}: {', '.join(exported)}")
    else:
        print(f"  #{dexnum:03d} {'shiny' if shiny else 'normal'}: no actions exported")


# ── Entry point ────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    args = sys.argv[1:]
    only_normal = 'normal' in args
    nums = [int(a) for a in args if a.isdigit()]
    if not nums:
        nums = list(range(1, 152))  # Default: all 151 Gen-1 Pokemon

    print(f"TamaPokeWear — Downloading {len(nums)} species from PMDCollab/SpriteCollab")
    print(f"  Normal  -> {os.path.abspath(OUT_NORMAL)}")
    print(f"  Shiny   -> {os.path.abspath(OUT_SHINY)}")
    print(f"  Thumbs  -> {os.path.abspath(OUT_THUMBS)}")
    print(f"  Cache   -> {os.path.abspath(CACHE)}")
    print()

    failures = []
    for n in nums:
        for shiny in ([False] if only_normal else [False, True]):
            try:
                pack(n, shiny)
            except Exception as e:
                print(f"  ERROR #{n:03d} {'shiny' if shiny else ''}: {e}")
                failures.append((n, shiny))

    print()
    if failures:
        print(f"Failures: {failures}")
    else:
        print("All sprites downloaded successfully!")
        print("Next step: run   python3 tools/generate_sounds.py")
