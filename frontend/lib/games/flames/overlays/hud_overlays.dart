// lib/games/flame/overlays/hud_overlay.dart
import 'package:flutter/material.dart';
import '../endless_runner_game.dart';

class HudOverlay extends StatelessWidget {
  final EndlessRunnerGame game;

  const HudOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: StreamBuilder<double>(
          stream: Stream.periodic(
            const Duration(milliseconds: 100),
            (_) => game.score,
          ),
          builder: (context, snapshot) {
            return Text(
              'Score: ${(snapshot.data ?? 0).toInt()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
    );
  }
}
