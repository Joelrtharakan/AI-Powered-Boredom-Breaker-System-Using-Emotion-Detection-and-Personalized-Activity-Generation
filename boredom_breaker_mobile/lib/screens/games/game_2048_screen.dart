import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  List<List<int>> grid = List.generate(4, (_) => List.filled(4, 0));
  int score = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      grid = List.generate(4, (_) => List.filled(4, 0));
      score = 0;
      _isGameOver = false;
      _addRandomTile();
      _addRandomTile();
    });
  }

  void _addRandomTile() {
    List<Point<int>> emptyCells = [];
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        if (grid[r][c] == 0) {
          emptyCells.add(Point(r, c));
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      Point<int> cell = emptyCells[Random().nextInt(emptyCells.length)];
      grid[cell.x][cell.y] = Random().nextDouble() < 0.9 ? 2 : 4;
    }
  }

  void _handleSwipe(SwipeDirection direction) {
    if (_isGameOver) return;

    setState(() {
      bool moved = false;
      if (direction == SwipeDirection.left) {
        moved = _moveLeft();
      } else if (direction == SwipeDirection.right) {
        moved = _moveRight();
      } else if (direction == SwipeDirection.up) {
        moved = _moveUp();
      } else if (direction == SwipeDirection.down) {
        moved = _moveDown();
      }

      if (moved) {
        _addRandomTile();
        if (_checkGameOver()) {
          _isGameOver = true;
          _showGameOverDialog();
        }
      }
    });
  }

  bool _moveLeft() {
    bool moved = false;
    for (int r = 0; r < 4; r++) {
      List<int> newRow = _mergeRow(grid[r]);
      if (newRow.toString() != grid[r].toString()) {
        grid[r] = newRow;
        moved = true;
      }
    }
    return moved;
  }

  bool _moveRight() {
    bool moved = false;
    for (int r = 0; r < 4; r++) {
      List<int> reversedRow = List.from(grid[r].reversed);
      List<int> newRow = _mergeRow(reversedRow);
      newRow = List.from(newRow.reversed);
      if (newRow.toString() != grid[r].toString()) {
        grid[r] = newRow;
        moved = true;
      }
    }
    return moved;
  }

  bool _moveUp() {
    bool moved = false;
    for (int c = 0; c < 4; c++) {
      List<int> col = [];
      for (int r = 0; r < 4; r++) col.add(grid[r][c]);

      List<int> newCol = _mergeRow(col);

      for (int r = 0; r < 4; r++) {
        if (grid[r][c] != newCol[r]) {
          grid[r][c] = newCol[r];
          moved = true;
        }
      }
    }
    return moved;
  }

  bool _moveDown() {
    bool moved = false;
    for (int c = 0; c < 4; c++) {
      List<int> col = [];
      for (int r = 0; r < 4; r++) col.add(grid[r][c]);

      List<int> reversedCol = List.from(col.reversed);
      List<int> newCol = _mergeRow(reversedCol);
      newCol = List.from(newCol.reversed);

      for (int r = 0; r < 4; r++) {
        if (grid[r][c] != newCol[r]) {
          grid[r][c] = newCol[r];
          moved = true;
        }
      }
    }
    return moved;
  }

  List<int> _mergeRow(List<int> row) {
    List<int> nonZero = row.where((e) => e != 0).toList();
    List<int> newRow = [];

    int i = 0;
    while (i < nonZero.length) {
      if (i + 1 < nonZero.length && nonZero[i] == nonZero[i + 1]) {
        int val = nonZero[i] * 2;
        newRow.add(val);
        score += val;
        i += 2;
      } else {
        newRow.add(nonZero[i]);
        i++;
      }
    }

    while (newRow.length < 4) {
      newRow.add(0);
    }
    return newRow;
  }

  bool _checkGameOver() {
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        if (grid[r][c] == 0) return false;
        if (c < 3 && grid[r][c] == grid[r][c + 1]) return false;
        if (r < 3 && grid[r][c] == grid[r + 1][c]) return false;
      }
    }
    return true;
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF18181B),
        title: Text(
          "Game Over",
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Text(
          "Score: $score",
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: Text(
              "Play Again",
              style: GoogleFonts.outfit(color: Colors.blueAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              "Exit",
              style: GoogleFonts.outfit(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        title: Text("2048", style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                "Score: $score",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _handleSwipe(SwipeDirection.up);
          } else if (details.primaryVelocity! > 0) {
            _handleSwipe(SwipeDirection.down);
          }
        },
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _handleSwipe(SwipeDirection.left);
          } else if (details.primaryVelocity! > 0) {
            _handleSwipe(SwipeDirection.right);
          }
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF18181B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                4,
                (r) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(4, (c) => _buildTile(grid[r][c])),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(int value) {
    return Container(
      width: 70,
      height: 70,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getTileColor(value),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          value == 0 ? "" : "$value",
          style: GoogleFonts.outfit(
            fontSize: value > 1000 ? 18 : 24,
            fontWeight: FontWeight.bold,
            color: value > 4 ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return Colors.white;
      case 4:
        return const Color(0xFFEDE0C8);
      case 8:
        return const Color(0xFFF2B179);
      case 16:
        return const Color(0xFFF59563);
      case 32:
        return const Color(0xFFF67C5F);
      case 64:
        return const Color(0xFFF65E3B);
      case 128:
        return const Color(0xFFEDCF72);
      case 256:
        return const Color(0xFFEDCC61);
      case 512:
        return const Color(0xFFEDC850);
      case 1024:
        return const Color(0xFFEDC53F);
      case 2048:
        return const Color(0xFFEDC22E);
      case 0:
        return Colors.white.withOpacity(0.1);
      default:
        return Colors.black;
    }
  }
}

enum SwipeDirection { up, down, left, right }
