import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/session_manager.dart';
import 'write_journal_screen.dart';

/// Custom page route for the Journal screen with a smooth
/// slide-up + fade + scale transition on enter, and slide-down on exit.
class JournalPageRoute extends PageRouteBuilder {
  JournalPageRoute()
    : super(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const JournalScreen(),
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Curved animations for buttery feel
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          // Slide from bottom
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curvedAnimation);

          // Fade
          final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
            ),
          );

          // Subtle scale
          final scaleAnimation = Tween<double>(
            begin: 0.96,
            end: 1.0,
          ).animate(curvedAnimation);

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: ScaleTransition(scale: scaleAnimation, child: child),
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

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _entries = [];
  final Set<int> _unlockedEntries = {};

  late AnimationController _entranceController;
  late Animation<double> _gradientSlide;
  late Animation<double> _sheetSlide;
  late Animation<double> _headerFade;
  late Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();

    // Master entrance animation controller
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Gradient header slides down from top
    _gradientSlide = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // White sheet slides up from bottom
    _sheetSlide = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Header text fades in
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    // Content fades in after sheet arrives
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _entranceController.forward();
    _fetchEntries();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
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

  /// Animate out then pop
  Future<void> _animateOut() async {
    await _entranceController.reverse();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          _animateOut();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AnimatedBuilder(
          animation: _entranceController,
          builder: (context, child) {
            return Stack(
              children: [
                // 1. Vibrant Gradient Background — slides down from top
                Positioned(
                  top: _gradientSlide.value * size.height * 0.28,
                  left: 0,
                  right: 0,
                  height: size.height * 0.28,
                  child: Opacity(
                    opacity: _headerFade.value.clamp(0.0, 1.0),
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
                          // Decorative circles
                          Positioned(
                            top: 40,
                            right: -40,
                            child: _buildCircle(120, 0.1),
                          ),
                          Positioned(
                            top: 100,
                            left: -30,
                            child: _buildCircle(80, 0.15),
                          ),
                          Positioned(
                            bottom: 20,
                            right: 60,
                            child: _buildCircle(50, 0.08),
                          ),

                          // Header content
                          SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: FadeTransition(
                                opacity: _headerFade,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.arrow_back_ios_new_rounded,
                                            color: Colors.white,
                                          ),
                                          onPressed: _animateOut,
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(-0.15, 0),
                                              end: Offset.zero,
                                            ).animate(_headerFade),
                                            child: Text(
                                              "Mindful Journal",
                                              style: GoogleFonts.outfit(
                                                fontSize: 30,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(-0.2, 0),
                                              end: Offset.zero,
                                            ).animate(_headerFade),
                                            child: Text(
                                              "Capture your thoughts & emotions",
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. White content sheet — slides up from bottom
                Positioned(
                  top:
                      size.height * 0.24 +
                      (_sheetSlide.value * size.height * 0.76),
                  left: 0,
                  right: 0,
                  bottom: math.min(0, -_sheetSlide.value * size.height * 0.76),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.08 * _contentFade.value,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: _buildContent(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // FAB with gradient
        floatingActionButton: AnimatedBuilder(
          animation: _contentFade,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 60 * (1 - _contentFade.value)),
              child: Opacity(
                opacity: _contentFade.value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: Container(
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
                    transitionDuration: const Duration(milliseconds: 500),
                    reverseTransitionDuration: const Duration(
                      milliseconds: 400,
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          final curved = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                            reverseCurve: Curves.easeInCubic,
                          );
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(curved),
                            child: FadeTransition(
                              opacity: curved,
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
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(double size, double alpha) {
    return Container(
      width: size,
      height: size,
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
        // Staggered item entrance — each card slides up with a delay
        return _buildJournalEntry(_entries[index], index)
            .animate()
            .fadeIn(
              delay: (150 + index * 80).ms,
              duration: 400.ms,
              curve: Curves.easeOut,
            )
            .slideY(
              begin: 0.12,
              delay: (150 + index * 80).ms,
              duration: 500.ms,
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
