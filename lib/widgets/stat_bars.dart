import 'package:flutter/material.dart';
import '../i18n/strings.dart';

class StatBars extends StatelessWidget {
  final int food, joy, energy, hygiene;
  final double width;
  final bool sleeping;
  final bool isMobile;

  const StatBars({
    super.key,
    required this.food,
    required this.joy,
    required this.energy,
    required this.hygiene,
    this.width = 180,
    this.sleeping = false,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _statItem(tr('food'), food),
              const SizedBox(width: 8),
              _statItem(tr('joy'), joy),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _statItem(tr('ene'), energy),
              const SizedBox(width: 8),
              _statItem(tr('hyg'), hygiene),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, int value) {
    Color barColor = Colors.green;
    if (value < 50) barColor = Colors.orange;
    if (value < 20) barColor = Colors.red;

    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 12 : 10,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: sleeping ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: isMobile ? 8 : 6,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(1),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (value / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
