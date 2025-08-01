import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
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

  // Daftar video iklan (ganti dengan path video Anda)
  final List<String> _advertisementVideos = [
    'assets/videos/ads/ad_video_1.mp4',
    'assets/videos/ads/ad_video_2.mp4',
    'assets/videos/ads/ad_video_3.mp4',
  ];

  // Daftar gambar fallback jika video tidak tersedia
  final List<String> _advertisementImages = [
    'assets/images/ads/ad_image_1.jpg',
    'assets/images/ads/ad_image_2.jpg',
    'assets/images/ads/ad_image_3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (_currentVideoIndex < _advertisementVideos.length - 1) {
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
    });
  }

  void _exitScreensaver() {
    // Kembali ke main screen ketika di-tap
    Navigator.of(context).pushReplacementNamed('/main');
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

              // Video/Image Slider
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _advertisementImages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentVideoIndex = index;
                    });
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
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Gambar iklan (fallback untuk video)
                            Image.asset(
                              _advertisementImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.video_library,
                                          size: 100,
                                          color: Colors.white54,
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          'Advertisement ${index + 1}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

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
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'MaxG Entertainment',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Touch anywhere to continue',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
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
                    _advertisementImages.length,
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
