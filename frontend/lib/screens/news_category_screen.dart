// lib/screens/news_category_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import 'news_detail_screen.dart';

class NewsCategoryScreen extends StatefulWidget {
  final String category;

  const NewsCategoryScreen({Key? key, required this.category})
    : super(key: key);

  @override
  _NewsCategoryScreenState createState() => _NewsCategoryScreenState();
}

class _NewsCategoryScreenState extends State<NewsCategoryScreen> {
  final NewsService _newsService = NewsService();
  final ScrollController _scrollController = ScrollController();

  List<NewsModel> _articles = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentLimit = 20;

  @override
  void initState() {
    super.initState();
    _loadNews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreNews();
    }
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final articles = await _newsService.getNewsByCategory(
        widget.category,
        limit: _currentLimit,
      );

      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final moreArticles = await _newsService.getNewsByCategory(
        widget.category,
        limit: _currentLimit + 20,
      );

      setState(() {
        if (moreArticles.length > _articles.length) {
          _articles = moreArticles;
          _currentLimit += 20;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB), // bg-gray-50 equivalent
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2563EB)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              '← Back to Home',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFF6B7280)),
            onPressed: () {
              // TODO: Implement search within category
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : _error != null
          ? _buildErrorState()
          : _articles.isEmpty
          ? _buildEmptyState()
          : _buildArticlesList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Color(0xFF9CA3AF), size: 64),
            SizedBox(height: 16),
            Text(
              'Failed to load news',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNews,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SVG-like icon using Icons
            Icon(Icons.article_outlined, color: Color(0xFF9CA3AF), size: 48),
            SizedBox(height: 16),
            Text(
              'No ${widget.category} articles found',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'There are no ${widget.category} articles available at the moment.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesList() {
    return RefreshIndicator(
      onRefresh: _loadNews,
      color: Color(0xFF2563EB),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category.toLowerCase() == 'entertainment'
                          ? 'Entertainment'
                          : widget.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Latest ${widget.category.toLowerCase()} news and updates',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Articles Grid
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == _articles.length && _isLoadingMore) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                  );
                }
                if (index < _articles.length) {
                  return _buildNewsCard(_articles[index]);
                }
                return null;
              }, childCount: _articles.length + (_isLoadingMore ? 1 : 0)),
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1024) return 3; // lg
    if (width > 768) return 2; // md
    return 1; // default
  }

  Widget _buildNewsCard(NewsModel article) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailScreen(slug: article.slug),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  child: article.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: article.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Color(0xFFE5E7EB),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF2563EB),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Color(0xFFE5E7EB),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    color: Color(0xFF9CA3AF),
                                    size: 32,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'No Image',
                                    style: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Color(0xFFE5E7EB),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  color: Color(0xFF9CA3AF),
                                  size: 32,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'No Image',
                                  style: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
            // Content Section
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryBackgroundColor(article.category),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article.category.toUpperCase(),
                        style: TextStyle(
                          color: _getCategoryTextColor(article.category),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Title
                    Expanded(
                      child: Text(
                        article.title,
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Description
                    if (article.description.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        article.description,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 12),
                    // Meta Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Unknown Source', // Atau bisa diganti dengan source lain
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatDateTime(article.publishedAt),
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
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
    );
  }

  Color _getCategoryBackgroundColor(String category) {
    switch (category.toLowerCase()) {
      case 'entertainment':
        return Color(0xFFF3E8FF); // purple-100
      case 'sports':
        return Color(0xFFDCFCE7); // green-100
      case 'politics':
        return Color(0xFFFEE2E2); // red-100
      case 'technology':
        return Color(0xFFDEF7FF); // blue-100
      default:
        return Color(0xFFE0E7FF); // indigo-100
    }
  }

  Color _getCategoryTextColor(String category) {
    switch (category.toLowerCase()) {
      case 'entertainment':
        return Color(0xFF7C3AED); // purple-600
      case 'sports':
        return Color(0xFF059669); // green-600
      case 'politics':
        return Color(0xFFDC2626); // red-600
      case 'technology':
        return Color(0xFF0284C7); // blue-600
      default:
        return Color(0xFF4F46E5); // indigo-600
    }
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
