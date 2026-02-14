import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import '../../theme/app_theme.dart';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  List<List<int>> grid = List.generate(4, (_) => List.filled(4, 0));
  int score = 0;
  int highScore = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      grid = List.generate(4, (_) => List.filled(4, 0));
      if (score > highScore) {
        highScore = score;
      }
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
      setState(() {
        grid[cell.x][cell.y] = Random().nextDouble() < 0.9 ? 2 : 4;
      });
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
          if (score > highScore) {
            highScore = score;
          }
          _showGameOverDialog();
        }
      }
    });
  }

  // --- Movement Logic ---

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
      for (int r = 0; r < 4; r++) {
        col.add(grid[r][c]);
      }

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
      for (int r = 0; r < 4; r++) {
        col.add(grid[r][c]);
      }

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "Game Over!",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Final Score",
              style: GoogleFonts.inter(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              "$score",
              style: GoogleFonts.outfit(
                color: AppColors.primary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Play Again",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
            ],
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
        title: Text(
          "2048",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetGame,
            tooltip: 'New Game',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            children: [
              // Score Board
              Row(
                children: [
                  _buildScoreCard("Score", score),
                  const SizedBox(width: 16),
                  _buildScoreCard("Best", highScore),
                ],
              ).animate().fadeIn().slideY(begin: -0.2),

              const Spacer(),

              // Game Grid
              Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF18181B),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity! < -200) {
                          _handleSwipe(SwipeDirection.up);
                        } else if (details.primaryVelocity! > 200) {
                          _handleSwipe(SwipeDirection.down);
                        }
                      },
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! < -200) {
                          _handleSwipe(SwipeDirection.left);
                        } else if (details.primaryVelocity! > 200) {
                          _handleSwipe(SwipeDirection.right);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors
                            .transparent, // Important for gesture detection
                        child: Column(
                          children: List.generate(4, (r) {
                            return Expanded(
                              child: Row(
                                children: List.generate(4, (c) {
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: _buildTile(grid[r][c]),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

              const Spacer(),

              Text(
                "Swipe to move tiles",
                style: GoogleFonts.inter(
                  color: Colors.white30,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(delay: 1.seconds),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(String label, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
                  "$value",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
                .animate(
                  key: ValueKey(value),
                  onPlay: (c) => c.forward(from: 0),
                )
                .scale(duration: 200.ms, curve: Curves.easeOutBack),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(int value) {
    final color = _getTileColor(value);
    final textColor = value > 4 ? Colors.white : const Color(0xFF1F1F1F);

    return AnimatedContainer(
      duration: 200.ms,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: value > 0
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: value > 0
            ? Text(
                "$value",
                style: GoogleFonts.outfit(
                  fontSize: value > 1000 ? 20 : 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack)
            : null,
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 0:
        return Colors.white.withOpacity(0.05);
      case 2:
        return const Color(0xFFEEE4DA);
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
      default:
        return const Color(0xFF3C3A32);
    }
  }
}

enum SwipeDirection { up, down, left, right }
