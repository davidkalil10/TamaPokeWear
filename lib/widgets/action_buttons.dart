import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onFeed, onPlay, onSleep, onBath;
  final bool sleeping;
  final double width;

  const ActionButtons({
    super.key,
    required this.onFeed,
    required this.onPlay,
    required this.onSleep,
    required this.onBath,
    required this.sleeping,
    this.width = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(0, -10),
            child: _customActionBtn(const BerryIcon(color: Colors.redAccent), onFeed),
          ),
          const SizedBox(width: 8),
          Transform.translate(
            offset: const Offset(0, 5),
            child: _customActionBtn(const PokeballIcon(), onPlay),
          ),
          const SizedBox(width: 8),
          Transform.translate(
            offset: const Offset(0, 5),
            child: _actionBtn(sleeping ? Icons.wb_sunny : Icons.dark_mode, sleeping ? Colors.orange : Colors.indigo, onSleep),
          ),
          const SizedBox(width: 8),
          Transform.translate(
            offset: const Offset(0, -10),
            child: _actionBtn(Icons.water_drop, Colors.lightBlue, onBath),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color iconColor, VoidCallback onTap) {
    return _customActionBtn(Icon(icon, color: iconColor, size: 18), onTap);
  }

  Widget _customActionBtn(Widget child, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black26, width: 1),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class PokeballIcon extends StatelessWidget {
  final double size;
  const PokeballIcon({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black87, width: 1.5),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.redAccent, Colors.redAccent, Colors.black87, Colors.black87, Colors.white, Colors.white],
          stops: [0.0, 0.45, 0.45, 0.55, 0.55, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: size * 0.35,
          height: size * 0.35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.black87, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class BerryIcon extends StatelessWidget {
  final Color color;
  const BerryIcon({super.key, this.color = Colors.lightBlue});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black87, width: 1.5),
            ),
          ),
          const Positioned(
            top: -2,
            child: Icon(Icons.eco, size: 10, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
