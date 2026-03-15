import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/games_api.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen>
    with TickerProviderStateMixin {
  static const int rows = 30;
  static const int columns = 20;
  final Random _random = Random();

  List<int> _snake = [];
  int _food = -1;
  String _direction = 'up';
  bool _isPlaying = false;
  bool _isGameOver = false;
  Timer? _gameLoop;
  int _score = 0;

  // Animation controllers for effects
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _resetGame();
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      int center = (rows * columns / 2).floor();
      _snake = [
        center, // Head
        center + columns, // Body
        center + columns * 2, // Tail
      ];
      _direction = 'up';
      _isPlaying = false;
      _isGameOver = false;
      _score = 0;
      _generateFood();
    });
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
    });
    _gameLoop = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      _updateSnake();
    });
  }

  void _generateFood() {
    int newFood;
    do {
      newFood = _random.nextInt(rows * columns);
    } while (_snake.contains(newFood));
    setState(() {
      _food = newFood;
    });
  }

  void _updateSnake() {
    if (!_isPlaying) return;

    setState(() {
      final int head = _snake.first;
      int nextHead;

      switch (_direction) {
        case 'up':
          if (head < columns) {
            nextHead = head + (rows - 1) * columns; // Wrap bottom
          } else {
            nextHead = head - columns;
          }
          break;
        case 'down':
          if (head >= (rows - 1) * columns) {
            nextHead = head % columns; // Wrap top
          } else {
            nextHead = head + columns;
          }
          break;
        case 'left':
          if (head % columns == 0) {
            nextHead = head + columns - 1; // Wrap right
          } else {
            nextHead = head - 1;
          }
          break;
        case 'right':
          if ((head + 1) % columns == 0) {
            nextHead = head - columns + 1; // Wrap left
          } else {
            nextHead = head + 1;
          }
          break;
        default:
          nextHead = head;
      }

      // Check for collision with self
      // We check against snake body, but NOT the tail because the tail moves forward
      if (_snake.take(_snake.length - 1).contains(nextHead)) {
        _handleGameOver();
        return;
      }

      _snake.insert(0, nextHead);

      if (nextHead == _food) {
        _score += 10;
        _generateFood();
        // Speed up slightly could go here
      } else {
        _snake.removeLast();
      }
    });
  }

  void _handleGameOver() {
    _gameLoop?.cancel();
    GamesApi.submitScore('snake', _score);
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });
  }

  void _handleInput(String newDir) {
    if ((newDir == 'up' && _direction != 'down') ||
        (newDir == 'down' && _direction != 'up') ||
        (newDir == 'left' && _direction != 'right') ||
        (newDir == 'right' && _direction != 'left')) {
      _direction = newDir;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Cyberpunk Grid Background
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(
                rows: rows,
                columns: columns,
                color: const Color(0xFFCBD5E1),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header Score Panel
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF1E293B,
                              ).withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF1E293B),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF1E293B,
                              ).withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "$_score",
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ).animate(key: ValueKey(_score)).scale(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Game Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: columns / rows,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF1E293B,
                                ).withValues(alpha: 0.05),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: GestureDetector(
                              onVerticalDragUpdate: (details) {
                                if (details.delta.dy > 0) {
                                  _handleInput('down');
                                } else if (details.delta.dy < 0) {
                                  _handleInput('up');
                                }
                              },
                              onHorizontalDragUpdate: (details) {
                                if (details.delta.dx > 0) {
                                  _handleInput('right');
                                } else if (details.delta.dx < 0) {
                                  _handleInput('left');
                                }
                              },
                              child: AnimatedBuilder(
                                key: const ValueKey("GameBoard"),
                                animation: _pulseController,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: SnakePainter(
                                      snake: _snake,
                                      food: _food,
                                      rows: rows,
                                      columns: columns,
                                      pulse: _pulseController.value,
                                    ),
                                    size: Size.infinite,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Footer / Instructions
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Text(
                    "SWIPE TO CONTROL",
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 4,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Start / Game Over Overlay
          if (!_isPlaying)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isGameOver) ...[
                          Text(
                            "GAME OVER",
                            style: GoogleFonts.outfit(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.redAccent,
                              shadows: [
                                BoxShadow(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ).animate().fadeIn().scale(),
                          const SizedBox(height: 16),
                          Text(
                            "Final Score: $_score",
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        if (!_isGameOver)
                          Column(
                            children: [
                              Icon(
                                    Icons.gesture_rounded,
                                    color: const Color(0xFF10B981),
                                    size: 64,
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .scale(
                                    begin: const Offset(1, 1),
                                    end: const Offset(1.1, 1.1),
                                  ),
                              const SizedBox(height: 24),
                              Text(
                                "SNAKE EVOLUTION",
                                style: GoogleFonts.outfit(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),

                        ElevatedButton(
                          onPressed: _isPlaying
                              ? null
                              : (_isGameOver ? _resetGame : _startGame),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 10,
                            shadowColor: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.3),
                          ),
                          child: Text(
                            _isGameOver ? "TRY AGAIN" : "START GAME",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: Text(
                            "EXIT GAME",
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF64748B),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SnakePainter extends CustomPainter {
  final List<int> snake;
  final int food;
  final int rows;
  final int columns;
  final double pulse;

  SnakePainter({
    required this.snake,
    required this.food,
    required this.rows,
    required this.columns,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cellWidth = size.width / columns;
    final double cellHeight = size.height / rows;

    final Paint snakePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    final Paint glowPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Draw Snake
    for (int i = 0; i < snake.length; i++) {
      int index = snake[i];
      int r = (index / columns).floor();
      int c = index % columns;

      Rect rect = Rect.fromLTWH(
        c * cellWidth + 1,
        r * cellHeight + 1,
        cellWidth - 2,
        cellHeight - 2,
      );

      // Draw glow for head
      if (i == 0) {
        canvas.drawRect(rect.inflate(4), glowPaint);
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        snakePaint,
      );
    }

    // Draw Food
    int foodR = (food / columns).floor();
    int foodC = food % columns;

    Offset foodCenter = Offset(
      (foodC * cellWidth) + (cellWidth / 2),
      (foodR * cellHeight) + (cellHeight / 2),
    );

    Paint foodPaint = Paint()
      ..color = const Color(0xFFFF4081)
      ..style = PaintingStyle.fill
      ..shader =
          RadialGradient(
            colors: [const Color(0xFFFF80AB), const Color(0xFFFF4081)],
          ).createShader(
            Rect.fromCircle(center: foodCenter, radius: cellWidth / 2),
          );

    Paint foodGlow = Paint()
      ..color = const Color(
        0xFFFF4081,
      ).withValues(alpha: 0.5 * (0.8 + (pulse * 0.2)))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(foodCenter, (cellWidth / 2) - 2, foodGlow);
    canvas.drawCircle(foodCenter, (cellWidth / 2) - 4, foodPaint);
  }

  @override
  bool shouldRepaint(SnakePainter oldDelegate) => true;
}

class GridPainter extends CustomPainter {
  final int rows;
  final int columns;
  final Color color;

  GridPainter({required this.rows, required this.columns, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    final double cellWidth = size.width / columns;
    final double cellHeight = size.height / rows;

    for (int i = 0; i <= columns; i++) {
      double x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (int i = 0; i <= rows; i++) {
      double y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
