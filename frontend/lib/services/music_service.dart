// lib/services/music_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_item.dart';

class MusicService {
  static const String _baseUrl = 'http://192.168.1.18:8000';
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

          // Save to local storage for offline access
          await _saveOfflineMusicList(musicItems);

          // Auto download music files
          _autoDownloadMusic(musicItems);

          return musicItems;
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
            'thumbnail': item.thumbnail,
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

  // Auto download music files in background
  Future<void> _autoDownloadMusic(List<MediaItem> musicItems) async {
    final downloadDir = await getDownloadDirectory();

    for (final music in musicItems) {
      final localFile = File('${downloadDir.path}/${music.localFileName}');

      // Skip if already downloaded
      if (await localFile.exists()) continue;

      try {
        await downloadMusicFile(music, downloadDir);
        print('Downloaded: ${music.title}');
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

  // Delete downloaded music file
  Future<void> deleteDownloadedMusic(MediaItem music) async {
    final downloadDir = await getDownloadDirectory();
    final localFile = File('${downloadDir.path}/${music.localFileName}');

    if (await localFile.exists()) {
      await localFile.delete();
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
}
