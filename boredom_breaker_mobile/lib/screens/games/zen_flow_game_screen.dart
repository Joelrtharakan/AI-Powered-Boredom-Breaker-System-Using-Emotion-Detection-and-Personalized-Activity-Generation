import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class ZenFlowGameScreen extends StatefulWidget {
  const ZenFlowGameScreen({super.key});

  @override
  State<ZenFlowGameScreen> createState() => _ZenFlowGameScreenState();
}

class _ZenFlowGameScreenState extends State<ZenFlowGameScreen> {
  // Game Configuration
  final int rows = 5;
  final int cols = 5;

  // Level Data: Each level maps a grid index to a color ID (1, 2, 3...)
  // 0 means empty.
  final List<Map<int, int>> levels = [
    // Level 1 (Simple)
    {
      0: 1, 4: 1, // Red pair
      10: 2, 14: 2, // Blue pair
      20: 3, 24: 3, // Green pair
    },
    // Level 2 (Cross)
    {2: 1, 22: 1, 10: 2, 14: 2, 0: 3, 24: 3, 4: 4, 20: 4},
    // Level 3 (Full)
    {0: 1, 24: 1, 1: 2, 23: 2, 2: 3, 22: 3, 3: 4, 21: 4, 4: 5, 20: 5},
  ];

  int currentLevelIndex = 0;

  // State
  // Identify which pipe color occupies a cell. 0 = empty.
  late List<int> gridState;
  // Track the current active paths for drawing
  // Map<ColorID, List<GridIndex>>
  Map<int, List<int>> paths = {};

  // Interaction
  int? currentDragColor;

  @override
  void initState() {
    super.initState();
    _loadLevel(0);
  }

  void _loadLevel(int index) {
    setState(() {
      currentLevelIndex = index;
      gridState = List.filled(rows * cols, 0);
      paths = {};

      // Initialize dots
      final levelData = levels[index % levels.length];
      levelData.forEach((idx, colorId) {
        gridState[idx] = colorId;
        // Start a path for each dot containing just itself
        paths[colorId] = [];
      });
    });
  }

  void _resetLevel() {
    _loadLevel(currentLevelIndex);
  }

  void _nextLevel() {
    _loadLevel((currentLevelIndex + 1) % levels.length);
  }

  // --- Interaction Logic ---

  void _onPanStart(DragStartDetails details, BoxConstraints constraints) {
    final index = _getIndexFromOffset(details.localPosition, constraints);
    if (index == -1) return;

    final dotColor = levels[currentLevelIndex % levels.length][index];

    // Case 1: Started on a Source Dot
    if (dotColor != null) {
      setState(() {
        currentDragColor = dotColor;
        // visual feedback
        paths[dotColor] = [index];
      });
    }
    // Case 2: Started on an existing path (optional, maybe later)
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (currentDragColor == null) return;

    final index = _getIndexFromOffset(details.localPosition, constraints);
    if (index == -1) return;

    final currentPath = paths[currentDragColor!]!;

    // If we moved to a new cell
    if (currentPath.isEmpty || currentPath.last != index) {
      // 1. Check if valid move (adjacent)
      if (currentPath.isNotEmpty) {
        if (!_isAdjacent(currentPath.last, index)) return;
      }

      // 2. Check collisions
      // If we hit a Source Dot of a DIFFERENT color, stop.
      final dotColor = levels[currentLevelIndex % levels.length][index];
      if (dotColor != null && dotColor != currentDragColor) return;

      // If we hit a path of a DIFFERENT color, cut that path (or stop? Flow usually stops or overwrites).
      // Let's go with: overlap overwrites other paths (except source dots).

      setState(() {
        // Handle backtracking: if we move back to the previous cell in our own path
        if (currentPath.length > 1 &&
            currentPath[currentPath.length - 2] == index) {
          currentPath.removeLast();
        }
        // Validation: Don't allow crossing own path (loop) unless backtracking
        else if (!currentPath.contains(index)) {
          // Check if we are overwriting another path
          _clearCellOwners(index, currentDragColor!);

          currentPath.add(index);
        }
      });

      if (_checkWinCondition()) {
        // Win!
        _showWinDialog();
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      currentDragColor = null;
    });
  }

  bool _isAdjacent(int a, int b) {
    final int r1 = a ~/ cols;
    final int c1 = a % cols;
    final int r2 = b ~/ cols;
    final int c2 = b % cols;
    return (r1 - r2).abs() + (c1 - c2).abs() == 1;
  }

  int _getIndexFromOffset(Offset offset, BoxConstraints constraints) {
    final cellSize = constraints.maxWidth / cols;
    final row = (offset.dy / cellSize).floor();
    final col = (offset.dx / cellSize).floor();

    if (row < 0 || row >= rows || col < 0 || col >= cols) return -1;
    return row * cols + col;
  }

  void _clearCellOwners(int index, int excludeColor) {
    // If any other path owns this cell, cut that path at this point
    paths.forEach((colorId, path) {
      if (colorId == excludeColor) return;
      if (path.contains(index)) {
        // Truncate this path
        final cutIdx = path.indexOf(index);
        // Keep path only up to before this index
        paths[colorId] = path.sublist(0, cutIdx);
      }
    });
  }

  bool _checkWinCondition() {
    // 1. All Colors must have a complete path connecting their two dots
    final levelData = levels[currentLevelIndex % levels.length];

    // Get all unique colors
    final colors = levelData.values.toSet();

    for (final color in colors) {
      final path = paths[color];
      if (path == null || path.isEmpty) return false;

      // Does path connect two distinct dots of this color?
      // Find the two dot indices for this color
      final dots = levelData.entries
          .where((e) => e.value == color)
          .map((e) => e.key)
          .toList();
      if (dots.length != 2) return false;

      bool startConnected = path.contains(dots[0]);
      bool endConnected = path.contains(dots[1]);

      if (!startConnected || !endConnected) return false;
    }

    // 2. All cells must be filled (Optional for "Flow", mandatory for perfect win, but let's stick to connection first)
    // Let's just require connection for now to be friendly.
    return true;
  }

  Color _getColor(int id) {
    switch (id) {
      case 1:
        return const Color(0xFFFF5252); // Red
      case 2:
        return const Color(0xFF448AFF); // Blue
      case 3:
        return const Color(0xFF69F0AE); // Green
      case 4:
        return const Color(0xFFFFD740); // Yellow
      case 5:
        return const Color(0xFFE040FB); // Purple
      default:
        return Colors.grey;
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF18181B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "Flow Complete!",
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.greenAccent,
              size: 64,
            ).animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text(
              "You found your flow.",
              style: GoogleFonts.inter(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextLevel();
            },
            child: Text(
              "Next Level",
              style: GoogleFonts.outfit(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
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
        title: Text(
          "Zen Flow",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetLevel,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Connect the matching dots",
                style: GoogleFonts.inter(
                  color: Colors.white38,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Level ${currentLevelIndex + 1}",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn().slideY(begin: -0.5),

              const SizedBox(height: 48),

              // The Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final gridSize = min(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return SizedBox(
                    width: gridSize,
                    height: gridSize,
                    child: GestureDetector(
                      onPanStart: (d) => _onPanStart(
                        d,
                        BoxConstraints(maxWidth: gridSize, maxHeight: gridSize),
                      ),
                      onPanUpdate: (d) => _onPanUpdate(
                        d,
                        BoxConstraints(maxWidth: gridSize, maxHeight: gridSize),
                      ),
                      onPanEnd: _onPanEnd,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF18181B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Stack(
                          children: [
                            // Grid Lines (Optional)

                            // Paths (Pipes)
                            ...paths.entries.map((e) {
                              return CustomPaint(
                                size: Size(gridSize, gridSize),
                                painter: PathPainter(
                                  pathIndices: e.value,
                                  cols: cols,
                                  color: _getColor(e.key),
                                ),
                              );
                            }),

                            // Dots
                            ...levels[currentLevelIndex % levels.length].entries
                                .map((e) {
                                  return Positioned(
                                    left: (e.key % cols) * (gridSize / cols),
                                    top: (e.key ~/ cols) * (gridSize / cols),
                                    width: gridSize / cols,
                                    height: gridSize / cols,
                                    child: Center(
                                      child:
                                          Container(
                                                width: (gridSize / cols) * 0.6,
                                                height: (gridSize / cols) * 0.6,
                                                decoration: BoxDecoration(
                                                  color: _getColor(e.value),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: _getColor(
                                                        e.value,
                                                      ).withOpacity(0.4),
                                                      blurRadius: 10,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                              )
                                              .animate(
                                                onPlay: (c) =>
                                                    c.repeat(reverse: true),
                                              )
                                              .scale(
                                                begin: const Offset(0.9, 0.9),
                                                end: const Offset(1.1, 1.1),
                                                duration: 1.seconds,
                                              ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  final List<int> pathIndices;
  final int cols;
  final Color color;

  PathPainter({
    required this.pathIndices,
    required this.cols,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pathIndices.length < 2) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = (size.width / cols) * 0.3;

    final path = Path();
    final cellSize = size.width / cols;

    // Get center of first cell
    final startC = pathIndices[0] % cols;
    final startR = pathIndices[0] ~/ cols;

    path.moveTo(
      (startC * cellSize) + (cellSize / 2),
      (startR * cellSize) + (cellSize / 2),
    );

    for (int i = 1; i < pathIndices.length; i++) {
      final c = pathIndices[i] % cols;
      final r = pathIndices[i] ~/ cols;
      path.lineTo(
        (c * cellSize) + (cellSize / 2),
        (r * cellSize) + (cellSize / 2),
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return oldDelegate.pathIndices != pathIndices;
  }
}
