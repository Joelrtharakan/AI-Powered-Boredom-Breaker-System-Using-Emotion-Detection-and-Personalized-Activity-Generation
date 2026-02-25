import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import 'spotify_player_screen.dart';

class MusicScreen extends StatefulWidget {
  final String? initialPlaylistName;
  final String? initialSpotifyUrl;
  final String? initialTitle;
  final ScrollController? scrollController;

  const MusicScreen({
    super.key,
    this.initialPlaylistName,
    this.initialSpotifyUrl,
    this.initialTitle,
    this.scrollController,
  });

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSpotifyUrl != null) {
        _openInAppPlayer(
          widget.initialTitle ?? "AI Pick",
          widget.initialSpotifyUrl!,
        );
      } else if (widget.initialPlaylistName != null) {
        // Find matching playlist
        final playlist = _moods.firstWhere(
          (m) =>
              m["title"].toString().toLowerCase().contains(
                widget.initialPlaylistName!.toLowerCase(),
              ) ||
              widget.initialPlaylistName!.toLowerCase().contains(
                m['title'].toString().toLowerCase(),
              ),
          orElse: () => _moods[0], // fallback
        );
        if (playlist["title"].toString().toLowerCase().contains(
              widget.initialPlaylistName!.toLowerCase(),
            ) ||
            widget.initialPlaylistName!.toLowerCase().contains(
              playlist['title'].toString().toLowerCase(),
            )) {
          _openInAppPlayer(playlist["title"], playlist["url"]);
        }
      }
    });
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
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          controller: widget.scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
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
                                color: const Color(
                                  0xFF0F172A,
                                ).withValues(alpha: 0.4),
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Atmospheres",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
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
      ),
    );
  }

  Widget _buildFrequencyIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.waves_rounded,
        color: Color(0xFF0F172A),
        size: 20,
      ),
    );
  }

  // Removed _buildGlowOrb as it's replaced by inline Positioned containers

  Widget _buildMasterHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(44),
        border: Border.all(
          color: const Color(0xFF1E293B).withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Hamburger Menu (Left)
              InkWell(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Scaffold.of(context).openDrawer();
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Navigator.canPop(context)
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.menu_rounded,
                    color: const Color(0xFF1E293B),
                    size: 20,
                  ),
                ),
              ),

              // 2. Music Icon with line (Center)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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

              // 3. Power Button or Placeholder (Right)
              if (_isConnected)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
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
                )
              else
                const SizedBox(
                  width: 48,
                  height: 48,
                ), // Empty space to balance the Row
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              _buildLiveBars(),
              const SizedBox(width: 12),
              Text(
                "STUDIO MODE ACTIVE",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                  letterSpacing: 2.5,
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
              color: const Color(0xFF1E293B),
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
                color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                letterSpacing: 6,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              "LOSSLESS AUDIO ENGINE • 44.1KHZ",
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF475569),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF1E293B).withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
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
              color: Color(0xFF0F172A),
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
                    color: const Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  _isConnected
                      ? "Direct frequency synchronization"
                      : "Unlock the full high-fidelity library",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
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
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1DB954).withAlpha(200),
                      const Color(0xFF1DB954),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1DB954).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  "LINK SPOTIFY",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final mood = _moods[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
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

    return GestureDetector(
          onTap: () => _openInAppPlayer(mood['title'], mood['url']),
          child: Container(
            height: 108,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor,
                  HSLColor.fromColor(accentColor).withLightness(0.4).toColor(),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Hero(
                  tag: 'icon_$title',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: isMaterial
                        ? Icon(
                            mood['materialIcon'],
                            color: Colors.white,
                            size: 36,
                          )
                        : Center(
                            child: Image.network(
                              mood['icon'],
                              width: 38,
                              height: 38,
                              color: Colors.white,
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood['desc'],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (index * 80).ms, duration: 600.ms)
        .slideX(begin: 0.05, curve: Curves.easeOutQuart);
  }
}
