// lib/screens/games_screen.dart
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
  final String icon;
  final Color color;
  final Widget gameWidget;
  final bool isActive;
  final String? backgroundImage; // For featured games

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
    // Definisi semua games dengan thumbnail background untuk featured cards
    final allGames = [
      GameItem(
        name: 'Snake Game',
        subtitle: 'Classic snake adventure',
        icon: '🐍',
        color: const Color(0xFF4CAF50),
        gameWidget: const SnakeGame(),
        backgroundImage:
            'assets/images/thumbnails/snake_gameplay.png', // Ganti dengan path gambar Anda
      ),
      GameItem(
        name: 'Tic Tac Toe',
        subtitle: 'Strategic X vs O battle',
        icon: '⭕',
        color: const Color(0xFF2196F3),
        gameWidget: const TicTacToeGame(),
        backgroundImage: 'assets/images/thumbnails/tictactoe_gameplay.png',
      ),
      GameItem(
        name: 'Memory Game',
        subtitle: 'Test your memory skills',
        icon: '🧠',
        color: const Color(0xFF9C27B0),
        gameWidget: const MemoryGame(),
        backgroundImage: 'assets/images/thumbnails/memory_gameplay.png',
      ),
      GameItem(
        name: 'Pong Game',
        subtitle: 'Classic arcade ping pong',
        icon: '🏓',
        color: const Color(0xFFFF9800),
        gameWidget: const PongGame(),
        backgroundImage: 'assets/images/thumbnails/pong_gameplay.png',
      ),
      GameItem(
        name: 'Endless Runner',
        subtitle: 'Run as far as you can',
        icon: '🏃',
        color: const Color(0xFF009688),
        gameWidget: const EndlessRunnerGame(),
        backgroundImage: 'assets/images/thumbnails/runner_gameplay.png',
      ),
      GameItem(
        name: 'Pac-Man Game',
        subtitle: 'Chase the ghosts',
        icon: '👻',
        color: const Color(0xFFFFC107),
        gameWidget: const PacmanGame(),
        backgroundImage: 'assets/images/thumbnails/pacman_gameplay.png',
      ),
    ];

    _allGames = allGames.where((game) => game.isActive).toList();

    // Random select 2 featured games (sama seperti kode asli)
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F172A),
              const Color(0xFF1E293B),
              const Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Enhanced Header Section
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Column(
                    children: [
                      // Top header with greeting and logo
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
                                    fontSize: isTablet ? 32 : 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Welcome to MaxG Entertainment Hub',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    color: Colors.grey[300],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // MaxG Logo Container dengan GIF
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            // decoration: BoxDecoration(
                            //   gradient: LinearGradient(
                            //     colors: [
                            //       const Color(0xFF00B14F).withOpacity(0.2),
                            //       const Color(0xFF00B14F).withOpacity(0.1),
                            //     ],
                            //   ),
                            //   borderRadius: BorderRadius.circular(16),
                            //   border: Border.all(
                            //     color: const Color(0xFF00B14F).withOpacity(0.3),
                            //     width: 1.5,
                            //   ),

                            //   boxShadow: [
                            //     BoxShadow(
                            //       color: const Color(
                            //         0xFF00B14F,
                            //       ).withOpacity(0.1),
                            //       blurRadius: 8,
                            //       offset: const Offset(0, 2),
                            //     ),
                            //   ],
                            // ),
                            child: Image.asset(
                              'assets/images/logo/Logo-MaxG-White.gif',
                              height: isTablet ? 28 : 22,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  'MaxG',
                                  style: TextStyle(
                                    color: const Color(0xFF00B14F),
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 22 : 18,
                                    letterSpacing: 1.2,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      // Enhanced Main Title Section
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.white.withOpacity(0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF00B14F),
                                        Color(0xFF00D956),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    '🎮',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Mini Games Collection',
                                  style: TextStyle(
                                    fontSize: isTablet ? 28 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Mainkan Mini Games Seru selama perjalananmu!',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: Colors.grey[300],
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.amber, Colors.orange],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Featured Games',
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: isTablet ? 280 : 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                      ),
                      itemCount: _featuredGames.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final game = _featuredGames[index];
                        return _EnhancedFeaturedGameCard(
                          game: game,
                          isTablet: isTablet,
                          onTap: () =>
                              _navigateToGame(context, game.gameWidget),
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],

              // All Games Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B14F).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.grid_view_rounded,
                              color: Color(0xFF00B14F),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'All Games',
                            style: TextStyle(
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_allGames.length} Games',
                          style: TextStyle(
                            color: Colors.grey[300],
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
                    crossAxisSpacing: isTablet ? 20 : 12,
                    mainAxisSpacing: isTablet ? 20 : 12,
                    childAspectRatio: isTablet ? 0.9 : 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final game = _allGames[index];
                    return _EnhancedGameCard(
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
      // Floating Time Widget (like in web version)
      floatingActionButton: _buildFloatingTimeWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }

  Widget _buildFloatingTimeWidget() {
    return AnimatedBuilder(
      animation: _timeAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_timeAnimationController.value * 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.85),
                ],
              ),
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
                    color: const Color(0xFF00B14F),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentTime,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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

// Enhanced Featured Game Card
class _EnhancedFeaturedGameCard extends StatefulWidget {
  final GameItem game;
  final bool isTablet;
  final VoidCallback onTap;

  const _EnhancedFeaturedGameCard({
    required this.game,
    required this.isTablet,
    required this.onTap,
  });

  @override
  State<_EnhancedFeaturedGameCard> createState() =>
      _EnhancedFeaturedGameCardState();
}

class _EnhancedFeaturedGameCardState extends State<_EnhancedFeaturedGameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.isTablet ? 320 : 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.game.color.withOpacity(0.9),
                    widget.game.color.withOpacity(0.7),
                    widget.game.color.withOpacity(0.5),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.game.color.withOpacity(
                      0.4 + (_glowAnimation.value * 0.2),
                    ),
                    blurRadius: 15 + (_glowAnimation.value * 10),
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background Image dengan Fade Effect (mirip seperti blade)
                  if (widget.game.backgroundImage != null) ...[
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            // Background Image - posisi di sebelah kanan
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              width: 140, // setengah dari card width
                              child: Image.asset(
                                widget.game.backgroundImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback jika gambar tidak ditemukan
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          widget.game.color.withOpacity(0.3),
                                          widget.game.color.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Gradient overlay dari kiri ke kanan untuk efek fade
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      widget.game.color.withOpacity(
                                        0.95,
                                      ), // Hampir solid di kiri
                                      widget.game.color.withOpacity(
                                        0.8,
                                      ), // Medium di tengah
                                      widget.game.color.withOpacity(
                                        0.4,
                                      ), // Transparan di kanan
                                      Colors
                                          .transparent, // Fully transparent di ujung kanan
                                    ],
                                    stops: const [0.0, 0.4, 0.7, 1.0],
                                  ),
                                ),
                              ),
                            ),

                            // Additional gradient untuk memastikan readability content
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.black.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.6],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Original Background Pattern (sebagai fallback)
                  if (widget.game.backgroundImage == null)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.transparent,
                                Colors.black.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Featured Badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.amber, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.game.icon,
                            style: TextStyle(
                              fontSize: widget.isTablet ? 36 : 32,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.game.name,
                          style: TextStyle(
                            fontSize: widget.isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.game.subtitle,
                          style: TextStyle(
                            fontSize: widget.isTablet ? 15 : 13,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
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
          );
        },
      ),
    );
  }
}

// Enhanced Game Card
class _EnhancedGameCard extends StatefulWidget {
  final GameItem game;
  final bool isTablet;
  final VoidCallback onTap;

  const _EnhancedGameCard({
    required this.game,
    required this.isTablet,
    required this.onTap,
  });

  @override
  State<_EnhancedGameCard> createState() => _EnhancedGameCardState();
}

class _EnhancedGameCardState extends State<_EnhancedGameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.game.color.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.game.color.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Status indicator
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
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
                          child: Text(
                            widget.game.icon,
                            style: TextStyle(
                              fontSize: widget.isTablet ? 32 : 28,
                            ),
                          ),
                        ),
                        SizedBox(height: widget.isTablet ? 12 : 10),
                        Text(
                          widget.game.name,
                          style: TextStyle(
                            fontSize: widget.isTablet ? 16 : 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                            color: Colors.grey[300],
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
        },
      ),
    );
  }
}
