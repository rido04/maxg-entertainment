// lib/games/memory_game.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class MemoryGame extends StatefulWidget {
  const MemoryGame({Key? key}) : super(key: key);

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  static const int gridSize = 4; // 4x4 grid
  static const List<IconData> gameIcons = [
    Icons.favorite,
    Icons.star,
    Icons.music_note,
    Icons.emoji_emotions,
    Icons.sports_soccer,
    Icons.palette,
    Icons.lightbulb,
    Icons.cake,
  ];

  List<MemoryCard> cards = [];
  List<int> selectedCards = [];
  int matches = 0;
  int moves = 0;
  bool isProcessing = false;
  bool gameWon = false;
  bool showingPreview = true;
  int countdownSeconds = 3;
  Timer? gameTimer;
  Timer? previewTimer;
  Timer? countdownTimer;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    previewTimer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    cards.clear();
    selectedCards.clear();
    matches = 0;
    moves = 0;
    seconds = 0;
    gameWon = false;
    isProcessing = false;
    showingPreview = true;
    countdownSeconds = 3;

    // Create pairs of cards and shuffle
    List<IconData> shuffledIcons = [...gameIcons, ...gameIcons]..shuffle();

    for (int i = 0; i < 16; i++) {
      cards.add(
        MemoryCard(
          id: i,
          icon: shuffledIcons[i],
          isFlipped: true, // Start flipped for preview
          isMatched: false,
        ),
      );
    }

    setState(() {});

    // Start countdown timer
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds > 0) {
        setState(() {
          countdownSeconds--;
        });
      } else {
        timer.cancel();
        // After countdown, flip all cards
        setState(() {
          showingPreview = false;
          for (var card in cards) {
            card.isFlipped = false;
          }
        });
        // Start game timer
        _startTimer();
      }
    });
  }

  void _startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!gameWon) {
        setState(() {
          seconds++;
        });
      }
    });
  }

  void _cardTapped(int index) {
    // Can't tap during preview
    if (showingPreview) return;

    if (isProcessing ||
        cards[index].isFlipped ||
        cards[index].isMatched ||
        selectedCards.length >= 2) {
      return;
    }

    setState(() {
      cards[index].isFlipped = true;
      selectedCards.add(index);
    });

    if (selectedCards.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    isProcessing = true;
    moves++;

    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      final firstCard = cards[selectedCards[0]];
      final secondCard = cards[selectedCards[1]];

      if (firstCard.icon == secondCard.icon) {
        // Match found
        setState(() {
          firstCard.isMatched = true;
          secondCard.isMatched = true;
          matches++;
        });

        if (matches == 8) {
          // All pairs matched
          gameTimer?.cancel();
          setState(() {
            gameWon = true;
          });
        }
      } else {
        // No match - flip back
        setState(() {
          firstCard.isFlipped = false;
          secondCard.isFlipped = false;
        });
      }

      selectedCards.clear();
      isProcessing = false;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1421),
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'MEMORY GAME',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            if (showingPreview) ...[
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.visibility,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      countdownSeconds > 0 ? '$countdownSeconds' : 'READY!',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        backgroundColor: const Color(0xFF1B2332),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00E676)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Game stats
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B2332), Color(0xFF0D1421)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF00B14F).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      Icons.timer,
                      'TIME',
                      _formatTime(seconds),
                      const Color(0xFF00E676),
                    ),
                    _buildStatItem(
                      Icons.touch_app,
                      'MOVES',
                      moves.toString(),
                      Colors.orange,
                    ),
                    _buildStatItem(
                      Icons.check_circle,
                      'MATCHES',
                      '$matches/8',
                      Colors.blue,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Win message
              if (gameWon)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E676), Color(0xFF00B14F)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'CONGRATULATIONS!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Time: ${_formatTime(seconds)} | Moves: $moves',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Game board - responsive grid
              Expanded(
                child: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate optimal size for square grid
                        double maxSize = min(
                          constraints.maxWidth * 0.95,
                          constraints.maxHeight * 0.9,
                        );

                        return Center(
                          child: SizedBox(
                            width: maxSize,
                            height: maxSize,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: 16,
                              itemBuilder: (context, index) {
                                final card = cards[index];
                                return _buildCard(card, index, maxSize);
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    // Countdown Overlay
                    if (showingPreview && countdownSeconds > 0)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.5, end: 1.2),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.elasticOut,
                                  builder: (context, scale, child) {
                                    return Transform.scale(
                                      scale: scale,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF00E676),
                                              Color(0xFF00B14F),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF00E676,
                                              ).withOpacity(0.6),
                                              blurRadius: 30,
                                              spreadRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            countdownSeconds.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 64,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 30),
                                const Text(
                                  'MEMORIZE THE CARDS!',
                                  style: TextStyle(
                                    color: Color(0xFF00E676),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.orange,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Text(
                                    'Get ready to match pairs!',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Control button
              ElevatedButton.icon(
                onPressed: _initializeGame,
                icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
                label: const Text(
                  'NEW GAME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B14F),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF00B14F).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(MemoryCard card, int index, double gridSize) {
    final isSelected = selectedCards.contains(index);
    final cardSize =
        (gridSize - (12 * 3)) / 4; // Calculate individual card size

    return GestureDetector(
      onTap: () => _cardTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: card.isMatched
              ? LinearGradient(
                  colors: [
                    const Color(0xFF00E676).withOpacity(0.3),
                    const Color(0xFF00B14F).withOpacity(0.3),
                  ],
                )
              : card.isFlipped
              ? const LinearGradient(
                  colors: [Color(0xFF1B2332), Color(0xFF0D1421)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00B14F)],
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: card.isMatched
                ? const Color(0xFF00E676)
                : isSelected
                ? Colors.orange
                : card.isFlipped
                ? const Color(0xFF00B14F).withOpacity(0.5)
                : Colors.transparent,
            width: card.isMatched || isSelected ? 3 : 2,
          ),
          boxShadow: [
            if (card.isMatched || isSelected)
              BoxShadow(
                color: card.isMatched
                    ? const Color(0xFF00E676).withOpacity(0.5)
                    : Colors.orange.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Center(
          child: card.isFlipped || card.isMatched
              ? Icon(
                  card.icon,
                  size: cardSize * 0.5,
                  color: card.isMatched
                      ? const Color(0xFF00E676)
                      : Colors.white,
                )
              : Icon(
                  Icons.help_outline,
                  size: cardSize * 0.5,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}

class MemoryCard {
  final int id;
  final IconData icon;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.icon,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
