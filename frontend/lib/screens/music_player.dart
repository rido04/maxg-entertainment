// lib/screens/music_player.dart - Updated dengan ActivityTrackerWrapper
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/media_item.dart';
import '../services/music_service.dart';
import '../services/global_audio_service.dart';
import '../widgets/activity_tracker_wrapper.dart'; // Import wrapper

class MusicPlayer extends StatefulWidget {
  final MediaItem music;

  const MusicPlayer({super.key, required this.music});

  @override
  State<MusicPlayer> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayer>
    with TickerProviderStateMixin {
  final MusicService _musicService = MusicService();
  final GlobalAudioService _globalAudioService = GlobalAudioService();
  bool _isLoading = true;
  bool _isOfflineMode = false;
  late AnimationController _rotationController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Check if this music is already playing
      if (_globalAudioService.currentMusic?.id == widget.music.id) {
        // Music is already loaded in global service
        final localPath = await _musicService.getLocalMusicPath(widget.music);
        setState(() {
          _isOfflineMode = localPath != null;
          _isLoading = false;
        });
      } else {
        // Load new music in global service
        await _globalAudioService.playMusic(widget.music);
        final localPath = await _musicService.getLocalMusicPath(widget.music);
        setState(() {
          _isOfflineMode = localPath != null;
          _isLoading = false;
        });
      }

      // Listen to player state changes for rotation animation
      _globalAudioService.playerStateStream.listen((state) {
        if (mounted) {
          if (state.playing) {
            _rotationController.repeat();
          } else {
            _rotationController.stop();
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to load audio: $e',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF282828),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '$minutes:${twoDigits(seconds)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return ActivityTrackerWrapper(
      screenName:
          'MusicPlayer', // Music player tidak di-whitelist, jadi timer tetap berjalan
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1DB954).withOpacity(0.3),
                const Color(0xFF121212),
                const Color(0xFF000000),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Spacer(),
                      // Logo placeholder di header
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      // Online/Offline indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _isOfflineMode
                              ? const Color(0xFF1DB954).withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isOfflineMode
                                ? const Color(0xFF1DB954)
                                : Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isOfflineMode ? Icons.offline_pin : Icons.cloud,
                              size: 16,
                              color: _isOfflineMode
                                  ? const Color(0xFF1DB954)
                                  : Colors.blue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isOfflineMode ? 'Offline' : 'Online',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _isOfflineMode
                                    ? const Color(0xFF1DB954)
                                    : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1DB954),
                          ),
                        )
                      : AnimatedBuilder(
                          animation: _globalAudioService,
                          builder: (context, child) {
                            return isLandscape
                                ? _buildLandscapeLayout(isTablet)
                                : _buildPortraitLayout(isTablet);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
      child: Column(
        children: [
          const Spacer(),

          // Album Art
          _buildAlbumArt(isTablet ? 280 : 240),

          SizedBox(height: isTablet ? 48 : 40),

          // Music Info
          _buildMusicInfo(isTablet),

          SizedBox(height: isTablet ? 48 : 40),

          // Progress Bar
          _buildProgressBar(),

          SizedBox(height: isTablet ? 48 : 40),

          // Control Buttons
          _buildControlButtons(isTablet),

          SizedBox(height: isTablet ? 32 : 24),

          // Download Section
          _buildDownloadSection(),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
      child: Row(
        children: [
          // Left side - Album Art
          Expanded(
            flex: 1,
            child: Center(child: _buildAlbumArt(isTablet ? 200 : 160)),
          ),

          SizedBox(width: isTablet ? 48 : 32),

          // Right side - Controls
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMusicInfo(isTablet),
                SizedBox(height: isTablet ? 32 : 24),
                _buildProgressBar(),
                SizedBox(height: isTablet ? 32 : 24),
                _buildControlButtons(isTablet),
                SizedBox(height: isTablet ? 24 : 16),
                _buildDownloadSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(double size) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * 3.14159,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1DB954),
                  Color(0xFF1ED760),
                  Color(0xFF1DB954),
                ],
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.asset(
                  'assets/images/logo/Logo-MaxG-White.gif',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMusicInfo(bool isTablet) {
    return Column(
      children: [
        Text(
          widget.music.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 28 : 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          widget.music.artist ?? 'Unknown Artist',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.music.album != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.music.album!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: isTablet ? 16 : 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildProgressBar() {
    return StreamBuilder<Duration>(
      stream: _globalAudioService.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = _globalAudioService.duration ?? Duration.zero;

        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF1DB954),
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: const Color(0xFF1DB954),
                overlayColor: const Color(0xFF1DB954).withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                trackHeight: 4,
              ),
              child: Slider(
                value: duration.inMilliseconds > 0
                    ? position.inMilliseconds / duration.inMilliseconds
                    : 0.0,
                onChanged: (value) {
                  final newPosition = Duration(
                    milliseconds: (value * duration.inMilliseconds).round(),
                  );
                  _globalAudioService.seek(newPosition);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlButtons(bool isTablet) {
    return StreamBuilder<PlayerState>(
      stream: _globalAudioService.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final playing = state?.playing ?? false;

        if (state?.processingState == ProcessingState.loading ||
            state?.processingState == ProcessingState.buffering) {
          return const CircularProgressIndicator(color: Color(0xFF1DB954));
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                iconSize: isTablet ? 32 : 28,
                icon: const Icon(
                  Icons.skip_previous_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  _globalAudioService.seek(Duration.zero);
                },
              ),
            ),

            SizedBox(width: isTablet ? 32 : 24),

            // Play/Pause button
            GestureDetector(
              onTapDown: (_) => _scaleController.forward(),
              onTapUp: (_) => _scaleController.reverse(),
              onTapCancel: () => _scaleController.reverse(),
              child: AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 - (_scaleController.value * 0.1),
                    child: Container(
                      width: isTablet ? 80 : 70,
                      height: isTablet ? 80 : 70,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1DB954).withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        iconSize: isTablet ? 40 : 35,
                        color: Colors.white,
                        icon: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        onPressed: playing
                            ? _globalAudioService.pause
                            : _globalAudioService.play,
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(width: isTablet ? 32 : 24),

            // Next button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                iconSize: isTablet ? 32 : 28,
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                onPressed: () {
                  // Implement next track functionality if needed
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDownloadSection() {
    return FutureBuilder<bool>(
      future: _musicService.isMusicDownloaded(widget.music),
      builder: (context, snapshot) {
        final isDownloaded = snapshot.data ?? false;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDownloaded
                      ? const Color(0xFF1DB954).withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDownloaded
                      ? Icons.download_done_rounded
                      : Icons.cloud_download_outlined,
                  color: isDownloaded
                      ? const Color(0xFF1DB954)
                      : Colors.white.withOpacity(0.7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDownloaded ? 'Downloaded' : 'Not Downloaded',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDownloaded
                          ? 'Available for offline playback'
                          : 'Download for offline access',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isDownloaded)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Color(0xFF1DB954),
                    ),
                    onPressed: _downloadMusic,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _downloadMusic() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF282828),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF1DB954)),
              const SizedBox(height: 20),
              Text(
                'Downloading ${widget.music.title}...',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      final downloadDir = await _musicService.getDownloadDirectory();
      await _musicService.downloadMusicFile(widget.music, downloadDir);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF1DB954)),
              SizedBox(width: 12),
              Text(
                'Download completed!',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Color(0xFF282828),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {});
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Download failed: $e',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF282828),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
