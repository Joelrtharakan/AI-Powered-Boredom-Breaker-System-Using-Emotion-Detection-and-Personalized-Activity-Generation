import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/mood_provider.dart';
import '../../providers/history_provider.dart';
import '../../services/session_manager.dart';
import '../../theme/app_theme.dart';
import '../zen_screen.dart';
import '../music/music_screen.dart';
import '../games/games_screen.dart';
import '../journal/journal_screen.dart';
import '../history/history_screen.dart';
import '../lockbox/lockbox_screen.dart';
import '../voice/voice_mode_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  final void Function(int tabIndex)? onTabSwitch;
  const DashboardScreen({super.key, this.scrollController, this.onTabSwitch});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _controller = TextEditingController();
  int _userId = 1;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final id = await SessionManager.getUserId();

    if (mounted) {
      setState(() {
        if (id != null) _userId = id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodState = ref.watch(moodProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Pure OLED Black
      resizeToAvoidBottomInset: false, // Prevents keyboard resizing background
      body: Stack(
        children: [
          // 1. Dynamic Ambient Background

          // 2. Main Content
          SafeArea(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // "The Pulse" - Mood Input Section
                  _MoodInputSection(
                        controller: _controller,
                        moodState: moodState,
                        onSubmit: () async {
                          if (_controller.text.isNotEmpty) {
                            await ref
                                .read(moodProvider.notifier)
                                .analyzeMood(_controller.text, _userId);
                            ref.read(historyProvider.notifier).fetchHistory();
                            if (context.mounted) {
                              FocusScope.of(context).unfocus();
                            }
                          }
                        },
                      )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 32),

                  // Generated Plan (appears here with animation)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack, // Playful bounce
                    child: moodState.when(
                      data: (data) {
                        if (data.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return _GeneratedPlanCard(
                          data: data,
                          onReset: () {
                            ref.read(moodProvider.notifier).reset();
                            _controller.clear();
                          },
                        ).animate().fadeIn().slideY(begin: 0.1);
                      },
                      loading: () => _buildLoadingIndicator(),
                      error: (e, _) => _buildErrorState(e.toString()),
                    ),
                  ),

                  // Instant Dopamine
                  const SizedBox(height: 12),
                  const _SectionTitle(title: "INSTANT DOPAMINE"),
                  const SizedBox(height: 16),
                  _buildDopamineRow()
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideX(begin: 0.1),

                  const SizedBox(height: 48),

                  // Explore Tools
                  const _SectionTitle(title: "EXPLORE TOOLS"),
                  const SizedBox(height: 16),
                  _buildExploreGrid().animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 120), // Bottom padding for FAB
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDopamineRow() {
    return SizedBox(
      height: 140, // Reduced height slightly
      child: Row(
        children: [
          Expanded(
            child: _DopamineCard(
              title: "Breathe",
              iconUrl:
                  "https://img.icons8.com/external-flat-vinzence-studio/64/external-breathe-world-pollution-flat-vinzence-studio.png",
              gradientStart: const Color(0xFF00C6FF),
              gradientEnd: const Color(0xFF0072FF),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ZenScreen()),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DopamineCard(
              title: "Games",
              iconUrl: "https://img.icons8.com/3d-fluency/94/controller.png",
              gradientStart: const Color(0xFFF2994A),
              gradientEnd: const Color(0xFFF2C94C),
              onTap: () {
                if (widget.onTabSwitch != null) {
                  widget.onTabSwitch!(1); // Switch to Games tab
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DopamineCard(
              title: "Music",
              iconUrl:
                  "https://img.icons8.com/liquid-glass-color/96/musical-notes.png",
              gradientStart: const Color(0xFF833AB4),
              gradientEnd: const Color(0xFFFD1D1D),
              onTap: () {
                if (widget.onTabSwitch != null) {
                  widget.onTabSwitch!(2); // Switch to Music tab
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreGrid() {
    final items = [
      {
        'title': 'Journal',
        'iconUrl': 'https://img.icons8.com/stickers/256/journal.png',
        'color': const Color(0xFF4FACFE),
        'screen': const JournalScreen(),
      },
      {
        'title': 'Voice',
        'iconUrl':
            'https://img.icons8.com/external-tal-revivo-filled-tal-revivo/96/external-inbuilt-voice-assistant-for-smartphones-isolated-on-a-white-background-house-filled-tal-revivo.png',
        'color': const Color(0xFFFF416C),
        'screen': const VoiceModeScreen(),
      },
      {
        'title': 'Lockbox',
        'iconUrl': 'https://img.icons8.com/clouds/256/lock--v1.png',
        'color': const Color(0xFF43E97B),
        'screen': const LockboxScreen(),
      },
      {
        'title': 'History',
        'iconUrl': 'https://img.icons8.com/clouds/256/time-machine.png',
        'color': const Color(0xFFFA709A),
        'screen': const HistoryScreen(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ExploreCard(item: item);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D4EFF).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    color: Color(0xFF6D4EFF),
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 1.seconds,
                ),
            const SizedBox(height: 16),
            Text(
                  "Crafting your escape...",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF94A3B8),
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2.seconds, color: const Color(0xFF1E293B)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              "Oops! Something went wrong.",
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please try again.",
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- WIDGET COMPONENTS ----------------

class _MoodInputSection extends StatelessWidget {
  final TextEditingController controller;
  final AsyncValue moodState;
  final VoidCallback onSubmit;

  const _MoodInputSection({
    required this.controller,
    required this.moodState,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            "How are you feeling?",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC), // Very light slate
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.transparent),
            ),
            child: TextField(
              controller: controller,
              style: GoogleFonts.inter(
                color: const Color(0xFF1E293B),
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: "I'm feeling a bit anxious and bored...",
                hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
              maxLines: 4,
              minLines: 3,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: moodState.isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: moodState.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Generate Plan",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratedPlanCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onReset;

  const _GeneratedPlanCard({required this.data, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final plan = data['plan'] as List;
    final mood = data['mood']['mood'];

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white, // Light theme card
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF1E293B).withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Your Personal Plan",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onReset,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    tooltip: "New Plan",
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), // Subtle badge bg
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      mood.toString().toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(
              color: const Color(0xFF1E293B).withValues(alpha: 0.05),
              height: 1,
            ),
          ),
          // Check for NO_EMOTION response
          if (plan.isNotEmpty && plan[0]['no_plan'] == true)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.sentiment_neutral_rounded,
                    color: const Color(0xFFCBD5E1),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    plan[0]['description'] ?? "No emotion detected",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Try telling me how you feel 💬",
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF6D4EFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            )
          else
            ...plan.asMap().entries.map((entry) {
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StepNumber(number: entry.key + 1),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['description'],
                            style: GoogleFonts.inter(
                              color: const Color(0xFF1E293B),
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (item['time_minutes'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 14,
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${item['time_minutes']} MIN",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFCBD5E1),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          _buildActionLink(context, item),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildActionLink(BuildContext context, Map<String, dynamic> item) {
    final String description = item['description'];
    final Map<String, dynamic>? metadata = item['metadata'];
    final lowerDesc = description.toLowerCase();

    String? label;
    Widget? screen;
    IconData? icon;
    Color? color;

    final String type = item['type'] ?? '';

    if (type == 'breathing' ||
        lowerDesc.contains('breath') ||
        lowerDesc.contains('meditat')) {
      label = "Start Breathing";
      screen = const ZenScreen();
      icon = Icons.air_rounded;
      color = const Color(0xFF00C6FF);
    } else if (type == 'music' ||
        type == 'calming_audio' ||
        lowerDesc.contains('music') ||
        lowerDesc.contains('song') ||
        lowerDesc.contains('listen') ||
        lowerDesc.contains('playlist') ||
        lowerDesc.contains('ambient') ||
        lowerDesc.contains('white noise') ||
        lowerDesc.contains('instrumental') ||
        (metadata != null &&
            (metadata.containsKey('spotify_uri') ||
                metadata.containsKey('playlist_name')))) {
      label = "Open Music";

      String? playlistName;
      String? spotifyUrl;
      String? trackName;

      if (metadata != null) {
        if (metadata.containsKey('spotify_uri')) {
          spotifyUrl = metadata['spotify_uri'];
        }
        if (metadata.containsKey('playlist_name')) {
          playlistName = metadata['playlist_name'];
          trackName = playlistName;
        }
      }

      screen = MusicScreen(
        initialPlaylistName: playlistName,
        initialSpotifyUrl: spotifyUrl,
        initialTitle: trackName,
      );
      icon = Icons.music_note_rounded;
      color = const Color(0xFF833AB4);
      if (playlistName != null) label = "Play $playlistName";
    } else if (type == 'game' ||
        lowerDesc.contains('game') ||
        lowerDesc.contains('play')) {
      label = "Play Games";
      String? gameTitle;

      // Try to find known game titles in description if minimal metadata isnt there
      if (metadata != null && metadata.containsKey('game_name')) {
        gameTitle = metadata['game_name'];
      } else {
        // Fuzzy find common games
        final knownGames = [
          "Snake Evolution",
          "Memory Flip",
          "Chimp Test",
          "Visual Memory",
          "Guess Number",
          "Aim Trainer",
          "Reaction Time",
          "Tic Tac Toe",
          "Rock Paper Scissors",
        ];
        for (final g in knownGames) {
          if (lowerDesc.contains(g.toLowerCase())) {
            gameTitle = g;
            break;
          }
        }
      }

      screen = GamesScreen(initialGameTitle: gameTitle);
      icon = Icons.gamepad_rounded;
      color = const Color(0xFFF2994A);
      if (gameTitle != null) label = "Play $gameTitle";
    } else if (type == 'journal' ||
        lowerDesc.contains('journal') ||
        lowerDesc.contains('write') ||
        lowerDesc.contains('note')) {
      label = "Open Journal";
      screen = const JournalScreen();
      icon = Icons.book_rounded;
      color = const Color(0xFF4FACFE);
    }

    if (label == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: InkWell(
        onTap: () {
          if (screen is HistoryScreen) {
            Navigator.push(context, HistoryScreen.route());
          } else if (screen is JournalScreen) {
            Navigator.push(context, JournalPageRoute());
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color!.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepNumber extends StatelessWidget {
  final int number;
  const _StepNumber({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(
          color: number == 1
              ? const Color(0xFF4EEBFF)
              : const Color(0xFFE2E8F0),
          width: 2,
        ),
      ),
      child: Text(
        "$number",
        style: GoogleFonts.outfit(
          color: number == 1
              ? const Color(0xFF4EEBFF)
              : const Color(0xFF64748B),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _DopamineCard extends StatelessWidget {
  final String title;
  final String iconUrl;
  final Color gradientStart;
  final Color gradientEnd;
  final VoidCallback onTap;

  const _DopamineCard({
    required this.title,
    required this.iconUrl,
    required this.gradientStart,
    required this.gradientEnd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // width: 140, // Removed fixed width so it expands
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF1E293B).withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: gradientStart.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: gradientEnd.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle gradient wash
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      gradientStart.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child:
                      Image.network(
                            iconUrl,
                            height: 48,
                            width: 48,
                          ) // Reduced icon size
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.1, 1.1),
                            duration: 2.seconds,
                          ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ExploreCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final screen = item['screen'] as Widget;
        if (screen is HistoryScreen) {
          Navigator.push(context, HistoryScreen.route());
        } else if (screen is JournalScreen) {
          Navigator.push(context, JournalPageRoute());
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        }
      },
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: (item['color'] as Color).withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: (item['color'] as Color).withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.network(
                item['iconUrl'] as String,
                width: 48,
                height: 48,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['title'] as String,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: AppColors.primary.withValues(alpha: 0.8),
          letterSpacing: 2.5,
        ),
      ),
    );
  }
}
