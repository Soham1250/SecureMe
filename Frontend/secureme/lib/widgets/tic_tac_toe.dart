import 'dart:math';
import 'package:flutter/material.dart';
import 'game_painters.dart';

class TicTacToe extends StatefulWidget {
  final Function(bool) onGameComplete;
  final bool playerFirst;

  const TicTacToe({
    super.key,
    required this.onGameComplete,
    required this.playerFirst,
  });

  @override
  State<TicTacToe> createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> with TickerProviderStateMixin {
  late List<List<String>> board;
  late bool isPlayerTurn;
  bool gameEnded = false;
  String winner = '';
  List<int>? winningLine;

  // Statistics
  int playerWins = 0;
  int computerWins = 0;
  int draws = 0;

  // Animation controllers
  final List<AnimationController> moveControllers = [];
  AnimationController? lineController;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  @override
  void didUpdateWidget(TicTacToe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playerFirst != widget.playerFirst) {
      initializeGame();
    }
  }

  void initializeGame() {
    board = List.generate(3, (_) => List.filled(3, ''));
    isPlayerTurn = widget.playerFirst;
    gameEnded = false;
    winner = '';
    winningLine = null;

    // Reset and dispose old animation controllers
    for (var controller in moveControllers) {
      controller.reset();
      controller.dispose();
    }
    moveControllers.clear();

    // Create new animation controllers
    for (int i = 0; i < 9; i++) {
      moveControllers.add(AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ));
    }

    lineController?.reset();
    lineController?.dispose();
    lineController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Make computer move if it's first
    if (!isPlayerTurn && mounted) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && !gameEnded) {
          makeComputerMove();
        }
      });
    }
  }

  bool checkWin(String player, [List<List<String>>? testBoard]) {
    final boardToCheck = testBoard ?? board;

    // Check rows
    for (int i = 0; i < 3; i++) {
      if (boardToCheck[i][0] == player &&
          boardToCheck[i][1] == player &&
          boardToCheck[i][2] == player) {
        if (testBoard == null) {
          winningLine = [i * 3, i * 3 + 1, i * 3 + 2];
        }
        return true;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (boardToCheck[0][i] == player &&
          boardToCheck[1][i] == player &&
          boardToCheck[2][i] == player) {
        if (testBoard == null) {
          winningLine = [i, i + 3, i + 6];
        }
        return true;
      }
    }

    // Check diagonals
    if (boardToCheck[0][0] == player &&
        boardToCheck[1][1] == player &&
        boardToCheck[2][2] == player) {
      if (testBoard == null) {
        winningLine = [0, 4, 8];
      }
      return true;
    }
    if (boardToCheck[0][2] == player &&
        boardToCheck[1][1] == player &&
        boardToCheck[2][0] == player) {
      if (testBoard == null) {
        winningLine = [2, 4, 6];
      }
      return true;
    }

    return false;
  }

  bool isBoardFull([List<List<String>>? testBoard]) {
    final boardToCheck = testBoard ?? board;
    for (var row in boardToCheck) {
      for (var cell in row) {
        if (cell.isEmpty) return false;
      }
    }
    return true;
  }

  void makeComputerMove() {
    if (gameEnded || !mounted) return;

    // Create a copy of the board for testing
    List<List<String>> testBoard =
        List.generate(3, (i) => List.generate(3, (j) => board[i][j]));

    // Try to win
    int? move = findWinningMove('X', testBoard);
    
    // Block player's winning move
    move ??= findWinningMove('O', testBoard);
    
    // Take center or make strategic move
    move ??= board[1][1].isEmpty ? 4 : findStrategicMove();

    // Safety check for move validity
    if (move == null || move < 0 || move >= 9) {
      move = findFirstEmptyCell();
    }

    if (mounted) {
      final moveIndex = move; // Capture the non-null value
      int row = moveIndex ~/ 3;
      int col = moveIndex % 3;

      setState(() {
        board[row][col] = 'X';
        moveControllers[moveIndex].forward();
      });

      checkGameEnd();
      if (!gameEnded) {
        isPlayerTurn = true;
      }
    }
  }

  int? findWinningMove(String player, List<List<String>> testBoard) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (testBoard[i][j].isEmpty) {
          testBoard[i][j] = player;
          if (checkWin(player, testBoard)) {
            testBoard[i][j] = '';
            return i * 3 + j;
          }
          testBoard[i][j] = '';
        }
      }
    }
    return null;
  }

  int? findStrategicMove() {
    List<int> availableMoves = [];
    List<int> cornerMoves = [];
    List<int> edgeMoves = [];

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j].isEmpty) {
          int move = i * 3 + j;
          availableMoves.add(move);

          if ((i == 0 || i == 2) && (j == 0 || j == 2)) {
            cornerMoves.add(move);
          } else if (i == 1 || j == 1) {
            edgeMoves.add(move);
          }
        }
      }
    }

    if (availableMoves.isEmpty) {
      return null;
    }

    // Prioritize moves: corners (70%), edges (20%), random (10%)
    double moveType = Random().nextDouble();
    if (moveType < 0.7 && cornerMoves.isNotEmpty) {
      return cornerMoves[Random().nextInt(cornerMoves.length)];
    } else if (moveType < 0.9 && edgeMoves.isNotEmpty) {
      return edgeMoves[Random().nextInt(edgeMoves.length)];
    }

    return availableMoves[Random().nextInt(availableMoves.length)];
  }

  int findFirstEmptyCell() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j].isEmpty) {
          return i * 3 + j;
        }
      }
    }
    return 0; // Fallback, should never happen in normal gameplay
  }

  void checkGameEnd() {
    if (!mounted) return;

    if (checkWin('O')) {
      gameEnded = true;
      winner = 'Player';
      playerWins++;
      lineController?.forward();
      widget.onGameComplete(true);
    } else if (checkWin('X')) {
      gameEnded = true;
      winner = 'Computer';
      computerWins++;
      lineController?.forward();
      widget.onGameComplete(true);
    } else if (isBoardFull()) {
      gameEnded = true;
      winner = 'Draw';
      draws++;
      widget.onGameComplete(true);
    }
  }

  void onCellTap(int row, int col) {
    if (!isPlayerTurn || board[row][col].isNotEmpty || gameEnded || !mounted) {
      return;
    }

    setState(() {
      board[row][col] = 'O';
      moveControllers[row * 3 + col].forward();
    });

    checkGameEnd();
    if (!gameEnded && mounted) {
      isPlayerTurn = false;
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && !gameEnded) {
          makeComputerMove();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in moveControllers) {
      controller.dispose();
    }
    lineController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (winner.isNotEmpty) ...[
          Text(
            winner == 'Draw' ? "It's a Draw!" : '$winner Wins!',
            style: TextStyle(
              color: winner == 'Player'
                  ? Colors.blue
                  : winner == 'Computer'
                      ? Colors.orange
                      : Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(initializeGame),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
            child: const Text(
              'Play Again',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: GridPainter(),
                ),
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 9,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final row = index ~/ 3;
                    final col = index % 3;
                    return GestureDetector(
                      onTap: () => onCellTap(row, col),
                      child: AnimatedBuilder(
                        animation: moveControllers[index],
                        builder: (context, child) {
                          return CustomPaint(
                            painter: MovePainter(
                              type: board[row][col],
                              progress: moveControllers[index].value,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                if (winningLine != null)
                  AnimatedBuilder(
                    animation: lineController!,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: WinLinePainter(
                          winningLine!,
                          lineController!.value,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Wins: $playerWins  Draws: $draws  Losses: $computerWins',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}