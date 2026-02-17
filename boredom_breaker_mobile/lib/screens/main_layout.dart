import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home/dashboard_screen.dart';
import 'games/games_screen.dart';
import 'chat/chat_screen.dart';
import 'music/music_screen.dart';
import 'journal/journal_screen.dart';
import 'history/history_screen.dart';
import 'lockbox/lockbox_screen.dart';
import 'voice/voice_mode_screen.dart';
import '../services/api_client.dart';
import '../services/session_manager.dart';
import '../theme/app_theme.dart';
import 'landing_screen.dart';

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
    const ChatScreen(),
  ];

  void _navigateTo(Widget screen) {
    // Close the drawer safely using the scaffold key, ONLY if it's open
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }

    // Navigate to the new screen
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true, // For modern floating nav bar effect
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Global Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.darkGradient,
              ),
            ),
          ),

          // Subtle Ambient Glow
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
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 150,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(child: _buildBottomNav()),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Boredom Breaker",
                  style: GoogleFonts.outfit(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Elevate your mood.",
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
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
          const Divider(color: Colors.white10, height: 40),
          _buildDrawerItem(Icons.logout_rounded, "Logout", () async {
            // Close drawer first
            if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
              _scaffoldKey.currentState?.closeDrawer();
            }

            final navigator = Navigator.of(context);
            await SessionManager.clearSession();
            ApiClient.setToken(null);
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LandingScreen()),
              (route) => false,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.2),
            BlendMode.darken,
          ),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.white30,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sports_esports_rounded),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Image.network(
                    "https://img.icons8.com/liquid-glass-color/32/musical-notes.png",
                    height: 24,
                    color: _currentIndex == 2
                        ? null
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.forum_rounded),
                  label: '',
                ),
              ],
            ),
          ),
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
