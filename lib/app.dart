import 'package:flutter/material.dart';
import 'package:wear_plus/wear_plus.dart';

import 'screens/home_screen.dart';
import 'services/game_engine.dart';
import 'theme/wear_theme.dart';

class TamaPokeApp extends StatelessWidget {
  final GameEngine engine;

  const TamaPokeApp({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TamaPokeWear',
      theme: WearTheme.dark,
      home: WatchShape(
        builder: (context, shape, child) {
          return AmbientMode(
            builder: (context, mode, child) {
              return HomeScreen(engine: engine);
            },
          );
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
