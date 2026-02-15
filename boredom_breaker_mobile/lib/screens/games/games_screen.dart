import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

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
    // Game Data Organization
    final featuredGame = GameData(
      "Snake Evolution",
      "Retro Reimagined",
      Icons.gesture_rounded,
      const Color(0xFF00FF94), // Neon Green
      const SnakeGameScreen(),
      "https://img.icons8.com/3d-fluency/94/snake.png",
    );

    final brainGames = [
      GameData(
        "Memory Flip",
        "Pattern Match",
        Icons.copy_rounded,
        const Color(0xFFFF0055),
        const MemoryFlipScreen(),
        null,
      ), // Neon Pink
      GameData(
        "Chimp Test",
        "Sequence Recall",
        Icons.psychology_rounded,
        const Color(0xFFFFD600),
        const ChimpTestScreen(),
        null,
      ), // Neon Yellow
      GameData(
        "Visual Memory",
        "Spatial Grid",
        Icons.grid_view_rounded,
        const Color(0xFF00E5FF),
        const VisualMemoryGame(),
        null,
      ), // Neon Cyan
      GameData(
        "Guess Number",
        "Intuition",
        Icons.help_center_rounded,
        const Color(0xFFD500F9),
        const NumberGuessGame(),
        null,
      ), // Neon Purple
    ];

    final actionGames = [
      GameData(
        "Aim Trainer",
        "Precision",
        Icons.gps_fixed_rounded,
        const Color(0xFFFF3D00),
        const AimTrainerScreen(),
        null,
      ), // Neon Red
      GameData(
        "Reaction Time",
        "Reflexes",
        Icons.bolt_rounded,
        const Color(0xFF76FF03),
        const ReactionTimeGame(),
        null,
      ), // Lime Green
    ];

    final classicGames = [
      GameData(
        "Tic Tac Toe",
        "Strategy",
        null,
        const Color(0xFF2979FF),
        const TicTacToeScreen(),
        "https://img.icons8.com/external-icongeek26-linear-colour-icongeek26/64/external-Tic-Tac-Toe-table-games-icongeek26-linear-colour-icongeek26.png",
      ), // Blue
      GameData(
        "Rock Paper Scissors",
        "Logic & Luck",
        Icons.sports_mma_rounded,
        const Color(0xFF651FFF),
        const RockPaperScissorsScreen(),
        "assets/rock_paper.png",
      ), // Indigo
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          // 1. Dynamic Background Mesh
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A0A0A),
                    Color(0xFF000000),
                    Color(0xFF0E0E12),
                  ],
                ),
              ),
            ),
          ),
          // Animated Glow Orbs
          Positioned(
            top: -150,
            left: -100,
            child:
                Container(
                      width: 500,
                      height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF7B1FA2).withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      duration: 4.seconds,
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                    ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child:
                Container(
                      width: 500,
                      height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF0091EA).withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      duration: 5.seconds,
                      begin: const Offset(1, 1),
                      end: const Offset(1.3, 1.3),
                    ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 2. Translucent App Bar
              SliverAppBar(
                expandedHeight: 100.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.black.withValues(alpha: 0.6),
                surfaceTintColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Center(
                    child: InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Image.network(
                        "https://img.icons8.com/bubbles/100/apple-arcade.png",
                        width: 28,
                        height: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "ARCADE",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.0,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                  child: Column(
                    children: [
                      // 3. Featured Hero Card
                      _buildSectionHeader(
                        "FEATURED",
                        Icons.star_rounded,
                        Colors.amber,
                      ),
                      const SizedBox(height: 20),
                      _buildHeroCard(
                        context,
                        featuredGame,
                      ).animate().slideY(begin: 0.1, duration: 600.ms).fadeIn(),

                      const SizedBox(height: 48),

                      // 4. Brain Training (Large Grid)
                      _buildSectionHeader(
                        "BRAIN & LOGIC",
                        Icons.psychology,
                        Colors.pinkAccent,
                      ),
                      const SizedBox(height: 20),
                      _buildGridSection(context, brainGames),

                      const SizedBox(height: 48),

                      // 5. Action (Wide Cards)
                      _buildSectionHeader(
                        "ACTION ZONE",
                        Icons.flash_on_rounded,
                        Colors.cyanAccent,
                      ),
                      const SizedBox(height: 20),
                      _buildActionList(context, actionGames),

                      const SizedBox(height: 48),

                      // 6. Classics (Compact Grid)
                      _buildSectionHeader(
                        "CLASSICS",
                        Icons.history_edu_rounded,
                        Colors.purpleAccent,
                      ),
                      const SizedBox(height: 20),
                      _buildGridSection(context, classicGames),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.5), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, GameData game) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => game.screen),
      ),
      child: Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: game.color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: game.color.withValues(alpha: 0.15),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Background Gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        game.color.withValues(alpha: 0.15),
                        const Color(0xFF121212),
                      ],
                      stops: const [0.0, 0.6],
                    ),
                  ),
                ),
              ),

              // Giant Icon Background
              Positioned(
                right: -40,
                bottom: -40,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    game.icon,
                    size: 200,
                    color: game.color.withValues(alpha: 0.08),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: game.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: game.color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        "MOST POPULAR",
                        style: GoogleFonts.outfit(
                          color: game.color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      game.title,
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      game.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 50,
                      width: 160,
                      decoration: BoxDecoration(
                        color: game.color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: game.color.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "PLAY NOW",
                            style: GoogleFonts.outfit(
                              color: Colors.black,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridSection(BuildContext context, List<GameData> games) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        return _buildHoloCard(context, games[index], index);
      },
    );
  }

  Widget _buildActionList(BuildContext context, List<GameData> games) {
    return Column(
      children: games
          .map(
            (game) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildWideHoloCard(context, game),
            ),
          )
          .toList(),
    );
  }

  Widget _buildHoloCard(BuildContext context, GameData game, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => game.screen),
      ),
      child:
          Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Subtle colored glow at top
                      Positioned(
                        top: -30,
                        right: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: game.color.withValues(alpha: 0.15),
                            boxShadow: [
                              BoxShadow(
                                color: game.color.withValues(alpha: 0.2),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: game.imageUrl != null
                                  ? (game.imageUrl!.startsWith("http")
                                        ? Image.network(
                                            game.imageUrl!,
                                            width: 28,
                                            height: 28,
                                          )
                                        : Image.asset(
                                            game.imageUrl!,
                                            width: 28,
                                            height: 28,
                                          ))
                                  : Icon(
                                      game.icon,
                                      color: game.color,
                                      size: 28,
                                    ),
                            ),
                            const Spacer(),
                            Text(
                              game.title,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              game.subtitle,
                              style: GoogleFonts.inter(
                                color: Colors.white38,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Arrow overlay
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white.withValues(alpha: 0.1),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: (index * 100).ms)
              .scale(begin: const Offset(0.95, 0.95)),
    );
  }

  Widget _buildWideHoloCard(BuildContext context, GameData game) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => game.screen),
      ),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                  boxShadow: [
                    BoxShadow(
                      color: game.color.withValues(alpha: 0.1),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: game.imageUrl != null
                    ? (game.imageUrl!.startsWith("http")
                          ? Image.network(game.imageUrl!, width: 28, height: 28)
                          : Image.asset(game.imageUrl!, width: 28, height: 28))
                    : Icon(game.icon, color: game.color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      game.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      game.subtitle,
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ).animate().slideX(begin: 0.1).fadeIn(),
    );
  }
}

class GameData {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Color color;
  final Widget screen;
  final String? imageUrl;

  GameData(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.screen,
    this.imageUrl,
  );
}
