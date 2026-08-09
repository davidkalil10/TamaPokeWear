import 'package:flutter/material.dart';
import '../models/pet_state.dart';
import '../services/game_engine.dart';
import '../i18n/strings.dart';

import '../services/audio_service.dart';

class CeremonyScreen extends StatefulWidget {
  final GameEngine engine;
  final Ceremony type;

  const CeremonyScreen({super.key, required this.engine, required this.type});

  @override
  State<CeremonyScreen> createState() => _CeremonyScreenState();
}

class _CeremonyScreenState extends State<CeremonyScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.type == Ceremony.farewell) {
      AudioService().playBgm('ending');
    }
  }

  @override
  void dispose() {
    widget.engine.applyBgm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String msg = '';
    IconData iconData = Icons.auto_awesome;
    Color iconColor = Colors.amber;
    
    if (widget.type == Ceremony.farewell) {
      msg = tr('farewell');
      iconData = Icons.favorite;
      iconColor = Colors.pinkAccent;
    } else if (widget.type == Ceremony.runaway) {
      msg = tr('runaway');
      iconData = Icons.directions_run;
      iconColor = Colors.blueGrey;
    } else if (widget.type == Ceremony.release) {
      msg = tr('released');
      iconData = Icons.outbox_rounded;
      iconColor = Colors.lightBlueAccent;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/sprites/ui/ceremony_bg.png',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.5), // Escurece um pouco para o texto ficar legível
            colorBlendMode: BlendMode.darken,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(iconData, color: iconColor, size: 42, shadows: const [Shadow(blurRadius: 4, color: Colors.black)]),
                  const SizedBox(height: 12),
                  Text(
                    msg, 
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      widget.engine.endCeremony();
                      Navigator.pop(context);
                    },
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.greenAccent, size: 28),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
