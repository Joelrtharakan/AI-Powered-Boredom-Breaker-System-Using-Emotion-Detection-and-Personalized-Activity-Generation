import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/games_api.dart';

class RockPaperScissorsScreen extends StatefulWidget {
  const RockPaperScissorsScreen({super.key});

  @override
  State<RockPaperScissorsScreen> createState() =>
      _RockPaperScissorsScreenState();
}

class _RockPaperScissorsScreenState extends State<RockPaperScissorsScreen> {
  final List<String> _choices = ["Rock", "Paper", "Scissors"];
  bool _gameStarted = false; // Instructions overlay

  // Colors
  final Color _paperColor = const Color(0xFF3B82F6); // Blue
  final Color _scissorsColor = const Color(0xFFEF4444); // Red
  final Color _bgColor = const Color(0xFFF8FAFC); // Slate 50

  String? _userChoice;
  String? _aiChoice;
  String? _result; // "WIN", "LOSE", "DRAW"
  bool _isProcessing = false;

  // Stats
  int _playerScore = 0;
  int _aiScore = 0;

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _resetRound();
    });
  }

  void _resetRound() {
    setState(() {
      _userChoice = null;
      _aiChoice = null;
      _result = null;
      _isProcessing = false;
    });
  }

  void _play(String choice) {
    if (_isProcessing) return;

    setState(() {
      _userChoice = choice;
      _isProcessing = true;
    });

    // Animate randomness
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _determineWinner(choice);
    });
  }

  void _determineWinner(String user) {
    String ai;
    int roll = Random().nextInt(100);

    if (roll < 35) {
      // AI cheats to Win or Draw
      if (user == "Rock") {
        ai = "Paper";
      } else if (user == "Paper") {
        ai = "Scissors";
      } else {
        ai = "Rock";
      }
    } else {
      // Random
      ai = _choices[Random().nextInt(3)];
    }

    String res;
    if (user == ai) {
      res = "DRAW";
    } else if ((user == "Rock" && ai == "Scissors") ||
        (user == "Paper" && ai == "Rock") ||
        (user == "Scissors" && ai == "Paper")) {
      res = "WIN";
      _playerScore++;
    } else {
      res = "LOSE";
      _aiScore++;
    }

    setState(() {
      _aiChoice = ai;
      _result = res;
      _isProcessing = false;
    });

    if (_playerScore >= 5 || _aiScore >= 5) {
      GamesApi.submitScore(
        'rock_paper_scissors',
        _playerScore > _aiScore ? 100 : 0,
      );
      Future.delayed(const Duration(milliseconds: 1000), _showGameOverDialog);
    }
  }

  void _showGameOverDialog() {
    bool playerWon = _playerScore > _aiScore;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: playerWon ? Colors.blueAccent : Colors.redAccent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (playerWon ? Colors.blueAccent : Colors.redAccent)
                    .withValues(alpha: 0.05),
                blurRadius: 40,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                playerWon ? Icons.emoji_events_rounded : Icons.cancel_rounded,
                size: 60,
                color: playerWon ? Colors.amberAccent : Colors.redAccent,
              ).animate().scale(curve: Curves.elasticOut),

              const SizedBox(height: 24),

              Text(
                playerWon ? "MATCH WON!" : "MATCH LOST",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              Text(
                "$_playerScore - $_aiScore",
                style: GoogleFonts.spaceMono(
                  color: const Color(0xFF64748B),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
                      ),
                      child: Text(
                        "EXIT",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        _restartMatch();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: playerWon
                            ? Colors.blueAccent
                            : Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "REMATCH",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
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

  void _restartMatch() {
    setState(() {
      _playerScore = 0;
      _aiScore = 0;
      _resetRound();
    });
  }

  IconData _getIcon(String? choice) {
    if (choice == "Rock") return Icons.landscape_rounded;
    if (choice == "Paper") return Icons.feed_rounded;
    if (choice == "Scissors") return Icons.content_cut_rounded;
    return Icons.question_mark_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // Ambient Background
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _paperColor.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(
                    color: _paperColor.withValues(alpha: 0.05),
                    blurRadius: 80,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _scissorsColor.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(
                    color: _scissorsColor.withValues(alpha: 0.05),
                    blurRadius: 80,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: !_gameStarted ? _buildInstructions() : _buildGameUI(size),
          ),
        ],
      ),
    );
  }

  Widget _buildGameUI(Size size) {
    // Determine card size based on height to prevent overflow
    double cardSize = size.height * 0.15;
    if (cardSize > 140) cardSize = 140; // Max size
    if (cardSize < 100) cardSize = 100; // Min size

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ), // Reduced vertical padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildScoreBadge(
                "YOU",
                _playerScore,
                Colors.blueAccent,
                Icons.person,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
              ),
              _buildScoreBadge(
                "AI",
                _aiScore,
                Colors.redAccent,
                Icons.smart_toy_rounded,
              ),
            ],
          ),
        ),

        // BATTLE ARENA (Flexible Column)
        Expanded(
          flex: 6, // Give more space to arena
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly, // Distribute evenly
            children: [
              // AI Choice
              _buildPlayCard(_aiChoice, isAi: true, size: cardSize),

              // Result / VS Text
              Flexible(
                child: Center(
                  child: _result != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _result == "WIN"
                                  ? "VICTORY"
                                  : (_result == "LOSE" ? "DEFEATED" : "DRAW"),
                              style: GoogleFonts.outfit(
                                fontSize: 32, // Slightly smaller font
                                fontWeight: FontWeight.w900,
                                color: _result == "WIN"
                                    ? Colors.greenAccent
                                    : (_result == "LOSE"
                                          ? Colors.redAccent
                                          : Colors.amberAccent),
                                letterSpacing: 2,
                                shadows: [
                                  BoxShadow(
                                    color: const Color(0xFFCBD5E1),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ).animate().scale(curve: Curves.elasticOut),

                            const SizedBox(height: 8),

                            // Play Again Button
                            ElevatedButton(
                              onPressed: _resetRound,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFCBD5E1),
                                foregroundColor: const Color(0xFF1E293B),
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                "PLAY AGAIN",
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      : (!_isProcessing
                            ? Text(
                                "VS",
                                style: GoogleFonts.outfit(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF94A3B8),
                                ),
                              )
                            : SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: const Color(0xFF94A3B8),
                                  strokeWidth: 2,
                                ),
                              )),
                ),
              ),

              // User Choice
              _buildPlayCard(_userChoice, isAi: false, size: cardSize),
            ],
          ),
        ),

        // CONTROLS (Only visible if not processing result)
        // Wrapped in Container with fixed height to prevent layout jumps
        SizedBox(
          height: 120,
          child: (_result == null && !_isProcessing)
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildChoiceBtn("Rock"),
                      _buildChoiceBtn("Paper"),
                      _buildChoiceBtn("Scissors"),
                    ],
                  ),
                )
              : const SizedBox.shrink(), // Render empty box when hidden to keep layout stable-ish? No, shrink is fine.
        ),
      ],
    );
  }

  Widget _buildScoreBadge(String label, int score, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            "$label: $score",
            style: GoogleFonts.spaceMono(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayCard(
    String? choice, {
    required bool isAi,
    required double size,
  }) {
    if (choice == null) {
      return Container(
        width: size * 0.7,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Icon(
          Icons.help_outline,
          color: const Color(0xFF94A3B8),
          size: 30,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAi
              ? Colors.redAccent.withValues(alpha: 0.5)
              : Colors.blueAccent.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAi ? Colors.redAccent : Colors.blueAccent).withValues(
              alpha: 0.05,
            ),
            blurRadius: 40,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIcon(choice),
            size: size * 0.4,
            color: const Color(0xFF1E293B),
          ),
          SizedBox(height: size * 0.1),
          Text(
            choice,
            style: GoogleFonts.outfit(
              color: const Color(0xFF64748B),
              fontSize: size * 0.15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildChoiceBtn(String choice) {
    return GestureDetector(
      onTap: () => _play(choice),
      child: Column(
        mainAxisSize: MainAxisSize.min, // prevent expansion
        children: [
          Container(
            width: 64, // Slightly smaller buttons
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(
              _getIcon(choice),
              color: const Color(0xFF1E293B),
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            choice,
            style: GoogleFonts.spaceMono(
              color: const Color(0xFF94A3B8),
              fontSize: 10,
            ),
          ),
        ],
      ),
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
              width: 120,
              height: 120,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFCBD5E1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withValues(alpha: 0.05),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: const Icon(
                Icons.sports_mma_rounded,
                color: Colors.purpleAccent,
                size: 60,
              ),
            ).animate().scale(duration: 1.seconds, curve: Curves.elasticOut),

            const SizedBox(height: 32),

            Text(
              "R P S",
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E293B),
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            Text(
              "Rock \u2022 Paper \u2022 Scissors",
              style: GoogleFonts.spaceMono(
                color: const Color(0xFF64748B),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 48),

            _buildInstructionRow(
              Icons.landscape_rounded,
              "Rock beats Scissors",
            ),
            _buildInstructionRow(Icons.feed_rounded, "Paper beats Rock"),
            _buildInstructionRow(
              Icons.content_cut_rounded,
              "Scissors beats Paper",
            ),

            const SizedBox(height: 60),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "FIGHT!",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "RETREAT",
                style: GoogleFonts.spaceMono(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center align
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 24),
          const SizedBox(width: 16),
          Text(
            text,
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
