import 'package:flutter/material.dart';
import '../services/game_engine.dart';
import '../i18n/strings.dart';

class BathScreen extends StatefulWidget {
  final GameEngine engine;
  const BathScreen({super.key, required this.engine});

  @override
  State<BathScreen> createState() => _BathScreenState();
}

class _BathScreenState extends State<BathScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        widget.engine.bath();
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.withValues(alpha: 0.3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water_drop, color: Colors.blue, size: 40),
            const SizedBox(height: 10),
            Text(tr('needsBath'), style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
