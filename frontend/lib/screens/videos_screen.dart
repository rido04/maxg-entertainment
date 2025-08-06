import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/media_item.dart';
import '../services/storage_service.dart'; // Update import
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
  late AnimationController _hoverAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _thumbnailFadeAnimation;
  late Animation<double> _thumbnailScaleAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isRefreshing = false;
  bool _isAutoDownloading = false;
  bool _isOnlineMode = false; // Track connection status
  MediaItem? _hoveredMedia;
  String? _currentTime;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _updateTime();
    _initializeAnimations();
    _checkConnectionStatus();

    // Update time every second
    Stream.periodic(const Duration(seconds: 1)).listen((_) => _updateTime());
  }

  void _initializeData() {
    // Offline-first: prioritize cached data
    mediaList = ApiService.fetchMediaList();
    _startAutoDownload();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _thumbnailAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _hoverAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _thumbnailFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _thumbnailAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _thumbnailScaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(
        parent: _thumbnailAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-0.02, 0)).animate(
          CurvedAnimation(
            parent: _hoverAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  Future<void> _checkConnectionStatus() async {
    final isOnline = await ApiService.checkServerConnection();
    if (mounted) {
      setState(() {
        _isOnlineMode = isOnline;
      });
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    final timeString =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
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
    _hoverAnimationController.dispose();
    super.dispose();
  }

  void _onMovieHover(MediaItem? media, bool isEntering) {
    if (_hoveredMedia != media) {
      setState(() {
        _hoveredMedia = media;
      });

      if (media != null && isEntering) {
        _thumbnailAnimationController.forward();
        _hoverAnimationController.forward();
      } else {
        _thumbnailAnimationController.reverse();
        _hoverAnimationController.reverse();
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
      // Force refresh from server
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

  // Tampilkan hanya video yang offline
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
      backgroundColor: const Color(0xFF1A1A2E),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverFillRemaining(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: _refreshMediaList,
                color: const Color(0xFF00B14F),
                child: FutureBuilder<List<MediaItem>>(
                  future: mediaList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingState();
                    }

                    if (snapshot.hasError) {
                      return _buildErrorState(snapshot.error.toString());
                    }

                    if (snapshot.hasData) {
                      final items = snapshot.data!;
                      final videoItems = StorageService.filterVideoFiles(items);

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
      floatingActionButton: _buildTimeDisplay(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF00B14F),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00B14F), Color(0xFF009940)],
          ),
        ),
        child: FlexibleSpaceBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  'assets/images/logo/Maxg-ent_white.gif',
                  width: 60,
                  height: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              // Connection status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isOnlineMode
                      ? Colors.green.withOpacity(0.8)
                      : Colors.orange.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isOnlineMode ? Icons.cloud_done : Icons.cloud_off,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isOnlineMode ? 'Online' : 'Offline',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
      ),
      actions: [
        // Offline mode toggle
        IconButton(
          icon: Icon(_isOnlineMode ? Icons.cloud_download : Icons.folder),
          tooltip: _isOnlineMode ? 'Show All' : 'Show Offline Only',
          onPressed: _isOnlineMode ? null : _showOfflineOnly,
        ),

        // Search button
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VideoSearchScreen(),
              ),
            );
          },
        ),

        if (_isAutoDownloading)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Downloading...',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),

        // IconButton(
        //   icon: _isRefreshing
        //       ? const SizedBox(
        //           width: 20,
        //           height: 20,
        //           child: CircularProgressIndicator(
        //             strokeWidth: 2,
        //             color: Colors.white,
        //           ),
        //         )
        //       : const Icon(Icons.refresh),
        //   onPressed: _isRefreshing || _isAutoDownloading
        //       ? null
        //       : _refreshMediaList,
        // ),
        // const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMainContent(List<MediaItem> videoItems) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E).withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildMovieList(videoItems)),
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: _buildDynamicThumbnail()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00B14F), Color(0xFF009940)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _isOnlineMode
                    ? 'Biar ga bosen di jalan, yuk nonton film seru!'
                    : 'Nikmati film offline tanpa khawatir koneksi!',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF00B14F),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _isOnlineMode ? 'List semua film' : 'Film offline tersedia',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // [Rest of the build methods remain the same as original...]
  // Update method _buildMovieList untuk support mobile
  Widget _buildMovieList(List<MediaItem> videoItems) {
    return Container(
      height: 400,
      child: ListView.builder(
        itemCount: videoItems.length,
        itemBuilder: (context, index) {
          final media = videoItems[index];
          final isHovered = _hoveredMedia == media;

          // Check if this media is downloaded
          return FutureBuilder<bool>(
            future: StorageService.isMediaDownloaded(media.localFileName),
            builder: (context, downloadSnapshot) {
              final isDownloaded = downloadSnapshot.data ?? false;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  // Mobile gestures
                  onTap: () => _handleMediaTap(media),
                  onLongPress: () => _onMovieHover(media, true),
                  onTapDown: (_) => _onMovieHover(media, true),
                  onTapUp: (_) {
                    // Delay untuk menunjukkan thumbnail sejenak
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      if (mounted) _onMovieHover(null, false);
                    });
                  },
                  onTapCancel: () => _onMovieHover(null, false),

                  // Desktop hover (tetap untuk desktop compatibility)
                  child: MouseRegion(
                    onEnter: (_) => _onMovieHover(media, true),
                    onExit: (_) => _onMovieHover(null, false),
                    child: AnimatedBuilder(
                      animation: _hoverAnimationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: isHovered
                              ? _slideAnimation.value *
                                    MediaQuery.of(context).size.width
                              : Offset.zero,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isHovered
                                    ? [
                                        const Color(0xFF00E863),
                                        const Color(0xFF00B14F),
                                        const Color(0xFF007A37),
                                      ]
                                    : [
                                        const Color(0xFF1E3A5F),
                                        const Color(0xFF2D5A87),
                                        const Color(0xFF3B6FA5),
                                      ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isHovered
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF00B14F,
                                        ).withOpacity(0.6),
                                        blurRadius: 30,
                                        spreadRadius: 4,
                                        offset: const Offset(-3, 6),
                                      ),
                                      BoxShadow(
                                        color: const Color(
                                          0xFF00E863,
                                        ).withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 1,
                                        offset: const Offset(2, -2),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 6,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isHovered
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.1),
                                  width: 1.5,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => _handleMediaTap(media),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        // Movie icon with download indicator
                                        Stack(
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              width: 58,
                                              height: 58,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: isHovered
                                                      ? [
                                                          Colors.white
                                                              .withOpacity(0.4),
                                                          Colors.white
                                                              .withOpacity(0.2),
                                                          Colors.white
                                                              .withOpacity(0.1),
                                                        ]
                                                      : [
                                                          Colors.white
                                                              .withOpacity(0.3),
                                                          Colors.white
                                                              .withOpacity(
                                                                0.15,
                                                              ),
                                                          Colors.white
                                                              .withOpacity(
                                                                0.08,
                                                              ),
                                                        ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.25),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.movie_filter_outlined,
                                                color: Colors.white,
                                                size: isHovered ? 30 : 28,
                                              ),
                                            ),
                                            // Download indicator
                                            if (isDownloaded)
                                              Positioned(
                                                right: -2,
                                                top: -2,
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.download_done,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 18),
                                        // Movie info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                media.title,
                                                style: TextStyle(
                                                  fontSize: isHovered ? 17 : 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                  letterSpacing: 0.3,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black
                                                          .withOpacity(0.3),
                                                      offset: const Offset(
                                                        1,
                                                        1,
                                                      ),
                                                      blurRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  AnimatedContainer(
                                                    duration: const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: isHovered
                                                            ? [
                                                                const Color(
                                                                  0xFF00B14F,
                                                                ).withOpacity(
                                                                  0.8,
                                                                ),
                                                                const Color(
                                                                  0xFF007A37,
                                                                ).withOpacity(
                                                                  0.8,
                                                                ),
                                                              ]
                                                            : [
                                                                Colors.white
                                                                    .withOpacity(
                                                                      0.2,
                                                                    ),
                                                                Colors.white
                                                                    .withOpacity(
                                                                      0.1,
                                                                    ),
                                                              ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.2),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      _getFileTypeFromUrl(
                                                        media.fileUrl,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white
                                                            .withOpacity(0.95),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // Offline indicator
                                                  if (isDownloaded)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green
                                                            .withOpacity(0.8),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: const Text(
                                                        'OFFLINE',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Play button
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: isHovered
                                                  ? [
                                                      const Color(0xFF00E863),
                                                      const Color(0xFF00B14F),
                                                      const Color(0xFF007A37),
                                                    ]
                                                  : [
                                                      Colors.white.withOpacity(
                                                        0.25,
                                                      ),
                                                      Colors.white.withOpacity(
                                                        0.15,
                                                      ),
                                                      Colors.white.withOpacity(
                                                        0.08,
                                                      ),
                                                    ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              28,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                              width: 1.5,
                                            ),
                                            boxShadow: isHovered
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFF00B14F,
                                                      ).withOpacity(0.4),
                                                      blurRadius: 12,
                                                      spreadRadius: 2,
                                                      offset: const Offset(
                                                        0,
                                                        3,
                                                      ),
                                                    ),
                                                  ]
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 6,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.play_circle_filled,
                                              color: isHovered
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(
                                                      0.9,
                                                    ),
                                              size: isHovered ? 32 : 30,
                                            ),
                                            onPressed: () =>
                                                _handlePlayButton(media),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDynamicThumbnail() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              // Default background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1A2E).withOpacity(0.95),
                      const Color(0xFF16213E).withOpacity(0.95),
                      const Color(0xFF0F3460).withOpacity(0.9),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: BackgroundPatternPainter()),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF00B14F).withOpacity(0.2),
                                  const Color(0xFF009940).withOpacity(0.1),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0xFF00B14F).withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _isOnlineMode
                                  ? Icons.movie_creation_outlined
                                  : Icons.folder_open,
                              size: 48,
                              color: Colors.white30,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'MaxG Cinema',
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isOnlineMode
                                ? 'Hover over a movie to preview'
                                : 'Offline movies ready to watch',
                            style: const TextStyle(
                              color: Colors.white24,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Dynamic thumbnail
              if (_hoveredMedia != null)
                AnimatedBuilder(
                  animation: _thumbnailAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _thumbnailScaleAnimation.value,
                      child: Opacity(
                        opacity: _thumbnailFadeAnimation.value,
                        child: _buildThumbnailContent(_hoveredMedia!),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailContent(MediaItem media) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87, Colors.black],
          stops: [0.4, 0.8, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: media.thumbnail ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E),
                      const Color(0xFF0F3460),
                    ],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00B14F),
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    colors: [
                      const Color(0xFF00B14F).withOpacity(0.1),
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.movie_outlined,
                    size: 64,
                    color: Colors.white24,
                  ),
                ),
              ),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.overlay,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    media.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00B14F), Color(0xFF009940)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getFileTypeFromUrl(media.fileUrl),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Offline status
                      FutureBuilder<bool>(
                        future: StorageService.isMediaDownloaded(
                          media
                              .localFileName, // Menggunakan getter localFileName
                        ),
                        builder: (context, snapshot) {
                          final isDownloaded = snapshot.data ?? false;
                          if (isDownloaded) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'OFFLINE READY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _handlePlayButton(media),
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Play Now',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B14F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFF00B14F).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => _handleMediaTap(media),
                        icon: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Details',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.8),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
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
          ),
          // Play button overlay
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.1),
          ],
        ),
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
            _isOnlineMode ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              color: _isOnlineMode ? const Color(0xFF00B14F) : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentTime ?? '00:00',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF00B14F)),
          SizedBox(height: 16),
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
                    backgroundColor: const Color(0xFF00B14F),
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
              color: const Color(0xFF00B14F),
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
      case 'WMV':
        return 'VIDEO • WMV';
      case 'FLV':
        return 'VIDEO • FLV';
      case 'WEBM':
        return 'VIDEO • WEBM';
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
        // Jika tidak ada offline, navigasi ke detail untuk download
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

// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1;

    final spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
