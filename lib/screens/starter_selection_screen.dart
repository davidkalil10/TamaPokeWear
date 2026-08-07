import 'package:flutter/material.dart';
import '../services/game_engine.dart';
import '../theme/wear_theme.dart';
import '../data/pokedex.dart';
import '../i18n/strings.dart';

class StarterSelectionScreen extends StatelessWidget {
  final GameEngine engine;

  const StarterSelectionScreen({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tr('chooseStarter'), style: const TextStyle(fontSize: 10, color: Colors.white)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _starterBtn(context, 1),
                const SizedBox(width: 8),
                _starterBtn(context, 4),
                const SizedBox(width: 8),
                _starterBtn(context, 7),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _starterBtn(BuildContext context, int speciesId) {
    final entry = dex[speciesId];
    return GestureDetector(
      onTap: () {
        engine.chooseStarter(speciesId);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: WearTheme.typeColor(entry.type).withValues(alpha: 0.3),
          shape: BoxShape.circle,
          border: Border.all(color: WearTheme.typeColor(entry.type), width: 2),
        ),
        child: Center(
          child: Text('#${speciesId.toString().padLeft(3, '0')}', style: const TextStyle(fontSize: 10)),
        ),
      ),
    );
  }
}
