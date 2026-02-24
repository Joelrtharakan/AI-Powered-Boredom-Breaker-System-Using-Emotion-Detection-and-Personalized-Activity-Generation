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

    _expansionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
      _expansionController.forward(from: 0);
    } else if (_phase == "Exhale") {
      _expansionController.reverse(from: 1);
    } else {
      // Hold - remains at 1 but pulse will affect it
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
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF1E293B),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ExcludeSemantics(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Dynamic Background Glow
              AnimatedContainer(
                duration: 2.seconds,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      _getPhaseColor().withValues(alpha: 0.12),
                      AppColors.background,
                    ],
                  ),
                ),
              ),

              // Floating particles
              ...List.generate(20, (index) => _buildFloatingParticle(index)),

              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                const Spacer(flex: 2),

                                // Phase Text
                                RepaintBoundary(
                                  child: Column(
                                    children: [
                                      Text(
                                            _phase.toUpperCase(),
                                            style: GoogleFonts.outfit(
                                              fontSize: 52,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xFF1E293B),
                                              letterSpacing: 12,
                                            ),
                                          )
                                          .animate(
                                            key: ValueKey(
                                              "phase_title_$_phase",
                                            ),
                                          )
                                          .fadeIn(duration: 800.ms)
                                          .blur(
                                            begin: const Offset(5, 5),
                                            end: Offset.zero,
                                          ),

                                      const SizedBox(height: 8),

                                      // Secondary Instruction
                                      Text(
                                            _getPhaseInstruction(),
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFFCBD5E1),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 1,
                                            ),
                                          )
                                          .animate(
                                            key: ValueKey(
                                              "phase_subtitle_$_phase",
                                            ),
                                          )
                                          .fadeIn(),
                                    ],
                                  ),
                                ),

                                const Spacer(flex: 3),

                                // The Main Visualizer
                                RepaintBoundary(
                                  child: Center(child: _buildAnimatedLungs()),
                                ),

                                const Spacer(flex: 3),

                                // Seconds counter
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white10,
                                        ),
                                      ),
                                    ),
                                    Text(
                                          "$_seconds",
                                          style: GoogleFonts.outfit(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: _getPhaseColor().withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        )
                                        .animate(key: ValueKey(_seconds))
                                        .scale(
                                          begin: const Offset(0.8, 0.8),
                                          end: const Offset(1, 1),
                                        )
                                        .fadeIn(duration: 200.ms),
                                  ],
                                ),

                                const Spacer(flex: 2),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
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
            duration: (15 + random.nextInt(10)).seconds,
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
                    color: _getPhaseColor().withValues(alpha: 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: _getPhaseColor().withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
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
        final baseScale = 1.0 + (0.6 * _expansionController.value);
        final pulseEffect = _phase == "Hold"
            ? (1.0 + 0.08 * _pulseController.value)
            : 1.0;

        final finalScale = baseScale * pulseEffect;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Orbiting Ring
            Transform.rotate(
              angle: _pulseController.value * math.pi * 2,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getPhaseColor().withValues(alpha: 0.05),
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
              ),
            ),

            // Outer Aura
            Container(
              width: 240 * finalScale,
              height: 240 * finalScale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getPhaseColor().withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
            ),

            // Core Glow
            Container(
              width: 160 * finalScale,
              height: 160 * finalScale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _getPhaseColor().withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getPhaseColor().withValues(alpha: 0.2),
                    blurRadius: 40 * finalScale,
                    spreadRadius: 10 * finalScale,
                  ),
                ],
              ),
            ),

            // The Inner Core
            Container(
              width: 80 * finalScale,
              height: 80 * finalScale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(
                  color: _getPhaseColor().withValues(alpha: 0.6),
                  width: 3,
                ),
              ),
              child: Center(
                child: Icon(
                  _getPhaseIcon(),
                  color: _getPhaseColor(),
                  size: 32 * finalScale,
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
        return Icons.expand_rounded;
      case "Hold":
        return Icons.pause_circle_filled_rounded;
      case "Exhale":
        return Icons.compress_rounded;
      default:
        return Icons.air_rounded;
    }
  }

  String _getPhaseInstruction() {
    switch (_phase) {
      case "Inhale":
        return "Fill your lungs slow";
      case "Hold":
        return "Embrace the stillness";
      case "Exhale":
        return "Release every tension";
      default:
        return "";
    }
  }
}
