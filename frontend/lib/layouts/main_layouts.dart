// lib/layouts/main_layouts.dart
import 'package:flutter/material.dart';
import '../widgets/navigation/slide_navigation.dart';
import '../routes/app_routes.dart';
import '../screens/home_screen.dart' as home;
import '../screens/videos_screen.dart' as videos;
import '../screens/music_screen.dart' as music;
import '../screens/games_screen.dart' as games; // Import games screen
import '../screens/news_screen.dart' as news;
import '../screens/about_screen.dart' as about;

class MainLayout extends StatefulWidget {
  final String initialRoute;

  const MainLayout({Key? key, this.initialRoute = AppRoutes.homeScreen})
    : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String currentRoute = AppRoutes.homeScreen;

  @override
  void initState() {
    super.initState();
    currentRoute = widget.initialRoute;
  }

  // Method untuk navigasi (seperti redirect di Laravel)
  void navigateToRoute(String route) {
    setState(() {
      currentRoute = route;
    });
  }

  // Method untuk mendapatkan widget berdasarkan route (seperti view() di Laravel)
  Widget _getPageWidget(String route) {
    switch (route) {
      case AppRoutes.homeScreen:
        return home.HomeScreen();
      case AppRoutes.videosScreen:
        return videos.VideosScreen();
      case AppRoutes.musicScreen:
        return music.MusicScreen();
      case AppRoutes.gamesScreen: // Add games route
        return games.GamesScreen();
      case AppRoutes.newsScreen:
        return news.NewsScreen();
      case AppRoutes.aboutScreen:
        return about.AboutScreen();
      default:
        return home.HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content area (seperti @yield('content') di blade)
          _getPageWidget(currentRoute),

          // Slide Navigation (seperti navbar di blade kamu)
          SlideNavigation(
            currentRoute: currentRoute,
            onNavigate: navigateToRoute,
          ),
        ],
      ),
    );
  }
}
