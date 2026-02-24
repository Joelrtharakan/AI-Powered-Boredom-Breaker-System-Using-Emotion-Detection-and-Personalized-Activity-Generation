import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure OLED black
      body: Stack(
        children: [
          // Dynamic Mesh Gradient Background
          Positioned(
            top: -150,
            left: -150,
            child: const _GlowingOrb(
              color: Color(0xFF8E2DE2),
            ).animate(onPlay: (c) => c.repeat()).rotate(duration: 20.seconds),
          ),
          Positioned(
            bottom: -200,
            right: -100,
            child: const _GlowingOrb(
              color: Color(0xFF6D4EFF),
            ).animate(onPlay: (c) => c.repeat()).rotate(duration: 25.seconds),
          ),
          Positioned(
            top: size.height * 0.3,
            right: -250,
            child: const _GlowingOrb(color: Color(0xFF00C6FF))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .slideX(begin: 0, end: 0.1, duration: 8.seconds),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),

                          // Floating App Logo
                          Center(
                                child: Hero(
                                  tag: 'app_logo',
                                  child:
                                      Container(
                                            width: 140,
                                            height: 140,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(36),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF6D4EFF,
                                                  ).withValues(alpha: 0.4),
                                                  blurRadius: 40,
                                                  spreadRadius: 10,
                                                  offset: const Offset(0, 10),
                                                ),
                                                BoxShadow(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 10,
                                                  spreadRadius: -5,
                                                  offset: const Offset(0, -5),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(36),
                                              child: Image.asset(
                                                'assets/logo.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                          .animate(
                                            onPlay: (c) =>
                                                c.repeat(reverse: true),
                                          )
                                          .slideY(
                                            begin: -0.03,
                                            end: 0.03,
                                            duration: 3.seconds,
                                            curve: Curves.easeInOutSine,
                                          ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 800.ms)
                              .scale(begin: const Offset(0.8, 0.8)),

                          const Spacer(),

                          // High-Impact Typography
                          Text(
                            "Reclaim\nYour Time.",
                            style: GoogleFonts.outfit(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.0,
                              letterSpacing: -2,
                            ),
                          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

                          const SizedBox(height: 16),

                          Text(
                            "Break the doom-scrolling loop and dive into curated games, ambient music, and AI-guided mental clarity.",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white70,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),

                          const SizedBox(height: 48),

                          // Modern Buttons Layout
                          Row(
                            children: [
                              Expanded(
                                child: _buildPrimaryButton(
                                  context,
                                  "Get Started",
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildSecondaryButton(
                                  context,
                                  "I already have an account",
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E2DE2).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _GlowingOrb extends StatelessWidget {
  final Color color;
  const _GlowingOrb({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 500,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.1, 0.5, 1.0],
        ),
      ),
    );
  }
}
