import 'package:flutter/material.dart';
import '../services/game_engine.dart';

class EvolutionScreen extends StatefulWidget {
  final GameEngine engine;
  const EvolutionScreen({super.key, required this.engine});

  @override
  State<EvolutionScreen> createState() => _EvolutionScreenState();
}

class _EvolutionScreenState extends State<EvolutionScreen> {
  bool _evolved = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          widget.engine.evolve();
          _evolved = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.engine.pet;
    final folder = pet.shiny ? 'shiny' : 'normal';
    final path = 'assets/sprites/$folder/${pet.speciesId.toString().padLeft(3, '0')}_idle.gif';
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(seconds: 1),
          child: _evolved
              ? Image.asset(path, key: const ValueKey(1), height: 100)
              : const Icon(Icons.star, key: ValueKey(2), color: Colors.amber, size: 100),
        ),
      ),
    );
  }
}
