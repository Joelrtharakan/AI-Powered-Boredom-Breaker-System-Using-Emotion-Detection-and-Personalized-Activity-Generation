import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/mood_provider.dart';
import '../chat/chat_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final moodState = ref.watch(moodProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF09090B), // Dark background
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            // Simple navigation to chat
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
        },
        child: const Icon(Icons.chat),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text("How are you feeling?", 
                style: GoogleFonts.outfit(
                  color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold
                )
              ),
              Text("Tell me or just click the magic button.", 
                style: GoogleFonts.inter(
                  color: Colors.white54, fontSize: 16
                )
              ),
              const SizedBox(height: 30),
              
              // Input Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: "I'm feeling a bit bored and tired...",
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        icon: moodState.isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                            : const Icon(Icons.flash_on),
                        label: Text(moodState.isLoading ? "Analyzing..." : "Detect Mood", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: moodState.isLoading ? null : () {
                          if (_controller.text.isNotEmpty) {
                              // Hardcoded User ID 1 for testing MVP
                             ref.read(moodProvider.notifier).analyzeMood(_controller.text, 1);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          shadowColor: Colors.blueAccent.withOpacity(0.5)
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Results Section
              moodState.when(
                data: (data) {
                  if (data.isEmpty) return const SizedBox.shrink();
                  final plan = data['plan'] as List;
                  final mood = data['mood']['mood'];
                  final intensity = ((data['mood']['intensity'] ?? 0) * 100).toInt();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Detected: $mood", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text("$intensity% Intensity", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...plan.map((item) => _buildPlanCard(item)),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  )
                ),
                error: (e, _) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.redAccent))),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> item) {
    IconData icon;
    Color color;
    
    switch (item['type']) {
      case 'music': icon = Icons.music_note; color = Colors.purpleAccent; break;
      case 'breathing': icon = Icons.air; color = Colors.tealAccent; break;
      case 'game': icon = Icons.gamepad; color = Colors.orangeAccent; break;
      case 'micro_task': icon = Icons.check_circle_outline; color = Colors.yellowAccent; break;
      default: icon = Icons.star; color = Colors.blueAccent; break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
           Container(
             width: 50, height: 50,
             decoration: BoxDecoration(
               color: color.withOpacity(0.1),
               borderRadius: BorderRadius.circular(16)
             ),
             child: Icon(icon, color: color, size: 24),
           ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['type'].toString().replaceAll('_', ' ').toUpperCase(), 
                  style: GoogleFonts.outfit(color: color, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),
                Text(item['description'], style: GoogleFonts.inter(color: Colors.white, fontSize: 16, height: 1.4)),
              ],
            ),
          ),
          if (item['time_minutes'] != null && item['time_minutes'] > 0)
            Text("${item['time_minutes']}m", style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
