// lib/screens/video_player_screen.dart - Updated dengan ActivityTrackerWrapper
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import '../models/media_item.dart';
import '../services/storage_service.dart';
import '../widgets/activity_tracker_wrapper.dart'; // Import wrapper
import 'dart:io';

class VideoPlayerScreen extends StatefulWidget {
  final MediaItem mediaItem;

  const VideoPlayerScreen({super.key, required this.mediaItem});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showControls = true;
  bool _isPlaying = false;
  bool _isFullScreen = false;
  bool _isUsingLocalFile = false;

  // Animation controllers
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;

  // Progress tracking
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVideoPlayer();
    _hideControlsTimer();
  }

  void _initializeAnimations() {
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controlsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controlsAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _controlsAnimationController.forward();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      _controller?.dispose();
      _controller = null;

      String videoPath;
      final filename = widget.mediaItem.localFileName;

      print('🎬 Initializing video: $filename');
      print('🔍 Looking for local file with ID-based name: $filename');
      print(
        '🌐 Original filename from URL: ${widget.mediaItem.downloadUrl.split('/').last}',
      );

      final isDownloaded = await StorageService.isMediaDownloaded(filename);
      print('📱 Is downloaded locally: $isDownloaded');

      if (isDownloaded) {
        videoPath = await StorageService.getLocalFilePath(filename);
        print('📁 Local path: $videoPath');

        final file = File(videoPath);
        final exists = await file.exists();
        final fileSize = exists ? await file.length() : 0;

        print('📄 File exists: $exists, Size: ${fileSize}KB');

        if (!exists || fileSize == 0) {
          print('❌ Local file invalid, falling back to network');
          throw Exception('Local file not found or empty');
        }

        try {
          final canRead = await file.readAsBytes();
          print('✅ File is readable, size: ${canRead.length} bytes');
        } catch (e) {
          print('❌ Cannot read file: $e');
          throw Exception('Cannot read local file: $e');
        }

        _controller = VideoPlayerController.file(file);
        _isUsingLocalFile = true;
        print('🎮 Created local file controller');
      } else {
        videoPath = widget.mediaItem.downloadUrl;
        print('🌐 Streaming from network: $videoPath');

        if (!videoPath.startsWith('http')) {
          throw Exception('Invalid network URL: $videoPath');
        }

        _controller = VideoPlayerController.networkUrl(Uri.parse(videoPath));
        _isUsingLocalFile = false;
        print('🎮 Created network controller');
      }

      print('⏳ Initializing controller...');

      await _controller!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Video initialization timeout after 30 seconds');
        },
      );

      if (!_controller!.value.isInitialized) {
        throw Exception('Controller initialization failed');
      }

      if (_controller!.value.hasError) {
        throw Exception(
          'Controller error: ${_controller!.value.errorDescription}',
        );
      }

      print('✅ Video initialized successfully');
      print('📊 Duration: ${_controller!.value.duration}');
      print('📐 Aspect ratio: ${_controller!.value.aspectRatio}');

      setState(() {
        _isLoading = false;
        _duration = _controller!.value.duration;
      });

      _controller!.addListener(_videoListener);

      await _controller!.play();
      setState(() {
        _isPlaying = true;
      });

      print('▶️ Started playing');
    } catch (e) {
      print('❌ Video initialization error: $e');

      if (_isUsingLocalFile && !e.toString().contains('network')) {
        print('🔄 Local file failed, trying network fallback...');
        await _tryNetworkFallback();
        return;
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = _getDetailedErrorMessage(e);
      });
    }
  }

  Future<void> _tryNetworkFallback() async {
    try {
      print('🌐 Attempting network fallback...');

      _controller?.dispose();
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.mediaItem.downloadUrl),
      );
      _isUsingLocalFile = false;

      await _controller!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Network fallback timeout');
        },
      );

      setState(() {
        _isLoading = false;
        _duration = _controller!.value.duration;
      });

      _controller!.addListener(_videoListener);
      await _controller!.play();
      setState(() {
        _isPlaying = true;
      });

      print('✅ Network fallback successful');
    } catch (e) {
      print('❌ Network fallback failed: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Both local and network playback failed: $e';
      });
    }
  }

  String _getDetailedErrorMessage(dynamic error) {
    String errorMsg = error.toString();

    if (errorMsg.contains('PlatformException')) {
      return 'Platform error: Video format may not be supported offline';
    } else if (errorMsg.contains('timeout')) {
      return 'Loading timeout: File may be too large or corrupted';
    } else if (errorMsg.contains('Source error')) {
      return 'Source error: File path or URL is invalid';
    } else if (errorMsg.contains('not found')) {
      return 'File not found: Video may not be properly downloaded';
    } else {
      return 'Error: $errorMsg';
    }
  }

  Future<void> _debugStorageInfo() async {
    try {
      final filename = widget.mediaItem.localFileName;
      final originalFilename = widget.mediaItem.downloadUrl.split('/').last;
      final isDownloaded = await StorageService.isMediaDownloaded(filename);

      print('\n=== 🔍 STORAGE DEBUG INFO ===');
      print('🆔 Media ID: ${widget.mediaItem.id}');
      print('📱 Local Filename (ID-based): $filename');
      print('📄 Original Filename: $originalFilename');
      print('💾 Is Downloaded: $isDownloaded');
      print('🌐 Download URL: ${widget.mediaItem.downloadUrl}');
      print('📂 File URL: ${widget.mediaItem.fileUrl}');

      if (isDownloaded) {
        try {
          final localPath = await StorageService.getLocalFilePath(filename);
          final file = File(localPath);
          final exists = await file.exists();

          print('📁 Local Path: $localPath');
          print('📄 File Exists: $exists');

          if (exists) {
            final fileSize = await file.length();
            final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
            print('📊 File Size: ${fileSizeMB}MB ($fileSize bytes)');

            try {
              final stat = await file.stat();
              print('📅 Modified: ${stat.modified}');
              print('🔐 Mode: ${stat.modeString()}');
            } catch (e) {
              print('❌ Stat error: $e');
            }
          }
        } catch (e) {
          print('❌ Local file access error: $e');
        }
      } else {
        print('🔍 Checking if file exists with original filename...');
        final originalFileDownloaded = await StorageService.isMediaDownloaded(
          originalFilename,
        );
        print('📄 Original filename downloaded: $originalFileDownloaded');

        if (originalFileDownloaded) {
          final originalPath = await StorageService.getLocalFilePath(
            originalFilename,
          );
          final originalFile = File(originalPath);
          final originalExists = await originalFile.exists();
          print(
            '⚠️ MISMATCH: File exists as "$originalFilename" but expected as "$filename"',
          );
          print('📁 Original path: $originalPath');
          print('📄 Original exists: $originalExists');
        }
      }

      try {
        final appDir = await getApplicationDocumentsDirectory();
        final supportDir = await getApplicationSupportDirectory();
        final tempDir = await getTemporaryDirectory();

        print('📂 App Documents: ${appDir.path}');
        print('📂 App Support: ${supportDir.path}');
        print('📂 Temp: ${tempDir.path}');

        final documentsDir = Directory(appDir.path);
        if (await documentsDir.exists()) {
          final files = await documentsDir.list().toList();
          print('📋 Files in documents directory:');
          for (var file in files) {
            if (file is File) {
              final fileName = file.path.split('/').last;
              final fileSize = await file.length();
              final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
              print('   📄 $fileName (${fileSizeMB}MB)');
            }
          }
        }
      } catch (e) {
        print('❌ Directory access error: $e');
      }

      print('========================\n');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Debug info printed to console. Check if filename mismatch exists.',
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('❌ Debug info error: $e');
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;

    setState(() {
      _position = _controller!.value.position;
      _isPlaying = _controller!.value.isPlaying;
    });

    if (_controller!.value.hasError) {
      setState(() {
        _hasError = true;
        _errorMessage =
            'Playback error: ${_controller!.value.errorDescription}';
      });
    }

    if (_isPlaying && _showControls) {
      _hideControlsTimer();
    }
  }

  void _hideControlsTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
        _controlsAnimationController.reverse();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _controlsAnimationController.forward();
      _hideControlsTimer();
    } else {
      _controlsAnimationController.reverse();
    }
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    setState(() {
      if (_isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
        _hideControlsTimer();
      }
    });
  }

  void _seekTo(Duration position) {
    if (_controller == null) return;
    _controller!.seekTo(position);
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    _controlsAnimationController.dispose();

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      // Jangan paksa portrait, biarkan sistem atau halaman sebelumnya yang mengatur
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ActivityTrackerWrapper(
      screenName:
          'VideoPlayerScreen', // Screen ini ada di whitelist, jadi timer akan di-pause
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: _isFullScreen
              ? _buildFullScreenPlayer()
              : _buildNormalPlayer(),
        ),
      ),
    );
  }

  Widget _buildNormalPlayer() {
    return Column(
      children: [
        // Header with connection status
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mediaItem.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _isUsingLocalFile ? Icons.offline_pin : Icons.cloud,
                          color: _isUsingLocalFile
                              ? Colors.green
                              : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isUsingLocalFile ? 'OFFLINE' : 'STREAMING',
                          style: TextStyle(
                            color: _isUsingLocalFile
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getFileTypeFromUrl(widget.mediaItem.fileUrl),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
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

        // Video Player
        Expanded(child: _buildVideoPlayer()),

        // Video Info
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Video Information',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Status',
                _isUsingLocalFile ? '📱 Offline' : '🌐 Online',
              ),
              _buildInfoRow('Duration', _formatDuration(_duration)),
              _buildInfoRow('File', widget.mediaItem.fileUrl.split('/').last),
              _buildInfoRow(
                'Type',
                _getFileTypeFromUrl(widget.mediaItem.fileUrl),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullScreenPlayer() {
    return _buildVideoPlayer();
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return _buildLoadingState();
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),

            // Controls Overlay
            if (_showControls)
              FadeTransition(
                opacity: _controlsAnimation,
                child: _buildControlsOverlay(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black54,
            Colors.transparent,
            Colors.transparent,
            Colors.black54,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Center Play/Pause Button
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(35),
              ),
              child: IconButton(
                iconSize: 50,
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: _togglePlayPause,
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Progress Bar
                  Row(
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _position.inMilliseconds.toDouble(),
                          max: _duration.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              _isDragging = true;
                            });
                          },
                          onChangeEnd: (value) {
                            _seekTo(Duration(milliseconds: value.toInt()));
                            setState(() {
                              _isDragging = false;
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                          inactiveColor: Colors.white24,
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white),
                        onPressed: () {
                          final newPosition =
                              _position - const Duration(seconds: 10);
                          _seekTo(
                            newPosition < Duration.zero
                                ? Duration.zero
                                : newPosition,
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10, color: Colors.white),
                        onPressed: () {
                          final newPosition =
                              _position + const Duration(seconds: 10);
                          _seekTo(
                            newPosition > _duration ? _duration : newPosition,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _isFullScreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          color: Colors.white,
                        ),
                        onPressed: _toggleFullScreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              _isUsingLocalFile
                  ? 'Loading offline video...'
                  : 'Loading online video...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Failed to load video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Retry button
              ElevatedButton.icon(
                onPressed: _initializeVideoPlayer,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              // Force stream online button
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    setState(() {
                      _isLoading = true;
                      _hasError = false;
                    });

                    _controller?.dispose();
                    _controller = VideoPlayerController.networkUrl(
                      Uri.parse(widget.mediaItem.downloadUrl),
                    );
                    _isUsingLocalFile = false;

                    await _controller!.initialize();

                    setState(() {
                      _isLoading = false;
                      _duration = _controller!.value.duration;
                    });

                    _controller!.addListener(_videoListener);
                    await _controller!.play();
                    setState(() {
                      _isPlaying = true;
                    });
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                      _hasError = true;
                      _errorMessage = 'Network streaming failed: $e';
                    });
                  }
                },
                icon: const Icon(Icons.cloud_download),
                label: const Text('Force Stream Online'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              // Debug button
              TextButton.icon(
                onPressed: _debugStorageInfo,
                icon: const Icon(Icons.bug_report, color: Colors.grey),
                label: const Text(
                  'Debug Storage Info',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
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
        return 'VIDEO • $extension';
    }
  }
}
