/// Port fiel da classe Pet (pet.h) — estado completo do pet virtual.
///
/// Todos os campos, constantes e lógica mapeiam 1:1 com o firmware C++ original.
library;

import 'dart:math';

import 'package:hive/hive.dart';

// ── Constantes do jogo (port de pet.h) ──────────────────────────────────────

/// 1 tick = 1 minuto real de jogo
const int petTickMs = 60000;

/// Minutos por nível. Com 60, Charmander evolui em ~16h de jogo
const int minutesPerLevel = 60;

/// Duração das animações (ms)
const int eatAnimMs = 2500;
const int heartMs = 1500;
const int evolveAnimMs = 5200;
const int ceremonyMs = 10000;

/// Farewell: forma final + 3 dias de jogo (em minutos)
const int farewellAgeMin = 3 * 24 * 60;

/// Runaway: 1 hora com tudo a zero
const int runawayTicks = 60;

/// Tipos de cerimônia de fim de ciclo
enum Ceremony { none, farewell, runaway, release }

/// Humor do pet
enum PetMood { happy, sad, eating, sleeping }

/// Medalhas (bitmask) — 8 medalhas possíveis
class Medals {
  static const int lv10 = 1 << 0;
  static const int lv25 = 1 << 1;
  static const int lv50 = 1 << 2;
  static const int berry = 1 << 3;
  static const int streak7 = 1 << 4;
  static const int bond = 1 << 5;
  static const int finalForm = 1 << 6;
  static const int fit = 1 << 7;
  static const int count = 8;
}

// ── Modelo do estado do Pet ─────────────────────────────────────────────────

@HiveType(typeId: 0)
class PetState extends HiveObject {
  // Stats 0..100
  @HiveField(0) int fullness;
  @HiveField(1) int joy;
  @HiveField(2) int energy;
  @HiveField(3) int hygiene;
  @HiveField(4) int poops;       // 0-3
  @HiveField(5) int weight;      // 0-100 (candy engorda, treino queima)

  // Genes (90-110%, rolados ao chocar) e treino (0-100)
  @HiveField(6) int geneAtk;
  @HiveField(7) int geneDef;
  @HiveField(8) int geneSpe;
  @HiveField(9) int trAtk;
  @HiveField(10) int trDef;
  @HiveField(11) int trSpe;

  @HiveField(12) bool berryKnown;  // já descobriu a berry favorita
  @HiveField(13) bool shiny;       // variante rara

  @HiveField(14) int ageMinutes;
  @HiveField(15) int speciesId;     // 1-151, -1 = ovo
  @HiveField(16) int prevSpeciesId; // para animação de evolução
  @HiveField(17) int careMistakes;  // descuidos (atrasam evolução)
  @HiveField(18) bool sleeping;

  @HiveField(19) int lastSeenEpoch; // último timestamp visto (progressão offline)
  @HiveField(20) int ceremony;      // Ceremony.index
  @HiveField(21) int lastEnd;       // como acabou a anterior (afeta o ovo)

  // Pokédex (bitmap de 151 bits = 19 bytes)
  @HiveField(22) List<int> dexReg;
  @HiveField(23) List<int> dexShinyReg;

  // Streak (do jogador, persiste entre criações)
  @HiveField(24) int streak;
  @HiveField(25) int bestStreak;
  @HiveField(26) int lastCareDay; // dia Julian do último cuidado

  // Bond (do bicho, reseta ao nascer outro)
  @HiveField(27) int bond;

  @HiveField(28) String nick; // apelido (vazio = nome da espécie)

  // Medalhas
  @HiveField(29) int medals;
  @HiveField(30) int totalMedals;
  @HiveField(31) int newMedal;       // recém-conquistada (para celebrar)
  @HiveField(32) int lastMilestone;  // milestone de streak já celebrado

  @HiveField(33) int gameHi;  // recorde do minijogo
  @HiveField(34) int strHi;   // recorde de golpes no saco

  // Estado interno do ovo
  @HiveField(35) int eggTarget;   // espécie que vai nascer
  @HiveField(36) bool eggShiny;   // se o ovo é shiny
  @HiveField(37) int eggTaps;     // quantos taps no ovo
  @HiveField(38) bool starterPick; // se é a primeira partida (escolha do starter)

  // Contadores internos
  @HiveField(39) int neglectTicks;    // ticks com tudo a zero
  @HiveField(40) int mistakeCooldown; // cooldown para não contar mesmo descuido
  @HiveField(41) int goodTicks;       // ticks seguidos com stats >= 40
  @HiveField(42) int ticksSinceSave;
  @HiveField(43) bool pendingSave;

  // Idioma
  @HiveField(44) int langIndex;

  // Som
  @HiveField(45) bool soundOn;

  PetState({
    this.fullness = 80,
    this.joy = 80,
    this.energy = 80,
    this.hygiene = 100,
    this.poops = 0,
    this.weight = 0,
    this.geneAtk = 100,
    this.geneDef = 100,
    this.geneSpe = 100,
    this.trAtk = 0,
    this.trDef = 0,
    this.trSpe = 0,
    this.berryKnown = false,
    this.shiny = false,
    this.ageMinutes = 0,
    this.speciesId = -1,
    this.prevSpeciesId = -1,
    this.careMistakes = 0,
    this.sleeping = false,
    this.lastSeenEpoch = 0,
    this.ceremony = 0,
    this.lastEnd = 0,
    List<int>? dexReg,
    List<int>? dexShinyReg,
    this.streak = 0,
    this.bestStreak = 0,
    this.lastCareDay = 0,
    this.bond = 0,
    this.nick = '',
    this.medals = 0,
    this.totalMedals = 0,
    this.newMedal = 0,
    this.lastMilestone = 0,
    this.gameHi = 0,
    this.strHi = 0,
    this.eggTarget = 1,
    this.eggShiny = false,
    this.eggTaps = 0,
    this.starterPick = true,
    this.neglectTicks = 0,
    this.mistakeCooldown = 0,
    this.goodTicks = 0,
    this.ticksSinceSave = 0,
    this.pendingSave = false,
    this.langIndex = 1, // EN default
    this.soundOn = true,
  })  : dexReg = dexReg ?? List.filled(19, 0),
        dexShinyReg = dexShinyReg ?? List.filled(19, 0);

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool get isEgg => speciesId == -1;

  int get level => ageMinutes ~/ minutesPerLevel;

  int get lowestStat => [fullness, joy, energy, hygiene].reduce(min);

  PetMood get mood {
    if (sleeping) return PetMood.sleeping;
    if (fullness < 30 || joy < 30 || energy < 30 || hygiene < 30) {
      return PetMood.sad;
    }
    return PetMood.happy;
  }

  Ceremony get currentCeremony => Ceremony.values[ceremony];
  Ceremony get lastEnding => Ceremony.values[lastEnd];

  // ── Pokédex helpers ────────────────────────────────────────────────────────

  bool isRegistered(int dexNum) {
    if (dexNum < 1 || dexNum > 151) return false;
    final idx = (dexNum - 1) ~/ 8;
    final bit = (dexNum - 1) % 8;
    return (dexReg[idx] & (1 << bit)) != 0;
  }

  void registerSpecies(int dexNum) {
    if (dexNum < 1 || dexNum > 151) return;
    final idx = (dexNum - 1) ~/ 8;
    final bit = (dexNum - 1) % 8;
    dexReg[idx] |= (1 << bit);
  }

  bool isShinyRegistered(int dexNum) {
    if (dexNum < 1 || dexNum > 151) return false;
    final idx = (dexNum - 1) ~/ 8;
    final bit = (dexNum - 1) % 8;
    return (dexShinyReg[idx] & (1 << bit)) != 0;
  }

  void registerShiny(int dexNum) {
    if (dexNum < 1 || dexNum > 151) return;
    final idx = (dexNum - 1) ~/ 8;
    final bit = (dexNum - 1) % 8;
    dexShinyReg[idx] |= (1 << bit);
  }

  int get registeredCount {
    int count = 0;
    for (int i = 1; i <= 151; i++) {
      if (isRegistered(i)) count++;
    }
    return count;
  }

  /// Bônus de cuidado para rolls de ovos (streak + bond)
  int get careBonus => (streak ~/ 7) + (bond ~/ 10);
}
