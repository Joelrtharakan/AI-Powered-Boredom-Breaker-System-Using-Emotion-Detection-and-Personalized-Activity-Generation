import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_client.dart';
import '../../services/session_manager.dart';
import 'package:google_fonts/google_fonts.dart';

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
            const SnackBar(content: Text("Chat history cleared. Start a new chat!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error clearing history: $e")),
        );
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
                  color: const Color(0xFF1E1E28),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
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
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Previous Chats",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white54),
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
                                style: GoogleFonts.inter(color: Colors.white54),
                              ),
                            )
                          : ListView.builder(
                              itemCount: sessions.length,
                              itemBuilder: (context, index) {
                                final s = sessions[index];
                                final isCurrent = s['session_id'] == _currentSessionId;
                                return ListTile(
                                  leading: const Icon(Icons.chat_bubble_outline, color: Colors.white70),
                                  title: Text(
                                    s['preview'] ?? 'Chat',
                                    style: GoogleFonts.inter(
                                      color: isCurrent ? Colors.greenAccent : Colors.white,
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    s['created_at'].toString().split('T')[0],
                                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching sessions: $e")),
        );
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
            color: const Color(0xFF1E1E28),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: Colors.white),
                title: Text("Start New Chat", style: GoogleFonts.inter(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _startNewChat();
                },
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.white),
                title: Text("View Previous Chats", style: GoogleFonts.inter(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showHistoryModal();
                },
              ),
              const Divider(color: Colors.white12),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: Text("Clear All Chat History", style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
          backgroundColor: const Color(0xFF1E1E28),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Clear History", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to clear all your chat history with Luno? This cannot be undone.", style: GoogleFonts.inter(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.inter(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(context);
                _clearAllChatHistory();
              },
              child: Text("Clear Everything", style: GoogleFonts.inter(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Dynamic gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Floating glow accents
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8A2387).withOpacity(0.3),
                    blurRadius: 150,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE94057).withOpacity(0.3),
                    blurRadius: 150,
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
                          reverse: true, // This positions messages from the bottom naturally
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: _messages.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_isLoading && index == 0) {
                              return _buildTypingIndicator();
                            }
                            final msg = _messages[_isLoading ? index - 1 : index];
                            final isUser = msg['role'] == 'user';
                            return _buildMessageBubble(msg['text']!, isUser, index);
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
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white38, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            "Start a conversation",
            style: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Say hi to Luno! 😄",
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 14,
            ),
          ),
        ].animate(interval: 100.ms).fadeIn().slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE94057).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Luno",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.5, end: 1.0, duration: 1.seconds),
                        const SizedBox(width: 6),
                        Text(
                          "Online • AI Companion",
                          style: GoogleFonts.inter(
                            color: Colors.white70,
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
                icon: const Icon(Icons.more_vert, color: Colors.white),
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
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12,
          left: isUser ? 60 : 0,
          right: isUser ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFFE94057), Color(0xFFF27121)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isUser ? null : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isUser ? 24 : 8),
            bottomRight: Radius.circular(isUser ? 8 : 24),
          ),
          border: isUser ? null : Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            if (isUser)
              BoxShadow(
                color: const Color(0xFFE94057).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 60),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(24),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFE94057),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Luno is thinking...",
              style: GoogleFonts.inter(
                color: Colors.white70,
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
        color: Colors.black.withOpacity(0.4),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: "Message Luno...",
                      hintStyle: GoogleFonts.inter(color: Colors.white38),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE94057), Color(0xFFF27121)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE94057).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
