import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/games_api.dart';

class AimTrainerScreen extends StatefulWidget {
  const AimTrainerScreen({super.key});

  @override
  State<AimTrainerScreen> createState() => _AimTrainerScreenState();
}

class _AimTrainerScreenState extends State<AimTrainerScreen> {
  int _score = 0;
  int _timeLeft = 30;
  bool _isPlaying = false;
  bool _gameStarted = false; // Instruction mode
  Timer? _timer;
  Offset _targetPos = const Offset(0.5, 0.5);
  final Random _random = Random();

  // Stats
  int _totalClicks = 0;
  int _hits = 0;

  // Design Config
  final Color _crosshairColor = const Color(0xFF10B981); // Emerald Green
  final Color _targetColor = const Color(0xFFFF0055); // Cyber Red

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _timer?.cancel(); // Safety cleanup
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isPlaying = true;
      _totalClicks = 0;
      _hits = 0;
      _spawnTarget();
      _gameStarted = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    _isPlaying = false;
    _timer?.cancel();
    GamesApi.submitScore('aim_trainer', _score);
    _showResultDialog();
  }

  void _spawnTarget() {
    // Keep target nicely within bounds (padding 15%)
    double padding = 0.15;
    setState(() {
      _targetPos = Offset(
        padding + _random.nextDouble() * (1.0 - 2 * padding),
        padding + _random.nextDouble() * (1.0 - 2 * padding),
      );
    });
  }

  void _handleHit(bool hit) {
    if (!_isPlaying) return;

    setState(() {
      _totalClicks++;
      if (hit) {
        _hits++;
        _score += 100 + (_hits * 5); // Combo bonus logic
        _spawnTarget();
      } else {
        _score -= 50; // Penalty for miss
        if (_score < 0) _score = 0;
      }
    });
  }

  double get _accuracy => _totalClicks == 0 ? 0 : (_hits / _totalClicks * 100);

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _crosshairColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _crosshairColor.withValues(alpha: 0.05),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "MISSION COMPLETE",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),

              _buildResultRow("SCORE", "$_score", _crosshairColor),
              _buildResultRow(
                "ACCURACY",
                "${_accuracy.toStringAsFixed(1)}%",
                const Color(0xFF1E293B),
              ),
              _buildResultRow(
                "HITS",
                "$_hits / $_totalClicks",
                const Color(0xFF64748B),
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // Pop dialog
                        Navigator.pop(context); // Pop screen
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "EXIT",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _startGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _crosshairColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "REDEPLOY",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.spaceMono(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Tactical Grid Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
                  radius: 1.5,
                ),
              ),
              child: Opacity(
                opacity: 0.1,
                child: Image.network(
                  "https://www.transparenttextures.com/patterns/diagmonds-light.png",
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),

          SafeArea(
            child: !_gameStarted ? _buildInstructions() : _buildGameLayer(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameLayer() {
    return Stack(
      children: [
        // 2. Interaction Layer
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (_) => _handleHit(false), // Miss tap
            child: Stack(
              children: [
                // Target Layer
                if (_isPlaying)
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double x = _targetPos.dx * constraints.maxWidth;
                        final double y = _targetPos.dy * constraints.maxHeight;

                        return Stack(
                          children: [
                            Positioned(
                              left: x - 40, // Center 80px target
                              top: y - 40,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapDown: (_) => _handleHit(true), // Hit tap
                                child:
                                    Container(
                                          width: 80,
                                          height: 80,
                                          decoration: const BoxDecoration(
                                            color: Colors.transparent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Outer Ring
                                              Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: _targetColor
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                        width: 2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: _targetColor
                                                              .withValues(
                                                                alpha: 0.3,
                                                              ),
                                                          blurRadius: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  .animate(
                                                    onPlay: (c) =>
                                                        c.repeat(reverse: true),
                                                  )
                                                  .scale(
                                                    begin: const Offset(1, 1),
                                                    end: const Offset(1.1, 1.1),
                                                    duration: 500.ms,
                                                  ),

                                              // Bullseye
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: _targetColor,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: _targetColor,
                                                      blurRadius: 10,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        .animate(key: ValueKey(_totalClicks))
                                        .scale(
                                          duration: 100.ms,
                                          curve: Curves.easeOutBack,
                                        ), // Pop in animation
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                // Crosshair Overlay (Decoration)
                Center(
                  child: IgnorePointer(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 2,
                          height: 2,
                          color: const Color(0xFF1E293B).withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. HUD Layer (Stats + Close Button)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Exit Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF1E293B),
                      size: 20,
                    ),
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.pop(context);
                    },
                  ),
                ),

                // Stats
                Row(
                  children: [
                    _buildHUDStat(
                      "TIME",
                      "00:${_timeLeft.toString().padLeft(2, '0')}",
                      const Color(0xFF1E293B),
                    ),
                    const SizedBox(width: 8),
                    _buildHUDStat("SCORE", "$_score", _crosshairColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHUDStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.spaceMono(
              color: const Color(0xFF94A3B8),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.spaceMono(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _crosshairColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _crosshairColor.withValues(alpha: 0.2),
                    blurRadius: 50,
                  ),
                ],
              ),
              child: Icon(
                Icons.gps_fixed_rounded,
                color: _crosshairColor,
                size: 60,
              ),
            ).animate().scale(duration: 1.seconds, curve: Curves.elasticOut),

            const SizedBox(height: 32),

            Text(
              "AIM TRAINER",
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E293B),
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 8),
            Text(
              "Speed & Precision Protocol",
              style: GoogleFonts.spaceMono(
                color: _crosshairColor,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 48),

            _buildInstructionRow(
              Icons.touch_app_rounded,
              "Tap targets quickly.",
              _crosshairColor,
            ),
            _buildInstructionRow(
              Icons.timer,
              "30 Seconds on the clock.",
              const Color(0xFF1E293B),
            ),
            _buildInstructionRow(
              Icons.not_interested,
              "Misses reduce score.",
              Colors.redAccent,
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _crosshairColor,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 10,
                    shadowColor: _crosshairColor.withValues(alpha: 0.4),
                  ),
                  child: Text(
                    "INITIATE SEQUENCE",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "ABORT MISSION",
                style: GoogleFonts.spaceMono(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Text(
            text,
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
