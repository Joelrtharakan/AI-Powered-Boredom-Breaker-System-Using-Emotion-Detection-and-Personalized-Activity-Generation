import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_2048_screen.dart';
import 'snake_game_screen.dart';
import 'visual_memory_game.dart';
import 'reaction_time_game.dart';
import 'number_guess_game.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        title: Text(
          "Games Arcade",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildGameCard(
              "2048",
              Icons.grid_4x4,
              Colors.orangeAccent,
              "Combine tiles to reach 2048!",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Game2048Screen(),
                  ),
                );
              },
            ),
            _buildGameCard(
              "Snake",
              Icons.gesture,
              Colors.greenAccent,
              "Classic snake game.",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SnakeGameScreen(),
                  ),
                );
              },
            ),
            _buildGameCard(
              "Visual Memory",
              Icons.flip,
              Colors.blueAccent,
              "Test your memory skills.",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VisualMemoryGame(),
                  ),
                );
              },
            ),
            _buildGameCard(
              "Reaction Time",
              Icons.touch_app,
              Colors.redAccent,
              "How fast can you tap?",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReactionTimeGame(),
                  ),
                );
              },
            ),
            _buildGameCard(
              "Number Guess",
              Icons.onetwothree,
              Colors.purpleAccent,
              "Guess the number!",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NumberGuessGame(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
