# Credits

TamaPokeWear is a **non-commercial, personal-use** project. It does not sell or
commercially redistribute any copyrighted material. Pokémon and all related
names, designs and characters are trademarks and © of **Nintendo / Game Freak /
The Pokémon Company**.

This project is not affiliated with or endorsed by any of those companies.

---

## Original Project

This Flutter app is a reimplementation of **[TamaPoke](https://github.com/socquique/TamaPoke)**,
an Arduino/ESP32 firmware originally created by **[socquique](https://github.com/socquique)**.

All game mechanics (stats, evolution logic, life cycle, rarity system, bond/streak/medals)
are ported faithfully from that original work.

---

## Sprites and Data

| Resource | Source | Use in this project |
|---|---|---|
| **All sprites** (idle, walk, sleep, eat, attack, pose…) | [PMD Sprite Collaboration (PMDCollab/SpriteCollab)](https://github.com/PMDCollab/SpriteCollab) | Mystery-Dungeon-style animated GIFs used everywhere: main screen, stat card, Pokéball minigame, and the Pokédex grid |
| **Gen-1 base stats** | [PokéAPI](https://pokeapi.co) | Real ATK/DEF/SPD for each species, used for battle stat calculations |

The **SpriteCollab** sprites are the work of its community of artists under their
own terms (Creative Commons Attribution-NonCommercial 4.0). Per-species/per-author
credit is in the original repository's
[tracker.json](https://github.com/PMDCollab/SpriteCollab/blob/master/tracker.json).
Huge thanks to that whole community for an enormous amount of work.

> **Important if you reuse this repo:** sprites are NOT included in this repository.
> Run `python3 tools/download_sprites.py` to download them directly from the
> original sources. Don't redistribute them commercially.

---

## Software

| Component | Author / Source |
|---|---|
| **Flutter SDK** | [Google](https://flutter.dev) — UI framework |
| **Hive** | [hivedb.dev](https://pub.dev/packages/hive) — local game save persistence |
| **audioplayers** | [bluefireteam](https://pub.dev/packages/audioplayers) — sound effects |
| **wear_plus** | [wear_plus](https://pub.dev/packages/wear_plus) — WearOS integration |
| **flutter_local_notifications** | [MaikuB](https://pub.dev/packages/flutter_local_notifications) — care reminders |
| **google_fonts** | [material.io](https://pub.dev/packages/google_fonts) — typography |
| **path_provider** | [Flutter team](https://pub.dev/packages/path_provider) — file paths |

---

TamaPokeWear's own code (Flutter app and tooling) is original work by
[David Kalil](https://github.com/davidkalil10), based on the game design and
logic of the original TamaPoke firmware by [socquique](https://github.com/socquique).
