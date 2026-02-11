import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/mood_provider.dart';
import '../chat/chat_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final moodState = ref.watch(moodProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF09090B), // Dark background
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Simple navigation to chat
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
        },
        child: const Icon(Icons.chat),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF18181B), const Color(0xFF09090B)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Profile
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back,",
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Joel",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ), // Hardcoded Name for now
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                      radius: 24,
                      child: const Icon(Icons.person, color: Colors.blueAccent),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Mood Input Card (Glassmorphism)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "How are you feeling?",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _controller,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: "I'm feeling a bit bored and tired...",
                          hintStyle: GoogleFonts.inter(color: Colors.white30),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        maxLines: 4,
                        minLines: 3,
                      ),
                      const SizedBox(height: 16),
                      // Quick Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildMoodChip("Bored 😑", "I am feeling bored"),
                          _buildMoodChip("Anxious 😰", "I am feeling anxious"),
                          _buildMoodChip("Tired 😴", "I am feeling tired"),
                          _buildMoodChip("Sad 😢", "I am feeling sad"),
                        ],
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: moodState.isLoading
                              ? null
                              : () {
                                  if (_controller.text.isNotEmpty) {
                                    ref
                                        .read(moodProvider.notifier)
                                        .analyzeMood(_controller.text, 1);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            shadowColor: const Color(
                              0xFF3B82F6,
                            ).withValues(alpha: 0.4),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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
                                    const Icon(Icons.auto_awesome, size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Analyze Mood",
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Results Section or Quick Actions
                if (!moodState.hasValue ||
                    (moodState.value?.isEmpty ?? true)) ...[
                  Text(
                    "Quick Relief",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickAction(
                        Icons.air,
                        "Breathing",
                        Colors.tealAccent,
                        () {},
                      ),
                      _buildQuickAction(
                        Icons.gamepad,
                        "Games",
                        Colors.orangeAccent,
                        () {},
                      ),
                      _buildQuickAction(
                        Icons.music_note,
                        "Music",
                        Colors.purpleAccent,
                        () {},
                      ),
                    ],
                  ),
                ],

                moodState.when(
                  data: (data) {
                    if (data.isEmpty) return const SizedBox.shrink();
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
                              "Suggested Plan",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getMoodColor(
                                  mood,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getMoodColor(
                                    mood,
                                  ).withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                "${mood.toUpperCase()} • $intensity%",
                                style: TextStyle(
                                  color: _getMoodColor(mood),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ...plan.map((item) => _buildPlanCard(item)),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(), // Loader is in button
                  error: (e, _) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Error: $e",
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),

                const SizedBox(height: 100), // Bottom padding for nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodChip(String label, String value) {
    return GestureDetector(
      onTap: () {
        _controller.text = value;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    if (mood.contains('anger') || mood.contains('frust')) {
      return Colors.redAccent;
    }
    if (mood.contains('happy') || mood.contains('joy')) {
      return Colors.amber;
    }
    if (mood.contains('sad')) {
      return Colors.blueGrey;
    }
    if (mood.contains('anx')) {
      return Colors.orangeAccent;
    }
    return Colors.blueAccent;
  }

  Widget _buildPlanCard(Map<String, dynamic> item) {
    IconData icon;
    Color color;

    switch (item['type']) {
      case 'music':
        icon = Icons.music_note;
        color = Colors.purpleAccent;
        break;
      case 'breathing':
        icon = Icons.air;
        color = Colors.tealAccent;
        break;
      case 'game':
        icon = Icons.gamepad;
        color = Colors.orangeAccent;
        break;
      case 'micro_task':
        icon = Icons.check_circle_outline;
        color = Colors.yellowAccent;
        break;
      default:
        icon = Icons.star;
        color = Colors.blueAccent;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['type'].toString().replaceAll('_', ' ').toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: color,
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
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
          if (item['time_minutes'] != null && item['time_minutes'] > 0)
            Text(
              "${item['time_minutes']}m",
              style: const TextStyle(
                color: Colors.white38,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
