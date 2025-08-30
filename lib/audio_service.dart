import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';

/// Audio service class to handle audio playback functionality
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  
  // Stream controllers for audio state
  final BehaviorSubject<bool> _isPlayingSubject = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<Duration> _positionSubject = BehaviorSubject<Duration>.seeded(Duration.zero);
  final BehaviorSubject<Duration?> _durationSubject = BehaviorSubject<Duration?>.seeded(null);
  final BehaviorSubject<String?> _currentTrackSubject = BehaviorSubject<String?>.seeded(null);

  // Public streams
  Stream<bool> get isPlayingStream => _isPlayingSubject.stream;
  Stream<Duration> get positionStream => _positionSubject.stream;
  Stream<Duration?> get durationStream => _durationSubject.stream;
  Stream<String?> get currentTrackStream => _currentTrackSubject.stream;

  // Getters for current state
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  String? get currentTrack => _currentTrackSubject.value;

  /// Initialize the audio service
  Future<void> initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    
    // Listen to player state changes
    _player.playingStream.listen(_isPlayingSubject.add);
    _player.positionStream.listen(_positionSubject.add);
    _player.durationStream.listen(_durationSubject.add);
  }

  /// Load and play audio from URL
  Future<void> playFromUrl(String url, {String? title}) async {
    try {
      await _player.setUrl(url);
      _currentTrackSubject.add(title ?? url);
      await _player.play();
    } catch (e) {
      throw AudioException('Failed to play audio from URL: $e');
    }
  }

  /// Load and play audio from asset
  Future<void> playFromAsset(String assetPath, {String? title}) async {
    try {
      await _player.setAsset(assetPath);
      _currentTrackSubject.add(title ?? assetPath);
      await _player.play();
    } catch (e) {
      throw AudioException('Failed to play audio from asset: $e');
    }
  }

  /// Play audio
  Future<void> play() async {
    await _player.play();
  }

  /// Pause audio
  Future<void> pause() async {
    await _player.pause();
  }

  /// Stop audio
  Future<void> stop() async {
    await _player.stop();
    _currentTrackSubject.add(null);
  }

  /// Seek to position
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// Set loop mode
  Future<void> setLoopMode(LoopMode loopMode) async {
    await _player.setLoopMode(loopMode);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _player.dispose();
    await _isPlayingSubject.close();
    await _positionSubject.close();
    await _durationSubject.close();
    await _currentTrackSubject.close();
  }
}

/// Custom exception for audio operations
class AudioException implements Exception {
  final String message;
  AudioException(this.message);

  @override
  String toString() => 'AudioException: $message';
}
