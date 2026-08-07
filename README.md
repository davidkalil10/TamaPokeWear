# TamaPokeWear

![Flutter](https://img.shields.io/badge/flutter-WearOS-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-3.x-00B4AB?logo=dart&logoColor=white)
![Code](https://img.shields.io/badge/code-MIT-blue)
![Languages](https://img.shields.io/badge/languages-6-FFCB05)
![Platform](https://img.shields.io/badge/platform-WearOS%20%2F%20Android-green?logo=android)

A **Gen-1 Pokémon Tamagotchi** for **Android WearOS** smartwatches — built entirely in **Flutter/Dart**. Raise any of the 151, evolve it, train it, and complete the Pokédex (shinies included).

This is a Flutter reimplementation of [TamaPoke](https://github.com/socquique/TamaPoke) by [socquique](https://github.com/socquique), which was originally built for a custom ESP32 round AMOLED hardware device. All game mechanics, numbers, and Pokédex data are ported faithfully 1:1 from the original firmware.

> **Personal, non-commercial fan project.** Code is MIT; sprites are from PMD SpriteCollab (CC BY-NC, Pokémon © Nintendo/Game Freak). See [License](#license) and [CREDITS.md](CREDITS.md).

---

## About the Author

👤 **David Kalil** — [@davidkalil10](https://github.com/davidkalil10)

### 🚀 Other Projects

| Project | Description | Links |
|---|---|---|
| 📺 **IPTV Smart Cast** | A premium multi-platform IPTV player (Meta Quest, Android, Android TV, WearOS, Samsung TV, Windows, Steam) with a standout exclusive feature: cross-platform **Watch Together** — watch live channels in real time with friends remotely, synced frame-by-frame across any device. | [Website](https://davidkalil10.github.io/IPTV-Smart-Cast-Website/) |
| 🎮 **Retro Smart Cast** | The ultimate GBA, GBC & GB emulator for Android, built in Flutter with a Dart FFI bridge to a native C++ engine. 60 FPS performance, haptic virtual buttons, real-time library search and multi-language support. | [Website](https://davidkalil10.github.io/Retro-Smart-Cast-Website/) |
| 🎸 **Cifraria** | Professional song library and guitar chord manager built in Flutter. Smart folders, setlist management, animated QR offline sharing, instant transposition, Google Drive sync, and Meta Quest VR support. | [Website](https://davidkalil10.github.io/Cifraria_Website/) |
| 🏢 **Simulação Sem Ilusão** | A financial X-ray app for anyone buying off-plan real estate in Brazil. Simulates INCC impact, Caixa vs. bank financing, obra evolution, FGTS weight, and custom payment schedules — with clean charts and PDF export. | [Website](https://simulacaosemilusao.netlify.app/) |

---

## Game Manual (the actual numbers)

A quick reference to how the game really works — values are straight from the code.

### Time & Leveling
- **1 real minute = 1 in-game minute.** Your Pokémon gains **+1 level every hour** of real time. Leveling is purely time-based — caring well doesn't speed it up, but neglect *delays evolution*.

### The Four Stats (0–100)
Needs: **FOOD**, **JOY**, **ENE** (energy), **HYG** (hygiene). Start 80 / 80 / 80 / 100.
While **awake**, per minute:

| Stat | Drain/min | Notes |
|---|---|---|
| FOOD | −2 | |
| ENE | −1 | −1 extra if overweight (weight > 50 → sluggish) |
| HYG | −1 | **−4 more per poop** on screen (max 3 poops) |
| JOY | −1 | **−2 extra** if FOOD < 30, **−2 extra** if HYG < 30 |

- ~**15 %/min** chance to poop (only if FOOD > 40). Poops tank hygiene fast.
- **Care slip-up** = letting any stat hit **≤ 10** (30-min cooldown so it counts once). Each slip-up **delays evolution by 1 level** and cools the bond.

### Actions
- 🍎 **Berry** (3 flavors): +25 FOOD. Each species has a **hidden favorite flavor** → +35 FOOD, +10 JOY, ♥, bond, and it gets revealed.
- 🍬 **Candy:** +10 FOOD, +12 JOY, but **+12 weight** (fattening).
- ⚽ **Play / minigame:** +JOY, −ENE; the Pokéball minigame trains **SPEED** and burns weight.
- 🥊 **Training bag:** trains **STRENGTH** (~4 hits = 1 pt, cap +18/session), tires it.
- 🫧 **Bath:** clears poops, HYG → 100.
- 👆 **Pet it:** +5 JOY + bond.
- 🌙 **Sleep:** rest — ENE **+6/min**, needs drain ~**4× slower** with floors (FOOD 30 / JOY 35 / HYG 45).

### Eggs & Who You Get (Spawn Odds)
- **First ever pet:** you pick a starter — **Bulbasaur / Charmander / Squirtle**.
- Hatch the egg: tap it **3×** (or wait — it hatches on its own).
- Every later egg rolls a **rarity tier**:

| Tier | Base chance | After a proper goodbye | # species |
|---|---|---|---|
| ✨ Legendary | ~3 %\* | ~10 % | 5 |
| 🔵 Rare | ~27 % | ~45 % | 27 |
| ⚪ Common | the rest | the rest | 47 |

  \* Legendaries only start appearing once you've **registered ≥ 25** Pokémon.
- A daily **streak** and high **bond** push rare/legendary odds higher.
- **Shiny:** base **1 / 48** (→ **1 / 24** right after a goodbye), improved by streak/bond down to a best of **1 / 8**. Tracked separately in the Pokédex.

### Evolution
- Triggers when **level ≥ its evolution level** (16 for most base forms) **and every stat ≥ 40**.
- **Never automatic** — a button appears and **you tap to witness it**.
- You can **decline** ("keep form"); it re-offers at the next level.
- *Eevee* branches toward whichever evolution you're still missing.

### The Three Endings
- 💛 **Farewell** — when it's a **final form** that has lived **3 days**. Blesses your next egg.
- 💔 **Run-away** — if you let **all four stats sit at 0 for a full hour**. Curses the next egg.
- 👋 **Release** — long-press the creature to let it go on your terms (neutral).

After any ending, a **new egg** appears.

### Bonds, Streaks, Medals, Pokédex
- **Streak** (player-wide): first care each real day. Milestones at **3 / 7 / 30 / 100** days.
- **Bond** (per pet): grows with affection (**cap +8/day**), cools on neglect.
- **8 medals** (Lv10/25/50, favorite berry found, 7-day streak, max bond, final form, "fit").
- **Pokédex:** raising a species registers it; **151 + shinies** to complete.

### Battle Stats
ATK / DEF / SPD = real **Gen-1 base** × genes + level + training.

---

## How to Play

On first run you **choose a starter**. After that you start with an **egg** — tap it 3 times or wait and it hatches.

**Buttons (bottom arc, icons):**
- 🍎 **Feed** → food menu.
- ⚽ **Play** → Pokéball minigame (trains SPEED). Tap the floating Pokéball — it gets faster as you hit it. 5 misses and you're out!
- 🌙 **Light** → sleep/wake.
- 🫧 **Bath** → clean your companion.

**Touch Gestures:**
- **Tap** the creature = pet it.
- **Swipe left** = open the **Pokédex**.
- **Swipe up** = open the **Stat Card** (tap the name to rename).
- **Swipe down** = **Settings** (set time, language, sound).
- **Long press** on the creature = **release** dialog.

---

## Building & Running

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.x
- A physical **WearOS smartwatch** or Android WearOS emulator
- Python 3.8+ with **Pillow** (`pip install Pillow`)

### 1. Clone the repository

```bash
git clone https://github.com/davidkalil10/TamaPokeWear.git
cd TamaPokeWear
```

### 2. Download the sprites

> **⚠️ Sprites are NOT included** for copyright reasons.
> They are downloaded from [PMD SpriteCollab](https://github.com/PMDCollab/SpriteCollab) (CC BY-NC 4.0).

```bash
pip install Pillow
python3 tools/download_sprites.py
```

This downloads all 151 Pokémon (normal + shiny) and saves them as GIFs + thumbnails under `assets/sprites/`. The first run downloads ~40 MB and caches it in `tools/.pmd_cache/`.

```bash
# Download specific Pokémon only
python3 tools/download_sprites.py 4 25      # Charmander + Pikachu
python3 tools/download_sprites.py normal    # Normal only (no shinies)
```

### 3. Generate sound effects

> **⚠️ Sounds are NOT included** (generated locally via synthesis).

```bash
python3 tools/generate_sounds.py
```

This creates 10 Game-Boy-style WAV sound effects in `assets/sounds/`. No external libraries required — pure Python only.

### 4. Build and run

```bash
flutter pub get
flutter run
```

---

## Project Structure

```
lib/
  models/       # PetState (game data, Hive persistence)
  services/     # GameEngine (game loop), AudioService
  screens/      # HomeScreen, PokedexScreen, StatCardScreen, etc.
  widgets/      # ActionButtons, StatBars, BiomeBackground, etc.
  data/         # Pokedex data (species, stats, evolution lines)
  i18n/         # Strings for EN, PT, ES, FR, DE, IT
assets/
  sprites/      # ← NOT IN REPO (run tools/download_sprites.py)
  sounds/       # ← NOT IN REPO (run tools/generate_sounds.py)
tools/
  download_sprites.py   # Downloads + converts PMD sprites to GIF
  generate_sounds.py    # Generates square-wave WAV sound effects
```

---

## Dependencies

| Package | Use |
|---|---|
| [`hive`](https://pub.dev/packages/hive) + [`hive_flutter`](https://pub.dev/packages/hive_flutter) | Local persistence (game save) |
| [`audioplayers`](https://pub.dev/packages/audioplayers) | Sound effects |
| [`wear_plus`](https://pub.dev/packages/wear_plus) | WearOS integration |
| [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) | Care reminders |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | Typography |
| [`path_provider`](https://pub.dev/packages/path_provider) | File paths |

---

## Credits

All sprites: [PMD SpriteCollab](https://github.com/PMDCollab/SpriteCollab) (community, CC BY-NC). Base stats: [PokéAPI](https://pokeapi.co). Pokémon is a ™ of Nintendo / Game Freak / The Pokémon Company. Non-commercial, personal-use project. Full credits in [`CREDITS.md`](CREDITS.md).

Original Arduino/ESP32 firmware by [socquique](https://github.com/socquique) — this project is a Flutter reimplementation of that work.

## License

- **Source code** (Flutter app + tooling): **[MIT](LICENSE)**.
- **Sprites & names**: © Nintendo / Game Freak / The Pokémon Company; pixel art from [PMD SpriteCollab](https://github.com/PMDCollab/SpriteCollab) (CC BY-NC 4.0). **Non-commercial use only.**

This is an unofficial fan project, not affiliated with or endorsed by Nintendo.
