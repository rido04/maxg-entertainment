// lib/models/game_item.dart
enum GameType {
  webview, // HTML games
  flame, // Native Flame games
  widget, // Pure Flutter widget games
}

class GameItem {
  final String name;
  final String? route;
  final String backgroundImage;
  final String icon;
  final String description;
  final Map<String, String> colors;
  final String status;
  final bool featured;
  final String? url;
  final bool offline;
  final GameType gameType; // New field for game type
  final String? gameClass; // Class name for Flame games

  GameItem({
    required this.name,
    this.route,
    required this.backgroundImage,
    required this.icon,
    required this.description,
    required this.colors,
    required this.status,
    this.featured = false,
    this.url,
    this.offline = false,
    this.gameType = GameType.webview,
    this.gameClass,
  });

  factory GameItem.fromJson(Map<String, dynamic> json) {
    GameType type = GameType.webview;
    if (json['game_type'] != null) {
      switch (json['game_type']) {
        case 'flame':
          type = GameType.flame;
          break;
        case 'widget':
          type = GameType.widget;
          break;
        default:
          type = GameType.webview;
      }
    }

    return GameItem(
      name: json['name'] ?? '',
      route: json['route'],
      backgroundImage: json['background_image'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      colors: Map<String, String>.from(json['colors'] ?? {}),
      status: json['status'] ?? 'coming_soon',
      featured: json['featured'] ?? false,
      url: json['url'],
      offline: json['offline'] ?? false,
      gameType: type,
      gameClass: json['game_class'],
    );
  }

  Map<String, dynamic> toJson() {
    String gameTypeString = 'webview';
    switch (gameType) {
      case GameType.flame:
        gameTypeString = 'flame';
        break;
      case GameType.widget:
        gameTypeString = 'widget';
        break;
      default:
        gameTypeString = 'webview';
    }

    return {
      'name': name,
      'route': route,
      'background_image': backgroundImage,
      'icon': icon,
      'description': description,
      'colors': colors,
      'status': status,
      'featured': featured,
      'url': url,
      'offline': offline,
      'game_type': gameTypeString,
      'game_class': gameClass,
    };
  }

  // Helper methods
  bool get isActive => status == 'active';
  bool get isComingSoon => status == 'coming_soon';
  bool get canPlayOffline =>
      offline && (gameType == GameType.flame || gameType == GameType.widget);
  bool get requiresInternet =>
      !offline || (url != null && url!.startsWith('http'));
  bool get isFlameGame => gameType == GameType.flame;
  bool get isWidgetGame => gameType == GameType.widget;
  bool get isWebViewGame => gameType == GameType.webview;
}
