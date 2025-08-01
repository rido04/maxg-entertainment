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

  // Method untuk mengkonversi MediaItem ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'file_path': fileUrl,
      'type': type,
      'duration': duration,
      'artist': artist,
      'album': album,
      'thumbnail': thumbnail,
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

  // Method untuk format durasi (jika diperlukan)
  String get formattedDuration {
    if (duration == null) return 'Unknown duration';
    return _formatDuration(Duration(seconds: duration!));
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
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}
