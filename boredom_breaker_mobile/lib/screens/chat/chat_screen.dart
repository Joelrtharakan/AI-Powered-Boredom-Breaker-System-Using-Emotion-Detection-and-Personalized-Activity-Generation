import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_client.dart';
import '../../services/session_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import '../music/music_screen.dart';
import '../games/games_screen.dart';
import '../games/tic_tac_toe_screen.dart';
import '../games/snake_game_screen.dart';
import '../games/aim_trainer_screen.dart';
import '../games/memory_flip_screen.dart';
import '../zen_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  final _api = ApiClient().client;
  int _userId = 1;
  String? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final id = await SessionManager.getUserId();
    if (id != null) _userId = id;
    _loadHistory();
  }

  Future<void> _loadHistory({String? sessionId}) async {
    try {
      String url = '/chat/history?user_id=$_userId&limit=50';
      if (sessionId != null) {
        url += '&session_id=$sessionId';
      }

      final res = await _api.get(url);
      if (res.statusCode == 200) {
        final List history = res.data;
        if (mounted) {
          setState(() {
            _messages.clear();
            if (history.isNotEmpty) {
              _currentSessionId = history.first['session_id'];
              // Add directly since reverse: true shows list bottom-up
              for (var msg in history) {
                _messages.add({
                  'role': msg['role'] == 'assistant' ? 'ai' : 'user',
                  'text': msg['message'],
                });
              }
            } else {
              _currentSessionId = sessionId; // might be empty
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to load history: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
    setState(() {
      _messages.insert(0, {'role': 'user', 'text': text});
      _isLoading = true;
      _controller.clear();
    });

    try {
      final requestData = {'user_id': _userId, 'message': text};
      if (_currentSessionId != null) {
        requestData['session_id'] = _currentSessionId!;
      }

      final res = await _api.post('/chat/send', data: requestData);

      if (mounted) {
        setState(() {
          _currentSessionId = res.data['session_id'];
          _messages.insert(0, {'role': 'ai', 'text': res.data['reply']});
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startNewChat() {
    setState(() {
      _currentSessionId = null;
      _messages.clear();
    });
  }

  Future<void> _clearAllChatHistory() async {
    try {
      final res = await _api.delete('/chat/history?user_id=$_userId');
      if (res.statusCode == 200) {
        setState(() {
          _currentSessionId = null;
          _messages.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Chat history cleared. Start a new chat!",
                style: TextStyle(color: const Color(0xFF1E293B)),
              ),
              backgroundColor: Colors.teal,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error clearing history: $e")));
      }
    }
  }

  void _showHistoryModal() async {
    try {
      final res = await _api.get('/chat/sessions?user_id=$_userId');
      if (res.statusCode == 200) {
        final List sessions = res.data;
        if (mounted) {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Previous Chats",
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF1E293B),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: const Color(0xFF94A3B8),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: sessions.isEmpty
                          ? Center(
                              child: Text(
                                "No previous chats found.",
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: sessions.length,
                              itemBuilder: (context, index) {
                                final s = sessions[index];
                                final isCurrent =
                                    s['session_id'] == _currentSessionId;
                                return ListTile(
                                  leading: const Icon(
                                    Icons.chat_bubble_outline,
                                    color: Colors.tealAccent,
                                  ),
                                  title: Text(
                                    s['preview'] ?? 'Chat',
                                    style: GoogleFonts.inter(
                                      color: isCurrent
                                          ? const Color(0xFF6D4EFF)
                                          : const Color(0xFF1E293B),
                                      fontWeight: isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    s['created_at'].toString().split('T')[0],
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _loadHistory(sessionId: s['session_id']);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching sessions: $e")));
      }
    }
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.add_circle_outline,
                  color: const Color(0xFF1E293B),
                ),
                title: Text(
                  "Start New Chat",
                  style: GoogleFonts.inter(color: const Color(0xFF1E293B)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _startNewChat();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.history,
                  color: const Color(0xFF1E293B),
                ),
                title: Text(
                  "View Previous Chats",
                  style: GoogleFonts.inter(color: const Color(0xFF1E293B)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showHistoryModal();
                },
              ),
              Divider(color: const Color(0xFF1E293B).withValues(alpha: 0.1)),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: Text(
                  "Clear All Chat History",
                  style: GoogleFonts.inter(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showClearConfirmation();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Clear History",
            style: GoogleFonts.outfit(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to clear all your chat history with Luno? This cannot be undone.",
            style: GoogleFonts.inter(color: const Color(0xFF64748B)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _clearAllChatHistory();
              },
              child: Text(
                "Clear Everything",
                style: GoogleFonts.inter(color: const Color(0xFF1E293B)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Floating glow accents
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6D4EFF).withValues(alpha: 0.1),
                    blurRadius: 200,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C6FF).withValues(alpha: 0.1),
                    blurRadius: 200,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _messages.isEmpty && !_isLoading
                      ? _buildEmptyState()
                      : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          itemCount: _messages.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_isLoading && index == 0) {
                              return _buildTypingIndicator();
                            }
                            final msg =
                                _messages[_isLoading ? index - 1 : index];
                            final isUser = msg['role'] == 'user';
                            return _buildMessageBubble(
                              msg['text']!,
                              isUser,
                              index,
                            );
                          },
                        ),
                ),
                _buildInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1E293B).withOpacity(0.03),
                      border: Border.all(
                        color: const Color(0xFF1E293B).withOpacity(0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6D4EFF).withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Image.network(
                      'https://img.icons8.com/nolan/64/bot.png',
                      width: 64,
                      height: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Your Safe Space",
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF1E293B),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Talk to Luno about how you're feeling.",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 15,
                    ),
                  ),
                ]
                .animate(interval: 100.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF1E293B).withValues(alpha: 0.05),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: const Color(0xFF1E293B),
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E293B).withOpacity(0.05),
                  border: Border.all(
                    color: const Color(0xFF1E293B).withOpacity(0.1),
                  ),
                ),
                child: Center(
                  child: Image.network(
                    'https://img.icons8.com/nolan/64/bot.png',
                    width: 28,
                    height: 28,
                  ),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Luno",
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF1E293B),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6D4EFF),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF6D4EFF,
                                    ).withOpacity(0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .fade(begin: 0.4, end: 1.0, duration: 1.5.seconds),
                        const SizedBox(width: 6),
                        Text(
                          "Active • Safe Space",
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: const Color(0xFF1E293B),
                ),
                onPressed: _showMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, int index) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child:
          Container(
                margin: EdgeInsets.only(
                  bottom: 16,
                  left: isUser ? 50 : 0,
                  right: isUser ? 0 : 50,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  // Deep Purple gradient for user to match Dashboard
                  gradient: isUser
                      ? const LinearGradient(
                          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isUser ? null : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 6),
                    bottomRight: Radius.circular(isUser ? 6 : 20),
                  ),
                  border: isUser
                      ? null
                      : Border.all(
                          color: const Color(
                            0xFF1E293B,
                          ).withValues(alpha: 0.05),
                        ),
                  boxShadow: [
                    if (isUser)
                      BoxShadow(
                        color: const Color(0xFF8E2DE2).withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    if (!isUser) ...[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: GoogleFonts.inter(
                        color: isUser ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                    if (!isUser) ..._buildActionButtons(text),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05, end: 0, duration: 300.ms),
    );
  }

  List<Widget> _buildActionButtons(String text) {
    final t = text.toLowerCase();
    final List<Widget> buttons = [];

    // Exact Playlist Routing
    if (t.contains("chill playlist") || t.contains("chill music")) {
      buttons.add(
        _buildActionChip(
          Icons.music_note_rounded,
          "Chill Playlist",
          const MusicScreen(initialPlaylistName: 'Chill'),
        ),
      );
    } else if (t.contains("focus playlist") || t.contains("focus music")) {
      buttons.add(
        _buildActionChip(
          Icons.center_focus_strong_rounded,
          "Focus Playlist",
          const MusicScreen(initialPlaylistName: 'Focus'),
        ),
      );
    } else if (t.contains("energize playlist") ||
        t.contains("energizing music")) {
      buttons.add(
        _buildActionChip(
          Icons.bolt_rounded,
          "Energize Playlist",
          const MusicScreen(initialPlaylistName: 'Energize'),
        ),
      );
    } else if (t.contains("sad playlist") || t.contains("sad music")) {
      buttons.add(
        _buildActionChip(
          Icons.water_drop_rounded,
          "Sad Playlist",
          const MusicScreen(initialPlaylistName: 'Sad'),
        ),
      );
    } else if (t.contains("happy playlist") || t.contains("happy music")) {
      buttons.add(
        _buildActionChip(
          Icons.wb_sunny_rounded,
          "Happy Playlist",
          const MusicScreen(initialPlaylistName: 'Happy'),
        ),
      );
    } else if (t.contains("christian playlist") || t.contains("worship")) {
      buttons.add(
        _buildActionChip(
          Icons.auto_awesome_rounded,
          "Christian Playlist",
          const MusicScreen(initialPlaylistName: 'Christian'),
        ),
      );
    } else if (t.contains("top hits")) {
      buttons.add(
        _buildActionChip(
          Icons.star_rounded,
          "Top Hits Playlist",
          const MusicScreen(initialPlaylistName: 'Top Hits'),
        ),
      );
    } else if (t.contains("music") ||
        t.contains("playlist") ||
        t.contains("song")) {
      // General Fallback
      buttons.add(
        _buildActionChip(
          Icons.music_note_rounded,
          "Listen to Music",
          const MusicScreen(),
        ),
      );
    }

    // Zen Mode / Breathing Routing
    if (t.contains("breathe") ||
        t.contains("breathing") ||
        t.contains("zen") ||
        t.contains("meditate") ||
        t.contains("exercise")) {
      buttons.add(
        _buildActionChip(Icons.air_rounded, "Zen Mode", const ZenScreen()),
      );
    }

    // Specific Mini Games Routing
    if (t.contains("snake")) {
      buttons.add(
        _buildActionChip(
          Icons.bug_report_rounded,
          "Play Snake",
          const SnakeGameScreen(),
        ),
      );
    } else if (t.contains("tic tac toe")) {
      buttons.add(
        _buildActionChip(
          Icons.grid_3x3_rounded,
          "Tic Tac Toe",
          const TicTacToeScreen(),
        ),
      );
    } else if (t.contains("memory flip") || t.contains("memory game")) {
      buttons.add(
        _buildActionChip(
          Icons.flip_to_front_rounded,
          "Memory Flip",
          const MemoryFlipScreen(),
        ),
      );
    } else if (t.contains("aim trainer")) {
      buttons.add(
        _buildActionChip(
          Icons.gps_fixed_rounded,
          "Aim Trainer",
          const AimTrainerScreen(),
        ),
      );
    } else if (t.contains("game") || t.contains("play")) {
      // General Fallback
      buttons.add(
        _buildActionChip(
          Icons.sports_esports_rounded,
          "Mini Games",
          const GamesScreen(),
        ),
      );
    }

    if (buttons.isEmpty) return [];

    return [
      const SizedBox(height: 14),
      Wrap(spacing: 8, runSpacing: 8, children: buttons),
    ];
  }

  Widget _buildActionChip(IconData icon, String label, Widget screen) {
    return ActionChip(
      backgroundColor: Colors.white,
      side: BorderSide(color: const Color(0xFF6D4EFF).withValues(alpha: 0.15)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      avatar: Icon(icon, color: const Color(0xFF6D4EFF), size: 16),
      label: Text(
        label,
        style: GoogleFonts.inter(
          color: const Color(0xFF1E293B),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      elevation: 0,
      pressElevation: 0,
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 60),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(
            color: const Color(0xFF1E293B).withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
                  'https://img.icons8.com/nolan/64/bot.png',
                  width: 18,
                  height: 18,
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -4, duration: 500.ms),
            const SizedBox(width: 12),
            Text(
              "Luno is typing softly...",
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF1E293B).withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(
                  28,
                ), // Slightly larger for smoother look
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.inter(
                  color: const Color(0xFF1E293B),
                  fontSize: 16,
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: "Share your thoughts...",
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8E2DE2),
                  Color(0xFF4A00E0),
                ], // Purple matching dashboard primary
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6D4EFF).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
