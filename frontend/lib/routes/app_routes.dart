class AppRoutes {
  // Route names (seperti route names di Laravel)
  static const String welcome = '/';
  static const String home = '/main';
  static const String videos = '/videos';
  static const String videoShow =
      '/video-show'; // Route baru untuk video player
  static const String music = '/music';
  static const String games = '/games';
  static const String news = '/news';
  static const String about = '/about';

  // Internal navigation routes (untuk navigasi dalam MainLayout)
  static const String homeScreen = 'home';
  static const String videosScreen = 'videos';
  static const String musicScreen = 'music';
  static const String gamesScreen = 'games';
  static const String newsScreen = 'news';
  static const String aboutScreen = 'about';

  // Route titles untuk navbar
  static const Map<String, String> routeTitles = {
    homeScreen: 'Home',
    videosScreen: 'Movies',
    musicScreen: 'Music',
    gamesScreen: 'Games',
    newsScreen: 'News',
    aboutScreen: 'About',
  };

  // Navigation menu items (seperti menu di blade kamu)
  static const List<NavMenuItem> menuItems = [
    NavMenuItem(route: homeScreen, title: 'Home', icon: 'home'),
    NavMenuItem(route: videosScreen, title: 'Movies', icon: 'movies'),
    NavMenuItem(route: musicScreen, title: 'Music', icon: 'music'),
    NavMenuItem(route: gamesScreen, title: 'Games', icon: 'games'),
    NavMenuItem(route: newsScreen, title: 'News', icon: 'news'),
    NavMenuItem(route: aboutScreen, title: 'About', icon: 'info'),
  ];
}

class NavMenuItem {
  final String route;
  final String title;
  final String icon;

  const NavMenuItem({
    required this.route,
    required this.title,
    required this.icon,
  });
}
