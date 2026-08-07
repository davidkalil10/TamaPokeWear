import 'package:flutter/material.dart';
import '../data/pokedex.dart';
import '../services/game_engine.dart';
import '../models/pet_state.dart';
import '../i18n/strings.dart';
import 'play_screen.dart';

class StatCardScreen extends StatelessWidget {
  final GameEngine engine;
  const StatCardScreen({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB0B9FF),
      body: PageView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPage1(context),
          _buildPage2(context),
          _buildPage3(context),
          _buildPage4(context),
        ],
      ),
    );
  }

  Widget _buildPage1(BuildContext context) {
    final pet = engine.pet;
    final entry = dex[pet.speciesId];
    final displayName = pet.nick.isNotEmpty ? pet.nick : entry.displayName;

    final String folder = 'normal';
    final path =
        'assets/sprites/$folder/${pet.speciesId.toString().padLeft(3, '0')}_idle.gif';

    final textStyle = TextStyle(
      fontSize: 10,
      fontFamily: 'monospace',
      fontWeight: FontWeight.bold,
      color: Colors.blue[800],
      letterSpacing: 1.0,
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            '${displayName.toUpperCase()} Lv.${pet.level}',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Image.asset(
            path,
            width: 50,
            height: 50,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.pets, size: 50),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.deepOrange,
                size: 12,
              ),
              Center(
                child: Text(
                  '${tr('streak')} ${pet.streak}   ${tr('best')} ${pet.bestStreak}',
                  style: textStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('BOND ', style: textStyle),
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Text('  10', style: textStyle),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_getFavoriteBerry(pet.speciesId)}   ${tr('age')} ${pet.ageMinutes ~/ 1440}d',
            style: textStyle,
          ),
          const SizedBox(height: 16),
          _buildPageDots(0),
        ],
      ),
    );
  }

  Widget _buildPage2(BuildContext context) {
    final pet = engine.pet;

    final textStyle = TextStyle(
      fontSize: 12,
      fontFamily: 'monospace',
      fontWeight: FontWeight.bold,
      color: Colors.blue[900],
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            tr('battle'),
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 16),
          _statRow(tr('atk'), engine.computedAtk, Colors.red, textStyle),
          _statRow(tr('def'), engine.computedDef, Colors.blue, textStyle),
          _statRow(tr('spd'), engine.computedSpd, Colors.green, textStyle),
          _statRow(tr('wgt'), pet.weight, Colors.orange, textStyle),
          const SizedBox(height: 16),
          // Train Strength button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PlayScreen(engine: engine)),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tr('trainStr'),
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPageDots(1),
        ],
      ),
    );
  }

  Widget _buildPage3(BuildContext context) {
    final pet = engine.pet;

    // Count unlocked medals
    int count = 0;
    for (int i = 0; i < 8; i++) {
      if ((pet.medals & (1 << i)) != 0) count++;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            '${tr('medals')} $count/8',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 16),
          // 4 rows of 2
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _medalBtn(tr('lv10'), (pet.medals & Medals.lv10) != 0),
              const SizedBox(width: 8),
              _medalBtn(tr('lv25'), (pet.medals & Medals.lv25) != 0),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _medalBtn(tr('lv50'), (pet.medals & Medals.lv50) != 0),
              const SizedBox(width: 8),
              _medalBtn(tr('berryFound'), (pet.medals & Medals.berry) != 0),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _medalBtn(tr('streak7'), (pet.medals & Medals.streak7) != 0),
              const SizedBox(width: 8),
              _medalBtn(tr('maxBond'), (pet.medals & Medals.bond) != 0),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _medalBtn(tr('finalForm'), (pet.medals & Medals.finalForm) != 0),
              const SizedBox(width: 8),
              _medalBtn(tr('inShape'), (pet.medals & Medals.fit) != 0),
            ],
          ),
          const SizedBox(height: 16),
          _buildPageDots(2),
        ],
      ),
    );
  }

  Widget _medalBtn(String text, bool unlocked) {
    return Container(
      width: 95,
      height: 24,
      decoration: BoxDecoration(
        color: unlocked ? Colors.greenAccent[400] : Colors.black12,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (unlocked)
            const Icon(Icons.check_circle, size: 10, color: Colors.white),
          if (unlocked) const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: unlocked ? Colors.white : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage4(BuildContext context) {
    final pet = engine.pet;
    final entry = dex[pet.speciesId];

    final int nextLevel = pet.level + 1;
    final int minIntoLevel = pet.ageMinutes % 60; // minutesPerLevel = 60
    final int minToNext = 60 - minIntoLevel;
    final double progress = minIntoLevel / 60.0;

    String evolveText = tr('finalForm');
    if (!entry.isFinalForm) {
      if (entry.evolveLevel > 0) {
        if (entry.evolveLevel <= pet.level) {
          evolveText = tr('readyEvolve');
        } else {
          evolveText =
              '${tr('evolvesIn')} ${entry.evolveLevel - pet.level} ${tr('lv')}';
        }
      } else {
        evolveText = tr('evolvesVia');
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            tr('progress'),
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${tr('lv')}${pet.level}',
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),

          const SizedBox(height: 8),
          Container(
            width: 120,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.greenAccent[400],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),
          Text(
            '$minToNext ${tr('minToNext')}$nextLevel',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),

          const SizedBox(height: 10),
          Text(
            tr('evolution'),
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.black26,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            evolveText,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),

          const SizedBox(height: 10),
          Text(
            '${tr('slipUps')}: ${pet.careMistakes}',
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),

          const SizedBox(height: 16),
          _buildPageDots(3),
        ],
      ),
    );
  }

  Widget _statRow(String label, int val, Color color, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 30, child: Text(label, style: style)),
          Container(
            width: 70,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (val / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              val.toString(),
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageDots(int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Icon(
            index == currentIndex ? Icons.circle : Icons.circle_outlined,
            size: 6,
            color: Colors.black54,
          ),
        );
      }),
    );
  }

  String _getFavoriteBerry(int speciesId) {
    if (speciesId < 0) return tr('berryUnk');
    final color = speciesId % 3;
    if (color == 0) return tr('berryRed');
    if (color == 1) return tr('berryBlue');
    return tr('berryGreen');
  }
}
