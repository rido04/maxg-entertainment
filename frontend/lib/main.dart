import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/welcome_screen.dart';
import 'widgets/welcome/welcome_content_widget.dart';
import 'routes/app_routes.dart';
import 'layouts/main_layouts.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/global_audio_service.dart';
import 'widgets/mini_player.dart';

void main() {
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
      initialRoute: AppRoutes.welcome,
      routes: {
        '/main': (context) => const MainLayoutWrapper(),
        '/videos': (context) =>
            MainLayoutWrapper(initialRoute: AppRoutes.videos),
        '/music': (context) => MainLayoutWrapper(initialRoute: AppRoutes.music),
        '/games': (context) => MainLayoutWrapper(initialRoute: AppRoutes.games),
        '/news': (context) => MainLayoutWrapper(initialRoute: AppRoutes.news),
        '/about': (context) => MainLayoutWrapper(initialRoute: AppRoutes.about),
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
      home: WelcomeScreen(),
      debugShowCheckedModeBanner: false,
      // Untuk memastikan audio tetap berjalan saat app di background
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          child: child!,
        );
      },
    );
  }
}

// Wrapper untuk MainLayout dengan Mini Player
class MainLayoutWrapper extends StatefulWidget {
  final String? initialRoute;

  const MainLayoutWrapper({super.key, this.initialRoute});

  @override
  State<MainLayoutWrapper> createState() => _MainLayoutWrapperState();
}

class _MainLayoutWrapperState extends State<MainLayoutWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize global audio service when entering main layout
    GlobalAudioService().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
    );
  }
}

// Alternative: Jika Anda ingin mini player muncul di semua halaman termasuk welcome
class GlobalAppWrapper extends StatefulWidget {
  final Widget child;

  const GlobalAppWrapper({super.key, required this.child});

  @override
  State<GlobalAppWrapper> createState() => _GlobalAppWrapperState();
}

class _GlobalAppWrapperState extends State<GlobalAppWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize global audio service
    GlobalAudioService().initialize();
  }

  @override
  Widget build(BuildContext context) {
    // Hanya tampilkan mini player jika bukan di welcome screen
    final isWelcomeScreen =
        ModalRoute.of(context)?.settings.name == AppRoutes.welcome ||
        widget.child is WelcomeScreen;

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: widget.child),
          // Mini player hanya muncul di halaman main, bukan di welcome
          if (!isWelcomeScreen) const MiniPlayer(),
        ],
      ),
    );
  }
}

// Jika ingin menggunakan GlobalAppWrapper untuk semua halaman:
// Ganti MaterialApp builder dengan:
/*
class MaxgApp extends StatelessWidget {
  const MaxgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ... semua konfigurasi theme sama ...
      
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          child: GlobalAppWrapper(child: child!),
        );
      },
      
      // ... sisa konfigurasi sama ...
    );
  }
}
*/
