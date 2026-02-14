import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

class BubblePopGameScreen extends StatefulWidget {
  const BubblePopGameScreen({super.key});

  @override
  State<BubblePopGameScreen> createState() => _BubblePopGameScreenState();
}

class _BubblePopGameScreenState extends State<BubblePopGameScreen>
    with TickerProviderStateMixin {
  // Game State
  List<Bubble> bubbles = [];
  int score = 0;

  // Animation Controller for continuous spawning
  late AnimationController _spawnerController;

  @override
  void initState() {
    super.initState();

    // Spawn initial bubbles
    for (int i = 0; i < 15; i++) {
      _spawnBubble();
    }

    // Continuously spawn new bubbles to keep screen full
    _spawnerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _spawnerController.addListener(() {
      if (bubbles.length < 20 && Random().nextDouble() < 0.05) {
        if (mounted) {
          setState(() {
            _spawnBubble();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _spawnerController.dispose();
    super.dispose();
  }

  void _spawnBubble() {
    // Generate relative positions (0.1 to 0.9) to keep away from extreme edges initially
    final xRel = 0.05 + Random().nextDouble() * 0.8;
    final yRel = 0.05 + Random().nextDouble() * 0.8;

    final size = Random().nextDouble() * 40 + 60; // 60-100 size

    final color = [
      Colors.cyanAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.amberAccent,
      Colors.greenAccent,
    ][Random().nextInt(5)];

    bubbles.add(
      Bubble(
        id:
            DateTime.now().microsecondsSinceEpoch.toString() +
            Random().nextInt(1000).toString(),
        xRel: xRel,
        yRel: yRel,
        size: size,
        color: color,
      ),
    );
  }

  void _popBubble(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      bubbles.removeWhere((b) => b.id == id);
      score++;
      // Spawn a new one immediately to replace
      _spawnBubble();
    });
  }

  void _resetGame() {
    setState(() {
      bubbles.clear();
      score = 0;
      for (int i = 0; i < 15; i++) {
        _spawnBubble();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        title: Text(
          "Bubble Pop",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child:
                  Text(
                        "Popped: $score",
                        style: GoogleFonts.spaceMono(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      .animate(key: ValueKey(score))
                      .scale(duration: 100.ms, curve: Curves.easeOutBack),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Bubbles Area
              ...bubbles.map((bubble) {
                // Calculate actual position based on container size
                // We use relative positioning to ensure it works on any screen size without MediaQuery crashes
                final left = bubble.xRel * (constraints.maxWidth - bubble.size);
                final top = bubble.yRel * (constraints.maxHeight - bubble.size);

                return Positioned(
                  left: left,
                  top: top,
                  child: GestureDetector(
                    onTap: () => _popBubble(bubble.id),
                    child:
                        AnimatedContainer(
                              duration: 500.ms,
                              curve: Curves.easeOutBack,
                              width: bubble.size,
                              height: bubble.size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    bubble.color.withOpacity(0.3),
                                    bubble.color.withOpacity(0.1),
                                  ],
                                  stops: const [0.3, 1.0],
                                ),
                                border: Border.all(
                                  color: bubble.color.withOpacity(0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: bubble.color.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: bubble.size * 0.3,
                                  height: bubble.size * 0.2,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.all(
                                      Radius.elliptical(
                                        bubble.size,
                                        bubble.size * 0.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .scale(
                              begin: const Offset(0, 0),
                              duration: 400.ms,
                              curve: Curves.easeOutBack,
                            )
                            .shimmer(
                              duration: 2.seconds,
                              delay: Random().nextInt(2000).ms,
                            ),
                  ),
                );
              }).toList(),

              // Bottom Hint
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child:
                      Text(
                            "Pop stress away...",
                            style: GoogleFonts.outfit(
                              color: Colors.white30,
                              fontSize: 18,
                              letterSpacing: 2,
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .fadeIn(duration: 2.seconds),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetGame,
        backgroundColor: Colors.white10,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}

class Bubble {
  final String id;
  final double xRel; // Relative X position (0.0 to 1.0)
  final double yRel; // Relative Y position (0.0 to 1.0)
  final double size;
  final Color color;

  Bubble({
    required this.id,
    required this.xRel,
    required this.yRel,
    required this.size,
    required this.color,
  });
}
