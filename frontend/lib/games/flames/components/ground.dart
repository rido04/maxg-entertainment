// lib/games/flame/components/ground.dart
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../utils/constant.dart';
import '../endless_runner_game.dart';

class Ground extends RectangleComponent with HasGameRef<EndlessRunnerGame> {
  @override
  Future<void> onLoad() async {
    size = Vector2(gameRef.size.x * 2, GameConstants.groundHeight);
    position = Vector2(0, gameRef.size.y - GameConstants.groundHeight);

    paint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.fill;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameRef.isGameRunning) return;

    // Move ground to the left
    position.x -= GameConstants.gameSpeed * dt;

    // Reset position when it goes off screen
    if (position.x <= -gameRef.size.x) {
      position.x = 0;
    }
  }
}
