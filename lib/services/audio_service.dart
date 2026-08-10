import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _enabled = true;
  String? _currentBgmTrack;

  bool get enabled => _enabled;
  set enabled(bool val) {
    _enabled = val;
    if (!val) {
      _bgmPlayer.pause();
    } else if (_currentBgmTrack != null && _currentBgmTrack != 'none') {
      _bgmPlayer.play();
    }
  }

  Future<void> init() async {
    // just_audio handles AudioContext out of the box very well.
    await _bgmPlayer.setLoopMode(LoopMode.one);
  }

  // --- BGM Methods ---

  Future<void> playBgm(String trackName) async {
    _currentBgmTrack = trackName;
    if (!_enabled) return;
    
    if (trackName == 'none') {
      await _bgmPlayer.stop();
      return;
    }
    
    // just_audio uses setAsset instead of AssetSource
    await _bgmPlayer.setAsset('assets/bgm/$trackName.mp3');
    await _bgmPlayer.setLoopMode(LoopMode.one);
    _bgmPlayer.play();
  }

  Future<void> pauseBgm() async {
    await _bgmPlayer.pause();
  }

  Future<void> resumeBgm() async {
    if (_enabled && _currentBgmTrack != null && _currentBgmTrack != 'none') {
      await _bgmPlayer.play();
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  // --- SFX Methods ---

  Future<void> play(String sfx) async {
    if (!_enabled) return;
    final p = AudioPlayer();
    await p.setAsset('assets/sounds/$sfx.wav');
    // In just_audio, play() returns a future that completes when the sound finishes playing!
    p.play().then((_) => p.dispose());
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
