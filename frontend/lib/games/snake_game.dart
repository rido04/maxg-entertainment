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

class _SnakeGameState extends State<SnakeGame> {
  static const int gridSize = 20;
  static const int gameSpeed = 200; // milliseconds

  List<Point<int>> snake = [Point(10, 10)];
  Point<int> food = Point(15, 15);
  Direction direction = Direction.right;
  bool isPlaying = false;
  bool gameOver = false;
  int score = 0;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    _generateFood();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
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
      } else {
        snake.removeLast();
      }
    });
  }

  void _gameOver() {
    gameTimer?.cancel();
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
      setState(() {
        direction = newDirection;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Snake Game - Score: $score'),
        backgroundColor: const Color(0xFF00B14F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00B14F), width: 2),
              ),
              child: CustomPaint(
                painter: SnakePainter(snake, food, gridSize),
                child: Container(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (gameOver)
                  Text(
                    'Game Over! Score: $score',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: isPlaying ? _pauseGame : _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B14F),
                      ),
                      child: Text(
                        gameOver
                            ? 'Start Again'
                            : (isPlaying ? 'Pause' : 'Start'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _resetGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Control buttons
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => _changeDirection(Direction.up),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00B14F),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _changeDirection(Direction.left),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                              color: Color(0xFF00B14F),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_left,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(width: 60),
                        GestureDetector(
                          onTap: () => _changeDirection(Direction.right),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                              color: Color(0xFF00B14F),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _changeDirection(Direction.down),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00B14F),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum Direction { up, down, left, right }

class SnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> food;
  final int gridSize;

  SnakePainter(this.snake, this.food, this.gridSize);

  @override
  void paint(Canvas canvas, Size size) {
    final double cellWidth = size.width / gridSize;
    final double cellHeight = size.height / gridSize;

    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
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

    // Draw snake
    for (int i = 0; i < snake.length; i++) {
      final point = snake[i];
      final rect = Rect.fromLTWH(
        point.x * cellWidth + 1,
        point.y * cellHeight + 1,
        cellWidth - 2,
        cellHeight - 2,
      );

      final snakePaint = Paint()
        ..color = i == 0 ? const Color(0xFF00B14F) : Colors.green.shade300;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        snakePaint,
      );
    }

    // Draw food
    final foodRect = Rect.fromLTWH(
      food.x * cellWidth + 2,
      food.y * cellHeight + 2,
      cellWidth - 4,
      cellHeight - 4,
    );

    final foodPaint = Paint()..color = Colors.red;

    canvas.drawOval(foodRect, foodPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
