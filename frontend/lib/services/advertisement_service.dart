// lib/services/advertisement_service.dart

import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/advertisement_item.dart';
import 'storage_service.dart';
import 'hive_storage_service.dart';

class AdvertisementService {
  static const String baseUrl = 'https://maxg.gvisignagesystem.com/api';
  static bool _isSyncing = false;

  /// Fetch advertisements (OFFLINE-FIRST)
  static Future<List<AdvertisementItem>> fetchAdvertisements({
    String? gender,
    String? ageGroup,
  }) async {
    print('📺 Fetching advertisements (gender: $gender, age: $ageGroup)...');

    // 1. Try to get from cache first
    final cachedAds = await HiveStorageService.getCachedAds();

    if (cachedAds.isNotEmpty) {
      print('✅ Using cached ads (${cachedAds.length})');

      // Filter by gender/age if specified
      final filteredAds = _filterAds(
        cachedAds,
        gender: gender,
        ageGroup: ageGroup,
      );

      // Try to sync in background (non-blocking)
      _syncAdsInBackground();

      return filteredAds;
    }

    // 2. No cache available, try to fetch from API
    print('⚠️ No cached ads, fetching from API...');

    try {
      final apiAds = await _fetchFromApi(gender: gender, ageGroup: ageGroup);

      if (apiAds.isNotEmpty) {
        // Save to cache for next time
        await HiveStorageService.saveAds(apiAds);

        // Download media files
        await _downloadAdvertisements(apiAds);

        return apiAds;
      }
    } catch (e) {
      print('❌ API fetch failed: $e');
    }

    // 3. Fallback: return empty list
    print('⚠️ No advertisements available (offline & no cache)');
    return [];
  }

  /// Fetch from API (with connectivity check)
  static Future<List<AdvertisementItem>> _fetchFromApi({
    String? gender,
    String? ageGroup,
  }) async {
    // Check connectivity first
    final hasInternet = await _checkConnectivity();
    if (!hasInternet) {
      print('📵 No internet connection');
      throw Exception('No internet connection');
    }

    try {
      final dio = Dio();

      final queryParams = <String, dynamic>{};
      if (gender != null) queryParams['gender'] = gender;
      if (ageGroup != null) queryParams['age_group'] = ageGroup;

      print('🌐 Fetching from API with params: $queryParams');

      final response = await dio.get(
        '$baseUrl/advertisements',
        queryParameters: queryParams,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final ads = data
            .map((json) => AdvertisementItem.fromJson(json))
            .toList();

        print('✅ Fetched ${ads.length} advertisements from API');
        return ads;
      }

      return [];
    } on DioException catch (e) {
      print('❌ API request failed: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      rethrow;
    }
  }

  /// Filter ads by gender and age group
  static List<AdvertisementItem> _filterAds(
    List<AdvertisementItem> ads, {
    String? gender,
    String? ageGroup,
  }) {
    if (gender == null && ageGroup == null) {
      return ads;
    }

    return ads.where((ad) {
      return ad.matchesProfile(gender: gender ?? 'all', ageGroup: ageGroup);
    }).toList();
  }

  /// Background sync (non-blocking)
  static Future<void> _syncAdsInBackground() async {
    if (_isSyncing) {
      print('⏳ Sync already in progress, skipping...');
      return;
    }

    _isSyncing = true;

    try {
      // Check if cache is recent
      final hasRecentCache = await HiveStorageService.hasRecentAdsCache(
        maxAge: const Duration(hours: 1), // Refresh every 1 hour
      );

      if (hasRecentCache) {
        print('✅ Cache is recent, skipping sync');
        return;
      }

      print('🔄 Syncing ads in background...');

      final apiAds = await _fetchFromApi();

      if (apiAds.isNotEmpty) {
        await HiveStorageService.saveAds(apiAds);
        await _downloadAdvertisements(apiAds);
        print('✅ Background sync completed');
      }
    } catch (e) {
      print('⚠️ Background sync failed (not critical): $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Force sync ads (manual refresh)
  static Future<bool> syncAds() async {
    print('🔄 Force syncing advertisements...');

    try {
      final apiAds = await _fetchFromApi();

      if (apiAds.isNotEmpty) {
        await HiveStorageService.saveAds(apiAds);
        await _downloadAdvertisements(apiAds);
        print('✅ Force sync completed: ${apiAds.length} ads');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Force sync failed: $e');
      return false;
    }
  }

  /// Download advertisement media files
  static Future<void> _downloadAdvertisements(
    List<AdvertisementItem> ads,
  ) async {
    for (final ad in ads) {
      try {
        final isDownloaded = await StorageService.isMediaDownloaded(
          ad.localFileName,
        );

        if (!isDownloaded) {
          print('⬇️ Downloading ad: ${ad.title}');
          await StorageService.downloadMedia(ad.fileUrl, ad.localFileName);

          // Download thumbnail if available
          if (ad.thumbnailUrl != null && ad.thumbnailUrl!.isNotEmpty) {
            final thumbFilename = 'ad_${ad.id}_thumb.jpg';
            await StorageService.downloadMedia(ad.thumbnailUrl!, thumbFilename);
          }
        }
      } catch (e) {
        print('❌ Failed to download ad ${ad.id}: $e');
      }
    }
  }

  /// Get local file path for ad
  static Future<String?> getLocalAdPath(AdvertisementItem ad) async {
    final isDownloaded = await StorageService.isMediaDownloaded(
      ad.localFileName,
    );
    if (isDownloaded) {
      return await StorageService.getLocalFilePath(ad.localFileName);
    }
    return null;
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

  /// Get cache stats (untuk debugging)
  static Future<Map<String, dynamic>> getCacheStats() async {
    return await HiveStorageService.getStats();
  }
}
