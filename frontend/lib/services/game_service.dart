// lib/services/game_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class GameModel {
  final String name;
  final String description;
  final String icon;
  final String route;
  final String? backgroundImage;
  final String status;
  final bool featured;
  final String? url;
  final Map<String, String>? colors;

  GameModel({
    required this.name,
    required this.description,
    required this.icon,
    required this.route,
    this.backgroundImage,
    required this.status,
    this.featured = false,
    this.url,
    this.colors,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🎮',
      route: json['route'] ?? '',
      backgroundImage: json['background_image'],
      status: json['status'] ?? 'active',
      featured: json['featured'] ?? false,
      url: json['url'],
      colors: json['colors'] != null
          ? Map<String, String>.from(json['colors'])
          : null,
    );
  }

  bool get isActive => status == 'active';
  bool get isComingSoon => status == 'coming_soon';
}

class GameService {
  static const String baseUrl =
      'http://your-laravel-backend.com'; // Ganti dengan URL backend kamu

  // Static data sebagai fallback atau untuk testing
  static List<GameModel> _getLocalGames() {
    return [
      GameModel(
        name: 'Tic Tac Toe',
        route: 'games.tictactoe',
        icon: '❌⭕',
        description: 'Game klasik X and O',
        status: 'active',
        backgroundImage: 'assets/images/bg-tictactoe.png',
        colors: {
          'hover_from': 'blue-800',
          'hover_to': 'blue-900',
          'border': 'blue-500',
        },
      ),
      GameModel(
        name: 'Snake Game',
        route: 'games.snake',
        icon: '🐍',
        description: 'Makan terus dan jangan tabrak tembok!',
        status: 'active',
        backgroundImage: 'assets/images/bg-snake-game.png',
        colors: {
          'hover_from': 'green-800',
          'hover_to': 'green-900',
          'border': 'green-500',
        },
      ),
      GameModel(
        name: 'Tetris Game',
        route: 'games.tetris',
        icon: '📱',
        description: 'Jatuhkan balok dengan rapi dan dapatkan skor tertinggi!',
        status: 'active',
        backgroundImage: 'assets/images/bg-tetris.png',
        colors: {
          'hover_from': 'purple-800',
          'hover_to': 'purple-900',
          'border': 'purple-500',
        },
      ),
      GameModel(
        name: 'Dino Game',
        route: 'games.dino',
        icon: '🦖',
        description: 'Mainkan game dino lompat yang paling populer di dunia!',
        status: 'active',
        backgroundImage: 'assets/images/bg-dino-game.png',
        colors: {
          'hover_from': 'orange-800',
          'hover_to': 'orange-900',
          'border': 'orange-500',
        },
      ),
      GameModel(
        name: 'Floppy Bird',
        route: 'games.floppybird',
        icon: '🐦',
        description: 'Ini dia game flappy bird yang populer dan adiktif!',
        status: 'active',
        backgroundImage: 'assets/images/bg-flappy-bird.png',
        colors: {
          'hover_from': 'sky-800',
          'hover_to': 'sky-900',
          'border': 'sky-500',
        },
      ),
      GameModel(
        name: 'Candy Crush',
        route: 'games.candycrush',
        icon: '🍬',
        description: 'Cocokan permen warna warni yang lezat!',
        status: 'active',
        backgroundImage: 'assets/images/bg-candy-crush.png',
        colors: {
          'hover_from': 'pink-800',
          'hover_to': 'pink-900',
          'border': 'pink-500',
        },
      ),
      GameModel(
        name: '2048',
        route: 'games.2048',
        icon: '🔢',
        description: 'Bisakah kamu mencapai 2048?',
        status: 'active',
        backgroundImage: 'assets/images/bg-2048.png',
        colors: {
          'hover_from': 'indigo-800',
          'hover_to': 'indigo-900',
          'border': 'indigo-500',
        },
      ),
      GameModel(
        name: 'Puzzle Game',
        route: '',
        icon: '🧩',
        description: 'Sharpen your mind with challenging puzzles',
        status: 'coming_soon',
        backgroundImage: 'assets/images/bg-puzzle-game.png',
      ),
      GameModel(
        name: 'Memory Game',
        route: '',
        icon: '🧠',
        description: 'Test your memory with card matching games',
        status: 'coming_soon',
        backgroundImage: 'assets/images/bg-memory-game.png',
      ),
    ];
  }

  // Fetch games from Laravel API
  static Future<List<GameModel>> fetchGamesFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/games'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => GameModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load games: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching games from API: $e');
      // Fallback to local data
      return _getLocalGames();
    }
  }

  // Get games with featured random selection (local logic)
  static Future<Map<String, List<GameModel>>> getGamesWithFeatured() async {
    List<GameModel> allGames;

    try {
      // Try to fetch from API first
      allGames = await fetchGamesFromAPI();
    } catch (e) {
      // Use local data as fallback
      allGames = _getLocalGames();
    }

    // Filter active games
    final activeGames = allGames.where((game) => game.isActive).toList();

    // Create a new list with featured selection
    final gamesWithFeatured = allGames
        .map(
          (game) => GameModel(
            name: game.name,
            route: game.route,
            icon: game.icon,
            description: game.description,
            status: game.status,
            backgroundImage: game.backgroundImage,
            url: game.url,
            colors: game.colors,
            featured: false, // Reset all to false first
          ),
        )
        .toList();

    // Random select featured games
    if (activeGames.length >= 2) {
      final random = Random();
      final activeIndices = <int>[];

      // Get indices of active games
      for (int i = 0; i < gamesWithFeatured.length; i++) {
        if (gamesWithFeatured[i].isActive) {
          activeIndices.add(i);
        }
      }

      // Randomly select 2 games to be featured
      activeIndices.shuffle(random);
      final featuredIndices = activeIndices.take(2).toList();

      // Update featured status
      for (final index in featuredIndices) {
        gamesWithFeatured[index] = GameModel(
          name: gamesWithFeatured[index].name,
          route: gamesWithFeatured[index].route,
          icon: gamesWithFeatured[index].icon,
          description: gamesWithFeatured[index].description,
          status: gamesWithFeatured[index].status,
          backgroundImage: gamesWithFeatured[index].backgroundImage,
          url: gamesWithFeatured[index].url,
          colors: gamesWithFeatured[index].colors,
          featured: true,
        );
      }
    }

    final featuredGames = gamesWithFeatured
        .where((game) => game.featured && game.isActive)
        .toList();

    return {
      'featured': featuredGames,
      'all': gamesWithFeatured.where((game) => game.isActive).toList(),
    };
  }

  // Convert colors from string to Flutter Colors
  static Color getColorFromString(String colorString, {double opacity = 1.0}) {
    final colorMap = {
      'blue-800': const Color(0xFF1E3A8A),
      'blue-900': const Color(0xFF1E40AF),
      'blue-500': const Color(0xFF3B82F6),
      'green-800': const Color(0xFF166534),
      'green-900': const Color(0xFF14532D),
      'green-500': const Color(0xFF22C55E),
      'purple-800': const Color(0xFF6B21A8),
      'purple-900': const Color(0xFF581C87),
      'purple-500': const Color(0xFF8B5CF6),
      'orange-800': const Color(0xFF9A3412),
      'orange-900': const Color(0xFF7C2D12),
      'orange-500': const Color(0xFFF97316),
      'sky-800': const Color(0xFF075985),
      'sky-900': const Color(0xFF0C4A6E),
      'sky-500': const Color(0xFF0EA5E9),
      'pink-800': const Color(0xFF9D174D),
      'pink-900': const Color(0xFF831843),
      'pink-500': const Color(0xFFEC4899),
      'indigo-800': const Color(0xFF3730A3),
      'indigo-900': const Color(0xFF312E81),
      'indigo-500': const Color(0xFF6366F1),
    };

    return (colorMap[colorString] ?? Colors.blue).withOpacity(opacity);
  }

  // Get primary color for a game based on its colors map
  static Color getPrimaryGameColor(GameModel game) {
    if (game.colors != null && game.colors!.containsKey('border')) {
      return getColorFromString(game.colors!['border']!);
    }

    // Default colors based on game name
    switch (game.name.toLowerCase()) {
      case 'snake game':
        return Colors.green;
      case 'tic tac toe':
        return Colors.blue;
      case 'tetris game':
        return Colors.purple;
      case 'dino game':
        return Colors.orange;
      case 'floppy bird':
        return Colors.cyan;
      case 'candy crush':
        return Colors.pink;
      case '2048':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }
}
