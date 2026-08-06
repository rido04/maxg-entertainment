// lib/games/pacman_game.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class PacmanGame extends StatefulWidget {
  const PacmanGame({Key? key}) : super(key: key);

  @override
  State<PacmanGame> createState() => _PacmanGameState();
}

class _PacmanGameState extends State<PacmanGame>
    with SingleTickerProviderStateMixin {
  // Game Variables
  Timer? gameTimer;
  bool gameStarted = false;
  bool gameOver = false;
  bool gameWon = false;
  int score = 0;
  int lives = 3;

  // Single Animation Controller untuk semua animasi
  late AnimationController animationController;

  // Player
  int pacmanX = 9;
  int pacmanY = 15;
  String direction = 'right';
  String nextDirection = 'right';

  // Ghosts
  List<Ghost> ghosts = [];
  bool powerMode = false;
  Timer? powerModeTimer;
  int powerModeTimeLeft = 0;

  // Game State
  List<List<int>> maze = [];
  int totalDots = 0;
  int dotsCollected = 0;

  // Grid size
  final int rows = 21;
  final int cols = 19;

  @override
  void initState() {
    super.initState();
    initializeGame();
    setupAnimation();
  }

  void setupAnimation() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat();
  }

  void initializeGame() {
    createMaze();
    setupGhosts();
    countDots();
  }

  void createMaze() {
    maze = [
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1],
      [1, 3, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 3, 1],
      [1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1],
      [1, 2, 1, 1, 1, 2, 1, 2, 1, 1, 1, 2, 1, 2, 1, 1, 1, 2, 1],
      [1, 2, 2, 2, 2, 2, 1, 2, 2, 1, 2, 2, 1, 2, 2, 2, 2, 2, 1],
      [1, 1, 1, 1, 1, 2, 1, 1, 4, 1, 4, 1, 1, 2, 1, 1, 1, 1, 1],
      [4, 4, 4, 4, 1, 2, 1, 4, 4, 4, 4, 4, 1, 2, 1, 4, 4, 4, 4],
      [1, 1, 1, 1, 1, 2, 1, 4, 1, 4, 1, 4, 1, 2, 1, 1, 1, 1, 1],
      [2, 2, 2, 2, 2, 2, 4, 4, 1, 4, 1, 4, 4, 2, 2, 2, 2, 2, 2],
      [1, 1, 1, 1, 1, 2, 1, 4, 1, 1, 1, 4, 1, 2, 1, 1, 1, 1, 1],
      [4, 4, 4, 4, 1, 2, 1, 4, 4, 4, 4, 4, 1, 2, 1, 4, 4, 4, 4],
      [1, 1, 1, 1, 1, 2, 1, 4, 1, 1, 1, 4, 1, 2, 1, 1, 1, 1, 1],
      [1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1],
      [1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 2, 1],
      [1, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 1],
      [1, 1, 1, 2, 1, 2, 1, 2, 1, 1, 1, 2, 1, 2, 1, 2, 1, 1, 1],
      [1, 2, 2, 2, 2, 2, 1, 2, 2, 1, 2, 2, 1, 2, 2, 2, 2, 2, 1],
      [1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1],
      [1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    ];
  }

  void setupGhosts() {
    ghosts = [
      Ghost(x: 9, y: 9, color: const Color(0xFFFF4444), direction: 'up'),
      Ghost(x: 8, y: 9, color: const Color(0xFFFF69B4), direction: 'left'),
      Ghost(x: 10, y: 9, color: const Color(0xFF00FFFF), direction: 'right'),
      Ghost(x: 9, y: 10, color: const Color(0xFFFFB852), direction: 'down'),
    ];
  }

  void countDots() {
    totalDots = 0;
    for (var row in maze) {
      for (var cell in row) {
        if (cell == 2) totalDots++;
      }
    }
  }

  void startGame() {
    if (gameStarted) return;

    setState(() {
      gameStarted = true;
      gameOver = false;
      gameWon = false;
      score = 0;
      lives = 3;
      dotsCollected = 0;
      pacmanX = 9;
      pacmanY = 15;
      direction = 'right';
      nextDirection = 'right';
      powerMode = false;
    });

    createMaze();
    setupGhosts();
    countDots();

    gameTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      updateGame();
    });
  }

  void updateGame() {
    if (gameOver || gameWon || !mounted) return;

    setState(() {
      movePacman();
      moveGhosts();
      checkCollisions();
      checkWinCondition();
    });
  }

  void movePacman() {
    // Try to change direction if possible
    if (canMove(pacmanX, pacmanY, nextDirection)) {
      direction = nextDirection;
    }

    if (canMove(pacmanX, pacmanY, direction)) {
      int newX = pacmanX;
      int newY = pacmanY;

      switch (direction) {
        case 'up':
          newY--;
          break;
        case 'down':
          newY++;
          break;
        case 'left':
          newX--;
          break;
        case 'right':
          newX++;
          break;
      }

      // Handle tunnel (left-right teleport)
      if (newX < 0) newX = cols - 1;
      if (newX >= cols) newX = 0;

      pacmanX = newX;
      pacmanY = newY;

      // Collect dots and power pellets
      if (maze[pacmanY][pacmanX] == 2) {
        maze[pacmanY][pacmanX] = 4;
        score += 10;
        dotsCollected++;
        HapticFeedback.lightImpact();
      } else if (maze[pacmanY][pacmanX] == 3) {
        maze[pacmanY][pacmanX] = 4;
        score += 50;
        activatePowerMode();
        HapticFeedback.mediumImpact();
      }
    }
  }

  void moveGhosts() {
    for (var ghost in ghosts) {
      String targetDirection = getGhostDirection(ghost);

      List<String> possibleDirections = [];
      if (canMove(ghost.x, ghost.y, 'up')) possibleDirections.add('up');
      if (canMove(ghost.x, ghost.y, 'down')) possibleDirections.add('down');
      if (canMove(ghost.x, ghost.y, 'left')) possibleDirections.add('left');
      if (canMove(ghost.x, ghost.y, 'right')) possibleDirections.add('right');

      if (possibleDirections.isNotEmpty) {
        if (possibleDirections.contains(targetDirection)) {
          ghost.direction = targetDirection;
        } else {
          ghost.direction =
              possibleDirections[Random().nextInt(possibleDirections.length)];
        }
      }

      // Move ghost
      if (canMove(ghost.x, ghost.y, ghost.direction)) {
        int newX = ghost.x;
        int newY = ghost.y;

        switch (ghost.direction) {
          case 'up':
            newY--;
            break;
          case 'down':
            newY++;
            break;
          case 'left':
            newX--;
            break;
          case 'right':
            newX++;
            break;
        }

        // Handle tunnel
        if (newX < 0) newX = cols - 1;
        if (newX >= cols) newX = 0;

        ghost.x = newX;
        ghost.y = newY;
      }
    }
  }

  String getGhostDirection(Ghost ghost) {
    int deltaX = pacmanX - ghost.x;
    int deltaY = pacmanY - ghost.y;

    if (powerMode) {
      // Run away from Pacman
      deltaX = -deltaX;
      deltaY = -deltaY;
    }

    if (deltaX.abs() > deltaY.abs()) {
      return deltaX > 0 ? 'right' : 'left';
    } else {
      return deltaY > 0 ? 'down' : 'up';
    }
  }

  bool canMove(int x, int y, String dir) {
    int newX = x, newY = y;

    switch (dir) {
      case 'up':
        newY--;
        break;
      case 'down':
        newY++;
        break;
      case 'left':
        newX--;
        break;
      case 'right':
        newX++;
        break;
    }

    // Handle tunnel
    if (newX < 0) newX = cols - 1;
    if (newX >= cols) newX = 0;

    if (newY < 0 || newY >= rows) return false;
    return maze[newY][newX] != 1;
  }

  void activatePowerMode() {
    setState(() {
      powerMode = true;
      powerModeTimeLeft = 8;
    });

    powerModeTimer?.cancel();
    powerModeTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          powerMode = false;
        });
      }
    });
  }

  void checkCollisions() {
    for (int i = 0; i < ghosts.length; i++) {
      if (ghosts[i].x == pacmanX && ghosts[i].y == pacmanY) {
        if (powerMode) {
          // Eat ghost
          score += 200;
          respawnGhost(i);
          HapticFeedback.heavyImpact();
        } else {
          // Lose life
          lives--;
          HapticFeedback.heavyImpact();

          if (lives <= 0) {
            endGame();
          } else {
            resetPositions();
          }
        }
      }
    }
  }

  void respawnGhost(int index) {
    ghosts[index].x = 9;
    ghosts[index].y = 9;
    ghosts[index].direction = [
      'up',
      'down',
      'left',
      'right',
    ][Random().nextInt(4)];
  }

  void resetPositions() {
    pacmanX = 9;
    pacmanY = 15;
    direction = 'right';
    nextDirection = 'right';
    setupGhosts();

    gameTimer?.cancel();
    Timer(const Duration(milliseconds: 1000), () {
      if (gameStarted && !gameOver && mounted) {
        gameTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
          updateGame();
        });
      }
    });
  }

  void checkWinCondition() {
    if (dotsCollected >= totalDots) {
      setState(() {
        gameWon = true;
      });
      gameTimer?.cancel();
      HapticFeedback.heavyImpact();
    }
  }

  void endGame() {
    setState(() {
      gameOver = true;
    });
    gameTimer?.cancel();
    powerModeTimer?.cancel();
  }

  void resetGame() {
    gameTimer?.cancel();
    powerModeTimer?.cancel();
    setState(() {
      gameStarted = false;
      gameOver = false;
      gameWon = false;
      powerMode = false;
    });
  }

  void handleSwipe(String swipeDirection) {
    if (gameStarted && !gameOver && !gameWon) {
      setState(() {
        nextDirection = swipeDirection;
      });
      HapticFeedback.selectionClick();
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    powerModeTimer?.cancel();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: GestureDetector(
        onPanUpdate: (details) {
          const double threshold = 10.0;
          if (details.delta.dx > threshold) {
            handleSwipe('right');
          } else if (details.delta.dx < -threshold) {
            handleSwipe('left');
          } else if (details.delta.dy > threshold) {
            handleSwipe('down');
          } else if (details.delta.dy < -threshold) {
            handleSwipe('up');
          }
        },
        onTap: !gameStarted ? startGame : null,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: gameStarted ? _buildGameArea() : _buildStartScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.yellow, size: 28),
          ),
          const Spacer(),
          if (gameStarted) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.yellow),
              ),
              child: Text(
                'SCORE: $score',
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '$lives',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (powerMode) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flash_on, color: Colors.purple, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'POWER',
                      style: const TextStyle(
                        color: Colors.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (sin(animationController.value * 2 * pi) * 0.1),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            'PAC-MAN',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.yellow,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Collect all dots and avoid ghosts!',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Text(
              'TAP TO START',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.yellow.withOpacity(0.3)),
            ),
            child: const Column(
              children: [
                Icon(Icons.swipe, color: Colors.yellow, size: 32),
                SizedBox(height: 8),
                Text(
                  'Swipe to change direction',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return Center(
      child: AspectRatio(
        aspectRatio: cols / rows,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: powerMode ? Colors.purple : const Color(0xFF1565C0),
              width: 3,
            ),
          ),
          child: Stack(
            children: [
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                ),
                itemCount: rows * cols,
                itemBuilder: (context, index) {
                  int x = index % cols;
                  int y = index ~/ cols;
                  return _buildMazeCell(x, y);
                },
              ),
              if (gameOver || gameWon) _buildGameOverOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMazeCell(int x, int y) {
    bool isPacman = pacmanX == x && pacmanY == y;
    Ghost? ghost = ghosts.firstWhere(
      (g) => g.x == x && g.y == y,
      orElse: () =>
          Ghost(x: -1, y: -1, color: Colors.transparent, direction: ''),
    );
    bool isGhost = ghost.x != -1;

    if (isPacman) {
      return _buildPacman();
    } else if (isGhost) {
      return _buildGhost(ghost);
    } else {
      return _buildMazeElement(maze[y][x]);
    }
  }

  Widget _buildPacman() {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        double rotation = 0;
        switch (direction) {
          case 'up':
            rotation = -pi / 2;
            break;
          case 'down':
            rotation = pi / 2;
            break;
          case 'left':
            rotation = pi;
            break;
          case 'right':
            rotation = 0;
            break;
        }

        return Transform.rotate(
          angle: rotation,
          child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CustomPaint(
              painter: PacmanPainter(animationController.value),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGhost(Ghost ghost) {
    Color ghostColor = powerMode ? Colors.blue : ghost.color;
    bool isFlashing = powerMode && powerModeTimeLeft <= 2;

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        // Flash between blue and white when power mode ending
        Color currentColor = ghostColor;
        if (isFlashing && sin(animationController.value * 4 * pi) > 0) {
          currentColor = Colors.white;
        }

        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: currentColor.withOpacity(0.6),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CustomPaint(painter: GhostPainter(currentColor, powerMode)),
        );
      },
    );
  }

  Widget _buildMazeElement(int cellType) {
    switch (cellType) {
      case 1: // Wall
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: powerMode
                ? Colors.purple.withOpacity(0.8)
                : const Color(0xFF1565C0).withOpacity(0.8),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case 2: // Dot
        return Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.circle,
            ),
          ),
        );
      case 3: // Power Pellet
        return Center(
          child: AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (sin(animationController.value * 2 * pi) * 0.3),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGameOverOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              gameWon ? 'VICTORY!' : 'GAME OVER',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: gameWon ? Colors.amber : Colors.red,
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 8,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.yellow, width: 2),
              ),
              child: Text(
                'FINAL SCORE: $score',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    resetGame();
                    startGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'PLAY AGAIN',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'MENU',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Ghost {
  int x, y;
  Color color;
  String direction;

  Ghost({
    required this.x,
    required this.y,
    required this.color,
    required this.direction,
  });
}

// Optimized Pacman Painter (safe, no shader issues)
class PacmanPainter extends CustomPainter {
  final double animationValue;

  PacmanPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0A0A0A)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw mouth opening with animation
    double mouthAngle = (sin(animationValue * pi * 2) * 0.5 + 0.5) * pi * 0.6;

    if (size.width > 0 && size.height > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -mouthAngle / 2,
        mouthAngle,
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PacmanPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}

// Optimized Ghost Painter (no shader, solid colors only)
class GhostPainter extends CustomPainter {
  final Color color;
  final bool powerMode;

  GhostPainter(this.color, this.powerMode);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Draw eyes
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final eyeRadius = size.width * 0.08;
    final leftEye = Offset(size.width * 0.35, size.height * 0.35);
    final rightEye = Offset(size.width * 0.65, size.height * 0.35);

    if (powerMode) {
      // Scared eyes - simple lines
      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(leftEye.dx - eyeRadius, leftEye.dy),
        Offset(leftEye.dx + eyeRadius, leftEye.dy),
        linePaint,
      );
      canvas.drawLine(
        Offset(rightEye.dx - eyeRadius, rightEye.dy),
        Offset(rightEye.dx + eyeRadius, rightEye.dy),
        linePaint,
      );

      // Draw wavy mouth
      final mouthPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(size.width * 0.3, size.height * 0.6);
      path.lineTo(size.width * 0.4, size.height * 0.7);
      path.lineTo(size.width * 0.5, size.height * 0.6);
      path.lineTo(size.width * 0.6, size.height * 0.7);
      path.lineTo(size.width * 0.7, size.height * 0.6);

      canvas.drawPath(path, mouthPaint);
    } else {
      // Normal eyes
      canvas.drawCircle(leftEye, eyeRadius, eyePaint);
      canvas.drawCircle(rightEye, eyeRadius, eyePaint);

      // Draw pupils
      final pupilPaint = Paint()..color = Colors.black;
      canvas.drawCircle(leftEye, eyeRadius * 0.5, pupilPaint);
      canvas.drawCircle(rightEye, eyeRadius * 0.5, pupilPaint);
    }

    // Draw wavy bottom (no shader, solid color)
    final wavePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.65);

    const int waves = 4;
    for (int i = 0; i <= waves; i++) {
      final waveX = i * size.width / waves;
      final waveY = size.height * (i % 2 == 0 ? 0.85 : 0.75);
      path.lineTo(waveX, waveY);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant GhostPainter oldDelegate) {
    return color != oldDelegate.color || powerMode != oldDelegate.powerMode;
  }
}
