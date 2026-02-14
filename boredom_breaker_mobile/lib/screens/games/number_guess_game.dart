import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class NumberGuessGame extends StatefulWidget {
  const NumberGuessGame({super.key});

  @override
  State<NumberGuessGame> createState() => _NumberGuessGameState();
}

class _NumberGuessGameState extends State<NumberGuessGame> {
  final TextEditingController _controller = TextEditingController();
  late int _targetNumber = Random().nextInt(100) + 1;
  String _message = "Guess a number between 1 and 100";
  List<int> _history = [];
  String _status = 'neutral'; // neutral, low, high, win
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _targetNumber = Random().nextInt(100) + 1;
      _message = "Guess a number between 1 and 100";
      _history = [];
      _status = 'neutral';
      _attempts = 0;
      _controller.clear();
    });
  }

  void _handleGuess() {
    final text = _controller.text;
    if (text.isEmpty) return;

    final guess = int.tryParse(text);
    if (guess == null) {
      setState(() {
        _message = "Please enter a valid number";
        _status = 'neutral';
      });
      return;
    }

    setState(() {
      _history.insert(0, guess); // Add to history
      _attempts++;

      if (guess == _targetNumber) {
        _message = "🎉 Correct! You won!";
        _status = 'win';
      } else if (guess < _targetNumber) {
        _message = "Too Low 📉 try higher";
        _status = 'low';
      } else {
        _message = "Too High 📈 try lower";
        _status = 'high';
      }
      _controller.clear();
    });
  }

  Color _getStatusColor() {
    switch (_status) {
      case 'win':
        return Colors.greenAccent;
      case 'low':
        return Colors.blueAccent;
      case 'high':
        return Colors.orangeAccent;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        title: Text(
          "Number Guess",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Status Card
            Container(
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: _status == 'neutral'
                      ? Colors.white10
                      : _getStatusColor().withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                        _message,
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _status == 'neutral'
                              ? Colors.white
                              : _getStatusColor(),
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate(key: ValueKey(_message))
                      .fadeIn()
                      .scale(duration: 200.ms),

                  if (_status == 'win')
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        "Attempts: $_attempts",
                        style: GoogleFonts.inter(color: Colors.white60),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Input Section
            if (_status != 'win') ...[
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "#",
                  hintStyle: const TextStyle(color: Colors.white12),
                  contentPadding: const EdgeInsets.symmetric(vertical: 24),
                ),
                onSubmitted: (_) => _handleGuess(),
                autofocus: true,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleGuess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Check",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    "Play Again",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ).animate().scale(curve: Curves.elasticOut),

            const SizedBox(height: 48),

            // History Section
            if (_history.isNotEmpty) ...[
              Text(
                "HISTORY",
                style: GoogleFonts.inter(
                  color: Colors.white30,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _history.map((h) {
                  final isLow = h < _targetNumber;
                  final color = isLow ? Colors.blueAccent : Colors.orangeAccent;
                  final icon = isLow
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$h",
                          style: GoogleFonts.spaceMono(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(icon, color: color, size: 16),
                      ],
                    ),
                  ).animate().scale(
                    duration: 200.ms,
                    curve: Curves.easeOutBack,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
