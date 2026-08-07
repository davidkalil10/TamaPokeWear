import 'package:flutter/material.dart';
import '../services/game_engine.dart';

class EggScreen extends StatelessWidget {
  final GameEngine engine;
  const EggScreen({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () => engine.tapEgg(),
          child: const Text('🥚', style: TextStyle(fontSize: 48)),
        ),
      ),
    );
  }
}
