import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'game_2048_screen.dart';
import 'snake_game_screen.dart';
import 'visual_memory_game.dart';
import 'reaction_time_game.dart';
import 'number_guess_game.dart';
import 'tic_tac_toe_screen.dart';
import 'rock_paper_scissors_screen.dart';
import 'chimp_test_screen.dart';
import 'aim_trainer_screen.dart';
import 'memory_flip_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "Games Arcade",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Challenge your self and beat the boredom.",
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ).animate().fadeIn().slideX(begin: -0.1),
            const SizedBox(height: 32),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildModernGameCard(
                  context,
                  "2048",
                  Icons.grid_4x4_rounded,
                  Colors.orangeAccent,
                  "Strategic puzzle",
                  const Game2048Screen(),
                  0,
                ),
                _buildModernGameCard(
                  context,
                  "Snake",
                  Icons.gesture_rounded,
                  Colors.greenAccent,
                  "Classic retro",
                  const SnakeGameScreen(),
                  1,
                ),
                _buildModernGameCard(
                  context,
                  "Memory Flip",
                  Icons.copy_rounded,
                  Colors.pinkAccent,
                  "Match emojis",
                  const MemoryFlipScreen(),
                  2,
                ),
                _buildModernGameCard(
                  context,
                  "Aim Trainer",
                  Icons.gps_fixed_rounded,
                  Colors.redAccent,
                  "Test accuracy",
                  const AimTrainerScreen(),
                  3,
                ),
                _buildModernGameCard(
                  context,
                  "Chimp Test",
                  Icons.psychology_rounded,
                  Colors.amberAccent,
                  "Memory sequence",
                  const ChimpTestScreen(),
                  4,
                ),
                _buildModernGameCard(
                  context,
                  "Tic Tac Toe",
                  Icons.close_rounded,
                  Colors.lightBlueAccent,
                  "Classic 3x3",
                  const TicTacToeScreen(),
                  5,
                ),
                _buildModernGameCard(
                  context,
                  "R-P-S",
                  Icons.front_hand_rounded,
                  Colors.indigoAccent,
                  "Luck of the draw",
                  const RockPaperScissorsScreen(),
                  6,
                ),
                _buildModernGameCard(
                  context,
                  "Visual Mem",
                  Icons.grid_view_rounded,
                  Colors.blueAccent,
                  "Recall skills",
                  const VisualMemoryGame(),
                  7,
                ),
                _buildModernGameCard(
                  context,
                  "Reaction",
                  Icons.bolt_rounded,
                  Colors.tealAccent,
                  "Tap speed",
                  const ReactionTimeGame(),
                  8,
                ),
                _buildModernGameCard(
                  context,
                  "Guess No.",
                  Icons.help_center_rounded,
                  Colors.purpleAccent,
                  "Intuition test",
                  const NumberGuessGame(),
                  9,
                ),
              ],
            ),
            const SizedBox(height: 120), // Padding for nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildModernGameCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String subtitle,
    Widget screen,
    int index,
  ) {
    return Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => screen),
              ),
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icon, color: color, size: 28),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .shimmer(duration: 3.seconds),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (index * 50).ms)
        .scale(begin: const Offset(0.9, 0.9));
  }
}
