import 'dart:async';
import 'package:flutter/material.dart';
import '../services/game_engine.dart';
import '../services/audio_service.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
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

  final BackupService _backupService = BackupService();
  bool _isBackupLoading = false;
  DateTime? _lastBackupDate;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _initBackup();
  }

  Future<void> _initBackup() async {
    await _backupService.signInSilently();
    if (_backupService.currentUser != null) {
      _refreshBackupDate();
    } else {
      if (mounted) setState(() {});
    }
  }

  Future<void> _refreshBackupDate() async {
    final date = await _backupService.getBackupDate();
    if (mounted) setState(() => _lastBackupDate = date);
  }

  Future<void> _loginGoogle() async {
    setState(() => _isBackupLoading = true);
    await _backupService.signIn();
    if (_backupService.currentUser != null) {
      await _refreshBackupDate();
    }
    if (mounted) setState(() => _isBackupLoading = false);
  }

  Future<void> _logoutGoogle() async {
    setState(() => _isBackupLoading = true);
    await _backupService.signOut();
    if (mounted) setState(() {
      _isBackupLoading = false;
      _lastBackupDate = null;
    });
  }

  Future<void> _doBackup() async {
    setState(() => _isBackupLoading = true);
    
    // Assegura que os dados estão totalmente descarregados no arquivo no disco
    await widget.engine.prepareForBackup();
    
    final success = await _backupService.backupData();
    
    // Reabre o Hive de forma transparente
    await widget.engine.resumeAfterBackup();
    
    if (success) {
      await _refreshBackupDate();
    }
    if (mounted) setState(() => _isBackupLoading = false);
  }

  Future<void> _doRestore() async {
    setState(() => _isBackupLoading = true);
    final success = await _backupService.restoreData();
    if (success) {
      await widget.engine.reloadEngine();
    }
    if (mounted) setState(() => _isBackupLoading = false);
  }

  Future<void> _doDeleteBackup() async {
    setState(() => _isBackupLoading = true);
    final success = await _backupService.deleteBackup();
    if (success) {
      await _refreshBackupDate();
    }
    if (mounted) setState(() => _isBackupLoading = false);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _toggleSound() {
    setState(() {
      AudioService().enabled = !AudioService().enabled;
      widget.engine.pet.soundOn = AudioService().enabled;
      widget.engine.forceSave();
    });
    AudioService().playTap();
  }

  void _cycleLanguage() {
    AudioService().playTap();
    setState(() {
      final nextIndex = (currentLang.index + 1) % Lang.values.length;
      currentLang = Lang.values[nextIndex];
      widget.engine.pet.langIndex = nextIndex;
      widget.engine.forceSave();
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
                const SizedBox(width: 10),
                // Lang button
                GestureDetector(
                  onTap: _cycleLanguage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // BGM button
                GestureDetector(
                  onTap: () {
                    AudioService().playTap();
                    setState(() {
                      widget.engine.bgmCycle();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.engine.bgmTrackName == 'none' ? Colors.grey : const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'BGM: ${widget.engine.bgmTrackName.toUpperCase()}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Cloud Save Section
            const Text('CLOUD SAVE', style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (_isBackupLoading)
              const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
            else if (_backupService.currentUser == null)
              GestureDetector(
                onTap: _loginGoogle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(6)),
                  child: const Text('LOGIN GOOGLE', style: TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                ),
              )
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _doBackup,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(6)),
                          child: const Text('BKP UP', style: TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _doRestore,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(6)),
                          child: const Text('DL SAVE', style: TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _doDeleteBackup,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(6)),
                          child: const Text('DEL BKP', style: TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _logoutGoogle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          decoration: BoxDecoration(color: Colors.blueGrey, borderRadius: BorderRadius.circular(6)),
                          child: const Text('OUT', style: TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(_lastBackupDate != null ? 'Last: ${_lastBackupDate!.day}/${_lastBackupDate!.month} ${_lastBackupDate!.hour}:${_lastBackupDate!.minute.toString().padLeft(2,'0')}' : 'No backup found', 
                       style: const TextStyle(fontSize: 8, color: Colors.black54, fontFamily: 'monospace')),
                ],
              ),
              
            const SizedBox(height: 16),
            /*
            const Text('NOTIFICATIONS', style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    AudioService().playTap();
                    NotificationService().scheduleCareNotification(
                      99,
                      DateTime.now().add(const Duration(seconds: 5)),
                      'Teste de Imagem',
                      'Veja se o sprite apareceu no fundo!',
                      speciesId: widget.engine.pet.speciesId,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(6)),
                    child: const Text('TEST (5s)', style: TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            */
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
