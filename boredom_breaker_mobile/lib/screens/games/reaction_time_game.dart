import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/games_api.dart';

class ReactionTimeGame extends StatefulWidget {
  const ReactionTimeGame({super.key});

  @override
  State<ReactionTimeGame> createState() => _ReactionTimeGameState();
}

class _ReactionTimeGameState extends State<ReactionTimeGame> {
  // Game states: waiting, ready (red), active (green), result, early
  String _state = 'idle'; // idle = waiting to start
  DateTime? _startTime;
  int _lastTime = 0;
  final List<int> _history = [];
  bool _gameStarted = false; // Instructions overlay
  Timer? _waitTimer;

  final Color _idleColor = const Color(0xFFF8FAFC); // Light Slate 50
  final Color _readyColor = const Color(0xFFEF4444); // Red 500
  final Color _activeColor = const Color(0xFF22C55E); // Green 500
  final Color _earlyColor = const Color(0xFFF59E0B); // Amber 500 (Warning)
  final Color _resultColor = const Color(0xFF3B82F6); // Blue 500

  @override
  void dispose() {
    _waitTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _resetRound();
    });
  }

  void _resetRound() {
    setState(() {
      _state = 'idle';
    });
  }

  void _handleTap() {
    if (!_gameStarted) return;

    setState(() {
      if (_state == 'idle' || _state == 'result' || _state == 'early') {
        // Start waiting (Red screen)
        _state = 'ready';
        _waitTimer?.cancel();

        // Random delay between 1.5s and 4.5s
        int delay = 1500 + Random().nextInt(3000);

        _waitTimer = Timer(Duration(milliseconds: delay), () {
          if (mounted && _state == 'ready') {
            setState(() {
              _state = 'active';
              _startTime = DateTime.now();
            });
          }
        });
      } else if (_state == 'ready') {
        // Early tap
        _waitTimer?.cancel();
        _state = 'early';
      } else if (_state == 'active') {
        // Successful reaction
        final now = DateTime.now();
        if (_startTime != null) {
          _lastTime = now.difference(_startTime!).inMilliseconds;
          _history.insert(0, _lastTime);
          if (_history.length > 5) _history.removeLast();
          GamesApi.submitScore('reaction', _lastTime);
          _state = 'result';
        }
      }
    });
  }

  Color _getBackgroundColor() {
    switch (_state) {
      case 'idle':
        return _idleColor;
      case 'ready':
        return _readyColor;
      case 'active':
        return _activeColor;
      case 'early':
        return _earlyColor;
      case 'result':
        return _resultColor;
      default:
        return _idleColor;
    }
  }

  IconData _getIcon() {
    switch (_state) {
      case 'idle':
        return Icons.touch_app_rounded;
      case 'ready':
        return Icons.more_horiz_rounded;
      case 'active':
        return Icons.flash_on_rounded;
      case 'early':
        return Icons.warning_rounded;
      case 'result':
        return Icons.timer_rounded;
      default:
        return Icons.touch_app;
    }
  }

  String _getMessage() {
    switch (_state) {
      case 'idle':
        return "Tap to Start";
      case 'ready':
        return "Wait for Green...";
      case 'active':
        return "CLICK!";
      case 'early':
        return "Too Soon!";
      case 'result':
        return "$_lastTime ms";
      default:
        return "";
    }
  }

  String _getSubMessage() {
    switch (_state) {
      case 'idle':
        return "When screen turns red, wait for green.";
      case 'ready':
        return "Keep steady...";
      case 'active':
        return "";
      case 'early':
        return "Wait for the green color.";
      case 'result':
        return "Tap to try again";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _gameStarted ? _getBackgroundColor() : _idleColor,
      body: Stack(
        children: [
          // Game Layer
          if (_gameStarted)
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (_) => _handleTap(),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: _getBackgroundColor(),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                              _getIcon(),
                              size: 100,
                              color: _state == 'idle'
                                  ? const Color(
                                      0xFF1E293B,
                                    ).withValues(alpha: 0.9)
                                  : Colors.white,
                            )
                            .animate(target: _state == 'active' ? 1 : 0)
                            .scale(duration: 100.ms, curve: Curves.easeOutBack),

                        const SizedBox(height: 32),

                        Text(
                          _getMessage(),
                          style: GoogleFonts.outfit(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: _state == 'idle'
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            letterSpacing: -1,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        if (_getSubMessage().isNotEmpty)
                          Text(
                            _getSubMessage(),
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              color: _state == 'idle'
                                  ? const Color(0xFF64748B)
                                  : Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                        if (_state == 'result' || _state == 'idle') ...[
                          const SizedBox(height: 60),
                          _buildHistory(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Instructions overlay
          if (!_gameStarted) _buildInstructions(),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              // Use GestureDetector to ensure tap works
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF1E293B),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    if (_history.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          "RECENT SCORES",
          style: GoogleFonts.spaceMono(
            fontSize: 12,
            color: const Color(0xFF64748B),
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: _history
              .map(
                (t) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "$t ms",
                    style: GoogleFonts.spaceMono(
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Colors.blueAccent.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.05),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.flash_on_rounded,
                  color: Colors.blueAccent,
                  size: 64,
                ),
              ).animate().scale(duration: 1.seconds, curve: Curves.elasticOut),

              const SizedBox(height: 32),

              Text(
                "REACTION TEST",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 48),

              _buildInstructionRow(
                Icons.touch_app_rounded,
                "Tap to start the test.",
              ),
              _buildInstructionRow(
                Icons.palette_rounded,
                "Wait for Red to turn GREEN.",
              ),
              _buildInstructionRow(
                Icons.timer_rounded,
                "Tap immediately when Green!",
              ),

              const SizedBox(height: 60),

              SizedBox(
                width: double.infinity,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Colors.blueAccent.withValues(alpha: 0.4),
                    ),
                    child: Text(
                      "START TEST",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: const Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
