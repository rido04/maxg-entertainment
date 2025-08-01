// lib/screens/games_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'game_player_screen.dart';
import '../models/game_item.dart';
import '../services/game_service.dart'; // Updated import

class GamesScreen extends StatefulWidget {
  @override
  _GamesScreenState createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  late Future<List<GameItem>> _gamesFuture;
  late Timer _timer;
  String _currentTime = '';
  String _greeting = '';
  bool _isOnline = true;
  bool _isRefreshing = false;
  final OfflineGameService _gameService = OfflineGameService();

  @override
  void initState() {
    super.initState();
    _gamesFuture = _gameService.fetchGames();
    _updateTimeAndGreeting();
    _checkOnlineStatus();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTimeAndGreeting();
    });

    // Check online status periodically
    Timer.periodic(Duration(minutes: 1), (timer) {
      _checkOnlineStatus();
    });
  }

  // PERBAIKAN: Method untuk dispose timer
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // PERBAIKAN: Method untuk cek status online yang lebih reliable
  void _checkOnlineStatus() async {
    try {
      final isOnline = await _gameService.isOnline();
      print('🌐 Online status check: $isOnline'); // Debug log
      if (mounted && isOnline != _isOnline) {
        setState(() {
          _isOnline = isOnline;
        });
        print('📡 Status changed to: ${_isOnline ? 'Online' : 'Offline'}');
      }
    } catch (e) {
      print('❌ Error checking online status: $e');
      // Assume offline jika error
      if (mounted && _isOnline) {
        setState(() {
          _isOnline = false;
        });
      }
    }
  }

  // PERBAIKAN: Method untuk cek apakah game bisa dimainkan
  bool _canPlayGame(GameItem game) {
    // Jika online, semua game active bisa dimainkan
    if (_isOnline && game.isActive) {
      return true;
    }

    // Jika offline, cek apakah game support offline
    if (!_isOnline) {
      final canPlayOffline =
          game.offline &&
          game.url != null &&
          game.url!.startsWith('assets/') &&
          game.isActive;
      print(
        '🎮 Game ${game.name}: offline=${game.offline}, url=${game.url}, canPlay=$canPlayOffline',
      );
      return canPlayOffline;
    }

    return false;
  }

  void _updateTimeAndGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    setState(() {
      _currentTime = _formatTime(now);

      if (hour < 12) {
        _greeting = 'Good Morning';
      } else if (hour < 17) {
        _greeting = 'Good Afternoon';
      } else {
        _greeting = 'Good Evening';
      }
    });
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _refreshGames() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final refreshedGames = await _gameService.fetchGames(forceRefresh: true);
      setState(() {
        _gamesFuture = Future.value(refreshedGames);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Games updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh: Using cached data'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  // PERBAIKAN: Method untuk navigate ke game
  void _navigateToGame(GameItem game) async {
    print('🚀 Attempting to navigate to game: ${game.name}');
    print('🌐 Online status: $_isOnline');
    print('📱 Game offline: ${game.offline}');
    print('🔗 Game URL: ${game.url}');

    if (game.url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Game URL not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // PERBAIKAN: Cek kondisi offline dengan lebih baik
    if (!_isOnline && !game.offline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This game requires internet connection'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // For offline games, check if assets exist
    if (game.offline && game.url!.startsWith('assets/')) {
      final assetsExist = await _gameService.gameAssetsExist(game.url!);
      print('📁 Assets exist for ${game.name}: $assetsExist');
      if (!assetsExist) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Game files not found. Please update the app.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      print('✅ Navigating to game player...');
      // Navigate to game player screen with game name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              GamePlayerScreen(gameUrl: game.url!, gameName: game.name),
        ),
      );
    } catch (e) {
      print('❌ Navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load game: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Debug method - opsional untuk testing
  void _showDebugInfo() async {
    final cacheInfo = await _gameService.getCacheInfo();
    final isOnline = await _gameService.forceCheckOnline();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Debug Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Online Status: ${isOnline ? "🟢 Online" : "🔴 Offline"}'),
            Text('App Status: ${_isOnline ? "🟢 Online" : "🔴 Offline"}'),
            SizedBox(height: 8),
            Text('Cache Info:'),
            Text('- Has Cache: ${cacheInfo['hasCache']}'),
            Text('- Last Update: ${cacheInfo['lastUpdate']}'),
            Text('- Is Expired: ${cacheInfo['isExpired']}'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await _gameService.testOfflineGames();
                Navigator.pop(context);
              },
              child: Text('Test Offline Games'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isOnline = !_isOnline;
                });
                Navigator.pop(context);
              },
              child: Text('Toggle Online Status'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1e293b).withOpacity(0.9),
              Color(0xFF1e40af).withOpacity(0.7),
              Color(0xFF1f2937).withOpacity(0.9),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main Content
            RefreshIndicator(
              onRefresh: _refreshGames,
              child: CustomScrollView(
                slivers: [
                  // Header Section
                  SliverToBoxAdapter(child: _buildHeader()),

                  // Main Title Section
                  SliverToBoxAdapter(child: _buildMainTitle()),

                  // Content
                  SliverToBoxAdapter(
                    child: FutureBuilder<List<GameItem>>(
                      future: _gamesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(50),
                              child: Column(
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading games...',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Error loading games',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Using offline data',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _refreshGames,
                                    child: Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final games = snapshot.data!;
                        return Column(
                          children: [
                            _buildFeaturedGames(games),
                            _buildAllGames(games),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Connection Status
            _buildConnectionStatus(),

            // Current Time Display
            _buildTimeDisplay(),

            // Debug button - bisa dihapus di production
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.grey.withOpacity(0.7),
                onPressed: _showDebugInfo,
                child: Icon(Icons.bug_report, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time-based Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _greeting,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey[200],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    if (_isRefreshing)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white70,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Welcome to MaxG Entertainment Hub',
                  style: TextStyle(color: Colors.grey[300], fontSize: 12),
                ),
              ],
            ),
          ),

          // Logo Section
          Container(
            width: 100,
            height: 150,
            padding: EdgeInsets.all(8),
            child: Image.asset(
              'assets/images/logo/Maxg-ent_white.gif',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Positioned(
      top: 45,
      left: 16,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _isOnline
              ? Colors.green.withOpacity(0.8)
              : Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isOnline ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
              size: 12,
            ),
            SizedBox(width: 4),
            Text(
              _isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTitle() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Text(
            'Mini Games Collection',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[200],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            _isOnline
                ? 'Mainkan Mini Games Seru selama perjalananmu!'
                : 'Playing offline - Some games may not be available',
            style: TextStyle(
              color: _isOnline ? Colors.grey[300] : Colors.orange[300],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedGames(List<GameItem> games) {
    final featuredGames = games
        .where((game) => game.featured && game.status == 'active')
        .take(2)
        .toList();

    if (featuredGames.isEmpty) return SizedBox.shrink();

    return Column(
      children: featuredGames
          .map((game) => _buildFeaturedGameCard(game))
          .toList(),
    );
  }

  // PERBAIKAN: Method _buildFeaturedGameCard sekarang dalam class
  Widget _buildFeaturedGameCard(GameItem game) {
    final canPlay = _canPlayGame(game);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canPlay ? () => _navigateToGame(game) : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: canPlay
                    ? [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.7),
                        Colors.white.withOpacity(0.3),
                      ]
                    : [
                        Colors.grey.withOpacity(0.5),
                        Colors.grey.withOpacity(0.3),
                        Colors.grey.withOpacity(0.1),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Featured Badge
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.yellow[600]!, Colors.orange[600]!],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Status indicator
                if (!canPlay)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        !_isOnline && !game.offline
                            ? 'Requires Internet'
                            : 'Coming Soon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Content
                Row(
                  children: [
                    // Game Icon
                    Container(
                      width: 60,
                      height: 60,
                      child: Center(
                        child: Text(
                          game.icon,
                          style: TextStyle(
                            fontSize: 40,
                            color: canPlay ? null : Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 16),

                    // Game Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: canPlay
                                  ? Colors.grey[800]
                                  : Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            game.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: canPlay
                                  ? Colors.grey[700]
                                  : Colors.grey[400],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: canPlay
                                    ? [Colors.blue[600]!, Colors.blue[700]!]
                                    : [Colors.grey[400]!, Colors.grey[500]!],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  canPlay ? Icons.play_arrow : Icons.lock,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  canPlay ? 'Play Now' : 'Locked',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllGames(List<GameItem> games) {
    final allGames = games
        .where((game) => !game.featured && game.status == 'active')
        .toList();

    if (allGames.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Games',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: allGames.length,
            itemBuilder: (context, index) {
              final game = allGames[index];
              final canPlay = _canPlayGame(game);

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canPlay ? () => _navigateToGame(game) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: canPlay
                            ? [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ]
                            : [
                                Colors.grey.withOpacity(0.2),
                                Colors.grey.withOpacity(0.1),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Status indicator
                        if (!canPlay)
                          Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _isOnline ? 'Coming Soon' : 'Offline Only',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        // Game Icon
                        Text(
                          game.icon,
                          style: TextStyle(
                            fontSize: 40,
                            color: canPlay ? null : Colors.grey,
                          ),
                        ),
                        SizedBox(height: 12),

                        // Game Name
                        Text(
                          game.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: canPlay ? Colors.white : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),

                        // Play Button
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: canPlay
                                ? Colors.blue[600]
                                : Colors.grey[600],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                canPlay ? Icons.play_arrow : Icons.lock,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                canPlay ? 'Play' : 'Locked',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Positioned(
      top: 45,
      right: 16,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Text(
          _currentTime,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
