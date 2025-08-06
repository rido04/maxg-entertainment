// lib/services/activity_tracker_service.dart
import 'package:flutter/material.dart';
import 'dart:async';

class ActivityTrackerService {
  static ActivityTrackerService? _instance;
  static ActivityTrackerService get instance {
    _instance ??= ActivityTrackerService._internal();
    return _instance!;
  }

  ActivityTrackerService._internal();

  Timer? _inactivityTimer;
  static const Duration _inactivityDuration = Duration(minutes: 1);
  bool _isTracking = false;
  bool _isPaused = false;
  BuildContext? _context;

  // Whitelist screens yang tidak boleh di-interrupt
  static const Set<String> _whitelistedScreens = {
    'VideoPlayerScreen',
    // 'MusicPlayer', // Music player bisa di-interrupt, user bisa dengerin musik sambil screensaver
    // Tambahkan screen lain sesuai kebutuhan
  };

  String? _currentScreen;

  /// Initialize the activity tracker
  void initialize(BuildContext context) {
    _context = context;
    _isTracking = true;
    _isPaused = false;
    _startTimer();
    debugPrint('🔄 ActivityTracker: Initialized');
  }

  /// Start/Restart the inactivity timer
  void _startTimer() {
    if (!_isTracking || _isPaused) return;

    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityDuration, () {
      if (_context != null && _context!.mounted) {
        debugPrint(
          '⏰ ActivityTracker: Timeout reached, navigating to screensaver',
        );
        _navigateToScreensaver();
      }
    });

    debugPrint('⏱️ ActivityTracker: Timer started/reset');
  }

  /// Reset the timer when user activity is detected
  void onUserActivity() {
    if (!_isTracking) return;

    // Check if current screen is whitelisted
    if (_currentScreen != null &&
        _whitelistedScreens.contains(_currentScreen)) {
      debugPrint(
        '🚫 ActivityTracker: Activity ignored - screen $_currentScreen is whitelisted',
      );
      return;
    }

    debugPrint('👆 ActivityTracker: User activity detected on $_currentScreen');
    _startTimer();
  }

  /// Pause the timer (untuk screen tertentu yang tidak boleh di-interrupt)
  void pauseTracking({String? reason}) {
    _isPaused = true;
    _inactivityTimer?.cancel();
    debugPrint(
      '⏸️ ActivityTracker: Paused ${reason != null ? '- $reason' : ''}',
    );
  }

  /// Resume the timer
  void resumeTracking({String? reason}) {
    _isPaused = false;
    if (_isTracking) {
      _startTimer();
      debugPrint(
        '▶️ ActivityTracker: Resumed ${reason != null ? '- $reason' : ''}',
      );
    }
  }

  /// Set current screen name (untuk debugging dan whitelist checking)
  void setCurrentScreen(String screenName) {
    _currentScreen = screenName;
    debugPrint('📱 ActivityTracker: Current screen: $screenName');

    // Auto pause/resume berdasarkan whitelist
    if (_whitelistedScreens.contains(screenName)) {
      pauseTracking(reason: 'Whitelisted screen: $screenName');
    } else {
      resumeTracking(reason: 'Non-whitelisted screen: $screenName');
    }
  }

  /// Stop tracking completely
  void stopTracking() {
    _isTracking = false;
    _inactivityTimer?.cancel();
    debugPrint('🛑 ActivityTracker: Stopped');
  }

  /// Navigate to screensaver
  void _navigateToScreensaver() {
    if (_context != null && _context!.mounted) {
      try {
        Navigator.of(_context!).pushReplacementNamed('/screensaver');
        debugPrint('🎬 ActivityTracker: Navigated to screensaver');
      } catch (e) {
        debugPrint('❌ ActivityTracker: Navigation error - $e');
      }
    }
  }

  /// Force navigate to screensaver (untuk testing atau manual trigger)
  void forceScreensaver() {
    debugPrint('🔧 ActivityTracker: Force screensaver triggered');
    _navigateToScreensaver();
  }

  /// Get current status (untuk debugging)
  Map<String, dynamic> getStatus() {
    return {
      'isTracking': _isTracking,
      'isPaused': _isPaused,
      'currentScreen': _currentScreen,
      'timerActive': _inactivityTimer?.isActive ?? false,
      'whitelistedScreens': _whitelistedScreens.toList(),
    };
  }

  /// Cleanup
  void dispose() {
    _inactivityTimer?.cancel();
    _isTracking = false;
    _isPaused = false;
    _context = null;
    _currentScreen = null;
    debugPrint('🗑️ ActivityTracker: Disposed');
  }
}
