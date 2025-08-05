// lib/screens/news_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import 'news_detail_screen.dart';
import 'news_category_screen.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();

  List<NewsModel> _latestNews = [];
  List<NewsModel> _popularNews = [];
  List<NewsModel> _sportsNews = [];
  List<NewsModel> _entertainmentNews = [];
  List<NewsModel> _politicsNews = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _newsService.getLatestNews(limit: 10),
        _newsService.getPopularNews(limit: 8),
        _newsService.getNewsByCategory('sports', limit: 8),
        _newsService.getNewsByCategory('entertainment', limit: 6),
        _newsService.getNewsByCategory('politics', limit: 6),
      ]);

      setState(() {
        _latestNews = results[0];
        _popularNews = results[1];
        _sportsNews = results[2];
        _entertainmentNews = results[3];
        _politicsNews = results[4];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingScreen()
          : _error != null
          ? _buildErrorScreen()
          : RefreshIndicator(
              onRefresh: _loadNews,
              child: SingleChildScrollView(
                child: Column(children: [_buildMainContent()]),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey[50],
      elevation: 1,
      shadowColor: Colors.grey[200],
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo/Logo-Maxg-Green.gif',
            height: 32,
            width: 32,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12),
          Text(
            '.newspaper',
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.grey[700]),
          onPressed: () {
            // TODO: Implement search
          },
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.grey[700]),
          onPressed: _loadNews,
        ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Center(child: CircularProgressIndicator(color: Colors.green));
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.grey, size: 64),
          SizedBox(height: 16),
          Text(
            'Failed to load news',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(_error!, textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNews,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      constraints: BoxConstraints(maxWidth: 1200),
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content (3/4 of screen)
          Expanded(
            flex: 3,
            child: Column(
              children: [
                SizedBox(height: 24),
                _buildFeaturedNews(),
                SizedBox(height: 32),
                _buildSecondaryNewsGrid(),
                SizedBox(height: 32),
                _buildCategorySections(),
              ],
            ),
          ),
          SizedBox(width: 24),
          // Sidebar (1/4 of screen)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                SizedBox(height: 24),
                _buildPopularSection(),
                SizedBox(height: 16),
                _buildLatestSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedNews() {
    if (_sportsNews.isEmpty) return SizedBox();

    final featured = _sportsNews.first;
    return GestureDetector(
      onTap: () => _navigateToDetail(featured.slug),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background Image
              if (featured.imageUrl != null)
                CachedNetworkImage(
                  imageUrl: featured.imageUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.error),
                  ),
                ),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              // Category Badge
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'HEADLINE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        featured.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12),
                      Text(
                        featured.description,
                        style: TextStyle(color: Colors.grey[200], fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Garuda News',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            _formatDateTime(featured.publishedAt),
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryNewsGrid() {
    if (_sportsNews.length < 4) return SizedBox();

    return Row(
      children: _sportsNews.skip(1).take(3).map((article) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => _navigateToDetail(article.slug),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          if (article.imageUrl != null)
                            CachedNetworkImage(
                              imageUrl: article.imageUrl!,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 160,
                                color: Colors.grey[300],
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 160,
                                color: Colors.grey[300],
                                child: Icon(Icons.error),
                              ),
                            ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'NEWS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey[900],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Garuda News',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                _formatDateTime(article.publishedAt),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySections() {
    return Column(
      children: [
        _buildCategorySection(
          'Sports',
          _sportsNews.skip(4).take(2).toList(),
          'sports',
        ),
        SizedBox(height: 32),
        _buildCategorySection(
          'Politics',
          _politicsNews.take(2).toList(),
          'politics',
        ),
        SizedBox(height: 32),
        _buildCategorySection(
          'Entertainment',
          _entertainmentNews.take(2).toList(),
          'entertainment',
        ),
      ],
    );
  }

  Widget _buildCategorySection(
    String title,
    List<NewsModel> articles,
    String category,
  ) {
    return Column(
      children: [
        // Section Header
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
            SizedBox(width: 16),
            Expanded(child: Container(height: 1, color: Colors.grey[300])),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NewsCategoryScreen(category: category),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Read More',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: Colors.green, size: 16),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        // Articles
        Column(
          children: articles.map((article) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => _navigateToDetail(article.slug),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 120,
                          height: 80,
                          child: article.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: article.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: Colors.grey[300],
                                        child: Icon(Icons.error),
                                      ),
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Text(
                                      'No Image',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.grey[900],
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Text(
                              title.toUpperCase(),
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Popular',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 24, right: 24, bottom: 24),
            child: Column(
              children: _sportsNews.take(5).toList().asMap().entries.map((
                entry,
              ) {
                int index = entry.key;
                NewsModel article = entry.value;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () => _navigateToDetail(article.slug),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'NEWS',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < 4) ...[
                      SizedBox(height: 16),
                      Divider(color: Colors.white.withOpacity(0.2), height: 1),
                      SizedBox(height: 16),
                    ],
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Latest',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              children: _politicsNews.take(5).toList().asMap().entries.map((
                entry,
              ) {
                int index = entry.key;
                NewsModel article = entry.value;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () => _navigateToDetail(article.slug),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: TextStyle(
                              color: Colors.grey[900],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatDateTime(article.publishedAt),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < 4) ...[
                      SizedBox(height: 12),
                      Divider(color: Colors.grey[200], height: 1),
                      SizedBox(height: 12),
                    ],
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(String slug) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewsDetailScreen(slug: slug)),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
