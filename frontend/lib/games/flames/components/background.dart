// lib/games/flame/components/background.dart
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../utils/constant.dart';
import '../endless_runner_game.dart';

class GameBackground extends RectangleComponent
    with HasGameRef<EndlessRunnerGame> {
  @override
  Future<void> onLoad() async {
    size = Vector2(gameRef.size.x * 2, gameRef.size.y);
    position = Vector2(0, 0);

    // Create a gradient background
    paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF87CEEB), // Sky blue
          Color(0xFFE0F6FF), // Light blue
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y))
      ..style = PaintingStyle.fill;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameRef.isGameRunning) return;

    // Move background to the left (slower than ground for parallax effect)
    position.x -= (GameConstants.gameSpeed * 0.3) * dt;

    // Reset position when it goes off screen
    if (position.x <= -gameRef.size.x) {
      position.x = 0;
    }
  }
}
