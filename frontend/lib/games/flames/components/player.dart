// lib/games/flame/components/player.dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';
import '../utils/constant.dart';
import '../endless_runner_game.dart';

class Player extends RectangleComponent with HasGameRef<EndlessRunnerGame> {
  late Vector2 velocity;
  bool isOnGround = true;
  bool isJumping = false;
  double groundY = 0;

  @override
  Future<void> onLoad() async {
    size = Vector2(GameConstants.playerWidth, GameConstants.playerHeight);
    groundY = gameRef.size.y - GameConstants.groundHeight - size.y;
    position = Vector2(100, groundY);
    velocity = Vector2.zero();

    paint = Paint()
      ..color = const Color(0xFF00FF00)
      ..style = PaintingStyle.fill;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameRef.isGameRunning) return;

    // Apply gravity
    if (!isOnGround) {
      velocity.y += GameConstants.gravity * dt;
    }

    // Update position
    position.y += velocity.y * dt;

    // Check ground collision
    if (position.y >= groundY) {
      position.y = groundY;
      velocity.y = 0;
      isOnGround = true;
      isJumping = false;
    } else {
      isOnGround = false;
    }
  }

  void jump() {
    if (isOnGround && !isJumping) {
      velocity.y = -GameConstants.jumpSpeed;
      isJumping = true;
      isOnGround = false;
    }
  }
}
