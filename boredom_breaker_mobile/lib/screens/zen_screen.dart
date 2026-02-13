import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ZenScreen extends StatefulWidget {
  const ZenScreen({super.key});

  @override
  State<ZenScreen> createState() => _ZenScreenState();
}

class _ZenScreenState extends State<ZenScreen> with TickerProviderStateMixin {
  late AnimationController _expansionController;
  late AnimationController _pulseController;
  String _phase = "Inhale";
  int _seconds = 4;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Main expansion/contraction
    _expansionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Subtle pulse for the "Hold" phase
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _startBreathingCycle();
    _handleAnimationForPhase();
  }

  void _startBreathingCycle() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_seconds > 1) {
          _seconds--;
        } else {
          if (_phase == "Inhale") {
            _phase = "Hold";
            _seconds = 4;
          } else if (_phase == "Hold") {
            _phase = "Exhale";
            _seconds = 4;
          } else {
            _phase = "Inhale";
            _seconds = 4;
          }
          _handleAnimationForPhase();
        }
      });
    });
  }

  void _handleAnimationForPhase() {
    if (_phase == "Inhale") {
      _expansionController.forward();
    } else if (_phase == "Exhale") {
      _expansionController.reverse();
    } else {
      // Hold - keep expanded but could add a tiny pulse
    }
  }

  @override
  void dispose() {
    _expansionController.dispose();
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Zen Mode",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [_getPhaseColor().withOpacity(0.15), AppColors.background],
          ),
        ),
        child: Stack(
          children: [
            // Floating particles / stars
            ...List.generate(15, (index) => _buildFloatingParticle(index)),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Phase Text with unique animation
                  Text(
                        _phase,
                        style: GoogleFonts.outfit(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 8,
                        ),
                      )
                      .animate(key: ValueKey(_phase))
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.2, end: 0)
                      .blur(begin: const Offset(10, 10), end: Offset.zero),

                  const SizedBox(height: 12),

                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      bool active = (4 - _seconds) > index;
                      return AnimatedContainer(
                        duration: 300.ms,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? _getPhaseColor() : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 100),

                  // The "Lungs" Visualizer
                  _buildAnimatedLungs(),

                  const SizedBox(height: 120),

                  Text(
                    _getPhaseInstruction(),
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ).animate(key: ValueKey(_phase)).fadeIn().scale(),

                  const SizedBox(height: 40),

                  Text(
                    "$_seconds",
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = math.Random(index);
    final size = random.nextDouble() * 4 + 2;
    final startAlignment = Alignment(
      random.nextDouble() * 2 - 1,
      random.nextDouble() * 2 - 1,
    );

    return Positioned.fill(
      child: Container()
          .animate(onPlay: (c) => c.repeat())
          .custom(
            duration: (10 + random.nextInt(10)).seconds,
            builder: (context, value, child) {
              return Align(
                alignment: Alignment(
                  startAlignment.x + math.sin(value * math.pi * 2) * 0.1,
                  startAlignment.y + math.cos(value * math.pi * 2) * 0.1,
                ),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getPhaseColor().withOpacity(0.3),
                    boxShadow: [
                      BoxShadow(
                        color: _getPhaseColor().withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildAnimatedLungs() {
    return AnimatedBuilder(
      animation: Listenable.merge([_expansionController, _pulseController]),
      builder: (context, child) {
        final scale = 1.0 + (0.6 * _expansionController.value);
        final pulse = _phase == "Hold"
            ? (1.0 + 0.05 * _pulseController.value)
            : 1.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Aura 2
            Container(
              width: 260 * scale * pulse,
              height: 260 * scale * pulse,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getPhaseColor().withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            // Outer Aura 1
            Container(
              width: 220 * scale * pulse,
              height: 220 * scale * pulse,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getPhaseColor().withOpacity(0.1),
                  width: 2,
                ),
              ),
            ),
            // Main Gradient Glow
            Container(
              width: 180 * scale * pulse,
              height: 180 * scale * pulse,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _getPhaseColor().withOpacity(
                      0.4 * _expansionController.value + 0.1,
                    ),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getPhaseColor().withOpacity(
                      0.2 * _expansionController.value,
                    ),
                    blurRadius: 50,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
            // The Core
            Container(
              width: 100 * scale * pulse,
              height: 100 * scale * pulse,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(
                  color: _getPhaseColor().withOpacity(0.6),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getPhaseColor().withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _getPhaseIcon(),
                  color: _getPhaseColor(),
                  size: 40 * scale,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getPhaseColor() {
    switch (_phase) {
      case "Inhale":
        return Colors.cyanAccent;
      case "Hold":
        return Colors.amberAccent;
      case "Exhale":
        return Colors.pinkAccent;
      default:
        return AppColors.primary;
    }
  }

  IconData _getPhaseIcon() {
    switch (_phase) {
      case "Inhale":
        return Icons.arrow_upward_rounded;
      case "Hold":
        return Icons.pause_rounded;
      case "Exhale":
        return Icons.arrow_downward_rounded;
      default:
        return Icons.air_rounded;
    }
  }

  String _getPhaseInstruction() {
    switch (_phase) {
      case "Inhale":
        return "Take a deep breath in";
      case "Hold":
        return "Hold and feel the stillness";
      case "Exhale":
        return "Slowly let it all out";
      default:
        return "Focus on the rhythm";
    }
  }
}
