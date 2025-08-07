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
  static const List<String> emojis = [
    '🎮',
    '🎯',
    '🎲',
    '🎪',
    '🎨',
    '🎭',
    '🎪',
    '🎸',
  ];

  List<MemoryCard> cards = [];
  List<int> selectedCards = [];
  int matches = 0;
  int moves = 0;
  bool isProcessing = false;
  bool gameWon = false;
  Timer? gameTimer;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
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

    // Create pairs of cards
    List<String> gameEmojis = [...emojis, ...emojis]..shuffle();

    for (int i = 0; i < 16; i++) {
      cards.add(
        MemoryCard(
          id: i,
          emoji: gameEmojis[i],
          isFlipped: false,
          isMatched: false,
        ),
      );
    }

    // Start timer
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!gameWon) {
        setState(() {
          seconds++;
        });
      }
    });

    setState(() {});
  }

  void _cardTapped(int index) {
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

    Timer(const Duration(milliseconds: 1000), () {
      final firstCard = cards[selectedCards[0]];
      final secondCard = cards[selectedCards[1]];

      if (firstCard.emoji == secondCard.emoji) {
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Memory Game'),
        backgroundColor: const Color(0xFF00B14F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Game stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Time', style: TextStyle(color: Colors.grey)),
                      Text(
                        _formatTime(seconds),
                        style: const TextStyle(
                          color: Color(0xFF00B14F),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Moves', style: TextStyle(color: Colors.grey)),
                      Text(
                        moves.toString(),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Matches',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '$matches/8',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (gameWon)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B14F),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🎉 Congratulations! 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Time: ${_formatTime(seconds)} | Moves: $moves',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Game board - responsive grid
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Optimize for tablet landscape
                  double maxSize = constraints.maxHeight * 0.8;
                  if (constraints.maxWidth < constraints.maxHeight) {
                    maxSize = constraints.maxWidth * 0.9;
                  }

                  return Center(
                    child: SizedBox(
                      width: maxSize,
                      height: maxSize,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: 16,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return GestureDetector(
                            onTap: () => _cardTapped(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: card.isMatched
                                    ? const Color(0xFF00B14F).withOpacity(0.3)
                                    : card.isFlipped
                                    ? const Color(0xFF1E1E1E)
                                    : const Color(0xFF00B14F),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: card.isMatched
                                      ? const Color(0xFF00B14F)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: card.isFlipped || card.isMatched
                                    ? Text(
                                        card.emoji,
                                        style: TextStyle(
                                          fontSize: constraints.maxWidth > 600
                                              ? 35
                                              : 30,
                                        ),
                                      )
                                    : Text(
                                        '?',
                                        style: TextStyle(
                                          fontSize: constraints.maxWidth > 600
                                              ? 35
                                              : 30,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Control button
            ElevatedButton(
              onPressed: _initializeGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B14F),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'New Game',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemoryCard {
  final int id;
  final String emoji;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
