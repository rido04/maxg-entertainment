// lib/services/game_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../models/game_item.dart';

class OfflineGameService {
  static const String baseUrl = 'http://192.168.1.18:8000';
  static const String _cacheKey = 'cached_games';
  static const String _lastUpdateKey = 'last_update';
  static const Duration _cacheExpiry = Duration(hours: 24);

  // Static local data dengan Flame games
  static final List<Map<String, dynamic>> _localGamesData = [
    // Flame-based games (Native Flutter games)
    {
      "name": "Snake Game",
      "route": "games.snake",
      "background_image": "assets/images/background/bg-snake-game.png",
      "icon": "🐍",
      "description": "Makan terus dan jangan tabrak tembok! (Native Flame)",
      "colors": {
        "hover_from": "green-800",
        "hover_to": "green-900",
        "border": "green-500",
        "glow_from": "green-600",
        "glow_to": "emerald-600",
        "button": "green-600",
        "button_hover": "green-500",
        "text_hover": "green-300",
        "corner": "green-500",
      },
      "status": "active",
      "featured": true,
      "offline": true,
      "game_type": "flame",
      "game_class": "SnakeGame",
    },
    {
      "name": "Tic Tac Toe",
      "route": "games.tictactoe",
      "background_image": "assets/images/background/bg-tixtactoe.png",
      "icon": "❌⭕",
      "description": "Game klasik X and O (Native Flame)",
      "colors": {
        "hover_from": "blue-800",
        "hover_to": "blue-900",
        "border": "blue-500",
        "glow_from": "blue-600",
        "glow_to": "blue-600",
        "button": "blue-600",
        "button_hover": "blue-500",
        "text_hover": "blue-300",
        "corner": "blue-500",
      },
      "status": "active",
      "featured": true,
      "offline": true,
      "game_type": "flame",
      "game_class": "TicTacToeGame",
    },
    {
      "name": "Tetris Game",
      "route": "games.tetris",
      "background_image": "assets/images/background/bg-tetris.png",
      "icon": "📱",
      "description":
          "Jatuhkan balok dengan rapi dan dapatkan skor tertinggi! (Coming Soon - Flame)",
      "colors": {
        "hover_from": "purple-800",
        "hover_to": "purple-900",
        "border": "purple-500",
        "glow_from": "purple-600",
        "glow_to": "violet-600",
        "button": "purple-600",
        "button_hover": "purple-500",
        "text_hover": "purple-300",
        "corner": "purple-500",
      },
      "status": "coming_soon",
      "featured": false,
      "offline": true,
      "game_type": "flame",
      "game_class": "TetrisGame",
    },

    // HTML-based games (Legacy WebView games)
    {
      "name": "Dino Game",
      "route": "games.dino",
      "background_image": "assets/images/background/bg-dino-game.png",
      "icon": "🦖",
      "description": "Game dino lompat klasik! (HTML Version)",
      "colors": {
        "hover_from": "orange-800",
        "hover_to": "orange-900",
        "border": "orange-500",
        "glow_from": "orange-600",
        "glow_to": "red-600",
        "button": "orange-600",
        "button_hover": "orange-500",
        "text_hover": "orange-300",
        "corner": "orange-500",
      },
      "status": "active",
      "featured": false,
      "url": "assets/games/dino/index.html",
      "offline": true,
      "game_type": "webview",
    },
    {
      "name": "Floppy Bird",
      "route": "games.floppybird",
      "background_image": "assets/images/background/bg-flappy-bird.png",
      "icon": "🐦",
      "description": "Game flappy bird yang populer! (HTML Version)",
      "colors": {
        "hover_from": "sky-800",
        "hover_to": "sky-900",
        "border": "sky-500",
        "glow_from": "sky-600",
        "glow_to": "cyan-600",
        "button": "sky-600",
        "button_hover": "sky-500",
        "text_hover": "sky-300",
        "corner": "sky-500",
      },
      "status": "active",
      "featured": false,
      "url": "assets/games/floppybird/index.html",
      "offline": true,
      "game_type": "webview",
    },
    {
      "name": "Candy Crush",
      "route": "games.candycrush",
      "background_image": "assets/images/background/bg-candy-crush.png",
      "icon": "🍬",
      "description": "Cocokan permen warna warni! (HTML Version)",
      "colors": {
        "hover_from": "sky-800",
        "hover_to": "sky-900",
        "border": "sky-500",
        "glow_from": "sky-600",
        "glow_to": "cyan-600",
        "button": "sky-600",
        "button_hover": "sky-500",
        "text_hover": "sky-300",
        "corner": "sky-500",
      },
      "status": "active",
      "featured": false,
      "url": "assets/games/candycrush/index.html",
      "offline": true,
      "game_type": "webview",
    },
    {
      "name": "2048",
      "route": "games.2048",
      "background_image": "assets/images/background/bg-2048.png",
      "icon": "🔢",
      "description": "Bisakah kamu mencapai 2048? (HTML Version)",
      "colors": {
        "hover_from": "sky-800",
        "hover_to": "sky-900",
        "border": "sky-500",
        "glow_from": "sky-600",
        "glow_to": "cyan-600",
        "button": "sky-600",
        "button_hover": "sky-500",
        "text_hover": "sky-300",
        "corner": "sky-500",
      },
      "status": "active",
      "featured": false,
      "url": "assets/games/2048/index.html",
      "offline": true,
      "game_type": "webview",
    },
  ];

  /// Fetch games dengan offline-first strategy
  Future<List<GameItem>> fetchGames({bool forceRefresh = false}) async {
    try {
      // 1. Load from cache first (jika tidak force refresh)
      if (!forceRefresh) {
        final cachedGames = await _loadFromCache();
        if (cachedGames.isNotEmpty) {
          print('📱 Loading games from cache');
          return cachedGames;
        }
      }

      // 2. Try to fetch from API
      print('🌐 Attempting to fetch games from API');
      final apiGames = await _fetchFromApi();
      if (apiGames.isNotEmpty) {
        // Merge with local games and prioritize offline games
        final mergedGames = _mergeWithLocalGames(apiGames);
        await _saveToCache(mergedGames);
        print('✅ Games fetched from API and merged with local games');
        return mergedGames;
      }
    } catch (e) {
      print('❌ API fetch failed: $e');
    }

    // 3. Fallback to local data
    print('💾 Using local fallback data');
    final localGames = _getLocalGames();
    await _saveToCache(localGames);
    return localGames;
  }

  /// Merge API games with local offline games
  List<GameItem> _mergeWithLocalGames(List<GameItem> apiGames) {
    final localGames = _getLocalGames();
    final Map<String, GameItem> gameMap = {};

    // Add local games first (they have offline capability)
    for (final game in localGames) {
      gameMap[game.name] = game;
    }

    // Add API games, but don't override local offline games
    for (final game in apiGames) {
      if (!gameMap.containsKey(game.name) || !gameMap[game.name]!.offline) {
        gameMap[game.name] = game;
      }
    }

    return gameMap.values.toList();
  }

  /// Load games from local cache
  Future<List<GameItem>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final lastUpdate = prefs.getInt(_lastUpdateKey) ?? 0;

      if (cachedData != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdate;
        final isExpired = cacheAge > _cacheExpiry.inMilliseconds;

        if (!isExpired) {
          final List<dynamic> jsonData = json.decode(cachedData);
          return jsonData.map((json) => GameItem.fromJson(json)).toList();
        } else {
          print('⏰ Cache expired, will refresh from API');
        }
      }
    } catch (e) {
      print('❌ Error loading from cache: $e');
    }
    return [];
  }

  /// Fetch games from API
  Future<List<GameItem>> _fetchFromApi() async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/games'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )
        .timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => GameItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load games: ${response.statusCode}');
    }
  }

  /// Get games from local static data
  List<GameItem> _getLocalGames() {
    return _localGamesData.map((json) => GameItem.fromJson(json)).toList();
  }

  /// Save games to local cache
  Future<void> _saveToCache(List<GameItem> games) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = games.map((game) => game.toJson()).toList();
      await prefs.setString(_cacheKey, json.encode(jsonData));
      await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('❌ Error saving to cache: $e');
    }
  }

  /// Check if game assets exist locally (for WebView games)
  Future<bool> gameAssetsExist(String assetPath) async {
    try {
      await rootBundle.loadString(assetPath);
      return true;
    } catch (e) {
      print('❌ Asset not found: $assetPath - $e');
      return false;
    }
  }

  /// Check if Flame game is available
  bool isFlameGameAvailable(String? gameClass) {
    if (gameClass == null) return false;

    // List of available Flame games
    const availableFlameGames = [
      'SnakeGame',
      'TicTacToeGame',
      // Add more as you implement them
    ];

    return availableFlameGames.contains(gameClass);
  }

  /// Clear cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_lastUpdateKey);
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    print('🔍 Checking online status...');

    // Method 1: Try to check internet connectivity first
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(Duration(seconds: 5));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('✅ Internet connection detected via DNS lookup');
        return true;
      }
    } catch (e) {
      print('❌ DNS lookup failed: $e');
    }

    // Method 2: Try to reach our API server
    try {
      final response = await http
          .head(Uri.parse(baseUrl))
          .timeout(Duration(seconds: 5));

      final isOnline = response.statusCode == 200;
      print(
        '🌐 API server check: ${isOnline ? 'Online' : 'Offline'} (Status: ${response.statusCode})',
      );
      return isOnline;
    } catch (e) {
      print('❌ API server check failed: $e');
    }

    // Method 3: Try a simple HTTP request to a reliable service
    try {
      final response = await http
          .head(Uri.parse('https://www.google.com'))
          .timeout(Duration(seconds: 5));

      final isOnline = response.statusCode == 200;
      print('🌐 Google connectivity check: ${isOnline ? 'Online' : 'Offline'}');
      return isOnline;
    } catch (e) {
      print('❌ Google connectivity check failed: $e');
    }

    print('📱 All connectivity checks failed, assuming offline');
    return false;
  }

  /// Force check online status untuk testing
  Future<bool> forceCheckOnline() async {
    print('🔄 Force checking online status...');
    return await isOnline();
  }

  /// Get cache info for debugging
  Future<Map<String, dynamic>> getCacheInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdateKey) ?? 0;
    final hasCache = prefs.containsKey(_cacheKey);

    return {
      'hasCache': hasCache,
      'lastUpdate': DateTime.fromMillisecondsSinceEpoch(lastUpdate),
      'cacheAge': DateTime.now().millisecondsSinceEpoch - lastUpdate,
      'isExpired':
          (DateTime.now().millisecondsSinceEpoch - lastUpdate) >
          _cacheExpiry.inMilliseconds,
    };
  }

  /// Test method untuk debugging offline games
  Future<void> testOfflineGames() async {
    print('🧪 Testing offline games...');
    final games = _getLocalGames();

    for (final game in games) {
      if (game.offline) {
        if (game.isFlameGame) {
          final available = isFlameGameAvailable(game.gameClass);
          print(
            '🎮 ${game.name} (Flame): ${available ? '✅' : '❌'} (${game.gameClass})',
          );
        } else if (game.url != null) {
          final exists = await gameAssetsExist(game.url!);
          print(
            '🎮 ${game.name} (WebView): ${exists ? '✅' : '❌'} (${game.url})',
          );
        }
      }
    }
  }
}
