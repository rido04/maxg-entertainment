// lib/games/flame/tictactoe_game.dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

enum Player { x, o, none }

class TicTacToeGame extends FlameGame with TapCallbacks {
  late GameBoard gameBoard;
  late GameStatusComponent statusComponent;
  late RestartButton restartButton;

  Player currentPlayer = Player.x;
  bool gameEnded = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    gameBoard = GameBoard();
    statusComponent = GameStatusComponent();
    restartButton = RestartButton();

    add(gameBoard);
    add(statusComponent);
    add(restartButton);

    updateStatus();
  }

  void makeMove(int row, int col) {
    if (gameEnded || gameBoard.getCell(row, col) != Player.none) {
      return;
    }

    gameBoard.setCell(row, col, currentPlayer);

    if (checkWinner()) {
      gameEnded = true;
      statusComponent.updateStatus(
        '${currentPlayer == Player.x ? 'X' : 'O'} Wins!',
      );
    } else if (gameBoard.isFull()) {
      gameEnded = true;
      statusComponent.updateStatus('It\'s a Draw!');
    } else {
      currentPlayer = currentPlayer == Player.x ? Player.o : Player.x;
      updateStatus();
    }
  }

  bool checkWinner() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (gameBoard.getCell(i, 0) == currentPlayer &&
          gameBoard.getCell(i, 1) == currentPlayer &&
          gameBoard.getCell(i, 2) == currentPlayer) {
        return true;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (gameBoard.getCell(0, i) == currentPlayer &&
          gameBoard.getCell(1, i) == currentPlayer &&
          gameBoard.getCell(2, i) == currentPlayer) {
        return true;
      }
    }

    // Check diagonals
    if (gameBoard.getCell(0, 0) == currentPlayer &&
        gameBoard.getCell(1, 1) == currentPlayer &&
        gameBoard.getCell(2, 2) == currentPlayer) {
      return true;
    }

    if (gameBoard.getCell(0, 2) == currentPlayer &&
        gameBoard.getCell(1, 1) == currentPlayer &&
        gameBoard.getCell(2, 0) == currentPlayer) {
      return true;
    }

    return false;
  }

  void updateStatus() {
    if (!gameEnded) {
      statusComponent.updateStatus(
        'Current Player: ${currentPlayer == Player.x ? 'X' : 'O'}',
      );
    }
  }

  void restartGame() {
    gameBoard.reset();
    currentPlayer = Player.x;
    gameEnded = false;
    updateStatus();
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Updated method signature
    final position = event.localPosition;

    // Check if restart button was tapped
    if (restartButton.containsPoint(position)) {
      restartGame();
      return;
    }

    // Convert global position to board local position
    final boardLocalPosition = position - gameBoard.position;
    if (gameBoard.containsPoint(boardLocalPosition)) {
      final cell = gameBoard.getCellFromPosition(boardLocalPosition);
      if (cell != null) {
        makeMove(cell.row, cell.col);
      }
    }
  }
}

class GameBoard extends RectangleComponent with HasGameRef<TicTacToeGame> {
  static const double cellSize = 100.0;
  static const double boardSize = cellSize * 3;

  List<List<Player>> board = List.generate(
    3,
    (_) => List.filled(3, Player.none),
  );
  List<List<CellComponent>> cells = [];

  GameBoard()
    : super(
        size: Vector2(boardSize, boardSize),
        paint: Paint()..color = Colors.grey[300]!,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Center the board - use game size after it's loaded
    position = Vector2(
      (game.size.x - size.x) / 2,
      (game.size.y - size.y) / 2 - 50,
    );

    // Create cells
    for (int i = 0; i < 3; i++) {
      cells.add([]);
      for (int j = 0; j < 3; j++) {
        final cell = CellComponent(i, j);
        cell.position = Vector2(j * cellSize, i * cellSize);
        cells[i].add(cell);
        add(cell);
      }
    }
  }

  Player getCell(int row, int col) => board[row][col];

  void setCell(int row, int col, Player player) {
    board[row][col] = player;
    cells[row][col].setPlayer(player);
  }

  bool isFull() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == Player.none) {
          return false;
        }
      }
    }
    return true;
  }

  void reset() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        board[i][j] = Player.none;
        cells[i][j].setPlayer(Player.none);
      }
    }
  }

  CellPosition? getCellFromPosition(Vector2 position) {
    if (position.x < 0 ||
        position.x > size.x ||
        position.y < 0 ||
        position.y > size.y) {
      return null;
    }

    final col = (position.x / cellSize).floor();
    final row = (position.y / cellSize).floor();

    if (row >= 0 && row < 3 && col >= 0 && col < 3) {
      return CellPosition(row, col);
    }

    return null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3;

    // Draw grid lines
    // Vertical lines
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.y),
        paint,
      );
    }

    // Horizontal lines
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.x, i * cellSize),
        paint,
      );
    }
  }
}

class CellComponent extends RectangleComponent {
  final int row;
  final int col;
  Player player = Player.none;

  CellComponent(this.row, this.col)
    : super(
        size: Vector2(GameBoard.cellSize, GameBoard.cellSize),
        paint: Paint()..color = Colors.transparent,
      );

  void setPlayer(Player newPlayer) {
    player = newPlayer;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (player == Player.none) return;

    final paint = Paint()
      ..color = player == Player.x ? Colors.red : Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final center = Vector2(size.x / 2, size.y / 2);
    final radius = size.x * 0.3;

    if (player == Player.x) {
      // Draw X
      canvas.drawLine(
        Offset(center.x - radius, center.y - radius),
        Offset(center.x + radius, center.y + radius),
        paint,
      );
      canvas.drawLine(
        Offset(center.x + radius, center.y - radius),
        Offset(center.x - radius, center.y + radius),
        paint,
      );
    } else if (player == Player.o) {
      // Draw O
      canvas.drawCircle(Offset(center.x, center.y), radius, paint);
    }
  }
}

class CellPosition {
  final int row;
  final int col;

  CellPosition(this.row, this.col);
}

class GameStatusComponent extends TextComponent with HasGameRef<TicTacToeGame> {
  GameStatusComponent()
    : super(
        text: 'Current Player: X',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  @override
  void onMount() {
    super.onMount();
    // Center the text using game size
    position = Vector2((game.size.x - size.x) / 2, 50);
  }

  void updateStatus(String newStatus) {
    text = newStatus;
    // Recenter after text change
    position = Vector2((game.size.x - size.x) / 2, 50);
  }
}

class RestartButton extends RectangleComponent with HasGameRef<TicTacToeGame> {
  late TextComponent buttonText;

  RestartButton()
    : super(size: Vector2(150, 50), paint: Paint()..color = Colors.blue);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    buttonText = TextComponent(
      text: 'Restart',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(buttonText);
  }

  @override
  void onMount() {
    super.onMount();

    // Position button at bottom center
    position = Vector2((game.size.x - size.x) / 2, game.size.y - 100);

    // Center text in button after mounting
    if (buttonText.isMounted) {
      buttonText.position = Vector2(
        (size.x - buttonText.size.x) / 2,
        (size.y - buttonText.size.y) / 2,
      );
    }
  }
}
