import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/session_manager.dart';
import '../../services/api_client.dart';

class WriteJournalScreen extends StatefulWidget {
  const WriteJournalScreen({super.key});

  @override
  State<WriteJournalScreen> createState() => _WriteJournalScreenState();
}

class _WriteJournalScreenState extends State<WriteJournalScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isEncrypted = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Title and Content cannot be empty",
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        throw Exception("User ID not found");
      }

      await ApiClient().client.post(
        '/journal/create',
        data: {
          'user_id': userId,
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'is_encrypted': _isEncrypted,
        },
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to save entry: $e",
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Vibrant Gradient Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.22,
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
                    top: 30,
                    right: -30,
                    child:
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ).animate().scale(
                          duration: 1.seconds,
                          curve: Curves.easeOutBack,
                        ),
                  ),
                  Positioned(
                    top: 80,
                    left: -20,
                    child:
                        Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            )
                            .animate(delay: 200.ms)
                            .scale(
                              duration: 1.seconds,
                              curve: Curves.easeOutBack,
                            ),
                  ),

                  // Header content
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              _isSaving
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      onPressed: _saveEntry,
                                    ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child:
                                Text(
                                      "New Entry",
                                      style: GoogleFonts.outfit(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 200.ms)
                                    .slideX(begin: -0.1),
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
            top: size.height * 0.18,
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                  child: Column(
                    children: [
                      // Privacy toggle card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF5E60CE,
                              ).withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _isEncrypted
                                        ? const Color(
                                            0xFF5E60CE,
                                          ).withValues(alpha: 0.1)
                                        : const Color(
                                            0xFF94A3B8,
                                          ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _isEncrypted
                                        ? Icons.lock_rounded
                                        : Icons.lock_open_rounded,
                                    color: _isEncrypted
                                        ? const Color(0xFF5E60CE)
                                        : const Color(0xFF94A3B8),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Privacy Protected",
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF1E293B),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _isEncrypted,
                              onChanged: (val) {
                                setState(() {
                                  _isEncrypted = val;
                                });
                              },
                              activeThumbColor: const Color(0xFF5E60CE),
                              activeTrackColor: const Color(
                                0xFF5E60CE,
                              ).withValues(alpha: 0.3),
                              inactiveThumbColor: const Color(0xFF94A3B8),
                              inactiveTrackColor: const Color(
                                0xFF94A3B8,
                              ).withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),

                      const SizedBox(height: 28),

                      // Title field
                      TextField(
                        controller: _titleController,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1E293B),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: "Title...",
                          hintStyle: GoogleFonts.outfit(
                            color: const Color(0xFFCBD5E1),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                      ),

                      // Subtle divider
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF5E60CE).withValues(alpha: 0.2),
                              const Color(0xFF4EA8DE).withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Content field
                      TextField(
                        controller: _contentController,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF334155),
                          fontSize: 17,
                          height: 1.7,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "How are you feeling?",
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFFCBD5E1),
                            fontSize: 17,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
