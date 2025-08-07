// lib/games/tic_tac_toe_game.dart
import 'package:flutter/material.dart';
import 'dart:math';

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({Key? key}) : super(key: key);

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  String winner = '';
  bool gameOver = false;
  bool isPlayerVsAI = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        backgroundColor: const Color(0xFF00B14F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game status
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    gameOver
                        ? (winner.isEmpty ? 'It\'s a Draw!' : 'Winner: $winner')
                        : 'Current Player: $currentPlayer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: gameOver
                          ? (winner.isEmpty
                                ? Colors.orange
                                : const Color(0xFF00B14F))
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mode: ${isPlayerVsAI ? 'vs AI' : 'vs Player'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Switch(
                        value: isPlayerVsAI,
                        onChanged: (value) {
                          setState(() {
                            isPlayerVsAI = value;
                            _resetGame();
                          });
                        },
                        activeColor: const Color(0xFF00B14F),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Game board
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomPaint(
                painter: TicTacToePainter(board),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _makeMove(index),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            board[index],
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: board[index] == 'X'
                                  ? const Color(0xFF00B14F)
                                  : Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _resetGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B14F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'New Game',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isPlayerVsAI = !isPlayerVsAI;
                      _resetGame();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: Text(
                    isPlayerVsAI ? 'vs Player' : 'vs AI',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
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

          // AI move if playing against AI and it's AI's turn
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
    // Simple AI strategy
    // 1. Win if possible
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) {
        board[i] = 'O';
        if (_checkWinner()) {
          board[i] = ''; // Reset for actual move
          return i;
        }
        board[i] = ''; // Reset
      }
    }

    // 2. Block player from winning
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) {
        board[i] = 'X';
        if (_checkWinner()) {
          board[i] = ''; // Reset for actual move
          return i;
        }
        board[i] = ''; // Reset
      }
    }

    // 3. Take center if available
    if (board[4].isEmpty) return 4;

    // 4. Take corners
    List<int> corners = [0, 2, 6, 8];
    corners.shuffle();
    for (int corner in corners) {
      if (board[corner].isEmpty) return corner;
    }

    // 5. Take any available spot
    List<int> availableSpots = [];
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) availableSpots.add(i);
    }

    if (availableSpots.isNotEmpty) {
      availableSpots.shuffle();
      return availableSpots.first;
    }

    return 0; // Fallback
  }

  bool _checkWinner() {
    // Check rows
    for (int i = 0; i < 9; i += 3) {
      if (board[i].isNotEmpty &&
          board[i] == board[i + 1] &&
          board[i] == board[i + 2]) {
        return true;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[i].isNotEmpty &&
          board[i] == board[i + 3] &&
          board[i] == board[i + 6]) {
        return true;
      }
    }

    // Check diagonals
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
      ..color = const Color(0xFF00B14F)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final cellWidth = size.width / 3;
    final cellHeight = size.height / 3;

    // Draw grid lines
    // Vertical lines
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (int i = 1; i < 3; i++) {
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
