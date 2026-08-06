// lib/services/session_log_service.dart

import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import '../models/passenger_session.dart';
import 'hive_storage_service.dart';

class SessionLogService {
  static const String baseUrl = 'https://maxg.gvisignagesystem.com/api';
  static String? _cachedDeviceId;
  static bool _isProcessingQueue = false;

  // Get device ID
  static Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _cachedDeviceId = 'ANDROID_${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _cachedDeviceId = 'IOS_${iosInfo.identifierForVendor}';
      } else {
        _cachedDeviceId = 'TABLET_001'; // Fallback
      }

      return _cachedDeviceId!;
    } catch (e) {
      print('Failed to get device ID: $e');
      return 'TABLET_UNKNOWN';
    }
  }

  /// Send session log to backend (with offline queue)
  static Future<bool> sendLog(PassengerSession session) async {
    try {
      final deviceId = await getDeviceId();

      final payload = session.toJson();
      payload['device_id'] = deviceId;

      print('📤 Sending session log: ${session.sessionId}');
      print('   - Viewed ads: ${session.viewedAds.length}');

      // Check connectivity first
      final hasInternet = await _checkConnectivity();

      if (!hasInternet) {
        print('📵 No internet, queueing log...');
        await HiveStorageService.queueSessionLog(session);
        return false;
      }

      // Try to send
      final dio = Dio();
      final response = await dio.post(
        '$baseUrl/sessions/log',
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        print('✅ Session logged successfully');

        // Try to process queued logs (non-blocking)
        _processQueuedLogsInBackground();

        return true;
      }

      print('⚠️ Unexpected response: ${response.statusCode}');
      await HiveStorageService.queueSessionLog(session);
      return false;
    } on DioException catch (e) {
      print('❌ Failed to send log: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }

      // Queue untuk retry nanti
      await HiveStorageService.queueSessionLog(session);
      return false;
    } catch (e) {
      print('❌ Unexpected error: $e');
      await HiveStorageService.queueSessionLog(session);
      return false;
    }
  }

  /// Process queued logs (retry sending)
  static Future<void> processQueuedLogs() async {
    if (_isProcessingQueue) {
      print('⏳ Already processing queue, skipping...');
      return;
    }

    _isProcessingQueue = true;

    try {
      // Check connectivity
      final hasInternet = await _checkConnectivity();
      if (!hasInternet) {
        print('📵 No internet, cannot process queue');
        return;
      }

      print('🔄 Processing queued logs...');

      final queuedLogs = await HiveStorageService.getQueuedLogs();

      if (queuedLogs.isEmpty) {
        print('✅ Queue is empty');
        return;
      }

      print('📤 Found ${queuedLogs.length} queued logs, sending...');

      int successCount = 0;
      int failCount = 0;

      for (var session in queuedLogs) {
        try {
          final deviceId = await getDeviceId();
          final payload = session.toJson();
          payload['device_id'] = deviceId;

          final dio = Dio();
          final response = await dio.post(
            '$baseUrl/sessions/log',
            data: payload,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              sendTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

          if (response.statusCode == 201 && response.data['success'] == true) {
            // Success - remove from queue
            await HiveStorageService.removeQueuedLog(session.sessionId);
            successCount++;
            print('✅ Queued log sent: ${session.sessionId}');
          } else {
            failCount++;
            print('⚠️ Queued log failed: ${session.sessionId}');
          }
        } catch (e) {
          failCount++;
          print('❌ Error sending queued log ${session.sessionId}: $e');
          // Keep in queue for next retry
        }
      }

      print('📊 Queue processed: $successCount sent, $failCount failed');
    } catch (e) {
      print('❌ Failed to process queue: $e');
    } finally {
      _isProcessingQueue = false;
    }
  }

  /// Process queued logs in background (non-blocking)
  static void _processQueuedLogsInBackground() {
    Future.delayed(Duration.zero, () async {
      try {
        await processQueuedLogs();
      } catch (e) {
        print('⚠️ Background queue processing failed: $e');
      }
    });
  }

  /// Check internet connectivity
  static Future<bool> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi;
    } catch (e) {
      print('❌ Connectivity check failed: $e');
      return false;
    }
  }

  /// Get session stats (optional - for debugging)
  static Future<Map<String, dynamic>?> getStats({
    String period = 'today',
  }) async {
    try {
      final deviceId = await getDeviceId();
      final dio = Dio();

      final response = await dio.get(
        '$baseUrl/sessions/stats',
        queryParameters: {'device_id': deviceId, 'period': period},
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }

      return null;
    } catch (e) {
      print('Failed to get stats: $e');
      return null;
    }
  }

  /// Get queue size (untuk monitoring)
  static Future<int> getQueueSize() async {
    final queuedLogs = await HiveStorageService.getQueuedLogs();
    return queuedLogs.length;
  }
}
