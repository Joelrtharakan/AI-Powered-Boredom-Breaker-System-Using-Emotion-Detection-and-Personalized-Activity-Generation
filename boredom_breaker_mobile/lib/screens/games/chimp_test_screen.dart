import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ChimpTestScreen extends StatefulWidget {
  const ChimpTestScreen({super.key});

  @override
  State<ChimpTestScreen> createState() => _ChimpTestScreenState();
}

class _ChimpTestScreenState extends State<ChimpTestScreen> {
  int _level = 4;
  List<int?> _grid = List.filled(40, null);
  int _nextExpected = 1;
  bool _hideNumbers = false;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  void _startLevel() {
    setState(() {
      _grid = List.filled(40, null);
      _nextExpected = 1;
      _hideNumbers = false;
      _isGameOver = false;

      List<int> positions = List.generate(40, (i) => i);
      positions.shuffle();

      for (int i = 1; i <= _level; i++) {
        _grid[positions[i - 1]] = i;
      }
    });
  }

  void _handleTap(int index) {
    if (_isGameOver || _grid[index] == null) return;

    if (_grid[index] == _nextExpected) {
      setState(() {
        if (_nextExpected == 1) _hideNumbers = true;

        _grid[index] = null; // Correct, remove tile
        _nextExpected++;

        if (_nextExpected > _level) {
          // Level Clear
          _level++;
          Future.delayed(const Duration(milliseconds: 500), _startLevel);
        }
      });
    } else {
      // Wrong Number
      setState(() {
        _isGameOver = true;
      });
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          "Test Failed",
          style: GoogleFonts.outfit(
            color: Colors.redAccent,
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
              setState(() => _level = 4);
              _startLevel();
            },
            child: Text(
              "Retry",
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
          "Chimp Test",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                "Lvl $_level",
                style: GoogleFonts.outfit(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
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
                "Click the numbers in order",
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _hideNumbers ? "Numbers are hidden!" : "Memorize positions...",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _hideNumbers ? Colors.amberAccent : Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: AspectRatio(
                  aspectRatio: 0.8,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: 40,
                    itemBuilder: (context, index) {
                      int? val = _grid[index];
                      if (val == null) return const SizedBox.shrink();

                      return GestureDetector(
                        onTap: () => _handleTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _hideNumbers
                                ? Colors.white
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _hideNumbers ? "" : "$val",
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ).animate().scale();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
