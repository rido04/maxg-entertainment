import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/media_item.dart';
import 'storage_service.dart';

class ApiService {
  static const String baseUrl = 'https://maxg.app.medialoger.com/api';
  static const String downloadBaseUrl = 'https://maxg.app.medialoger.com';
  static const Duration timeoutDuration = Duration(seconds: 10);

  /// Fetch media list dengan offline-first approach
  static Future<List<MediaItem>> fetchMediaList({
    bool forceOnline = false,
  }) async {
    try {
      print('Fetching media list...');

      // Jika tidak force online, coba ambil dari cache dulu
      if (!forceOnline) {
        final cachedMedia = await StorageService.getCachedMediaList();
        if (cachedMedia != null && cachedMedia.isNotEmpty) {
          print('Using cached data with ${cachedMedia.length} items');

          // Tetap coba update di background (optional)
          _updateCacheInBackground();

          return cachedMedia;
        }
      }

      // Coba fetch dari server
      final response = await http
          .get(Uri.parse('$baseUrl/media'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List data = jsonResponse['data'];
        final mediaList = data.map((item) => MediaItem.fromJson(item)).toList();

        // Simpan ke cache
        await StorageService.cacheMediaList(mediaList);
        print('Fetched ${mediaList.length} items from server and cached');

        return mediaList;
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch from server: $e');

      // Fallback ke cache
      print('Falling back to cached data...');
      final cachedMedia = await StorageService.getCachedMediaList();

      if (cachedMedia != null && cachedMedia.isNotEmpty) {
        print('Using cached fallback with ${cachedMedia.length} items');
        return cachedMedia;
      }

      // Jika tidak ada cache, return empty list
      print('No cached data available');
      return [];
    }
  }

  /// Update cache di background tanpa mengganggu UI
  static void _updateCacheInBackground() {
    Future.microtask(() async {
      try {
        print('Updating cache in background...');
        final response = await http
            .get(Uri.parse('$baseUrl/media'))
            .timeout(timeoutDuration);

        if (response.statusCode == 200) {
          Map<String, dynamic> jsonResponse = json.decode(response.body);
          List data = jsonResponse['data'];
          final mediaList = data
              .map((item) => MediaItem.fromJson(item))
              .toList();

          await StorageService.cacheMediaList(mediaList);
          print('Background cache update completed');
        }
      } catch (e) {
        print('Background update failed: $e');
      }
    });
  }

  /// Cek koneksi ke server
  static Future<bool> checkServerConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'), // Endpoint health check
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Server connection check failed: $e');
      return false;
    }
  }

  /// Force refresh dari server
  static Future<List<MediaItem>> forceRefreshMediaList() async {
    try {
      // Clear cache terlebih dahulu
      await StorageService.clearCache();

      // Fetch fresh data
      return await fetchMediaList(forceOnline: true);
    } catch (e) {
      print('Force refresh failed: $e');
      // Jika gagal, tetap return cached data jika ada
      final cachedMedia = await StorageService.getCachedMediaList();
      return cachedMedia ?? [];
    }
  }
}
