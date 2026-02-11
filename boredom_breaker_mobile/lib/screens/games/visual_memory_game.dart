import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualMemoryGame extends StatefulWidget {
  const VisualMemoryGame({super.key});

  @override
  State<VisualMemoryGame> createState() => _VisualMemoryGameState();
}

class _VisualMemoryGameState extends State<VisualMemoryGame> {
  int _level = 1;
  int _lives = 3;
  List<int> _targetTiles = [];
  List<int> _selectedTiles = [];
  bool _showingPattern = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startLevel());
  }

  void _startLevel() {
    if (!mounted) return;
    setState(() {
      _selectedTiles = [];
      _targetTiles = [];
      _showingPattern = true;
      _isPlaying = true;

      // Simple 4x4 grid (16 tiles)
      int numTiles = _level + 2;
      // Clamp max tiles to say 12 to be playable
      if (numTiles > 12) numTiles = 12;

      List<int> available = List.generate(16, (i) => i);
      available.shuffle();
      _targetTiles = available.take(numTiles).toList();
    });

    // Show pattern for longer as level increases? Or fix at 2s?
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showingPattern = false;
        });
      }
    });
  }

  void _handleTap(int index) {
    if (_showingPattern || !_isPlaying) return;
    if (_selectedTiles.contains(index)) return; // Already tapped

    setState(() {
      _selectedTiles.add(index);

      if (!_targetTiles.contains(index)) {
        // WRONG TILE
        _lives--;

        if (_lives <= 0) {
          _gameOver();
        } else {
          // Flash Red or something?
          // Reset selection for retry logic?
          // Ideally in visual memory, one mistake usually ends level or you lose a life and continue.
          // Let's implement immediate feedback: Red tile
          // If wrong tile tapped, user loses 1 life, game pauses 1s then shows pattern again?
          _tryAgain();
        }
      } else {
        // CORRECT TILE
        // Check if level complete (all targets found)
        int correctCount = _selectedTiles
            .where((t) => _targetTiles.contains(t))
            .length;
        if (correctCount == _targetTiles.length) {
          // Level Complete
          _level++;
          Future.delayed(const Duration(milliseconds: 800), _startLevel);
        }
      }
    });
  }

  void _tryAgain() {
    _showingPattern = true; // Block input
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Wrong! $_lives lives left."),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.redAccent,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _selectedTiles = []; // Clear wrong selection
          _showingPattern =
              false; // Allow input again (maybe show pattern again?)
          // Usually games show pattern again if you fail. so lets do that.
          _showingPattern = true;
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) setState(() => _showingPattern = false);
          });
        });
      }
    });
  }

  void _gameOver() {
    setState(() => _isPlaying = false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF18181B),
        title: Text(
          "Game Over",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "You reached Level $_level",
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _level = 1;
                _lives = 3;
                _startLevel();
              });
            },
            child: Text(
              "Restart",
              style: GoogleFonts.outfit(color: Colors.blueAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Close Screen
            },
            child: Text(
              "Close",
              style: GoogleFonts.outfit(color: Colors.white54),
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
          "Visual Memory",
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    "$_lives",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Lvl $_level",
                    style: GoogleFonts.outfit(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
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
                _showingPattern ? "Memorize Pattern..." : "Tap the Tiles!",
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _showingPattern ? Colors.yellowAccent : Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    bool isTarget = _targetTiles.contains(index);
                    bool isSelected = _selectedTiles.contains(index);

                    Color color = Colors.white.withValues(alpha: 0.1);

                    if (_showingPattern) {
                      if (isTarget) color = Colors.white;
                    } else {
                      if (isSelected) {
                        if (isTarget) {
                          color = Colors.blueAccent; // Correct
                        } else {
                          color = Colors.redAccent; // Wrong
                        }
                      }
                    }

                    return GestureDetector(
                      onTap: () => _handleTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (color != Colors.white.withValues(alpha: 0.1))
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
