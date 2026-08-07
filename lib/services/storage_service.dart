/// Serviço de persistência usando Hive — equivale ao NVS/Preferences do ESP32.
library;

import 'package:hive_flutter/hive_flutter.dart';

import '../models/pet_state.dart';

class StorageService {
  static const String _boxName = 'tamapoke';
  static const String _petKey = 'pet';

  late Box<PetState> _box;

  Future<void> init() async {
    await Hive.initFlutter();

    // Registrar o adapter manualmente (sem build_runner por enquanto)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PetStateAdapter());
    }

    _box = await Hive.openBox<PetState>(_boxName);
  }

  Future<PetState> loadPet() async {
    return _box.get(_petKey) ?? PetState();
  }

  Future<void> savePet(PetState pet) async {
    await _box.put(_petKey, pet);
  }

  Future<void> wipe() async {
    await _box.clear();
  }

  // ── PC Box (Archive) ──────────────────────────────────────────────────────
  
  String _archiveKey(int speciesId, bool isShiny) => 'archived_${speciesId}_$isShiny';

  Future<void> saveArchivedPet(PetState pet) async {
    await _box.put(_archiveKey(pet.speciesId, pet.shiny), pet.clone());
  }

  PetState? loadArchivedPet(int speciesId, bool isShiny) {
    return _box.get(_archiveKey(speciesId, isShiny));
  }

  bool hasArchivedPet(int speciesId, bool isShiny) {
    return _box.containsKey(_archiveKey(speciesId, isShiny));
  }

  Future<void> removeArchivedPet(int speciesId, bool isShiny) async {
    await _box.delete(_archiveKey(speciesId, isShiny));
  }
}

/// Adapter manual para PetState (evita dependência de build_runner)
class PetStateAdapter extends TypeAdapter<PetState> {
  @override
  final int typeId = 0;

  @override
  PetState read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return PetState(
      fullness: fields[0] as int? ?? 80,
      joy: fields[1] as int? ?? 80,
      energy: fields[2] as int? ?? 80,
      hygiene: fields[3] as int? ?? 100,
      poops: fields[4] as int? ?? 0,
      weight: fields[5] as int? ?? 0,
      geneAtk: fields[6] as int? ?? 100,
      geneDef: fields[7] as int? ?? 100,
      geneSpe: fields[8] as int? ?? 100,
      trAtk: fields[9] as int? ?? 0,
      trDef: fields[10] as int? ?? 0,
      trSpe: fields[11] as int? ?? 0,
      berryKnown: fields[12] as bool? ?? false,
      shiny: fields[13] as bool? ?? false,
      ageMinutes: fields[14] as int? ?? 0,
      speciesId: fields[15] as int? ?? -1,
      prevSpeciesId: fields[16] as int? ?? -1,
      careMistakes: fields[17] as int? ?? 0,
      sleeping: fields[18] as bool? ?? false,
      lastSeenEpoch: fields[19] as int? ?? 0,
      ceremony: fields[20] as int? ?? 0,
      lastEnd: fields[21] as int? ?? 0,
      dexReg: (fields[22] as List?)?.cast<int>(),
      dexShinyReg: (fields[23] as List?)?.cast<int>(),
      streak: fields[24] as int? ?? 0,
      bestStreak: fields[25] as int? ?? 0,
      lastCareDay: fields[26] as int? ?? 0,
      bond: fields[27] as int? ?? 0,
      nick: fields[28] as String? ?? '',
      medals: fields[29] as int? ?? 0,
      totalMedals: fields[30] as int? ?? 0,
      newMedal: fields[31] as int? ?? 0,
      lastMilestone: fields[32] as int? ?? 0,
      gameHi: fields[33] as int? ?? 0,
      strHi: fields[34] as int? ?? 0,
      eggTarget: fields[35] as int? ?? 1,
      eggShiny: fields[36] as bool? ?? false,
      eggTaps: fields[37] as int? ?? 0,
      starterPick: fields[38] as bool? ?? true,
      neglectTicks: fields[39] as int? ?? 0,
      mistakeCooldown: fields[40] as int? ?? 0,
      goodTicks: fields[41] as int? ?? 0,
      ticksSinceSave: fields[42] as int? ?? 0,
      pendingSave: fields[43] as bool? ?? false,
      langIndex: fields[44] as int? ?? 1,
      soundOn: fields[45] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, PetState obj) {
    writer.writeByte(46); // number of fields
    writer.writeByte(0); writer.write(obj.fullness);
    writer.writeByte(1); writer.write(obj.joy);
    writer.writeByte(2); writer.write(obj.energy);
    writer.writeByte(3); writer.write(obj.hygiene);
    writer.writeByte(4); writer.write(obj.poops);
    writer.writeByte(5); writer.write(obj.weight);
    writer.writeByte(6); writer.write(obj.geneAtk);
    writer.writeByte(7); writer.write(obj.geneDef);
    writer.writeByte(8); writer.write(obj.geneSpe);
    writer.writeByte(9); writer.write(obj.trAtk);
    writer.writeByte(10); writer.write(obj.trDef);
    writer.writeByte(11); writer.write(obj.trSpe);
    writer.writeByte(12); writer.write(obj.berryKnown);
    writer.writeByte(13); writer.write(obj.shiny);
    writer.writeByte(14); writer.write(obj.ageMinutes);
    writer.writeByte(15); writer.write(obj.speciesId);
    writer.writeByte(16); writer.write(obj.prevSpeciesId);
    writer.writeByte(17); writer.write(obj.careMistakes);
    writer.writeByte(18); writer.write(obj.sleeping);
    writer.writeByte(19); writer.write(obj.lastSeenEpoch);
    writer.writeByte(20); writer.write(obj.ceremony);
    writer.writeByte(21); writer.write(obj.lastEnd);
    writer.writeByte(22); writer.write(obj.dexReg);
    writer.writeByte(23); writer.write(obj.dexShinyReg);
    writer.writeByte(24); writer.write(obj.streak);
    writer.writeByte(25); writer.write(obj.bestStreak);
    writer.writeByte(26); writer.write(obj.lastCareDay);
    writer.writeByte(27); writer.write(obj.bond);
    writer.writeByte(28); writer.write(obj.nick);
    writer.writeByte(29); writer.write(obj.medals);
    writer.writeByte(30); writer.write(obj.totalMedals);
    writer.writeByte(31); writer.write(obj.newMedal);
    writer.writeByte(32); writer.write(obj.lastMilestone);
    writer.writeByte(33); writer.write(obj.gameHi);
    writer.writeByte(34); writer.write(obj.strHi);
    writer.writeByte(35); writer.write(obj.eggTarget);
    writer.writeByte(36); writer.write(obj.eggShiny);
    writer.writeByte(37); writer.write(obj.eggTaps);
    writer.writeByte(38); writer.write(obj.starterPick);
    writer.writeByte(39); writer.write(obj.neglectTicks);
    writer.writeByte(40); writer.write(obj.mistakeCooldown);
    writer.writeByte(41); writer.write(obj.goodTicks);
    writer.writeByte(42); writer.write(obj.ticksSinceSave);
    writer.writeByte(43); writer.write(obj.pendingSave);
    writer.writeByte(44); writer.write(obj.langIndex);
    writer.writeByte(45); writer.write(obj.soundOn);
  }
}
