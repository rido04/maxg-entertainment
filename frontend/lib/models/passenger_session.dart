// lib/models/passenger_session.dart

import 'package:uuid/uuid.dart';

class PassengerSession {
  final String sessionId;
  final DateTime startTime;
  DateTime? endTime;
  final String gender; // 'male', 'female', 'unknown'
  final String? ageGroup; // 'child', 'teen', 'adult', 'senior'
  int adViewCount;
  List<int> viewedAdIds;
  Map<String, dynamic>? metadata;

  PassengerSession({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    required this.gender,
    this.ageGroup,
    this.adViewCount = 0,
    List<int>? viewedAdIds,
    this.metadata,
  }) : viewedAdIds = viewedAdIds ?? [];

  // Factory constructor untuk membuat session baru
  factory PassengerSession.create({required String gender, String? ageGroup}) {
    return PassengerSession(
      sessionId: const Uuid().v4(),
      startTime: DateTime.now(),
      gender: gender,
      ageGroup: ageGroup,
    );
  }

  // Duration getter
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  int get durationSeconds => duration.inSeconds;

  // Track viewed ad
  void trackAdView(int adId) {
    if (!viewedAdIds.contains(adId)) {
      viewedAdIds.add(adId);
      adViewCount++;
    }
  }

  // End session
  void end() {
    endTime = DateTime.now();
  }

  // To JSON for API
  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'device_id': 'TABLET_001', // TODO: Get from device info
      'driver_id': null, // TODO: Get from app state if available
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time':
          endTime?.toUtc().toIso8601String() ??
          DateTime.now().toUtc().toIso8601String(),
      'duration_seconds': durationSeconds,
      'gender': gender,
      'age_group': ageGroup,
      'ad_view_count': adViewCount,
      'viewed_ads': viewedAdIds,
      'metadata': metadata ?? {'app_version': '1.0.0'},
    };
  }

  @override
  String toString() {
    return 'PassengerSession(id: $sessionId, gender: $gender, duration: ${durationSeconds}s)';
  }
}
