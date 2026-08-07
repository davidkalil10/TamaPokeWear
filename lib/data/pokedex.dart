/// Port fiel de tools/dex_data.py — dados dos 151 Pokémon Gen 1.
///
/// Cada entrada: (dexNum, slug, displayName, type, evolvesTo, evolveLevel)
/// - slug: identificador interno lowercase
/// - displayName: nome para exibição
/// - type: chave de [typeAccents]
/// - evolvesTo: número dex da evolução (0 = forma final)
/// - evolveLevel: nível para evolução (gen-1 real; pedra≈30, troca≈40)
library;

/// Cores accent por tipo (hex do original dex_data.py)
const Map<String, int> typeAccents = {
  'normal':   0xFF8A8A6A,
  'fire':     0xFFE8503A,
  'water':    0xFF4F93C4,
  'grass':    0xFF3C8A4C,
  'electric': 0xFFB8960B,
  'ice':      0xFF4FB4C4,
  'fighting': 0xFFA5552D,
  'poison':   0xFF8A4F9E,
  'ground':   0xFFB08A3D,
  'psychic':  0xFFD4527E,
  'bug':      0xFF7A9A24,
  'rock':     0xFF93803D,
  'ghost':    0xFF6A5A9E,
  'dragon':   0xFF5A52C4,
};

/// Bioma associado a cada tipo (para background)
const Map<String, String> typeBiome = {
  'normal':   'meadow',
  'fire':     'volcano',
  'water':    'beach',
  'grass':    'forest',
  'electric': 'meadow',
  'ice':      'snow',
  'fighting': 'mountain',
  'poison':   'forest',
  'ground':   'mountain',
  'psychic':  'meadow',
  'bug':      'forest',
  'rock':     'mountain',
  'ghost':    'forest',
  'dragon':   'mountain',
};

class DexEntry {
  final int dexNum;
  final String slug;
  final String displayName;
  final String type;
  final int evolvesTo;   // 0 = forma final
  final int evolveLevel; // 0 = não evolui

  const DexEntry({
    required this.dexNum,
    required this.slug,
    required this.displayName,
    required this.type,
    required this.evolvesTo,
    required this.evolveLevel,
  });

  bool get isFinalForm => evolvesTo == 0;

  /// Retorna a base form (primeiro da linha evolutiva).
  /// Ex: Charmeleon(5) → Charmander(4)
  int get baseForm {
    // Percorre para trás até achar quem não é evolução de ninguém
    for (final e in dex) {
      if (e.evolvesTo == dexNum) return e.baseForm;
    }
    return dexNum;
  }
}

/// Tabela completa: 151 Pokémon Gen 1 (índice 0 = dummy, 1-151 = Pokémon)
/// Port direto de dex_data.py DEX[]
const List<DexEntry> dex = [
  // Índice 0: dummy (para alinhar com dexNum 1-based)
  DexEntry(dexNum: 0, slug: 'none', displayName: '---', type: 'normal', evolvesTo: 0, evolveLevel: 0),

  // --- Starters ---
  DexEntry(dexNum: 1, slug: 'bulbasaur', displayName: 'Bulbasaur', type: 'grass', evolvesTo: 2, evolveLevel: 16),
  DexEntry(dexNum: 2, slug: 'ivysaur', displayName: 'Ivysaur', type: 'grass', evolvesTo: 3, evolveLevel: 32),
  DexEntry(dexNum: 3, slug: 'venusaur', displayName: 'Venusaur', type: 'grass', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 4, slug: 'charmander', displayName: 'Charmander', type: 'fire', evolvesTo: 5, evolveLevel: 16),
  DexEntry(dexNum: 5, slug: 'charmeleon', displayName: 'Charmeleon', type: 'fire', evolvesTo: 6, evolveLevel: 36),
  DexEntry(dexNum: 6, slug: 'charizard', displayName: 'Charizard', type: 'fire', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 7, slug: 'squirtle', displayName: 'Squirtle', type: 'water', evolvesTo: 8, evolveLevel: 16),
  DexEntry(dexNum: 8, slug: 'wartortle', displayName: 'Wartortle', type: 'water', evolvesTo: 9, evolveLevel: 36),
  DexEntry(dexNum: 9, slug: 'blastoise', displayName: 'Blastoise', type: 'water', evolvesTo: 0, evolveLevel: 0),

  // --- Bugs ---
  DexEntry(dexNum: 10, slug: 'caterpie', displayName: 'Caterpie', type: 'bug', evolvesTo: 11, evolveLevel: 7),
  DexEntry(dexNum: 11, slug: 'metapod', displayName: 'Metapod', type: 'bug', evolvesTo: 12, evolveLevel: 10),
  DexEntry(dexNum: 12, slug: 'butterfree', displayName: 'Butterfree', type: 'bug', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 13, slug: 'weedle', displayName: 'Weedle', type: 'bug', evolvesTo: 14, evolveLevel: 7),
  DexEntry(dexNum: 14, slug: 'kakuna', displayName: 'Kakuna', type: 'bug', evolvesTo: 15, evolveLevel: 10),
  DexEntry(dexNum: 15, slug: 'beedrill', displayName: 'Beedrill', type: 'bug', evolvesTo: 0, evolveLevel: 0),

  // --- Normal/Flying ---
  DexEntry(dexNum: 16, slug: 'pidgey', displayName: 'Pidgey', type: 'normal', evolvesTo: 17, evolveLevel: 18),
  DexEntry(dexNum: 17, slug: 'pidgeotto', displayName: 'Pidgeotto', type: 'normal', evolvesTo: 18, evolveLevel: 36),
  DexEntry(dexNum: 18, slug: 'pidgeot', displayName: 'Pidgeot', type: 'normal', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 19, slug: 'rattata', displayName: 'Rattata', type: 'normal', evolvesTo: 20, evolveLevel: 20),
  DexEntry(dexNum: 20, slug: 'raticate', displayName: 'Raticate', type: 'normal', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 21, slug: 'spearow', displayName: 'Spearow', type: 'normal', evolvesTo: 22, evolveLevel: 20),
  DexEntry(dexNum: 22, slug: 'fearow', displayName: 'Fearow', type: 'normal', evolvesTo: 0, evolveLevel: 0),

  // --- Poison/Ground ---
  DexEntry(dexNum: 23, slug: 'ekans', displayName: 'Ekans', type: 'poison', evolvesTo: 24, evolveLevel: 22),
  DexEntry(dexNum: 24, slug: 'arbok', displayName: 'Arbok', type: 'poison', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 25, slug: 'pikachu', displayName: 'Pikachu', type: 'electric', evolvesTo: 26, evolveLevel: 30),
  DexEntry(dexNum: 26, slug: 'raichu', displayName: 'Raichu', type: 'electric', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 27, slug: 'sandshrew', displayName: 'Sandshrew', type: 'ground', evolvesTo: 28, evolveLevel: 22),
  DexEntry(dexNum: 28, slug: 'sandslash', displayName: 'Sandslash', type: 'ground', evolvesTo: 0, evolveLevel: 0),

  // --- Nidoran ---
  DexEntry(dexNum: 29, slug: 'nidoranf', displayName: 'Nidoran♀', type: 'poison', evolvesTo: 30, evolveLevel: 16),
  DexEntry(dexNum: 30, slug: 'nidorina', displayName: 'Nidorina', type: 'poison', evolvesTo: 31, evolveLevel: 30),
  DexEntry(dexNum: 31, slug: 'nidoqueen', displayName: 'Nidoqueen', type: 'poison', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 32, slug: 'nidoranm', displayName: 'Nidoran♂', type: 'poison', evolvesTo: 33, evolveLevel: 16),
  DexEntry(dexNum: 33, slug: 'nidorino', displayName: 'Nidorino', type: 'poison', evolvesTo: 34, evolveLevel: 30),
  DexEntry(dexNum: 34, slug: 'nidoking', displayName: 'Nidoking', type: 'poison', evolvesTo: 0, evolveLevel: 0),

  // --- Fairy-like ---
  DexEntry(dexNum: 35, slug: 'clefairy', displayName: 'Clefairy', type: 'normal', evolvesTo: 36, evolveLevel: 30),
  DexEntry(dexNum: 36, slug: 'clefable', displayName: 'Clefable', type: 'normal', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 37, slug: 'vulpix', displayName: 'Vulpix', type: 'fire', evolvesTo: 38, evolveLevel: 30),
  DexEntry(dexNum: 38, slug: 'ninetales', displayName: 'Ninetales', type: 'fire', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 39, slug: 'jigglypuff', displayName: 'Jigglypuff', type: 'normal', evolvesTo: 40, evolveLevel: 30),
  DexEntry(dexNum: 40, slug: 'wigglytuff', displayName: 'Wigglytuff', type: 'normal', evolvesTo: 0, evolveLevel: 0),

  // --- Cave/Poison ---
  DexEntry(dexNum: 41, slug: 'zubat', displayName: 'Zubat', type: 'poison', evolvesTo: 42, evolveLevel: 22),
  DexEntry(dexNum: 42, slug: 'golbat', displayName: 'Golbat', type: 'poison', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 43, slug: 'oddish', displayName: 'Oddish', type: 'grass', evolvesTo: 44, evolveLevel: 21),
  DexEntry(dexNum: 44, slug: 'gloom', displayName: 'Gloom', type: 'grass', evolvesTo: 45, evolveLevel: 36),
  DexEntry(dexNum: 45, slug: 'vileplume', displayName: 'Vileplume', type: 'grass', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 46, slug: 'paras', displayName: 'Paras', type: 'bug', evolvesTo: 47, evolveLevel: 24),
  DexEntry(dexNum: 47, slug: 'parasect', displayName: 'Parasect', type: 'bug', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 48, slug: 'venonat', displayName: 'Venonat', type: 'bug', evolvesTo: 49, evolveLevel: 31),
  DexEntry(dexNum: 49, slug: 'venomoth', displayName: 'Venomoth', type: 'bug', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 50, slug: 'diglett', displayName: 'Diglett', type: 'ground', evolvesTo: 51, evolveLevel: 26),
  DexEntry(dexNum: 51, slug: 'dugtrio', displayName: 'Dugtrio', type: 'ground', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 52, slug: 'meowth', displayName: 'Meowth', type: 'normal', evolvesTo: 53, evolveLevel: 28),
  DexEntry(dexNum: 53, slug: 'persian', displayName: 'Persian', type: 'normal', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 54, slug: 'psyduck', displayName: 'Psyduck', type: 'water', evolvesTo: 55, evolveLevel: 33),
  DexEntry(dexNum: 55, slug: 'golduck', displayName: 'Golduck', type: 'water', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 56, slug: 'mankey', displayName: 'Mankey', type: 'fighting', evolvesTo: 57, evolveLevel: 28),
  DexEntry(dexNum: 57, slug: 'primeape', displayName: 'Primeape', type: 'fighting', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 58, slug: 'growlithe', displayName: 'Growlithe', type: 'fire', evolvesTo: 59, evolveLevel: 30),
  DexEntry(dexNum: 59, slug: 'arcanine', displayName: 'Arcanine', type: 'fire', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 60, slug: 'poliwag', displayName: 'Poliwag', type: 'water', evolvesTo: 61, evolveLevel: 25),
  DexEntry(dexNum: 61, slug: 'poliwhirl', displayName: 'Poliwhirl', type: 'water', evolvesTo: 62, evolveLevel: 40),
  DexEntry(dexNum: 62, slug: 'poliwrath', displayName: 'Poliwrath', type: 'water', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 63, slug: 'abra', displayName: 'Abra', type: 'psychic', evolvesTo: 64, evolveLevel: 16),
  DexEntry(dexNum: 64, slug: 'kadabra', displayName: 'Kadabra', type: 'psychic', evolvesTo: 65, evolveLevel: 40),
  DexEntry(dexNum: 65, slug: 'alakazam', displayName: 'Alakazam', type: 'psychic', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 66, slug: 'machop', displayName: 'Machop', type: 'fighting', evolvesTo: 67, evolveLevel: 28),
  DexEntry(dexNum: 67, slug: 'machoke', displayName: 'Machoke', type: 'fighting', evolvesTo: 68, evolveLevel: 40),
  DexEntry(dexNum: 68, slug: 'machamp', displayName: 'Machamp', type: 'fighting', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 69, slug: 'bellsprout', displayName: 'Bellsprout', type: 'grass', evolvesTo: 70, evolveLevel: 21),
  DexEntry(dexNum: 70, slug: 'weepinbell', displayName: 'Weepinbell', type: 'grass', evolvesTo: 71, evolveLevel: 36),
  DexEntry(dexNum: 71, slug: 'victreebel', displayName: 'Victreebel', type: 'grass', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 72, slug: 'tentacool', displayName: 'Tentacool', type: 'water', evolvesTo: 73, evolveLevel: 30),
  DexEntry(dexNum: 73, slug: 'tentacruel', displayName: 'Tentacruel', type: 'water', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 74, slug: 'geodude', displayName: 'Geodude', type: 'rock', evolvesTo: 75, evolveLevel: 25),
  DexEntry(dexNum: 75, slug: 'graveler', displayName: 'Graveler', type: 'rock', evolvesTo: 76, evolveLevel: 40),
  DexEntry(dexNum: 76, slug: 'golem', displayName: 'Golem', type: 'rock', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 77, slug: 'ponyta', displayName: 'Ponyta', type: 'fire', evolvesTo: 78, evolveLevel: 40),
  DexEntry(dexNum: 78, slug: 'rapidash', displayName: 'Rapidash', type: 'fire', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 79, slug: 'slowpoke', displayName: 'Slowpoke', type: 'water', evolvesTo: 80, evolveLevel: 37),
  DexEntry(dexNum: 80, slug: 'slowbro', displayName: 'Slowbro', type: 'water', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 81, slug: 'magnemite', displayName: 'Magnemite', type: 'electric', evolvesTo: 82, evolveLevel: 30),
  DexEntry(dexNum: 82, slug: 'magneton', displayName: 'Magneton', type: 'electric', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 83, slug: 'farfetchd', displayName: "Farfetch'd", type: 'normal', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 84, slug: 'doduo', displayName: 'Doduo', type: 'normal', evolvesTo: 85, evolveLevel: 31),
  DexEntry(dexNum: 85, slug: 'dodrio', displayName: 'Dodrio', type: 'normal', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 86, slug: 'seel', displayName: 'Seel', type: 'water', evolvesTo: 87, evolveLevel: 34),
  DexEntry(dexNum: 87, slug: 'dewgong', displayName: 'Dewgong', type: 'ice', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 88, slug: 'grimer', displayName: 'Grimer', type: 'poison', evolvesTo: 89, evolveLevel: 38),
  DexEntry(dexNum: 89, slug: 'muk', displayName: 'Muk', type: 'poison', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 90, slug: 'shellder', displayName: 'Shellder', type: 'water', evolvesTo: 91, evolveLevel: 30),
  DexEntry(dexNum: 91, slug: 'cloyster', displayName: 'Cloyster', type: 'ice', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 92, slug: 'gastly', displayName: 'Gastly', type: 'ghost', evolvesTo: 93, evolveLevel: 25),
  DexEntry(dexNum: 93, slug: 'haunter', displayName: 'Haunter', type: 'ghost', evolvesTo: 94, evolveLevel: 40),
  DexEntry(dexNum: 94, slug: 'gengar', displayName: 'Gengar', type: 'ghost', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 95, slug: 'onix', displayName: 'Onix', type: 'rock', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 96, slug: 'drowzee', displayName: 'Drowzee', type: 'psychic', evolvesTo: 97, evolveLevel: 26),
  DexEntry(dexNum: 97, slug: 'hypno', displayName: 'Hypno', type: 'psychic', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 98, slug: 'krabby', displayName: 'Krabby', type: 'water', evolvesTo: 99, evolveLevel: 28),
  DexEntry(dexNum: 99, slug: 'kingler', displayName: 'Kingler', type: 'water', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 100, slug: 'voltorb', displayName: 'Voltorb', type: 'electric', evolvesTo: 101, evolveLevel: 30),
  DexEntry(dexNum: 101, slug: 'electrode', displayName: 'Electrode', type: 'electric', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 102, slug: 'exeggcute', displayName: 'Exeggcute', type: 'grass', evolvesTo: 103, evolveLevel: 30),
  DexEntry(dexNum: 103, slug: 'exeggutor', displayName: 'Exeggutor', type: 'grass', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 104, slug: 'cubone', displayName: 'Cubone', type: 'ground', evolvesTo: 105, evolveLevel: 28),
  DexEntry(dexNum: 105, slug: 'marowak', displayName: 'Marowak', type: 'ground', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 106, slug: 'hitmonlee', displayName: 'Hitmonlee', type: 'fighting', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 107, slug: 'hitmonchan', displayName: 'Hitmonchan', type: 'fighting', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 108, slug: 'lickitung', displayName: 'Lickitung', type: 'normal', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 109, slug: 'koffing', displayName: 'Koffing', type: 'poison', evolvesTo: 110, evolveLevel: 35),
  DexEntry(dexNum: 110, slug: 'weezing', displayName: 'Weezing', type: 'poison', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 111, slug: 'rhyhorn', displayName: 'Rhyhorn', type: 'ground', evolvesTo: 112, evolveLevel: 42),
  DexEntry(dexNum: 112, slug: 'rhydon', displayName: 'Rhydon', type: 'ground', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 113, slug: 'chansey', displayName: 'Chansey', type: 'normal', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 114, slug: 'tangela', displayName: 'Tangela', type: 'grass', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 115, slug: 'kangaskhan', displayName: 'Kangaskhan', type: 'normal', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 116, slug: 'horsea', displayName: 'Horsea', type: 'water', evolvesTo: 117, evolveLevel: 32),
  DexEntry(dexNum: 117, slug: 'seadra', displayName: 'Seadra', type: 'water', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 118, slug: 'goldeen', displayName: 'Goldeen', type: 'water', evolvesTo: 119, evolveLevel: 33),
  DexEntry(dexNum: 119, slug: 'seaking', displayName: 'Seaking', type: 'water', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 120, slug: 'staryu', displayName: 'Staryu', type: 'water', evolvesTo: 121, evolveLevel: 30),
  DexEntry(dexNum: 121, slug: 'starmie', displayName: 'Starmie', type: 'water', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 122, slug: 'mrmime', displayName: 'Mr. Mime', type: 'psychic', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 123, slug: 'scyther', displayName: 'Scyther', type: 'bug', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 124, slug: 'jynx', displayName: 'Jynx', type: 'ice', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 125, slug: 'electabuzz', displayName: 'Electabuzz', type: 'electric', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 126, slug: 'magmar', displayName: 'Magmar', type: 'fire', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 127, slug: 'pinsir', displayName: 'Pinsir', type: 'bug', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 128, slug: 'tauros', displayName: 'Tauros', type: 'normal', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 129, slug: 'magikarp', displayName: 'Magikarp', type: 'water', evolvesTo: 130, evolveLevel: 20),
  DexEntry(dexNum: 130, slug: 'gyarados', displayName: 'Gyarados', type: 'water', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 131, slug: 'lapras', displayName: 'Lapras', type: 'ice', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 132, slug: 'ditto', displayName: 'Ditto', type: 'normal', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 133, slug: 'eevee', displayName: 'Eevee', type: 'normal', evolvesTo: 134, evolveLevel: 30), // branches in code
  DexEntry(dexNum: 134, slug: 'vaporeon', displayName: 'Vaporeon', type: 'water', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 135, slug: 'jolteon', displayName: 'Jolteon', type: 'electric', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 136, slug: 'flareon', displayName: 'Flareon', type: 'fire', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 137, slug: 'porygon', displayName: 'Porygon', type: 'normal', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 138, slug: 'omanyte', displayName: 'Omanyte', type: 'rock', evolvesTo: 139, evolveLevel: 40),
  DexEntry(dexNum: 139, slug: 'omastar', displayName: 'Omastar', type: 'rock', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 140, slug: 'kabuto', displayName: 'Kabuto', type: 'rock', evolvesTo: 141, evolveLevel: 40),
  DexEntry(dexNum: 141, slug: 'kabutops', displayName: 'Kabutops', type: 'rock', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 142, slug: 'aerodactyl', displayName: 'Aerodactyl', type: 'rock', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 143, slug: 'snorlax', displayName: 'Snorlax', type: 'normal', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 144, slug: 'articuno', displayName: 'Articuno', type: 'ice', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 145, slug: 'zapdos', displayName: 'Zapdos', type: 'electric', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 146, slug: 'moltres', displayName: 'Moltres', type: 'fire', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 147, slug: 'dratini', displayName: 'Dratini', type: 'dragon', evolvesTo: 148, evolveLevel: 30),
  DexEntry(dexNum: 148, slug: 'dragonair', displayName: 'Dragonair', type: 'dragon', evolvesTo: 149, evolveLevel: 55),
  DexEntry(dexNum: 149, slug: 'dragonite', displayName: 'Dragonite', type: 'dragon', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 150, slug: 'mewtwo', displayName: 'Mewtwo', type: 'psychic', evolvesTo: 0, evolveLevel: 0),
  DexEntry(dexNum: 151, slug: 'mew', displayName: 'Mew', type: 'psychic', evolvesTo: 0, evolveLevel: 0),
];

/// Base stats do PokeAPI: (hp, atk, def, speed) — port de dex_stats.py
/// Index 0 = dummy, 1-151 = Pokémon
const List<List<int>> baseStats = [
  [0, 0, 0, 0],       // 0: dummy
  [45, 49, 49, 45],    // 1: Bulbasaur
  [60, 62, 63, 60],    // 2: Ivysaur
  [80, 82, 83, 80],    // 3: Venusaur
  [39, 52, 43, 65],    // 4: Charmander
  [58, 64, 58, 80],    // 5: Charmeleon
  [78, 84, 78, 100],   // 6: Charizard
  [44, 48, 65, 43],    // 7: Squirtle
  [59, 63, 80, 58],    // 8: Wartortle
  [79, 83, 100, 78],   // 9: Blastoise
  [45, 30, 35, 45],    // 10: Caterpie
  [50, 20, 55, 30],    // 11: Metapod
  [60, 45, 50, 70],    // 12: Butterfree
  [40, 35, 30, 50],    // 13: Weedle
  [45, 25, 50, 35],    // 14: Kakuna
  [65, 90, 40, 75],    // 15: Beedrill
  [40, 45, 40, 56],    // 16: Pidgey
  [63, 60, 55, 71],    // 17: Pidgeotto
  [83, 80, 75, 101],   // 18: Pidgeot
  [30, 56, 35, 72],    // 19: Rattata
  [55, 81, 60, 97],    // 20: Raticate
  [40, 60, 30, 70],    // 21: Spearow
  [65, 90, 65, 100],   // 22: Fearow
  [35, 60, 44, 55],    // 23: Ekans
  [60, 95, 69, 80],    // 24: Arbok
  [35, 55, 40, 90],    // 25: Pikachu
  [60, 90, 55, 110],   // 26: Raichu
  [50, 75, 85, 40],    // 27: Sandshrew
  [75, 100, 110, 65],  // 28: Sandslash
  [55, 47, 52, 41],    // 29: Nidoran♀
  [70, 62, 67, 56],    // 30: Nidorina
  [90, 92, 87, 76],    // 31: Nidoqueen
  [46, 57, 40, 50],    // 32: Nidoran♂
  [61, 72, 57, 65],    // 33: Nidorino
  [81, 102, 77, 85],   // 34: Nidoking
  [70, 45, 48, 35],    // 35: Clefairy
  [95, 70, 73, 60],    // 36: Clefable
  [38, 41, 40, 65],    // 37: Vulpix
  [73, 76, 75, 100],   // 38: Ninetales
  [115, 45, 20, 20],   // 39: Jigglypuff
  [140, 70, 45, 45],   // 40: Wigglytuff
  [40, 45, 35, 55],    // 41: Zubat
  [75, 80, 70, 90],    // 42: Golbat
  [45, 50, 55, 30],    // 43: Oddish
  [60, 65, 70, 40],    // 44: Gloom
  [75, 80, 85, 50],    // 45: Vileplume
  [35, 70, 55, 25],    // 46: Paras
  [60, 95, 80, 30],    // 47: Parasect
  [60, 55, 50, 45],    // 48: Venonat
  [70, 65, 60, 90],    // 49: Venomoth
  [10, 55, 25, 95],    // 50: Diglett
  [35, 100, 50, 120],  // 51: Dugtrio
  [40, 45, 35, 90],    // 52: Meowth
  [65, 70, 60, 115],   // 53: Persian
  [50, 52, 48, 55],    // 54: Psyduck
  [80, 82, 78, 85],    // 55: Golduck
  [40, 80, 35, 70],    // 56: Mankey
  [65, 105, 60, 95],   // 57: Primeape
  [55, 70, 45, 60],    // 58: Growlithe
  [90, 110, 80, 95],   // 59: Arcanine
  [40, 50, 40, 90],    // 60: Poliwag
  [65, 65, 65, 90],    // 61: Poliwhirl
  [90, 95, 95, 70],    // 62: Poliwrath
  [25, 20, 15, 90],    // 63: Abra
  [40, 35, 30, 105],   // 64: Kadabra
  [55, 50, 45, 120],   // 65: Alakazam
  [70, 80, 50, 35],    // 66: Machop
  [80, 100, 70, 45],   // 67: Machoke
  [90, 130, 80, 55],   // 68: Machamp
  [50, 75, 35, 40],    // 69: Bellsprout
  [65, 90, 50, 55],    // 70: Weepinbell
  [80, 105, 65, 70],   // 71: Victreebel
  [40, 40, 35, 70],    // 72: Tentacool
  [80, 70, 65, 100],   // 73: Tentacruel
  [40, 80, 100, 20],   // 74: Geodude
  [55, 95, 115, 35],   // 75: Graveler
  [80, 120, 130, 45],  // 76: Golem
  [50, 85, 55, 90],    // 77: Ponyta
  [65, 100, 70, 105],  // 78: Rapidash
  [90, 65, 65, 15],    // 79: Slowpoke
  [95, 75, 110, 30],   // 80: Slowbro
  [25, 35, 70, 45],    // 81: Magnemite
  [50, 60, 95, 70],    // 82: Magneton
  [52, 90, 55, 60],    // 83: Farfetch'd
  [35, 85, 45, 75],    // 84: Doduo
  [60, 110, 70, 110],  // 85: Dodrio
  [65, 45, 55, 45],    // 86: Seel
  [90, 70, 80, 70],    // 87: Dewgong
  [80, 80, 50, 25],    // 88: Grimer
  [105, 105, 75, 50],  // 89: Muk
  [30, 65, 100, 40],   // 90: Shellder
  [50, 95, 180, 70],   // 91: Cloyster
  [30, 35, 30, 80],    // 92: Gastly
  [45, 50, 45, 95],    // 93: Haunter
  [60, 65, 60, 110],   // 94: Gengar
  [35, 45, 160, 70],   // 95: Onix
  [60, 48, 45, 42],    // 96: Drowzee
  [85, 73, 70, 67],    // 97: Hypno
  [30, 105, 90, 50],   // 98: Krabby
  [55, 130, 115, 75],  // 99: Kingler
  [40, 30, 50, 100],   // 100: Voltorb
  [60, 50, 70, 150],   // 101: Electrode
  [60, 40, 80, 40],    // 102: Exeggcute
  [95, 95, 85, 55],    // 103: Exeggutor
  [50, 50, 95, 35],    // 104: Cubone
  [60, 80, 110, 45],   // 105: Marowak
  [50, 120, 53, 87],   // 106: Hitmonlee
  [50, 105, 79, 76],   // 107: Hitmonchan
  [90, 55, 75, 30],    // 108: Lickitung
  [40, 65, 95, 35],    // 109: Koffing
  [65, 90, 120, 60],   // 110: Weezing
  [80, 85, 95, 25],    // 111: Rhyhorn
  [105, 130, 120, 40], // 112: Rhydon
  [250, 5, 5, 50],     // 113: Chansey
  [65, 55, 115, 60],   // 114: Tangela
  [105, 95, 80, 90],   // 115: Kangaskhan
  [30, 40, 70, 60],    // 116: Horsea
  [55, 65, 95, 85],    // 117: Seadra
  [45, 67, 60, 63],    // 118: Goldeen
  [80, 92, 65, 68],    // 119: Seaking
  [30, 45, 55, 85],    // 120: Staryu
  [60, 75, 85, 115],   // 121: Starmie
  [40, 45, 65, 90],    // 122: Mr. Mime
  [70, 110, 80, 105],  // 123: Scyther
  [65, 50, 35, 95],    // 124: Jynx
  [65, 83, 57, 105],   // 125: Electabuzz
  [65, 95, 57, 93],    // 126: Magmar
  [65, 125, 100, 85],  // 127: Pinsir
  [75, 100, 95, 110],  // 128: Tauros
  [20, 10, 55, 80],    // 129: Magikarp
  [95, 125, 79, 81],   // 130: Gyarados
  [130, 85, 80, 60],   // 131: Lapras
  [48, 48, 48, 48],    // 132: Ditto
  [55, 55, 50, 55],    // 133: Eevee
  [130, 65, 60, 65],   // 134: Vaporeon
  [65, 65, 60, 130],   // 135: Jolteon
  [65, 130, 60, 65],   // 136: Flareon
  [65, 60, 70, 40],    // 137: Porygon
  [35, 40, 100, 35],   // 138: Omanyte
  [70, 60, 125, 55],   // 139: Omastar
  [30, 80, 90, 55],    // 140: Kabuto
  [60, 115, 105, 80],  // 141: Kabutops
  [80, 105, 65, 130],  // 142: Aerodactyl
  [160, 110, 65, 30],  // 143: Snorlax
  [90, 85, 100, 85],   // 144: Articuno
  [90, 90, 85, 100],   // 145: Zapdos
  [90, 100, 90, 90],   // 146: Moltres
  [41, 64, 45, 50],    // 147: Dratini
  [61, 84, 65, 70],    // 148: Dragonair
  [91, 134, 95, 80],   // 149: Dragonite
  [106, 110, 90, 130], // 150: Mewtwo
  [100, 100, 100, 100],// 151: Mew
];

/// Egg rarity tiers — port do original
/// Espécies que SÓ nascem de ovos (base forms, excluindo evoluções)
enum EggRarity { common, rare, legendary }

/// Tabela de raridade: espécies agrupadas por tier
const Map<EggRarity, List<int>> eggRarityTable = {
  EggRarity.legendary: [144, 145, 146, 150, 151], // 5 lendários
  EggRarity.rare: [
    25, 37, 58, 77, 81, 95, 106, 107, 108, 113, 114, 115,
    122, 123, 124, 125, 126, 127, 128, 131, 132, 133, 137,
    138, 140, 142, 143, // 27 raros
  ],
  // Common: todos os outros base forms (~47)
};

/// IDs dos 3 starters
const List<int> starterIds = [1, 4, 7];
