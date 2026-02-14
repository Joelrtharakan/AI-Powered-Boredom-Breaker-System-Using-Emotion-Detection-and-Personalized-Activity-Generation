import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import 'spotify_player_screen.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  bool _isConnected = false;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _moods = [
    {
      "title": "Chill",
      "desc": "Soft hits to wind down",
      "materialIcon": Icons.self_improvement_rounded,
      "color": const Color(0xFF4EEBFF),
      "url": "https://open.spotify.com/playlist/37i9dQZF1DX4WYpdgoIcn6",
    },
    {
      "title": "Focus",
      "desc": "Deep flow state beats",
      "icon":
          "https://img.icons8.com/liquid-glass-color/96/define-location.png",
      "color": const Color(0xFF9489FE),
      "url": "https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ",
    },
    {
      "title": "Energize",
      "desc": "High intensity pop",
      "icon": "https://img.icons8.com/liquid-glass-color/96/lightning-bolt.png",
      "color": const Color(0xFFFFD64E),
      "url": "https://open.spotify.com/playlist/37i9dQZF1DX0vHZ8elq0UK",
    },
    {
      "title": "Sad",
      "desc": "Feel the resonance",
      "materialIcon": Icons.cloud_rounded,
      "color": const Color(0xFF4E92FF),
      "url": "https://open.spotify.com/playlist/37i9dQZF1DX7qK8ma5wgG1",
    },
    {
      "title": "Happy",
      "desc": "Sun-drenched rhythm",
      "materialIcon": Icons.wb_sunny_rounded,
      "color": const Color(0xFFFF8E4E),
      "url": "https://open.spotify.com/playlist/37i9dQZF1DXdPec7aLTmlC",
    },
    {
      "title": "Christian",
      "desc": "Soul-lifting worship",
      "icon": "https://img.icons8.com/liquid-glass/96/cross.png",
      "color": const Color(0xFFD44EFF),
      "url": "https://open.spotify.com/playlist/37i9dQZF1DXcb6CQIjdqKy",
    },
    {
      "title": "Top Hits",
      "desc": "Global sonic waves",
      "icon": "https://img.icons8.com/liquid-glass-color/96/bullish.png",
      "color": const Color(0xFF4EFF94),
      "url": "https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M",
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkSpotifyConnection();
  }

  Future<void> _checkSpotifyConnection() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isConnected = prefs.getBool('isSpotifyConnected') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _connectSpotify() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SpotifyPlayerScreen(
          title: "Account Login",
          spotifyUrl: "https://accounts.spotify.com/login",
          isLoginOnly: true,
        ),
        fullscreenDialog: true,
      ),
    );

    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isSpotifyConnected', true);
      setState(() => _isConnected = true);
    }
  }

  void _openInAppPlayer(String title, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpotifyPlayerScreen(title: title, spotifyUrl: url),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF030303),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Masterpiece Ambient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF050505),
                    Color(0xFF0C0C0E),
                    Color(0xFF030303),
                  ],
                ),
              ),
            ),
          ),

          // Deep Ethereal Orbs
          Positioned(
            top: -200,
            left: -100,
            child: _buildGlowOrb(const Color(0xFF5A3BFF), 600, 20.seconds),
          ),
          Positioned(
            bottom: 100,
            right: -150,
            child: _buildGlowOrb(const Color(0xFF3BAFFF), 500, 25.seconds),
          ),
          Positioned(
            top: 400,
            left: -100,
            child: _buildGlowOrb(const Color(0xFFFF3B97), 450, 22.seconds),
          ),

          // 2. Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildMasterHeader(),
                      const SizedBox(height: 48),
                      _buildSpotifyBridge(),
                      const SizedBox(height: 64),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "CURATED",
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white.withValues(alpha: 0.3),
                                  letterSpacing: 4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Atmospheres",
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          _buildFrequencyIndicator(),
                        ],
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              _buildMoodGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: const Icon(Icons.waves_rounded, color: Colors.white30, size: 20),
    );
  }

  Widget _buildGlowOrb(Color color, double size, Duration duration) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
                Colors.transparent,
              ],
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .move(
          duration: duration,
          begin: const Offset(0, 0),
          end: const Offset(100, 120),
          curve: Curves.easeInOutSine,
        )
        .scale(
          duration: duration,
          begin: const Offset(1, 1),
          end: const Offset(1.4, 1.4),
          curve: Curves.easeInOutSine,
        );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      toolbarHeight: 100,
      centerTitle: true,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Center(
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ),
      title: Column(
        children: [
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Image.network(
            "https://img.icons8.com/liquid-glass-color/96/musical-notes.png",
            height: 32,
          ),
        ],
      ),
      actions: [
        if (_isConnected)
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.power_settings_new_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isSpotifyConnected', false);
                setState(() => _isConnected = false);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMasterHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildLiveBars(),
              const SizedBox(width: 12),
              Text(
                "STUDIO MODE ACTIVE",
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Sonic",
            style: GoogleFonts.playfairDisplay(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              height: 0.8,
              color: Colors.white,
              letterSpacing: -2,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "SANCTUARY",
              style: GoogleFonts.outfit(
                fontSize: 56,
                fontWeight: FontWeight.w200,
                height: 0.9,
                color: Colors.white.withValues(alpha: 0.2),
                letterSpacing: 6,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Text(
              "LOSSLESS AUDIO ENGINE • 44.1KHZ",
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white38,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 1.seconds).slideY(begin: 0.05);
  }

  Widget _buildLiveBars() {
    return Row(
      children: List.generate(
        4,
        (i) =>
            Container(
                  margin: const EdgeInsets.only(right: 2),
                  width: 2,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(1),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleY(begin: 0.3, end: 1.0, duration: (400 + (i * 100)).ms),
      ),
    );
  }

  Widget _buildSpotifyBridge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1DB954).withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1DB954).withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1DB954),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.4),
                  blurRadius: 25,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isConnected ? "BRIDGE ACTIVE" : "SPOTIFY LINK",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  _isConnected
                      ? "Direct frequency synchronization"
                      : "Unlock the full high-fidelity library",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!_isConnected)
            InkWell(
              onTap: _connectSpotify,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "LINK",
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.98, 0.98));
  }

  Widget _buildMoodGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final mood = _moods[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _buildMoodCard(mood, index),
          );
        }, childCount: _moods.length),
      ),
    );
  }

  Widget _buildMoodCard(Map<String, dynamic> mood, int index) {
    final bool isMaterial = mood.containsKey('materialIcon');
    final Color accentColor = mood['color'] as Color;
    final String title = mood['title'];

    // Define unique styles for different playlists
    BoxDecoration cardDecoration;
    Widget? backgroundEffect;

    switch (title) {
      case 'Chill':
        cardDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.02),
            ],
          ),
        );
        backgroundEffect = Positioned.fill(
          child: CustomPaint(
            painter: _WavePainter(accentColor.withValues(alpha: 0.05)),
          ),
        );
        break;
      case 'Energize':
        cardDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.1),
              blurRadius: 40,
              spreadRadius: -10,
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.8),
            ],
          ),
        );
        backgroundEffect = Positioned.fill(
          child:
              Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.bottomRight,
                        radius: 1.5,
                        colors: [
                          accentColor.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(
                    duration: 3.seconds,
                    color: accentColor.withValues(alpha: 0.1),
                  ),
        );
        break;
      case 'Focus':
        cardDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: const Color(0xFF0F0F12),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        );
        backgroundEffect = Positioned.fill(
          child: Opacity(
            opacity: 0.05,
            child: GridPaper(
              color: accentColor,
              divisions: 1,
              subdivisions: 1,
              interval: 40,
            ),
          ),
        );
        break;
      case 'Happy':
        cardDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withValues(alpha: 0.3),
              const Color(0xFFFFE082).withValues(alpha: 0.1),
            ],
          ),
        );
        backgroundEffect = Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
                radius: 0.8,
              ),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
        );
        break;
      case 'Christian':
        cardDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C003E), Color(0xFF12001B)],
          ),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
            width: 2,
          ),
        );
        backgroundEffect = Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: accentColor,
              size: 200,
            ),
          ),
        );
        break;
      case 'Top Hits':
        cardDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withValues(alpha: 0.1),
              const Color(0xFF003311),
            ],
          ),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        );
        backgroundEffect = Positioned.fill(
          child: Opacity(
            opacity: 0.2,
            child: Icon(Icons.language_rounded, color: accentColor, size: 220),
          ),
        );
        break;
      case 'Sad':
        cardDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accentColor.withValues(alpha: 0.15),
              const Color(0xFF050510),
            ],
          ),
        );
        backgroundEffect = Positioned.fill(
          child: _buildGlowOrb(
            accentColor.withValues(alpha: 0.1),
            300,
            10.seconds,
          ),
        );
        break;
      default:
        cardDecoration = BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        );
    }

    return InkWell(
          onTap: () => _openInAppPlayer(mood['title'], mood['url']),
          borderRadius: BorderRadius.circular(32),
          child: Container(
            height: 200,
            clipBehavior: Clip.antiAlias,
            decoration: cardDecoration,
            child: Stack(
              children: [
                backgroundEffect ?? const SizedBox(),

                // Shared Ambient Glow (Top Right)
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.08),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      // Icon Section
                      Hero(
                        tag: 'icon_$title',
                        child: Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.2),
                                blurRadius: 32,
                                spreadRadius: -10,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: isMaterial
                              ? Icon(
                                  mood['materialIcon'],
                                  color: accentColor,
                                  size: 44,
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Image.network(
                                    mood['icon'],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Text Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                title.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: accentColor,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                title,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                  height: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              mood['desc'],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.3),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Play Indicator
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (index * 100).ms, duration: 800.ms)
        .slideX(begin: 0.1);
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  _WavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    for (double i = 0; i < size.width; i += 20) {
      path.moveTo(i, 0);
      path.quadraticBezierTo(i + 10, size.height / 2, i + 20, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}
