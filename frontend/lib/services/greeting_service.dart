// lib/services/greeting_service.dart

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../widgets/greeting_overlay_widget.dart';

class GreetingService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isInitialized = false;

  // Audio file paths
  static final Map<String, List<String>> _audioFiles = {
    'male': [
      'audio/greetings/male_greeting_1.mp3',
      'audio/greetings/male_greeting_2.mp3',
    ],
    'female': [
      'audio/greetings/female_greeting_1.mp3',
      'audio/greetings/female_greeting_2.mp3',
    ],
    'unknown': [
      'audio/greetings/neutral_greeting_1.mp3',
      'audio/greetings/neutral_greeting_2.mp3',
    ],
  };

  // Greeting messages (for visual display)
  static final Map<String, List<String>> _greetings = {
    'male': [
      'Selamat datang, Pak!',
      'Halo Bapak!\nSelamat datang di GrabCar',
      'Selamat siang!\nNikmati perjalanan Anda',
    ],
    'female': [
      'Selamat datang, Bu!',
      'Halo Ibu!\nSelamat datang di GrabCar',
      'Selamat siang!\nNikmati perjalanan Anda',
    ],
    'unknown': [
      'Selamat datang!',
      'Halo!\nSelamat datang di GrabCar',
      'Nikmati perjalanan Anda',
    ],
  };

  // Initialize
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);

      // 👇 TAMBAH INI - Request audio focus dengan priority tinggi
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

      _isInitialized = true;
      print('🎙️ Audio Player initialized with media player mode');
    } catch (e) {
      print('❌ Audio initialization failed: $e');
    }
  }

  static Future<void> playGreeting({
    required String gender,
    String? ageGroup,
    BuildContext? context,
    VoidCallback? onComplete,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final random = Random().nextInt(
      _greetings[gender]?.length ?? _greetings['unknown']!.length,
    );

    final greetingList = _greetings[gender] ?? _greetings['unknown']!;
    final greeting = greetingList[random];

    final audioList = _audioFiles[gender] ?? _audioFiles['unknown']!;
    final audioFile = audioList[random.clamp(0, audioList.length - 1)];

    print('💬 Greeting: "$greeting"');
    print('🎵 Audio: $audioFile');

    if (context != null) {
      GreetingOverlay.show(context, message: greeting, gender: gender);
    }

    try {
      // 👇 Stop dulu kalau ada yang playing
      await _audioPlayer.stop();

      // 👇 Set volume max
      await _audioPlayer.setVolume(1.0);

      print('🎵 Playing greeting audio...');
      await _audioPlayer.play(AssetSource(audioFile));

      _audioPlayer.onPlayerComplete.first.then((_) {
        print('✅ Greeting audio completed');
        onComplete?.call();
      });
    } catch (e) {
      print('❌ Audio play failed: $e');
      onComplete?.call();
    }
  }

  // Stop current greeting
  static Future<void> stop() async {
    await _audioPlayer.stop();
  }

  // Dispose
  static Future<void> dispose() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    _isInitialized = false;
  }
}
