import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/session_manager.dart';
import 'write_journal_screen.dart'; // Ensure it's in the same directory

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Mindful Journal",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1E293B),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF1E293B),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: const Color(0xFF64748B),
            ),
            onPressed: _fetchEntries,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _entries.isEmpty
          ? Center(
              child: Text(
                "No journal entries yet.\nStart writing now!",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                return _buildJournalEntry(
                  _entries[index],
                  index,
                ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
              },
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: AppColors.primaryGradient),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final value = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WriteJournalScreen()),
            );
            if (value == true) {
              _fetchEntries();
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: Text(
            "Write Entry",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.edit_note_rounded),
        ),
      ),
    );
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
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF1E293B).withOpacity(0.05)),
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
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isEncrypted)
                  Icon(
                    isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                    color: isLocked ? AppColors.primary : Colors.tealAccent,
                    size: 18,
                  )
                else
                  const Icon(
                    Icons.verified_user_rounded,
                    color: Colors.tealAccent,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLocked)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: const Color(0xFF1E293B).withOpacity(0.05),
                    child: Text(
                      "This entry is locked. Tap to view the contents of $title...",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1E293B),
                        fontSize: 16,
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
                      color: const Color(0xFF1E293B),
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: emotionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: emotionColor.withOpacity(0.3)),
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
