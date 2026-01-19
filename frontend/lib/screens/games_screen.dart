// lib/screens/games_screen.dart - Professional version with Blade template styling
import 'package:flutter/material.dart';
import '../games/snake_game.dart';
import '../games/tic_tac_toe_game.dart';
import '../games/memory_game.dart';
import '../games/pong_game.dart';
import '../games/endless_runner_game.dart';
import '../games/pacman_game.dart';
import 'dart:math';

class GameItem {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget gameWidget;
  final bool isActive;
  final String? backgroundImage;

  GameItem({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gameWidget,
    this.isActive = true,
    this.backgroundImage,
  });
}

class GamesScreen extends StatefulWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen>
    with TickerProviderStateMixin {
  List<GameItem> _featuredGames = [];
  List<GameItem> _allGames = [];
  String _greeting = '';
  String _currentTime = '';
  late AnimationController _timeAnimationController;

  @override
  void initState() {
    super.initState();
    _timeAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _updateGreeting();
    _updateCurrentTime();
    _initializeGames();

    // Update time every second
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) {
        _updateCurrentTime();
      }
    });
  }

  @override
  void dispose() {
    _timeAnimationController.dispose();
    super.dispose();
  }

  void _initializeGames() {
    final allGames = [
      GameItem(
        name: 'Snake Game',
        subtitle: 'Classic snake adventure',
        icon: Icons.grid_4x4_rounded,
        color: const Color(0xFF22C55E),
        gameWidget: const SnakeGame(),
        backgroundImage: 'assets/games/snake/preview.png',
      ),
      GameItem(
        name: 'Tic Tac Toe',
        subtitle: 'Strategic X vs O battle',
        icon: Icons.grid_on_rounded,
        color: const Color(0xFF3B82F6),
        gameWidget: const TicTacToeGame(),
        backgroundImage: 'assets/games/tictactoe/preview.png',
      ),
      GameItem(
        name: 'Memory Game',
        subtitle: 'Test your memory skills',
        icon: Icons.psychology_rounded,
        color: const Color(0xFF8B5CF6),
        gameWidget: const MemoryGame(),
        backgroundImage: 'assets/games/memory/preview.png',
      ),
      GameItem(
        name: 'Pong Game',
        subtitle: 'Classic arcade ping pong',
        icon: Icons.sports_tennis_rounded,
        color: const Color(0xFFF59E0B),
        gameWidget: const PongGame(),
        backgroundImage: 'assets/games/pong/preview.png',
      ),
      GameItem(
        name: 'Endless Runner',
        subtitle: 'Run as far as you can',
        icon: Icons.directions_run_rounded,
        color: const Color(0xFF14B8A6),
        gameWidget: const EndlessRunnerGame(),
        backgroundImage: 'assets/games/runner/preview.png',
      ),
      GameItem(
        name: 'Pac-Man Game',
        subtitle: 'Chase the ghosts',
        icon: Icons.sports_esports_rounded,
        color: const Color(0xFFEAB308),
        gameWidget: const PacmanGame(),
        backgroundImage: 'assets/games/pacman/preview.png',
      ),
    ];

    _allGames = allGames.where((game) => game.isActive).toList();
    _selectFeaturedGames();
  }

  void _selectFeaturedGames() {
    final random = Random();
    final activeGames = _allGames.where((game) => game.isActive).toList();

    if (activeGames.length >= 2) {
      final shuffled = List<GameItem>.from(activeGames)..shuffle(random);
      _featuredGames = shuffled.take(2).toList();
    } else {
      _featuredGames = activeGames;
    }
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour < 17) {
      _greeting = 'Good Afternoon';
    } else {
      _greeting = 'Good Evening';
    }
  }

  void _updateCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour == 0
        ? 12
        : (now.hour > 12 ? now.hour - 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';

    setState(() {
      _currentTime = '$hour:$minute $period';
    });

    _timeAnimationController.forward().then((_) {
      _timeAnimationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background/Background_Color.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Column(
                    children: [
                      // Top header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _greeting,
                                  style: TextStyle(
                                    fontSize: isTablet ? 28 : 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[200],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Welcome to MaxG Entertainment Hub',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: Colors.grey[200],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Logo
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Image.asset(
                              'assets/images/logo/Maxg-ent_white.gif',
                              height: isTablet ? 48 : 36,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  'MaxG',
                                  style: TextStyle(
                                    color: Colors.grey[200],
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 24 : 20,
                                    letterSpacing: 1.2,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      // Main Title Section
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Mini Games Collection',
                              style: TextStyle(
                                fontSize: isTablet ? 28 : 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[200],
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Mainkan Mini Games Seru selama perjalananmu!',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: Colors.grey[200]?.withOpacity(0.9),
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Featured Games Section
              if (_featuredGames.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: 16,
                    ),
                    child: Text(
                      'Featured Games',
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[200],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final game = _featuredGames[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _FeaturedGameCard(
                          game: game,
                          isTablet: isTablet,
                          onTap: () =>
                              _navigateToGame(context, game.gameWidget),
                        ),
                      );
                    }, childCount: _featuredGames.length),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],

              // All Games Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Games',
                        style: TextStyle(
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[200],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_allGames.length} Games',
                          style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // All Games Grid
              SliverPadding(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 4 : 2,
                    crossAxisSpacing: isTablet ? 16 : 12,
                    mainAxisSpacing: isTablet ? 16 : 12,
                    childAspectRatio: isTablet ? 1.0 : 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final game = _allGames[index];
                    return _GameCard(
                      game: game,
                      isTablet: isTablet,
                      onTap: () => _navigateToGame(context, game.gameWidget),
                    );
                  }, childCount: _allGames.length),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
      // Floating Time Widget
      floatingActionButton: _buildFloatingTimeWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFloatingTimeWidget() {
    return AnimatedBuilder(
      animation: _timeAnimationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LOCAL TIME',
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _currentTime,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToGame(BuildContext context, Widget game) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => game,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: const Interval(0.3, 1.0)),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: fadeIn, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

// Featured Game Card
class _FeaturedGameCard extends StatefulWidget {
  final GameItem game;
  final bool isTablet;
  final VoidCallback onTap;

  const _FeaturedGameCard({
    required this.game,
    required this.isTablet,
    required this.onTap,
  });

  @override
  State<_FeaturedGameCard> createState() => _FeaturedGameCardState();
}

class _FeaturedGameCardState extends State<_FeaturedGameCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF3B82F6).withOpacity(0.5)
                : Colors.grey.withOpacity(0.2),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.05),
              blurRadius: _isHovered ? 12 : 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Image with Gradient Overlay
            if (widget.game.backgroundImage != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Image on right half
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Image.asset(
                          widget.game.backgroundImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.transparent),
                        ),
                      ),
                      // Gradient overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white.withOpacity(0.95),
                                Colors.white.withOpacity(0.7),
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.4, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Featured Badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEAB308), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEAB308).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'FEATURED',
                  style: TextStyle(
                    fontSize: widget.isTablet ? 11 : 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: widget.isTablet ? 64 : 56,
                    height: widget.isTablet ? 64 : 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.game.color.withOpacity(0.2),
                          widget.game.color.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.game.icon,
                      color: widget.game.color,
                      size: widget.isTablet ? 32 : 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.game.name,
                          style: TextStyle(
                            fontSize: widget.isTablet ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.game.subtitle,
                          style: TextStyle(
                            fontSize: widget.isTablet ? 14 : 13,
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Play Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: widget.isTablet ? 14 : 12,
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
            ),
          ],
        ),
      ),
    );
  }
}

// Regular Game Card
class _GameCard extends StatefulWidget {
  final GameItem game;
  final bool isTablet;
  final VoidCallback onTap;

  const _GameCard({
    required this.game,
    required this.isTablet,
    required this.onTap,
  });

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF3B82F6).withOpacity(0.5)
                : Colors.grey.withOpacity(0.2),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.05),
              blurRadius: _isHovered ? 12 : 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Status indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(widget.isTablet ? 20 : 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.game.color.withOpacity(0.2),
                          widget.game.color.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.game.icon,
                      color: widget.game.color,
                      size: widget.isTablet ? 32 : 28,
                    ),
                  ),
                  SizedBox(height: widget.isTablet ? 12 : 10),
                  Text(
                    widget.game.name,
                    style: TextStyle(
                      fontSize: widget.isTablet ? 16 : 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: widget.isTablet ? 6 : 4),
                  Text(
                    widget.game.subtitle,
                    style: TextStyle(
                      fontSize: widget.isTablet ? 13 : 11,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
