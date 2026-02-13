import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

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

      int numTiles = _level + 2;
      if (numTiles > 12) numTiles = 12;

      List<int> available = List.generate(16, (i) => i);
      available.shuffle();
      _targetTiles = available.take(numTiles).toList();
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showingPattern = false);
    });
  }

  void _handleTap(int index) {
    if (_showingPattern || !_isPlaying) return;
    if (_selectedTiles.contains(index)) return;

    setState(() {
      _selectedTiles.add(index);
      if (!_targetTiles.contains(index)) {
        _lives--;
        if (_lives <= 0) {
          _gameOver();
        } else {
          _tryAgain();
        }
      } else {
        int correctCount = _selectedTiles
            .where((t) => _targetTiles.contains(t))
            .length;
        if (correctCount == _targetTiles.length) {
          _level++;
          Future.delayed(const Duration(milliseconds: 800), _startLevel);
        }
      }
    });
  }

  void _tryAgain() {
    _showingPattern = true;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _selectedTiles = [];
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
              style: GoogleFonts.outfit(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Visual Memory",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _buildStat(Icons.favorite_rounded, "$_lives", Colors.redAccent),
          _buildStat(Icons.bolt_rounded, "Lvl $_level", Colors.amberAccent),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _showingPattern ? "Memorize Pattern..." : "Tap the Tiles!",
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _showingPattern ? Colors.amberAccent : Colors.white,
              ),
            ).animate(target: _showingPattern ? 1 : 0).shimmer(),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    bool isTarget = _targetTiles.contains(index);
                    bool isSelected = _selectedTiles.contains(index);
                    Color color = Colors.white.withValues(alpha: 0.05);
                    if (_showingPattern && isTarget) {
                      color = Colors.white;
                    } else if (isSelected) {
                      color = isTarget ? AppColors.primary : Colors.redAccent;
                    }

                    return GestureDetector(
                      onTap: () => _handleTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            if (color != Colors.white.withValues(alpha: 0.05))
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                      ),
                    ).animate().scale(delay: (index * 20).ms);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
