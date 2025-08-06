// lib/main.dart - Updated version
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'screens/screen_saver_screen.dart';
import 'routes/app_routes.dart';
import 'layouts/main_layouts.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/global_audio_service.dart';
import 'services/activity_tracker_service.dart'; // Import service baru
import 'widgets/mini_player.dart';
import 'widgets/map_trigger_button.dart';
import 'widgets/map_modal_widget.dart';
import 'widgets/activity_tracker_wrapper.dart'; // Import wrapper baru

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MaxgApp());
}

void syncAllMedia() async {
  final mediaItems = await ApiService.fetchMediaList();
  await StorageService.downloadAllMedia(mediaItems);
}

class MaxgApp extends StatelessWidget {
  const MaxgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/main',
      routes: {
        '/main': (context) => const MainLayoutWrapper(),
        '/videos': (context) =>
            MainLayoutWrapper(initialRoute: AppRoutes.videos),
        '/music': (context) => MainLayoutWrapper(initialRoute: AppRoutes.music),
        '/games': (context) => MainLayoutWrapper(initialRoute: AppRoutes.games),
        '/news': (context) => MainLayoutWrapper(initialRoute: AppRoutes.news),
        '/about': (context) => MainLayoutWrapper(initialRoute: AppRoutes.about),
        '/screensaver': (context) => ScreensaverScreen(),
      },
      title: 'MaxG Entertainment',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00B14F),
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
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          subtitleTextStyle: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF00B14F), size: 24),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00B14F),
          foregroundColor: Colors.white,
          elevation: 8,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF00B14F),
        ),
      ),
      home: const MainLayoutWrapper(),
      debugShowCheckedModeBanner: false,
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

// Simplified MainLayoutWrapper dengan global activity tracker
class MainLayoutWrapper extends StatefulWidget {
  final String? initialRoute;

  const MainLayoutWrapper({super.key, this.initialRoute});

  @override
  State<MainLayoutWrapper> createState() => _MainLayoutWrapperState();
}

class _MainLayoutWrapperState extends State<MainLayoutWrapper> {
  bool _isMapModalVisible = false;
  final ActivityTrackerService _activityTracker =
      ActivityTrackerService.instance;

  @override
  void initState() {
    super.initState();
    // Initialize services
    GlobalAudioService().initialize();
    _setFullscreen();

    // Initialize global activity tracker
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activityTracker.initialize(context);
    });
  }

  @override
  void dispose() {
    // Dispose activity tracker when leaving main layout
    _activityTracker.dispose();
    super.dispose();
  }

  void _setFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

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
    return ActivityTrackerWrapper(
      screenName: 'MainLayout',
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: widget.initialRoute != null
                      ? MainLayout(initialRoute: widget.initialRoute!)
                      : MainLayout(),
                ),
                const MiniPlayer(),
              ],
            ),
            MapTriggerButton(onTap: _showMapModal),
            if (_isMapModalVisible) MapModal(onClose: _hideMapModal),
          ],
        ),
      ),
    );
  }
}
