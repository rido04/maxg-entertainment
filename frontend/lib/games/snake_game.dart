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

class _SnakeGameState extends State<SnakeGame> with TickerProviderStateMixin {
  static const int gridSize = 20;
  static const int gameSpeed = 200;

  List<Point<int>> snake = [Point(10, 10)];
  Point<int> food = Point(15, 15);
  Direction direction = Direction.right;
  bool isPlaying = false;
  bool gameOver = false;
  int score = 0;
  Timer? gameTimer;

  // Animation controllers untuk efek visual
  late AnimationController _foodAnimationController;
  late AnimationController _gameOverAnimationController;

  @override
  void initState() {
    super.initState();
    _generateFood();
    _setupAnimations();
  }

  void _setupAnimations() {
    _foodAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _gameOverAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _foodAnimationController.dispose();
    _gameOverAnimationController.dispose();
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
    _gameOverAnimationController.reset();
    setState(() {
      snake = [Point(10, 10)];
      direction = Direction.right;
      score = 0;
      gameOver = false;
      isPlaying = false;
    });
    _generateFood();
  }

  void _updateGame() {
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

    // Check self collision
    if (snake.contains(newHead)) {
      _gameOver();
      return;
    }

    setState(() {
      snake.insert(0, newHead);

      // Check food collision
      if (newHead == food) {
        score += 10;
        _generateFood();
        HapticFeedback.lightImpact(); // Haptic feedback saat makan
      } else {
        snake.removeLast();
      }
    });
  }

  void _gameOver() {
    gameTimer?.cancel();
    _gameOverAnimationController.forward();
    HapticFeedback.heavyImpact(); // Haptic feedback saat game over
    setState(() {
      gameOver = true;
      isPlaying = false;
    });
  }

  void _changeDirection(Direction newDirection) {
    // Prevent reverse direction
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }

    if (isPlaying) {
      HapticFeedback.selectionClick(); // Haptic feedback saat ubah arah
      setState(() {
        direction = newDirection;
      });
    }
  }

  Widget _buildControlButton(
    Direction dir,
    IconData icon, {
    bool isCenter = false,
  }) {
    bool isPressed = direction == dir && isPlaying;

    return GestureDetector(
      onTap: () => _changeDirection(dir),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(isCenter ? 18 : 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPressed
                ? [const Color(0xFF00E676), const Color(0xFF00B14F)]
                : [const Color(0xFF00B14F), const Color(0xFF00A047)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00B14F).withOpacity(0.4),
              blurRadius: isPressed ? 15 : 8,
              spreadRadius: isPressed ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: isCenter ? 35 : 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00B14F)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Spacer(),
            if (snake.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Length: ${snake.length}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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
      ),
      body: Row(
        children: [
          // Game Area (mengambil sebagian besar layar)
          Expanded(
            flex: 7,
            child: Column(
              children: [
                // Status bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1B2332),
                        const Color(0xFF0D1421),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatusItem('🐍', 'Snake', '${snake.length}'),
                      _buildStatusItem('🎯', 'Score', '$score'),
                      _buildStatusItem(
                        isPlaying ? '▶️' : (gameOver ? '💀' : '⏸️'),
                        'Status',
                        gameOver
                            ? 'Game Over'
                            : (isPlaying ? 'Playing' : 'Paused'),
                      ),
                    ],
                  ),
                ),

                // Game Canvas
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        colors: [
                          const Color(0xFF1B2332),
                          const Color(0xFF0D1421),
                        ],
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
                          // Game canvas
                          CustomPaint(
                            painter: EnhancedSnakePainter(
                              snake,
                              food,
                              gridSize,
                              _foodAnimationController,
                            ),
                            child: Container(),
                          ),

                          // Game Over overlay
                          if (gameOver)
                            AnimatedBuilder(
                              animation: _gameOverAnimationController,
                              builder: (context, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(
                                      0.8 * _gameOverAnimationController.value,
                                    ),
                                    borderRadius: BorderRadius.circular(17),
                                  ),
                                  child: Center(
                                    child: Transform.scale(
                                      scale: _gameOverAnimationController.value,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            '💀',
                                            style: TextStyle(fontSize: 50),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            'GAME OVER',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Final Score: $score',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
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
                    ),
                  ),
                ),

                // Control buttons row
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildGameButton(
                        isPlaying
                            ? 'Pause'
                            : (gameOver ? 'Play Again' : 'Start'),
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        isPlaying ? _pauseGame : _startGame,
                        Colors.green,
                      ),
                      _buildGameButton(
                        'Reset',
                        Icons.refresh,
                        _resetGame,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Control Panel (D-pad di samping kanan)
          Container(
            width: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1B2332), const Color(0xFF0D1421)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                left: BorderSide(
                  color: const Color(0xFF00B14F).withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'CONTROLS',
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 30),

                // D-pad layout
                Column(
                  children: [
                    // Up button
                    _buildControlButton(Direction.up, Icons.keyboard_arrow_up),
                    const SizedBox(height: 15),

                    // Left, Center, Right row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildControlButton(
                          Direction.left,
                          Icons.keyboard_arrow_left,
                        ),
                        const SizedBox(width: 15),
                        _buildControlButton(
                          Direction.right,
                          Icons.keyboard_arrow_right,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Down button
                    _buildControlButton(
                      Direction.down,
                      Icons.keyboard_arrow_down,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Direction indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B14F).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getDirectionArrow(direction),
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        _getDirectionText(direction),
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildStatusItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00E676),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 5,
        shadowColor: color.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  String _getDirectionArrow(Direction dir) {
    switch (dir) {
      case Direction.up:
        return '⬆️';
      case Direction.down:
        return '⬇️';
      case Direction.left:
        return '⬅️';
      case Direction.right:
        return '➡️';
    }
  }

  String _getDirectionText(Direction dir) {
    switch (dir) {
      case Direction.up:
        return 'UP';
      case Direction.down:
        return 'DOWN';
      case Direction.left:
        return 'LEFT';
      case Direction.right:
        return 'RIGHT';
    }
  }
}

enum Direction { up, down, left, right }

class EnhancedSnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> food;
  final int gridSize;
  final AnimationController foodAnimation;

  EnhancedSnakePainter(
    this.snake,
    this.food,
    this.gridSize,
    this.foodAnimation,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final double cellWidth = size.width / gridSize;
    final double cellHeight = size.height / gridSize;

    // Draw subtle grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= gridSize; i++) {
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.width, i * cellHeight),
        gridPaint,
      );
    }

    // Draw snake dengan gradient dan efek glow
    for (int i = 0; i < snake.length; i++) {
      final point = snake[i];
      final rect = Rect.fromLTWH(
        point.x * cellWidth + 2,
        point.y * cellHeight + 2,
        cellWidth - 4,
        cellHeight - 4,
      );

      // Snake head lebih besar dan berbeda warna
      final bool isHead = i == 0;
      final paint = Paint();

      if (isHead) {
        paint.shader = RadialGradient(
          colors: [
            const Color(0xFF00E676),
            const Color(0xFF00B14F),
            const Color(0xFF00A047),
          ],
        ).createShader(rect);
      } else {
        // Body dengan gradient yang memudar
        final alpha = (255 * (1 - i / snake.length * 0.7)).toInt();
        paint.color = Color.fromARGB(alpha, 0, 177, 79);
      }

      // Glow effect untuk head
      if (isHead) {
        final glowPaint = Paint()
          ..color = const Color(0xFF00E676).withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(4), const Radius.circular(8)),
          glowPaint,
        );
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(isHead ? 8 : 6)),
        paint,
      );

      // Snake eyes untuk head
      if (isHead) {
        final eyeSize = cellWidth * 0.15;
        final eyePaint = Paint()..color = Colors.white;

        canvas.drawCircle(
          Offset(rect.center.dx - eyeSize, rect.center.dy - eyeSize / 2),
          eyeSize / 2,
          eyePaint,
        );
        canvas.drawCircle(
          Offset(rect.center.dx + eyeSize, rect.center.dy - eyeSize / 2),
          eyeSize / 2,
          eyePaint,
        );

        // Pupils
        final pupilPaint = Paint()..color = Colors.black;
        canvas.drawCircle(
          Offset(rect.center.dx - eyeSize, rect.center.dy - eyeSize / 2),
          eyeSize / 4,
          pupilPaint,
        );
        canvas.drawCircle(
          Offset(rect.center.dx + eyeSize, rect.center.dy - eyeSize / 2),
          eyeSize / 4,
          pupilPaint,
        );
      }
    }

    // Draw food dengan animasi dan glow effect
    final foodRect = Rect.fromLTWH(
      food.x * cellWidth + 3,
      food.y * cellHeight + 3,
      cellWidth - 6,
      cellHeight - 6,
    );

    // Pulsing glow effect
    final glowRadius = 15 + (foodAnimation.value * 10);
    final glowPaint = Paint()
      ..color = Colors.red.withOpacity(0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, glowRadius);

    canvas.drawOval(foodRect.inflate(glowRadius), glowPaint);

    // Food dengan gradient
    final foodPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.red.shade400, Colors.red.shade600, Colors.red.shade800],
      ).createShader(foodRect);

    // Pulsing scale effect
    final scale = 1.0 + (foodAnimation.value * 0.2);
    final scaledRect = Rect.fromCenter(
      center: foodRect.center,
      width: foodRect.width * scale,
      height: foodRect.height * scale,
    );

    canvas.drawOval(scaledRect, foodPaint);

    // Food highlight
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.6);
    canvas.drawOval(
      Rect.fromCenter(
        center: scaledRect.center,
        width: scaledRect.width * 0.4,
        height: scaledRect.height * 0.4,
      ),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
