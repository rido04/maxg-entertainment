// lib/models/media_item.dart

class MediaItem {
  final int id;
  final String title;
  final String fileUrl;

  MediaItem({required this.id, required this.title, required this.fileUrl});

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'],
      title: json['title'],
      fileUrl: json['file_path'],
    );
  }

  String get downloadUrl => 'http://192.168.1.9:8000/$fileUrl';
}
