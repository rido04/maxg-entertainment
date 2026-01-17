// lib/screens/artist_detail_screen.dart - Updated with Blade template styling
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/music_service.dart';
import '../services/global_audio_service.dart';
import '../screens/music_player.dart';

class ArtistDetailScreen extends StatefulWidget {
  final String artistName;
  final List<MediaItem> musicList;

  const ArtistDetailScreen({
    super.key,
    required this.artistName,
    required this.musicList,
  });

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen>
    with SingleTickerProviderStateMixin {
  final MusicService _musicService = MusicService();
  final GlobalAudioService _globalAudioService = GlobalAudioService();
  Map<int, bool> _downloadStatus = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isShuffled = false;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _checkDownloadStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkDownloadStatus() async {
    for (final music in widget.musicList) {
      final isDownloaded = await _musicService.isMusicDownloaded(music);
      setState(() {
        _downloadStatus[music.id] = isDownloaded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final displayedSongs = _showAll
        ? widget.musicList
        : widget.musicList.take(5).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background/Background_Color.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Hero Section with Gradient Background
            SliverAppBar(
              expandedHeight: isLandscape ? 200 : 300,
              floating: false,
              pinned: false,
              backgroundColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200]?.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.grey[200]),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradient Background
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF22C55E).withOpacity(0.4),
                              const Color(0xFF16A34A).withOpacity(0.3),
                              const Color(0xFF064E3B).withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                      // Artist Info
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 32 : 24,
                            vertical: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Artist Image
                              Container(
                                width: isLandscape ? 160 : 200,
                                height: isLandscape ? 160 : 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFD97706),
                                      Color(0xFFF59E0B),
                                      Color(0xFF1F2937),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF3B82F6,
                                    ).withOpacity(0.3),
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: widget.musicList.isNotEmpty
                                      ? (widget.musicList.first.thumbnail !=
                                                    null &&
                                                widget
                                                    .musicList
                                                    .first
                                                    .thumbnail!
                                                    .isNotEmpty
                                            ? _buildThumbnailImage(
                                                widget
                                                    .musicList
                                                    .first
                                                    .thumbnail!,
                                                isTablet,
                                              )
                                            : _buildArtistPlaceholder(isTablet))
                                      : _buildArtistPlaceholder(isTablet),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Verified Badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    color: Color(0xFF14B8A6),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'VERIFIED ARTIST',
                                    style: TextStyle(
                                      color: const Color(0xFF14B8A6),
                                      fontSize: isTablet ? 14 : 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Artist Name
                              Text(
                                widget.artistName,
                                style: TextStyle(
                                  fontSize: isTablet ? 48 : 36,
                                  fontWeight: FontWeight.w900,
                                  foreground: Paint()
                                    ..shader =
                                        const LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Color(0xFFBFDBFE),
                                            Color(0xFFD1D5DB),
                                          ],
                                        ).createShader(
                                          const Rect.fromLTWH(0, 0, 200, 70),
                                        ),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              // Song Count
                              Text(
                                '${widget.musicList.length} song${widget.musicList.length == 1 ? '' : 's'}',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 24,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    // Play All Button
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => _playAllSongs(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Play All',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Shuffle Button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isShuffled
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF6B7280),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            setState(() {
                              _isShuffled = !_isShuffled;
                            });
                            _playAllSongs(shuffle: _isShuffled);
                          },
                          child: const Icon(
                            Icons.shuffle_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Songs List Section
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
              sliver: widget.musicList.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState())
                  : SliverList(
                      delegate: SliverChildListDelegate([
                        // Section Header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Popular',
                            style: TextStyle(
                              color: const Color(0xFF1F2937),
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Songs List
                        ...displayedSongs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final music = entry.value;
                          return _buildSongListItem(music, index + 1, isTablet);
                        }).toList(),
                        // Show More Button
                        if (widget.musicList.length > 5)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showAll = !_showAll;
                                  });
                                },
                                child: Text(
                                  _showAll
                                      ? 'SHOW LESS'
                                      : 'SHOW ${widget.musicList.length - 5} MORE SONGS',
                                  style: TextStyle(
                                    color: const Color(0xFF6B7280),
                                    fontSize: isTablet ? 14 : 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 100),
                      ]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongListItem(MediaItem music, int index, bool isTablet) {
    return AnimatedBuilder(
      animation: _globalAudioService,
      builder: (context, child) {
        final isCurrentlyPlaying =
            _globalAudioService.currentMusic?.id == music.id;
        final isPlaying =
            _globalAudioService.player.playing && isCurrentlyPlaying;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isCurrentlyPlaying
                ? const Color(0xFF1F2937).withOpacity(0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _playMusic(music),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 12 : 8,
                ),
                child: Row(
                  children: [
                    // Track Number / Play Icon
                    SizedBox(
                      width: 40,
                      child: isCurrentlyPlaying && isPlaying
                          ? _buildPlayingIndicator()
                          : Text(
                              index.toString(),
                              style: TextStyle(
                                color: const Color(0xFF6B7280),
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                    const SizedBox(width: 12),
                    // Thumbnail
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1F2937)],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child:
                            music.thumbnail != null &&
                                music.thumbnail!.isNotEmpty
                            ? _buildThumbnailImage(music.thumbnail!, isTablet)
                            : _buildThumbnailPlaceholder(music, isTablet),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Song Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            music.title,
                            style: TextStyle(
                              color: isCurrentlyPlaying
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (music.album != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              music.album!,
                              style: TextStyle(
                                color: const Color(0xFF6B7280),
                                fontSize: isTablet ? 14 : 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        MusicPlayer(music: music),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return SlideTransition(
                                        position: animation.drive(
                                          Tween(
                                            begin: const Offset(0.0, 1.0),
                                            end: Offset.zero,
                                          ).chain(
                                            CurveTween(curve: Curves.easeInOut),
                                          ),
                                        ),
                                        child: child,
                                      );
                                    },
                              ),
                            );
                          },
                          child: Text(
                            'DETAIL',
                            style: TextStyle(
                              color: const Color(0xFF1F2937),
                              fontSize: isTablet ? 12 : 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          music.duration != null
                              ? _formatDuration(music.duration!)
                              : '3:45',
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPlayingBar(0),
        const SizedBox(width: 2),
        _buildPlayingBar(200),
        const SizedBox(width: 2),
        _buildPlayingBar(400),
      ],
    );
  }

  Widget _buildPlayingBar(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Container(
          width: 3,
          height: 4 + (value * 12),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }

  Widget _buildThumbnailImage(String thumbnailPath, bool isTablet) {
    if (thumbnailPath.startsWith('/')) {
      return Image.file(
        File(thumbnailPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildArtistPlaceholder(isTablet),
      );
    } else {
      return Image.network(
        thumbnailPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildArtistPlaceholder(isTablet),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF6B7280),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: Color(0xFF9CA3AF),
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No songs found',
            style: TextStyle(
              color: const Color(0xFF1F2937),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This artist doesn\'t have any songs yet.',
            style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildArtistPlaceholder(bool isTablet) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
        ),
      ),
      child: Center(
        child: Text(
          widget.artistName.isNotEmpty
              ? widget.artistName[0].toUpperCase()
              : 'A',
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 60 : 50,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder(MediaItem music, bool isTablet) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1F2937)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: const Color(0xFF60A5FA),
          size: isTablet ? 24 : 20,
        ),
      ),
    );
  }

  Future<void> _playMusic(MediaItem music) async {
    try {
      final isCurrentlyPlaying =
          _globalAudioService.currentMusic?.id == music.id;
      final isPlaying =
          _globalAudioService.player.playing && isCurrentlyPlaying;

      if (isCurrentlyPlaying) {
        if (isPlaying) {
          await _globalAudioService.pause();
        } else {
          await _globalAudioService.play();
        }
      } else {
        await _globalAudioService.playMusic(music);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to play: $e');
    }
  }

  Future<void> _playAllSongs({bool shuffle = false}) async {
    if (widget.musicList.isEmpty) return;

    try {
      List<MediaItem> playlist = List.from(widget.musicList);
      if (shuffle) {
        playlist.shuffle();
      }

      await _globalAudioService.playMusic(playlist.first);
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to play songs: $e');
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
