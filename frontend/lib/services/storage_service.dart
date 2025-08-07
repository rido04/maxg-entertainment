import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import '../models/media_item.dart';

class StorageService {
  static const String _cacheFileName = 'media_cache.json';

  // Tambah di StorageService class
  static Future<String> getThumbnailFilePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final thumbnailDir = Directory('${directory.path}/thumbnails');
    if (!await thumbnailDir.exists()) {
      await thumbnailDir.create(recursive: true);
    }
    return '${thumbnailDir.path}/$filename';
  }

  static Future<bool> isThumbnailDownloaded(int mediaId) async {
    final extensions = ['jpg', 'png', 'webp', 'gif'];
    for (final ext in extensions) {
      final path = await getThumbnailFilePath('${mediaId}_thumb.$ext');
      if (File(path).existsSync()) return true;
    }
    return false;
  }

  static Future<String?> getLocalThumbnailPath(int mediaId) async {
    final extensions = ['jpg', 'png', 'webp', 'gif'];
    for (final ext in extensions) {
      final path = await getThumbnailFilePath('${mediaId}_thumb.$ext');
      if (File(path).existsSync()) return path;
    }
    return null;
  }

  static Future<void> downloadThumbnail(String url, int mediaId) async {
    if (url.isEmpty) return;

    try {
      final dio = Dio();
      final extension = _getImageExtension(url);
      final savePath = await getThumbnailFilePath(
        '${mediaId}_thumb.$extension',
      );

      await dio.download(url, savePath);
      print('Thumbnail downloaded: $savePath');
    } catch (e) {
      print('Failed to download thumbnail: $e');
    }
  }

  static String _getImageExtension(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();

    if (path.contains('.png')) return 'png';
    if (path.contains('.webp')) return 'webp';
    if (path.contains('.gif')) return 'gif';
    return 'jpg'; // default
  }

  /// Ambil path lokal untuk menyimpan file
  static Future<String> getLocalFilePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }

  /// Ambil path untuk cache metadata
  static Future<String> getCacheFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_cacheFileName';
  }

  /// Cek apakah file sudah diunduh
  static Future<bool> isMediaDownloaded(String filename) async {
    final path = await getLocalFilePath(filename);
    return File(path).existsSync();
  }

  /// Simpan metadata media list ke cache lokal
  // Replace method cacheMediaList yang existing
  static Future<void> cacheMediaList(List<MediaItem> mediaList) async {
    try {
      // Download thumbnails dan update paths
      final List<Map<String, dynamic>> updatedJsonData = [];

      for (final item in mediaList) {
        // Download thumbnail jika belum ada
        if (item.thumbnail != null && item.thumbnail!.isNotEmpty) {
          final isDownloaded = await isThumbnailDownloaded(item.id);
          if (!isDownloaded) {
            await downloadThumbnail(item.thumbnail!, item.id);
          }
        }

        // Get local thumbnail path
        final localThumbnailPath = await getLocalThumbnailPath(item.id);

        // Create JSON dengan local thumbnail path jika ada
        final itemJson = item.toJson();
        if (localThumbnailPath != null) {
          itemJson['thumbnail'] = localThumbnailPath;
        }

        updatedJsonData.add(itemJson);
      }

      final cacheFile = File(await getCacheFilePath());
      await cacheFile.writeAsString(
        json.encode({
          'cached_at': DateTime.now().toIso8601String(),
          'data': updatedJsonData,
        }),
      );
      print('Media list cached with local thumbnail paths');
    } catch (e) {
      print('Failed to cache media list: $e');
    }
  }

  /// Ambil cached media list
  static Future<List<MediaItem>?> getCachedMediaList() async {
    try {
      final cacheFile = File(await getCacheFilePath());
      if (!cacheFile.existsSync()) {
        print('No cache file found');
        return null;
      }

      final content = await cacheFile.readAsString();
      final jsonData = json.decode(content);
      final List<dynamic> data = jsonData['data'];

      print('Loaded ${data.length} items from cache');
      return data.map((item) => MediaItem.fromJson(item)).toList();
    } catch (e) {
      print('Failed to load cached media list: $e');
      return null;
    }
  }

  /// Ambil hanya media yang sudah terdownload
  static Future<List<MediaItem>> getDownloadedMedia() async {
    try {
      final cachedList = await getCachedMediaList();
      if (cachedList == null) return [];

      final downloadedMedia = <MediaItem>[];

      for (var item in cachedList) {
        final filename =
            item.localFileName; // Menggunakan getter localFileName dari model
        final isDownloaded = await isMediaDownloaded(filename);

        if (isDownloaded) {
          downloadedMedia.add(item);
        }
      }

      print('Found ${downloadedMedia.length} downloaded media files');
      return downloadedMedia;
    } catch (e) {
      print('Failed to get downloaded media: $e');
      return [];
    }
  }

  /// Filter video files dari media list
  static List<MediaItem> filterVideoFiles(List<MediaItem> mediaList) {
    return mediaList.where((media) {
      final extension = media.fileUrl.split('.').last.toLowerCase();
      return [
        'mp4',
        'avi',
        'mov',
        'mkv',
        'wmv',
        'flv',
        'webm',
      ].contains(extension);
    }).toList();
  }

  /// Unduh file dari internet ke lokal storage
  static Future<void> downloadMedia(String url, String filename) async {
    final savePath = await getLocalFilePath(filename);
    final dio = Dio();

    try {
      await dio.download(url, savePath);
      print('Download complete: $savePath');
    } catch (e) {
      print('Download failed: $e');
      rethrow;
    }
  }

  /// Unduh semua media dalam daftar
  static Future<void> downloadAllMedia(List<MediaItem> mediaList) async {
    for (var item in mediaList) {
      final filename = item.localFileName; // Menggunakan getter localFileName
      final fileExists = await isMediaDownloaded(filename);

      if (!fileExists) {
        try {
          await downloadMedia(item.downloadUrl, filename);
        } catch (e) {
          print('Failed to download ${item.title}: $e');
          // Continue dengan file lainnya
        }
      }
    }
  }

  /// Hapus cache (untuk refresh)
  static Future<void> clearCache() async {
    try {
      final cacheFile = File(await getCacheFilePath());
      if (cacheFile.existsSync()) {
        await cacheFile.delete();
        print('Cache cleared');
      }
    } catch (e) {
      print('Failed to clear cache: $e');
    }
  }

  /// Cek ukuran file yang sudah didownload
  static Future<String> getDownloadedFileSize(String filename) async {
    try {
      final path = await getLocalFilePath(filename);
      final file = File(path);
      if (file.existsSync()) {
        final bytes = await file.length();
        return _formatBytes(bytes);
      }
      return '0 B';
    } catch (e) {
      return '0 B';
    }
  }

  /// Format bytes ke readable format
  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}
