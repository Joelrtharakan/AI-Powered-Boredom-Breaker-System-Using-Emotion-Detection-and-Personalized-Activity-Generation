import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReactionTimeGame extends StatefulWidget {
  const ReactionTimeGame({super.key});

  @override
  State<ReactionTimeGame> createState() => _ReactionTimeGameState();
}

class _ReactionTimeGameState extends State<ReactionTimeGame> {
  // Game states: waiting, ready, active, result
  String _state = 'waiting';
  DateTime? _startTime;
  int _reactionTime = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          "Reaction Time",
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: InkWell(
        onTap: _handleTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getIcon(), size: 80, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                _getMessage(),
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              if (_state == 'result') ...[
                const SizedBox(height: 10),
                Text(
                  "Tap to try again",
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (_state) {
      case 'ready':
        return Colors.redAccent;
      case 'active':
        return Colors.greenAccent;
      case 'result':
        return const Color(0xFF09090B);
      default:
        return const Color(0xFF09090B);
    }
  }

  IconData _getIcon() {
    switch (_state) {
      case 'waiting':
        return Icons.touch_app;
      case 'ready':
        return Icons.timelapse;
      case 'active':
        return Icons.bolt;
      case 'result':
        return Icons.timer;
      default:
        return Icons.touch_app;
    }
  }

  String _getMessage() {
    switch (_state) {
      case 'waiting':
        return "Tap to start";
      case 'ready':
        return "Wait for green...";
      case 'active':
        return "TAP NOW!";
      case 'result':
        return "$_reactionTime ms";
      case 'early':
        return "Too soon! Tap to try again.";
      default:
        return "";
    }
  }

  void _handleTap() {
    setState(() {
      if (_state == 'waiting' || _state == 'result' || _state == 'early') {
        _state = 'ready';
        Future.delayed(
          Duration(milliseconds: 1000 + (DateTime.now().millisecond % 2000)),
          () {
            if (mounted && _state == 'ready') {
              setState(() {
                _state = 'active';
                _startTime = DateTime.now();
              });
            }
          },
        );
      } else if (_state == 'ready') {
        _state = 'early';
      } else if (_state == 'active') {
        _reactionTime = DateTime.now().difference(_startTime!).inMilliseconds;
        _state = 'result';
      }
    });
  }
}
