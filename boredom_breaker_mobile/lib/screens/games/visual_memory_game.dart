import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  bool _gameStarted = false; // Add instruction state

  @override
  void initState() {
    super.initState();
    // Do NOT start level automatically. Wait for user to click Start.
  }

  void _startLevel() {
    if (!mounted) return;
    setState(() {
      _selectedTiles = [];
      _targetTiles = [];
      _showingPattern = true;
      _isPlaying = true;

      // Difficulty: Start with 3, cap at 12-14?
      int numTiles = _level + 2;
      if (numTiles > 16) numTiles = 16; // Cap at full grid

      List<int> available = List.generate(16, (i) => i);
      available.shuffle();
      _targetTiles = available.take(numTiles).toList();
    });

    // Show pattern longer if more tiles
    int showTime = 1000 + (_level * 100);
    if (showTime > 2500) showTime = 2500;

    Future.delayed(Duration(milliseconds: showTime), () {
      if (mounted) setState(() => _showingPattern = false);
    });
  }

  void _handleTap(int index) {
    if (_showingPattern || !_isPlaying) return;
    if (_selectedTiles.contains(index)) return;

    setState(() {
      // Check if Correct
      if (_targetTiles.contains(index)) {
        _selectedTiles.add(index);

        // Check Level Complete
        if (_selectedTiles.length == _targetTiles.length) {
          _level++;
          Future.delayed(const Duration(milliseconds: 500), _startLevel);
        }
      } else {
        // Wrong Tile
        _lives--;
        // Show missed tile briefly in Red?
        // For now just removing life or ending game.
        // Standard visual memory: You lose a life, showing the correct one?
        // Let's keep it simple: Wrong tap -> Life lost.
        // Maybe shake screen?

        if (_lives <= 0) {
          _gameOver();
        } else {
          // Flash Red feedback?
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Wrong tile!"),
              backgroundColor: Colors.redAccent,
              duration: 500.ms,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Show the pattern again to remind them?
          // Standard game usually restarts the pattern or level.
          _startLevel();
        }
      }
    });
  }

  void _gameOver() {
    setState(() => _isPlaying = false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.amberAccent.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amberAccent.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.grid_goldenratio_rounded,
                size: 80,
                color: Colors.amberAccent,
              ).animate().scale(duration: 600.ms),
              const SizedBox(height: 24),
              Text(
                "MEMORY OVERLOAD!",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You reached Level $_level",
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
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
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "EXIT",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
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
                          _level = 1;
                          _lives = 3;
                          _gameStarted = true;
                        });
                        _startLevel();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "RETRY",
                        style: GoogleFonts.outfit(
                          color: Colors.black,
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Cyberpunk Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1005), // Dark Gold
                    Color(0xFF000000),
                  ],
                ),
              ),
            ),
          ),
          // 2. Grid Pattern Overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                "https://www.transparenttextures.com/patterns/cubes.png",
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
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),

                            Column(
                              children: [
                                Text(
                                  "VISUAL MEMORY",
                                  style: GoogleFonts.outfit(
                                    color: Colors.amberAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                      _showingPattern ? "WATCH" : "RECALL",
                                      style: GoogleFonts.spaceMono(
                                        color: _showingPattern
                                            ? Colors.amberAccent
                                            : Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                    .animate(target: _showingPattern ? 1 : 0)
                                    .shimmer(),
                              ],
                            ),

                            // Stat
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amberAccent.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.amberAccent.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.amberAccent,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "$_lives",
                                    style: GoogleFonts.outfit(
                                      color: Colors.amberAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Level Indicator
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text(
                          "LEVEL $_level",
                          style: GoogleFonts.outfit(
                            color: Colors.white24,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                      ),

                      // Grid
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          constraints: const BoxConstraints(
                            maxWidth: 360,
                          ), // Constrain for cleaner look
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: 16,
                              itemBuilder: (context, index) {
                                bool isTarget = _targetTiles.contains(index);
                                bool isSelected = _selectedTiles.contains(
                                  index,
                                );

                                // Animation States
                                Color color = const Color(0xFF2A2A2A); // Base

                                if (_showingPattern && isTarget) {
                                  color = Colors.white; // Flash White
                                } else if (isSelected && isTarget) {
                                  color =
                                      Colors.amberAccent; // Correct Selection
                                } else if (isSelected && !isTarget) {
                                  color = Colors
                                      .redAccent; // Wrong Selection (Though logic usually handles this immediately)
                                }

                                return GestureDetector(
                                  onTap: () => _handleTap(index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: (_showingPattern && isTarget)
                                            ? Colors.white
                                            : Colors.white.withValues(
                                                alpha: 0.05,
                                              ),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        if (_showingPattern && isTarget)
                                          BoxShadow(
                                            color: Colors.white.withValues(
                                              alpha: 0.4,
                                            ),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        if (isSelected && isTarget)
                                          BoxShadow(
                                            color: Colors.amberAccent
                                                .withValues(alpha: 0.4),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                      ],
                                    ),
                                  ),
                                ).animate().scale(delay: (index * 20).ms);
                              },
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 60),
                    ],
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
                  color: Colors.amberAccent.withValues(alpha: 0.05),
                  border: Border.all(
                    color: Colors.amberAccent.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amberAccent.withValues(alpha: 0.1),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.grid_4x4_rounded,
                  size: 60,
                  color: Colors.amberAccent,
                ),
              ).animate().scale(duration: 1.seconds, curve: Curves.elasticOut),

              const SizedBox(height: 32),

              Text(
                "VISUAL MEMORY",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Pattern Recognition Test",
                style: GoogleFonts.inter(
                  color: Colors.amberAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 48),

              _buildInstructionItem(
                Icons.visibility_rounded,
                "Watch the white tiles flash.",
              ),
              _buildInstructionItem(
                Icons.timer_rounded,
                "Memorize the pattern.",
              ),
              _buildInstructionItem(
                Icons.touch_app_rounded,
                "Tap the tiles to recreate it.",
              ),
              _buildInstructionItem(
                Icons.favorite_rounded,
                "3 lives. Don't miss!",
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
                      _startLevel();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 15,
                      shadowColor: Colors.amberAccent.withValues(alpha: 0.4),
                    ),
                    child: Text(
                      "START TEST",
                      style: GoogleFonts.outfit(
                        color: Colors.black,
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
                    color: Colors.white38,
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

  Widget _buildInstructionItem(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amberAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.amberAccent, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white70,
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
}
