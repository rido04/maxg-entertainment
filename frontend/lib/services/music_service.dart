// lib/services/music_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_item.dart';

class MusicService {
  static const String _baseUrl = 'https://maxg.app.medialoger.com';
  static const String _downloadedMusicKey = 'downloaded_music';

  // Check internet connectivity
  Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Get local app documents directory
  Future<Directory> getDownloadDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final musicDir = Directory('${directory.path}/music');
    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
    }
    return musicDir;
  }

  // Get thumbnails directory
  Future<Directory> getThumbnailDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final thumbnailDir = Directory('${directory.path}/thumbnails');
    if (!await thumbnailDir.exists()) {
      await thumbnailDir.create(recursive: true);
    }
    return thumbnailDir;
  }

  // Fetch music list with offline support
  Future<List<MediaItem>> fetchMusic() async {
    final hasInternet = await hasInternetConnection();

    if (hasInternet) {
      try {
        // Fetch from API
        final response = await http.get(Uri.parse('$_baseUrl/api/media'));

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body)['data'];
          final musicItems = data
              .where((item) => item['type'] == 'audio')
              .map((json) => MediaItem.fromJson(json))
              .toList();

          // Update music items with local thumbnail paths
          final updatedMusicItems = await _updateWithLocalPaths(musicItems);

          // Save to local storage for offline access
          await _saveOfflineMusicList(updatedMusicItems);

          // Auto download music files and thumbnails
          _autoDownloadMusic(musicItems);

          return updatedMusicItems;
        } else {
          throw Exception('Failed to load music');
        }
      } catch (e) {
        // If online fetch fails, fallback to offline
        return await _getOfflineMusicList();
      }
    } else {
      // No internet, load from offline storage
      return await _getOfflineMusicList();
    }
  }

  // Update music items with local thumbnail paths if available
  Future<List<MediaItem>> _updateWithLocalPaths(
    List<MediaItem> musicItems,
  ) async {
    final List<MediaItem> updatedItems = [];

    for (final music in musicItems) {
      final localThumbnailPath = await getLocalThumbnailPath(music);

      // Create new MediaItem with local thumbnail path if available
      final updatedMusic = MediaItem(
        id: music.id,
        title: music.title,
        fileUrl: music.fileUrl,
        type: music.type,
        category: music.category,
        duration: music.duration,
        artist: music.artist,
        album: music.album,
        thumbnail:
            localThumbnailPath ??
            music.thumbnail, // Use local path if available
        cast: music.cast,
        castList: music.castList,
        director: music.director,
        writers: music.writers,
        description: music.description,
        rating: music.rating,
      );

      updatedItems.add(updatedMusic);
    }

    return updatedItems;
  }

  // Save music list to SharedPreferences for offline access
  Future<void> _saveOfflineMusicList(List<MediaItem> musicItems) async {
    final prefs = await SharedPreferences.getInstance();
    final musicJsonList = musicItems
        .map(
          (item) => {
            'id': item.id,
            'title': item.title,
            'file_path': item.fileUrl,
            'type': item.type,
            'duration': item.duration,
            'artist': item.artist,
            'album': item.album,
            'thumbnail':
                item.thumbnail, // This will be local path if downloaded
            'description': item.description,
            'rating': item.rating,
          },
        )
        .toList();

    await prefs.setString(_downloadedMusicKey, json.encode(musicJsonList));
  }

  // Get offline music list from SharedPreferences
  Future<List<MediaItem>> _getOfflineMusicList() async {
    final prefs = await SharedPreferences.getInstance();
    final musicJsonString = prefs.getString(_downloadedMusicKey);

    if (musicJsonString != null) {
      final List<dynamic> musicJsonList = json.decode(musicJsonString);
      return musicJsonList.map((json) => MediaItem.fromJson(json)).toList();
    }

    return [];
  }

  // Auto download music files and thumbnails in background
  Future<void> _autoDownloadMusic(List<MediaItem> musicItems) async {
    final downloadDir = await getDownloadDirectory();

    for (final music in musicItems) {
      final localFile = File('${downloadDir.path}/${music.localFileName}');

      // Skip if already downloaded
      if (await localFile.exists()) continue;

      try {
        // Download audio file
        await downloadMusicFile(music, downloadDir);
        print('Downloaded audio: ${music.title}');

        // Download thumbnail if available
        if (music.thumbnail != null && music.thumbnail!.isNotEmpty) {
          await downloadThumbnail(music);
          print('Downloaded thumbnail: ${music.title}');
        }
      } catch (e) {
        print('Failed to download ${music.title}: $e');
      }
    }
  }

  // Download individual music file
  Future<File> downloadMusicFile(MediaItem music, Directory downloadDir) async {
    final response = await http.get(Uri.parse(music.downloadUrl));

    if (response.statusCode == 200) {
      final file = File('${downloadDir.path}/${music.localFileName}');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception('Failed to download music file');
    }
  }

  // Download thumbnail
  Future<File?> downloadThumbnail(MediaItem music) async {
    if (music.thumbnail == null || music.thumbnail!.isEmpty) {
      return null;
    }

    try {
      final thumbnailDir = await getThumbnailDirectory();
      final response = await http.get(Uri.parse(music.thumbnail!));

      if (response.statusCode == 200) {
        final extension = _getImageExtensionFromUrl(music.thumbnail!);
        final file = File(
          '${thumbnailDir.path}/${music.id}_thumbnail.$extension',
        );
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      print('Failed to download thumbnail for ${music.title}: $e');
    }

    return null;
  }

  // Get image extension from URL
  String _getImageExtensionFromUrl(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();

    if (path.contains('.jpg') || path.contains('.jpeg')) return 'jpg';
    if (path.contains('.png')) return 'png';
    if (path.contains('.webp')) return 'webp';
    if (path.contains('.gif')) return 'gif';

    return 'jpg'; // default
  }

  // Get local thumbnail path
  Future<String?> getLocalThumbnailPath(MediaItem music) async {
    final thumbnailDir = await getThumbnailDirectory();

    // Check for different extensions
    final extensions = ['jpg', 'png', 'webp', 'gif'];

    for (final ext in extensions) {
      final file = File('${thumbnailDir.path}/${music.id}_thumbnail.$ext');
      if (await file.exists()) {
        return file.path;
      }
    }

    return null;
  }

  // Get local file path for music (for offline playback)
  Future<String?> getLocalMusicPath(MediaItem music) async {
    final downloadDir = await getDownloadDirectory();
    final localFile = File('${downloadDir.path}/${music.localFileName}');

    if (await localFile.exists()) {
      return localFile.path;
    }

    return null; // File not downloaded
  }

  // Check if music is downloaded
  Future<bool> isMusicDownloaded(MediaItem music) async {
    final downloadDir = await getDownloadDirectory();
    final localFile = File('${downloadDir.path}/${music.localFileName}');
    return await localFile.exists();
  }

  // Check if thumbnail is downloaded
  Future<bool> isThumbnailDownloaded(MediaItem music) async {
    final localThumbnailPath = await getLocalThumbnailPath(music);
    return localThumbnailPath != null;
  }

  // Delete downloaded music file
  Future<void> deleteDownloadedMusic(MediaItem music) async {
    final downloadDir = await getDownloadDirectory();
    final localFile = File('${downloadDir.path}/${music.localFileName}');

    if (await localFile.exists()) {
      await localFile.delete();
    }
  }

  // Delete downloaded thumbnail
  Future<void> deleteDownloadedThumbnail(MediaItem music) async {
    final localThumbnailPath = await getLocalThumbnailPath(music);
    if (localThumbnailPath != null) {
      final file = File(localThumbnailPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  // Get download progress (for UI feedback)
  Stream<double> downloadMusicWithProgress(MediaItem music) async* {
    final downloadDir = await getDownloadDirectory();
    final localFile = File('${downloadDir.path}/${music.localFileName}');

    final request = http.Request('GET', Uri.parse(music.downloadUrl));
    final response = await request.send();

    if (response.statusCode == 200) {
      final contentLength = response.contentLength ?? 0;
      var downloadedBytes = 0;

      final sink = localFile.openWrite();

      await for (final chunk in response.stream) {
        downloadedBytes += chunk.length;
        sink.add(chunk);

        if (contentLength > 0) {
          yield downloadedBytes / contentLength;
        }
      }

      await sink.close();
      yield 1.0; // Download complete
    } else {
      throw Exception('Failed to download music file');
    }
  }

  // Download both music and thumbnail with progress
  Stream<Map<String, dynamic>> downloadMusicAndThumbnailWithProgress(
    MediaItem music,
  ) async* {
    yield {'stage': 'audio', 'progress': 0.0};

    // Download audio first
    await for (final progress in downloadMusicWithProgress(music)) {
      yield {'stage': 'audio', 'progress': progress};
    }

    // Download thumbnail
    yield {'stage': 'thumbnail', 'progress': 0.0};

    if (music.thumbnail != null && music.thumbnail!.isNotEmpty) {
      try {
        await downloadThumbnail(music);
        yield {'stage': 'thumbnail', 'progress': 1.0};
      } catch (e) {
        yield {'stage': 'error', 'message': 'Failed to download thumbnail: $e'};
      }
    } else {
      yield {'stage': 'thumbnail', 'progress': 1.0};
    }

    yield {'stage': 'complete', 'progress': 1.0};
  }
}
