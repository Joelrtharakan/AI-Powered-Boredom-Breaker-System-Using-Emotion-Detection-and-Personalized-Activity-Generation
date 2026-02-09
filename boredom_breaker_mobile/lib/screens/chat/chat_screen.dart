import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import 'package:dio/dio.dart';

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

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      // Hardcoded user id 1
      final res = await _api.get('/chat/history?user_id=1&limit=20');
      if (res.statusCode == 200) {
        final List history = res.data;
        setState(() {
          _messages.clear();
          for (var msg in history) {
            _messages.add({
              'role': msg['role'] == 'assistant' ? 'ai' : 'user',
              'text': msg['message']
            });
          }
        });
      }
    } catch (e) {
      print("Failed to load history: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final text = _controller.text;
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
      _controller.clear();
    });

    try {
      final res = await _api.post('/chat/send', data: {
        'user_id': 1,
        'message': text
      });

      setState(() {
        _messages.add({'role': 'ai', 'text': res.data['reply']});
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Companion")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['text']!, style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "Type a message..."))),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage)
              ],
            ),
          )
        ],
      ),
    );
  }
}
