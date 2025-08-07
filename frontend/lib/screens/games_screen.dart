// lib/screens/games_screen.dart
import 'package:flutter/material.dart';
import '../games/snake_game.dart';
import '../games/tic_tac_toe_game.dart';
import '../games/memory_game.dart';
import '../games/pong_game.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎮 Mini Games',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B14F),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Pilih game favoritmu!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _GameCard(
                      title: 'Snake Game',
                      subtitle: 'Classic snake game',
                      icon: '🐍',
                      color: Colors.green,
                      onTap: () => _navigateToGame(context, const SnakeGame()),
                    ),
                    _GameCard(
                      title: 'Tic Tac Toe',
                      subtitle: 'X vs O game',
                      icon: '⭕',
                      color: Colors.blue,
                      onTap: () =>
                          _navigateToGame(context, const TicTacToeGame()),
                    ),
                    _GameCard(
                      title: 'Memory Game',
                      subtitle: 'Match the pairs',
                      icon: '🧠',
                      color: Colors.purple,
                      onTap: () => _navigateToGame(context, const MemoryGame()),
                    ),
                    _GameCard(
                      title: 'Pong Game',
                      subtitle: 'Classic ping pong',
                      icon: '🏓',
                      color: Colors.orange,
                      onTap: () => _navigateToGame(context, const PongGame()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, Widget game) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => game));
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.8),
              color.withOpacity(0.6),
              color.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
