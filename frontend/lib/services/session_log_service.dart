// lib/services/session_log_service.dart

import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../models/passenger_session.dart';

class SessionLogService {
  static const String baseUrl =
      'https://acorned-willis-overneatly.ngrok-free.dev/api';
  static String? _cachedDeviceId;

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

  // Send session log to backend
  static Future<bool> sendLog(PassengerSession session) async {
    try {
      final deviceId = await getDeviceId();

      final payload = session.toJson();
      payload['device_id'] = deviceId;

      print('📤 Sending session log: ${session.sessionId}');
      print('Payload: $payload');

      final dio = Dio();
      final response = await dio.post(
        '$baseUrl/sessions/log',
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        print('✅ Session logged successfully');
        return true;
      }

      print('⚠️ Unexpected response: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      print('❌ Failed to send log: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }

      // Queue untuk retry nanti
      await _queueLog(session);
      return false;
    } catch (e) {
      print('❌ Unexpected error: $e');
      await _queueLog(session);
      return false;
    }
  }

  // Queue log for later (if offline)
  static Future<void> _queueLog(PassengerSession session) async {
    // TODO: Implement local queue using Hive or SQLite
    print('📋 Session queued for later: ${session.sessionId}');
  }

  // Get session stats (optional - for debugging)
  static Future<Map<String, dynamic>?> getStats({
    String period = 'today',
  }) async {
    try {
      final deviceId = await getDeviceId();
      final dio = Dio();

      final response = await dio.get(
        '$baseUrl/sessions/stats',
        queryParameters: {'device_id': deviceId, 'period': period},
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
}
