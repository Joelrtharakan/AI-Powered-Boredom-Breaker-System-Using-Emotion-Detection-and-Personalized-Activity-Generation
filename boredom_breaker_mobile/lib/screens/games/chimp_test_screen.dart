import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/games_api.dart';

class ChimpTestScreen extends StatefulWidget {
  const ChimpTestScreen({super.key});

  @override
  State<ChimpTestScreen> createState() => _ChimpTestScreenState();
}

class _ChimpTestScreenState extends State<ChimpTestScreen> {
  int _level = 1;
  List<int?> _grid = List.filled(30, null);
  int _nextExpected = 1;
  bool _hideNumbers = false;
  bool _isGameOver = false;
  bool _gameStarted = false;
  int _lives = 3;

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  void _startLevel() {
    setState(() {
      _grid = List.filled(30, null);
      _nextExpected = 1;
      _hideNumbers = false;
      _isGameOver = false;

      // Cap at 30 logic
      int numItems = _level;
      if (numItems > 30) numItems = 30;

      List<int> positions = List.generate(30, (i) => i);
      positions.shuffle();

      for (int i = 1; i <= numItems; i++) {
        _grid[positions[i - 1]] = i;
      }
    });
  }

  void _handleTap(int index) {
    if (_isGameOver || _grid[index] == null) return;

    int tapedValue = _grid[index]!;

    if (tapedValue == _nextExpected) {
      setState(() {
        if (_nextExpected == 1) {
          _hideNumbers = true;
        }

        _grid[index] = null; // Remove tile
        _nextExpected++;

        if (_nextExpected > _level) {
          // Level Clear
          _level++;
          Future.delayed(const Duration(milliseconds: 500), _startLevel);
        }
      });
    } else {
      // Wrong Number - Lose a life
      setState(() {
        _lives--;
        if (_lives <= 0) {
          _isGameOver = true;
          _showGameOverDialog();
        } else {
          // Reset the same level
          _startLevel();
        }
      });
    }
  }

  void _showGameOverDialog() {
    GamesApi.submitScore('chimp_test', _level > 1 ? _level - 1 : 0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.05),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.psychology_alt_rounded,
                size: 80,
                color: Color(0xFF0EA5E9),
              ).animate().shake(duration: 600.ms),
              const SizedBox(height: 24),
              Text(
                "BRAIN OVERLOAD!",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You memorized $_level numbers.",
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Exit screen
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "EXIT",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _level = 1; // Reset to Level 1
                          _lives = 3; // Reset lives
                          _gameStarted = true;
                        });
                        _startLevel();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF0EA5E9,
                        ), // Better contrast blue
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "RETRY",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Sleek Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 1.5,
                  colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
                ),
              ),
            ),
          ),

          // 2. Grid Pattern Overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                "https://www.transparenttextures.com/patterns/carbon-fibre.png", // Texture pattern
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          SafeArea(
            child: !_gameStarted
                ? _buildInstructions()
                : Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1E293B,
                                ).withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Color(0xFF1E293B),
                                  size: 20,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),

                            // Lives Indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.favorite_rounded,
                                    color: Colors.redAccent,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "$_lives",
                                    style: GoogleFonts.outfit(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate(target: _lives < 3 ? 1.0 : 0.0).shake(),

                            // Title
                            Column(
                              children: [
                                Text(
                                  "CHIMP TEST",
                                  style: GoogleFonts.outfit(
                                    color: const Color(
                                      0xFF0EA5E9,
                                    ), // Improved contrast blue
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _hideNumbers ? "RECALL MODE" : "MEMORIZE",
                                  style: GoogleFonts.spaceMono(
                                    color: _hideNumbers
                                        ? Colors.redAccent
                                        : const Color(0xFF64748B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ).animate(target: _hideNumbers ? 1 : 0).shake(),
                              ],
                            ),

                            // Level Indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF0EA5E9,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFF0EA5E9,
                                  ).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                "LVL $_level",
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF0EA5E9),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Game Grid
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      5, // 5 columns is standard for phone
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.0,
                                ),
                            itemCount: 30, // 5x6
                            itemBuilder: (context, index) {
                              int? val = _grid[index];
                              if (val == null) return const SizedBox();

                              return _buildTile(index, val);
                            },
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Footer / Restart
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _level = 1; // Reset to Level 1
                              _startLevel();
                            });
                          },
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: const Color(
                              0xFF1E293B,
                            ).withValues(alpha: 0.3),
                            size: 18,
                          ),
                          label: Text(
                            "RESET",
                            style: GoogleFonts.outfit(
                              color: const Color(
                                0xFF1E293B,
                              ).withValues(alpha: 0.3),
                              letterSpacing: 1.5,
                              fontSize: 12,
                            ),
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

  Widget _buildTile(int index, int val) {
    return GestureDetector(
      onTap: () => _handleTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _hideNumbers
              ? const Color(0xFFCBD5E1) // The "Cover" color
              : Colors.white, // The "Card" color
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hideNumbers
                ? const Color(0xFFCBD5E1)
                : const Color(0xFF06B6D4).withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _hideNumbers
                  ? Colors.transparent
                  : const Color(0xFF06B6D4).withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: _hideNumbers
              ? const LinearGradient(
                  colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF06B6D4).withValues(alpha: 0.1),
                    Colors.blue.withValues(alpha: 0.05),
                  ],
                ),
        ),
        child: Center(
          child: _hideNumbers
              ? Container(
                  // Dot in the center of hint
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                )
              : Text(
                  "$val",
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF06B6D4),
                    shadows: [
                      Shadow(
                        color: Colors.blue.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildInstructionItem(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF0EA5E9), size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: const Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.05),
                  border: Border.all(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  size: 60,
                  color: Color(0xFF0EA5E9),
                ),
              ).animate().scale(duration: 1.seconds, curve: Curves.elasticOut),

              const SizedBox(height: 32),

              Text(
                "PRIMATE MEMORY",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Can you beat the chimp?",
                style: GoogleFonts.inter(
                  color: const Color(0xFF0284C7), // Darker Cyan/Blue (Sky 600)
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 48),

              _buildInstructionItem(
                Icons.touch_app_rounded,
                "Tap '1' to start the sequence.",
              ),
              _buildInstructionItem(
                Icons.visibility_off_rounded,
                "Other numbers will hide.",
              ),
              _buildInstructionItem(
                Icons.format_list_numbered_rounded,
                "Tap the hidden squares in order.",
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _gameStarted = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 15,
                      shadowColor: const Color(
                        0xFF0EA5E9,
                      ).withValues(alpha: 0.4),
                    ),
                    child: Text(
                      "START EXPERIMENT",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "ABORT",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
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
