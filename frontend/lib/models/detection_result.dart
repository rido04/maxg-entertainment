// lib/models/detection_result.dart

class DetectionResult {
  final bool hasFace;
  final String gender; // 'male', 'female', 'unknown'
  final String ageGroup; // 'child', 'teen', 'adult', 'senior'
  final double confidence;
  final DateTime timestamp;

  DetectionResult({
    required this.hasFace,
    required this.gender,
    required this.ageGroup,
    required this.confidence,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory DetectionResult.noFace() {
    return DetectionResult(
      hasFace: false,
      gender: 'unknown',
      ageGroup: 'unknown',
      confidence: 0.0,
    );
  }

  factory DetectionResult.detected({
    required String gender,
    required String ageGroup,
    required double confidence,
  }) {
    return DetectionResult(
      hasFace: true,
      gender: gender,
      ageGroup: ageGroup,
      confidence: confidence,
    );
  }

  @override
  String toString() {
    return 'DetectionResult(hasFace: $hasFace, gender: $gender, age: $ageGroup, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

// Age estimation helper
class AgeEstimator {
  static String estimateAgeGroup(int estimatedAge) {
    if (estimatedAge < 13) return 'child';
    if (estimatedAge < 20) return 'teen';
    if (estimatedAge < 60) return 'adult';
    return 'senior';
  }
  
  static int getAverageAge(String ageGroup) {
    switch (ageGroup) {
      case 'child': return 8;
      case 'teen': return 16;
      case 'adult': return 35;
      case 'senior': return 65;
      default: return 30;
    }
  }
}