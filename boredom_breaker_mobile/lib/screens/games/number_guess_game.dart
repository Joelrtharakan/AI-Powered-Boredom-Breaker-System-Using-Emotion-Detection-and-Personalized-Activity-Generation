import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../services/games_api.dart';

class NumberGuessGame extends StatefulWidget {
  const NumberGuessGame({super.key});

  @override
  State<NumberGuessGame> createState() => _NumberGuessGameState();
}

class _NumberGuessGameState extends State<NumberGuessGame> {
  final TextEditingController _controller = TextEditingController();
  late int _targetNumber;
  String _message = "Guess a number between 1 and 100";
  List<int> _history = [];
  String _status = 'neutral'; // neutral, low, high, win
  int _attempts = 0;
  bool _gameStarted = false; // New state for intro screen

  // Design constants
  final Color _primaryColor = const Color(0xFF8B5CF6); // Violet
  final Color _secondaryColor = const Color(0xFFEC4899); // Pink
  final Color _accentLow = const Color(0xFF3B82F6); // Blue
  final Color _accentHigh = const Color(0xFFF97316); // Orange

  @override
  void initState() {
    super.initState();
    _resetGameLogic();
  }

  void _resetGameLogic() {
    setState(() {
      _targetNumber = Random().nextInt(100) + 1;
      _message = "Guess a number between 1 and 100";
      _history = [];
      _status = 'neutral';
      _attempts = 0;
      _controller.clear();
    });
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _resetGameLogic();
    });
  }

  void _handleGuess() {
    final text = _controller.text;
    if (text.isEmpty) return;

    final guess = int.tryParse(text);
    if (guess == null) {
      setState(() {
        _message = "Please enter a valid number";
        _status = 'neutral';
      });
      return;
    }

    // Check if duplicate (optional, but good UX)
    if (_history.contains(guess)) {
      // Don't count duplicate unless invalid logic desired
      // Actually, let's allow it but warn? Nah, proceed.
    }

    setState(() {
      // Add to front of history
      if (!_history.contains(guess)) {
        _history.insert(0, guess);
        _attempts++;
      }

      if (guess == _targetNumber) {
        _message = "🎉 Correct! You won!";
        _status = 'win';
        int score = 1000 - (_attempts * 50);
        if (score < 10) score = 10;
        GamesApi.submitScore('number_guess', score);
      } else if (guess < _targetNumber) {
        _message = "Too Low 📉 try higher";
        _status = 'low';
      } else {
        _message = "Too High 📈 try lower";
        _status = 'high';
      }
      _controller.clear();
    });
  }

  Color _getStatusColor() {
    switch (_status) {
      case 'win':
        return Colors.greenAccent;
      case 'low':
        return _accentLow;
      case 'high':
        return _accentHigh;
      default:
        return const Color(0xFF1E293B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light background
      body: Stack(
        children: [
          // Background Gradient Mesh
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withValues(alpha: 0.1),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _secondaryColor.withValues(alpha: 0.1),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: !_gameStarted ? _buildInstructions() : _buildGameInterface(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInterface() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: const Color(0xFF1E293B),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Text(
                "GUESS THE NUMBER",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Attempts: $_attempts",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Status Card
                AnimatedContainer(
                  duration: 300.ms,
                  padding: const EdgeInsets.all(32),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: _status == 'neutral'
                          ? const Color(0xFFCBD5E1)
                          : _getStatusColor().withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      if (_status != 'neutral')
                        BoxShadow(
                          color: _getStatusColor().withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                            _message,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _status == 'neutral'
                                  ? const Color(0xFF1E293B)
                                  : _getStatusColor(),
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          )
                          .animate(key: ValueKey(_message))
                          .fadeIn()
                          .scale(duration: 200.ms),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Input Section
                if (_status != 'win') ...[
                  // Nice modern input
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF1E293B),
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "?",
                        hintStyle: TextStyle(color: const Color(0xFF94A3B8)),
                        counterText: "",
                      ),
                      maxLength: 3,
                      onSubmitted: (_) => _handleGuess(),
                      autofocus: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleGuess,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: _primaryColor.withValues(alpha: 0.5),
                        elevation: 8,
                      ),
                      child: Text(
                        "SUBMIT GUESS",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ] else
                  Column(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 64,
                        color: Colors.amberAccent,
                      ).animate().scale(curve: Curves.elasticOut),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _resetGameLogic();
                            // _gameStarted remains true;
                          },
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                          ),
                          label: Text(
                            "PLAY AGAIN",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),

                const SizedBox(height: 48),

                // History Section
                if (_history.isNotEmpty) ...[
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFCBD5E1))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "HISTORY",
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFCBD5E1))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Wrap logic
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _history.map((h) {
                      final bool isLow = h < _targetNumber;
                      // Logic for "Winning number" in history?
                      // If game is won, the winning number is at index 0.
                      // But let's just color code hints.

                      Color color = Colors.white24;
                      IconData icon = Icons.circle;

                      if (h == _targetNumber) {
                        color = Colors.greenAccent;
                        icon = Icons.check_circle_rounded;
                      } else if (isLow) {
                        color = _accentLow;
                        icon = Icons.arrow_upward_rounded;
                      } else {
                        color = _accentHigh;
                        icon = Icons.arrow_downward_rounded;
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$h",
                              style: GoogleFonts.spaceMono(
                                color: const Color(0xFF1E293B),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(icon, color: color, size: 16),
                          ],
                        ),
                      ).animate().scale(
                        duration: 200.ms,
                        curve: Curves.easeOutBack,
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primaryColor.withValues(alpha: 0.1),
                border: Border.all(color: _primaryColor.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withValues(alpha: 0.2),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Icon(Icons.casino_rounded, size: 60, color: _primaryColor),
            ).animate().scale(duration: 1.seconds, curve: Curves.elasticOut),

            const SizedBox(height: 32),
            Text(
              "NUMBER GUESS",
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w900,
                fontSize: 28,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Find the secret number (1-100)",
              style: GoogleFonts.inter(
                color: _secondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 48),

            _buildInstructionItem(
              Icons.question_mark_rounded,
              "I'm thinking of a number...",
            ),
            _buildInstructionItem(
              Icons.arrow_upward_rounded,
              "If I say 'Low', guess higher.",
            ),
            _buildInstructionItem(
              Icons.arrow_downward_rounded,
              "If I say 'High', guess lower.",
            ),
            _buildInstructionItem(
              Icons.emoji_events_rounded,
              "Find it in fewest tries!",
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 15,
                    shadowColor: _primaryColor.withValues(alpha: 0.4),
                  ),
                  child: Text(
                    "START GUESSING",
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
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF1E293B), size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
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
