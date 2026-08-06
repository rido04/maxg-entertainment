// lib/games/snake_game.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class SnakeGame extends StatefulWidget {
  const SnakeGame({Key? key}) : super(key: key);

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame>
    with SingleTickerProviderStateMixin {
  static const int gridSize = 20;
  static const int gameSpeed = 200;

  List<Point<int>> snake = [Point(10, 10)];
  Point<int> food = Point(15, 15);
  Direction direction = Direction.right;
  Direction? pendingDirection;
  bool isPlaying = false;
  bool gameOver = false;
  int score = 0;
  Timer? gameTimer;

  // Single animation controller untuk food pulse
  late AnimationController _foodAnimationController;
  late Animation<double> _foodPulse;

  @override
  void initState() {
    super.initState();
    _generateFood();
    _setupAnimations();
  }

  void _setupAnimations() {
    _foodAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _foodPulse = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _foodAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _foodAnimationController.dispose();
    super.dispose();
  }

  void _generateFood() {
    final random = Random();
    Point<int> newFood;
    do {
      newFood = Point(random.nextInt(gridSize), random.nextInt(gridSize));
    } while (snake.contains(newFood));

    setState(() {
      food = newFood;
    });
  }

  void _startGame() {
    if (gameOver) {
      _resetGame();
    }

    setState(() {
      isPlaying = true;
    });

    gameTimer = Timer.periodic(Duration(milliseconds: gameSpeed), (timer) {
      _updateGame();
    });
  }

  void _pauseGame() {
    gameTimer?.cancel();
    setState(() {
      isPlaying = false;
    });
  }

  void _resetGame() {
    gameTimer?.cancel();
    setState(() {
      snake = [Point(10, 10)];
      direction = Direction.right;
      pendingDirection = null;
      score = 0;
      gameOver = false;
      isPlaying = false;
    });
    _generateFood();
  }

  void _updateGame() {
    // Apply pending direction untuk smooth control
    if (pendingDirection != null) {
      direction = pendingDirection!;
      pendingDirection = null;
    }

    Point<int> newHead;

    switch (direction) {
      case Direction.up:
        newHead = Point(snake.first.x, snake.first.y - 1);
        break;
      case Direction.down:
        newHead = Point(snake.first.x, snake.first.y + 1);
        break;
      case Direction.left:
        newHead = Point(snake.first.x - 1, snake.first.y);
        break;
      case Direction.right:
        newHead = Point(snake.first.x + 1, snake.first.y);
        break;
    }

    // Check wall collision
    if (newHead.x < 0 ||
        newHead.x >= gridSize ||
        newHead.y < 0 ||
        newHead.y >= gridSize) {
      _gameOver();
      return;
    }

    // Check self collision (cek SEBELUM insert head baru)
    if (snake.contains(newHead)) {
      _gameOver();
      return;
    }

    // Check food collision
    bool ateFood = (newHead == food);

    setState(() {
      snake.insert(0, newHead);

      if (ateFood) {
        score += 10;
        _generateFood();
        HapticFeedback.lightImpact();
      } else {
        snake.removeLast();
      }
    });
  }

  void _gameOver() {
    gameTimer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      gameOver = true;
      isPlaying = false;
    });
  }

  void _changeDirection(Direction newDirection) {
    if (!isPlaying && !gameOver) return;

    // Prevent reverse direction
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }

    HapticFeedback.selectionClick();
    pendingDirection = newDirection;
  }

  void _handleSwipe(DragEndDetails details) {
    if (!isPlaying || gameOver) return;

    final velocity = details.velocity.pixelsPerSecond;
    final dx = velocity.dx.abs();
    final dy = velocity.dy.abs();

    // Determine swipe direction based on velocity
    if (dx > dy) {
      // Horizontal swipe
      if (velocity.dx > 0) {
        _changeDirection(Direction.right);
      } else {
        _changeDirection(Direction.left);
      }
    } else {
      // Vertical swipe
      if (velocity.dy > 0) {
        _changeDirection(Direction.down);
      } else {
        _changeDirection(Direction.up);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00B14F)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'SCORE: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Text(
                'LENGTH: ${snake.length}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B2332),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00E676)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPlaying
                  ? Colors.green.withOpacity(0.2)
                  : (gameOver
                        ? Colors.red.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isPlaying
                    ? Colors.green
                    : (gameOver ? Colors.red : Colors.grey),
              ),
            ),
            child: Text(
              gameOver ? 'GAME OVER' : (isPlaying ? 'PLAYING' : 'PAUSED'),
              style: TextStyle(
                color: isPlaying
                    ? Colors.green
                    : (gameOver ? Colors.red : Colors.grey),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.0, // Force square ratio untuk prevent gepeng
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Game Canvas (square/proporsional)
                Expanded(
                  child: GestureDetector(
                    onVerticalDragEnd: _handleSwipe,
                    onHorizontalDragEnd: _handleSwipe,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          center: Alignment.center,
                          colors: [Color(0xFF1B2332), Color(0xFF0D1421)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00B14F).withOpacity(0.5),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00B14F).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: Stack(
                          children: [
                            // Game canvas with AnimatedBuilder hanya untuk food
                            AnimatedBuilder(
                              animation: _foodPulse,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: OptimizedSnakePainter(
                                    snake,
                                    food,
                                    gridSize,
                                    _foodPulse.value,
                                  ),
                                  child: Container(),
                                );
                              },
                            ),

                            // Swipe hint overlay (hanya muncul saat pause)
                            if (!isPlaying && !gameOver)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.swipe,
                                        color: Color(0xFF00E676),
                                        size: 48,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'SWIPE TO CONTROL',
                                        style: TextStyle(
                                          color: Color(0xFF00E676),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Swipe up, down, left, or right to move',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Game Over overlay
                            if (gameOver)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.red,
                                            width: 3,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 48,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'GAME OVER',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF00E676),
                                              Color(0xFF00B14F),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          'FINAL SCORE: $score',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGameButton(
                      isPlaying ? 'PAUSE' : (gameOver ? 'PLAY AGAIN' : 'START'),
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      isPlaying ? _pauseGame : _startGame,
                      isPlaying ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 16),
                    _buildGameButton(
                      'RESET',
                      Icons.refresh,
                      _resetGame,
                      const Color(0xFF00B14F),
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

  Widget _buildGameButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 24),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 1,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 8,
        shadowColor: color.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    );
  }
}

enum Direction { up, down, left, right }

class OptimizedSnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> food;
  final int gridSize;
  final double foodScale;

  OptimizedSnakePainter(this.snake, this.food, this.gridSize, this.foodScale);

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = min(size.width, size.height) / gridSize;

    // Draw subtle grid (optimized - hanya garis tipis)
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= gridSize; i++) {
      final offset = i * cellSize;
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset, gridSize * cellSize),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, offset),
        Offset(gridSize * cellSize, offset),
        gridPaint,
      );
    }

    // Draw snake dengan optimized rendering
    final headPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF00E676), const Color(0xFF00B14F)],
      ).createShader(Rect.fromLTWH(0, 0, cellSize, cellSize));

    for (int i = 0; i < snake.length; i++) {
      final point = snake[i];
      final rect = Rect.fromLTWH(
        point.x * cellSize + 2,
        point.y * cellSize + 2,
        cellSize - 4,
        cellSize - 4,
      );

      final bool isHead = i == 0;

      if (isHead) {
        // Head dengan glow
        final glowPaint = Paint()
          ..color = const Color(0xFF00E676).withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(3), const Radius.circular(8)),
          glowPaint,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          headPaint,
        );

        // Simple eyes
        final eyeSize = cellSize * 0.12;
        final eyePaint = Paint()..color = Colors.white;
        final pupilPaint = Paint()..color = Colors.black;

        final leftEye = Offset(
          rect.center.dx - eyeSize * 1.5,
          rect.center.dy - eyeSize,
        );
        final rightEye = Offset(
          rect.center.dx + eyeSize * 1.5,
          rect.center.dy - eyeSize,
        );

        canvas.drawCircle(leftEye, eyeSize, eyePaint);
        canvas.drawCircle(rightEye, eyeSize, eyePaint);
        canvas.drawCircle(leftEye, eyeSize * 0.5, pupilPaint);
        canvas.drawCircle(rightEye, eyeSize * 0.5, pupilPaint);
      } else {
        // Body dengan opacity gradient
        final alpha = (255 * (1 - i / snake.length * 0.6)).toInt();
        final bodyPaint = Paint()..color = Color.fromARGB(alpha, 0, 182, 83);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          bodyPaint,
        );
      }
    }

    // Draw food dengan pulse effect
    final foodRect = Rect.fromLTWH(
      food.x * cellSize + 3,
      food.y * cellSize + 3,
      cellSize - 6,
      cellSize - 6,
    );

    final scaledRect = Rect.fromCenter(
      center: foodRect.center,
      width: foodRect.width * foodScale,
      height: foodRect.height * foodScale,
    );

    // Glow
    final glowPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(scaledRect.inflate(6), glowPaint);

    // Food gradient
    final foodPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.red.shade400, Colors.red.shade700],
      ).createShader(scaledRect);
    canvas.drawOval(scaledRect, foodPaint);

    // Highlight
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.7);
    canvas.drawOval(
      Rect.fromCenter(
        center: scaledRect.center,
        width: scaledRect.width * 0.35,
        height: scaledRect.height * 0.35,
      ),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(OptimizedSnakePainter oldDelegate) {
    return snake != oldDelegate.snake ||
        food != oldDelegate.food ||
        foodScale != oldDelegate.foodScale;
  }
}
