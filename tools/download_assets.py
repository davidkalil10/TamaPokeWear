#!/usr/bin/env python3
"""
TamaPokeWear — Asset Download Script
=====================================
Downloads and converts PMD SpriteCollab animated sprites into the GIF files
used by this Flutter app.

Source: https://github.com/PMDCollab/SpriteCollab (CC BY-NC 4.0)
Per-species/per-author credits: https://github.com/PMDCollab/SpriteCollab/blob/master/tracker.json

Requirements:
  pip install Pillow

Usage:
  python3 tools/download_assets.py           # all 151 normal + shiny
  python3 tools/download_assets.py 4 25      # specific dex numbers only
  python3 tools/download_assets.py normal 1  # only normal sprites for dex #1
"""
import os
import sys
import struct
import urllib.request
import xml.etree.ElementTree as ET
from PIL import Image

# ── Configuration ──────────────────────────────────────────────────────────────

BASE = 'https://raw.githubusercontent.com/PMDCollab/SpriteCollab/master/sprite'
CACHE = os.path.join(os.path.dirname(__file__), '.pmd_cache')
OUT_NORMAL = os.path.join(os.path.dirname(__file__), '..', 'assets', 'sprites', 'normal')
OUT_SHINY  = os.path.join(os.path.dirname(__file__), '..', 'assets', 'sprites', 'shiny')
OUT_THUMBS = os.path.join(os.path.dirname(__file__), '..', 'assets', 'sprites', 'thumbs')

FRAME_DELAY_MS = 120  # milliseconds per frame in the output GIF
ALPHA_T = 128         # alpha threshold for transparency

# Action names we want to export as separate GIF files
# (action_name_in_SpriteCollab, output_suffix, row_index_in_spritesheet)
ACTIONS = [
    ('Idle',   'idle',   0),
    ('Walk',   'walk',   6),   # row 6 = leftward walk in PMD sheets
    ('Sleep',  'sleep',  0),
    ('Eat',    'eat',    0),
    ('Attack', 'attack', 0),
    ('Pose',   'pose',   0),
]

# ── Helpers ────────────────────────────────────────────────────────────────────

def fetch(url: str, dest: str) -> bool:
    """Download a file only if not already cached. Returns True on success."""
    if os.path.exists(dest):
        return True
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        data = urllib.request.urlopen(req, timeout=30).read()
        with open(dest, 'wb') as f:
            f.write(data)
        return True
    except Exception as e:
        return False


def load_animdata(folder: str) -> dict:
    """Parse AnimData.xml and return a dict of action_name -> (fw, fh, durations, png_name)."""
    path = os.path.join(folder, 'AnimData.xml')
    anims = {}
    tree = ET.parse(path)
    for a in tree.getroot().find('Anims'):
        name = a.find('Name').text
        if a.find('FrameWidth') is None:
            copy = a.find('CopyOf')
            if copy is not None:
                anims[name] = ('copy', copy.text)
            continue
        anims[name] = (
            int(a.find('FrameWidth').text),
            int(a.find('FrameHeight').text),
            [int(d.text) for d in a.find('Durations')],
            name,
        )
    # Resolve aliases
    for k, v in list(anims.items()):
        if isinstance(v, tuple) and v[0] == 'copy':
            anims[k] = anims.get(v[1])
    return anims


def extract_frames(im: Image.Image, fw: int, fh: int, row: int, nframes: int) -> list:
    """Slice the sprite sheet into individual RGBA frame images."""
    rows = im.size[1] // fh
    r = row if rows > row else 0
    frames = []
    for i in range(nframes):
        frame = im.crop((i * fw, r * fh, (i + 1) * fw, (r + 1) * fh))
        frames.append(frame)
    return frames


def frames_to_gif(frames: list, out_path: str):
    """Save a list of RGBA PIL Images as an animated GIF."""
    converted = []
    for frame in frames:
        # Convert to palette mode while preserving transparency
        p_frame = frame.convert('RGBA').quantize(colors=255, method=Image.MEDIANCUT)
        converted.append(p_frame)

    if not converted:
        return

    converted[0].save(
        out_path,
        save_all=True,
        append_images=converted[1:],
        loop=0,
        duration=FRAME_DELAY_MS,
        disposal=2,
    )


def make_thumb_png(dex: int, normal_idle_gif: str, out_path: str):
    """Extract frame 0 of the idle GIF and save as a small 40x40 PNG thumbnail."""
    try:
        im = Image.open(normal_idle_gif)
        im.seek(0)
        img = im.convert('RGBA')
        # Scale down maintaining aspect ratio to fit 40x40
        CELL = 40
        w, h = img.size
        scale = min(CELL / w, CELL / h, 1.0)
        nw, nh = max(1, round(w * scale)), max(1, round(h * scale))
        img = img.resize((nw, nh), Image.NEAREST)
        thumb = Image.new('RGBA', (CELL, CELL), (0, 0, 0, 0))
        thumb.paste(img, ((CELL - nw) // 2, (CELL - nh) // 2))
        thumb.save(out_path)
    except Exception as e:
        print(f"    [thumb] FAILED for {dex:03d}: {e}")

# ── Main export logic ──────────────────────────────────────────────────────────

def export_species(dex: int, shiny: bool = False):
    """Download PMD sprites for one species and export each action as a GIF file."""
    sub = '/0000/0001' if shiny else ''
    tag = 'shiny' if shiny else 'normal'
    cache_folder = os.path.join(CACHE, f'{dex:04d}{"s" if shiny else ""}')
    base_url = f'{BASE}/{dex:04d}{sub}'
    out_folder = OUT_SHINY if shiny else OUT_NORMAL

    os.makedirs(out_folder, exist_ok=True)

    # 1. Get AnimData.xml
    anim_xml_cache = os.path.join(cache_folder, 'AnimData.xml')
    if not fetch(f'{base_url}/AnimData.xml', anim_xml_cache):
        print(f"  SKIP #{dex:03d} {tag}: no AnimData.xml at remote")
        return

    try:
        anims = load_animdata(cache_folder)
    except Exception as e:
        print(f"  SKIP #{dex:03d} {tag}: AnimData parse error: {e}")
        return

    exported = []

    for (anim_name, suffix, row) in ACTIONS:
        info = anims.get(anim_name)
        if info is None:
            continue  # This species doesn't have this action

        fw, fh, durs, src_name = info
        png_url = f'{base_url}/{src_name}-Anim.png'
        png_cache = os.path.join(cache_folder, f'{src_name}-Anim.png')

        if not fetch(png_url, png_cache):
            continue

        try:
            im = Image.open(png_cache).convert('RGBA')
        except Exception as e:
            print(f"    [{anim_name}] open error: {e}")
            continue

        nframes = min(len(durs), im.size[0] // fw, 24)
        frames = extract_frames(im, fw, fh, row, nframes)

        out_path = os.path.join(out_folder, f'{dex:03d}_{suffix}.gif')
        try:
            frames_to_gif(frames, out_path)
            exported.append(suffix)
        except Exception as e:
            print(f"    [{anim_name}] GIF save error: {e}")

    if exported:
        print(f"  #{dex:03d} {tag}: {', '.join(exported)}")
    else:
        print(f"  #{dex:03d} {tag}: NO actions exported")

    # Generate thumbnail from normal idle
    if not shiny:
        idle_path = os.path.join(OUT_NORMAL, f'{dex:03d}_idle.gif')
        if os.path.exists(idle_path):
            os.makedirs(OUT_THUMBS, exist_ok=True)
            thumb_path = os.path.join(OUT_THUMBS, f'{dex:03d}.png')
            make_thumb_png(dex, idle_path, thumb_path)


# ── Entry point ────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    args = sys.argv[1:]
    only_normal = 'normal' in args
    nums = [int(a) for a in args if a.isdigit()] or list(range(1, 152))

    print(f"TamaPokeWear — Downloading {len(nums)} species from PMDCollab/SpriteCollab")
    print(f"  Output: {os.path.abspath(OUT_NORMAL)}")
    print()

    failures = []
    for n in nums:
        for shiny in ([False] if only_normal else [False, True]):
            try:
                export_species(n, shiny)
            except Exception as e:
                print(f"  FAIL #{n:03d} {'shiny' if shiny else ''}: {e}")
                failures.append((n, shiny))

    print()
    if failures:
        print(f"FAILURES: {failures}")
    else:
        print(f"Done! All sprites saved to assets/sprites/")
        print(f"Thumbnails saved to assets/sprites/thumbs/")
        print()
        print("Next step: add your sound files to assets/sounds/")
        print("  Required files: tap.wav, eat.wav, play.wav, heart.wav,")
        print("                  hatch.wav, evolve.wav, medal.wav, deny.wav,")
        print("                  bye.wav, level.wav")
