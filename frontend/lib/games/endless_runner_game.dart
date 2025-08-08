// lib/games/endless_runner_game.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class EndlessRunnerGame extends StatefulWidget {
  const EndlessRunnerGame({Key? key}) : super(key: key);

  @override
  State<EndlessRunnerGame> createState() => _EndlessRunnerGameState();
}

class _EndlessRunnerGameState extends State<EndlessRunnerGame>
    with TickerProviderStateMixin {
  // Game Variables
  Timer? gameTimer;
  double playerY = 0.5; // 0.0 = top, 1.0 = bottom
  double playerVelocity = 0;
  bool isJumping = false;
  bool gameStarted = false;
  bool gameOver = false;
  int score = 0;
  int coins = 0;
  double gameSpeed = 1.0;

  // Game Objects
  List<Obstacle> obstacles = [];
  List<Coin> gameCoins = [];
  double obstacleTimer = 0;
  double coinTimer = 0;

  // Animation Controllers
  late AnimationController playerAnimController;
  late AnimationController backgroundController;

  // Constants
  final double gravity = 0.008;
  final double jumpStrength = -0.15;
  final double groundLevel = 0.7;

  @override
  void initState() {
    super.initState();
    initializeAnimations();
  }

  void initializeAnimations() {
    playerAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..repeat(reverse: true);

    backgroundController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  void startGame() {
    if (gameStarted) return;

    setState(() {
      gameStarted = true;
      gameOver = false;
      score = 0;
      coins = 0;
      playerY = groundLevel;
      obstacles.clear();
      gameCoins.clear();
      gameSpeed = 1.0;
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      updateGame();
    });
  }

  void updateGame() {
    if (gameOver) return;

    setState(() {
      // Update score
      score += (gameSpeed * 0.5).round();

      // Increase difficulty
      if (score % 500 == 0) {
        gameSpeed += 0.1;
      }

      // Update player physics
      if (isJumping || playerY < groundLevel) {
        playerVelocity += gravity;
        playerY += playerVelocity;

        if (playerY >= groundLevel) {
          playerY = groundLevel;
          isJumping = false;
          playerVelocity = 0;
        }
      }

      // Spawn obstacles
      obstacleTimer += gameSpeed;
      if (obstacleTimer > 80) {
        spawnObstacle();
        obstacleTimer = 0;
      }

      // Spawn coins
      coinTimer += gameSpeed;
      if (coinTimer > 120) {
        spawnCoin();
        coinTimer = 0;
      }

      // Update obstacles
      obstacles.removeWhere((obstacle) {
        obstacle.x -= 0.02 * gameSpeed;
        return obstacle.x < -0.1;
      });

      // Update coins
      gameCoins.removeWhere((coin) {
        coin.x -= 0.02 * gameSpeed;
        return coin.x < -0.1;
      });

      // Check collisions
      checkCollisions();
    });
  }

  void spawnObstacle() {
    final random = Random();
    final type = random.nextInt(3);

    obstacles.add(
      Obstacle(
        x: 1.1,
        y: type == 0
            ? groundLevel + 0.1
            : groundLevel - 0.2, // Ground or air obstacle
        width: 0.08,
        height: type == 0 ? 0.15 : 0.08,
        type: type,
      ),
    );
  }

  void spawnCoin() {
    final random = Random();
    gameCoins.add(
      Coin(x: 1.1, y: groundLevel - random.nextDouble() * 0.3, size: 0.06),
    );
  }

  void checkCollisions() {
    // Check obstacle collisions
    for (final obstacle in obstacles) {
      if (obstacle.x < 0.2 && obstacle.x > 0.0) {
        if ((playerY + 0.08) > obstacle.y &&
            (playerY - 0.08) < (obstacle.y + obstacle.height)) {
          endGame();
          return;
        }
      }
    }

    // Check coin collisions
    gameCoins.removeWhere((coin) {
      if (coin.x < 0.2 && coin.x > 0.0) {
        if ((playerY - coin.y).abs() < 0.08) {
          coins++;
          return true;
        }
      }
      return false;
    });
  }

  void jump() {
    if (!isJumping && playerY >= groundLevel) {
      setState(() {
        isJumping = true;
        playerVelocity = jumpStrength;
      });
    }
  }

  void endGame() {
    setState(() {
      gameOver = true;
    });
    gameTimer?.cancel();
  }

  void resetGame() {
    gameTimer?.cancel();
    setState(() {
      gameStarted = false;
      gameOver = false;
      playerY = groundLevel;
      playerVelocity = 0;
      obstacles.clear();
      gameCoins.clear();
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    playerAnimController.dispose();
    backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: gameStarted ? jump : startGame,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0A0A2E),
                const Color(0xFF16213E),
                const Color(0xFF0F3460),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background effects
              _buildBackground(),

              // Game area
              if (gameStarted) _buildGameArea(),

              // UI
              _buildUI(),

              // Game over overlay
              if (gameOver) _buildGameOverOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: backgroundController,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(backgroundController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildGameArea() {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Ground line
        Positioned(
          bottom: size.height * (1 - groundLevel - 0.05),
          left: 0,
          right: 0,
          height: 4,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan.withOpacity(0.5),
                  Colors.cyan,
                  Colors.cyan.withOpacity(0.5),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),

        // Player
        AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          left: size.width * 0.1,
          bottom: size.height * (1 - playerY - 0.08),
          child: AnimatedBuilder(
            animation: playerAnimController,
            builder: (context, child) {
              return Transform.rotate(
                angle: playerVelocity * 2,
                child: Container(
                  width: size.width * 0.08,
                  height: size.height * 0.08,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.cyan, const Color(0xFF1565C0)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: playerAnimController.value * 3,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Obstacles
        ...obstacles.map((obstacle) => _buildObstacle(size, obstacle)),

        // Coins
        ...gameCoins.map((coin) => _buildCoin(size, coin)),
      ],
    );
  }

  Widget _buildObstacle(Size size, Obstacle obstacle) {
    Color color;
    switch (obstacle.type) {
      case 0: // Ground spike
        color = Colors.red;
        break;
      case 1: // Air block
        color = Colors.orange;
        break;
      default:
        color = Colors.purple;
    }

    return Positioned(
      left: size.width * obstacle.x,
      bottom: size.height * (1 - obstacle.y - obstacle.height),
      child: Container(
        width: size.width * obstacle.width,
        height: size.height * obstacle.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              Color.fromRGBO(
                color.red ~/ 1.5,
                color.green ~/ 1.5,
                color.blue ~/ 1.5,
                1.0,
              ),
            ],
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoin(Size size, Coin coin) {
    return Positioned(
      left: size.width * coin.x,
      bottom: size.height * (1 - coin.y - coin.size / 2),
      child: Container(
        width: size.width * coin.size,
        height: size.width * coin.size,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.yellow, const Color(0xFFE65100)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.8),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Icon(
          Icons.star,
          color: Colors.white,
          size: size.width * coin.size * 0.6,
        ),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top UI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                // Score and coins
                if (gameStarted) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Score: $score',
                        style: const TextStyle(
                          color: Colors.cyan,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '⭐ $coins',
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const Spacer(),

            // Start message
            if (!gameStarted && !gameOver) ...[
              Column(
                children: [
                  const Icon(
                    Icons.directions_run,
                    size: 80,
                    color: Colors.cyan,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '🏃‍♂️ Cyber Runner',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap to jump and avoid obstacles!',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.cyan, const Color(0xFF1976D2)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Text(
                      'TAP TO START',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '💥 GAME OVER',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Final Score: $score',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.cyan,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '⭐ Stars Collected: $coins',
              style: const TextStyle(fontSize: 18, color: Colors.yellow),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: resetGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'PLAY AGAIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'MENU',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Game Objects
class Obstacle {
  double x, y, width, height;
  int type;

  Obstacle({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.type,
  });
}

class Coin {
  double x, y, size;

  Coin({required this.x, required this.y, required this.size});
}

// Background Painter
class BackgroundPainter extends CustomPainter {
  final double animationValue;

  BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.1)
      ..strokeWidth = 2;

    // Moving lines effect
    for (int i = 0; i < 5; i++) {
      final x = (size.width * (i * 0.3 + animationValue)) % (size.width * 1.5);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height * 0.3, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
