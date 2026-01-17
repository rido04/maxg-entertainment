// lib/screens/music_player.dart - Updated with Blade template styling
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/media_item.dart';
import '../services/music_service.dart';
import '../services/global_audio_service.dart';
import '../widgets/activity_tracker_wrapper.dart';

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
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (_globalAudioService.currentMusic?.id == widget.music.id) {
        final localPath = await _musicService.getLocalMusicPath(widget.music);
        setState(() {
          _isOfflineMode = localPath != null;
          _isLoading = false;
        });
      } else {
        await _globalAudioService.playMusic(widget.music);
        final localPath = await _musicService.getLocalMusicPath(widget.music);
        setState(() {
          _isOfflineMode = localPath != null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load audio: $e');
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
      screenName: 'MusicPlayer',
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/background/Background_Color.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Main Content
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200]?.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey[200],
                size: 28,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF22C55E),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading...',
            style: TextStyle(
              color: Colors.grey[200],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Album Art
          _buildAlbumArt(isTablet ? 280 : 240),

          SizedBox(height: isTablet ? 48 : 40),

          // Music Info
          _buildMusicInfo(isTablet),

          SizedBox(height: isTablet ? 32 : 24),

          // Control Buttons Row
          _buildControlButtonsRow(isTablet),

          SizedBox(height: isTablet ? 32 : 24),

          // Volume Control
          _buildVolumeControl(),

          SizedBox(height: isTablet ? 32 : 24),

          // Progress Bar
          _buildProgressBar(),

          SizedBox(height: isTablet ? 48 : 40),

          // Main Play Button
          _buildMainPlayButton(isTablet),

          const SizedBox(height: 40),

          // Song Details
          if (widget.music.description != null) ...[
            _buildSongDetails(isTablet),
            const SizedBox(height: 24),
          ],

          // Download Section
          _buildDownloadSection(),
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMusicInfo(isTablet),
                  SizedBox(height: isTablet ? 24 : 16),
                  _buildControlButtonsRow(isTablet),
                  SizedBox(height: isTablet ? 24 : 16),
                  _buildVolumeControl(),
                  SizedBox(height: isTablet ? 24 : 16),
                  _buildProgressBar(),
                  SizedBox(height: isTablet ? 24 : 16),
                  _buildMainPlayButton(isTablet),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A), Color(0xFF22C55E)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child:
            widget.music.thumbnail != null && widget.music.thumbnail!.isNotEmpty
            ? Image.network(
                widget.music.thumbnail!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildAlbumPlaceholder(),
              )
            : _buildAlbumPlaceholder(),
      ),
    );
  }

  Widget _buildAlbumPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFFD97706)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note_rounded, color: Colors.white, size: 80),
      ),
    );
  }

  Widget _buildMusicInfo(bool isTablet) {
    return Column(
      children: [
        // Song Type Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SONG',
                style: TextStyle(
                  color: Colors.grey[200]?.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Title
        Text(
          widget.music.title,
          style: TextStyle(
            color: Colors.grey[100],
            fontSize: isTablet ? 32 : 28,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        // Artist & Album
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.music.artist != null) ...[
              Text(
                widget.music.artist!,
                style: TextStyle(
                  color: Colors.grey[200]?.withOpacity(0.9),
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (widget.music.album != null) ...[
              Text(
                ' • ',
                style: TextStyle(
                  color: Colors.grey[200]?.withOpacity(0.7),
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              Text(
                widget.music.album!,
                style: TextStyle(
                  color: Colors.grey[200]?.withOpacity(0.7),
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ],
          ],
        ),
        if (widget.music.duration != null) ...[
          const SizedBox(height: 8),
          Text(
            _formatDuration(Duration(seconds: widget.music.duration!)),
            style: TextStyle(
              color: Colors.grey[200]?.withOpacity(0.7),
              fontSize: isTablet ? 14 : 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildControlButtonsRow(bool isTablet) {
    return StreamBuilder<PlayerState>(
      stream: _globalAudioService.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final playing = state?.playing ?? false;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous button
            Container(
              width: isTablet ? 48 : 40,
              height: isTablet ? 48 : 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                iconSize: isTablet ? 24 : 20,
                icon: const Icon(
                  Icons.skip_previous_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  _globalAudioService.seek(Duration.zero);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVolumeControl() {
    return Row(
      children: [
        Icon(Icons.volume_up, color: Colors.grey[200], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF22C55E),
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: const Color(0xFF22C55E),
              overlayColor: const Color(0xFF22C55E).withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 6,
                elevation: 0,
              ),
              trackHeight: 4,
            ),
            child: Slider(
              value: _globalAudioService.player.volume,
              onChanged: (value) {
                _globalAudioService.player.setVolume(value);
              },
            ),
          ),
        ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyle(color: Colors.grey[200], fontSize: 12),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(color: Colors.grey[200], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  width: duration.inMilliseconds > 0
                      ? MediaQuery.of(context).size.width *
                            (position.inMilliseconds / duration.inMilliseconds)
                      : 0,
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainPlayButton(bool isTablet) {
    return StreamBuilder<PlayerState>(
      stream: _globalAudioService.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final playing = state?.playing ?? false;

        if (state?.processingState == ProcessingState.loading ||
            state?.processingState == ProcessingState.buffering) {
          return const CircularProgressIndicator(color: Color(0xFF22C55E));
        }

        return GestureDetector(
          onTap: playing ? _globalAudioService.pause : _globalAudioService.play,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse ring
                  if (playing)
                    Container(
                      width:
                          (isTablet ? 80 : 70) *
                          (1 + _pulseController.value * 0.2),
                      height:
                          (isTablet ? 80 : 70) *
                          (1 + _pulseController.value * 0.2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(
                            0xFF22C55E,
                          ).withOpacity(1 - _pulseController.value),
                          width: 2,
                        ),
                      ),
                    ),
                  // Main button
                  Container(
                    width: isTablet ? 80 : 70,
                    height: isTablet ? 80 : 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22C55E), Color(0xFFD97706)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: isTablet ? 40 : 35,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSongDetails(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About This Song',
            style: TextStyle(
              color: const Color(0xFF1F2937),
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.music.description!,
            style: TextStyle(
              color: const Color(0xFF374151),
              fontSize: isTablet ? 16 : 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadSection() {
    return FutureBuilder<bool>(
      future: _musicService.isMusicDownloaded(widget.music),
      builder: (context, snapshot) {
        final isDownloaded = snapshot.data ?? false;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDownloaded
                      ? const Color(0xFF22C55E).withOpacity(0.2)
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDownloaded
                      ? Icons.download_done_rounded
                      : Icons.cloud_download_outlined,
                  color: isDownloaded
                      ? const Color(0xFF22C55E)
                      : const Color(0xFF6B7280),
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
                        color: Color(0xFF1F2937),
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
                        color: const Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isDownloaded)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Color(0xFF22C55E),
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF22C55E)),
              const SizedBox(height: 20),
              Text(
                'Downloading ${widget.music.title}...',
                style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
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
              Icon(Icons.check_circle, color: Color(0xFF22C55E)),
              SizedBox(width: 12),
              Text(
                'Download completed!',
                style: TextStyle(color: Color(0xFF1F2937)),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {});
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorSnackBar('Download failed: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Color(0xFF1F2937)),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
