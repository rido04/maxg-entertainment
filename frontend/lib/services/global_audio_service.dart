// lib/services/global_audio_service.dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/media_item.dart';
import 'music_service.dart';

class GlobalAudioService extends ChangeNotifier {
  static final GlobalAudioService _instance = GlobalAudioService._internal();
  factory GlobalAudioService() => _instance;
  GlobalAudioService._internal();

  late AudioPlayer _player;
  final MusicService _musicService = MusicService();

  MediaItem? _currentMusic;
  bool _isInitialized = false;
  bool _isOfflineMode = false;
  bool _isLoading = false;

  // Getters
  AudioPlayer get player => _player;
  MediaItem? get currentMusic => _currentMusic;
  bool get isInitialized => _isInitialized;
  bool get isOfflineMode => _isOfflineMode;
  bool get isLoading => _isLoading;
  bool get hasCurrentMusic => _currentMusic != null;

  // Streams
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Duration? get duration => _player.duration;
  Duration get position => _player.position;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _player = AudioPlayer();
    _isInitialized = true;

    // Listen to player state changes
    _player.playerStateStream.listen((state) {
      notifyListeners();
    });

    _player.positionStream.listen((position) {
      notifyListeners();
    });

    _player.durationStream.listen((duration) {
      notifyListeners();
    });
  }

  Future<void> playMusic(MediaItem music) async {
    if (!_isInitialized) await initialize();

    _currentMusic = music;
    _isLoading = true;
    notifyListeners();

    try {
      // First, try to get local file path
      final localPath = await _musicService.getLocalMusicPath(music);

      if (localPath != null) {
        // Play from local file (offline)
        await _player.setFilePath(localPath);
        _isOfflineMode = true;
      } else {
        // Check internet connection
        final hasInternet = await _musicService.hasInternetConnection();

        if (hasInternet) {
          // Play from URL (online)
          await _player.setUrl(music.downloadUrl);
          _isOfflineMode = false;
        } else {
          throw Exception('No internet connection and music not downloaded');
        }
      }

      _isLoading = false;
      await _player.play();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    _currentMusic = null;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void dispose() {
    _player.dispose();
    _isInitialized = false;
    super.dispose();
  }

  String formatDuration(Duration? duration) {
    if (duration == null) return '0:00';

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '$minutes:${twoDigits(seconds)}';
    }
  }
}
