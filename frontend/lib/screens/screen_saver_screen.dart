// lib/screens/screen_saver_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';
import '../services/session_manager_service.dart';
import '../services/advertisement_service.dart';
import '../models/advertisement_item.dart';

class ScreensaverScreen extends StatefulWidget {
  @override
  _ScreensaverScreenState createState() => _ScreensaverScreenState();
}

class _ScreensaverScreenState extends State<ScreensaverScreen> {
  PageController _pageController = PageController();
  Timer? _autoPlayTimer;
  int _currentAdIndex = 0;
  int? _pausedVideoIndex; // 👈 Tambah variable ini di class state
  Duration? _pausedVideoPosition; // 👈 Simpan posisi video
  List<VideoPlayerController> _videoControllers = [];

  final SessionManagerService _sessionManager = SessionManagerService();
  List<AdvertisementItem> _advertisements = [];
  bool _isLoadingAds = true;

  @override
  void initState() {
    super.initState();
    _setFullScreen();
    _initializeSessionManager();
    _loadDefaultAdvertisements();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    _disposeVideoControllers();
    _sessionManager.stopMonitoring();
    _sessionManager.dispose();
    super.dispose();
  }

  void _setFullScreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  Future<void> _initializeSessionManager() async {
    print('🚀 Initializing session manager...');

    await _sessionManager.initialize();
    _sessionManager.setContext(context);

    // 👇 Set pause/resume controls
    _sessionManager.setVideoControls(
      onPauseVideo: _pauseAllVideos,
      onResumeVideo: _resumeAllVideos,
    );

    _sessionManager.onSessionStarted = (session) {
      print('✅ Session started: ${session.sessionId}');
    };

    _sessionManager.onSessionEnded = (session) {
      print(
        '📊 Session ended: Duration=${session.durationSeconds}s, Ads viewed=${session.adViewCount}',
      );
      _loadDefaultAdvertisements();
    };

    _sessionManager.onAdsUpdated = (ads) {
      print('🎯 Ads updated: ${ads.length} targeted ads');
      _updateAdvertisements(ads);

      // 👇 TAMBAH INI - Pause semua video setelah ads di-update
      Future.delayed(Duration(milliseconds: 300), () {
        if (_sessionManager.state == SessionState.detected ||
            _sessionManager.state == SessionState.active) {
          _pauseAllVideos();
          print('🔇 Videos paused after ads update during active session');
        }
      });
    };

    _sessionManager.onStateChanged = (state) {
      print('🔄 State changed: $state');
    };

    _sessionManager.startMonitoring();

    print('✅ Session manager ready');
  }

  void _pauseAllVideos() {
    // 👇 Pause SEMUA video controllers
    for (int i = 0; i < _videoControllers.length; i++) {
      final controller = _videoControllers[i];
      if (controller.value.isInitialized) {
        controller.setVolume(0.0);
        controller.pause();
      }
    }

    // Simpan posisi video yang lagi aktif
    final videoIndex = _getVideoControllerIndex(_currentAdIndex);
    if (videoIndex >= 0 && videoIndex < _videoControllers.length) {
      _pausedVideoIndex = videoIndex;
      _pausedVideoPosition = _videoControllers[videoIndex].value.position;
    }

    print('⏸️🔇 All videos paused and muted');
  }

  void _resumeAllVideos() {
    if (_pausedVideoIndex != null &&
        _pausedVideoIndex! >= 0 &&
        _pausedVideoIndex! < _videoControllers.length) {
      final controller = _videoControllers[_pausedVideoIndex!];

      if (controller.value.isInitialized) {
        // Restore posisi
        if (_pausedVideoPosition != null) {
          controller.seekTo(_pausedVideoPosition!);
        }

        // 👇 Set volume dulu, baru play
        controller.setVolume(1.0);

        // 👇 Delay kecil
        Future.delayed(Duration(milliseconds: 100), () {
          controller.play();
        });

        print('▶️🔊 Video resumed from ${_pausedVideoPosition?.inSeconds}s');

        _pausedVideoIndex = null;
        _pausedVideoPosition = null;
      }
    }
  }

  Future<void> _loadDefaultAdvertisements() async {
    try {
      setState(() => _isLoadingAds = true);

      print('📺 Loading default advertisements...');

      final ads = await AdvertisementService.fetchAdvertisements();

      if (ads.isNotEmpty) {
        _updateAdvertisements(ads);
      } else {
        print('⚠️ No advertisements available');
        setState(() => _isLoadingAds = false);
      }
    } catch (e) {
      print('❌ Failed to load advertisements: $e');
      setState(() => _isLoadingAds = false);
    }
  }

  void _updateAdvertisements(List<AdvertisementItem> ads) {
    _disposeVideoControllers();

    setState(() {
      _advertisements = ads;
      _currentAdIndex = 0;
      _isLoadingAds = false;
    });

    _initializeVideoControllers();
  }

  Future<void> _initializeVideoControllers() async {
    for (int i = 0; i < _advertisements.length; i++) {
      final ad = _advertisements[i];

      if (!ad.isVideo) continue;

      try {
        final localPath = await AdvertisementService.getLocalAdPath(ad);

        if (localPath == null || !File(localPath).existsSync()) {
          print('⚠️ Video not downloaded: ${ad.title}');
          continue;
        }

        final controller = VideoPlayerController.file(File(localPath));
        await controller.initialize();
        controller.setLooping(true);
        _videoControllers.add(controller);

        print('✅ Video initialized: ${ad.title}');
      } catch (e) {
        print('❌ Failed to initialize video ${ad.title}: $e');
      }
    }

    if (_videoControllers.isNotEmpty && mounted) {
      _videoControllers[0].play();

      if (_sessionManager.isActive) {
        _sessionManager.trackAdView(_advertisements[0].id);
      }
    }

    _startAutoPlay();

    if (mounted) setState(() {});
  }

  void _disposeVideoControllers() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    _videoControllers.clear();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();

    _autoPlayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_advertisements.isEmpty) return;

      final currentAd = _advertisements[_currentAdIndex];

      if (currentAd.isVideo) {
        final videoIndex = _getVideoControllerIndex(_currentAdIndex);

        if (videoIndex >= 0 && videoIndex < _videoControllers.length) {
          final controller = _videoControllers[videoIndex];

          if (controller.value.isInitialized) {
            if (controller.value.position >=
                controller.value.duration - const Duration(seconds: 1)) {
              _nextAd();
            }
          }
        }
      } else {
        if (timer.tick % currentAd.duration == 0) {
          _nextAd();
        }
      }
    });
  }

  void _nextAd() {
    if (_advertisements.isEmpty) return;

    final currentVideoIndex = _getVideoControllerIndex(_currentAdIndex);
    if (currentVideoIndex >= 0 &&
        currentVideoIndex < _videoControllers.length) {
      _videoControllers[currentVideoIndex].pause();
    }

    _currentAdIndex = (_currentAdIndex + 1) % _advertisements.length;

    if (_sessionManager.isActive) {
      _sessionManager.trackAdView(_advertisements[_currentAdIndex].id);
    }

    final nextVideoIndex = _getVideoControllerIndex(_currentAdIndex);
    if (nextVideoIndex >= 0 && nextVideoIndex < _videoControllers.length) {
      _videoControllers[nextVideoIndex].seekTo(Duration.zero);
      _videoControllers[nextVideoIndex].play();
    }

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        _currentAdIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  int _getVideoControllerIndex(int adIndex) {
    int videoIndex = 0;
    for (int i = 0; i < adIndex; i++) {
      if (_advertisements[i].isVideo) videoIndex++;
    }
    return videoIndex;
  }

  void _exitScreensaver() {
    for (var controller in _videoControllers) {
      if (controller.value.isInitialized) {
        controller.pause();
      }
    }

    _sessionManager.stopMonitoring();

    Navigator.of(context).pushReplacementNamed('/main');
  }

  void _muteAllVideos() {
    for (var controller in _videoControllers) {
      if (controller.value.isInitialized) {
        controller.setVolume(0.0);
      }
    }
    print('🔇 All videos muted');
  }

  void _unmuteAllVideos() {
    for (var controller in _videoControllers) {
      if (controller.value.isInitialized) {
        controller.setVolume(1.0);
      }
    }
    print('🔊 All videos unmuted');
  }

  Widget _buildAdPlayer(int index) {
    if (index >= _advertisements.length) {
      return _buildPlaceholder('No advertisement');
    }

    final ad = _advertisements[index];

    return Stack(
      fit: StackFit.expand,
      children: [
        if (ad.isVideo) _buildVideoPlayer(ad) else _buildImagePlayer(ad),
      ],
    );
  }

  Widget _buildVideoPlayer(AdvertisementItem ad) {
    final videoIndex = _getVideoControllerIndex(_currentAdIndex);

    if (videoIndex < 0 || videoIndex >= _videoControllers.length) {
      return _buildPlaceholder('Video not ready');
    }

    final controller = _videoControllers[videoIndex];

    if (!controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00B14F)),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }

  Widget _buildImagePlayer(AdvertisementItem ad) {
    print('🖼️ Loading image for ad: ${ad.title}');
    print('   File URL: ${ad.fileUrl}');

    return FutureBuilder<String?>(
      future: AdvertisementService.getLocalAdPath(ad),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00B14F)),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final file = File(snapshot.data!);

          if (!file.existsSync()) {
            return _buildPlaceholder('Image file not found');
          }

          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('❌ Image load error: $error');
              return _buildPlaceholder('Failed to load image');
            },
          );
        }

        return _buildPlaceholder('Image not available');
      },
    );
  }

  Widget _buildPlaceholder(String message) {
    return Container(
      color: const Color(0xFF1e293b),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_not_supported_outlined,
              size: 100,
              color: Colors.white30,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(color: Colors.white54, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _exitScreensaver,
        child: Stack(
          children: [
            if (_isLoadingAds)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF00B14F)),
                    SizedBox(height: 20),
                    Text(
                      'Loading advertisements...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              )
            else if (_advertisements.isEmpty)
              const Center(
                child: Text(
                  'No advertisements available',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            else
              PageView.builder(
                controller: _pageController,
                itemCount: _advertisements.length,
                onPageChanged: (index) {
                  final currentVideoIndex = _getVideoControllerIndex(
                    _currentAdIndex,
                  );
                  if (currentVideoIndex >= 0 &&
                      currentVideoIndex < _videoControllers.length) {
                    _videoControllers[currentVideoIndex].pause();
                  }

                  setState(() {
                    _currentAdIndex = index;
                  });

                  if (_sessionManager.isActive) {
                    _sessionManager.trackAdView(_advertisements[index].id);
                  }

                  final nextVideoIndex = _getVideoControllerIndex(
                    _currentAdIndex,
                  );
                  if (nextVideoIndex >= 0 &&
                      nextVideoIndex < _videoControllers.length) {
                    _videoControllers[nextVideoIndex].play();
                  }
                },
                itemBuilder: (context, index) {
                  return _buildAdPlayer(index);
                },
              ),

            if (!_isLoadingAds && _advertisements.isNotEmpty)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: FadeInUp(
                  duration: const Duration(seconds: 2),
                  child: const Center(
                    child: Icon(
                      Icons.touch_app,
                      color: Colors.white38,
                      size: 32,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
