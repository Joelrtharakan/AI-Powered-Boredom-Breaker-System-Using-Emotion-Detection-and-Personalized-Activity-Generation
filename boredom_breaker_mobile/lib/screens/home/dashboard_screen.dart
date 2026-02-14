import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/mood_provider.dart';
import '../../services/session_manager.dart';
import '../../theme/app_theme.dart';
import '../chat/chat_screen.dart';
import '../zen_screen.dart';
import '../music/music_screen.dart';
import '../games/games_screen.dart';
import '../journal/journal_screen.dart';
import '../history/history_screen.dart';
import '../lockbox/lockbox_screen.dart';
import '../voice/voice_mode_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _controller = TextEditingController();
  int _userId = 1;
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final id = await SessionManager.getUserId();
    final name = await SessionManager.getUserName();
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
      backgroundColor: Colors.black, // Deep AMOLED black base
      body: Stack(
        children: [
          // Ambient Background Gradients
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purpleAccent.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
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
                gradient: RadialGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Section
                  _buildHeader()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.2),

                  const SizedBox(height: 32),

                  // 2. Mood Input (The "Pulse")
                  _buildMoodSection(moodState).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 32),

                  // 3. Quick Relief (Featured Icons)
                  Text(
                    "Instant Dopamine",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 16),
                  _buildQuickReliefRow()
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideX(),

                  const SizedBox(height: 32),

                  // 4. Dynamic Content (Plan or Explore)
                  moodState.when(
                    data: (data) {
                      if (data.isEmpty) return const SizedBox.shrink();
                      return _buildGeneratedPlan(
                        data,
                      ).animate().fadeIn(duration: 500.ms);
                    },
                    loading: () => _buildLoadingIndicator(),
                    error: (e, _) => Text(
                      "Error: $e",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                  _buildExploreGrid().animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 80), // Bottom padding
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back,",
              style: GoogleFonts.outfit(fontSize: 16, color: Colors.white54),
            ),
            Text(
              _userName,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF1E1E1E),
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSection(AsyncValue moodState) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151517),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How are you feeling right now?",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _controller,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type it out...",
                hintStyle: GoogleFonts.inter(color: Colors.white30),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: moodState.isLoading
                  ? null
                  : () {
                      if (_controller.text.isNotEmpty) {
                        ref
                            .read(moodProvider.notifier)
                            .analyzeMood(_controller.text, _userId);
                        FocusScope.of(context).unfocus();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: moodState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      "Fix My Mood",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReliefRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildIconCard(
          "Breathe",
          "https://img.icons8.com/external-flat-vinzence-studio/64/external-breathe-world-pollution-flat-vinzence-studio.png",
          Colors.cyanAccent,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ZenScreen()),
          ),
        ),
        _buildIconCard(
          "Games",
          "https://img.icons8.com/3d-fluency/94/controller.png",
          Colors.orangeAccent,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GamesScreen()),
          ),
        ),
        _buildIconCard(
          "Music",
          "https://img.icons8.com/liquid-glass-color/96/musical-notes.png",
          Colors.purpleAccent,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MusicScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildIconCard(
    String label,
    String imageUrl,
    Color glowColor,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1D),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                    height: 48,
                    width: 48,
                    child: Image.network(imageUrl, fit: BoxFit.contain),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 2.seconds,
                    curve: Curves.easeInOut,
                  ),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratedPlan(Map<String, dynamic> data) {
    final plan = data['plan'] as List;
    final mood = data['mood']['mood'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Your Personal Plan",
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                mood.toString().toUpperCase(),
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...plan.asMap().entries.map((entry) {
          final item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.amberAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['description'],
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      if (item['time_minutes'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "${item['time_minutes']} mins",
                            style: GoogleFonts.inter(
                              color: Colors.white30,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (entry.key * 100).ms).slideX();
        }),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildExploreGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Explore Tools",
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildExploreCard(
              "Journal",
              Icons.book,
              Colors.blueAccent,
              const JournalScreen(),
            ),
            _buildExploreCard(
              "Voice Mode",
              Icons.mic,
              Colors.redAccent,
              const VoiceModeScreen(),
            ),
            _buildExploreCard(
              "Lockbox",
              Icons.lock,
              Colors.tealAccent,
              const LockboxScreen(),
            ),
            _buildExploreCard(
              "History",
              Icons.history,
              Colors.purpleAccent,
              const HistoryScreen(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExploreCard(
    String title,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF151517),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              "AI is thinking...",
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIButton() {
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      child: const Icon(Icons.auto_awesome),
    ).animate().scale(
      delay: 1.seconds,
      duration: 400.ms,
      curve: Curves.elasticOut,
    );
  }
}
