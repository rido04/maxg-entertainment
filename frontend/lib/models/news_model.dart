// lib/models/news_model.dart
class NewsModel {
  final int id;
  final String title;
  final String description;
  final String? content;
  final String category;
  final String slug;
  final String? imageUrl;
  final String sourceUrl;
  final DateTime publishedAt;
  final DateTime? createdAt;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    this.content,
    required this.category,
    required this.slug,
    this.imageUrl,
    required this.sourceUrl,
    required this.publishedAt,
    this.createdAt,
  });

  // From JSON (API Response)
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'],
      category: json['category'] ?? '',
      slug: json['slug'] ?? '',
      imageUrl: json['image_url'],
      sourceUrl: json['source_url'] ?? '',
      publishedAt:
          DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  // To JSON (for database storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'category': category,
      'slug': slug,
      'image_url': imageUrl,
      'source_url': sourceUrl,
      'published_at': publishedAt.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // From Database Map
  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      content: map['content'],
      category: map['category'] ?? '',
      slug: map['slug'] ?? '',
      imageUrl: map['image_url'],
      sourceUrl: map['source_url'] ?? '',
      publishedAt:
          DateTime.tryParse(map['published_at'] ?? '') ?? DateTime.now(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
    );
  }

  // To Database Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'category': category,
      'slug': slug,
      'image_url': imageUrl,
      'source_url': sourceUrl,
      'published_at': publishedAt.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

// lib/models/api_response_model.dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? meta;

  ApiResponse({required this.success, this.data, this.message, this.meta});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      message: json['message'],
      meta: json['meta'],
    );
  }
}

// lib/models/news_list_response.dart
class NewsListResponse {
  final List<NewsModel> articles;
  final Map<String, dynamic>? meta;

  NewsListResponse({required this.articles, this.meta});

  factory NewsListResponse.fromJson(Map<String, dynamic> json) {
    List<NewsModel> articles = [];
    if (json['data'] != null) {
      articles = (json['data'] as List)
          .map((item) => NewsModel.fromJson(item))
          .toList();
    }

    return NewsListResponse(articles: articles, meta: json['meta']);
  }
}

// lib/models/news_detail_response.dart
class NewsDetailResponse {
  final NewsModel article;
  final List<NewsModel> relatedArticles;

  NewsDetailResponse({required this.article, required this.relatedArticles});

  factory NewsDetailResponse.fromJson(Map<String, dynamic> json) {
    NewsModel article = NewsModel.fromJson(json['data']);

    List<NewsModel> relatedArticles = [];
    if (json['related'] != null) {
      relatedArticles = (json['related'] as List)
          .map((item) => NewsModel.fromJson(item))
          .toList();
    }

    return NewsDetailResponse(
      article: article,
      relatedArticles: relatedArticles,
    );
  }
}
