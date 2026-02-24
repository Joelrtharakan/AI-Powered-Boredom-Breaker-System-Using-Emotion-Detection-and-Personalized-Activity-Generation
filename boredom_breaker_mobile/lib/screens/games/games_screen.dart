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

class GamesScreen extends StatefulWidget {
  final String? initialGameTitle;
  final ScrollController? scrollController;
  const GamesScreen({super.key, this.initialGameTitle, this.scrollController});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialGameTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToGame(widget.initialGameTitle!);
      });
    }
  }

  void _navigateToGame(String title) {
    // Re-create the list to find the game
    // This is a bit inefficient but safe since we don't want to move all data classes out right now
    final allGames = _getAllGames();
    final game = allGames.firstWhere(
      (g) => g.title.toLowerCase() == title.toLowerCase(),
      orElse: () => allGames[0], // Fallback
    );

    // Only navigate if we found a match (or fallback if desired, but better to check)
    if (game.title.toLowerCase() == title.toLowerCase()) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => game.screen));
    }
  }

  List<GameData> _getAllGames() {
    return [
      GameData(
        "Snake Evolution",
        "Retro Reimagined",
        Icons.gesture_rounded,
        const Color(0xFF6D4EFF),
        const SnakeGameScreen(),
        "https://img.icons8.com/3d-fluency/94/snake.png",
      ),
      GameData(
        "Memory Flip",
        "Pattern Match",
        Icons.copy_rounded,
        const Color(0xFF6D4EFF),
        const MemoryFlipScreen(),
        null,
      ),
      GameData(
        "Chimp Test",
        "Sequence Recall",
        Icons.psychology_rounded,
        const Color(0xFF6D4EFF),
        const ChimpTestScreen(),
        null,
      ),
      GameData(
        "Visual Memory",
        "Spatial Grid",
        Icons.grid_view_rounded,
        const Color(0xFF6D4EFF),
        const VisualMemoryGame(),
        null,
      ),
      GameData(
        "Guess Number",
        "Intuition",
        Icons.help_center_rounded,
        const Color(0xFF6D4EFF),
        const NumberGuessGame(),
        null,
      ),
      GameData(
        "Aim Trainer",
        "Precision",
        Icons.gps_fixed_rounded,
        const Color(0xFF6D4EFF),
        const AimTrainerScreen(),
        null,
      ),
      GameData(
        "Reaction Time",
        "Reflexes",
        Icons.bolt_rounded,
        const Color(0xFF6D4EFF),
        const ReactionTimeGame(),
        null,
      ),
      GameData(
        "Tic Tac Toe",
        "Strategy",
        null,
        const Color(0xFF6D4EFF),
        const TicTacToeScreen(),
        "https://img.icons8.com/external-icongeek26-linear-colour-icongeek26/64/external-Tic-Tac-Toe-table-games-icongeek26-linear-colour-icongeek26.png",
      ),
      GameData(
        "Rock Paper Scissors",
        "Logic & Luck",
        Icons.sports_mma_rounded,
        const Color(0xFF6D4EFF),
        const RockPaperScissorsScreen(),
        "assets/rock_paper.png",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Game Data Organization
    // We'll filter from the master list now
    final allGames = _getAllGames();

    final featuredGame = allGames.firstWhere(
      (g) => g.title == "Snake Evolution",
    );
    final brainGames = allGames
        .where(
          (g) => [
            "Memory Flip",
            "Chimp Test",
            "Visual Memory",
            "Guess Number",
          ].contains(g.title),
        )
        .toList();
    final actionGames = allGames
        .where((g) => ["Aim Trainer", "Reaction Time"].contains(g.title))
        .toList();
    final classicGames = allGames
        .where((g) => ["Tic Tac Toe", "Rock Paper Scissors"].contains(g.title))
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          controller: widget.scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                child: Column(
                  children: [
                    // 3. Featured Hero Card
                    _buildSectionHeader(
                      "FEATURED",
                      Icons.star_rounded,
                      const Color(0xFF6D4EFF),
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
                      const Color(0xFF6D4EFF),
                    ),
                    const SizedBox(height: 20),
                    _buildGridSection(context, brainGames),

                    const SizedBox(height: 48),

                    // 5. Action (Wide Cards)
                    _buildSectionHeader(
                      "ACTION ZONE",
                      Icons.flash_on_rounded,
                      const Color(0xFF6D4EFF),
                    ),
                    const SizedBox(height: 20),
                    _buildActionList(context, actionGames),

                    const SizedBox(height: 48),

                    // 6. Classics (Compact Grid)
                    _buildSectionHeader(
                      "CLASSICS",
                      Icons.history_edu_rounded,
                      const Color(0xFF6D4EFF),
                    ),
                    const SizedBox(height: 20),
                    _buildGridSection(context, classicGames),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: const Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.3), Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(2),
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
        height: 320, // Increased height to prevent overflow
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: const Color(0xFF1E293B).withValues(alpha: 0.08),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Stack(
            children: [
              // Vibrant Accent Glow
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: game.color.withValues(alpha: 0.15),
                    boxShadow: [
                      BoxShadow(
                        color: game.color.withValues(alpha: 0.2),
                        blurRadius: 60,
                      ),
                    ],
                  ),
                ),
              ),

              // Giant Abstract Icon Background
              Positioned(
                right: -30,
                bottom: -30,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    game.icon ?? Icons.extension,
                    size: 240,
                    color: game.color.withValues(alpha: 0.1),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: game.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "MOST POPULAR",
                        style: GoogleFonts.outfit(
                          color: game.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      flex: 2,
                      child: Text(
                        game.title,
                        style: GoogleFonts.outfit(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E293B),
                          height: 1.0,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 1,
                      child: Text(
                        game.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 54,
                      width: 170,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            game.color.withValues(alpha: 0.7),
                            game.color,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: game.color.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "PLAY NOW",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 1.2,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.08),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Stack(
                    children: [
                      // Vibrant corner glow
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: game.color.withValues(alpha: 0.1),
                            boxShadow: [
                              BoxShadow(
                                color: game.color.withValues(alpha: 0.15),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Bottom left subtle glow
                      Positioned(
                        bottom: -40,
                        left: -40,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: game.color.withValues(alpha: 0.05),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: game.color.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: game.color.withValues(alpha: 0.25),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: game.imageUrl != null
                                  ? (game.imageUrl!.startsWith("http")
                                        ? Image.network(
                                            game.imageUrl!,
                                            width: 32,
                                            height: 32,
                                          )
                                        : Image.asset(
                                            game.imageUrl!,
                                            width: 32,
                                            height: 32,
                                          ))
                                  : Icon(
                                      game.icon,
                                      color: game.color,
                                      size: 32,
                                    ),
                            ),
                            const Spacer(),
                            Text(
                              game.title,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF1E293B),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              game.subtitle,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Arrow overlay
                      Positioned(
                        bottom: 22,
                        right: 22,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: game.color,
                            size: 14,
                          ),
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
        height: 115,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: const Color(0xFF1E293B).withValues(alpha: 0.08),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // Ambient background glow
              Positioned(
                right: -60,
                top: -60,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: game.color.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: game.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: game.color.withValues(alpha: 0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: game.imageUrl != null
                          ? (game.imageUrl!.startsWith("http")
                                ? Image.network(
                                    game.imageUrl!,
                                    width: 32,
                                    height: 32,
                                  )
                                : Image.asset(
                                    game.imageUrl!,
                                    width: 32,
                                    height: 32,
                                  ))
                          : Icon(game.icon, color: game.color, size: 32),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            game.title,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF1E293B),
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            game.subtitle,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF64748B),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            game.color.withValues(alpha: 0.7),
                            game.color,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: game.color.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
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
