import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/game_engine.dart';
import '../data/pokedex.dart';
import '../i18n/strings.dart';
import '../widgets/biome_background.dart';

class PlayScreen extends StatefulWidget {
  final GameEngine engine;
  const PlayScreen({super.key, required this.engine});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with TickerProviderStateMixin {
  int _score = 0;
  bool _playing = true;
  late AnimationController _timerCtrl;
  late AnimationController _punchCtrl;
  late Animation<double> _punchAnim;

  @override
  void initState() {
    super.initState();
    // 5 seconds timer
    _timerCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _timerCtrl.reverse(from: 1.0);
    
    _timerCtrl.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() => _playing = false);
        widget.engine.playResult(_score);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    });

    // Punch animation
    _punchCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _punchAnim = Tween<double>(begin: 0, end: 15).animate(CurvedAnimation(parent: _punchCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _timerCtrl.dispose();
    _punchCtrl.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!_playing) return;
    setState(() => _score++);
    _punchCtrl.forward(from: 0).then((_) => _punchCtrl.reverse());
  }

  Widget _buildPunchingBag() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 2, height: 15, color: Colors.white70), // String
        Container(
          width: 50,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white70, width: 2),
          ),
          child: Center(
            child: Container(
              height: 2,
              color: Colors.black38,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.engine.pet;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background matches main screen
          BiomeBackground(type: pet.isEgg ? 'normal' : dex[pet.speciesId].type, sleeping: pet.sleeping),
          
          if (_playing)
            Stack(
              alignment: Alignment.center,
              children: [
                // Dotted circle background
                CustomPaint(
                  size: const Size(160, 160),
                  painter: _DottedCirclePainter(),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _onTap,
                      child: AnimatedBuilder(
                        animation: _punchAnim,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(_punchAnim.value, 0), // Wiggle horizontally
                          child: child,
                        ),
                        child: _buildPunchingBag(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Score box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70, width: 2),
                      ),
                      child: Text(
                        '$_score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(tr('hitFast'), style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace')),
                    const SizedBox(height: 10),
                    // Timer bar
                    AnimatedBuilder(
                      animation: _timerCtrl,
                      builder: (ctx, _) {
                        return Container(
                          width: 120,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 120 * _timerCtrl.value,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent[400],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(tr('done'), style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('${tr('score')}: $_score', style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
              ],
            ),
        ],
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.fill;
    
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw 8 dots around the circle
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi) / 4;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
