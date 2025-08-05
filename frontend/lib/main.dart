import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'screens/screen_saver_screen.dart'; // Ganti dari welcome_screen.dart
import 'routes/app_routes.dart';
import 'layouts/main_layouts.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/global_audio_service.dart';
import 'widgets/mini_player.dart';
import 'widgets/map_trigger_button.dart';
import 'widgets/map_modal_widget.dart';

void main() async {
  // Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Set orientation ke landscape dan fullscreen
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set fullscreen immersive
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MaxgApp());
}

void syncAllMedia() async {
  final mediaItems = await ApiService.fetchMediaList();
  await StorageService.downloadAllMedia(mediaItems); // Panggil fungsi langsung
}

class MaxgApp extends StatelessWidget {
  const MaxgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Ubah initial route ke home/main layout
      initialRoute: '/main',
      routes: {
        '/main': (context) => const MainLayoutWrapper(),
        '/videos': (context) =>
            MainLayoutWrapper(initialRoute: AppRoutes.videos),
        '/music': (context) => MainLayoutWrapper(initialRoute: AppRoutes.music),
        '/games': (context) => MainLayoutWrapper(initialRoute: AppRoutes.games),
        '/news': (context) => MainLayoutWrapper(initialRoute: AppRoutes.news),
        '/about': (context) => MainLayoutWrapper(initialRoute: AppRoutes.about),
        '/screensaver': (context) =>
            ScreensaverScreen(), // Route untuk screensaver
      },
      title: 'MaxG Entertainment',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        // Grab Green Color Scheme
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00B14F), // Grab Green
          primaryContainer: Color(0xFF1A5D33),
          secondary: Color(0xFF66D9A5),
          secondaryContainer: Color(0xFF2D5B4A),
          surface: Color(0xFF121212),
          background: Color(0xFF0A0A0A),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),

        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00B14F),
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // Card Theme
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),

        // List Tile Theme
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          subtitleTextStyle: TextStyle(color: Colors.grey, fontSize: 14),
        ),

        // Icon Theme
        iconTheme: const IconThemeData(color: Color(0xFF00B14F), size: 24),

        // FloatingActionButton Theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00B14F),
          foregroundColor: Colors.white,
          elevation: 8,
        ),

        // Progress Indicator Theme
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF00B14F),
        ),
      ),
      home: const MainLayoutWrapper(),
      debugShowCheckedModeBanner: false,
      // Untuk memastikan audio tetap berjalan saat app di background
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: child!,
        );
      },
    );
  }
}

// Wrapper untuk MainLayout dengan Mini Player dan Screensaver Detection
class MainLayoutWrapper extends StatefulWidget {
  final String? initialRoute;

  const MainLayoutWrapper({super.key, this.initialRoute});

  @override
  State<MainLayoutWrapper> createState() => _MainLayoutWrapperState();
}

class _MainLayoutWrapperState extends State<MainLayoutWrapper> {
  Timer? _inactivityTimer;
  bool _isMapModalVisible = false; // Tambahkan state untuk map modal
  static const Duration _inactivityDuration = Duration(
    minutes: 1,
  ); // 1 minute idle

  @override
  void initState() {
    super.initState();
    // Initialize global audio service when entering main layout
    GlobalAudioService().initialize();
    _startInactivityTimer();

    // Pastikan fullscreen tetap aktif
    _setFullscreen();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _setFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityDuration, () {
      // Navigasi ke screensaver setelah idle
      Navigator.of(context).pushReplacementNamed('/screensaver');
    });
  }

  void _resetInactivityTimer() {
    _startInactivityTimer();
    _setFullscreen(); // Reset fullscreen juga
  }

  // Method untuk show/hide map modal
  void _showMapModal() {
    setState(() {
      _isMapModalVisible = true;
    });
  }

  void _hideMapModal() {
    setState(() {
      _isMapModalVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Detect any touch to reset inactivity timer
      onTap: _resetInactivityTimer,
      onPanDown: (_) => _resetInactivityTimer(),
      child: Scaffold(
        body: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Main Layout Content
                Expanded(
                  child: widget.initialRoute != null
                      ? MainLayout(initialRoute: widget.initialRoute!)
                      : MainLayout(),
                ),
                // Mini Player - akan muncul ketika ada musik yang diputar
                const MiniPlayer(),
              ],
            ),

            // Map trigger button (positioned at bottom center)
            MapTriggerButton(onTap: _showMapModal),

            // Map modal overlay
            if (_isMapModalVisible) MapModal(onClose: _hideMapModal),
          ],
        ),
      ),
    );
  }
}
