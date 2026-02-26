import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/session_manager.dart';
import 'write_journal_screen.dart';

/// Premium page route — handles ALL slide in/out animation.
/// Single source of truth for the transition, no conflicts.
class JournalPageRoute extends PageRouteBuilder {
  JournalPageRoute()
    : super(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const JournalScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 550),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart, // Smooth deceleration on enter
            reverseCurve: Curves
                .easeInOutCubic, // Gentle acceleration+deceleration on exit
          );

          // Fade: quick fade-in on enter, gentle fade-out on exit
          final fade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
            reverseCurve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
          );

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.85),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
}

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  bool _isLoading = true;
  List<dynamic> _entries = [];
  final Set<int> _unlockedEntries = {};

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  Future<void> _fetchEntries() async {
    setState(() => _isLoading = true);
    try {
      final userId = await SessionManager.getUserId();
      if (userId != null) {
        final response = await ApiClient().client.get(
          '/journal/list',
          queryParameters: {'user_id': userId, 'limit': 20},
        );
        if (response.statusCode == 200) {
          setState(() {
            _entries = response.data;
          });
        }
      }
    } catch (e) {
      debugPrint("Journal fetch error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getEmotionColor(String? emotion) {
    if (emotion == null) return Colors.blueGrey;
    final em = emotion.toLowerCase();
    if (em.contains("joy") ||
        em.contains("happy") ||
        em.contains("excited") ||
        em.contains("relieved")) {
      return Colors.tealAccent;
    } else if (em.contains("sad") || em.contains("grief")) {
      return Colors.blueAccent;
    } else if (em.contains("anger") ||
        em.contains("mad") ||
        em.contains("stressed")) {
      return Colors.redAccent;
    } else if (em.contains("fear") ||
        em.contains("anxious") ||
        em.contains("panic")) {
      return Colors.orangeAccent;
    } else if (em.contains("bored") || em.contains("fatigue")) {
      return AppColors.secondary;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Gradient header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.28,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF5E60CE),
                    Color(0xFF4EA8DE),
                    Color(0xFF56CFE1),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(top: 40, right: -40, child: _circle(120, 0.1)),
                  Positioned(top: 100, left: -30, child: _circle(80, 0.15)),
                  Positioned(bottom: 20, right: 60, child: _circle(50, 0.08)),
                  // Header content
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white70,
                                ),
                                onPressed: _fetchEntries,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                      "Mindful Journal",
                                      style: GoogleFonts.outfit(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(duration: 400.ms, delay: 200.ms)
                                    .slideX(begin: -0.05),
                                const SizedBox(height: 4),
                                Text(
                                      "Capture your thoughts & emotions",
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        color: Colors.white70,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(duration: 400.ms, delay: 300.ms)
                                    .slideX(begin: -0.05),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. White content area
          Positioned(
            top: size.height * 0.24,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),

      // FAB
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF5E60CE), Color(0xFF4EA8DE)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4EA8DE).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          heroTag: 'journal_fab',
          onPressed: () async {
            final value = await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const WriteJournalScreen(),
                transitionDuration: const Duration(milliseconds: 450),
                reverseTransitionDuration: const Duration(milliseconds: 350),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                        reverseCurve: Curves.easeInCubic,
                      );
                      return FadeTransition(
                        opacity: curved,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.15),
                            end: Offset.zero,
                          ).animate(curved),
                          child: child,
                        ),
                      );
                    },
              ),
            );
            if (value == true) {
              _fetchEntries();
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: Text(
            "Write Entry",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 400.ms),
    );
  }

  Widget _circle(double s, double alpha) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_rounded,
              size: 64,
              color: const Color(0xFF94A3B8).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "No journal entries yet.\nStart writing now!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 17,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        return _buildJournalEntry(_entries[index], index)
            .animate()
            .fadeIn(
              delay: (index * 60).ms,
              duration: 350.ms,
              curve: Curves.easeOut,
            )
            .slideY(
              begin: 0.05,
              delay: (index * 60).ms,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }

  Widget _buildJournalEntry(dynamic entry, int index) {
    final entryId = entry['id'] as int;
    final isEncrypted =
        entry['is_encrypted'] == true || entry['is_encrypted'] == 1;
    final isLocked = isEncrypted && !_unlockedEntries.contains(entryId);

    DateTime cDate;
    try {
      cDate = DateTime.parse(entry['created_at']);
    } catch (_) {
      cDate = DateTime.now();
    }
    final dateStr = DateFormat('MMM dd, yyyy').format(cDate);
    final emotionStr = entry['emotion'] ?? 'Neutral';
    final emotionColor = _getEmotionColor(emotionStr);

    final String title = entry['title'] ?? '';
    final String content = entry['content'] ?? '';

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          setState(() {
            _unlockedEntries.add(entryId);
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5E60CE).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isEncrypted)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? const Color(0xFF5E60CE).withValues(alpha: 0.1)
                          : const Color(0xFF10B981).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                      color: isLocked
                          ? const Color(0xFF5E60CE)
                          : const Color(0xFF10B981),
                      size: 16,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: Color(0xFF10B981),
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (isLocked)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5E60CE).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "This entry is locked. Tap to view the contents of $title...",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1E293B),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1E293B),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    content,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF475569),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: emotionColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: emotionColor.withValues(alpha: 0.25)),
              ),
              child: Text(
                emotionStr,
                style: TextStyle(
                  color: emotionColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
