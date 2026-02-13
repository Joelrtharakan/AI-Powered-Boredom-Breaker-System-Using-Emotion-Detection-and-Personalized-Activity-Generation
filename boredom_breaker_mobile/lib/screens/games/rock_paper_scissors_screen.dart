import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class RockPaperScissorsScreen extends StatefulWidget {
  const RockPaperScissorsScreen({super.key});

  @override
  State<RockPaperScissorsScreen> createState() =>
      _RockPaperScissorsScreenState();
}

class _RockPaperScissorsScreenState extends State<RockPaperScissorsScreen> {
  final List<String> _choices = ["Rock", "Paper", "Scissors"];
  final List<IconData> _icons = [
    Icons.back_hand_rounded,
    Icons.front_hand_rounded,
    Icons.content_cut_rounded,
  ];

  String? _userChoice;
  String? _aiChoice;
  String? _result;
  bool _isAnimating = false;

  void _play(String choice) {
    if (_isAnimating) return;

    setState(() {
      _userChoice = choice;
      _isAnimating = true;
      _result = null;
      _aiChoice = null;
    });

    // Simulate "Rock, Paper, Scissors..." animation
    Future.delayed(const Duration(milliseconds: 1000), () {
      final aiIndex = Random().nextInt(3);
      final aiChoice = _choices[aiIndex];

      setState(() {
        _aiChoice = aiChoice;
        _isAnimating = false;
        _result = _getResult(choice, aiChoice);
      });
    });
  }

  String _getResult(String user, String ai) {
    if (user == ai) return "It's a Tie!";
    if ((user == "Rock" && ai == "Scissors") ||
        (user == "Paper" && ai == "Rock") ||
        (user == "Scissors" && ai == "Paper")) {
      return "You Win! 🎉";
    }
    return "AI Wins! 🤖";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Rock Paper Scissors",
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI Section
            _buildChoiceCircle(_aiChoice, isAI: true),
            const SizedBox(height: 20),
            Text(
              "AI COMPANION",
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 60),

            // Result Section
            SizedBox(
              height: 40,
              child: Text(
                _result ?? (_isAnimating ? "Choosing..." : "VS"),
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _result?.contains("Win") ?? false
                      ? AppColors.primary
                      : Colors.white,
                ),
              ).animate(target: _result != null ? 1 : 0).scale().shimmer(),
            ),

            const SizedBox(height: 60),

            // User Section
            Text(
              "YOUR TURN",
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChoiceButton(
                  "Rock",
                  Icons.back_hand_rounded,
                  Colors.orangeAccent,
                ),
                const SizedBox(width: 20),
                _buildChoiceButton(
                  "Paper",
                  Icons.front_hand_rounded,
                  Colors.blueAccent,
                ),
                const SizedBox(width: 20),
                _buildChoiceButton(
                  "Scissors",
                  Icons.content_cut_rounded,
                  Colors.purpleAccent,
                ),
              ],
            ),

            const SizedBox(height: 60),
            TextButton(
              onPressed: () => setState(() {
                _userChoice = null;
                _aiChoice = null;
                _result = null;
              }),
              child: Text(
                "Reset",
                style: GoogleFonts.inter(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCircle(String? choice, {bool isAI = false}) {
    IconData? icon;
    if (choice != null) {
      icon = _icons[_choices.indexOf(choice)];
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          if (choice != null)
            BoxShadow(
              color: isAI
                  ? AppColors.secondary.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.2),
              blurRadius: 30,
            ),
        ],
      ),
      child: Center(
        child: icon != null
            ? Icon(
                icon,
                size: 50,
                color: isAI ? AppColors.secondary : AppColors.primary,
              )
            : Icon(Icons.help_outline_rounded, size: 50, color: Colors.white10),
      ).animate(target: choice != null ? 1 : 0).scale().rotate(),
    );
  }

  Widget _buildChoiceButton(String choice, IconData icon, Color color) {
    bool isSelected = _userChoice == choice;
    return GestureDetector(
      onTap: () => _play(choice),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.2)
                  : AppColors.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : Colors.white.withOpacity(0.05),
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? color : Colors.white54,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            choice,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.white : AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
