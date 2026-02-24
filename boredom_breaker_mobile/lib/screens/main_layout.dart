import 'dart:ui';
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
    const SizedBox.shrink(),
  ];

  void _navigateTo(Widget screen) {
    // Close the drawer first
    Navigator.pop(context);

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
          // 1. Vibrant Top Half Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF5E60CE), // Indigo
                    Color(0xFF4EA8DE), // Blue
                    Color(0xFF56CFE1), // Cyan
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.05,
                    right: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. White Curved Container holding the entire Main App Content
          Positioned(
            top:
                MediaQuery.of(context).size.height *
                0.15, // Pushes the curve up slightly
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens.map((screen) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 0),
                        child: screen,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          // Custom Header actions floating inside the top gradient (Hamburger menu, etc)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),

          // Floating Bottom Navigation Bar sitting above the white content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(top: false, child: _buildBottomNav()),
          ),
        ],
      ),
      // Removed standard bottomNavigationBar to avoid the "black block" slot
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
              border: Border(bottom: BorderSide(color: Colors.black12)),
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
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
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
          const Divider(color: Colors.black12, height: 40),
          _buildDrawerItem(Icons.logout_rounded, "Logout", () async {
            // Close drawer
            Navigator.pop(context);

            await SessionManager.clearSession();
            ApiClient.setToken(null);

            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LandingScreen()),
                (route) => false,
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, left: 32, right: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white, // Ultra bright white base
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_rounded),
                _buildNavItem(1, Icons.sports_esports_rounded),
                _buildNavItem(2, Icons.music_note_rounded),
                _buildNavItem(3, Icons.forum_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        } else {
          setState(() => _currentIndex = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        width: 60,
        height: 60,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isSelected
                ? const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: isSelected ? 24 : 26,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        label,
        style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}
