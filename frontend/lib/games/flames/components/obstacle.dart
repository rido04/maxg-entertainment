// lib/games/flame/components/obstacle.dart
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/painting.dart';
import '../utils/constant.dart';
import '../endless_runner_game.dart';
import 'player.dart';

class Obstacle extends RectangleComponent
    with HasGameRef<EndlessRunnerGame>, CollisionCallbacks {
  @override
  Future<void> onLoad() async {
    size = Vector2(GameConstants.obstacleWidth, GameConstants.obstacleHeight);
    position = Vector2(
      gameRef.size.x + size.x,
      gameRef.size.y - GameConstants.groundHeight - size.y,
    );

    paint = Paint()
      ..color = const Color(0xFFFF0000)
      ..style = PaintingStyle.fill;

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameRef.isGameRunning) return;

    // Move obstacle to the left
    position.x -= GameConstants.gameSpeed * dt;

    // Remove when off screen
    if (position.x < -size.x) {
      removeFromParent();
    }
  }

  @override
  bool onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Player) {
      gameRef.gameOver();
      return true;
    }
    return false;
  }
}
