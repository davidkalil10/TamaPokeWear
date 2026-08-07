import 'dart:async';
import 'package:flutter/material.dart';
import '../services/game_engine.dart';
import '../services/audio_service.dart';
import '../i18n/strings.dart';

class SettingsScreen extends StatefulWidget {
  final GameEngine engine;
  final VoidCallback onOk;
  const SettingsScreen({super.key, required this.engine, required this.onOk});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _toggleSound() {
    setState(() {
      AudioService().enabled = !AudioService().enabled;
    });
    AudioService().playTap();
  }

  void _cycleLanguage() {
    AudioService().playTap();
    setState(() {
      final nextIndex = (currentLang.index + 1) % Lang.values.length;
      currentLang = Lang.values[nextIndex];
    });
    // Triggers rebuild on the rest of the app to reflect language
    widget.engine.onStateChanged?.call();
  }

  bool _showTimeMsg = false;

  void _onTimeBtnTap() {
    AudioService().playDeny();
    setState(() => _showTimeMsg = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showTimeMsg = false);
    });
  }

  Widget _timeBtn(String label) {
    return GestureDetector(
      onTap: _onTimeBtnTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black45),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hh = _now.hour.toString().padLeft(2, '0');
    final mm = _now.minute.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFFE6E6FA), // Lavender/light purple background
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(tr('setTime'), style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('$hh:$mm', style: const TextStyle(fontFamily: 'monospace', fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _timeBtn('-'),
                const SizedBox(width: 4),
                _timeBtn('+'),
                const SizedBox(width: 20),
                _timeBtn('-'),
                const SizedBox(width: 4),
                _timeBtn('+'),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                Text(tr('hour'), style: const TextStyle(fontSize: 8, color: Colors.black38, fontFamily: 'monospace')),
                const SizedBox(width: 50),
                Text(tr('min'), style: const TextStyle(fontSize: 8, color: Colors.black38, fontFamily: 'monospace')),
                const SizedBox(width: 10),
              ],
            ),
            SizedBox(
              height: 16,
              child: _showTimeMsg
                  ? Text(tr('timeSynced'), style: const TextStyle(fontSize: 8, color: Colors.redAccent, fontFamily: 'monospace', fontWeight: FontWeight.bold))
                  : null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sound button
                GestureDetector(
                  onTap: _toggleSound,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AudioService().enabled ? const Color(0xFF2E7D32) : Colors.grey,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      AudioService().enabled ? tr('sndOn') : tr('sndOff'),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 25),
                // Lang button
                GestureDetector(
                  onTap: _cycleLanguage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black38),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${currentLang.name.toUpperCase()} >',
                      style: const TextStyle(color: Colors.black87, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // OK button
            GestureDetector(
              onTap: () {
                AudioService().playTap();
                widget.onOk();
              },
              child: Container(
                width: 100,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(tr('ok'), style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            Text(tr('swipeUp'), style: const TextStyle(fontSize: 8, color: Colors.black38, fontFamily: 'monospace')),
            
            // Hidden Release button for debug/mechanics
            const SizedBox(height: 10),
            GestureDetector(
              onLongPress: () {
                widget.engine.release();
                widget.onOk();
              },
              child: const Opacity(
                opacity: 0.1,
                child: Icon(Icons.delete, size: 16, color: Colors.black),
              ),
            )
          ],
        ),
        ),
      ),
    );
  }
}
