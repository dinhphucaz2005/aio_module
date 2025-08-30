import 'dart:async';
import 'audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Audio manager class to provide high-level audio management
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioService _audioService = AudioService();
  final List<AudioTrack> _playlist = [];
  int _currentIndex = -1;

  bool get hasPlaylist => _playlist.isNotEmpty;
  int get currentIndex => _currentIndex;
  List<AudioTrack> get playlist => List.unmodifiable(_playlist);
  AudioTrack? get currentTrack => _currentIndex >= 0 && _currentIndex < _playlist.length
      ? _playlist[_currentIndex]
      : null;

  // Expose audio service streams
  Stream<bool> get isPlayingStream => _audioService.isPlayingStream;
  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<String?> get currentTrackStream => _audioService.currentTrackStream;

  /// Initialize the audio manager
  Future<void> initialize() async {
    await _audioService.initialize();
  }

  /// Add a track to the playlist
  void addTrack(AudioTrack track) {
    _playlist.add(track);
  }

  /// Add multiple tracks to the playlist
  void addTracks(List<AudioTrack> tracks) {
    _playlist.addAll(tracks);
  }

  /// Clear the playlist
  void clearPlaylist() {
    _playlist.clear();
    _currentIndex = -1;
  }

  /// Play track by index
  Future<void> playTrackAt(int index) async {
    if (index < 0 || index >= _playlist.length) {
      throw ArgumentError('Index out of range');
    }

    _currentIndex = index;
    final track = _playlist[index];

    if (track.isUrl) {
      await _audioService.playFromUrl(track.source, title: track.title);
    } else {
      await _audioService.playFromAsset(track.source, title: track.title);
    }
  }

  /// Play the current track
  Future<void> play() async {
    if (_currentIndex >= 0) {
      await _audioService.play();
    }
  }

  /// Pause playback
  Future<void> pause() async {
    await _audioService.pause();
  }

  /// Stop playback
  Future<void> stop() async {
    await _audioService.stop();
  }

  /// Play next track
  Future<void> playNext() async {
    if (_currentIndex < _playlist.length - 1) {
      await playTrackAt(_currentIndex + 1);
    }
  }

  /// Play previous track
  Future<void> playPrevious() async {
    if (_currentIndex > 0) {
      await playTrackAt(_currentIndex - 1);
    }
  }

  /// Seek to position
  Future<void> seekTo(Duration position) async {
    await _audioService.seekTo(position);
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
  }

  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    await _audioService.setSpeed(speed);
  }

  /// Set loop mode
  Future<void> setLoopMode(LoopMode loopMode) async {
    await _audioService.setLoopMode(loopMode);
  }

  /// Shuffle playlist
  void shufflePlaylist() {
    if (_playlist.length > 1) {
      final currentTrack = _currentIndex >= 0 ? _playlist[_currentIndex] : null;
      _playlist.shuffle();

      if (currentTrack != null) {
        _currentIndex = _playlist.indexOf(currentTrack);
      }
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _audioService.dispose();
    _playlist.clear();
    _currentIndex = -1;
  }
}

/// Represents an audio track
class AudioTrack {
  final String title;
  final String source; // URL or asset path
  final String? artist;
  final String? album;
  final String? artworkUrl;
  final Duration? duration;
  final bool isUrl;

  const AudioTrack({
    required this.title,
    required this.source,
    this.artist,
    this.album,
    this.artworkUrl,
    this.duration,
    this.isUrl = true,
  });

  /// Create track from URL
  factory AudioTrack.fromUrl({
    required String title,
    required String url,
    String? artist,
    String? album,
    String? artworkUrl,
    Duration? duration,
  }) {
    return AudioTrack(
      title: title,
      source: url,
      artist: artist,
      album: album,
      artworkUrl: artworkUrl,
      duration: duration,
      isUrl: true,
    );
  }

  /// Create track from asset
  factory AudioTrack.fromAsset({
    required String title,
    required String assetPath,
    String? artist,
    String? album,
    String? artworkUrl,
    Duration? duration,
  }) {
    return AudioTrack(
      title: title,
      source: assetPath,
      artist: artist,
      album: album,
      artworkUrl: artworkUrl,
      duration: duration,
      isUrl: false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioTrack &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          source == other.source &&
          isUrl == other.isUrl;

  @override
  int get hashCode => title.hashCode ^ source.hashCode ^ isUrl.hashCode;

  @override
  String toString() {
    return 'AudioTrack(title: $title, source: $source, artist: $artist, isUrl: $isUrl)';
  }
}
