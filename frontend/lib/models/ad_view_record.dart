// lib/models/ad_view_record.dart

class AdViewRecord {
  final int adId;
  final String adTitle;
  final DateTime viewedAt;
  final int?
  durationSeconds; // Optional: berapa lama ditonton (untuk future enhancement)

  AdViewRecord({
    required this.adId,
    required this.adTitle,
    required this.viewedAt,
    this.durationSeconds,
  });

  // From JSON
  factory AdViewRecord.fromJson(Map<String, dynamic> json) {
    return AdViewRecord(
      adId: json['ad_id'] as int,
      adTitle: json['ad_title'] as String,
      viewedAt: DateTime.parse(json['viewed_at'] as String),
      durationSeconds: json['duration_seconds'] as int?,
    );
  }

  // To JSON (untuk dikirim ke backend)
  Map<String, dynamic> toJson() {
    return {
      'ad_id': adId,
      'ad_title': adTitle,
      'viewed_at': viewedAt.toIso8601String(),
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
    };
  }

  @override
  String toString() {
    return 'AdViewRecord(id: $adId, title: $adTitle, at: $viewedAt)';
  }
}
