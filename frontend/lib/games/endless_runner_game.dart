// lib/games/endless_runner_game.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class EndlessRunnerGame extends StatefulWidget {
  const EndlessRunnerGame({Key? key}) : super(key: key);

  @override
  State<EndlessRunnerGame> createState() => _EndlessRunnerGameState();
}

class _EndlessRunnerGameState extends State<EndlessRunnerGame>
    with SingleTickerProviderStateMixin {
  // Game Variables
  Timer? gameTimer;
  double playerY = 100.0; // Y position from bottom
  double playerVelocity = 0;
  bool isOnGround = true;
  bool gameStarted = false;
  bool gameOver = false;
  int score = 0;
  double gameSpeed = 5.0;

  // Game Objects
  List<GameObject> gameObjects = [];
  List<Particle> particles = [];
  double spawnTimer = 0;

  // Animation
  late AnimationController rotationController;

  // Constants
  final double gravity = 1200; // pixels per second²
  final double jumpVelocity = 550; // pixels per second (POSITIVE for up)
  final double playerSize = 30;
  final double groundY = 100; // Ground position from bottom

  @override
  void initState() {
    super.initState();
    rotationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();
  }

  void startGame() {
    if (gameStarted) return;

    setState(() {
      gameStarted = true;
      gameOver = false;
      score = 0;
      playerY = groundY;
      playerVelocity = 0;
      isOnGround = true;
      gameObjects.clear();
      particles.clear();
      gameSpeed = 5.0;
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      updateGame(0.016); // ~60 FPS
    });
  }

  void updateGame(double dt) {
    if (gameOver || !mounted) return;

    setState(() {
      // Update score
      score += (gameSpeed * 0.1).round();

      // Increase difficulty gradually
      if (score % 500 == 0 && gameSpeed < 12) {
        gameSpeed += 0.2;
      }

      // Update player physics
      if (!isOnGround) {
        playerVelocity -= gravity * dt; // Gravity pulls DOWN (negative)
        playerY += playerVelocity * dt;

        // Check if landed
        if (playerY <= groundY) {
          playerY = groundY;
          playerVelocity = 0;
          isOnGround = true;
        }
      }

      // Spawn objects
      spawnTimer += dt * gameSpeed;
      if (spawnTimer > 1.0) {
        spawnGameObject();
        spawnTimer = 0;
      }

      // Update game objects
      gameObjects.removeWhere((obj) {
        obj.x -= gameSpeed * dt * 100;
        return obj.x < -50;
      });

      // Update particles
      particles.removeWhere((p) {
        p.update(dt);
        return p.life <= 0;
      });

      // Check collisions
      checkCollisions();
    });
  }

  void spawnGameObject() {
    final random = Random();
    final type = random.nextInt(100);

    if (type < 60) {
      // Spike on ground
      gameObjects.add(
        GameObject(
          x: 400,
          y: groundY,
          width: 30,
          height: 30,
          type: GameObjectType.spike,
        ),
      );
    } else if (type < 85) {
      // Platform in air
      gameObjects.add(
        GameObject(
          x: 400,
          y: groundY + 80,
          width: 80,
          height: 20,
          type: GameObjectType.platform,
        ),
      );
    } else {
      // Moving spike in air
      gameObjects.add(
        GameObject(
          x: 400,
          y: groundY + 60,
          width: 25,
          height: 25,
          type: GameObjectType.movingSpike,
        ),
      );
    }
  }

  void checkCollisions() {
    final playerLeft = 50;
    final playerRight = 50 + playerSize;
    final playerBottom = playerY; // Bottom of player
    final playerTop = playerY + playerSize; // Top of player

    for (final obj in gameObjects) {
      if (obj.type == GameObjectType.platform) continue;

      final objLeft = obj.x;
      final objRight = obj.x + obj.width;
      final objBottom = obj.y; // Bottom of object
      final objTop = obj.y + obj.height; // Top of object

      // Simple AABB collision
      if (playerRight > objLeft &&
          playerLeft < objRight &&
          playerTop > objBottom &&
          playerBottom < objTop) {
        endGame();
        return;
      }
    }
  }

  void jump() {
    if (isOnGround && !gameOver) {
      setState(() {
        isOnGround = false;
        playerVelocity = jumpVelocity;
      });
      HapticFeedback.lightImpact();

      // Spawn jump particles
      for (int i = 0; i < 5; i++) {
        particles.add(
          Particle(
            x: 50 + playerSize / 2,
            y: playerY + playerSize,
            color: Colors.cyan,
          ),
        );
      }
    }
  }

  void endGame() {
    setState(() {
      gameOver = true;
    });
    gameTimer?.cancel();
    HapticFeedback.heavyImpact();

    // Death particles
    for (int i = 0; i < 15; i++) {
      particles.add(
        Particle(
          x: 50 + playerSize / 2,
          y: playerY + playerSize / 2,
          color: Colors.red,
        ),
      );
    }
  }

  void resetGame() {
    gameTimer?.cancel();
    setState(() {
      gameStarted = false;
      gameOver = false;
      playerY = groundY;
      playerVelocity = 0;
      isOnGround = true;
      gameObjects.clear();
      particles.clear();
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      body: GestureDetector(
        onTap: gameStarted ? jump : startGame,
        child: Stack(
          children: [
            // Game area
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF0D1421), const Color(0xFF1B2332)],
                ),
              ),
              child: gameStarted ? _buildGameArea() : _buildStartScreen(),
            ),

            // UI Overlay
            if (gameStarted) _buildUI(),

            // Game over overlay
            if (gameOver) _buildGameOverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: rotationController.value * 2 * pi,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            'GEOMETRY DASH',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.cyan,
              letterSpacing: 2,
              shadows: [Shadow(color: Colors.black, blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Tap to jump and avoid obstacles!',
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.cyan, Color(0xFF0D7377)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Text(
              'TAP TO START',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return CustomPaint(
      painter: GamePainter(
        playerY: playerY,
        playerSize: playerSize,
        groundY: groundY,
        gameObjects: gameObjects,
        particles: particles,
        rotationValue: rotationController.value,
        isOnGround: isOnGround,
      ),
      child: Container(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.cyan, size: 28),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.cyan, width: 2),
              ),
              child: Text(
                'SCORE: $score',
                style: const TextStyle(
                  color: Colors.cyan,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.9)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.close, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                letterSpacing: 2,
                shadows: [Shadow(color: Colors.black, blurRadius: 10)],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.cyan, width: 2),
              ),
              child: Text(
                'FINAL SCORE: $score',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    resetGame();
                    startGame();
                  },
                  icon: const Icon(Icons.replay, color: Colors.white),
                  label: const Text(
                    'PLAY AGAIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home, color: Colors.white70),
                  label: const Text(
                    'MENU',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
enum GameObjectType { spike, platform, movingSpike }

class GameObject {
  double x, y, width, height;
  GameObjectType type;

  GameObject({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.type,
  });
}

class Particle {
  double x, y;
  double vx, vy;
  Color color;
  double life;

  Particle({required this.x, required this.y, required this.color})
    : vx = (Random().nextDouble() - 0.5) * 200,
      vy = Random().nextDouble() * 150 + 50, // Positive = upward
      life = 1.0;

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    vy -= 500 * dt; // Gravity pulls down
    life -= dt * 2;
  }
}

// Game Painter
class GamePainter extends CustomPainter {
  final double playerY;
  final double playerSize;
  final double groundY;
  final List<GameObject> gameObjects;
  final List<Particle> particles;
  final double rotationValue;
  final bool isOnGround;

  GamePainter({
    required this.playerY,
    required this.playerSize,
    required this.groundY,
    required this.gameObjects,
    required this.particles,
    required this.rotationValue,
    required this.isOnGround,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw ground
    final groundPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, size.height - groundY, size.width, groundY),
      groundPaint,
    );

    // Draw ground line with glow
    final glowPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.5)
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawLine(
      Offset(0, size.height - groundY),
      Offset(size.width, size.height - groundY),
      glowPaint,
    );

    final linePaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(0, size.height - groundY),
      Offset(size.width, size.height - groundY),
      linePaint,
    );

    // Draw particles
    for (final particle in particles) {
      final particlePaint = Paint()
        ..color = particle.color.withOpacity(particle.life);

      canvas.drawCircle(
        Offset(particle.x, size.height - particle.y),
        3,
        particlePaint,
      );
    }

    // Draw game objects
    for (final obj in gameObjects) {
      switch (obj.type) {
        case GameObjectType.spike:
          _drawSpike(canvas, size, obj);
          break;
        case GameObjectType.platform:
          _drawPlatform(canvas, size, obj);
          break;
        case GameObjectType.movingSpike:
          _drawMovingSpike(canvas, size, obj);
          break;
      }
    }

    // Draw player with rotation
    canvas.save();
    canvas.translate(
      50 + playerSize / 2,
      size.height - playerY - playerSize / 2,
    );
    canvas.rotate(rotationValue * 2 * pi);

    // Player glow
    final playerGlow = Paint()
      ..color = Colors.cyan.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: playerSize + 10,
          height: playerSize + 10,
        ),
        const Radius.circular(8),
      ),
      playerGlow,
    );

    // Player body
    final playerPaint = Paint()..color = Colors.cyan;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: playerSize,
          height: playerSize,
        ),
        const Radius.circular(5),
      ),
      playerPaint,
    );

    canvas.restore();
  }

  void _drawSpike(Canvas canvas, Size size, GameObject obj) {
    final paint = Paint()..color = Colors.red;

    final glowPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    final baseY = size.height - obj.y;
    path.moveTo(obj.x, baseY);
    path.lineTo(obj.x + obj.width / 2, baseY - obj.height);
    path.lineTo(obj.x + obj.width, baseY);
    path.close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  void _drawPlatform(Canvas canvas, Size size, GameObject obj) {
    final paint = Paint()..color = Colors.orange;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          obj.x,
          size.height - obj.y - obj.height,
          obj.width,
          obj.height,
        ),
        const Radius.circular(4),
      ),
      paint,
    );
  }

  void _drawMovingSpike(Canvas canvas, Size size, GameObject obj) {
    final paint = Paint()..color = Colors.purple;
    final glowPaint = Paint()
      ..color = Colors.purple.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final centerY = size.height - obj.y - obj.height / 2;

    canvas.drawCircle(
      Offset(obj.x + obj.width / 2, centerY),
      obj.width / 2 + 5,
      glowPaint,
    );

    canvas.drawCircle(
      Offset(obj.x + obj.width / 2, centerY),
      obj.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    return true;
  }
}
