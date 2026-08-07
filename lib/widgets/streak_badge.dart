import 'package:flutter/material.dart';

class StreakBadge extends StatelessWidget {
  final int streak;
  const StreakBadge({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('🔥 $streak', style: const TextStyle(fontSize: 8, color: Colors.white)),
    );
  }
}
