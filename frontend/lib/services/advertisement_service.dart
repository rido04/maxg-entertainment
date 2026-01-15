// lib/services/advertisement_service.dart

import 'package:dio/dio.dart';
import '../models/advertisement_item.dart';
import 'storage_service.dart';

class AdvertisementService {
  static const String baseUrl =
      'https://acorned-willis-overneatly.ngrok-free.dev/api';

  static Future<List<AdvertisementItem>> fetchAdvertisements({
    String? gender,
    String? ageGroup,
  }) async {
    try {
      final dio = Dio();

      // 🔍 Add logging interceptor
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );

      final queryParams = <String, dynamic>{};
      if (gender != null) queryParams['gender'] = gender;
      if (ageGroup != null) queryParams['age_group'] = ageGroup;

      print('Fetching ads with params: $queryParams');

      final response = await dio.get(
        '$baseUrl/advertisements',
        queryParameters: queryParams,
      );

      // 🔍 Print raw response
      print('📡 Raw response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];

        // 🔍 Print each item
        for (var item in data) {
          print('📦 Item: $item');
        }

        final ads = data
            .map((json) => AdvertisementItem.fromJson(json))
            .toList();

        print('✅ Fetched ${ads.length} advertisements');
        await _downloadAdvertisements(ads);

        return ads;
      }

      return [];
    } catch (e, stackTrace) {
      print('❌ Failed to fetch advertisements: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<void> _downloadAdvertisements(
    List<AdvertisementItem> ads,
  ) async {
    for (final ad in ads) {
      try {
        final isDownloaded = await StorageService.isMediaDownloaded(
          ad.localFileName,
        );

        if (!isDownloaded) {
          print('Downloading ad: ${ad.title}');
          await StorageService.downloadMedia(ad.fileUrl, ad.localFileName);

          // Download thumbnail if available
          if (ad.thumbnailUrl != null && ad.thumbnailUrl!.isNotEmpty) {
            final thumbFilename = 'ad_${ad.id}_thumb.jpg';
            await StorageService.downloadMedia(ad.thumbnailUrl!, thumbFilename);
          }
        }
      } catch (e) {
        print('Failed to download ad ${ad.id}: $e');
      }
    }
  }

  // Get local file path for ad
  static Future<String?> getLocalAdPath(AdvertisementItem ad) async {
    final isDownloaded = await StorageService.isMediaDownloaded(
      ad.localFileName,
    );
    if (isDownloaded) {
      return await StorageService.getLocalFilePath(ad.localFileName);
    }
    return null;
  }
}
