// lib/games/flame/endless_runner_game.dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'components/player.dart';
import 'components/ground.dart' as ground_component;
import 'components/background.dart' as bg_component;
import 'components/obstacle.dart';
import 'overlays/hud_overlays.dart';
import 'overlays/game_over_overlays.dart';
import 'utils/constant.dart';

class EndlessRunnerGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection, TapDetector {
  late Player player;
  late ground_component.Ground ground;
  late bg_component.GameBackground background;
  late TimerComponent obstacleSpawner;

  double score = 0;
  bool isGameRunning = true;
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    // Add background first (bottom layer)
    background = bg_component.GameBackground();
    add(background);

    // Add ground
    ground = ground_component.Ground();
    add(ground);

    // Add player
    player = Player();
    add(player);

    // Setup obstacle spawner
    obstacleSpawner = TimerComponent(
      period: GameConstants.obstacleSpawnInterval,
      repeat: true,
      onTick: spawnObstacle,
    );
    add(obstacleSpawner);

    // Register overlays
    overlays.addEntry('hud', (context, game) => HudOverlay(game: this));
    overlays.addEntry(
      'gameOver',
      (context, game) => GameOverOverlay(game: this),
    );

    // Show HUD
    overlays.add('hud');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameRunning) {
      score += dt * 10; // Score increases over time

      // Increase difficulty over time
      if (score > 100 && obstacleSpawner.timer.limit > 1.0) {
        obstacleSpawner.timer.limit = max(
          1.0,
          GameConstants.obstacleSpawnInterval - (score / 500),
        );
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (keysPressed.contains(LogicalKeyboardKey.space) && isGameRunning) {
      player.jump();
      return KeyEventResult.handled;
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    if (isGameRunning) {
      player.jump();
    }
    return true;
  }

  void spawnObstacle() {
    if (isGameRunning) {
      // Add some randomness to obstacle spacing
      if (random.nextDouble() < 0.7) {
        // 70% chance to spawn
        final obstacle = Obstacle();
        add(obstacle);
      }
    }
  }

  void gameOver() {
    isGameRunning = false;
    obstacleSpawner.timer.stop();
    overlays.add('gameOver');
  }

  void restart() {
    // Remove all obstacles
    children.whereType<Obstacle>().forEach((obstacle) {
      obstacle.removeFromParent();
    });

    // Reset game state
    score = 0;
    isGameRunning = true;

    // Reset player position
    player.position = Vector2(100, player.groundY);
    player.velocity = Vector2.zero();
    player.isOnGround = true;
    player.isJumping = false;

    // Restart obstacle spawner
    obstacleSpawner.timer.limit = GameConstants.obstacleSpawnInterval;
    obstacleSpawner.timer.start();

    // Hide game over overlay
    overlays.remove('gameOver');
  }
}
