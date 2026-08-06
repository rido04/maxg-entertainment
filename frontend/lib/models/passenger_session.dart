// lib/models/passenger_session.dart

import 'package:uuid/uuid.dart';
import 'ad_view_record.dart';

class PassengerSession {
  final String sessionId;
  final String gender;
  final String ageGroup;
  final DateTime startTime;
  DateTime? endTime;

  int adViewCount = 0; // Legacy counter (bisa dihapus nanti)
  List<AdViewRecord> viewedAds = []; // 👈 BARU - Detailed ad tracking

  Map<String, dynamic> metadata = {};

  PassengerSession({
    required this.sessionId,
    required this.gender,
    required this.ageGroup,
    required this.startTime,
    this.endTime,
    this.metadata = const {},
  });

  // Factory constructor
  factory PassengerSession.create({
    required String gender,
    required String ageGroup,
  }) {
    return PassengerSession(
      sessionId: const Uuid().v4(),
      gender: gender,
      ageGroup: ageGroup,
      startTime: DateTime.now(),
    );
  }

  // Track ad view dengan detail
  void trackAdView(int adId, String adTitle) {
    viewedAds.add(
      AdViewRecord(adId: adId, adTitle: adTitle, viewedAt: DateTime.now()),
    );

    adViewCount++; // Keep legacy counter for backward compatibility

    print('📊 Ad tracked: $adTitle (Total: ${viewedAds.length})');
  }

  // End session
  void end() {
    endTime = DateTime.now();
    print('🏁 Session ended: $sessionId');
  }

  // Get duration in seconds
  int get durationSeconds {
    if (endTime == null) {
      return DateTime.now().difference(startTime).inSeconds;
    }
    return endTime!.difference(startTime).inSeconds;
  }

  // Check if session is active
  bool get isActive => endTime == null;

  // To JSON (untuk dikirim ke backend)
  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'gender': gender,
      'age_group': ageGroup,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'ad_view_count': adViewCount,
      'viewed_ads': viewedAds.map((ad) => ad.toJson()).toList(), // 👈 BARU
      'metadata': metadata,
    };
  }

  // From JSON (untuk restore dari queue)
  factory PassengerSession.fromJson(Map<String, dynamic> json) {
  final session = PassengerSession(
    sessionId: json['session_id'] as String,
    gender: json['gender'] as String,
    ageGroup: json['age_group'] as String,
    startTime: DateTime.parse(json['start_time'] as String),
    endTime: json['end_time'] != null
        ? DateTime.parse(json['end_time'] as String)
        : null,
    metadata: json['metadata'] != null 
        ? Map<String, dynamic>.from(json['metadata'] as Map)
        : {},
  );

  session.adViewCount = json['ad_view_count'] as int? ?? 0;

  // 👇 FIX: Handle Map<dynamic, dynamic> dari Hive
  if (json['viewed_ads'] != null) {
    session.viewedAds = (json['viewed_ads'] as List)
        .map((ad) {
          // Convert Map<dynamic, dynamic> → Map<String, dynamic>
          final adMap = ad is Map<String, dynamic> 
              ? ad 
              : Map<String, dynamic>.from(ad as Map);
          return AdViewRecord.fromJson(adMap);
        })
        .toList();
  }

  return session;
}

  @override
  String toString() {
    return 'PassengerSession(id: $sessionId, gender: $gender, age: $ageGroup, '
        'duration: ${durationSeconds}s, ads: ${viewedAds.length})';
  }
}
