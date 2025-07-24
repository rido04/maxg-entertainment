// lib/models/media_item.dart

class MediaItem {
  final int id;
  final String title;
  final String fileUrl;
  final String? type;
  final int? duration;
  final String? artist;
  final String? album;
  final String? thumbnail;

  MediaItem({
    required this.id,
    required this.title,
    required this.fileUrl,
    this.type,
    this.duration,
    this.artist,
    this.album,
    this.thumbnail,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'],
      title: json['title'],
      fileUrl: json['file_path'],
      type: json['type'],
      duration: json['duration'],
      artist: json['artist'],
      album: json['album'],
      thumbnail: json['thumbnail'],
    );
  }

  String get localFileName {
    final ext = downloadUrl.split('.').last;
    return '$id.$ext';
  }

  String get downloadUrl => 'http://192.168.1.9:8000/$fileUrl';
}
