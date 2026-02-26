import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'profile/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _userName = "Friend";
  String? _profilePicture;
  final ApiClient _apiClient = ApiClient();

  final List<ScrollController> _scrollControllers = [
    ScrollController(),
    ScrollController(),
    ScrollController(),
  ];

  late final List<Widget> _screens = [
    DashboardScreen(scrollController: _scrollControllers[0]),
    GamesScreen(scrollController: _scrollControllers[1]),
    MusicScreen(scrollController: _scrollControllers[2]),
    const SizedBox.shrink(), // Chat is pushed
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final name = await SessionManager.getUserName();

    if (ApiClient.token != null) {
      try {
        final response = await _apiClient.client.get('/auth/me');
        if (response.statusCode == 200 && response.data != null) {
          if (mounted) {
            setState(() {
              _profilePicture = response.data['profile_picture'];
            });
          }
        }
      } catch (e) {
        debugPrint("Failed to load profile picture: $e");
      }
    }

    if (mounted) {
      setState(() {
        if (name != null) _userName = name;
      });
    }
  }

  void _navigateTo(Widget screen) {
    // Close the drawer first
    Navigator.pop(context);

    // Navigate to the new screen
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.1, 0.0), // Subtle horizontal slide
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutQuart,
                    ),
                  ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () async {
        // Navigate to profile and refresh when back
        await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ProfileScreen(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(
                              1.0,
                              0.0,
                            ), // Standard horizontal slide
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutQuart,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
          ),
        );
        _loadUserData(); // Refresh changes
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF1A1A1D),
          backgroundImage: _profilePicture != null
              ? MemoryImage(base64Decode(_profilePicture!))
              : null,
          child: _profilePicture == null
              ? const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 20,
                )
              : null,
        ),
      ),
    );
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
            right: 16,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    if (_currentIndex == 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Hello, $_userName",
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Let's break the cycle.",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _buildProfileAvatar(),
                    ],
                    if (_currentIndex == 1) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Image.network(
                          "https://img.icons8.com/bubbles/100/apple-arcade.png",
                          width: 28,
                          height: 28,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "ARCADE",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      _buildProfileAvatar(),
                    ],
                    if (_currentIndex == 2) ...[
                      const Spacer(),
                      FutureBuilder<SharedPreferences>(
                        future: SharedPreferences.getInstance(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          final isConnected =
                              snapshot.data!.getBool('isSpotifyConnected') ??
                              false;
                          if (!isConnected) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: GestureDetector(
                              onTap: () async {
                                await snapshot.data!.setBool(
                                  'isSpotifyConnected',
                                  false,
                                );
                                // Force a rebuild to reflect the new state
                                setState(() {});
                              },
                              child: const Icon(
                                Icons.link_off_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildProfileAvatar(),
                    ],
                  ],
                ),
                if (_currentIndex == 2)
                  IgnorePointer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 4,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Image.network(
                          "https://img.icons8.com/liquid-glass-color/96/musical-notes.png",
                          height: 38,
                        ),
                      ],
                    ),
                  ),
              ],
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
                _buildNavItem(0, Icons.home_rounded, "Home"),
                _buildNavItem(1, Icons.sports_esports_rounded, "Games"),
                _buildNavItem(2, Icons.music_note_rounded, "Music"),
                _buildNavItem(3, Icons.forum_rounded, "Luno"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 3) {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const ChatScreen()),
          );
        } else {
          setState(() => _currentIndex = index);
          if (_scrollControllers[index].hasClients) {
            _scrollControllers[index].animateTo(
              0.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          }
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: isSelected ? 20 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: isSelected
                ? const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Colors.transparent, Colors.transparent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : Colors.transparent,
                blurRadius: isSelected ? 15 : 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: isSelected ? 22 : 28,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  alignment: Alignment.centerLeft,
                  child: isSelected
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            label,
                            maxLines: 1,
                            softWrap: false,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
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
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        label,
        style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}
