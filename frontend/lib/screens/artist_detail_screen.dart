// lib/screens/artist_detail_screen.dart
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
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          // Enhanced Header with Artist Info
          SliverAppBar(
            expandedHeight: isLandscape ? 200 : 300,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () => _showOptionsMenu(context),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: FadeTransition(
                opacity: _fadeAnimation,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF1DB954).withOpacity(0.8),
                            const Color(0xFF1ED760).withOpacity(0.6),
                            const Color(0xFF121212),
                          ],
                          stops: const [0.0, 0.5, 1.0],
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Artist Image
                            Center(
                              child: Container(
                                width: isLandscape ? 120 : 150,
                                height: isLandscape ? 120 : 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
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
                                            ? Image.network(
                                                widget
                                                    .musicList
                                                    .first
                                                    .thumbnail!,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) =>
                                                        _buildArtistPlaceholder(
                                                          isTablet,
                                                        ),
                                              )
                                            : _buildArtistPlaceholder(isTablet))
                                      : _buildArtistPlaceholder(isTablet),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Artist Name
                            Text(
                              widget.artistName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 32 : 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Stats
                            Text(
                              '${widget.musicList.length} song${widget.musicList.length == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
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

          // Action Buttons
          SliverPersistentHeader(
            pinned: false,
            delegate: _ActionButtonsDelegate(
              child: Container(
                color: const Color(0xFF121212),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 24,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    // Play All Button
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1DB954).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () => _playAllSongs(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Play All',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Shuffle Button
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isShuffled
                            ? const Color(0xFF1DB954)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: () {
                            setState(() {
                              _isShuffled = !_isShuffled;
                            });
                            _playAllSongs(shuffle: _isShuffled);
                          },
                          child: Icon(
                            Icons.shuffle_rounded,
                            color: _isShuffled
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Songs List
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 24,
              vertical: 8,
            ),
            sliver: widget.musicList.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildListDelegate([
                      // Section Header
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Text(
                              'Songs',
                              style: TextStyle(
                                color: const Color(0xFF1DB954),
                                fontSize: isTablet ? 24 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${widget.musicList.length} songs',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Songs Container
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.musicList.length,
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.white.withOpacity(0.05),
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final music = widget.musicList[index];
                            return _buildSongListItem(
                              music,
                              index + 1,
                              isTablet,
                            );
                          },
                        ),
                      ),
                    ]),
                  ),
          ),
        ],
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
          decoration: BoxDecoration(
            color: isCurrentlyPlaying
                ? const Color(0xFF1DB954).withOpacity(0.1)
                : Colors.transparent,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: isTablet ? 12 : 8,
            ),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    index.toString(),
                    style: TextStyle(
                      color: isCurrentlyPlaying
                          ? const Color(0xFF1DB954)
                          : Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: isTablet ? 50 : 40,
                  height: isTablet ? 50 : 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        music.thumbnail != null && music.thumbnail!.isNotEmpty
                        ? Image.network(
                            music.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildThumbnailPlaceholder(music, isTablet),
                          )
                        : _buildThumbnailPlaceholder(music, isTablet),
                  ),
                ),
              ],
            ),
            title: Text(
              music.title,
              style: TextStyle(
                color: isCurrentlyPlaying
                    ? const Color(0xFF1DB954)
                    : Colors.white,
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: music.artist != null
                ? Text(
                    music.artist!,
                    style: TextStyle(
                      color: isCurrentlyPlaying
                          ? const Color(0xFF1DB954).withOpacity(0.8)
                          : Colors.white.withOpacity(0.7),
                      fontSize: isTablet ? 14 : 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!(_downloadStatus[music.id] ?? false)) ...[
                  IconButton(
                    icon: Icon(
                      Icons.download_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: isTablet ? 20 : 18,
                    ),
                    onPressed: () => _downloadMusic(music),
                  ),
                ],
                Text(
                  music.duration != null
                      ? _formatDuration(music.duration!)
                      : '3:45',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isTablet ? 12 : 11,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isCurrentlyPlaying && isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: isTablet ? 20 : 18,
                    ),
                    onPressed: () => _playMusic(music),
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MusicPlayer(music: music),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: const Offset(0.0, 1.0),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeInOut)),
                          ),
                          child: child,
                        );
                      },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.music_note_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No songs found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This artist doesn\'t have any songs yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
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
          colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
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
          colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
        ),
      ),
      child: Center(
        child: Text(
          music.title.isNotEmpty ? music.title[0].toUpperCase() : 'M',
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 20 : 16,
            fontWeight: FontWeight.bold,
          ),
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
      // Here you could add logic to set up a playlist queue
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to play songs: $e');
    }
  }

  Future<void> _downloadMusic(MediaItem music) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF282828),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1DB954),
                    strokeWidth: 3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Downloading',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                music.title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );

      final downloadDir = await _musicService.getDownloadDirectory();
      await _musicService.downloadMusicFile(music, downloadDir);

      setState(() {
        _downloadStatus[music.id] = true;
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Download completed!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      music.title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF282828),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorSnackBar(context, 'Failed to download: $e');
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF282828),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.download_rounded, color: Colors.white),
              title: const Text(
                'Download All',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _downloadAllSongs();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded, color: Colors.white),
              title: const Text(
                'Share Artist',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAllSongs() async {
    // Implement download all functionality
    for (final music in widget.musicList) {
      if (!(_downloadStatus[music.id] ?? false)) {
        await _downloadMusic(music);
      }
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
        backgroundColor: const Color(0xFF282828),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class _ActionButtonsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _ActionButtonsDelegate({required this.child});

  @override
  double get minExtent => 96;

  @override
  double get maxExtent => 96;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
