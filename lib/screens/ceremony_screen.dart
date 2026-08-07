import 'package:flutter/material.dart';
import '../models/pet_state.dart';
import '../services/game_engine.dart';
import '../i18n/strings.dart';

class CeremonyScreen extends StatelessWidget {
  final GameEngine engine;
  final Ceremony type;

  const CeremonyScreen({super.key, required this.engine, required this.type});

  @override
  Widget build(BuildContext context) {
    String msg = '';
    if (type == Ceremony.farewell) msg = tr('bye');
    else if (type == Ceremony.runaway) msg = 'Runaway...';
    else if (type == Ceremony.release) msg = 'Released';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber, size: 40),
            const SizedBox(height: 10),
            Text(msg, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                engine.endCeremony();
                Navigator.pop(context);
              },
              child: const Text('OK', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}
