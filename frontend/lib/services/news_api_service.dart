// lib/services/news_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';
// import '../models/api_response_model.dart';
// import '../models/news_list_response.dart';
// import '../models/news_detail_response.dart';

class NewsApiService {
  static const String baseUrl =
      'http://192.168.1.18:8000'; // Ganti dengan URL API kamu

  // Get latest news for home page
  Future<NewsListResponse> getLatestNews({
    int limit = 20,
    String? category,
  }) async {
    try {
      String url = '$baseUrl/api/news?limit=$limit';
      if (category != null) {
        url += '&category=$category';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return NewsListResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }

  // Get news by category
  Future<NewsListResponse> getNewsByCategory(
    String category, {
    int limit = 12,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/news/category/$category?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return NewsListResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load category news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching category news: $e');
    }
  }

  // Get popular news
  Future<NewsListResponse> getPopularNews({
    int limit = 10,
    String? category,
  }) async {
    try {
      String url = '$baseUrl/api/news/popular?limit=$limit';
      if (category != null) {
        url += '&category=$category';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return NewsListResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load popular news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching popular news: $e');
    }
  }

  // Get single news article
  Future<NewsDetailResponse> getNewsDetail(String slug) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/news/$slug'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return NewsDetailResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load news detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news detail: $e');
    }
  }

  // Search news
  Future<NewsListResponse> searchNews(
    String query, {
    String? category,
    int limit = 20,
  }) async {
    try {
      String url =
          '$baseUrl/api/news/search?q=${Uri.encodeComponent(query)}&limit=$limit';
      if (category != null) {
        url += '&category=$category';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return NewsListResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to search news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching news: $e');
    }
  }
}
