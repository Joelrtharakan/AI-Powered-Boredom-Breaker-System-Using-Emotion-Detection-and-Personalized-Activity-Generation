import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class VoiceModeScreen extends StatefulWidget {
  const VoiceModeScreen({super.key});

  @override
  State<VoiceModeScreen> createState() => _VoiceModeScreenState();
}

class _VoiceModeScreenState extends State<VoiceModeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isListening = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Voice Mode",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 24,
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
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: 100,
            left: -100,
            child: _GlowDisk(color: AppColors.primary.withValues(alpha: 0.1)),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Pulsing Mic
                GestureDetector(
                  onTap: () => setState(() => _isListening = !_isListening),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      double scale = 1.0 + (_pulseController.value * 0.2);
                      double opacity = 0.2 - (_pulseController.value * 0.1);

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isListening) ...[
                            _MicAura(
                              scale: scale * 1.5,
                              opacity: opacity * 0.5,
                            ),
                            _MicAura(scale: scale * 1.2, opacity: opacity),
                          ],
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _isListening
                                    ? AppColors.primaryGradient
                                    : [
                                        Colors.grey.shade800,
                                        Colors.grey.shade900,
                                      ],
                              ),
                              boxShadow: [
                                if (_isListening)
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                              ],
                            ),
                            child: Icon(
                              _isListening
                                  ? Icons.mic_rounded
                                  : Icons.mic_off_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 60),

                Text(
                      _isListening ? "Listening..." : "Paused",
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                    .animate(target: _isListening ? 1 : 0)
                    .shimmer(duration: 2.seconds),

                const SizedBox(height: 16),

                Text(
                  "Speak freely. I'm here to listen.",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),

                const Spacer(flex: 3),

                // Transcription Placeholder
                if (_isListening)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Text(
                      "\"I've been feeling a bit overwhelmed lately with work and was looking for something to relax...\"",
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        elevation: 0,
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 36),
      ).animate().scale(delay: 1.seconds),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _MicAura extends StatelessWidget {
  final double scale;
  final double opacity;
  const _MicAura({required this.scale, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _GlowDisk extends StatelessWidget {
  final Color color;
  const _GlowDisk({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 150, spreadRadius: 50)],
      ),
    );
  }
}
