import 'package:flutter/material.dart';
import '../services/game_engine.dart';
import '../i18n/strings.dart';

class FeedScreen extends StatelessWidget {
  final GameEngine engine;
  const FeedScreen({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tr('feed'), style: const TextStyle(color: Colors.white, fontSize: 12)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _foodBtn(context, Colors.red, () => _feedAndPop(context, () => engine.feedBerry(0))),
                const SizedBox(width: 8),
                _foodBtn(context, Colors.blue, () => _feedAndPop(context, () => engine.feedBerry(1))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _foodBtn(context, Colors.green, () => _feedAndPop(context, () => engine.feedBerry(2))),
                const SizedBox(width: 8),
                _foodBtn(context, Colors.orange, () => _feedAndPop(context, engine.feedCandy), icon: Icons.cake),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _feedAndPop(BuildContext context, VoidCallback action) {
    action();
    Navigator.pop(context);
  }

  Widget _foodBtn(BuildContext context, Color color, VoidCallback onTap, {IconData icon = Icons.apple}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.3), shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
