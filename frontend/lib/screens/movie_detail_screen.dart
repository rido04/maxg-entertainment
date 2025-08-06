import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import '../models/media_item.dart';
import '../services/storage_service.dart';
import 'videos_player_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final MediaItem mediaItem;

  const MovieDetailScreen({super.key, required this.mediaItem});

  @override
  State<MovieDetailScreen> createState() => _BladeStyleMovieDetailScreenState();
}

class _BladeStyleMovieDetailScreenState extends State<MovieDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  bool _isDownloaded = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkDownloadStatus();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  Future<void> _checkDownloadStatus() async {
    final isDownloaded = await StorageService.isMediaDownloaded(
      widget.mediaItem.localFileName,
    );
    setState(() {
      _isDownloaded = isDownloaded;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Gradient Overlay
          _buildBackground(),

          // Animated Background Elements
          _buildAnimatedBackgroundElements(),

          // Logo
          _buildLogo(),

          // Main Content
          _buildMainContent(),

          // Time Display
          _buildTimeDisplay(),

          // Back Button
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background/Background_Color.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.blue.shade900.withOpacity(0.2),
                Colors.grey.shade800.withOpacity(0.1),
                Colors.grey.shade900.withOpacity(0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackgroundElements() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Top Right Circle
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Positioned(
                top: -160 + (_pulseAnimation.value * 20),
                right: -160 + (_pulseAnimation.value * 20),
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade500.withOpacity(
                      0.1 * _pulseAnimation.value,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.shade400.withOpacity(
                        0.05 * _pulseAnimation.value,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Bottom Left Circle
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: -160 + (_pulseAnimation.value * 15),
                left: -160 + (_pulseAnimation.value * 15),
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade500.withOpacity(
                      0.1 * _pulseAnimation.value,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade400.withOpacity(
                        0.05 * _pulseAnimation.value,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Center Circle
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height / 2 - 144,
                left: MediaQuery.of(context).size.width / 2 - 144,
                child: Container(
                  width: 288,
                  height: 288,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple.shade500.withOpacity(
                      0.05 * _pulseAnimation.value,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      right: 16,
      child: Container(
        width: 160,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/logo/Maxg-ent_white.gif',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Positioned.fill(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Row(
            children: [
              // Poster Section (Left 1/3)
              Expanded(
                flex: 1,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildPosterSection(),
                ),
              ),

              // Content Section (Right 2/3)
              Expanded(
                flex: 2,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: _buildContentSection(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosterSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: widget.mediaItem.thumbnail != null
                ? CachedNetworkImage(
                    imageUrl: widget.mediaItem.thumbnail!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFF16213E),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.teal,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: const BoxDecoration(
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
                      child: const Center(
                        child: Icon(
                          Icons.movie_outlined,
                          size: 64,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
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
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.movie_outlined,
                            size: 64,
                            color: Colors.white24,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No Thumbnail',
                            style: TextStyle(
                              color: Colors.white54,
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
    );
  }

  Widget _buildContentSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge
          if (widget.mediaItem.category != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Text(
                widget.mediaItem.category!.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Title
          Text(
            widget.mediaItem.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          // Info Tags Row
          _buildInfoTags(),

          const SizedBox(height: 20),

          // Star Rating
          _buildStarRating(),

          const SizedBox(height: 24),

          // Synopsis Box
          _buildSynopsisBox(),

          const SizedBox(height: 24),

          // Cast & Crew Section
          _buildCastCrewSection(),

          const SizedBox(height: 32),

          // Action Buttons
          _buildActionButtons(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoTags() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        // IMDb Rating Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade700,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'IMDb',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.mediaItem.rating ?? 'N/A'}/10',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Duration Tag
        if (widget.mediaItem.duration != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${widget.mediaItem.duration} Min',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // Download Status
        if (_isDownloaded)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download_done, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  'OFFLINE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStarRating() {
    final rating = widget.mediaItem.numericRating;
    final starRating = rating > 0 ? (rating / 2) : 0; // Convert 0-10 to 0-5
    final fullStars = starRating.floor();
    final hasHalfStar = (starRating - fullStars) >= 0.5;

    return Row(
      children: [
        // Stars
        Row(
          children: List.generate(5, (index) {
            if (index < fullStars) {
              return const Icon(Icons.star, color: Colors.yellow, size: 20);
            } else if (index == fullStars && hasHalfStar) {
              return const Icon(
                Icons.star_half,
                color: Colors.yellow,
                size: 20,
              );
            } else {
              return const Icon(
                Icons.star_border,
                color: Colors.grey,
                size: 20,
              );
            }
          }),
        ),

        const SizedBox(width: 12),

        // Rating Text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.mediaItem.formattedStarRating,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.mediaItem.numericRating > 0)
              Text(
                widget.mediaItem.formattedRating.replaceAll('/10', '/10 TMDb'),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSynopsisBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Synopsis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.mediaItem.description ??
                'No description available for this movie. Please contact support for more information.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastCrewSection() {
    return Column(
      children: [
        Row(
          children: [
            // Cast Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cast',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.mediaItem.cast ??
                          'Cast information will be updated soon.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Director Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Director',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.mediaItem.director ??
                          'Director information will be updated soon.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),

                    if (widget.mediaItem.writers != null) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Writers',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.mediaItem.writers!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Play Button
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _handlePlayMovie,
            icon: const Icon(Icons.play_arrow, size: 24, color: Colors.white),
            label: const Text(
              'Play Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 8,
              shadowColor: Colors.teal.shade600.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Download Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isDownloading ? null : _handleDownload,
            icon: _isDownloading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    _isDownloaded ? Icons.download_done : Icons.download,
                    size: 20,
                    color: _isDownloaded ? Colors.green : Colors.white,
                  ),
            label: Text(
              _isDownloading
                  ? 'Downloading...'
                  : _isDownloaded
                  ? 'Downloaded'
                  : 'Download',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _isDownloaded ? Colors.green : Colors.white,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _isDownloaded
                    ? Colors.green
                    : Colors.white.withOpacity(0.8),
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDisplay() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CURRENT TIME',
              style: TextStyle(
                color: Colors.teal,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                final now = DateTime.now();
                return Text(
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                final now = DateTime.now();
                final weekdays = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun',
                ];
                return Text(
                  '${weekdays[now.weekday - 1]} ${now.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePlayMovie() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(mediaItem: widget.mediaItem),
      ),
    );
  }

  Future<void> _handleDownload() async {
    if (_isDownloaded || _isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      await StorageService.downloadMedia(
        widget.mediaItem.downloadUrl,
        widget.mediaItem.localFileName,
      );

      setState(() {
        _isDownloaded = true;
        _isDownloading = false;
      });

      _showSuccessMessage('Movie downloaded successfully!');
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      _showErrorMessage('Download failed: $e');
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
