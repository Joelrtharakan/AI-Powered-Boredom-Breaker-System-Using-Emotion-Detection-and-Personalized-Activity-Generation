import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/games_api.dart';

class MemoryFlipScreen extends StatefulWidget {
  const MemoryFlipScreen({super.key});

  @override
  State<MemoryFlipScreen> createState() => _MemoryFlipScreenState();
}

class _MemoryFlipScreenState extends State<MemoryFlipScreen> {
  // Config
  int _level = 1;
  final int _maxLevel = 3;

  // Game State
  bool _gameStarted = false; // Instruction overlay state
  late List<String> _cards;
  late List<bool> _flipped;
  late List<bool> _solved;
  int? _firstIndex;
  int _moves = 0;
  bool _busy = false; // Prevent interactions while flipping back

  // Grid Config
  int _crossAxisCount = 3;
  double _childAspectRatio = 0.9;

  // Assets
  final List<String> _allEmojis = [
    '🎮',
    '⚡',
    '🌈',
    '🌙',
    '🍕',
    '🚀',
    '💎',
    '🎨',
    '🎸',
    '🐱',
    '🌵',
    '🍩',
    '🎈',
    '🧩',
    '🏆',
    '⚓',
    '📷',
    '🔑',
    '🍔',
    '🎁',
    '🔥',
    '🎲',
    '🎵',
    '⚽',
    '🕶️',
    '💡',
    '⏰',
    '🚲',
    '🍉',
    '🍦',
  ];

  @override
  void initState() {
    super.initState();
    _startLevel(_level);
  }

  void _startLevel(int level) {
    int pairs;
    int rows;
    int cols;

    // Difficulty Progression
    switch (level) {
      case 1: // 3x4 = 12 cards (6 pairs)
        cols = 3;
        rows = 4;
        break;
      case 2: // 4x4 = 16 cards (8 pairs)
        cols = 4;
        rows = 4;
        break;
      case 3: // 4x5 = 20 cards (10 pairs)
        cols = 4;
        rows = 5;
        break;
      default:
        cols = 4;
        rows = 4;
    }

    pairs = (cols * rows) ~/ 2;
    _crossAxisCount = cols;
    // Square-ish aspect ratio for better look
    _childAspectRatio = 0.9;

    setState(() {
      _level = level;
      var levelEmojis = _allEmojis.take(pairs).toList();
      _cards = [...levelEmojis, ...levelEmojis]..shuffle();
      _flipped = List.filled(_cards.length, false);
      _solved = List.filled(_cards.length, false);
      _moves = 0;
      _firstIndex = null;
      _busy = false;
    });
  }

  void _handleTap(int index) {
    if (_busy || _flipped[index] || _solved[index]) return;

    setState(() {
      _flipped[index] = true;
    });

    if (_firstIndex == null) {
      _firstIndex = index;
    } else {
      _moves++;
      if (_cards[_firstIndex!] == _cards[index]) {
        // Match Found
        setState(() {
          _solved[_firstIndex!] = true;
          _solved[index] = true;
          _firstIndex = null;
        });

        if (_solved.every((e) => e)) {
          Future.delayed(const Duration(milliseconds: 500), _showWinDialog);
        }
      } else {
        // No Match
        _busy = true;
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          setState(() {
            _flipped[_firstIndex!] = false;
            _flipped[index] = false;
            _firstIndex = null;
            _busy = false;
          });
        });
      }
    }
  }

  void _showWinDialog() {
    bool isLastLevel = _level >= _maxLevel;
    Color glowColor = isLastLevel ? Colors.amber : Colors.greenAccent;
    String title = isLastLevel ? "GRAND CHAMPION!" : "LEVEL $_level CLEARED!";
    IconData icon = isLastLevel
        ? Icons.emoji_events_rounded
        : Icons.check_circle_outline_rounded;

    int currentScore = (_level * 1000) - (_moves * 10);
    GamesApi.submitScore('memory_flip', currentScore);

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
            border: Border.all(color: glowColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 80, color: glowColor)
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .shimmer(),
              const SizedBox(height: 24),
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (isLastLevel)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "You've mastered all levels!",
                    style: GoogleFonts.inter(
                      color: Colors.amberAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Text(
                "Solved in $_moves moves",
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
                        if (isLastLevel) {
                          _startLevel(1); // Restart from level 1
                        } else {
                          _startLevel(_level + 1);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: glowColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isLastLevel ? "REPLAY" : "NEXT LEVEL",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
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
          // Dynamic Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8FAFC),
                    Color(0xFFF1F5F9),
                    Color(0xFFCBD5E1),
                  ],
                ),
              ),
            ),
          ),
          // Floating Orbs
          Positioned(
            top: -100,
            right: -100,
            child:
                Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.pinkAccent.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                      duration: 4.seconds,
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
                                color: const Color(
                                  0xFF1E293B,
                                ).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Color(0xFF1E293B),
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  "LEVEL $_level",
                                  style: GoogleFonts.outfit(
                                    color: Colors.pinkAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  "MEMORY FLIP",
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF1E293B),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Tap pairs to match",
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF64748B),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1E293B,
                                ).withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFF1E293B,
                                  ).withValues(alpha: 0.1),
                                ),
                              ),
                              child: Text(
                                "$_moves MOVES",
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: _crossAxisCount,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: _childAspectRatio,
                                  ),
                              itemCount: _cards.length,
                              itemBuilder: (context, index) {
                                return _buildCard(index);
                              },
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: TextButton.icon(
                          onPressed: () => _startLevel(_level),
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Color(0xFF94A3B8),
                          ),
                          label: Text(
                            "RESTART LEVEL",
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 1.5,
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

  Widget _buildInstructions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.help_outline_rounded,
              size: 80,
              color: Colors.pinkAccent,
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 32),
            Text(
              "HOW TO PLAY",
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w900,
                fontSize: 28,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            _buildInstructionItem(
              Icons.touch_app_rounded,
              "Tap a card to flip it over.",
            ),
            const SizedBox(height: 16),
            _buildInstructionItem(
              Icons.compare_arrows_rounded,
              "Find the matching pair.",
            ),
            const SizedBox(height: 16),
            _buildInstructionItem(
              Icons.timelapse_rounded,
              "Clear matched pairs quickly!",
            ),
            const SizedBox(height: 16),
            _buildInstructionItem(
              Icons.layers_rounded,
              "Complete 3 levels to win.",
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _gameStarted = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 10,
                  shadowColor: Colors.pinkAccent.withValues(alpha: 0.4),
                ),
                child: Text(
                  "START GAME",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "BACK TO ARCADE",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.pinkAccent, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(int index) {
    bool isRevealed = _flipped[index] || _solved[index];
    bool isSolved = _solved[index];

    return GestureDetector(
      onTap: () => _handleTap(index),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: isRevealed ? 180 : 0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutBack,
        builder: (context, value, child) {
          bool isFront = value < 90;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * pi / 180),
            alignment: Alignment.center,
            child: isFront
                ? _buildCardBack()
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildCardFront(_cards[index], isSolved),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.question_mark_rounded,
          color: const Color(0xFFCBD5E1),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCardFront(String emoji, bool isSolved) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSolved
              ? Colors.greenAccent
              : Colors.pinkAccent.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSolved
                ? Colors.greenAccent.withValues(alpha: 0.1)
                : Colors.pinkAccent.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: _crossAxisCount > 4 ? 24 : 32, // Dynamic font size
          ),
        ),
      ),
    );
  }
}
