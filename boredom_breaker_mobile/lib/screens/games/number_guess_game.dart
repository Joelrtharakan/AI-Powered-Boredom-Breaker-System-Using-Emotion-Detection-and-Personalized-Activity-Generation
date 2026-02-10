import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NumberGuessGame extends StatefulWidget {
  const NumberGuessGame({super.key});

  @override
  State<NumberGuessGame> createState() => _NumberGuessGameState();
}

class _NumberGuessGameState extends State<NumberGuessGame> {
  final TextEditingController _controller = TextEditingController();
  final int _targetNumber = (DateTime.now().millisecond % 100) + 1; // 1-100
  String _message = "Guess a number between 1 and 100";
  int _attempts = 0;

  void _checkGuess() {
    setState(() {
      _attempts++;
      final guess = int.tryParse(_controller.text);
      if (guess == null) {
        _message = "Please enter a valid number";
      } else if (guess < _targetNumber) {
        _message = "Too low! Try again.";
      } else if (guess > _targetNumber) {
        _message = "Too high! Try again.";
      } else {
        _message = "Correct! You guessed it in $_attempts attempts.";
      }
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        title: Text(
          "Number Guessing",
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _message,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 32),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                hintText: "#",
                hintStyle: TextStyle(color: Colors.white38),
              ),
              onSubmitted: (_) => _checkGuess(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkGuess,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "Guess",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
