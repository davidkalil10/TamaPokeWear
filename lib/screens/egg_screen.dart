import 'package:flutter/material.dart';
import 'dart:math';
import '../services/game_engine.dart';
import '../i18n/strings.dart';

class EggScreen extends StatefulWidget {
  final GameEngine engine;
  const EggScreen({super.key, required this.engine});

  @override
  State<EggScreen> createState() => _EggScreenState();
}

class _EggScreenState extends State<EggScreen> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onTapEgg() {
    if (!_shakeController.isAnimating) {
      _shakeController.forward(from: 0.0);
    }
    widget.engine.tapEgg();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/sprites/ui/egg_bg.png',
            fit: BoxFit.cover,
          ),
          // Egg with shake animation
          Center(
            child: GestureDetector(
              onTap: _onTapEgg,
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  // A simple shake effect using sine wave
                  final sineValue = sin(_shakeController.value * 4 * pi);
                  return Transform.translate(
                    offset: Offset(sineValue * 8, 0),
                    child: Transform.rotate(
                      angle: sineValue * 0.1,
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  'assets/sprites/ui/egg.png',
                  width: 100, // Adjust size as needed for WearOS screen
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Prompt text
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Text(
              tr('eggTouch'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
