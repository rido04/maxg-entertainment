// lib/games/flame/snake_game.dart
import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SnakeGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  static const int gridSize = 20;
  late int gridWidth;
  late int gridHeight;

  late Snake snake;
  late Food food;
  late ScoreComponent scoreComponent;
  late GameOverComponent gameOverComponent;

  int score = 0;
  bool isGameOver = false;
  bool isPaused = false;
  async.Timer? gameTimer; // Use alias

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Calculate grid dimensions based on screen size
    gridWidth = (size.x / gridSize).floor();
    gridHeight = (size.y / gridSize).floor();

    // Initialize game components
    snake = Snake(gridWidth, gridHeight);
    food = Food(gridWidth, gridHeight);
    scoreComponent = ScoreComponent();
    gameOverComponent = GameOverComponent();

    add(snake);
    add(food);
    add(scoreComponent);
    add(gameOverComponent);

    // Generate first food
    generateFood();

    // Start game loop
    startGameLoop();
  }

  void startGameLoop() {
    gameTimer?.cancel();
    gameTimer = async.Timer.periodic(const Duration(milliseconds: 200), (
      timer,
    ) {
      if (isGameOver || isPaused) {
        timer.cancel();
        return;
      }
      updateGame();
    });
  }

  void updateGame() {
    if (isGameOver || isPaused) return;

    // Move snake
    snake.move();

    // Check collision with food
    if (snake.head.x == food.position.x && snake.head.y == food.position.y) {
      snake.grow();
      score += 10;
      scoreComponent.updateScore(score);
      generateFood();
    }

    // Check game over conditions
    if (snake.checkSelfCollision() ||
        snake.checkWallCollision(gridWidth, gridHeight)) {
      gameOver();
    }
  }

  void generateFood() {
    final random = Random();
    Vector2 newPosition;

    do {
      newPosition = Vector2(
        random.nextInt(gridWidth).toDouble(),
        random.nextInt(gridHeight).toDouble(),
      );
    } while (snake.occupiesPosition(newPosition));

    food.updatePosition(newPosition);
  }

  void gameOver() {
    isGameOver = true;
    gameTimer?.cancel();
    gameOverComponent.show(score);
  }

  void restart() {
    isGameOver = false;
    isPaused = false;
    score = 0;

    snake.reset();
    scoreComponent.updateScore(score);
    gameOverComponent.hide();
    generateFood();
    startGameLoop();
  }

  void pauseGame() {
    isPaused = !isPaused;
    if (!isPaused && !isGameOver) {
      startGameLoop();
    } else {
      gameTimer?.cancel();
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        snake.changeDirection(Direction.up);
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
        snake.changeDirection(Direction.down);
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        snake.changeDirection(Direction.left);
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        snake.changeDirection(Direction.right);
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.space)) {
        if (isGameOver) {
          restart();
        } else {
          pauseGame();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void onRemove() {
    gameTimer?.cancel();
    super.onRemove();
  }
}

enum Direction { up, down, left, right }

class Snake extends Component with HasGameRef<SnakeGame> {
  List<Vector2> body = [];
  Direction direction = Direction.right;
  Direction? nextDirection;

  final int gridWidth;
  final int gridHeight;

  Snake(this.gridWidth, this.gridHeight) {
    reset();
  }

  void reset() {
    body.clear();
    direction = Direction.right;
    nextDirection = null;

    // Initialize snake in the center
    final centerX = gridWidth ~/ 2;
    final centerY = gridHeight ~/ 2;

    body.add(Vector2(centerX.toDouble(), centerY.toDouble()));
    body.add(Vector2(centerX - 1.0, centerY.toDouble()));
    body.add(Vector2(centerX - 2.0, centerY.toDouble()));
  }

  Vector2 get head => body.first;

  void changeDirection(Direction newDirection) {
    // Prevent reverse direction
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    nextDirection = newDirection;
  }

  void move() {
    if (nextDirection != null) {
      direction = nextDirection!;
      nextDirection = null;
    }

    final head = this.head.clone();

    switch (direction) {
      case Direction.up:
        head.y -= 1;
        break;
      case Direction.down:
        head.y += 1;
        break;
      case Direction.left:
        head.x -= 1;
        break;
      case Direction.right:
        head.x += 1;
        break;
    }

    body.insert(0, head);
    body.removeLast();
  }

  void grow() {
    final tail = body.last.clone();
    body.add(tail);
  }

  bool checkSelfCollision() {
    final head = this.head;
    for (int i = 1; i < body.length; i++) {
      if (body[i].x == head.x && body[i].y == head.y) {
        return true;
      }
    }
    return false;
  }

  bool checkWallCollision(int gridWidth, int gridHeight) {
    final head = this.head;
    return head.x < 0 ||
        head.x >= gridWidth ||
        head.y < 0 ||
        head.y >= gridHeight;
  }

  bool occupiesPosition(Vector2 position) {
    return body.any(
      (segment) => segment.x == position.x && segment.y == position.y,
    );
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.green;
    final headPaint = Paint()..color = Colors.green[800]!;

    for (int i = 0; i < body.length; i++) {
      final segment = body[i];
      final rect = Rect.fromLTWH(
        segment.x * SnakeGame.gridSize,
        segment.y * SnakeGame.gridSize,
        SnakeGame.gridSize.toDouble(),
        SnakeGame.gridSize.toDouble(),
      );

      canvas.drawRect(rect, i == 0 ? headPaint : paint);

      // Add border
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }
}

class Food extends Component with HasGameRef<SnakeGame> {
  Vector2 position = Vector2.zero();
  final int gridWidth;
  final int gridHeight;

  Food(this.gridWidth, this.gridHeight);

  void updatePosition(Vector2 newPosition) {
    position = newPosition;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.red;
    final rect = Rect.fromLTWH(
      position.x * SnakeGame.gridSize,
      position.y * SnakeGame.gridSize,
      SnakeGame.gridSize.toDouble(),
      SnakeGame.gridSize.toDouble(),
    );

    canvas.drawOval(rect, paint);

    // Add border
    canvas.drawOval(
      rect,
      Paint()
        ..color = Colors.red[800]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}

class ScoreComponent extends TextComponent with HasGameRef<SnakeGame> {
  ScoreComponent()
    : super(
        text: 'Score: 0',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ) {
    position = Vector2(10, 10);
  }

  void updateScore(int score) {
    text = 'Score: $score';
  }
}

class GameOverComponent extends RectangleComponent with HasGameRef<SnakeGame> {
  late TextComponent gameOverText;
  late TextComponent scoreText;
  late TextComponent restartText;

  GameOverComponent()
    : super(
        size: Vector2(300, 200),
        paint: Paint()..color = Colors.black.withOpacity(0.8),
      ) {
    gameOverText = TextComponent(
      text: 'Game Over!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    scoreText = TextComponent(
      text: 'Final Score: 0',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );

    restartText = TextComponent(
      text: 'Press SPACE to restart',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(gameOverText);
    add(scoreText);
    add(restartText);

    hide();
  }

  @override
  void onMount() {
    super.onMount();

    // Center the game over screen using game reference
    position = Vector2((game.size.x - size.x) / 2, (game.size.y - size.y) / 2);

    // Position texts
    gameOverText.position = Vector2((size.x - gameOverText.size.x) / 2, 30);
    scoreText.position = Vector2((size.x - scoreText.size.x) / 2, 80);
    restartText.position = Vector2((size.x - restartText.size.x) / 2, 120);
  }

  void show(int finalScore) {
    scoreText.text = 'Final Score: $finalScore';
    // Reposition score text after text change
    scoreText.position = Vector2((size.x - scoreText.size.x) / 2, 80);

    opacity = 1.0;
  }

  void hide() {
    opacity = 0.0;
  }
}
