// lib/services/game_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game_item.dart';

class GameService {
  static const String baseUrl = 'http://192.168.1.18:8000';

  Future<List<GameItem>> fetchGames() async {
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
        return jsonData.map((json) => GameItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load games: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching games: $e');
    }
  }
}

// Alternative untuk testing tanpa server - disesuaikan dengan JSON asli
class MockGameService {
  Future<List<GameItem>> fetchGames() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    // Mock data sesuai dengan JSON asli (tanpa field featured)
    final mockData = [
      {
        'name': 'Tic Tac Toe',
        'route': 'games.tictactoe',
        'background_image': 'images/background/bg-tixtactoe.png',
        'icon': '❌⭕',
        'description': 'Game klasik X and O',
        'colors': {
          'hover_from': 'blue-800',
          'hover_to': 'blue-900',
          'border': 'blue-500',
          'glow_from': 'blue-600',
          'glow_to': 'blue-600',
          'button': 'blue-600',
          'button_hover': 'blue-500',
          'text_hover': 'blue-300',
          'corner': 'blue-500',
        },
        'status': 'active',
        'url': 'http://192.168.1.18:8000/game/tictactoe/index.html',
      },
      {
        'name': 'Snake Game',
        'route': 'games.snake',
        'background_image': 'images/background/bg-snake-game.png',
        'icon': '🐍',
        'description': 'Makan terus dan jangan tabrak tembok!',
        'colors': {
          'hover_from': 'green-800',
          'hover_to': 'green-900',
          'border': 'green-500',
          'glow_from': 'green-600',
          'glow_to': 'emerald-600',
          'button': 'green-600',
          'button_hover': 'green-500',
          'text_hover': 'green-300',
          'corner': 'green-500',
        },
        'status': 'coming_soon',
        'url': 'http://192.168.1.18:8000/game/snake/index.html',
      },
      {
        'name': 'Tetris Game',
        'route': 'games.tetris',
        'background_image': 'images/background/bg-tetris.png',
        'icon': '📱',
        'description':
            'Jatuhkan balok dengan rapi dan dapatkan skor tertinggi!',
        'colors': {
          'hover_from': 'purple-800',
          'hover_to': 'purple-900',
          'border': 'purple-500',
          'glow_from': 'purple-600',
          'glow_to': 'violet-600',
          'button': 'purple-600',
          'button_hover': 'purple-500',
          'text_hover': 'purple-300',
          'corner': 'purple-500',
        },
        'status': 'active',
        'url': 'http://192.168.1.18:8000/game/tetris/index.html',
      },
      {
        'name': 'Dino Game',
        'route': 'games.dino',
        'background_image': 'images/background/bg-dino-game.png',
        'icon': '🦖',
        'description': 'Mainkan game dino lompat yang paling populer di dunia!',
        'colors': {
          'hover_from': 'orange-800',
          'hover_to': 'orange-900',
          'border': 'orange-500',
          'glow_from': 'orange-600',
          'glow_to': 'red-600',
          'button': 'orange-600',
          'button_hover': 'orange-500',
          'text_hover': 'orange-300',
          'corner': 'orange-500',
        },
        'status': 'active',
        'url': 'http://192.168.1.18:8000/game/dino/index.html',
      },
      {
        'name': 'Puzzle Game',
        'route': null,
        'background_image': 'images/background/bg-puzzle-game.png',
        'icon': '🧩',
        'description': 'Sharpen your mind with challenging puzzles',
        'colors': {
          'hover_from': 'blue-800',
          'hover_to': 'blue-900',
          'border': 'blue-500',
          'glow_from': 'blue-600',
          'glow_to': 'cyan-600',
          'button': 'gray-600',
          'button_hover': 'gray-600',
          'text_hover': 'blue-300',
          'corner': 'blue-500',
        },
        'status': 'coming_soon',
        'url': null,
      },
      {
        'name': 'Memory Game',
        'route': null,
        'background_image': 'images/background/bg-memory-game.png',
        'icon': '🧠',
        'description': 'Test your memory with card matching games',
        'colors': {
          'hover_from': 'pink-800',
          'hover_to': 'pink-900',
          'border': 'pink-500',
          'glow_from': 'pink-600',
          'glow_to': 'rose-600',
          'button': 'gray-600',
          'button_hover': 'gray-600',
          'text_hover': 'pink-300',
          'corner': 'pink-500',
        },
        'status': 'coming_soon',
        'url': null,
      },
      {
        'name': 'Floppy Bird',
        'route': 'games.floppybird',
        'background_image': 'images/background/bg-flappy-bird.png',
        'icon': '🐦',
        'description': 'Ini dia game flappy bird yang populer dan adiktif!',
        'colors': {
          'hover_from': 'sky-800',
          'hover_to': 'sky-900',
          'border': 'sky-500',
          'glow_from': 'sky-600',
          'glow_to': 'cyan-600',
          'button': 'sky-600',
          'button_hover': 'sky-500',
          'text_hover': 'sky-300',
          'corner': 'sky-500',
        },
        'status': 'active',
        'url': 'http://192.168.1.18:8000/game/floppybird/index.html',
      },
      {
        'name': 'Candy Crush',
        'route': 'games.candycrush',
        'background_image': 'images/background/bg-candy-crush.png',
        'icon': '🍬',
        'description': 'Cocokan permen warna warni yang lezat!',
        'colors': {
          'hover_from': 'sky-800',
          'hover_to': 'sky-900',
          'border': 'sky-500',
          'glow_from': 'sky-600',
          'glow_to': 'cyan-600',
          'button': 'sky-600',
          'button_hover': 'sky-500',
          'text_hover': 'sky-300',
          'corner': 'sky-500',
        },
        'status': 'active',
        'url': 'http://192.168.1.18:8000/game/candycrush/index.html',
      },
      {
        'name': '2048',
        'route': 'games.2048',
        'background_image': 'images/background/bg-2048.png',
        'icon': '🔢',
        'description': 'Bisakah kamu mencapai 2048?',
        'colors': {
          'hover_from': 'sky-800',
          'hover_to': 'sky-900',
          'border': 'sky-500',
          'glow_from': 'sky-600',
          'glow_to': 'cyan-600',
          'button': 'sky-600',
          'button_hover': 'sky-500',
          'text_hover': 'sky-300',
          'corner': 'sky-500',
        },
        'status': 'active',
        'url': 'http://192.168.1.18:8000/game/2048/index.html',
      },
    ];

    return mockData.map((json) => GameItem.fromJson(json)).toList();
  }
}
