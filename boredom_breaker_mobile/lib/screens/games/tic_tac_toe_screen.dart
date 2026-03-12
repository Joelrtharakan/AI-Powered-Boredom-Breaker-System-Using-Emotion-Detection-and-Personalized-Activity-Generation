import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/games_api.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> _board = List.filled(9, "");
  bool _isPlayerTurn = true; // Player is always X
  String? _winner;
  List<int>? _winningLine;
  bool _isDraw = false;
  bool _gameStarted = false; // Instructions

  final Color _primaryColor = const Color(0xFF06B6D4); // Cyan 500
  final Color _secondaryColor = const Color(0xFFE11D48); // Rose 600
  final Color _bgColor = const Color(0xFFF8FAFC); // Light Slate 50

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _resetGame();
    });
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, "");
      _isPlayerTurn = true;
      _winner = null;
      _winningLine = null;
      _isDraw = false;
    });
  }

  void _handleTap(int index) {
    if (_board[index] != "" || _winner != null || !_isPlayerTurn) return;

    setState(() {
      _board[index] = "X";
      _isPlayerTurn = false;
      _checkGameState();

      if (_winner == null && !_isDraw) {
        // AI Turn with delay
        Future.delayed(const Duration(milliseconds: 600), _makeSmartAIMove);
      }
    });
  }

  // Hard AI: Minimax algorithm implementation for perfect/hard play
  void _makeSmartAIMove() {
    if (!mounted || _winner != null || _isDraw) return;

    int bestScore = -1000;
    int bestMove = -1;

    // Clone board for simulation
    List<String> boardCopy = List.from(_board);

    // Check available moves
    List<int> availableMoves = [];
    for (int i = 0; i < 9; i++) {
      if (boardCopy[i] == "") availableMoves.add(i);
    }

    if (availableMoves.isEmpty) return;

    // Minimax loop
    for (int move in availableMoves) {
      boardCopy[move] = "O"; // AI is O
      int score = _minimax(boardCopy, 0, false);
      boardCopy[move] = ""; // Undo

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    // Fallback if something fails (shouldn't)
    if (bestMove == -1) {
      bestMove = availableMoves[Random().nextInt(availableMoves.length)];
    }

    setState(() {
      _board[bestMove] = "O";
      _isPlayerTurn = true;
      _checkGameState();
    });
  }

  int _minimax(List<String> board, int depth, bool isMaximizing) {
    // Check terminal states
    String? result = _checkWinnerSimple(board);
    if (result == "O") return 10 - depth; // AI wins
    if (result == "X") return depth - 10; // Player wins
    if (!board.contains("")) return 0; // Draw

    if (isMaximizing) {
      // AI's turn to maximize
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == "") {
          board[i] = "O";
          int score = _minimax(board, depth + 1, false);
          board[i] = "";
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      // Player's turn to minimize AI score
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == "") {
          board[i] = "X";
          int score = _minimax(board, depth + 1, true);
          board[i] = "";
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  String? _checkWinnerSimple(List<String> board) {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var line in lines) {
      String a = board[line[0]];
      String b = board[line[1]];
      String c = board[line[2]];
      if (a != "" && a == b && a == c) return a;
    }
    return null;
  }

  void _checkGameState() {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var line in lines) {
      String a = _board[line[0]];
      String b = _board[line[1]];
      String c = _board[line[2]];

      if (a != "" && a == b && a == c) {
        _winner = a;
        _winningLine = line;
        if (a == 'X') {
          GamesApi.submitScore('tic_tac_toe', 100);
        } else {
          GamesApi.submitScore('tic_tac_toe', 0);
        }
        _showResultDialog(); // Show dialog on win
        return;
      }
    }

    if (!_board.contains("") && _winner == null) {
      _isDraw = true;
      GamesApi.submitScore('tic_tac_toe', 50);
      _showResultDialog(); // Show dialog on draw
    }
  }

  void _showResultDialog() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      String title = _isDraw
          ? "IT'S A DRAW!"
          : (_winner == 'X' ? "YOU WON!" : "AI WINS!");
      Color color = _isDraw
          ? const Color(0xFF64748B)
          : (_winner == 'X' ? _primaryColor : _secondaryColor);

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
              border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 30),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isDraw ? Icons.balance_rounded : Icons.emoji_events_rounded,
                  size: 60,
                  color: color,
                ).animate().scale(curve: Curves.elasticOut),

                const SizedBox(height: 24),

                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1E293B),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Exit screen
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: const Color(
                              0xFF1E293B,
                            ).withValues(alpha: 0.2),
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
                          Navigator.pop(context); // Close dialog
                          _resetGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          "RETRY",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                          ),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withValues(alpha: 0.05),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _secondaryColor.withValues(alpha: 0.05),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: !_gameStarted ? _buildInstructions() : _buildGameUI(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameUI() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
              ),
              Text(
                "HARD MODE",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              IconButton(
                onPressed: _resetGame,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Status Text
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Text(
            _winner != null
                ? (_winner == 'X' ? 'YOU WIN!' : 'AI WINS!')
                : _isDraw
                ? "DRAW"
                : (_isPlayerTurn ? "YOUR TURN" : "AI THINKING..."),
            style: GoogleFonts.outfit(
              color: _winner != null
                  ? (_winner == 'X' ? _primaryColor : _secondaryColor)
                  : const Color(0xFF1E293B),
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: 1,
            ),
          ).animate(target: _winner != null ? 1 : 0).shimmer(),
        ),

        const Spacer(),

        // Board
        Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  final cellValue = _board[index];
                  final isWinningCell = _winningLine?.contains(index) ?? false;

                  return GestureDetector(
                    onTap: () => _handleTap(index),
                    child: AnimatedContainer(
                      duration: 300.ms,
                      decoration: BoxDecoration(
                        color: isWinningCell
                            ? (cellValue == "X"
                                  ? _primaryColor.withValues(alpha: 0.2)
                                  : _secondaryColor.withValues(alpha: 0.2))
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isWinningCell
                              ? (cellValue == "X"
                                    ? _primaryColor
                                    : _secondaryColor)
                              : const Color(0xFFCBD5E1),
                          width: isWinningCell ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: cellValue == ""
                            ? null
                            : Icon(
                                cellValue == "X"
                                    ? Icons.close_rounded
                                    : Icons.circle_outlined,
                                size: 40,
                                color: cellValue == "X"
                                    ? _primaryColor
                                    : _secondaryColor,
                              ).animate().scale(curve: Curves.elasticOut),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        const Spacer(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInstructions() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFCBD5E1)),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withValues(alpha: 0.2),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Image.network(
                "https://img.icons8.com/external-icongeek26-linear-colour-icongeek26/64/external-Tic-Tac-Toe-table-games-icongeek26-linear-colour-icongeek26.png",
                fit: BoxFit.contain,
              ),
            ).animate().scale(duration: 1.seconds, curve: Curves.elasticOut),

            const SizedBox(height: 32),

            Text(
              "TIC TAC TOE",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E293B),
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            Text(
              "vs Minimax AI",
              style: GoogleFonts.spaceMono(
                color: const Color(0xFF64748B),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 48),

            _buildInstructionRow("You are Player X (Cyan)"),
            _buildInstructionRow("AI is Player O (Pink)"),
            _buildInstructionRow("AI plays perfectly. Good luck!"),

            const SizedBox(height: 60),

            SizedBox(
              width: double.infinity,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: const Color(0xFF1E293B),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 10,
                  ),
                  child: Text(
                    "CHALLENGE AI",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "EXIT",
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

  Widget _buildInstructionRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: const Color(0xFF64748B),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
