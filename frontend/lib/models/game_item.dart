// lib/models/game_item.dart
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
  final bool offline; // New field to indicate if game works offline

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
  });

  factory GameItem.fromJson(Map<String, dynamic> json) {
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
    );
  }

  Map<String, dynamic> toJson() {
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
    };
  }

  // Helper methods
  bool get isActive => status == 'active';
  bool get isComingSoon => status == 'coming_soon';
  bool get canPlayOffline =>
      offline && url != null && url!.startsWith('assets/');
  bool get requiresInternet =>
      !offline || (url != null && url!.startsWith('http'));
}
