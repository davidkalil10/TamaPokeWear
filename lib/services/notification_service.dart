import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timeZoneInfo.identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // App abre quando a notificação é clicada
      },
    );
    
    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> scheduleCareNotification(
      int id, DateTime scheduledDate, String title, String body, {int? speciesId}) async {
    if (!_isInitialized) return;
    if (scheduledDate.isBefore(DateTime.now())) return;

    AndroidBitmap<Object>? largeIcon;
    if (speciesId != null && speciesId > 0) {
      try {
        final String dexNum = speciesId.toString().padLeft(3, '0');
        final ByteData byteData = await rootBundle.load('assets/sprites/thumbs/$dexNum.png');
        final Uint8List bytes = byteData.buffer.asUint8List();
        largeIcon = ByteArrayAndroidBitmap(bytes);
      } catch (e) {
        // Ignora se não achar o thumb
      }
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'tamapoke_care_channel',
          'Alerta de Cuidados',
          channelDescription: 'Avisa quando o seu Pokémon estiver precisando de ajuda',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          largeIcon: largeIcon,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
