import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _enabled = true;
  String? _currentBgmTrack;

  bool get enabled => _enabled;
  set enabled(bool val) {
    _enabled = val;
    if (!val) {
      _bgmPlayer.pause();
    } else if (_currentBgmTrack != null && _currentBgmTrack != 'none') {
      _bgmPlayer.resume();
    }
  }

  Future<void> init() async {
    // BGM: no audio focus so it never gets interrupted
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.none,
      ),
    ));

    // SFX: also no audio focus so it won't steal from BGM
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.assistanceSonification,
        audioFocus: AndroidAudioFocus.none,
      ),
    ));
  }

  // --- BGM Methods ---

  Future<void> playBgm(String trackName) async {
    _currentBgmTrack = trackName;
    if (!_enabled) return;
    
    if (trackName == 'none') {
      await _bgmPlayer.stop();
      return;
    }
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('bgm/$trackName.mp3'));
  }

  Future<void> pauseBgm() async {
    await _bgmPlayer.pause();
  }

  Future<void> resumeBgm() async {
    if (_enabled && _currentBgmTrack != null && _currentBgmTrack != 'none') {
      await _bgmPlayer.resume();
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  // --- SFX Methods ---

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
