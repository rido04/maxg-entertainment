// lib/games/pong_game.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class PongGame extends StatefulWidget {
  const PongGame({Key? key}) : super(key: key);

  @override
  State<PongGame> createState() => _PongGameState();
}

class _PongGameState extends State<PongGame>
    with SingleTickerProviderStateMixin {
  // Game variables
  double ballX = 0.0;
  double ballY = 0.0;
  double ballSpeedX = 0.025;
  double ballSpeedY = 0.015;
  double playerY = 0.0;
  double aiY = 0.0;
  int playerScore = 0;
  int aiScore = 0;
  bool gameStarted = false;
  Timer? gameTimer;

  // Touch control
  double? touchStartY;
  double? lastTouchY;

  // Animation
  late AnimationController trailController;

  // Game constants
  static const double paddleHeight = 0.25;
  static const double paddleWidth = 0.03;
  static const double ballSize = 0.025;
  static const double aiSpeed = 0.022;
  static const int winScore = 5;

  // Ball trail effect
  List<Offset> ballTrail = [];

  @override
  void initState() {
    super.initState();
    _resetBall();
    trailController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    trailController.dispose();
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
      ballTrail.clear();
    });
    _resetBall();
  }

  void _resetBall() {
    setState(() {
      ballX = 0.0;
      ballY = 0.0;
      // Random direction with minimum speed
      double angle = (Random().nextDouble() - 0.5) * pi / 3;
      double speed = 0.025;
      ballSpeedX = (Random().nextBool() ? 1 : -1) * speed * cos(angle);
      ballSpeedY = speed * sin(angle);
      ballTrail.clear();
    });
  }

  void _updateGame() {
    if (!mounted) return;

    setState(() {
      // Store ball position for trail
      ballTrail.add(Offset(ballX, ballY));
      if (ballTrail.length > 8) {
        ballTrail.removeAt(0);
      }

      // Move ball
      ballX += ballSpeedX;
      ballY += ballSpeedY;

      // Increase speed slightly over time
      ballSpeedX *= 1.0002;
      ballSpeedY *= 1.0002;

      // Ball collision with top/bottom walls
      if (ballY <= -1 + ballSize || ballY >= 1 - ballSize) {
        ballSpeedY = -ballSpeedY;
        HapticFeedback.lightImpact();
      }

      // Ball collision with paddles
      // Left paddle (player)
      if (ballX <= -1 + paddleWidth + ballSize &&
          ballY >= playerY - paddleHeight / 2 &&
          ballY <= playerY + paddleHeight / 2) {
        ballSpeedX = ballSpeedX.abs() * 1.05; // Speed up slightly
        ballSpeedY += (ballY - playerY) * 0.15; // Add spin
        HapticFeedback.mediumImpact();
      }

      // Right paddle (AI)
      if (ballX >= 1 - paddleWidth - ballSize &&
          ballY >= aiY - paddleHeight / 2 &&
          ballY <= aiY + paddleHeight / 2) {
        ballSpeedX = -ballSpeedX.abs() * 1.05; // Speed up slightly
        ballSpeedY += (ballY - aiY) * 0.15; // Add spin
        HapticFeedback.lightImpact();
      }

      // Ball out of bounds - scoring
      if (ballX < -1.2) {
        aiScore++;
        HapticFeedback.heavyImpact();
        _checkWin();
        _resetBall();
      } else if (ballX > 1.2) {
        playerScore++;
        HapticFeedback.heavyImpact();
        _checkWin();
        _resetBall();
      }

      // Enhanced AI movement with prediction
      double predictedY = _predictBallY();
      double targetY = predictedY;

      // Add some randomness to make AI beatable
      if (Random().nextDouble() < 0.1) {
        targetY += (Random().nextDouble() - 0.5) * 0.2;
      }

      if (aiY < targetY - 0.02) {
        aiY += aiSpeed;
      } else if (aiY > targetY + 0.02) {
        aiY -= aiSpeed;
      }

      // Keep AI paddle in bounds
      aiY = aiY.clamp(-1 + paddleHeight / 2, 1 - paddleHeight / 2);
    });
  }

  double _predictBallY() {
    // Simple prediction: where will ball be when it reaches AI paddle
    if (ballSpeedX <= 0) return ballY; // Ball going away from AI

    double timeToReach = (1 - paddleWidth - ballX) / ballSpeedX;
    double predictedY = ballY + ballSpeedY * timeToReach;

    // Account for bounces
    while (predictedY.abs() > 1) {
      if (predictedY > 1) {
        predictedY = 2 - predictedY;
      } else if (predictedY < -1) {
        predictedY = -2 - predictedY;
      }
    }

    return predictedY;
  }

  void _checkWin() {
    if (playerScore >= winScore || aiScore >= winScore) {
      _pauseGame();
    }
  }

  void _handlePanStart(DragStartDetails details) {
    if (!gameStarted) return;
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    touchStartY = (localPosition.dy / size.height) * 2 - 1;
    lastTouchY = touchStartY;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!gameStarted) return;
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final normalizedY = (localPosition.dy / size.height) * 2 - 1;

    setState(() {
      playerY = normalizedY.clamp(-1 + paddleHeight / 2, 1 - paddleHeight / 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool gameEnded = playerScore >= winScore || aiScore >= winScore;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      appBar: AppBar(
        title: const Text(
          'PONG',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color(0xFF1B2332),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00E676)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                // Score display
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 40,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B2332), Color(0xFF0D1421)],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildScoreCard(
                        'PLAYER',
                        playerScore,
                        const Color(0xFF00E676),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'FIRST TO $winScore',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      _buildScoreCard('AI', aiScore, Colors.orange),
                    ],
                  ),
                ),

                // Game area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00E676).withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: Stack(
                        children: [
                          // Game canvas
                          GestureDetector(
                            onPanStart: _handlePanStart,
                            onPanUpdate: _handlePanUpdate,
                            child: CustomPaint(
                              painter: PongPainter(
                                ballX: ballX,
                                ballY: ballY,
                                playerY: playerY,
                                aiY: aiY,
                                ballTrail: ballTrail,
                              ),
                              child: Container(),
                            ),
                          ),

                          // Start overlay
                          if (!gameStarted && !gameEnded)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.touch_app,
                                      color: Color(0xFF00E676),
                                      size: 64,
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'TAP TO START',
                                      style: TextStyle(
                                        color: Color(0xFF00E676),
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Drag to move your paddle',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Win overlay
                          if (gameEnded)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      playerScore >= winScore
                                          ? Icons.emoji_events
                                          : Icons.sentiment_dissatisfied,
                                      color: playerScore >= winScore
                                          ? const Color(0xFF00E676)
                                          : Colors.orange,
                                      size: 80,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      playerScore >= winScore
                                          ? 'YOU WIN!'
                                          : 'AI WINS!',
                                      style: TextStyle(
                                        color: playerScore >= winScore
                                            ? const Color(0xFF00E676)
                                            : Colors.orange,
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Final Score: $playerScore - $aiScore',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Control buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        gameStarted
                            ? 'PAUSE'
                            : (gameEnded ? 'PLAY AGAIN' : 'START'),
                        gameStarted ? Icons.pause : Icons.play_arrow,
                        () {
                          if (gameEnded) {
                            _resetGame();
                            _startGame();
                          } else if (gameStarted) {
                            _pauseGame();
                          } else {
                            _startGame();
                          }
                        },
                        gameStarted ? Colors.orange : const Color(0xFF00E676),
                      ),
                      const SizedBox(width: 16),
                      _buildControlButton(
                        'RESET',
                        Icons.refresh,
                        _resetGame,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Text(
            score.toString(),
            style: TextStyle(
              color: color,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 24),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 8,
        shadowColor: color.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    );
  }
}

class PongPainter extends CustomPainter {
  final double ballX, ballY, playerY, aiY;
  final List<Offset> ballTrail;

  PongPainter({
    required this.ballX,
    required this.ballY,
    required this.playerY,
    required this.aiY,
    required this.ballTrail,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Convert normalized coordinates to screen coordinates
    double screenX(double x) => (x + 1) * size.width / 2;
    double screenY(double y) => (-y + 1) * size.height / 2;

    // Draw center line (dashed)
    final centerLinePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 3;

    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(
        Offset(size.width / 2, i),
        Offset(size.width / 2, i + 10),
        centerLinePaint,
      );
    }

    // Draw ball trail
    for (int i = 0; i < ballTrail.length; i++) {
      final pos = ballTrail[i];
      final opacity = (i / ballTrail.length) * 0.5;
      final trailPaint = Paint()
        ..color = const Color(0xFF00E676).withOpacity(opacity);

      canvas.drawCircle(
        Offset(screenX(pos.dx), screenY(pos.dy)),
        size.width * _PongGameState.ballSize * (0.5 + opacity),
        trailPaint,
      );
    }

    // Draw ball with glow
    final glowPaint = Paint()
      ..color = const Color(0xFF00E676).withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(
      Offset(screenX(ballX), screenY(ballY)),
      size.width * _PongGameState.ballSize * 1.5,
      glowPaint,
    );

    final ballPaint = Paint()..color = const Color(0xFF00E676);
    canvas.drawCircle(
      Offset(screenX(ballX), screenY(ballY)),
      size.width * _PongGameState.ballSize,
      ballPaint,
    );

    // Draw player paddle (left) with glow
    final playerGlowPaint = Paint()
      ..color = const Color(0xFF00E676).withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final playerRect = Rect.fromCenter(
      center: Offset(
        screenX(-1 + _PongGameState.paddleWidth),
        screenY(playerY),
      ),
      width: size.width * _PongGameState.paddleWidth,
      height: size.height * _PongGameState.paddleHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(playerRect.inflate(4), const Radius.circular(8)),
      playerGlowPaint,
    );

    final playerPaint = Paint()..color = const Color(0xFF00E676);
    canvas.drawRRect(
      RRect.fromRectAndRadius(playerRect, const Radius.circular(8)),
      playerPaint,
    );

    // Draw AI paddle (right) with glow
    final aiGlowPaint = Paint()
      ..color = Colors.orange.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final aiRect = Rect.fromCenter(
      center: Offset(screenX(1 - _PongGameState.paddleWidth), screenY(aiY)),
      width: size.width * _PongGameState.paddleWidth,
      height: size.height * _PongGameState.paddleHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(aiRect.inflate(4), const Radius.circular(8)),
      aiGlowPaint,
    );

    final aiPaint = Paint()..color = Colors.orange;
    canvas.drawRRect(
      RRect.fromRectAndRadius(aiRect, const Radius.circular(8)),
      aiPaint,
    );
  }

  @override
  bool shouldRepaint(covariant PongPainter oldDelegate) {
    return ballX != oldDelegate.ballX ||
        ballY != oldDelegate.ballY ||
        playerY != oldDelegate.playerY ||
        aiY != oldDelegate.aiY;
  }
}
