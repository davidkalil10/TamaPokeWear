import 'package:flutter/material.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'screens/home_screen.dart';
import 'services/game_engine.dart';
import 'screens/mobile_wrapper.dart';
import 'theme/wear_theme.dart';

class TamaPokeApp extends StatefulWidget {
  final GameEngine engine;
  final String flavor;

  const TamaPokeApp({super.key, required this.engine, this.flavor = 'wear'});

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
    debugPrint("[TamaPokeApp] AppLifecycleState changed to: $state");
    if (state == AppLifecycleState.paused) {
      widget.engine.pauseGame();
      widget.engine.scheduleFutureNotifications();
    } else if (state == AppLifecycleState.resumed) {
      widget.engine.resumeGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget homeWidget;
    
    if (widget.flavor == 'mobile') {
      homeWidget = MobileWrapper(engine: widget.engine);
    } else {
      homeWidget = WatchShape(
        builder: (context, shape, child) {
          return AmbientMode(
            builder: (context, mode, child) {
              return HomeScreen(engine: widget.engine);
            },
          );
        },
      );
    }

    return MaterialApp(
      title: 'TamaPokeWear',
      theme: WearTheme.dark,
      home: homeWidget,
      debugShowCheckedModeBanner: false,
    );
  }
}
