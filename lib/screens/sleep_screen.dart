import 'package:flutter/material.dart';
import '../services/game_engine.dart';

class SleepScreen extends StatelessWidget {
  final GameEngine engine;
  const SleepScreen({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Sleep'),
      ),
    );
  }
}
