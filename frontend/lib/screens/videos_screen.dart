import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/media_item.dart';
import '../services/storage_service.dart';
import 'videos_player_screen.dart';
import 'video_search_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'movie_detail_screen.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen>
    with TickerProviderStateMixin {
  late Future<List<MediaItem>> mediaList;
  late AnimationController _animationController;
  late AnimationController _thumbnailAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _thumbnailOpacityAnimation;
  late Animation<double> _thumbnailScaleAnimation;

  bool _isRefreshing = false;
  bool _isAutoDownloading = false;
  bool _isOnlineMode = false;
  int _currentPage = 1;
  int _itemsPerPage = 8;
  MediaItem? _hoveredMedia;
  String? _currentTime;
  String _selectedCategory = 'All';
  String _selectedType = 'All';
  double _minRating = 0.0;
  bool _showOnlyDownloaded = false;
  List<String> _availableCategories = ['All'];
  List<String> _availableTypes = ['All'];
  List<MediaItem> _allVideoItems = [];
  final ScrollController _scrollController = ScrollController();

  int _getActiveFiltersCount() {
    int count = 0;
    if (_selectedCategory != 'All') count++;
    if (_selectedType != 'All') count++;
    if (_showOnlyDownloaded) count++;
    return count;
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildFilterModal(),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    _updateTime();
    _initializeAnimations();
    _checkConnectionStatus();
    _initializeFilterOptions();

    Stream.periodic(const Duration(seconds: 1)).listen((_) => _updateTime());
  }

  void _initializeData() {
    mediaList = ApiService.fetchMediaList();
    _startAutoDownload();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _thumbnailAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _thumbnailOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _thumbnailAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _thumbnailScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _thumbnailAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  List<MediaItem> _applyFilters(List<MediaItem> items) {
    return items.where((item) {
      if (_selectedCategory != 'All' &&
          (item.category == null || item.category != _selectedCategory)) {
        return false;
      }

      if (_selectedType != 'All' &&
          (item.type == null || item.type != _selectedType)) {
        return false;
      }

      if (item.numericRating < _minRating) {
        return false;
      }

      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedType = 'All';
      _minRating = 0.0;
      _showOnlyDownloaded = false;
    });
  }

  Future<void> _checkConnectionStatus() async {
    final isOnline = await ApiService.checkServerConnection();
    if (mounted) {
      setState(() {
        _isOnlineMode = isOnline;
      });
    }
  }

  Future<void> _initializeFilterOptions() async {
    try {
      final allMedia = await ApiService.fetchMediaList();
      final videoItems = StorageService.filterVideoFiles(allMedia);

      final categories = videoItems
          .map((item) => item.category ?? 'Unknown')
          .where((category) => category.isNotEmpty)
          .toSet()
          .toList();

      final types = videoItems
          .map((item) => item.type ?? 'Unknown')
          .where((type) => type.isNotEmpty)
          .toSet()
          .toList();

      setState(() {
        _availableCategories = ['All', ...categories];
        _availableTypes = ['All', ...types];
      });
    } catch (e) {
      print('Error initializing filter options: $e');
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeString =
        "${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period";
    if (mounted) {
      setState(() {
        _currentTime = timeString;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _thumbnailAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMovieHover(MediaItem? media, bool isEntering) {
    if (_hoveredMedia != media) {
      setState(() {
        _hoveredMedia = media;
      });

      if (media != null && isEntering) {
        _thumbnailAnimationController.forward();
      } else {
        _thumbnailAnimationController.reverse();
      }
    }
  }

  Future<void> _startAutoDownload() async {
    setState(() {
      _isAutoDownloading = true;
    });

    try {
      print('Starting auto download...');
      final allMedia = await ApiService.fetchMediaList();
      final videoItems = StorageService.filterVideoFiles(allMedia);

      print('Found ${videoItems.length} video files to download');
      await StorageService.downloadAllMedia(videoItems);

      print('Auto download completed!');
      _showSuccessMessage('Videos ready for offline viewing');
    } catch (e) {
      print('Auto download failed: $e');
      _showErrorMessage('Some downloads may have failed');
    } finally {
      setState(() {
        _isAutoDownloading = false;
      });
    }
  }

  Future<void> _refreshMediaList() async {
    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final freshData = await ApiService.forceRefreshMediaList();

      setState(() {
        mediaList = Future.value(freshData);
        _isRefreshing = false;
      });

      await _checkConnectionStatus();
      _startAutoDownload();

      _showSuccessMessage('Media list updated');
    } catch (e) {
      setState(() {
        _isRefreshing = false;
      });
      _showErrorMessage('Refresh failed, showing cached data');
    }
  }

  Future<void> _showOfflineOnly() async {
    try {
      final offlineVideos = await StorageService.getDownloadedMedia();
      final videoItems = StorageService.filterVideoFiles(offlineVideos);

      setState(() {
        mediaList = Future.value(videoItems);
      });

      _showSuccessMessage('Showing ${videoItems.length} offline videos');
    } catch (e) {
      _showErrorMessage('Failed to load offline videos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background/Background_Color.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchAndFilter(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: RefreshIndicator(
                    onRefresh: _refreshMediaList,
                    color: const Color(0xFFF0B513),
                    child: FutureBuilder<List<MediaItem>>(
                      future: mediaList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildLoadingState();
                        }

                        if (snapshot.hasError) {
                          return _buildErrorState(snapshot.error.toString());
                        }

                        if (snapshot.hasData) {
                          final items = snapshot.data!;
                          final videoItems = StorageService.filterVideoFiles(
                            items,
                          );

                          if (videoItems.isEmpty) {
                            return _buildEmptyState();
                          }

                          return _buildMainContent(videoItems);
                        }

                        return _buildLoadingState();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildTimeDisplay(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logo/Maxg-ent_white.gif',
                width: 120,
                height: 60,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isOnlineMode
                        ? [Color(0xFF10B981), Color(0xFF059669)]
                        : [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isOnlineMode ? Icons.cloud_done : Icons.cloud_off,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isOnlineMode ? 'Online' : 'Offline',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VideoSearchScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white),
                onPressed: _isRefreshing || _isAutoDownloading
                    ? null
                    : _refreshMediaList,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Biar ga bosen di jalan, yuk nonton film seru!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                style: TextStyle(color: Colors.grey[800]),
                decoration: InputDecoration(
                  hintText: 'Lagi mau nonton apa nih?...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF00B14F)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (value) {
                  // Handle search
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _showFilterModal,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF0B513), Color(0xFFF5D271)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFF0B513).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune, size: 18, color: Colors.white),
                  if (_getActiveFiltersCount() > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      '${_getActiveFiltersCount()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterModal() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.tune,
                          color: Color(0xFFF0B513),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Filter Movies',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _resetFilters();
                            });
                            setState(() {});
                          },
                          child: const Text(
                            'Reset All',
                            style: TextStyle(color: Color(0xFFF0B513)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Genre',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          items: _availableCategories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                category,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setModalState(() {
                              _selectedCategory = newValue!;
                              _currentPage = 1;
                            });
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Type',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          items: _availableTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setModalState(() {
                              _selectedType = newValue!;
                              _currentPage = 1;
                            });
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Show Downloaded Only',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _showOnlyDownloaded,
                          onChanged: (bool value) {
                            setModalState(() {
                              _showOnlyDownloaded = value;
                              _currentPage = 1;
                            });
                            setState(() {});
                          },
                          activeColor: const Color(0xFFF0B513),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0B513),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(List<MediaItem> videoItems) {
    _allVideoItems = videoItems;
    final filteredItems = _applyFilters(_allVideoItems);

    final totalPages = (filteredItems.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(
      0,
      filteredItems.length,
    );
    final currentPageItems = filteredItems.sublist(startIndex, endIndex);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;

        if (isTablet) {
          // Tablet/Desktop layout with split view
          return Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildListHeader(filteredItems),
                    Expanded(
                      child: _buildMovieList(currentPageItems, filteredItems),
                    ),
                    if (totalPages > 1) _buildPagination(totalPages),
                  ],
                ),
              ),
              Expanded(flex: 1, child: _buildThumbnailPreview()),
            ],
          );
        } else {
          // Mobile layout
          return Column(
            children: [
              _buildListHeader(filteredItems),
              Expanded(child: _buildMovieList(currentPageItems, filteredItems)),
              if (totalPages > 1) _buildPagination(totalPages),
            ],
          );
        }
      },
    );
  }

  Widget _buildListHeader(List<MediaItem> filteredItems) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF0B513), Color(0xFFF5D271)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'List semua film',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${filteredItems.length} movies',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieList(
    List<MediaItem> currentPageItems,
    List<MediaItem> allItems,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: currentPageItems.length,
      itemBuilder: (context, index) {
        final media = currentPageItems[index];
        final isHovered = _hoveredMedia == media;

        return FutureBuilder<bool>(
          future: StorageService.isMediaDownloaded(media.localFileName),
          builder: (context, downloadSnapshot) {
            final isDownloaded = downloadSnapshot.data ?? false;

            return GestureDetector(
              onTap: () => _handleMediaTap(media),
              onTapDown: (_) => _onMovieHover(media, true),
              onTapUp: (_) {
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (mounted) _onMovieHover(null, false);
                });
              },
              onTapCancel: () => _onMovieHover(null, false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isHovered
                        ? [Color(0xFF005234), Color(0xFF00693D)]
                        : [Color(0xFFF0B513), Color(0xFFF5D271)],
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                  border: Border.all(
                    color: isHovered
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isHovered ? Color(0xFF005234) : Color(0xFFF0B513))
                          .withOpacity(0.3),
                      blurRadius: isHovered ? 15 : 8,
                      offset: Offset(0, isHovered ? 6 : 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                              media.thumbnail ?? '',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              media.category?.toUpperCase() ?? 'ENTERTAINMENT',
                              style: TextStyle(
                                fontSize: 10,
                                color: isHovered
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.black.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              media.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isHovered
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  (media.duration?.toString() ?? 'Live'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isHovered
                                        ? Colors.white.withOpacity(0.9)
                                        : Colors.black.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isHovered ? 0 : 1,
                        child: Image.asset(
                          'assets/images/logo/Logo-Maxg-Green.gif',
                          width: 60,
                          height: 60,
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isHovered ? 1 : 0,
                        child: Image.asset(
                          'assets/images/logo/Maxg-ent_white.gif',
                          width: 60,
                          height: 60,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThumbnailPreview() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Default state
            if (_hoveredMedia == null)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A2E),
                      Color(0xFF16213E),
                      Color(0xFF0F3460),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo/Maxg-ent_white.gif',
                        width: 200,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'MaxG Cinema',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Dynamic thumbnail
            if (_hoveredMedia != null)
              AnimatedBuilder(
                animation: _thumbnailAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _thumbnailOpacityAnimation.value,
                    child: Transform.scale(
                      scale: _thumbnailScaleAnimation.value,
                      child: Stack(
                        children: [
                          // Background image
                          Positioned.fill(
                            child: CachedNetworkImage(
                              imageUrl: _hoveredMedia!.thumbnail ?? '',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[900],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFF0B513),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[900],
                                child: Icon(
                                  Icons.movie_outlined,
                                  size: 64,
                                  color: Colors.white24,
                                ),
                              ),
                            ),
                          ),

                          // Gradient overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                    Colors.black.withOpacity(0.9),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Play button overlay
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),

                          // Bottom info
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _hoveredMedia!.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFF0B513),
                                          Color(0xFFF5D271),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getFileTypeFromUrl(
                                        _hoveredMedia!.fileUrl,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _handlePlayButton(_hoveredMedia!),
                                        icon: const Icon(
                                          Icons.play_arrow,
                                          size: 20,
                                        ),
                                        label: const Text('Play Now'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFFF0B513),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            _handleMediaTap(_hoveredMedia!),
                                        icon: const Icon(
                                          Icons.info_outline,
                                          size: 18,
                                        ),
                                        label: const Text('Details'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: BorderSide(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            width: 1.5,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
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
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.white),
            onPressed: _currentPage > 1
                ? () => _changePage(_currentPage - 1)
                : null,
          ),
          ...List.generate(totalPages > 5 ? 5 : totalPages, (index) {
            int pageNum;
            if (totalPages <= 5) {
              pageNum = index + 1;
            } else {
              int start = (_currentPage - 2).clamp(1, totalPages - 4);
              pageNum = start + index;
            }

            return GestureDetector(
              onTap: () => _changePage(pageNum),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: pageNum == _currentPage
                      ? LinearGradient(
                          colors: [Color(0xFFF0B513), Color(0xFFF5D271)],
                        )
                      : null,
                  color: pageNum == _currentPage
                      ? null
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: pageNum == _currentPage
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$pageNum',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: pageNum == _currentPage
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
          IconButton(
            icon: Icon(Icons.chevron_right, color: Colors.white),
            onPressed: _currentPage < totalPages
                ? () => _changePage(_currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  void _changePage(int newPage) {
    setState(() {
      _currentPage = newPage;
      _hoveredMedia = null;
    });
    _thumbnailAnimationController.reset();
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildTimeDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'NOW',
            style: TextStyle(
              color: Color(0xFFF0B513),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentTime ?? '00:00 AM',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 3, color: Color(0xFFF0B513)),
          const SizedBox(height: 16),
          Text(
            'Loading media content...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.cloud_off,
                color: Colors.orange,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Server Not Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Don\'t worry! Your downloaded movies are still available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _showOfflineOnly,
                  icon: const Icon(Icons.folder),
                  label: const Text('Show Offline'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _refreshMediaList,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0B513),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isOnlineMode ? Icons.library_music_outlined : Icons.folder_open,
              color: const Color(0xFFF0B513),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _isOnlineMode ? 'No Media Found' : 'No Offline Media',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isOnlineMode
                  ? 'Pull down to refresh and check for new content'
                  : 'Download some movies first when online',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _getFileTypeFromUrl(String url) {
    final extension = url.split('.').last.toUpperCase();
    switch (extension) {
      case 'MP4':
        return 'VIDEO • MP4';
      case 'AVI':
        return 'VIDEO • AVI';
      case 'MOV':
        return 'VIDEO • MOV';
      case 'MKV':
        return 'VIDEO • MKV';
      default:
        return 'VIDEO • MP4';
    }
  }

  Future<void> _handleMediaTap(MediaItem media) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(mediaItem: media),
      ),
    );
  }

  Future<void> _handlePlayButton(MediaItem media) async {
    try {
      final filename = media.localFileName;
      final isDownloaded = await StorageService.isMediaDownloaded(filename);

      if (isDownloaded) {
        _showSuccessMessage('Playing from device storage');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(mediaItem: media),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(mediaItem: media),
        ),
      );
    } catch (e) {
      _showErrorMessage('Failed to play media: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 16),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
