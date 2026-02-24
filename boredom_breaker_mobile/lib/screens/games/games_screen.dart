import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

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
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    "All",
    "Brain & Logic",
    "Action",
    "Classics",
  ];

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
    final allGames = _getAllGames();
    final game = allGames.firstWhere(
      (g) => g.title.toLowerCase() == title.toLowerCase(),
      orElse: () => allGames[0],
    );

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
        const Color(0xFF10B981),
        const SnakeGameScreen(),
        "https://img.icons8.com/3d-fluency/94/snake.png",
        "Classics",
      ),
      GameData(
        "Memory Flip",
        "Pattern Match",
        Icons.copy_rounded,
        const Color(0xFF8B5CF6),
        const MemoryFlipScreen(),
        null,
        "Brain & Logic",
      ),
      GameData(
        "Chimp Test",
        "Sequence Recall",
        Icons.psychology_rounded,
        const Color(0xFFF59E0B),
        const ChimpTestScreen(),
        null,
        "Brain & Logic",
      ),
      GameData(
        "Visual Memory",
        "Spatial Grid",
        Icons.grid_view_rounded,
        const Color(0xFF0EA5E9),
        const VisualMemoryGame(),
        null,
        "Brain & Logic",
      ),
      GameData(
        "Guess Number",
        "Intuition",
        Icons.help_center_rounded,
        const Color(0xFFEC4899),
        const NumberGuessGame(),
        null,
        "Brain & Logic",
      ),
      GameData(
        "Aim Trainer",
        "Precision",
        Icons.gps_fixed_rounded,
        const Color(0xFFEF4444),
        const AimTrainerScreen(),
        null,
        "Action",
      ),
      GameData(
        "Reaction Time",
        "Reflexes",
        Icons.bolt_rounded,
        const Color(0xFF14B8A6),
        const ReactionTimeGame(),
        null,
        "Action",
      ),
      GameData(
        "Tic Tac Toe",
        "Strategy",
        null,
        const Color(0xFF3B82F6),
        const TicTacToeScreen(),
        "https://img.icons8.com/external-icongeek26-linear-colour-icongeek26/64/external-Tic-Tac-Toe-table-games-icongeek26-linear-colour-icongeek26.png",
        "Classics",
      ),
      GameData(
        "Rock Paper Scissors",
        "Logic & Luck",
        Icons.sports_mma_rounded,
        const Color(0xFFF43F5E),
        const RockPaperScissorsScreen(),
        "assets/rock_paper.png",
        "Classics",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final allGames = _getAllGames();
    final featuredGame = allGames.firstWhere(
      (g) => g.title == "Snake Evolution",
    );
    final quickPlayGames = allGames
        .where(
          (g) =>
              ["Memory Flip", "Aim Trainer", "Tic Tac Toe"].contains(g.title),
        )
        .toList();

    // Filtered games based on category
    final displayedGames = _selectedCategoryIndex == 0
        ? allGames
        : allGames
              .where((g) => g.category == _categories[_selectedCategoryIndex])
              .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const _SectionTitle(title: "FEATURED GAME"),
              const SizedBox(height: 16),
              _buildFeaturedCard(featuredGame)
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 32),

              const _SectionTitle(title: "QUICK PLAY"),
              const SizedBox(height: 16),
              _buildQuickPlayRow(
                quickPlayGames,
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [const _SectionTitle(title: "EXPLORE COLLECTION")],
              ),
              const SizedBox(height: 16),
              _buildCategoryChips(),
              const SizedBox(height: 20),

              _buildGrid(displayedGames)
                  .animate(key: ValueKey(_selectedCategoryIndex))
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(GameData game) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => game.screen),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: const Color(0xFF1E293B).withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: game.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.title,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: game.color.withValues(alpha: 0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: game.color),
                  const SizedBox(width: 8),
                  Text(
                    "Play Now",
                    style: GoogleFonts.outfit(
                      color: game.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPlayRow(List<GameData> games) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final game = games[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => game.screen),
            ),
            child: Container(
              width: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    game.color,
                    HSLColor.fromColor(game.color).withLightness(0.4).toColor(),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: game.color.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      game.icon ?? Icons.extension,
                      size: 100,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        Text(
                          game.title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_categories.length, (index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFF1E293B).withValues(alpha: 0.08),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF1E293B,
                            ).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  _categories[index],
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGrid(List<GameData> games) {
    if (games.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            "No games found in this category.",
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => game.screen),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFF1E293B).withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: game.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: game.imageUrl != null
                          ? (game.imageUrl!.startsWith("http")
                                ? Image.network(
                                    game.imageUrl!,
                                    width: 24,
                                    height: 24,
                                  )
                                : Image.asset(
                                    game.imageUrl!,
                                    width: 24,
                                    height: 24,
                                  ))
                          : Icon(game.icon, color: game.color, size: 24),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFFCBD5E1),
                      size: 14,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.category,
                      style: GoogleFonts.inter(
                        color: game.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: 24, height: 2, color: const Color(0xFFCBD5E1)),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: const Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
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
  final String category;

  GameData(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.screen,
    this.imageUrl,
    this.category,
  );
}
