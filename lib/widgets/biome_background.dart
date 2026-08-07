import 'package:flutter/material.dart';

class BiomeBackground extends StatelessWidget {
  final String type;
  final bool sleeping;
  const BiomeBackground({super.key, required this.type, this.sleeping = false});

  @override
  Widget build(BuildContext context) {
    Color skyColor = sleeping ? const Color(0xFF101820) : const Color(0xFF4A90E2);
    Color horizonColor = sleeping ? const Color(0xFF0D1218) : const Color(0xFF1565C0);
    Color groundColor = sleeping ? const Color(0xFF2A2A1A) : const Color(0xFFE2C288);

    if (type == 'fire') {
      groundColor = sleeping ? const Color(0xFF3A1515) : const Color(0xFFD47348);
    } else if (type == 'grass') {
      groundColor = sleeping ? const Color(0xFF153A15) : const Color(0xFF88E288);
    }

    return Column(
      children: [
        // Sky with Sun/Moon
        Expanded(
          flex: 50,
          child: Container(
            color: skyColor,
            child: Stack(
              children: [
                Positioned(
                  top: 40,
                  right: 60,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sleeping ? Colors.white70 : const Color(0xFFFFD54F),
                      boxShadow: [
                        BoxShadow(
                          color: (sleeping ? Colors.white : const Color(0xFFFFD54F)).withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!sleeping)
                  Positioned(
                    top: 50,
                    right: 100,
                    child: const Icon(Icons.cloud, color: Colors.white54, size: 40),
                  ),
              ],
            ),
          ),
        ),
        // Horizon line
        Expanded(
          flex: 4,
          child: Container(color: horizonColor),
        ),
        // Ground
        Expanded(
          flex: 46,
          child: Container(color: groundColor),
        ),
      ],
    );
  }
}
