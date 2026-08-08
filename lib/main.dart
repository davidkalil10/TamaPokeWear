import 'package:flutter/material.dart';

import 'app.dart';
import 'services/game_engine.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  final notificationService = NotificationService();
  await notificationService.init();

  final engine = GameEngine(storage: storage);
  await engine.init();

  runApp(TamaPokeApp(engine: engine));
}
