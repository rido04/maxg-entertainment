// lib/services/running_text_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/running_text_item.dart';
import 'hive_storage_service.dart';

class RunningTextService {
  static const String baseUrl = 'https://maxg.gvisignagesystem.com/api';
  static bool _isSyncing = false;

  /// Fetch active running texts (OFFLINE-FIRST)
  static Future<List<RunningTextItem>> fetchActiveRunningTexts() async {
    print('📜 Fetching running texts...');

    // 1. Try to get from cache first
    final cachedTexts = await HiveStorageService.getCachedRunningTexts();

    if (cachedTexts.isNotEmpty) {
      print('✅ Using cached running texts (${cachedTexts.length})');

      // Convert from dynamic to RunningTextItem
      final runningTextItems = cachedTexts
          .map((json) => RunningTextItem.fromJson(json))
          .toList();

      // Try to sync in background (non-blocking)
      _syncRunningTextsInBackground();

      return runningTextItems;
    }

    // 2. No cache available, try to fetch from API
    print('⚠️ No cached running texts, fetching from API...');

    try {
      final apiTexts = await _fetchFromApi();

      if (apiTexts.isNotEmpty) {
        // Save to cache for next time
        await HiveStorageService.saveRunningTexts(apiTexts);
        return apiTexts;
      }
    } catch (e) {
      print('❌ API fetch failed: $e');
    }

    // 3. Fallback: return empty list
    print('⚠️ No running texts available (offline & no cache)');
    return [];
  }

  /// Fetch from API (with connectivity check)
  static Future<List<RunningTextItem>> _fetchFromApi() async {
    // Check connectivity first
    final hasInternet = await _checkConnectivity();
    if (!hasInternet) {
      print('📵 No internet connection');
      throw Exception('No internet connection');
    }

    try {
      print('📡 Fetching active running texts from API...');

      final response = await http
          .get(
            Uri.parse('$baseUrl/running-texts/active'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> runningTextsJson = data['data'];

          final runningTexts = runningTextsJson
              .map((json) => RunningTextItem.fromJson(json))
              .toList();

          print('✅ Fetched ${runningTexts.length} running texts from API');

          return runningTexts;
        }
      }

      return [];
    } catch (e) {
      print('❌ API request failed: $e');
      rethrow;
    }
  }

  /// Background sync (non-blocking)
  static Future<void> _syncRunningTextsInBackground() async {
    if (_isSyncing) {
      print('⏳ Sync already in progress, skipping...');
      return;
    }

    _isSyncing = true;

    try {
      // Check if cache is recent
      final hasRecentCache =
          await HiveStorageService.hasRecentRunningTextsCache(
            maxAge: const Duration(minutes: 30), // Refresh every 30 minutes
          );

      if (hasRecentCache) {
        print('✅ Running texts cache is recent, skipping sync');
        return;
      }

      print('🔄 Syncing running texts in background...');

      final apiTexts = await _fetchFromApi();

      if (apiTexts.isNotEmpty) {
        await HiveStorageService.saveRunningTexts(apiTexts);
        print('✅ Background sync completed');
      }
    } catch (e) {
      print('⚠️ Background sync failed (not critical): $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Force sync running texts (manual refresh)
  static Future<bool> syncRunningTexts() async {
    print('🔄 Force syncing running texts...');

    try {
      final apiTexts = await _fetchFromApi();

      if (apiTexts.isNotEmpty) {
        await HiveStorageService.saveRunningTexts(apiTexts);
        print('✅ Force sync completed: ${apiTexts.length} texts');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Force sync failed: $e');
      return false;
    }
  }

  /// Check internet connectivity
  static Future<bool> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result == (ConnectivityResult.mobile) ||
          result == (ConnectivityResult.wifi);
    } catch (e) {
      print('❌ Connectivity check failed: $e');
      return false;
    }
  }
}
