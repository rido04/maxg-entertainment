// lib/services/session_manager_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/passenger_session.dart';
import '../models/detection_result.dart';
import '../models/advertisement_item.dart';
import 'face_detection_service.dart';
import 'session_log_service.dart';
import 'greeting_service.dart';
import 'advertisement_service.dart';

enum SessionState { idle, detected, active, cooldown }

class SessionManagerService {
  // Singleton pattern
  static final SessionManagerService _instance =
      SessionManagerService._internal();
  factory SessionManagerService() => _instance;
  SessionManagerService._internal();

  // State
  SessionState _state = SessionState.idle;
  PassengerSession? _currentSession;
  Timer? _cooldownTimer;
  Timer? _detectionTimer;
  List<AdvertisementItem> _currentAds = [];
  BuildContext? _context;
  int _consecutiveDetections = 0;
  String? _lastDetectedGender;
  final List<String> _recentDetections = [];
  final int _historySize = 5;
  bool _isMonitoringPaused = false; // 👈 BARU - untuk pause/resume

  VoidCallback? _onPauseVideo;
  VoidCallback? _onResumeVideo;

  // Configuration
  final Duration sessionTimeout = const Duration(minutes: 3);
  final Duration detectionInterval = const Duration(seconds: 3);
  final Duration postSessionCooldown = const Duration(seconds: 30); // 👈 TAMBAH
  final double confidenceThreshold = 0.65;

  // Callbacks
  Function(SessionState)? onStateChanged;
  Function(PassengerSession)? onSessionStarted;
  Function(PassengerSession)? onSessionEnded;
  Function(List<AdvertisementItem>)? onAdsUpdated;

  // Getters
  SessionState get state => _state;
  PassengerSession? get currentSession => _currentSession;
  List<AdvertisementItem> get currentAds => _currentAds;
  bool get isActive =>
      _state == SessionState.active || _state == SessionState.cooldown;
  bool get isMonitoring => _detectionTimer != null && _detectionTimer!.isActive;
  bool get isMonitoringPaused => _isMonitoringPaused;

  void setContext(BuildContext context) {
    _context = context;
    print('📍 Context registered for SessionManager');
  }

  void setVideoControls({
    VoidCallback? onPauseVideo,
    VoidCallback? onResumeVideo,
  }) {
    _onPauseVideo = onPauseVideo;
    _onResumeVideo = onResumeVideo;
    print('🎛️ Video controls registered');
  }

  Future<void> initialize() async {
    print('🚀 Initializing Session Manager...');
    await FaceDetectionService.initialize();
    print('✅ Session Manager initialized');
  }

  /// Start monitoring (called when entering screensaver)
  void startMonitoring() {
    if (_detectionTimer != null && _detectionTimer!.isActive) {
      print('⚠️ Monitoring already active');
      return;
    }

    _isMonitoringPaused = false;
    print('👁️ Starting face detection monitoring...');

    _detectionTimer = Timer.periodic(detectionInterval, (_) async {
      if (!_isMonitoringPaused) {
        await _checkForFace();
      }
    });
  }

  /// Pause monitoring (called when exiting screensaver, but keep session alive)
  void pauseMonitoring() {
    if (_detectionTimer == null || !_detectionTimer!.isActive) {
      print('⚠️ Monitoring not active, nothing to pause');
      return;
    }

    _isMonitoringPaused = true;
    print(
      '⏸️ Monitoring paused (session still active: ${_currentSession?.sessionId})',
    );

    // IMPORTANT: Don't cancel the timer, just pause it
    // Session continues running in background
  }

  /// Resume monitoring (called when re-entering screensaver)
  void resumeMonitoring() {
    if (_detectionTimer == null || !_detectionTimer!.isActive) {
      print('⚠️ Monitoring not active, restarting...');
      startMonitoring();
      return;
    }

    _isMonitoringPaused = false;
    print('▶️ Monitoring resumed (session: ${_currentSession?.sessionId})');
  }

  /// Stop monitoring completely (only when disposing)
  void stopMonitoring() {
    _detectionTimer?.cancel();
    _detectionTimer = null;
    _isMonitoringPaused = false;
    print('🛑 Monitoring stopped');
  }

  Future<void> _checkForFace() async {
    try {
      final result = await FaceDetectionService.detectAndClassify();

      switch (_state) {
        case SessionState.idle:
          if (result.hasFace && result.confidence >= confidenceThreshold) {
            _recentDetections.add(result.gender);
            if (_recentDetections.length > _historySize) {
              _recentDetections.removeAt(0);
            }

            final majorityGender = _getMajorityGender();

            if (_lastDetectedGender == majorityGender) {
              _consecutiveDetections++;

              if (_consecutiveDetections >= 2) {
                final stableResult = DetectionResult.detected(
                  gender: majorityGender,
                  ageGroup: result.ageGroup,
                  confidence: result.confidence,
                );

                await _startNewSession(stableResult);
                _consecutiveDetections = 0;
                _lastDetectedGender = null;
                _recentDetections.clear();
              }
            } else {
              _lastDetectedGender = majorityGender;
              _consecutiveDetections = 1;
            }
          } else {
            _consecutiveDetections = 0;
            _lastDetectedGender = null;
          }
          break;

        case SessionState.active:
          if (result.hasFace) {
            _resetCooldown();
          } else {
            _startCooldown();
          }
          break;

        case SessionState.cooldown:
          // Check if this is POST-SESSION cooldown or IN-SESSION cooldown
          if (_currentSession == null) {
            // POST-SESSION cooldown - ignore all face detection
            print('⏳ Post-session cooldown active, ignoring face detection');
            return;
          }

          // IN-SESSION cooldown - allow face to resume session
          if (result.hasFace) {
            _cancelCooldown();
            _changeState(SessionState.active);
          }
          break;

        case SessionState.detected:
          break;
      }
    } catch (e) {
      print('❌ Detection check failed: $e');
    }
  }

  Future<void> _startNewSession(DetectionResult detection) async {
    print('🎉 New passenger detected!');
    _changeState(SessionState.detected);

    _currentSession = PassengerSession.create(
      gender: detection.gender,
      ageGroup: detection.ageGroup,
    );

    _currentSession!.metadata = {
      'detection_confidence': detection.confidence,
      'app_version': '1.0.0',
    };

    print('📝 Session created: ${_currentSession!.sessionId}');

    _onPauseVideo?.call();

    await _playGreetingAndWait(detection);

    await _fetchTargetedAds(detection.gender, detection.ageGroup);

    _changeState(SessionState.active);
    onSessionStarted?.call(_currentSession!);

    _onResumeVideo?.call();

    print('✅ Session started successfully');
  }

  Future<void> _playGreetingAndWait(DetectionResult detection) async {
    final completer = Completer<void>();

    if (_context != null) {
      GreetingService.playGreeting(
        gender: detection.gender,
        ageGroup: detection.ageGroup,
        context: _context,
        onComplete: () {
          print('🎵 Greeting finished');
          completer.complete();
        },
      );
    } else {
      print('⚠️ Context not available, greeting visual skipped');
      GreetingService.playGreeting(
        gender: detection.gender,
        ageGroup: detection.ageGroup,
        onComplete: () {
          completer.complete();
        },
      );
    }

    await completer.future;
  }

  String _getMajorityGender() {
    if (_recentDetections.isEmpty) return 'unknown';

    final maleCount = _recentDetections.where((g) => g == 'male').length;
    final femaleCount = _recentDetections.where((g) => g == 'female').length;

    final majority = maleCount > femaleCount ? 'male' : 'female';
    final confidence =
        (maleCount > femaleCount ? maleCount : femaleCount) /
        _recentDetections.length;

    print(
      '📊 Gender history: Male=$maleCount, Female=$femaleCount → $majority (${(confidence * 100).toStringAsFixed(0)}%)',
    );

    return majority;
  }

  Future<void> _fetchTargetedAds(String gender, String ageGroup) async {
    try {
      print('🎯 Fetching targeted ads for $gender, $ageGroup...');

      final ads = await AdvertisementService.fetchAdvertisements(
        gender: gender,
        ageGroup: ageGroup,
      );

      _currentAds = ads;
      onAdsUpdated?.call(_currentAds);

      print('📺 Loaded ${_currentAds.length} targeted ads');
    } catch (e) {
      print('❌ Failed to fetch ads: $e');
      _currentAds = [];
    }
  }

  /// Track ad view (panggil dengan ID DAN TITLE)
  void trackAdView(int adId, String adTitle) {
    if (_currentSession != null && _state == SessionState.active) {
      _currentSession!.trackAdView(adId, adTitle);
      print(
        '👁️ Ad viewed: $adTitle (Total: ${_currentSession!.viewedAds.length})',
      );
    } else {
      print('⚠️ Cannot track ad view: Session not active (state: $_state)');
    }
  }

  void _startCooldown() {
    if (_state == SessionState.cooldown) return;

    print(
      '⏳ No face detected, starting ${sessionTimeout.inMinutes}min cooldown...',
    );
    _changeState(SessionState.cooldown);

    _cooldownTimer = Timer(sessionTimeout, () {
      _endSession();
    });
  }

  void _resetCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
  }

  void _cancelCooldown() {
    print('👤 Face detected again, session continues');
    _resetCooldown();
  }

  Future<void> _endSession() async {
    if (_currentSession == null) return;

    print('📊 Ending session: ${_currentSession!.sessionId}');
    print('   - Duration: ${_currentSession!.durationSeconds}s');
    print('   - Ads viewed: ${_currentSession!.viewedAds.length}');

    _currentSession!.end();

    final success = await SessionLogService.sendLog(_currentSession!);

    if (success) {
      print('✅ Session logged successfully');
    } else {
      print('⚠️ Session queued (will retry when online)');
    }

    onSessionEnded?.call(_currentSession!);

    _currentSession = null;
    _currentAds = [];

    // 👇 UBAH: Stay in cooldown state (post-session cooldown)
    _changeState(SessionState.cooldown);

    // 👇 TAMBAH: Start post-session cooldown timer
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(postSessionCooldown, () {
      _changeState(SessionState.idle);
      print('🔄 Back to idle state (post-session cooldown finished)');
    });

    print(
      '⏳ Post-session cooldown started (${postSessionCooldown.inSeconds}s)',
    );
  }

  void _changeState(SessionState newState) {
    if (_state == newState) return;

    print('🔄 State: $_state → $newState');
    _state = newState;
    onStateChanged?.call(_state);
  }

  Future<void> forceEndSession() async {
    _resetCooldown();
    await _endSession();
  }

  void dispose() {
    stopMonitoring();
    _resetCooldown();
    _currentSession = null;
    _currentAds = [];
    print('🔴 Session Manager disposed');
  }
}
