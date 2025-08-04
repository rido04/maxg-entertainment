// lib/games/flame/endless_runner_screen.dart
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'endless_runner_game.dart';

class EndlessRunnerScreen extends StatefulWidget {
  @override
  _EndlessRunnerScreenState createState() => _EndlessRunnerScreenState();
}

class _EndlessRunnerScreenState extends State<EndlessRunnerScreen> {
  late EndlessRunnerGame game;

  @override
  void initState() {
    super.initState();
    game = EndlessRunnerGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game Widget
          GameWidget<EndlessRunnerGame>.controlled(gameFactory: () => game),

          // Back Button
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),

          // Instructions (shows initially, fades after few seconds)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🎮 How to Play',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap anywhere or press SPACE to jump\nAvoid the red obstacles!\nScore increases as you survive longer',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    game.pauseEngine();
    super.dispose();
  }
}
