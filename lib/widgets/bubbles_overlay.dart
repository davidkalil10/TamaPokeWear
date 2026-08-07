import 'dart:math';
import 'package:flutter/material.dart';

class BubblesOverlay extends StatefulWidget {
  const BubblesOverlay({super.key});

  @override
  State<BubblesOverlay> createState() => _BubblesOverlayState();
}

class _BubblesOverlayState extends State<BubblesOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  late List<_Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    // Generate random bubbles
    _bubbles = List.generate(20, (index) {
      return _Bubble(
        startX: _random.nextDouble() * 100 - 50, // relative to center
        startY: _random.nextDouble() * 50,
        size: _random.nextDouble() * 25 + 10,
        speed: _random.nextDouble() * 100 + 50,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: _bubbles.map((b) {
            double currentY = b.startY - (_controller.value * b.speed);
            return Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Transform.translate(
                offset: Offset(b.startX, currentY),
                child: Center(
                  child: Container(
                    width: b.size,
                    height: b.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.6 * (1 - _controller.value)),
                      border: Border.all(
                        color: Colors.blueAccent.withValues(alpha: 0.8 * (1 - _controller.value)),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Bubble {
  final double startX;
  final double startY;
  final double size;
  final double speed;

  _Bubble({
    required this.startX,
    required this.startY,
    required this.size,
    required this.speed,
  });
}
