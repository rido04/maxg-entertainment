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

class _PacmanGameState extends State<PacmanGame> with TickerProviderStateMixin {
  // Game Variables
  Timer? gameTimer;
  bool gameStarted = false;
  bool gameOver = false;
  bool gameWon = false;
  int score = 0;
  int lives = 3;

  // Animation Controllers
  late AnimationController pacmanController;
  late AnimationController ghostController;
  late AnimationController powerPelletController;
  late AnimationController moveAnimationController;
  late AnimationController scoreAnimationController;

  // Smooth Movement Variables
  double pacmanAnimX = 9.0;
  double pacmanAnimY = 15.0;
  List<Offset> ghostAnimPositions = [];

  // Player
  int pacmanX = 9;
  int pacmanY = 15;
  String direction = 'right';
  String nextDirection = 'right';
  bool isMoving = false;

  // Ghosts
  List<Ghost> ghosts = [];
  bool powerMode = false;
  Timer? powerModeTimer;
  int powerModeTimeLeft = 0;

  // Game State
  List<List<int>> maze = [];
  int totalDots = 0;
  int dotsCollected = 0;
  int comboMultiplier = 1;
  int scorePopup = 0;

  // Visual Effects
  List<ParticleEffect> particles = [];
  Color mazeColor = const Color(0xFF1565C0);

  // Grid size
  final int rows = 21;
  final int cols = 19;

  @override
  void initState() {
    super.initState();
    initializeGame();
    setupAnimations();
  }

  void setupAnimations() {
    pacmanController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..repeat();

    ghostController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    powerPelletController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    moveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    moveAnimationController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void initializeGame() {
    createMaze();
    setupGhosts();
    setupGhostAnimPositions();
    countDots();
  }

  void setupGhostAnimPositions() {
    ghostAnimPositions = ghosts
        .map((ghost) => Offset(ghost.x.toDouble(), ghost.y.toDouble()))
        .toList();
  }

  void createMaze() {
    // Enhanced maze layout with better visual design
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
      Ghost(
        x: 9,
        y: 9,
        color: const Color(0xFFFF4444),
        direction: 'up',
        name: 'Blinky',
      ),
      Ghost(
        x: 8,
        y: 9,
        color: const Color(0xFFFF69B4),
        direction: 'left',
        name: 'Pinky',
      ),
      Ghost(
        x: 10,
        y: 9,
        color: const Color(0xFF00FFFF),
        direction: 'right',
        name: 'Inky',
      ),
      Ghost(
        x: 9,
        y: 10,
        color: const Color(0xFFFFB852),
        direction: 'down',
        name: 'Clyde',
      ),
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
      pacmanAnimX = 9.0;
      pacmanAnimY = 15.0;
      direction = 'right';
      nextDirection = 'right';
      powerMode = false;
      comboMultiplier = 1;
      particles.clear();
    });

    createMaze();
    setupGhosts();
    setupGhostAnimPositions();
    countDots();

    gameTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      updateGame();
    });
  }

  void updateGame() {
    if (gameOver || gameWon) return;

    setState(() {
      if (!isMoving) {
        movePacman();
        moveGhosts();
      }
      updateParticles();
      checkCollisions();
      checkWinCondition();
      updatePowerModeTimer();
    });
  }

  void updatePowerModeTimer() {
    if (powerMode) {
      powerModeTimeLeft = ((powerModeTimer?.tick ?? 0) * 120 / 1000).floor();
    }
  }

  void updateParticles() {
    particles.removeWhere((particle) => particle.life <= 0);
    for (var particle in particles) {
      particle.update();
    }
  }

  void addParticleEffect(double x, double y, Color color, int count) {
    for (int i = 0; i < count; i++) {
      particles.add(
        ParticleEffect(
          x: x,
          y: y,
          color: color,
          velocity: Offset(
            (Random().nextDouble() - 0.5) * 4,
            (Random().nextDouble() - 0.5) * 4,
          ),
        ),
      );
    }
  }

  void movePacman() {
    // Try to change direction if possible
    if (canMove(pacmanX, pacmanY, nextDirection)) {
      direction = nextDirection;
    }

    if (canMove(pacmanX, pacmanY, direction)) {
      isMoving = true;

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

      // Animate smooth movement
      animatePacmanMovement(newX.toDouble(), newY.toDouble());

      pacmanX = newX;
      pacmanY = newY;

      // Collect dots and power pellets
      if (maze[pacmanY][pacmanX] == 2) {
        maze[pacmanY][pacmanX] = 4;
        int points = 10 * comboMultiplier;
        score += points;
        dotsCollected++;
        showScorePopup(points);
        addParticleEffect(
          pacmanX.toDouble(),
          pacmanY.toDouble(),
          Colors.yellow,
          3,
        );
        HapticFeedback.lightImpact();

        if (comboMultiplier < 5) comboMultiplier++;
      } else if (maze[pacmanY][pacmanX] == 3) {
        maze[pacmanY][pacmanX] = 4;
        int points = 50 * comboMultiplier;
        score += points;
        showScorePopup(points);
        addParticleEffect(
          pacmanX.toDouble(),
          pacmanY.toDouble(),
          Colors.orange,
          8,
        );
        activatePowerMode();
        HapticFeedback.mediumImpact();
      } else {
        comboMultiplier = 1; // Reset combo if no dot collected
      }
    }
  }

  void animatePacmanMovement(double targetX, double targetY) {
    final startX = pacmanAnimX;
    final startY = pacmanAnimY;

    moveAnimationController.reset();
    moveAnimationController.forward().then((_) {
      isMoving = false;
    });

    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: moveAnimationController, curve: Curves.easeOut),
    );

    animation.addListener(() {
      pacmanAnimX = startX + (targetX - startX) * animation.value;
      pacmanAnimY = startY + (targetY - startY) * animation.value;
    });
  }

  void showScorePopup(int points) {
    setState(() {
      scorePopup = points;
    });

    scoreAnimationController.reset();
    scoreAnimationController.forward();

    Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          scorePopup = 0;
        });
      }
    });
  }

  void moveGhosts() {
    for (int i = 0; i < ghosts.length; i++) {
      var ghost = ghosts[i];

      // Enhanced AI behavior
      String targetDirection = getGhostTargetDirection(ghost, i);

      List<String> possibleDirections = [];
      if (canMove(ghost.x, ghost.y, 'up')) possibleDirections.add('up');
      if (canMove(ghost.x, ghost.y, 'down')) possibleDirections.add('down');
      if (canMove(ghost.x, ghost.y, 'left')) possibleDirections.add('left');
      if (canMove(ghost.x, ghost.y, 'right')) possibleDirections.add('right');

      if (possibleDirections.isNotEmpty) {
        // Prefer target direction if possible
        if (possibleDirections.contains(targetDirection)) {
          ghost.direction = targetDirection;
        } else {
          // Avoid reversing direction unless necessary
          String oppositeDirection = getOppositeDirection(ghost.direction);
          if (possibleDirections.length > 1) {
            possibleDirections.removeWhere((dir) => dir == oppositeDirection);
          }

          // Choose best direction towards target
          ghost.direction = getBestDirection(
            possibleDirections,
            ghost,
            targetDirection,
          );
        }
      }

      // Move ghost with animation
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

        // Animate ghost movement
        animateGhostMovement(i, newX.toDouble(), newY.toDouble());
      }
    }
  }

  void animateGhostMovement(int ghostIndex, double targetX, double targetY) {
    if (ghostIndex < ghostAnimPositions.length) {
      final startPos = ghostAnimPositions[ghostIndex];
      ghostAnimPositions[ghostIndex] = Offset(
        startPos.dx + (targetX - startPos.dx) * 0.3,
        startPos.dy + (targetY - startPos.dy) * 0.3,
      );
    }
  }

  String getGhostTargetDirection(Ghost ghost, int ghostIndex) {
    // Different AI behaviors for each ghost
    switch (ghostIndex) {
      case 0: // Blinky - aggressive, targets Pacman directly
        return getDirectionToTarget(ghost.x, ghost.y, pacmanX, pacmanY);
      case 1: // Pinky - tries to ambush Pacman
        int targetX = pacmanX;
        int targetY = pacmanY;
        switch (direction) {
          case 'up':
            targetY -= 4;
            break;
          case 'down':
            targetY += 4;
            break;
          case 'left':
            targetX -= 4;
            break;
          case 'right':
            targetX += 4;
            break;
        }
        return getDirectionToTarget(ghost.x, ghost.y, targetX, targetY);
      case 2: // Inky - unpredictable
        if (Random().nextDouble() < 0.7) {
          return getDirectionToTarget(ghost.x, ghost.y, pacmanX, pacmanY);
        } else {
          return ['up', 'down', 'left', 'right'][Random().nextInt(4)];
        }
      case 3: // Clyde - runs away when close
        double distance = sqrt(
          pow(ghost.x - pacmanX, 2) + pow(ghost.y - pacmanY, 2),
        );
        if (distance < 8 && !powerMode) {
          // Run away
          return getDirectionToTarget(
            ghost.x,
            ghost.y,
            pacmanX < cols / 2 ? cols - 1 : 0,
            pacmanY < rows / 2 ? rows - 1 : 0,
          );
        } else {
          return getDirectionToTarget(ghost.x, ghost.y, pacmanX, pacmanY);
        }
      default:
        return getDirectionToTarget(ghost.x, ghost.y, pacmanX, pacmanY);
    }
  }

  String getDirectionToTarget(int fromX, int fromY, int targetX, int targetY) {
    int deltaX = targetX - fromX;
    int deltaY = targetY - fromY;

    if (powerMode) {
      // Run away from Pacman in power mode
      deltaX = -deltaX;
      deltaY = -deltaY;
    }

    if (deltaX.abs() > deltaY.abs()) {
      return deltaX > 0 ? 'right' : 'left';
    } else {
      return deltaY > 0 ? 'down' : 'up';
    }
  }

  String getBestDirection(
    List<String> directions,
    Ghost ghost,
    String preferred,
  ) {
    if (directions.contains(preferred)) return preferred;

    // Return direction closest to preferred
    final directionPriority = {
      'up': ['up', 'left', 'right', 'down'],
      'down': ['down', 'left', 'right', 'up'],
      'left': ['left', 'up', 'down', 'right'],
      'right': ['right', 'up', 'down', 'left'],
    };

    for (String dir in directionPriority[preferred] ?? directions) {
      if (directions.contains(dir)) return dir;
    }

    return directions.first;
  }

  String getOppositeDirection(String dir) {
    switch (dir) {
      case 'up':
        return 'down';
      case 'down':
        return 'up';
      case 'left':
        return 'right';
      case 'right':
        return 'left';
      default:
        return 'up';
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
      mazeColor = Colors.purple;
    });

    powerModeTimer?.cancel();
    powerModeTimer = Timer(const Duration(seconds: 8), () {
      setState(() {
        powerMode = false;
        mazeColor = const Color(0xFF1565C0);
      });
    });
  }

  void checkCollisions() {
    for (int i = 0; i < ghosts.length; i++) {
      if (ghosts[i].x == pacmanX && ghosts[i].y == pacmanY) {
        if (powerMode) {
          // Eat ghost
          int points = 200 * (i + 1);
          score += points;
          showScorePopup(points);
          addParticleEffect(
            pacmanX.toDouble(),
            pacmanY.toDouble(),
            ghosts[i].color,
            10,
          );
          respawnGhost(i);
          HapticFeedback.heavyImpact();
        } else {
          // Lose life
          lives--;
          addParticleEffect(
            pacmanX.toDouble(),
            pacmanY.toDouble(),
            Colors.red,
            15,
          );
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
    ghostAnimPositions[index] = const Offset(9.0, 9.0);
  }

  void resetPositions() {
    pacmanX = 9;
    pacmanY = 15;
    pacmanAnimX = 9.0;
    pacmanAnimY = 15.0;
    direction = 'right';
    nextDirection = 'right';
    setupGhosts();
    setupGhostAnimPositions();

    // Brief pause before continuing
    gameTimer?.cancel();
    Timer(const Duration(milliseconds: 1000), () {
      if (gameStarted && !gameOver) {
        gameTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
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
      addParticleEffect(
        pacmanX.toDouble(),
        pacmanY.toDouble(),
        Colors.amber,
        20,
      );
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
      particles.clear();
      comboMultiplier = 1;
      scorePopup = 0;
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
    pacmanController.dispose();
    ghostController.dispose();
    powerPelletController.dispose();
    moveAnimationController.dispose();
    scoreAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: GestureDetector(
        onPanUpdate: (details) {
          // Enhanced swipe detection
          const double threshold = 8.0;
          if (details.delta.dx > threshold)
            handleSwipe('right');
          else if (details.delta.dx < -threshold)
            handleSwipe('left');
          else if (details.delta.dy > threshold)
            handleSwipe('down');
          else if (details.delta.dy < -threshold)
            handleSwipe('up');
        },
        onTap: !gameStarted ? startGame : null,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: gameStarted ? _buildGameArea() : _buildStartScreen(),
              ),
              if (gameOver || gameWon) _buildGameOverOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.yellow, size: 28),
          ),
          const Spacer(),
          if (gameStarted) ...[
            Column(
              children: [
                Text(
                  'Score: $score',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                ),
                if (comboMultiplier > 1)
                  Text(
                    'x$comboMultiplier Combo!',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                Row(
                  children: List.generate(
                    lives,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: const Text('🟡', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
                if (powerMode)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'POWER: ${powerModeTimeLeft}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          colors: [Colors.yellow.withOpacity(0.1), Colors.transparent],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Pacman
            AnimatedBuilder(
              animation: pacmanController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (pacmanController.value * 0.1),
                  child: const Text('🟡', style: TextStyle(fontSize: 100)),
                );
              },
            ),
            const SizedBox(height: 30),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.yellow, Colors.orange, Colors.red],
              ).createShader(bounds),
              child: const Text(
                'PAC-MAN',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Collect all dots and avoid ghosts!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: powerPelletController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (powerPelletController.value * 0.05),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.yellow,
                          Color(0xFFFFA000),
                          Colors.orange,
                        ],
                      ),
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
                );
              },
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
                  Text(
                    '🎮 Controls',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Swipe to change direction',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  Text(
                    'Eat power pellets to turn the tables!',
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameArea() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: AspectRatio(
        aspectRatio: cols / rows,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  colors: [Colors.black, Color(0xFF1A1A1A)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: powerMode ? Colors.purple : mazeColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (powerMode ? Colors.purple : mazeColor).withOpacity(
                      0.5,
                    ),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: GridView.builder(
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
            ),
            // Particle effects layer
            ...particles.map((particle) => _buildParticle(particle)),
            // Score popup
            if (scorePopup > 0) _buildScorePopup(),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(ParticleEffect particle) {
    return Positioned(
      left: particle.x * (MediaQuery.of(context).size.width - 16) / cols,
      top: particle.y * (MediaQuery.of(context).size.width - 16) / cols,
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: particle.color.withOpacity(particle.life / 100),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildScorePopup() {
    return AnimatedBuilder(
      animation: scoreAnimationController,
      builder: (context, child) {
        return Positioned(
          left: pacmanAnimX * (MediaQuery.of(context).size.width - 16) / cols,
          top:
              (pacmanAnimY - scoreAnimationController.value * 2) *
              (MediaQuery.of(context).size.width - 16) /
              cols,
          child: Transform.scale(
            scale: 1.0 + scoreAnimationController.value * 0.5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                '+$scorePopup',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMazeCell(int x, int y) {
    Widget content;

    // Check if Pacman is here
    if (pacmanX == x && pacmanY == y) {
      content = _buildPacman();
    }
    // Check if any ghost is here
    else {
      Ghost? ghostHere;
      int ghostIndex = -1;
      for (int i = 0; i < ghosts.length; i++) {
        if (ghosts[i].x == x && ghosts[i].y == y) {
          ghostHere = ghosts[i];
          ghostIndex = i;
          break;
        }
      }

      if (ghostHere != null) {
        content = _buildGhost(ghostHere, ghostIndex);
      } else {
        content = _buildMazeElement(maze[y][x]);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: maze[y][x] == 1
            ? (powerMode
                  ? Colors.purple.withOpacity(0.8)
                  : mazeColor.withOpacity(0.8))
            : Colors.transparent,
        borderRadius: maze[y][x] == 1 ? BorderRadius.circular(2) : null,
        boxShadow: maze[y][x] == 1
            ? [
                BoxShadow(
                  color: (powerMode ? Colors.purple : mazeColor).withOpacity(
                    0.3,
                  ),
                  blurRadius: 2,
                ),
              ]
            : null,
      ),
      child: content,
    );
  }

  Widget _buildPacman() {
    return AnimatedBuilder(
      animation: pacmanController,
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
              gradient: RadialGradient(
                colors: [Colors.yellow, Color(0xFFFFA000)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.8),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: CustomPaint(painter: PacmanPainter(pacmanController.value)),
          ),
        );
      },
    );
  }

  Widget _buildGhost(Ghost ghost, int ghostIndex) {
    Color ghostColor = powerMode ? Colors.blue.withOpacity(0.8) : ghost.color;
    bool isFlashing = powerMode && powerModeTimeLeft <= 2;

    return AnimatedBuilder(
      animation: ghostController,
      builder: (context, child) {
        Color currentColor = ghostColor;
        if (isFlashing && ghostController.value > 0.5) {
          currentColor = Colors.white;
        }

        return Transform.scale(
          scale: 0.85 + (ghostController.value * 0.15),
          child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [currentColor, currentColor.withOpacity(0.7)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              boxShadow: [
                BoxShadow(
                  color: currentColor.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CustomPaint(painter: GhostPainter(currentColor, powerMode)),
          ),
        );
      },
    );
  }

  Widget _buildMazeElement(int cellType) {
    switch (cellType) {
      case 2: // Dot
        return Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.yellow, Color(0xFFFFA000)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.8),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      case 3: // Power Pellet
        return AnimatedBuilder(
          animation: powerPelletController,
          builder: (context, child) {
            return Center(
              child: Transform.scale(
                scale: 0.7 + (powerPelletController.value * 0.6),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Colors.yellow, Color(0xFFFFA000), Colors.orange],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.9),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGameOverOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.95),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: scoreAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (scoreAnimationController.value * 0.1),
                  child: Text(
                    gameWon ? '🎉 VICTORY!' : '👻 GAME OVER',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader =
                            LinearGradient(
                              colors: gameWon
                                  ? [Colors.amber, Colors.yellow, Colors.orange]
                                  : [Colors.red, Colors.pink, Colors.purple],
                            ).createShader(
                              const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                            ),
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 8,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.yellow.withOpacity(0.2),
                    Colors.orange.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.yellow, width: 2),
              ),
              child: Text(
                'Final Score: $score',
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
            const SizedBox(height: 15),
            if (gameWon)
              Text(
                'All dots collected! 🟡',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
              )
            else
              Text(
                'Better luck next time! 👾',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
              ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: powerPelletController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (powerPelletController.value * 0.02),
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          resetGame();
                          startGame();
                        },
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 35,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              side: BorderSide(color: Colors.yellow, width: 2),
                            ).copyWith(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                    return states.contains(
                                          MaterialState.pressed,
                                        )
                                        ? Colors.yellow.withOpacity(0.2)
                                        : Colors.yellow.withOpacity(0.1);
                                  }),
                            ),
                        child: const Text(
                          'PLAY AGAIN',
                          style: TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 25),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        side: BorderSide(color: Colors.white54, width: 2),
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith((
                          states,
                        ) {
                          return states.contains(MaterialState.pressed)
                              ? Colors.white.withOpacity(0.1)
                              : Colors.transparent;
                        }),
                      ),
                  child: const Text(
                    'MENU',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
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

// Enhanced Ghost Class
class Ghost {
  int x, y;
  Color color;
  String direction;
  String name;

  Ghost({
    required this.x,
    required this.y,
    required this.color,
    required this.direction,
    required this.name,
  });
}

// Particle Effect Class
class ParticleEffect {
  double x, y;
  Color color;
  Offset velocity;
  double life;

  ParticleEffect({
    required this.x,
    required this.y,
    required this.color,
    required this.velocity,
    this.life = 100.0,
  });

  void update() {
    x += velocity.dx * 0.1;
    y += velocity.dy * 0.1;
    life -= 3.0;
    velocity = velocity * 0.98; // Friction
  }
}

// Enhanced Pacman Painter
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

    // Draw mouth opening with smoother animation
    double mouthAngle = (sin(animationValue * pi * 2) * 0.5 + 0.5) * pi * 0.8;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -mouthAngle / 2,
      mouthAngle,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Enhanced Ghost Painter
class GhostPainter extends CustomPainter {
  final Color color;
  final bool powerMode;

  GhostPainter(this.color, this.powerMode);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw eyes
    final eyeRadius = size.width * 0.08;
    final leftEye = Offset(size.width * 0.35, size.height * 0.35);
    final rightEye = Offset(size.width * 0.65, size.height * 0.35);

    // In power mode, draw different eyes (scared)
    if (powerMode) {
      // Draw zigzag mouth
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

      // Draw straight line eyes
      final eyePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(leftEye.dx - eyeRadius, leftEye.dy),
        Offset(leftEye.dx + eyeRadius, leftEye.dy),
        eyePaint,
      );
      canvas.drawLine(
        Offset(rightEye.dx - eyeRadius, rightEye.dy),
        Offset(rightEye.dx + eyeRadius, rightEye.dy),
        eyePaint,
      );
    } else {
      // Normal eyes
      canvas.drawCircle(leftEye, eyeRadius, paint);
      canvas.drawCircle(rightEye, eyeRadius, paint);

      // Draw pupils
      paint.color = Colors.black;
      canvas.drawCircle(leftEye, eyeRadius * 0.6, paint);
      canvas.drawCircle(rightEye, eyeRadius * 0.6, paint);
    }

    // Draw bottom wavy part (more detailed)
    paint.color = color;
    final path = Path();
    path.moveTo(0, size.height * 0.65);

    const int waves = 5;
    for (int i = 0; i < waves; i++) {
      final waveX = (i + 1) * size.width / waves;
      final waveY = size.height * (0.75 + (i % 2 == 0 ? 0.15 : -0.05));
      path.lineTo(waveX, waveY);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
