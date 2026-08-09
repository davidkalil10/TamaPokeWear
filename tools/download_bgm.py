import os
import urllib.request
import ssl

"""
TamaPokeWear - BGM Download Script
==================================
Downloads classic Pokémon background music from Archive.org.
"""

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(SCRIPT_DIR, '..')
OUT_BGM = os.path.join(ROOT, 'assets', 'bgm')

# Direct URLs to MP3 files on Archive.org
TRACKS = {
    'pallet_town.mp3': 'https://archive.org/download/pkmn-rgby-soundtrack/Disc%201/03%20-%20Pallet%20Town.mp3',
    'littleroot_town.mp3': 'https://archive.org/download/pkmn-rse-soundtrack/Disc%201/05%20-%20Littleroot%20Town.mp3',
    'pokemon_center.mp3': 'https://archive.org/download/pkmn-rgby-soundtrack/Disc%201/17%20-%20Pok%C3%A9mon%20Center.mp3',
    'evolution.mp3': 'https://archive.org/download/pkmn-rgby-soundtrack/Disc%201/33%20-%20Congratulations%21%20Your%20Pok%C3%A9mon%20Evolved%21.mp3',
    'ending.mp3': 'https://archive.org/download/pkmn-rgby-soundtrack/Disc%201/52%20-%20Ending.mp3',
    'title_screen.mp3': 'https://archive.org/download/pkmn-rgby-soundtrack/Disc%201/02%20-%20Title%20Screen.mp3',
}

def download_bgm():
    os.makedirs(OUT_BGM, exist_ok=True)
    
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    print(f"Downloading {len(TRACKS)} background music tracks to {OUT_BGM}...")

    for filename, url in TRACKS.items():
        out_path = os.path.join(OUT_BGM, filename)
        if os.path.exists(out_path):
            print(f"  [SKIPPED] {filename} already exists.")
            continue
        
        print(f"  [DOWNLOADING] {filename}...")
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req, context=ctx, timeout=30) as response:
                with open(out_path, 'wb') as out_file:
                    out_file.write(response.read())
            print(f"  [SUCCESS] {filename}")
        except Exception as e:
            print(f"  [ERROR] Failed to download {filename}: {e}")

if __name__ == '__main__':
    download_bgm()
    print("\nNext step: Make sure assets/bgm/ is in pubspec.yaml")
