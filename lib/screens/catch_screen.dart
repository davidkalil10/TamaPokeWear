import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/game_engine.dart';
import '../services/audio_service.dart';
import '../data/pokedex.dart';
import '../i18n/strings.dart';
import '../widgets/biome_background.dart';
import '../widgets/action_buttons.dart';

class CatchScreen extends StatefulWidget {
  final GameEngine engine;
  const CatchScreen({super.key, required this.engine});

  @override
  State<CatchScreen> createState() => _CatchScreenState();
}

class _CatchScreenState extends State<CatchScreen> {
  int _score = 0;
  int _lives = 5;
  bool _playing = true;
  bool _done = false;

  late Alignment _targetAlignment;
  final _random = math.Random();
  Timer? _moveTimer;
  int _moveDurationMs = 1500;

  @override
  void initState() {
    super.initState();
    _targetAlignment = const Alignment(0, -0.3); // Start near top
    _startTimer();
  }

  void _startTimer() {
    _moveTimer?.cancel();
    _moveTimer = Timer.periodic(Duration(milliseconds: _moveDurationMs), (timer) {
      if (!_playing) return;
      _movePokeball();
    });
  }

  void _movePokeball() {
    setState(() {
      // Random x between -0.8 and 0.8, y between -0.8 and 0.1 (avoiding pokemon at bottom)
      double x = (_random.nextDouble() * 1.6) - 0.8;
      double y = (_random.nextDouble() * 0.9) - 0.8; 
      _targetAlignment = Alignment(x, y);
    });
  }

  void _onPokeballTap() {
    if (!_playing) return;
    AudioService().playTap();
    setState(() {
      _score++;
      // Speed up slightly, min 400ms
      _moveDurationMs = math.max(400, (_moveDurationMs * 0.95).round());
      _movePokeball();
    });
    // Restart timer with new speed
    _startTimer();
  }

  void _onBackgroundTap() {
    if (!_playing) return;
    AudioService().playDeny();
    setState(() {
      _lives--;
      if (_lives <= 0) {
        _endGame();
      }
    });
  }

  void _endGame() {
    _playing = false;
    _moveTimer?.cancel();
    setState(() => _done = true);
    widget.engine.playResult(_score); // Uses the engine's original logic!
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    super.dispose();
  }

  Widget _buildSprite(dynamic pet, Size size) {
    final entry = dex[pet.speciesId];
    final spriteSize = size.width * 0.35;
    final folder = pet.shiny ? 'shiny' : 'normal';
    const action = 'walk';
    
    return Image.asset(
      'assets/sprites/$folder/${pet.speciesId.toString().padLeft(3, '0')}_$action.gif',
      width: spriteSize,
      height: spriteSize,
      fit: BoxFit.contain,
      errorBuilder: (ctx, err, stack) => Icon(Icons.help_outline, size: spriteSize, color: Colors.white),
    );
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pet = widget.engine.pet;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background
          Positioned.fill(child: BiomeBackground(type: dex[pet.speciesId].type, sleeping: false)),

          // Game Layer
          if (!_done)
            Positioned.fill(
              child: GestureDetector(
                onTap: _onBackgroundTap,
                child: Container(
                  color: Colors.transparent, // Required to capture taps
                  child: Stack(
                    children: [
                      // UI
                      Positioned(
                        top: size.height * 0.1,
                        left: 0, right: 0,
                        child: Column(
                          children: [
                            Text(
                              '$_score',
                              style: const TextStyle(fontSize: 24, fontFamily: 'monospace', color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('REST ', style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.white)),
                                Text('$_lives ', style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.white, fontWeight: FontWeight.bold)),
                                for (int i = 0; i < 5; i++)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(
                                        color: i < _lives ? Colors.redAccent : Colors.white24,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Pokemon at bottom
                      Positioned(
                        bottom: size.height * 0.15,
                        left: size.width * 0.325,
                        child: IgnorePointer(
                          child: _buildSprite(pet, size),
                        ),
                      ),

                      // Pokeball
                      AnimatedAlign(
                        alignment: _targetAlignment,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutQuad,
                        child: GestureDetector(
                          onTap: _onPokeballTap,
                          child: const PokeballIcon(size: 36),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tr('done'), style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('${tr('score')}: $_score', style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

