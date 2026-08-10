import 'package:flutter/material.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'screens/home_screen.dart';
import 'services/game_engine.dart';
import 'theme/wear_theme.dart';

class TamaPokeApp extends StatefulWidget {
  final GameEngine engine;

  const TamaPokeApp({super.key, required this.engine});

  @override
  State<TamaPokeApp> createState() => _TamaPokeAppState();
}

class _TamaPokeAppState extends State<TamaPokeApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    widget.engine.cancelAllNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      widget.engine.forceSave();
      widget.engine.scheduleFutureNotifications();
    } else if (state == AppLifecycleState.resumed) {
      widget.engine.resumeGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TamaPokeWear',
      theme: WearTheme.dark,
      home: WatchShape(
        builder: (context, shape, child) {
          return AmbientMode(
            builder: (context, mode, child) {
              return HomeScreen(engine: widget.engine);
            },
          );
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
