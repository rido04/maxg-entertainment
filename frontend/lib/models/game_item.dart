// lib/models/game_item.dart
class GameItem {
  final String name;
  final String? route;
  final String backgroundImage;
  final String icon;
  final String description;
  final Map<String, dynamic> colors;
  final String status;
  final String? url;

  GameItem({
    required this.name,
    this.route,
    required this.backgroundImage,
    required this.icon,
    required this.description,
    required this.colors,
    required this.status,
    this.url,
  });

  factory GameItem.fromJson(Map<String, dynamic> json) {
    return GameItem(
      name: json['name'] ?? '',
      route: json['route'],
      backgroundImage: json['background_image'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      colors: json['colors'] ?? {},
      status: json['status'] ?? '',
      url: json['url'],
    );
  }

  // Helper methods untuk logika bisnis
  bool get isActive => status == 'active';
  bool get isComingSoon => status == 'coming_soon';
  bool get hasUrl => url != null && url!.isNotEmpty;
  bool get hasRoute => route != null && route!.isNotEmpty;

  // Jika Anda butuh logika featured berdasarkan kriteria tertentu
  bool get isFeatured {
    // Contoh: game aktif dengan URL bisa dianggap featured
    return isActive && hasUrl;

    // Atau berdasarkan nama game tertentu
    // return ['Tic Tac Toe', 'Tetris Game'].contains(name);
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
      'url': url,
    };
  }
}
