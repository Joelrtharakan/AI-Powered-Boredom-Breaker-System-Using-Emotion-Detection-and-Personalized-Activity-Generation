import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:async';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int rows = 20;
  static const int columns = 20;
  static const int squareSize = 20;
  final Random _random = Random();

  List<int> _snake = [45, 46, 47];
  int _food = 100;
  String _direction = 'up';
  bool _isPlaying = false;
  Timer? _timer;

  void _startGame() {
    setState(() {
      _snake = [45, 46, 47];
      _direction = 'up';
      _isPlaying = true;
      _generateFood();
      _timer = Timer.periodic(const Duration(milliseconds: 300), (Timer timer) {
        _updateSnake();
      });
    });
  }

  void _generateFood() {
    _food = _random.nextInt(rows * columns);
    if (_snake.contains(_food)) {
      _generateFood();
    }
  }

  void _updateSnake() {
    if (!_isPlaying) return;

    setState(() {
      final int head = _snake.last;
      int nextHead;

      switch (_direction) {
        case 'up':
          nextHead = head - columns;
          if (nextHead < 0) nextHead += rows * columns;
          break;
        case 'down':
          nextHead = head + columns;
          if (nextHead >= rows * columns) nextHead -= rows * columns;
          break;
        case 'left':
          if (head % columns == 0) {
            nextHead = head + columns - 1;
          } else {
            nextHead = head - 1;
          }
          break;
        case 'right':
          if ((head + 1) % columns == 0) {
            nextHead = head - columns + 1;
          } else {
            nextHead = head + 1;
          }
          break;
        default:
          nextHead = head;
      }

      if (_snake.contains(nextHead)) {
        _gameOver();
        return;
      }

      _snake.add(nextHead);

      if (nextHead == _food) {
        _generateFood();
      } else {
        _snake.removeAt(0);
      }
    });
  }

  void _gameOver() {
    setState(() {
      _isPlaying = false;
      _timer?.cancel();
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Game Over',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          content: Text(
            'Score: ${_snake.length - 3}',
            style: GoogleFonts.inter(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Play Again',
                style: GoogleFonts.outfit(color: Colors.greenAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
              },
            ),
            TextButton(
              child: Text(
                'Exit',
                style: GoogleFonts.outfit(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Snake", style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0 && _direction != 'up') {
                  _direction = 'down';
                } else if (details.delta.dy < 0 && _direction != 'down') {
                  _direction = 'up';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 && _direction != 'left') {
                  _direction = 'right';
                } else if (details.delta.dx < 0 && _direction != 'right') {
                  _direction = 'left';
                }
              },
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rows * columns,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    if (_snake.contains(index)) {
                      return Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: _snake.last == index
                              ? Colors.green[400]
                              : Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    } else if (index == _food) {
                      return Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.all(1),
                        color: Colors.grey[900],
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Score: ${_snake.length - 3}",
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 20),
                ),
                if (!_isPlaying)
                  ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                    ),
                    child: Text(
                      "Start",
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
