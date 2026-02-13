import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> _board = List.filled(9, "");
  bool _xIsNext = true;
  String? _winner;
  bool _isDraw = false;

  void _handleTap(int index) {
    if (_board[index] != "" || _winner != null) return;

    setState(() {
      _board[index] = _xIsNext ? "X" : "O";
      _xIsNext = !_xIsNext;
      _winner = _checkWinner();
      if (_winner == null && !_board.contains("")) {
        _isDraw = true;
      }
    });
  }

  String? _checkWinner() {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var line in lines) {
      if (_board[line[0]] != "" &&
          _board[line[0]] == _board[line[1]] &&
          _board[line[0]] == _board[line[2]]) {
        return _board[line[0]];
      }
    }
    return null;
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, "");
      _xIsNext = true;
      _winner = null;
      _isDraw = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Tic Tac Toe",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _winner != null
                  ? "Winner: $_winner"
                  : _isDraw
                  ? "It's a Draw!"
                  : "Player ${_xIsNext ? 'X' : 'O'}'s Turn",
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _winner != null ? AppColors.primary : Colors.white,
              ),
            ).animate(target: _winner != null ? 1 : 0).shimmer(),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: SizedBox(
                width: 300,
                height: 300,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _handleTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Center(
                          child:
                              Text(
                                    _board[index],
                                    style: GoogleFonts.outfit(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: _board[index] == "X"
                                          ? AppColors.primary
                                          : AppColors.secondary,
                                    ),
                                  )
                                  .animate(target: _board[index] != "" ? 1 : 0)
                                  .scale()
                                  .fadeIn(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 56),
            _buildResetButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return Container(
      width: 200,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: _winner != null || _isDraw
              ? AppColors.primaryGradient
              : [Colors.grey.shade800, Colors.grey.shade900],
        ),
        boxShadow: [
          if (_winner != null || _isDraw)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _resetGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          "Reset Game",
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
