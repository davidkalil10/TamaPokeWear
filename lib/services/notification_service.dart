import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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

    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        'tamapoke_care_channel',
        'Alerta de Cuidados',
        description: 'Avisa quando o seu Pokémon estiver precisando de ajuda',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      ),
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
        final File? file = await _getScaledThumb(speciesId);
        if (file != null) {
          largeIcon = FilePathAndroidBitmap(file.path);
        }
      } catch (e) {
        // Ignora
      }
    }

    try {
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
            styleInformation: largeIcon != null 
                ? BigPictureStyleInformation(largeIcon, hideExpandedLargeIcon: true) 
                : null,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Se o relógio bloquear alarmes exatos (SecurityException), fazemos o fallback para inexato
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
            styleInformation: largeIcon != null 
                ? BigPictureStyleInformation(largeIcon, hideExpandedLargeIcon: true) 
                : null,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<File?> _getScaledThumb(int speciesId) async {
    try {
      final String dexNum = speciesId.toString().padLeft(3, '0');
      final ByteData byteData = await rootBundle.load('assets/sprites/thumbs/$dexNum.png');
      final Uint8List list = byteData.buffer.asUint8List();
      
      final ui.Codec codec = await ui.instantiateImageCodec(list);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;
      
      // Aumenta a imagem em 3x para ocupar adequadamente o bloco da notificação no WearOS
      final int scale = 3;
      final int targetWidth = image.width * scale;
      final int targetHeight = image.height * scale;
      
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(recorder);
      
      final Paint paint = Paint()..filterQuality = FilterQuality.none;
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
        paint,
      );
      
      final ui.Picture picture = recorder.endRecording();
      final ui.Image scaledImage = await picture.toImage(targetWidth, targetHeight);
      final ByteData? pngBytes = await scaledImage.toByteData(format: ui.ImageByteFormat.png);
      
      if (pngBytes != null) {
        final Directory tempDir = await getTemporaryDirectory();
        final File file = File('${tempDir.path}/thumb_scaled_$dexNum.png');
        await file.writeAsBytes(pngBytes.buffer.asUint8List(), flush: true);
        return file;
      }
    } catch (e) {
      debugPrint('Erro ao escalar sprite: $e');
    }
    return null;
  }
}
