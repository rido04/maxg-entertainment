import 'dart:convert';

class MediaItem {
  final int id;
  final String title;
  final String fileUrl;
  final String? type;
  final String? category;
  final int? duration;
  final String? artist;
  final String? album;
  final String? thumbnail;
  final String? cast;
  final List<CastMember>? castList;
  final String? director;
  final String? writers;

  MediaItem({
    required this.id,
    required this.title,
    required this.fileUrl,
    this.type,
    this.category,
    this.duration,
    this.artist,
    this.album,
    this.thumbnail,
    this.cast,
    this.castList,
    this.director,
    this.writers,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    List<CastMember>? parsedCast;

    // Parse cast_json if available
    if (json['cast_json'] != null && json['cast_json'].toString().isNotEmpty) {
      try {
        final castJsonString = json['cast_json'].toString();
        final castJsonList = jsonDecode(castJsonString) as List;
        parsedCast = castJsonList
            .map((castItem) => CastMember.fromJson(castItem))
            .toList();
      } catch (e) {
        print('Error parsing cast_json: $e');
      }
    }

    return MediaItem(
      id: json['id'],
      title: json['title'],
      fileUrl: json['file_path'],
      type: json['type'],
      category: json['category'],
      duration: json['duration'],
      artist: json['artist'],
      album: json['album'],
      thumbnail: json['thumbnail'],
      cast: json['cast'],
      castList: parsedCast,
      director: json['director'],
      writers: json['writers'],
    );
  }

  // Method untuk mengkonversi MediaItem ke JSON
  Map<String, dynamic> toJson() {
    String? castJsonString;
    if (castList != null && castList!.isNotEmpty) {
      castJsonString = jsonEncode(castList!.map((c) => c.toJson()).toList());
    }

    return {
      'id': id,
      'title': title,
      'file_path': fileUrl,
      'type': type,
      'category': category,
      'duration': duration,
      'artist': artist,
      'album': album,
      'thumbnail': thumbnail,
      'cast': cast,
      'cast_json': castJsonString,
      'director': director,
      'writers': writers,
    };
  }

  // Getter untuk nama file lokal
  String get localFileName {
    final ext = downloadUrl.split('.').last;
    return '$id.$ext';
  }

  // Getter untuk download URL
  String get downloadUrl => 'http://192.168.1.18:8000/$fileUrl';

  // Getter untuk ekstensi file
  String get fileExtension {
    return fileUrl.split('.').last.toLowerCase();
  }

  // Getter untuk mengecek apakah ini video
  bool get isVideo {
    const videoExtensions = [
      'mp4',
      'avi',
      'mov',
      'mkv',
      'wmv',
      'flv',
      'webm',
      'm4v',
      '3gp',
    ];
    return videoExtensions.contains(fileExtension);
  }

  // Getter untuk mengecek apakah ini audio
  bool get isAudio {
    const audioExtensions = ['mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a', 'wma'];
    return audioExtensions.contains(fileExtension);
  }

  // Method untuk format durasi
  String get formattedDuration {
    if (duration == null) return 'Unknown duration';
    return _formatDuration(Duration(minutes: duration!));
  }

  // Get main cast (first 5)
  List<CastMember> get mainCast {
    if (castList == null) return [];
    return castList!.take(5).toList();
  }

  // Override equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Override toString untuk debugging
  @override
  String toString() {
    return 'MediaItem(id: $id, title: $title, fileUrl: $fileUrl)';
  }

  // Helper method untuk format durasi
  static String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

// Model untuk Cast Member
class CastMember {
  final bool adult;
  final int gender;
  final int id;
  final String knownForDepartment;
  final String name;
  final String originalName;
  final double popularity;
  final String? profilePath;
  final int castId;
  final String character;
  final String creditId;
  final int order;

  CastMember({
    required this.adult,
    required this.gender,
    required this.id,
    required this.knownForDepartment,
    required this.name,
    required this.originalName,
    required this.popularity,
    this.profilePath,
    required this.castId,
    required this.character,
    required this.creditId,
    required this.order,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      adult: json['adult'] ?? false,
      gender: json['gender'] ?? 0,
      id: json['id'],
      knownForDepartment: json['known_for_department'] ?? '',
      name: json['name'] ?? '',
      originalName: json['original_name'] ?? '',
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      profilePath: json['profile_path'],
      castId: json['cast_id'] ?? 0,
      character: json['character'] ?? '',
      creditId: json['credit_id'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adult': adult,
      'gender': gender,
      'id': id,
      'known_for_department': knownForDepartment,
      'name': name,
      'original_name': originalName,
      'popularity': popularity,
      'profile_path': profilePath,
      'cast_id': castId,
      'character': character,
      'credit_id': creditId,
      'order': order,
    };
  }

  // Get full profile image URL
  String? get fullProfilePath {
    if (profilePath == null || profilePath!.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/w185$profilePath';
  }

  @override
  String toString() {
    return 'CastMember(name: $name, character: $character)';
  }
}
