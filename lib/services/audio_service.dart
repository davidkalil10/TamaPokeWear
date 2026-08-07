import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;

  bool get enabled => _enabled;
  set enabled(bool val) => _enabled = val;

  Future<void> init() async {
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  void play(String sfx) {
    if (!_enabled) return;
    _player.play(AssetSource('sounds/$sfx.wav'));
  }

  void playTap() => play('tap');
  void playEat() => play('eat');
  void playPlay() => play('play');
  void playHeart() => play('heart');
  void playHatch() => play('hatch');
  void playEvolve() => play('evolve');
  void playMedal() => play('medal');
  void playDeny() => play('deny');
  void playBye() => play('bye');
  void playLevel() => play('level');
}
