import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class MemoryFlipScreen extends StatefulWidget {
  const MemoryFlipScreen({super.key});

  @override
  State<MemoryFlipScreen> createState() => _MemoryFlipScreenState();
}

class _MemoryFlipScreenState extends State<MemoryFlipScreen> {
  final List<String> _emojis = ['🎮', '⚡', '🌈', '🌙', '🍕', '🚀', '💎', '🎨'];
  late List<String> _cards;
  late List<bool> _flipped;
  late List<bool> _solved;
  int? _firstIndex;
  int _moves = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    setState(() {
      _cards = [..._emojis, ..._emojis]..shuffle();
      _flipped = List.filled(16, false);
      _solved = List.filled(16, false);
      _moves = 0;
      _firstIndex = null;
      _busy = false;
    });
  }

  void _handleTap(int index) {
    if (_busy || _flipped[index] || _solved[index]) return;

    setState(() {
      _flipped[index] = true;
    });

    if (_firstIndex == null) {
      _firstIndex = index;
    } else {
      _moves++;
      if (_cards[_firstIndex!] == _cards[index]) {
        // Match!
        setState(() {
          _solved[_firstIndex!] = true;
          _solved[index] = true;
          _firstIndex = null;
        });
        if (_solved.every((e) => e)) {
          _showWinDialog();
        }
      } else {
        // No Match
        _busy = true;
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          setState(() {
            _flipped[_firstIndex!] = false;
            _flipped[index] = false;
            _firstIndex = null;
            _busy = false;
          });
        });
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          "Victory!",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 60,
              color: Colors.amberAccent,
            ),
            const SizedBox(height: 16),
            Text(
              "Solved in $_moves moves",
              style: GoogleFonts.inter(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeGame();
            },
            child: Text(
              "Play Again",
              style: GoogleFonts.outfit(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              "Close",
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Memory Flip",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                "Moves: $_moves",
                style: GoogleFonts.outfit(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Find all pairs to win!",
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    bool isRevealed = _flipped[index] || _solved[index];
                    return GestureDetector(
                      onTap: () => _handleTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isRevealed
                              ? Colors.white
                              : AppColors.surface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          boxShadow: [
                            if (isRevealed)
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.1),
                                blurRadius: 10,
                              ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isRevealed ? _cards[index] : "?",
                            style: GoogleFonts.outfit(
                              fontSize: isRevealed ? 32 : 24,
                              fontWeight: FontWeight.bold,
                              color: isRevealed ? null : Colors.white24,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 56),
              TextButton(
                onPressed: _initializeGame,
                child: Text(
                  "Reset Game",
                  style: GoogleFonts.inter(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
