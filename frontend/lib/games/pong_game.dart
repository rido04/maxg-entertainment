// lib/games/pong_game.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class PongGame extends StatefulWidget {
  const PongGame({Key? key}) : super(key: key);

  @override
  State<PongGame> createState() => _PongGameState();
}

class _PongGameState extends State<PongGame> {
  // Game variables
  double ballX = 0.0;
  double ballY = 0.0;
  double ballSpeedX = 0.02;
  double ballSpeedY = 0.01;
  double playerY = 0.0;
  double aiY = 0.0;
  int playerScore = 0;
  int aiScore = 0;
  bool gameStarted = false;
  Timer? gameTimer;

  // Game constants
  static const double paddleHeight = 0.3;
  static const double paddleWidth = 0.05;
  static const double ballSize = 0.03;
  static const double paddleSpeed = 0.03;
  static const double aiSpeed = 0.02;

  @override
  void initState() {
    super.initState();
    _resetBall();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    if (gameTimer?.isActive ?? false) return;

    setState(() {
      gameStarted = true;
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateGame();
    });
  }

  void _pauseGame() {
    gameTimer?.cancel();
    setState(() {
      gameStarted = false;
    });
  }

  void _resetGame() {
    gameTimer?.cancel();
    setState(() {
      playerScore = 0;
      aiScore = 0;
      gameStarted = false;
      playerY = 0.0;
      aiY = 0.0;
    });
    _resetBall();
  }

  void _resetBall() {
    setState(() {
      ballX = 0.0;
      ballY = 0.0;
      ballSpeedX = (Random().nextBool() ? 1 : -1) * 0.02;
      ballSpeedY = (Random().nextDouble() - 0.5) * 0.02;
    });
  }

  void _updateGame() {
    setState(() {
      // Move ball
      ballX += ballSpeedX;
      ballY += ballSpeedY;

      // Ball collision with top/bottom walls
      if (ballY <= -1 + ballSize || ballY >= 1 - ballSize) {
        ballSpeedY = -ballSpeedY;
      }

      // Ball collision with paddles
      // Left paddle (player)
      if (ballX <= -1 + paddleWidth + ballSize &&
          ballY >= playerY - paddleHeight / 2 &&
          ballY <= playerY + paddleHeight / 2) {
        ballSpeedX = -ballSpeedX;
        ballSpeedY += (ballY - playerY) * 0.1; // Add spin effect
      }

      // Right paddle (AI)
      if (ballX >= 1 - paddleWidth - ballSize &&
          ballY >= aiY - paddleHeight / 2 &&
          ballY <= aiY + paddleHeight / 2) {
        ballSpeedX = -ballSpeedX;
        ballSpeedY += (ballY - aiY) * 0.1; // Add spin effect
      }

      // Ball out of bounds - scoring
      if (ballX < -1) {
        aiScore++;
        _resetBall();
      } else if (ballX > 1) {
        playerScore++;
        _resetBall();
      }

      // AI movement
      double targetY = ballY;
      if (aiY < targetY - 0.05) {
        aiY += aiSpeed;
      } else if (aiY > targetY + 0.05) {
        aiY -= aiSpeed;
      }

      // Keep AI paddle in bounds
      aiY = aiY.clamp(-1 + paddleHeight / 2, 1 - paddleHeight / 2);
    });
  }

  void _movePlayerPaddle(double delta) {
    setState(() {
      playerY = (playerY + delta).clamp(
        -1 + paddleHeight / 2,
        1 - paddleHeight / 2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Pong Game - Player: $playerScore | AI: $aiScore'),
        backgroundColor: const Color(0xFF00B14F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00B14F), width: 2),
              ),
              child: CustomPaint(
                painter: PongPainter(
                  ballX: ballX,
                  ballY: ballY,
                  playerY: playerY,
                  aiY: aiY,
                ),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    if (gameStarted) {
                      final RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      final size = renderBox.size;
                      final localPosition = renderBox.globalToLocal(
                        details.globalPosition,
                      );
                      final normalizedY =
                          (localPosition.dy / size.height) * 2 - 1;
                      _movePlayerPaddle(normalizedY - playerY);
                    }
                  },
                  child: Container(),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Score display
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Player',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            playerScore.toString(),
                            style: const TextStyle(
                              color: Color(0xFF00B14F),
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'VS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        children: [
                          const Text(
                            'AI',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            aiScore.toString(),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Game controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: gameStarted ? _pauseGame : _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B14F),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: Text(
                        gameStarted ? 'Pause' : 'Start',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _resetGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Player controls
                if (gameStarted) ...[
                  const Text(
                    'Drag on screen to move your paddle',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _movePlayerPaddle(-paddleSpeed * 3),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00B14F),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      GestureDetector(
                        onTap: () => _movePlayerPaddle(paddleSpeed * 3),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00B14F),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PongPainter extends CustomPainter {
  final double ballX, ballY, playerY, aiY;

  PongPainter({
    required this.ballX,
    required this.ballY,
    required this.playerY,
    required this.aiY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    // Draw center line
    final centerLinePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    for (double i = -1; i < 1; i += 0.1) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.width / 2, (i + 1) * size.height / 2),
          width: 2,
          height: size.height * 0.03,
        ),
        centerLinePaint,
      );
    }

    // Convert normalized coordinates to screen coordinates
    double screenX(double x) => (x + 1) * size.width / 2;
    double screenY(double y) => (-y + 1) * size.height / 2;

    // Draw ball
    final ballPaint = Paint()..color = const Color(0xFF00B14F);
    canvas.drawCircle(
      Offset(screenX(ballX), screenY(ballY)),
      size.width * _PongGameState.ballSize,
      ballPaint,
    );

    // Draw player paddle (left)
    final playerPaint = Paint()..color = const Color(0xFF00B14F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            screenX(-1 + _PongGameState.paddleWidth / 2),
            screenY(playerY),
          ),
          width: size.width * _PongGameState.paddleWidth,
          height: size.height * _PongGameState.paddleHeight,
        ),
        const Radius.circular(5),
      ),
      playerPaint,
    );

    // Draw AI paddle (right)
    final aiPaint = Paint()..color = Colors.orange;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            screenX(1 - _PongGameState.paddleWidth / 2),
            screenY(aiY),
          ),
          width: size.width * _PongGameState.paddleWidth,
          height: size.height * _PongGameState.paddleHeight,
        ),
        const Radius.circular(5),
      ),
      aiPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
