// lib/models/advertisement_item.dart

class AdvertisementItem {
  final int id;
  final String title;
  final String? description;
  final String type;
  final String fileUrl;
  final String? thumbnailUrl;
  final int duration;
  final int priority;
  final List<String> targetGender;
  final List<String> targetAgeGroup;

  AdvertisementItem({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.duration,
    required this.priority,
    required this.targetGender,
    required this.targetAgeGroup,
  });

  factory AdvertisementItem.fromJson(Map<String, dynamic> json) {
    print('📦 Parsing advertisement JSON:');
    print('   ID: ${json['id']}');
    print('   Title: ${json['title']}');
    print('   Type: ${json['type']}');

    // ✅ FALLBACK: Coba file_url dulu, kalau ga ada pakai file_path
    String fileUrl = json['file_url'] as String? ?? '';

    if (fileUrl.isEmpty && json['file_path'] != null) {
      // Build URL dari file_path
      const baseUrl = 'https://maxg.gvisignagesystem.com';
      fileUrl = '$baseUrl/storage/${json['file_path']}';
      print('   ⚠️ file_url not found, building from file_path: $fileUrl');
    }

    print('   file_url: $fileUrl');

    if (fileUrl.isEmpty) {
      print('⚠️ WARNING: file_url is EMPTY for ad ${json['id']}');
    }

    return AdvertisementItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'image',
      fileUrl: fileUrl,
      thumbnailUrl: json['thumbnail_url'] as String?,
      duration: json['duration'] as int? ?? 15,
      priority: json['priority'] as int? ?? 0,
      targetGender:
          (json['target_gender'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['all'],
      targetAgeGroup:
          (json['target_age_group'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['all'],
    );
  }

  // 👇 TAMBAH: toJson untuk Hive caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'file_url': fileUrl,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'priority': priority,
      'target_gender': targetGender,
      'target_age_group': targetAgeGroup,
    };
  }

  bool matchesProfile({required String gender, String? ageGroup}) {
    final genderMatch =
        targetGender.contains('all') || targetGender.contains(gender);
    if (!genderMatch) return false;

    if (ageGroup != null) {
      final ageMatch =
          targetAgeGroup.contains('all') || targetAgeGroup.contains(ageGroup);
      return ageMatch;
    }

    return true;
  }

  String get localFileName {
    if (fileUrl.isEmpty) {
      print('⚠️ Cannot generate localFileName: fileUrl is empty');
      return 'ad_${id}_unknown.jpg';
    }

    final uri = Uri.tryParse(fileUrl);
    if (uri == null) {
      print('⚠️ Invalid URL: $fileUrl');
      return 'ad_${id}_invalid.jpg';
    }

    final extension = uri.pathSegments.last.split('.').last.toLowerCase();
    return 'ad_${id}.$extension';
  }

  bool get isVideo => type == 'video';
  bool get isImage => type == 'image';

  @override
  String toString() {
    return 'AdvertisementItem(id: $id, title: $title, type: $type, fileUrl: $fileUrl)';
  }
}
