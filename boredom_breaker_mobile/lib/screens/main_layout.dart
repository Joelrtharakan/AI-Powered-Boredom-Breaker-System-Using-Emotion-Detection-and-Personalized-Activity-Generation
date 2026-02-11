import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home/dashboard_screen.dart';
import 'games/games_screen.dart';
import 'chat/chat_screen.dart';
import 'music/music_screen.dart';
import 'journal/journal_screen.dart';
import 'history/history_screen.dart';
import 'lockbox/lockbox_screen.dart';
import 'voice/voice_mode_screen.dart'; // Ensure this file exists or crate it

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const GamesScreen(),
    const MusicScreen(),
    const ChatScreen(), // AI Friend
  ];

  void _navigateTo(Widget screen) {
    Navigator.pop(context); // Close drawer
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: const Color(0xFF09090B),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF18181B), Color(0xFF09090B)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.blueAccent,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Joel",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Premium Member",
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              Icons.book_outlined,
              "Journal",
              () => _navigateTo(const JournalScreen()),
            ),
            _buildDrawerItem(
              Icons.mic_none_outlined,
              "Voice Mode",
              () => _navigateTo(const VoiceModeScreen()),
            ),
            _buildDrawerItem(
              Icons.lock_outline,
              "Lockbox",
              () => _navigateTo(const LockboxScreen()),
            ),
            _buildDrawerItem(
              Icons.history,
              "History",
              () => _navigateTo(const HistoryScreen()),
            ),
            const Divider(color: Colors.white10),
            _buildDrawerItem(Icons.logout, "Logout", () {
              // Implement Logout
              Navigator.pop(context);
              Navigator.pop(context);
            }),
          ],
        ),
      ),
      body: Stack(
        children: [
          _screens[_currentIndex],
          // Custom Menu Button to open Drawer
          Positioned(
            top: 50,
            left: 16,
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white70),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          color: const Color(0xFF09090B),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF09090B),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.white38,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_esports_outlined),
              activeIcon: Icon(Icons.sports_esports),
              label: 'Games',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note_outlined),
              activeIcon: Icon(Icons.music_note),
              label: 'Music',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'AI Friend',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        label,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}
