import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Mindful Journal",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: 4, // Dummy Data
        itemBuilder: (context, index) {
          return _buildJournalEntry(
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
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {},
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

  Widget _buildJournalEntry(int index) {
    final dates = ["Feb 12", "Feb 10", "Feb 08", "Feb 05"];
    final moods = ["Relieved", "Anxious", "Inspired", "Bored"];
    final colors = [
      Colors.tealAccent,
      Colors.orangeAccent,
      AppColors.secondary,
      Colors.blueGrey,
    ];
    final texts = [
      "Finally finished the big project. The AI breathing exercises really helped maintain my focus during the final push.",
      "A bit nervous about tomorrow's presentation. Trying to stay grounded and not overthink.",
      "Had a sudden burst of creativity after using the Sonic Therapy mode. Wrote down two new app ideas.",
      "The usual routine is getting a bit old. Need to find a new hobby or something to break the loop.",
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dates[index],
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(
                Icons.verified_user_rounded,
                color: Colors.tealAccent,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            texts[index],
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors[index].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors[index].withValues(alpha: 0.3)),
            ),
            child: Text(
              moods[index],
              style: TextStyle(
                color: colors[index],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
