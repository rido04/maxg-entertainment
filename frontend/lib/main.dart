import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'widgets/welcome/welcome_content_widget.dart';
import 'routes/app_routes.dart';
import 'layouts/main_layouts.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MaxgApp());
}

void syncAllMedia() async {
  final mediaItems = await ApiService.fetchMediaList();
  await downloadAllMedia(mediaItems); // Panggil fungsi langsung
}

class MaxgApp extends StatelessWidget {
  const MaxgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: AppRoutes.welcome,
      routes: {
        '/main': (context) => MainLayout(),
        '/videos': (context) => MainLayout(initialRoute: AppRoutes.videos),
        '/music': (context) => MainLayout(initialRoute: AppRoutes.music),
        '/games': (context) => MainLayout(initialRoute: AppRoutes.games),
        '/news': (context) => MainLayout(initialRoute: AppRoutes.news),
        '/about': (context) => MainLayout(initialRoute: AppRoutes.about),
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
    );
  }
}
