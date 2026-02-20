import 'dart:convert'; // Added for base64Decode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../providers/mood_provider.dart';
import '../../providers/history_provider.dart';
import '../../services/session_manager.dart';
import '../../services/api_client.dart'; // Added ApiClient
import '../chat/chat_screen.dart';
import '../zen_screen.dart';
import '../music/music_screen.dart';
import '../games/games_screen.dart';
import '../journal/journal_screen.dart';
import '../history/history_screen.dart';
import '../lockbox/lockbox_screen.dart';
import '../voice/voice_mode_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiClient _apiClient = ApiClient(); // Instance of ApiClient
  int _userId = 1;
  String _userName = "Friend";
  String? _profilePicture; // State variable for profile picture

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final id = await SessionManager.getUserId();
    final name = await SessionManager.getUserName();

    // Fetch profile picture from backend (only if authenticated)
    if (ApiClient.token != null) {
      try {
        final response = await _apiClient.client.get('/auth/me');
        if (response.statusCode == 200 && response.data != null) {
          if (mounted) {
            setState(() {
              _profilePicture = response.data['profile_picture'];
            });
          }
        }
      } catch (e) {
        // Silent error for profile pic to not disrupt UX
        debugPrint("Failed to load profile picture: $e");
      }
    }

    if (mounted) {
      setState(() {
        if (id != null) _userId = id;
        if (name != null) _userName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodState = ref.watch(moodProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure OLED Black
      resizeToAvoidBottomInset: false, // Prevents keyboard resizing background
      body: Stack(
        children: [
          // 1. Dynamic Ambient Background
          const _AmbientBackground(),

          // 2. Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader()
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .slideY(begin: -0.2),

                  const SizedBox(height: 32),

                  // "The Pulse" - Mood Input Section
                  _MoodInputSection(
                        controller: _controller,
                        moodState: moodState,
                        onSubmit: () {
                          if (_controller.text.isNotEmpty) {
                            ref
                                .read(moodProvider.notifier)
                                .analyzeMood(_controller.text, _userId);
                            ref.read(historyProvider.notifier).fetchHistory();
                            FocusScope.of(context).unfocus();
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
                        if (data.isEmpty) return const SizedBox.shrink();
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
      floatingActionButton: _buildAIButton(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, $_userName",
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Let's break the cycle.",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () async {
            // Navigate to profile and refresh when back
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
            // Refresh user data (especially profile pic) when returning
            _loadUserData();
          },
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8E2DE2),
                  Color(0xFF4A00E0),
                ], // Deep Purple gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8E2DE2).withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1A1A1D),
                backgroundImage: _profilePicture != null
                    ? MemoryImage(base64Decode(_profilePicture!))
                    : null,
                child: _profilePicture == null
                    ? const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GamesScreen()),
              ),
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MusicScreen()),
              ),
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
        'icon': Icons.book_rounded,
        'color': const Color(0xFF4FACFE),
        'screen': const JournalScreen(),
      },
      {
        'title': 'Voice',
        'icon': Icons.graphic_eq_rounded,
        'color': const Color(0xFFFF416C),
        'screen': const VoiceModeScreen(),
      },
      {
        'title': 'Lockbox',
        'icon': Icons.lock_outline_rounded,
        'color': const Color(0xFF43E97B),
        'screen': const LockboxScreen(),
      },
      {
        'title': 'History',
        'icon': Icons.schedule_rounded,
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
                    color: Colors.white54,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2.seconds, color: Colors.white),
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
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please try again.",
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIButton() {
    return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C6FF).withValues(alpha: 0.5),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            child: const Icon(Icons.auto_awesome_rounded, size: 28),
          ),
        )
        .animate()
        .scale(delay: 1.seconds, duration: 600.ms, curve: Curves.elasticOut)
        .shimmer(delay: 3.seconds, duration: 1.5.seconds);
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
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6D4EFF).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  color: Color(0xFF9D84FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "How are you feeling?",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E22), // Slightly lighter black
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.transparent),
            ),
            child: TextField(
              controller: controller,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: "I'm feeling a bit anxious and bored...",
                hintStyle: GoogleFonts.inter(color: Colors.white24),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
              maxLines: 4,
              minLines: 3,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: moodState.isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 10,
                shadowColor: Colors.white.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: moodState.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
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
        color: const Color(0xFF141414), // Dark Grey for contrast
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D4EFF).withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: -10,
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
                    color: Colors.white,
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
                      color: Colors.white54,
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
                      color: const Color(0xFF2A2A2E), // Subtle badge bg
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      mood.toString().toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFB0B0B0),
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
              color: Colors.white.withValues(alpha: 0.05),
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
                    color: Colors.white38,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    plan[0]['description'] ?? "No emotion detected",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFB0B0B0),
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
                              color: const Color(0xFFE0E0E0),
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
                                    color: Colors.white38,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${item['time_minutes']} MIN",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white38,
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
        if (metadata.containsKey('spotify_uri'))
          spotifyUrl = metadata['spotify_uri'];
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

    if (label == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: InkWell(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen!)),
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
          color: number == 1 ? const Color(0xFF4EEBFF) : Colors.white24,
          width: 2,
        ),
      ),
      child: Text(
        "$number",
        style: GoogleFonts.outfit(
          color: number == 1 ? const Color(0xFF4EEBFF) : Colors.white70,
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
          color: const Color(0xFF161618),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                    color: Colors.white,
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
    final color = item['color'] as Color;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item['screen'] as Widget),
      ),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161618),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item['icon'] as IconData, color: color, size: 24),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['title'] as String,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: Colors.white24,
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
          color: Colors.white38,
          letterSpacing: 2.5,
        ),
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -150,
          right: -100,
          child:
              Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(
                            0xFF4A00E0,
                          ).withValues(alpha: 0.15), // Deep Purple
                          Colors.transparent,
                        ],
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: 6.seconds,
                  ),
        ),
        Positioned(
          bottom: 100,
          left: -150,
          child:
              Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(
                            0xFF00C6FF,
                          ).withValues(alpha: 0.1), // Neon Blue
                          Colors.transparent,
                        ],
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.4, 1.4),
                    duration: 7.seconds,
                  ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}
