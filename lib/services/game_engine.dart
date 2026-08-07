/// Port fiel de pet.cpp — motor do jogo TamaPoke.
///
/// Contém toda a lógica do tamagotchi: tick (decay de stats),
/// ovos, evolução, cerimônias, ações do jogador, progressão offline.
library;

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../data/pokedex.dart';
import '../models/pet_state.dart';
import 'audio_service.dart';
import 'storage_service.dart';

class GameEngine {
  final StorageService _storage;
  final Random _rng = Random();

  PetState _pet;
  PetState get pet => _pet;

  Timer? _tickTimer;

  /// Callbacks para a UI reagir a eventos
  void Function()? onStateChanged;
  void Function(String message)? onStatusMessage;
  void Function()? onEvolutionReady;
  void Function()? onFarewellReady;
  void Function()? onRunawayReady;
  void Function(int newMedal)? onMedalEarned;
  void Function(int milestone)? onStreakMilestone;

  GameEngine({
    required StorageService storage,
    PetState? initialState,
  })  : _storage = storage,
        _pet = initialState ?? PetState();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> init() async {
    _pet = await _storage.loadPet();

    // Progressão offline
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (_pet.lastSeenEpoch > 0) {
      _syncClock(now);
    }
    _pet.lastSeenEpoch = now;

    // Iniciar o timer de 1 minuto
    _tickTimer = Timer.periodic(
      const Duration(milliseconds: petTickMs),
      (_) => _tick(),
    );
  }

  void dispose() {
    _tickTimer?.cancel();
    _save();
  }

  // ── Progressão Offline (port de Pet::syncClock) ───────────────────────────

  void _syncClock(int nowEpoch) {
    final seen = _pet.lastSeenEpoch;
    _pet.lastSeenEpoch = nowEpoch;
    if (nowEpoch == 0) return;

    int mins = (seen > 0 && nowEpoch > seen) ? (nowEpoch - seen) ~/ 60 : 0;
    if (mins < 2 || _pet.currentCeremony != Ceremony.none) {
      return; // sem tempo significativo ou em cerimônia
    }
    // Tope: 2 semanas
    if (mins > 14 * 24 * 60) mins = 14 * 24 * 60;

    for (int i = 0; i < mins; i++) {
      _pet.ageMinutes++;
      if (_pet.isEgg) {
        if (_pet.ageMinutes >= 3 && !_pet.starterPick) _hatch();
        continue;
      }
      if (_pet.sleeping) {
        _pet.energy = _clamp100(_pet.energy + 6);
        if (_pet.ageMinutes % 2 == 0) {
          _pet.fullness = _dropTo(_pet.fullness, 1, 30);
          _pet.joy = _dropTo(_pet.joy, 1, 35);
        }
        if (_pet.ageMinutes % 3 == 0) {
          _pet.hygiene = _dropTo(_pet.hygiene, 1, 45);
        }
        continue;
      }
      // Despierto: stats caem com pisos mais altos (piedad offline)
      _pet.fullness = _dropTo(_pet.fullness, 2, 15);
      _pet.energy = _dropTo(_pet.energy, 1, 15);
      _pet.hygiene = _dropTo(_pet.hygiene, 1, 15);
      _pet.joy = _dropTo(_pet.joy, 1, 15);
    }

    if (!_pet.isEgg && !_pet.sleeping) {
      int p = _pet.poops + mins ~/ 240;
      _pet.poops = p > 3 ? 3 : p;
    }
  }

  // ── Tick principal (port de Pet::tick) ─────────────────────────────────────

  void _tick() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _pet.lastSeenEpoch = now;

    // Fim de cerimônia → novo ovo
    if (_pet.currentCeremony != Ceremony.none) {
      // A cerimônia é gerenciada pela UI (animação), aqui só atualizamos
      return;
    }

    _pet.ageMinutes++;

    if (_pet.isEgg) {
      if (_pet.ageMinutes >= 3) _hatch();
      _notifyChanged();
      return;
    }

    // ── Dormindo ──
    if (_pet.sleeping) {
      _pet.energy = _clamp100(_pet.energy + 6);
      if (_pet.weight > 0 && _pet.ageMinutes % 3 == 0) _pet.weight--;
      if (_pet.ageMinutes % 2 == 0) {
        _pet.fullness = _dropTo(_pet.fullness, 1, 30);
        _pet.joy = _dropTo(_pet.joy, 1, 35);
      }
      if (_pet.ageMinutes % 3 == 0) {
        _pet.hygiene = _dropTo(_pet.hygiene, 1, 45);
      }
      _checkMedals();
      _autoSave();
      _notifyChanged();
      return;
    }

    // ── Acordado ──
    _pet.fullness = _clamp100(_pet.fullness - 2);
    _pet.energy = _clamp100(_pet.energy - 1);

    // Cocôs: 15% chance por minuto se FOOD > 40
    if (_pet.fullness > 40 && _pet.poops < 3 && _rng.nextInt(100) < 15) {
      _pet.poops++;
    }

    // Higiene: -1 base -4 por cocô
    _pet.hygiene = _clamp100(_pet.hygiene - 1 - 4 * _pet.poops);

    // Sobrepeso: energia cai o dobro
    if (_pet.weight > 50) _pet.energy = _clamp100(_pet.energy - 1);
    if (_pet.weight > 0 && _pet.ageMinutes % 3 == 0) _pet.weight--;

    // Treino de defesa: 12h seguidas com stats >= 40 = +1 DEF
    if (_pet.lowestStat >= 40) {
      _pet.goodTicks++;
      if (_pet.goodTicks >= 720) {
        _pet.goodTicks = 0;
        if (_pet.trDef < 100) _pet.trDef++;
      }
    } else {
      _pet.goodTicks = 0;
    }

    // Joy: base -1, extra -2 se faminto, extra -2 se sujo
    int dJoy = -1;
    if (_pet.fullness < 30) dJoy -= 2;
    if (_pet.hygiene < 30) dJoy -= 2;
    _pet.joy = _clamp100(_pet.joy + dJoy);

    // Descuidos
    if (_pet.mistakeCooldown > 0) _pet.mistakeCooldown--;
    if (_pet.lowestStat <= 10 && _pet.mistakeCooldown == 0) {
      _pet.careMistakes++;
      _pet.mistakeCooldown = 30;
      if (_pet.bond > 3) _pet.bond -= 3;
    }

    _checkMedals();

    // Abandono total
    if (_pet.fullness == 0 &&
        _pet.joy == 0 &&
        _pet.energy == 0 &&
        _pet.hygiene == 0) {
      if (_pet.neglectTicks < runawayTicks) _pet.neglectTicks++;
      if (_pet.neglectTicks >= runawayTicks) {
        onRunawayReady?.call();
      }
    } else {
      _pet.neglectTicks = 0;
    }

    // Streak diário
    _checkDailyStreak();

    _autoSave();
    _notifyChanged();
  }

  // ── Ações do jogador ──────────────────────────────────────────────────────

  /// Alimentar com berry (0=vermelha, 1=azul, 2=verde)
  void feedBerry(int color) {
    AudioService().playEat();
    if (_pet.isEgg || _pet.sleeping) return;
    final isFavorite = !_pet.isEgg && (_pet.speciesId % 3) == color;

    if (isFavorite) {
      _pet.fullness = _clamp100(_pet.fullness + 35);
      _pet.joy = _clamp100(_pet.joy + 10);
      _pet.bond = _clamp100(_pet.bond + 2);
      if (!_pet.berryKnown) {
        _pet.berryKnown = true;
        _awardMedal(Medals.berry);
      }
      onStatusMessage?.call('likes'); // "It likes it!"
    } else {
      _pet.fullness = _clamp100(_pet.fullness + 25);
    }

    _recordCare();
    _notifyChanged();
  }

  /// Alimentar com candy (+10 FOOD, +12 JOY, +12 weight)
  void feedCandy() {
    AudioService().playEat();
    if (_pet.isEgg || _pet.sleeping) return;
    _pet.fullness = _clamp100(_pet.fullness + 10);
    _pet.joy = _clamp100(_pet.joy + 12);
    _pet.weight = _clamp100(_pet.weight + 12);
    _recordCare();
    _notifyChanged();
  }

  /// Fazer carinho (+5 JOY + bond)
  void petIt() {
    AudioService().playHeart();
    if (_pet.isEgg || _pet.sleeping) return;
    _pet.joy = _clamp100(_pet.joy + 5);
    _pet.bond = _clamp100(_pet.bond + 1);
    _recordCare();
    _notifyChanged();
  }

  /// Banho: limpa cocôs, HYG → 100
  void bath() {
    if (_pet.isEgg || _pet.sleeping) return;
    _pet.poops = 0;
    _pet.hygiene = 100;
    _recordCare();
    _notifyChanged();
  }

  /// Dormir / acordar
  void toggleSleep() {
    if (_pet.isEgg) return;
    _pet.sleeping = !_pet.sleeping;
    _notifyChanged();
  }

  /// Resultado do minijogo (recompensa: +JOY, -ENE, treina SPEED, queima peso)
  void playResult(int score) {
    if (score > 0) AudioService().playPlay();
    else AudioService().playDeny();
    if (_pet.isEgg || _pet.sleeping) return;
    _pet.joy = _clamp100(_pet.joy + 15 + score ~/ 5);
    _pet.energy = _clamp100(_pet.energy - 10);
    if (score > 0 && _pet.trSpe < 100) _pet.trSpe++;
    if (_pet.weight > 0) _pet.weight = _clamp100(_pet.weight - 5);
    if (score > _pet.gameHi) _pet.gameHi = score;
    _recordCare();
    _notifyChanged();
  }

  /// Treino no saco (treina STRENGTH, cansa)
  void trainStrength(int hits) {
    AudioService().playPlay();
    if (_pet.isEgg || _pet.sleeping) return;
    final gain = hits ~/ 4;
    if (gain > 0 && _pet.trAtk < 100) {
      _pet.trAtk = (_pet.trAtk + gain).clamp(0, 100);
    }
    _pet.energy = _clamp100(_pet.energy - 15);
    if (_pet.weight > 0) _pet.weight = _clamp100(_pet.weight - 3);
    if (hits > _pet.strHi) _pet.strHi = hits;
    _recordCare();
    _notifyChanged();
  }

  /// Tocar no ovo (3 taps = chocar)
  void tapEgg() {
    AudioService().playTap();
    if (!_pet.isEgg) return;
    _pet.eggTaps++;
    if (_pet.eggTaps >= 3) {
      _hatch();
    }
    _notifyChanged();
  }

  /// Escolher starter (primeira partida)
  void chooseStarter(int dexNum) {
    if (!_pet.starterPick) return;
    _pet.starterPick = false;
    _pet.eggTarget = dexNum;
    _hatch();
    _notifyChanged();
  }

  /// Renomear (nickname)
  void rename(String newNick) {
    _pet.nick = newNick.length > 11 ? newNick.substring(0, 11) : newNick;
    _notifyChanged();
  }

  // ── Evolução ──────────────────────────────────────────────────────────────

  bool get canEvolveNow {
    if (_pet.isEgg || _pet.sleeping) return false;
    final entry = dex[_pet.speciesId];
    if (entry.isFinalForm) return false;

    final requiredLevel = entry.evolveLevel + _pet.careMistakes;
    return _pet.level >= requiredLevel && _pet.lowestStat >= 40;
  }

  /// Evoluir! Retorna true se evoluiu
  bool evolve() {
    AudioService().playEvolve();
    if (!canEvolveNow) return false;
    final entry = dex[_pet.speciesId];
    _pet.prevSpeciesId = _pet.speciesId;

    // Eevee: ramifica para a evolução que falta
    if (_pet.speciesId == 133) {
      _pet.speciesId = _pickEeveeEvolution();
    } else {
      _pet.speciesId = entry.evolvesTo;
    }

    _pet.registerSpecies(_pet.speciesId);
    if (_pet.shiny) _pet.registerShiny(_pet.speciesId);
    _pet.nick = ''; // reseta apelido na evolução

    // Verifica medalha de forma final
    if (dex[_pet.speciesId].isFinalForm) {
      _awardMedal(Medals.finalForm);
    }

    _notifyChanged();
    return true;
  }

  /// Declinar evolução (mantém a forma, re-oferece no próximo nível)
  void declineEvolution() {
    // Não faz nada, o canEvolveNow vai retornar true no próximo nível
  }

  // ── Finais ────────────────────────────────────────────────────────────────

  bool get canFarewellNow {
    if (_pet.isEgg) return false;
    return true; // TEMP: Forcing Farewell button to appear for testing
  }

  bool get canRunawayNow => _pet.neglectTicks >= runawayTicks;

  void farewell() {
    _pet.ceremony = Ceremony.farewell.index;
    _pet.lastEnd = Ceremony.farewell.index;
    _storage.saveArchivedPet(_pet);
    _save();
  }

  void runaway() {
    _pet.ceremony = Ceremony.runaway.index;
    _pet.lastEnd = Ceremony.runaway.index;
    _save();
  }

  void release() {
    _pet.ceremony = Ceremony.release.index;
    _pet.lastEnd = Ceremony.release.index;
    _save();
  }

  /// Finalizar cerimônia → novo ovo
  void endCeremony() {
    _newEgg();
    _notifyChanged();
  }

  // ── Ovos ──────────────────────────────────────────────────────────────────

  void _newEgg() {
    _pet.ceremony = Ceremony.none.index;
    _pet.neglectTicks = 0;
    _pet.weight = 0;
    _pet.speciesId = -1;
    _pet.prevSpeciesId = -1;
    _pet.eggTarget = _pickEggSpecies();
    _pet.starterPick = (_pet.registeredCount == 0);

    // Shiny roll: 1/48 base, 1/24 após farewell, melhorado por careBonus
    int shinyBase = (_pet.lastEnding == Ceremony.farewell ? 24 : 48) -
        _pet.careBonus;
    if (shinyBase < 8) shinyBase = 8;
    _pet.eggShiny = _rng.nextInt(shinyBase) == 0;

    _pet.eggTaps = 0;
    _pet.fullness = 80;
    _pet.joy = 80;
    _pet.energy = 80;
    _pet.hygiene = 100;
    _pet.poops = 0;
    _pet.ageMinutes = 0;
    _pet.careMistakes = 0;
    _pet.mistakeCooldown = 0;
    _pet.sleeping = false;
    _pet.bond = 0;
    _pet.nick = '';
    _pet.medals = 0;
    _pet.newMedal = 0;
    _pet.goodTicks = 0;
    _pet.trAtk = 0;
    _pet.trDef = 0;
    _pet.trSpe = 0;
    _pet.berryKnown = false;

    // Roll genes: 90-110% para cada stat
    _pet.geneAtk = 90 + _rng.nextInt(21);
    _pet.geneDef = 90 + _rng.nextInt(21);
    _pet.geneSpe = 90 + _rng.nextInt(21);

    _save();
  }

  void _hatch() {
    AudioService().playHatch();
    _pet.speciesId = _pet.eggTarget;
    _pet.shiny = _pet.eggShiny;
    _pet.registerSpecies(_pet.speciesId);
    if (_pet.shiny) _pet.registerShiny(_pet.speciesId);
    _save();
    _notifyChanged();
  }

  /// Escolhe espécie para o ovo baseado em raridade e Pokédex incompleta
  int _pickEggSpecies() {
    // Determinar tier de raridade
    EggRarity tier;
    final blessed = _pet.lastEnding == Ceremony.farewell;
    final cursed = _pet.lastEnding == Ceremony.runaway;

    if (cursed) {
      tier = EggRarity.common;
    } else {
      final roll = _rng.nextDouble();
      final legendChance = (_pet.registeredCount >= 25)
          ? (blessed ? 0.10 : 0.03) + _pet.careBonus * 0.005
          : 0.0;
      final rareChance = (blessed ? 0.45 : 0.27) + _pet.careBonus * 0.01;

      if (roll < legendChance) {
        tier = EggRarity.legendary;
      } else if (roll < legendChance + rareChance) {
        tier = EggRarity.rare;
      } else {
        tier = EggRarity.common;
      }
    }

    // Pegar a lista de espécies do tier
    List<int> candidates;
    if (tier == EggRarity.legendary) {
      candidates = List.from(eggRarityTable[EggRarity.legendary]!);
    } else if (tier == EggRarity.rare) {
      candidates = List.from(eggRarityTable[EggRarity.rare]!);
    } else {
      // Common: todas as base forms que não estão em rare nem legendary
      final rareLeg = {
        ...eggRarityTable[EggRarity.legendary]!,
        ...eggRarityTable[EggRarity.rare]!,
      };
      candidates = [];
      for (int i = 1; i <= 151; i++) {
        final entry = dex[i];
        // É base form (ninguém evolui para ele)?
        bool isBaseForm = true;
        for (int j = 1; j <= 151; j++) {
          if (dex[j].evolvesTo == i) {
            isBaseForm = false;
            break;
          }
        }
        if (isBaseForm && !rareLeg.contains(i) && !entry.isFinalForm) {
          candidates.add(i);
        }
        // Também adicionar formas finais que são "standalone" (sem pré-evolução)
        if (isBaseForm && !rareLeg.contains(i) && entry.isFinalForm) {
          // Verificar se é realmente standalone
          bool hasPrevo = false;
          for (int j = 1; j <= 151; j++) {
            if (dex[j].evolvesTo == i) {
              hasPrevo = true;
              break;
            }
          }
          if (!hasPrevo) candidates.add(i);
        }
      }
      if (candidates.isEmpty) {
        // Fallback: todos os base forms
        for (int i = 1; i <= 151; i++) {
          bool isBaseForm = true;
          for (int j = 1; j <= 151; j++) {
            if (dex[j].evolvesTo == i) {
              isBaseForm = false;
              break;
            }
          }
          if (isBaseForm) candidates.add(i);
        }
      }
    }

    // Favorecer espécies cujas linhas evolutivas não estão completas
    final incomplete = candidates
        .where((id) => _lineHasUnregistered(id))
        .toList();
    if (incomplete.isNotEmpty) {
      return incomplete[_rng.nextInt(incomplete.length)];
    }

    return candidates[_rng.nextInt(candidates.length)];
  }

  bool _lineHasUnregistered(int baseId) {
    int cur = baseId;
    for (int guard = 0; cur >= 1 && cur <= 151 && guard < 6; guard++) {
      if (!_pet.isRegistered(cur)) return true;
      final entry = dex[cur];
      if (entry.isFinalForm) break;
      cur = entry.evolvesTo;
    }
    return false;
  }

  int _pickEeveeEvolution() {
    // Eevee → a evolução que o jogador ainda não registrou
    final evos = [134, 135, 136]; // Vaporeon, Jolteon, Flareon
    final missing = evos.where((id) => !_pet.isRegistered(id)).toList();
    if (missing.isNotEmpty) return missing[_rng.nextInt(missing.length)];
    return evos[_rng.nextInt(evos.length)];
  }

  // ── Medalhas ──────────────────────────────────────────────────────────────

  void _checkMedals() {
    if (_pet.isEgg) return;
    final lv = _pet.level;
    if (lv >= 10) _awardMedal(Medals.lv10);
    if (lv >= 25) _awardMedal(Medals.lv25);
    if (lv >= 50) _awardMedal(Medals.lv50);
    if (_pet.streak >= 7) _awardMedal(Medals.streak7);
    if (_pet.bond >= 100) _awardMedal(Medals.bond);
    if (dex[_pet.speciesId].isFinalForm) _awardMedal(Medals.finalForm);
    if (_pet.weight == 0 && _pet.careMistakes == 0) _awardMedal(Medals.fit);
  }

  void _awardMedal(int medal) {
    if ((_pet.medals & medal) != 0) return; // Já tem
    _pet.medals |= medal;
    _pet.totalMedals++;
    _pet.newMedal = medal;
    onMedalEarned?.call(medal);
  }

  // ── Streak diário ─────────────────────────────────────────────────────────

  void _checkDailyStreak() {
    final today = _julianDay(DateTime.now());
    if (_pet.lastCareDay == 0) return; // Sem cuidado ainda

    if (today > _pet.lastCareDay + 1) {
      // Perdeu um dia: streak quebrada
      _pet.streak = 0;
    }
  }

  void _recordCare() {
    final today = _julianDay(DateTime.now());
    if (today != _pet.lastCareDay) {
      _pet.lastCareDay = today;
      _pet.streak++;
      if (_pet.streak > _pet.bestStreak) _pet.bestStreak = _pet.streak;

      // Milestones
      const milestones = [3, 7, 30, 100];
      for (final m in milestones) {
        if (_pet.streak == m && _pet.lastMilestone < m) {
          _pet.lastMilestone = m;
          onStreakMilestone?.call(m);
        }
      }
    }

    // Bond: +1 por cuidado, cap +8 por dia
    if (_pet.bond < 100) {
      _pet.bond = (_pet.bond + 1).clamp(0, 100);
    }
  }

  // ── Battle stats helpers ──────────────────────────────────────────────────

  /// ATK = base × genes + level + training
  int get computedAtk {
    if (_pet.isEgg) return 0;
    final base = baseStats[_pet.speciesId][1];
    return (base * _pet.geneAtk ~/ 100) + _pet.level + _pet.trAtk;
  }

  int get computedDef {
    if (_pet.isEgg) return 0;
    final base = baseStats[_pet.speciesId][2];
    return (base * _pet.geneDef ~/ 100) + _pet.level + _pet.trDef;
  }

  int get computedSpd {
    if (_pet.isEgg) return 0;
    final base = baseStats[_pet.speciesId][3];
    return (base * _pet.geneSpe ~/ 100) + _pet.level + _pet.trSpe;
  }

  // ── Helpers internos ──────────────────────────────────────────────────────

  int _clamp100(int v) => v.clamp(0, 100);

  int _dropTo(int v, int d, int floor) {
    if (v <= floor) return v;
    return (v - floor > d) ? v - d : floor;
  }

  int _julianDay(DateTime dt) {
    return dt.year * 10000 + dt.month * 100 + dt.day;
  }

  void _autoSave() {
    _pet.ticksSinceSave++;
    if (_pet.ticksSinceSave >= 5) {
      _pet.ticksSinceSave = 0;
      _save();
    }
  }

  void _save() {
    _storage.savePet(_pet);
  }

  void _notifyChanged() {
    onStateChanged?.call();
  }

  /// Status message baseado no estado atual
  String get statusKey {
    if (_pet.isEgg) return 'egg';
    if (_pet.sleeping) return 'sleeping';
    if (_pet.shiny && _pet.ageMinutes < 5) return 'shiny';
    if (_pet.fullness < 20) return 'hungry';
    if (_pet.hygiene < 20) return 'needsBath';
    if (_pet.energy < 20) return 'exhausted';
    if (_pet.joy < 20) return 'sad';
    if (_pet.weight > 50) return 'chubby';
    return 'happy';
  }

  // ── PC Box (Easter Egg) ───────────────────────────────────────────────────

  bool hasArchivedPet(int speciesId, bool isShiny) {
    return _storage.hasArchivedPet(speciesId, isShiny);
  }

  /// Verifica se o Pokémon atual é um veterano (já teve despedida).
  bool isCurrentPetVeteran() {
    if (_pet.isEgg) return false;
    return _pet.ceremony == Ceremony.farewell.index;
  }

  /// Troca o Pokémon atual por um do PC.
  void swapWithArchived(int targetSpecies, bool targetShiny) async {
    final archived = _storage.loadArchivedPet(targetSpecies, targetShiny);
    if (archived == null) return; // Não deveria acontecer se UI verificar antes

    if (isCurrentPetVeteran()) {
      // Se é veterano, salva o progresso dele de volta no PC
      await _storage.saveArchivedPet(_pet);
    }
    // Se não é veterano, o pet atual é simplesmente descartado

    final newPet = archived.clone();
    newPet.copyGlobalsFrom(_pet); // Preserve Pokedex, Streak, and Medals
    _pet = newPet;
    
    // O pet arquivado "desperta" agora, então precisamos atualizar lastSeenEpoch
    _pet.lastSeenEpoch = DateTime.now().millisecondsSinceEpoch;
    _save();
    _notifyChanged();
  }
}
