// lib/services/news_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'news_api_service.dart';
import 'database_service.dart';
import '../models/news_model.dart';
// import '../models/news_list_response.dart';
// import '../models/news_detail_response.dart';

class NewsService {
  final NewsApiService _apiService = NewsApiService();
  final DatabaseService _databaseService = DatabaseService();

  // Check internet connectivity
  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Get latest news (online + offline)
  Future<List<NewsModel>> getLatestNews({
    int limit = 20,
    String? category,
  }) async {
    try {
      if (await _hasInternetConnection()) {
        // Try to fetch from API
        final response = await _apiService.getLatestNews(
          limit: limit,
          category: category,
        );

        // Save to database for offline use
        await _databaseService.saveNews(response.articles);

        return response.articles;
      } else {
        // Fallback to offline data
        return await _databaseService.getAllNews(
          limit: limit,
          category: category,
        );
      }
    } catch (e) {
      // If API fails, use offline data
      return await _databaseService.getAllNews(
        limit: limit,
        category: category,
      );
    }
  }

  // Get news by category
  Future<List<NewsModel>> getNewsByCategory(
    String category, {
    int limit = 12,
  }) async {
    try {
      if (await _hasInternetConnection()) {
        final response = await _apiService.getNewsByCategory(
          category,
          limit: limit,
        );
        await _databaseService.saveNews(response.articles);
        return response.articles;
      } else {
        return await _databaseService.getNewsByCategory(category, limit: limit);
      }
    } catch (e) {
      return await _databaseService.getNewsByCategory(category, limit: limit);
    }
  }

  // Get popular news
  Future<List<NewsModel>> getPopularNews({
    int limit = 10,
    String? category,
  }) async {
    try {
      if (await _hasInternetConnection()) {
        final response = await _apiService.getPopularNews(
          limit: limit,
          category: category,
        );
        await _databaseService.saveNews(response.articles);
        return response.articles;
      } else {
        return await _databaseService.getAllNews(
          limit: limit,
          category: category,
        );
      }
    } catch (e) {
      return await _databaseService.getAllNews(
        limit: limit,
        category: category,
      );
    }
  }

  // Get news detail
  Future<NewsModel?> getNewsDetail(String slug) async {
    try {
      if (await _hasInternetConnection()) {
        final response = await _apiService.getNewsDetail(slug);

        // Save main article and related articles to database
        await _databaseService.saveNews([response.article]);
        if (response.relatedArticles.isNotEmpty) {
          await _databaseService.saveNews(response.relatedArticles);
        }

        return response.article;
      } else {
        return await _databaseService.getNewsBySlug(slug);
      }
    } catch (e) {
      return await _databaseService.getNewsBySlug(slug);
    }
  }

  // Search news
  Future<List<NewsModel>> searchNews(
    String query, {
    String? category,
    int limit = 20,
  }) async {
    try {
      if (await _hasInternetConnection()) {
        final response = await _apiService.searchNews(
          query,
          category: category,
          limit: limit,
        );
        return response.articles;
      } else {
        return await _databaseService.searchNews(
          query,
          category: category,
          limit: limit,
        );
      }
    } catch (e) {
      return await _databaseService.searchNews(
        query,
        category: category,
        limit: limit,
      );
    }
  }

  // Get related news based on category or similar content
  Future<List<NewsModel>> getRelatedNews(
    String? category, {
    int limit = 5,
    String? excludeSlug,
  }) async {
    try {
      if (await _hasInternetConnection()) {
        // Try to get related news from API first
        List<NewsModel> relatedNews = [];

        if (category != null && category.isNotEmpty) {
          // Get news by same category
          final response = await _apiService.getNewsByCategory(
            category,
            limit:
                limit +
                2, // Get a few extra in case we need to exclude current article
          );
          relatedNews = response.articles;
        } else {
          // If no category, get latest news
          final response = await _apiService.getLatestNews(limit: limit + 2);
          relatedNews = response.articles;
        }

        // Exclude current article if specified
        if (excludeSlug != null) {
          relatedNews = relatedNews
              .where((article) => article.slug != excludeSlug)
              .toList();
        }

        // Take only the required limit
        relatedNews = relatedNews.take(limit).toList();

        // Save to database for offline use
        if (relatedNews.isNotEmpty) {
          await _databaseService.saveNews(relatedNews);
        }

        return relatedNews;
      } else {
        // Fallback to offline data
        return await _getRelatedNewsOffline(
          category,
          limit: limit,
          excludeSlug: excludeSlug,
        );
      }
    } catch (e) {
      // If API fails, use offline data
      return await _getRelatedNewsOffline(
        category,
        limit: limit,
        excludeSlug: excludeSlug,
      );
    }
  }

  // Helper method to get related news from offline storage
  Future<List<NewsModel>> _getRelatedNewsOffline(
    String? category, {
    int limit = 5,
    String? excludeSlug,
  }) async {
    List<NewsModel> relatedNews = [];

    if (category != null && category.isNotEmpty) {
      // Get news by same category from database
      relatedNews = await _databaseService.getNewsByCategory(
        category,
        limit: limit + 2,
      );
    } else {
      // Get latest news from database
      relatedNews = await _databaseService.getAllNews(limit: limit + 2);
    }

    // Exclude current article if specified
    if (excludeSlug != null) {
      relatedNews = relatedNews
          .where((article) => article.slug != excludeSlug)
          .toList();
    }

    // Take only the required limit
    return relatedNews.take(limit).toList();
  }
}
