import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../widgets/welcome/header_widget.dart';
import '../widgets/welcome/time_display_widget.dart';

class ScreensaverScreen extends StatefulWidget {
  @override
  _ScreensaverScreenState createState() => _ScreensaverScreenState();
}

class _ScreensaverScreenState extends State<ScreensaverScreen> {
  PageController _pageController = PageController();
  Timer? _autoPlayTimer;
  int _currentVideoIndex = 0;
  List<VideoPlayerController> _videoControllers = [];

  // Daftar video iklan berdasarkan screenshot Anda
  final List<String> _advertisementVideos = [
    'assets/video/bebas_seenaknya_grabfood.mp4',
    'assets/video/grabmart_beauty_ready.mp4',
  ];

  // Daftar gambar fallback jika video tidak tersedia
  final List<String> _advertisementImages = [
    'assets/images/ads/grabfood_discount.jpg',
    'assets/images/ads/grabmart_beauty.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _initializeVideos();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    _disposeVideoControllers();
    super.dispose();
  }

  Future<bool> _checkAssetExists(String assetPath) async {
    try {
      await DefaultAssetBundle.of(context).load(assetPath);
      return true;
    } catch (e) {
      print('Asset not found: $assetPath');
      return false;
    }
  }

  void _initializeVideos() async {
    for (int i = 0; i < _advertisementVideos.length; i++) {
      String videoPath = _advertisementVideos[i];
      VideoPlayerController? controller;

      try {
        // Check if asset exists first
        bool assetExists = await _checkAssetExists(videoPath);
        if (!assetExists) {
          print('Asset not found: $videoPath');
          _videoControllers.add(VideoPlayerController.asset('')); // placeholder
          continue;
        }

        controller = VideoPlayerController.asset(videoPath);
        await controller.initialize();
        controller.setLooping(true);
        _videoControllers.add(controller);
        print('Video initialized successfully: $videoPath');
      } catch (e) {
        print('Error initializing video: $videoPath - $e');
        // Add null controller to maintain index alignment
        _videoControllers.add(VideoPlayerController.asset(''));
      }
    }

    // Start playing first video if available
    if (_videoControllers.isNotEmpty &&
        _videoControllers[0].value.isInitialized) {
      _videoControllers[0].play();
    }

    _startAutoPlay();
    if (mounted) setState(() {});
  }

  void _disposeVideoControllers() {
    for (VideoPlayerController controller in _videoControllers) {
      controller.dispose();
    }
    _videoControllers.clear();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Check if current video has finished
      if (_videoControllers.isNotEmpty &&
          _currentVideoIndex < _videoControllers.length &&
          _videoControllers[_currentVideoIndex].value.isInitialized) {
        VideoPlayerController currentController =
            _videoControllers[_currentVideoIndex];

        // If video finished or close to finish (within 1 second)
        if (currentController.value.position >=
            currentController.value.duration - Duration(seconds: 1)) {
          // Move to next video
          if (_currentVideoIndex < _advertisementVideos.length - 1) {
            _currentVideoIndex++;
          } else {
            _currentVideoIndex = 0;
          }

          // Restart current video (for looping)
          currentController.seekTo(Duration.zero);
          currentController.play();

          if (_pageController.hasClients) {
            _pageController.animateToPage(
              _currentVideoIndex,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      } else {
        // Fallback: if no video, use 15 second interval for images
        if (timer.tick % 15 == 0) {
          if (_currentVideoIndex < _advertisementImages.length - 1) {
            _currentVideoIndex++;
          } else {
            _currentVideoIndex = 0;
          }

          if (_pageController.hasClients) {
            _pageController.animateToPage(
              _currentVideoIndex,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      }
    });
  }

  void _exitScreensaver() {
    // Stop all videos before exiting
    for (VideoPlayerController controller in _videoControllers) {
      if (controller.value.isInitialized) {
        controller.pause();
      }
    }
    // Kembali ke main screen ketika di-tap
    Navigator.of(context).pushReplacementNamed('/main');
  }

  Widget _buildVideoPlayer(int index) {
    // Always show fallback image if video controller is not properly initialized
    if (index >= _videoControllers.length ||
        _videoControllers[index] == null ||
        !_videoControllers[index].value.isInitialized) {
      return _buildFallbackImage(index);
    }

    VideoPlayerController controller = _videoControllers[index];

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getVideoTitle(index),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Touch anywhere to continue',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackImage(int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fallback image
        index < _advertisementImages.length
            ? Image.asset(
                _advertisementImages[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorPlaceholder(index);
                },
              )
            : _buildErrorPlaceholder(index),

        // Overlay dengan informasi
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getVideoTitle(index),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Touch anywhere to continue',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorPlaceholder(int index) {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 100, color: Colors.white54),
            SizedBox(height: 20),
            Text(
              _getVideoTitle(index),
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getVideoTitle(int index) {
    switch (index) {
      case 0:
        return 'Bebas Seenaknya Pasti Diskon';
      case 1:
        return 'GrabMart Beauty Ready';
      default:
        return 'Advertisement ${index + 1}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _exitScreensaver,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1e293b).withOpacity(0.25),
                Color(0xFF1e40af).withOpacity(0.15),
                Color(0xFF1f2937).withOpacity(0.25),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/background/Background_Color.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Color(0xFF1e293b));
                  },
                ),
              ),

              // Video Slider
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _advertisementVideos.length,
                  onPageChanged: (index) {
                    // Stop previous video
                    if (_videoControllers.isNotEmpty &&
                        _currentVideoIndex < _videoControllers.length &&
                        _videoControllers[_currentVideoIndex]
                            .value
                            .isInitialized) {
                      _videoControllers[_currentVideoIndex].pause();
                    }

                    setState(() {
                      _currentVideoIndex = index;
                    });

                    // Start current video
                    if (_videoControllers.isNotEmpty &&
                        _currentVideoIndex < _videoControllers.length &&
                        _videoControllers[_currentVideoIndex]
                            .value
                            .isInitialized) {
                      _videoControllers[_currentVideoIndex].play();
                    }
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _buildVideoPlayer(index),
                      ),
                    );
                  },
                ),
              ),

              // Header (Logo MaxG)
              Positioned(top: 0, left: 0, right: 0, child: HeaderWidget()),

              // Page Indicators
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _advertisementVideos.length,
                    (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: _currentVideoIndex == index ? 30 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _currentVideoIndex == index
                            ? Color(0xFF00B14F)
                            : Colors.white54,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),

              // Time Display
              Positioned(bottom: 24, right: 24, child: TimeDisplayWidget()),

              // Subtle animation hint
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: FadeInUp(
                  duration: Duration(seconds: 2),
                  child: Center(
                    child: Icon(
                      Icons.touch_app,
                      color: Colors.white54,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
