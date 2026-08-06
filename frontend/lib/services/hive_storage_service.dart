// lib/services/hive_storage_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../models/advertisement_item.dart';
import '../models/passenger_session.dart';

class HiveStorageService {
  static const String _adsBoxName = 'advertisements_cache';
  static const String _logsQueueBoxName = 'session_logs_queue';
  static const String _metadataBoxName = 'app_metadata';
  static const String _runningTextsBoxName = 'running_texts_cache'; // 👈 TAMBAH

  static Box<Map>? _adsBox;
  static Box<Map>? _logsQueueBox;
  static Box<dynamic>? _metadataBox;
  static Box<Map>? _runningTextsBox; // 👈 TAMBAH

  static bool _isInitialized = false;

  // Initialize Hive
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🗄️ Initializing Hive...');

      await Hive.initFlutter();

      // Open boxes
      _adsBox = await Hive.openBox<Map>(_adsBoxName);
      _logsQueueBox = await Hive.openBox<Map>(_logsQueueBoxName);
      _metadataBox = await Hive.openBox(_metadataBoxName);
      _runningTextsBox = await Hive.openBox<Map>(
        _runningTextsBoxName,
      ); // 👈 TAMBAH

      _isInitialized = true;
      print('✅ Hive initialized');
      print('   - Cached ads: ${_adsBox!.length}');
      print('   - Queued logs: ${_logsQueueBox!.length}');
      print(
        '   - Cached running texts: ${_runningTextsBox!.length}',
      ); // 👈 TAMBAH
    } catch (e) {
      print('❌ Hive initialization failed: $e');
      rethrow;
    }
  }

  // ========== ADVERTISEMENTS CACHE ==========

  /// Save ads to local cache
  static Future<void> saveAds(List<AdvertisementItem> ads) async {
    await _ensureInitialized();

    try {
      // Clear old cache
      await _adsBox!.clear();

      // Save new ads
      for (var ad in ads) {
        await _adsBox!.put(ad.id.toString(), ad.toJson());
      }

      // Update last sync time
      await _metadataBox!.put(
        'ads_last_sync',
        DateTime.now().toIso8601String(),
      );

      print('💾 Saved ${ads.length} ads to cache');
    } catch (e) {
      print('❌ Failed to save ads: $e');
    }
  }

  /// Get cached ads
  static Future<List<AdvertisementItem>> getCachedAds() async {
    await _ensureInitialized();

    try {
      final cachedAds = _adsBox!.values
          .map(
            (json) =>
                AdvertisementItem.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();

      print('📦 Retrieved ${cachedAds.length} ads from cache');
      return cachedAds;
    } catch (e) {
      print('❌ Failed to get cached ads: $e');
      return [];
    }
  }

  /// Check if ads cache exists and is recent
  static Future<bool> hasRecentAdsCache({
    Duration maxAge = const Duration(hours: 24),
  }) async {
    await _ensureInitialized();

    final lastSync = _metadataBox!.get('ads_last_sync') as String?;
    if (lastSync == null) return false;

    final lastSyncTime = DateTime.parse(lastSync);
    final age = DateTime.now().difference(lastSyncTime);

    return age < maxAge && _adsBox!.isNotEmpty;
  }

  // ========== SESSION LOGS QUEUE ==========

  /// Add session log to queue (untuk retry nanti)
  static Future<void> queueSessionLog(PassengerSession session) async {
    await _ensureInitialized();

    try {
      final key =
          '${session.sessionId}_${DateTime.now().millisecondsSinceEpoch}';
      await _logsQueueBox!.put(key, session.toJson());

      print(
        '📋 Session queued: ${session.sessionId} (Queue size: ${_logsQueueBox!.length})',
      );
    } catch (e) {
      print('❌ Failed to queue session: $e');
    }
  }

  /// Get all queued session logs
  static Future<List<PassengerSession>> getQueuedLogs() async {
    await _ensureInitialized();

    try {
      final sessions = _logsQueueBox!.values
          .map(
            (json) =>
                PassengerSession.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();

      print('📤 Retrieved ${sessions.length} queued logs');
      return sessions;
    } catch (e) {
      print('❌ Failed to get queued logs: $e');
      return [];
    }
  }

  /// Remove session log from queue (setelah berhasil dikirim)
  static Future<void> removeQueuedLog(String sessionId) async {
    await _ensureInitialized();

    try {
      // Find and delete matching key
      final keysToDelete = _logsQueueBox!.keys
          .where((key) => key.toString().startsWith(sessionId))
          .toList();

      for (var key in keysToDelete) {
        await _logsQueueBox!.delete(key);
      }

      print('✅ Removed queued log: $sessionId');
    } catch (e) {
      print('❌ Failed to remove queued log: $e');
    }
  }

  /// Clear all queued logs (untuk debugging)
  static Future<void> clearQueuedLogs() async {
    await _ensureInitialized();
    await _logsQueueBox!.clear();
    print('🗑️ Cleared all queued logs');
  }

  // ========== METADATA ==========

  /// Get last sync time for ads
  static Future<DateTime?> getLastAdsSyncTime() async {
    await _ensureInitialized();

    final lastSync = _metadataBox!.get('ads_last_sync') as String?;
    return lastSync != null ? DateTime.parse(lastSync) : null;
  }

  /// Set custom metadata
  static Future<void> setMetadata(String key, dynamic value) async {
    await _ensureInitialized();
    await _metadataBox!.put(key, value);
  }

  /// Get custom metadata
  static Future<dynamic> getMetadata(String key) async {
    await _ensureInitialized();
    return _metadataBox!.get(key);
  }

  // ========== RUNNING TEXTS CACHE ========== 👈 TAMBAH

  /// Save running texts to local cache
  static Future<void> saveRunningTexts(List<dynamic> runningTexts) async {
    await _ensureInitialized();

    try {
      // Clear old cache
      await _runningTextsBox!.clear();

      // Save new running texts
      for (int i = 0; i < runningTexts.length; i++) {
        final rt = runningTexts[i];
        final Map<String, dynamic> rtJson = rt is Map<String, dynamic>
            ? rt
            : (rt as dynamic).toJson();
        await _runningTextsBox!.put(i.toString(), rtJson);
      }

      // Update last sync time
      await _metadataBox!.put(
        'running_texts_last_sync',
        DateTime.now().toIso8601String(),
      );

      print('💾 Saved ${runningTexts.length} running texts to cache');
    } catch (e) {
      print('❌ Failed to save running texts: $e');
    }
  }


  /// Get cached running texts
  static Future<List<dynamic>> getCachedRunningTexts() async {
    await _ensureInitialized();

    try {
      final cachedTexts = _runningTextsBox!.values.map((json) {
        return Map<String, dynamic>.from(json);
      }).toList();

      print('📦 Retrieved ${cachedTexts.length} running texts from cache');
      return cachedTexts;
    } catch (e) {
      print('❌ Failed to get cached running texts: $e');
      return [];
    }
  }

  /// Check if running texts cache exists and is recent
  static Future<bool> hasRecentRunningTextsCache({
    Duration maxAge = const Duration(minutes: 30),
  }) async {
    await _ensureInitialized();

    final lastSync = _metadataBox!.get('running_texts_last_sync') as String?;
    if (lastSync == null) return false;

    final lastSyncTime = DateTime.parse(lastSync);
    final age = DateTime.now().difference(lastSyncTime);

    return age < maxAge && _runningTextsBox!.isNotEmpty;
  }

  /// Get last sync time for running texts
  static Future<DateTime?> getLastRunningTextsSyncTime() async {
    await _ensureInitialized();

    final lastSync = _metadataBox!.get('running_texts_last_sync') as String?;
    return lastSync != null ? DateTime.parse(lastSync) : null;
  }

  // ========== UTILITIES ==========

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Get storage stats (untuk debugging)
  static Future<Map<String, dynamic>> getStats() async {
    await _ensureInitialized();

    final lastSync = await getLastAdsSyncTime();

    return {
      'cached_ads_count': _adsBox!.length,
      'queued_logs_count': _logsQueueBox!.length,
      'last_ads_sync': lastSync?.toIso8601String(),
      'cache_age_hours': lastSync != null
          ? DateTime.now().difference(lastSync).inHours
          : null,
    };
  }

  /// Clear all storage (untuk reset/debugging)
  static Future<void> clearAll() async {
    await _ensureInitialized();

    await _adsBox!.clear();
    await _logsQueueBox!.clear();
    await _metadataBox!.clear();

    print('🗑️ Cleared all Hive storage');
  }
}
