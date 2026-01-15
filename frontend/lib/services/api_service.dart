import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import '../models/media_item.dart';
import 'storage_service.dart';

class ApiService {
  static const String baseUrl =
      'https://acorned-willis-overneatly.ngrok-free.dev/api';
  static const String downloadBaseUrl =
      'https://acorned-willis-overneatly.ngrok-free.dev';
  static const Duration timeoutDuration = Duration(seconds: 15);

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeoutDuration,
        receiveTimeout: timeoutDuration,
        sendTimeout: timeoutDuration,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'MaxG-Entertainment-App/1.0',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Bypass SSL verification
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      client.connectionTimeout = timeoutDuration;
      return client;
    };

    // Add logging interceptor for debugging
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
    );

    return dio;
  }

  static Future<List<MediaItem>> fetchMediaList({
    bool forceOnline = false,
  }) async {
    try {
      print('Fetching media list with Dio...');

      if (!forceOnline) {
        final cachedMedia = await StorageService.getCachedMediaList();
        if (cachedMedia != null && cachedMedia.isNotEmpty) {
          print('Using cached data with ${cachedMedia.length} items');
          _updateCacheInBackground();
          return cachedMedia;
        }
      }

      final dio = _createDio();
      final response = await dio.get('/media');

      if (response.statusCode == 200 && response.data != null) {
        final jsonResponse = response.data as Map<String, dynamic>;
        final data = jsonResponse['data'] as List;
        final mediaList = data.map((item) => MediaItem.fromJson(item)).toList();

        await StorageService.cacheMediaList(mediaList);
        print('✅ Fetched ${mediaList.length} items from server and cached');

        return mediaList;
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio error: ${e.type} - ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
        print('Response status: ${e.response?.statusCode}');
      }

      print('Falling back to cached data...');
      final cachedMedia = await StorageService.getCachedMediaList();
      if (cachedMedia != null && cachedMedia.isNotEmpty) {
        print('Using cached fallback with ${cachedMedia.length} items');
        return cachedMedia;
      }

      print('No cached data available');
      return [];
    } catch (e) {
      print('❌ Unexpected error: $e');

      final cachedMedia = await StorageService.getCachedMediaList();
      if (cachedMedia != null && cachedMedia.isNotEmpty) {
        return cachedMedia;
      }

      return [];
    }
  }

  static void _updateCacheInBackground() {
    Future.microtask(() async {
      try {
        print('Updating cache in background...');
        final dio = _createDio();
        final response = await dio.get('/media');

        if (response.statusCode == 200 && response.data != null) {
          final jsonResponse = response.data as Map<String, dynamic>;
          final data = jsonResponse['data'] as List;
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

  static Future<bool> checkServerConnection() async {
    try {
      final dio = _createDio();
      final response = await dio.get(
        '/media',
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Server connection check failed: $e');
      return false;
    }
  }

  static Future<List<MediaItem>> forceRefreshMediaList() async {
    try {
      await StorageService.clearCache();
      return await fetchMediaList(forceOnline: true);
    } catch (e) {
      print('Force refresh failed: $e');
      final cachedMedia = await StorageService.getCachedMediaList();
      return cachedMedia ?? [];
    }
  }
}
