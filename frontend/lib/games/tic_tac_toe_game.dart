// lib/games/tic_tac_toe_game.dart
import 'package:flutter/material.dart';
import 'dart:math';

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({Key? key}) : super(key: key);

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame>
    with TickerProviderStateMixin {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  String winner = '';
  bool gameOver = false;
  bool isPlayerVsAI = true;
  late AnimationController _pulseController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF0A0E27)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        _buildGameStatus(),
                        const SizedBox(height: 40),
                        _buildGameBoard(),
                        const SizedBox(height: 40),
                        _buildControlButtons(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00B14F).withOpacity(0.2),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF00B14F).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00B14F).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF00B14F)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 15),
          const Text(
            'TIC TAC TOE',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatus() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1E1E).withOpacity(0.8),
            const Color(0xFF2A2A2A).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gameOver
              ? (winner.isEmpty ? Colors.orange : const Color(0xFF00B14F))
              : const Color(0xFF00B14F).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: gameOver
                ? (winner.isEmpty
                      ? Colors.orange.withOpacity(0.3)
                      : const Color(0xFF00B14F).withOpacity(0.3))
                : const Color(0xFF00B14F).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              gameOver
                  ? (winner.isEmpty ? 'DRAW GAME' : 'WINNER: $winner')
                  : 'PLAYER: $currentPlayer',
              key: ValueKey(gameOver ? winner : currentPlayer),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: gameOver
                    ? (winner.isEmpty ? Colors.orange : const Color(0xFFFFD700))
                    : Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00B14F).withOpacity(0.2),
                  const Color(0xFFFFD700).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF00B14F).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'MODE: ${isPlayerVsAI ? 'VS AI' : 'VS PLAYER'}',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 15),
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: isPlayerVsAI,
                    onChanged: (value) {
                      setState(() {
                        isPlayerVsAI = value;
                        _resetGame();
                      });
                    },
                    activeColor: const Color(0xFF00B14F),
                    activeTrackColor: const Color(0xFF00B14F).withOpacity(0.3),
                    inactiveThumbColor: const Color(0xFFFFD700),
                    inactiveTrackColor: const Color(
                      0xFFFFD700,
                    ).withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Container(
      width: 320,
      height: 320,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1E1E).withOpacity(0.9),
            const Color(0xFF2A2A2A).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFF00B14F).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B14F).withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          CustomPaint(
            painter: TicTacToePainter(board),
            size: const Size(290, 290),
          ),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _makeMove(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: board[index].isEmpty
                        ? LinearGradient(
                            colors: [
                              const Color(0xFF2A2A2A).withOpacity(0.3),
                              Colors.transparent,
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    border: board[index].isEmpty
                        ? Border.all(
                            color: const Color(0xFF00B14F).withOpacity(0.1),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: board[index].isNotEmpty
                          ? ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: board[index] == 'X'
                                    ? [
                                        const Color(0xFF00B14F),
                                        const Color(0xFF00D957),
                                      ]
                                    : [
                                        const Color(0xFFFFD700),
                                        const Color(0xFFFFA500),
                                      ],
                              ).createShader(bounds),
                              child: Text(
                                board[index],
                                key: ValueKey('$index-${board[index]}'),
                                style: const TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildGradientButton(
          onPressed: _resetGame,
          label: 'NEW GAME',
          colors: [const Color(0xFF00B14F), const Color(0xFF00D957)],
        ),
        _buildGradientButton(
          onPressed: () {
            setState(() {
              isPlayerVsAI = !isPlayerVsAI;
              _resetGame();
            });
          },
          label: isPlayerVsAI ? 'VS PLAYER' : 'VS AI',
          colors: [const Color(0xFFFFD700), const Color(0xFFFFA500)],
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required String label,
    required List<Color> colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  void _makeMove(int index) {
    if (board[index].isEmpty && !gameOver) {
      setState(() {
        board[index] = currentPlayer;

        if (_checkWinner()) {
          winner = currentPlayer;
          gameOver = true;
        } else if (_isBoardFull()) {
          gameOver = true;
        } else {
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';

          if (isPlayerVsAI && currentPlayer == 'O' && !gameOver) {
            Future.delayed(const Duration(milliseconds: 500), () {
              _makeAIMove();
            });
          }
        }
      });
    }
  }

  void _makeAIMove() {
    if (gameOver) return;

    int bestMove = _getBestMove();

    setState(() {
      board[bestMove] = 'O';

      if (_checkWinner()) {
        winner = 'O';
        gameOver = true;
      } else if (_isBoardFull()) {
        gameOver = true;
      } else {
        currentPlayer = 'X';
      }
    });
  }

  int _getBestMove() {
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) {
        board[i] = 'O';
        if (_checkWinner()) {
          board[i] = '';
          return i;
        }
        board[i] = '';
      }
    }

    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) {
        board[i] = 'X';
        if (_checkWinner()) {
          board[i] = '';
          return i;
        }
        board[i] = '';
      }
    }

    if (board[4].isEmpty) return 4;

    List<int> corners = [0, 2, 6, 8];
    corners.shuffle();
    for (int corner in corners) {
      if (board[corner].isEmpty) return corner;
    }

    List<int> availableSpots = [];
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) availableSpots.add(i);
    }

    if (availableSpots.isNotEmpty) {
      availableSpots.shuffle();
      return availableSpots.first;
    }

    return 0;
  }

  bool _checkWinner() {
    for (int i = 0; i < 9; i += 3) {
      if (board[i].isNotEmpty &&
          board[i] == board[i + 1] &&
          board[i] == board[i + 2]) {
        return true;
      }
    }

    for (int i = 0; i < 3; i++) {
      if (board[i].isNotEmpty &&
          board[i] == board[i + 3] &&
          board[i] == board[i + 6]) {
        return true;
      }
    }

    if (board[0].isNotEmpty && board[0] == board[4] && board[0] == board[8]) {
      return true;
    }

    if (board[2].isNotEmpty && board[2] == board[4] && board[2] == board[6]) {
      return true;
    }

    return false;
  }

  bool _isBoardFull() {
    return !board.contains('');
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      winner = '';
      gameOver = false;
    });
  }
}

class TicTacToePainter extends CustomPainter {
  final List<String> board;

  TicTacToePainter(this.board);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final cellWidth = size.width / 3;
    final cellHeight = size.height / 3;

    for (int i = 1; i < 3; i++) {
      final gradient = LinearGradient(
        colors: [
          const Color(0xFF00B14F).withOpacity(0.6),
          const Color(0xFFFFD700).withOpacity(0.4),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      paint.shader = gradient;

      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        paint,
      );

      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.width, i * cellHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
