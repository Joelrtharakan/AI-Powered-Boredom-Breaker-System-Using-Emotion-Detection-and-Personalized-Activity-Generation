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
  String _userName = "Joel";

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

  void _navigateToItem(Map<String, dynamic> item) {
    final type = item['type'].toString().toLowerCase();
    if (type == 'breathing') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ZenScreen()),
      );
    } else if (type == 'game') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GamesScreen()),
      );
    } else if (type == 'music') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MusicScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodState = ref.watch(moodProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Good day,",
                        style: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _userName,
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: AppColors.surface,
                      radius: 26,
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: -0.2),

              const SizedBox(height: 32),
              _buildPremiumInputCard(moodState),
              const SizedBox(height: 40),

              moodState.when(
                data: (data) {
                  if (data.isEmpty) return _buildQuickRelief();

                  final plan = data['plan'] as List;
                  final mood = data['mood']['mood'];
                  final intensity = ((data['mood']['intensity'] ?? 0) * 100)
                      .toInt();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Today's Path",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildMoodBadge(mood, intensity),
                        ],
                      ).animate().fadeIn().slideX(begin: -0.1),
                      const SizedBox(height: 20),
                      ...List.generate(plan.length, (index) {
                        return InkWell(
                          onTap: () => _navigateToItem(plan[index]),
                          borderRadius: BorderRadius.circular(24),
                          child: _buildPlanCard(plan[index], index)
                              .animate()
                              .fadeIn(delay: (index * 150).ms)
                              .slideY(begin: 0.2, curve: Curves.easeOut),
                        );
                      }),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton.icon(
                          onPressed: () =>
                              ref.read(moodProvider.notifier).getSurprisePlan(),
                          icon: const Icon(
                            Icons.redeem_rounded,
                            color: Colors.amberAccent,
                          ),
                          label: Text(
                            "Surprise Me",
                            style: GoogleFonts.outfit(color: Colors.white70),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(
                        "Crafting your plan...",
                        style: GoogleFonts.inter(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                error: (e, _) => _buildErrorCard(e.toString()),
              ),

              const SizedBox(height: 48),
              _buildExploreSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        ),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
      ).animate().scale(delay: 500.ms).fadeIn(),
    );
  }

  Widget _buildPremiumInputCard(AsyncValue moodState) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's on your mind?",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            maxLines: 4,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: "I'm feeling...",
              hintStyle: GoogleFonts.inter(color: Colors.white24),
              filled: true,
              fillColor: Colors.black12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildAnalyzeButton(moodState),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1);
  }

  Widget _buildAnalyzeButton(AsyncValue moodState) {
    bool isLoading = moodState.isLoading;
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: AppColors.primaryGradient),
      ),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                if (_controller.text.isNotEmpty) {
                  ref
                      .read(moodProvider.notifier)
                      .analyzeMood(_controller.text, _userId);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                "Find My Flow",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildQuickRelief() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Relief",
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ReliefIcon(
              icon: Icons.air,
              label: "Breathe",
              color: Colors.cyanAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ZenScreen()),
              ),
            ),
            _ReliefIcon(
              icon: Icons.gamepad_rounded,
              label: "Play",
              color: Colors.orangeAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GamesScreen()),
              ),
            ),
            _ReliefIcon(
              imageUrl:
                  "https://img.icons8.com/liquid-glass-color/96/musical-notes.png",
              label: "Listen",
              color: Colors.purpleAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MusicScreen()),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildExploreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Explore More",
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildExploreCard(
              "Journal",
              Icons.book_rounded,
              Colors.blueAccent,
              const JournalScreen(),
            ),
            _buildExploreCard(
              "Voice",
              Icons.mic_rounded,
              Colors.redAccent,
              const VoiceModeScreen(),
            ),
            _buildExploreCard(
              "Lockbox",
              Icons.lock_rounded,
              Colors.purpleAccent,
              const LockboxScreen(),
            ),
            _buildExploreCard(
              "History",
              Icons.history_rounded,
              Colors.tealAccent,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: InkWell(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodBadge(String mood, int intensity) {
    Color color = _getMoodColor(mood);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        "${mood.toUpperCase()} • $intensity%",
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> item, int index) {
    IconData icon;
    Color color;
    switch (item['type']) {
      case 'music':
        icon = Icons.music_note_rounded;
        color = AppColors.secondary;
        break;
      case 'breathing':
        icon = Icons.air_rounded;
        color = Colors.tealAccent;
        break;
      case 'game':
        icon = Icons.sports_esports_rounded;
        color = Colors.orangeAccent;
        break;
      case 'micro_task':
        icon = Icons.auto_fix_high_rounded;
        color = AppColors.accent;
        break;
      default:
        icon = Icons.star_rounded;
        color = AppColors.primary;
        break;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: item['type'] == 'music'
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.network(
                        "https://img.icons8.com/liquid-glass-color/96/musical-notes.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['type'].toString().replaceAll('_', ' ').toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: color,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['description'],
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (item['time_minutes'] != null)
            Text(
              "${item['time_minutes']}m",
              style: GoogleFonts.inter(
                color: Colors.white30,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    mood = mood.toLowerCase();
    if (mood.contains('anger') || mood.contains('frust')) {
      return Colors.redAccent;
    }
    if (mood.contains('happy') || mood.contains('joy')) {
      return Colors.amberAccent;
    }
    if (mood.contains('sad')) {
      return Colors.lightBlueAccent;
    }
    return AppColors.primary;
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(error, style: const TextStyle(color: Colors.redAccent)),
    );
  }
}

class _ReliefIcon extends StatelessWidget {
  final IconData? icon;
  final String? imageUrl;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ReliefIcon({
    this.icon,
    this.imageUrl,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 32,
              child: imageUrl != null
                  ? Image.network(imageUrl!, fit: BoxFit.contain)
                  : Icon(icon, color: color, size: 32),
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
