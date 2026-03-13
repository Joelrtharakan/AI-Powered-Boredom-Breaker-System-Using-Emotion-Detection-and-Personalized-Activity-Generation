import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import 'spotify_player_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/music_launch_provider.dart';

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
      "icon":
          "https://img.icons8.com/external-flaticons-lineal-color-flat-icons/64/external-calm-emotions-and-emotional-intelligence-flaticons-lineal-color-flat-icons-2.png",
      "color": const Color(0xFF2DD4BF),
      "url": "https://open.spotify.com/playlist/37i9dQZF1DX4WYpdgoIcn6",
    },
    {
      "title": "Focus",
      "desc": "Deep flow state beats",
      "icon": "https://img.icons8.com/pastel-glyph/64/define-location--v1.png",
      "color": const Color(0xFFA78BFA),
      "url": "https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ",
    },
    {
      "title": "Energize",
      "desc": "High intensity pop",
      "icon": "https://img.icons8.com/3d-fluency/94/flash-on.png",
      "color": const Color(0xFFFB923C),
      "url": "https://open.spotify.com/playlist/37i9dQZF1DX0vHZ8elq0UK",
    },
    {
      "title": "Sad",
      "desc": "Feel the resonance",
      "icon": "https://img.icons8.com/3d-fluency/94/weary-face.png",
      "color": const Color(0xFF3B82F6),
      "url": "https://open.spotify.com/playlist/37i9dQZF1DX7qK8ma5wgG1",
    },
    {
      "title": "Happy",
      "desc": "Sun-drenched rhythm",
      "icon": "https://img.icons8.com/bubbles/100/winner.png",
      "color": const Color(0xFFF43F5E),
      "url": "https://open.spotify.com/playlist/37i9dQZF1DXdPec7aLTmlC",
    },
    {
      "title": "Christian",
      "desc": "Soul-lifting worship",
      "icon": "https://img.icons8.com/windows/32/cross.png",
      "color": const Color(0xFFD4A373),
      "url": "https://open.spotify.com/playlist/37i9dQZF1DXcb6CQIjdqKy",
    },
    {
      "title": "Top Hits",
      "desc": "Global sonic waves",
      "icon": "https://img.icons8.com/stickers/100/improvement.png",
      "color": const Color(0xFF34D399),
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

  Future<void> _logoutSpotify() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSpotifyConnected', false);
    setState(() => _isConnected = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Logged out of Spotify",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
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
    return Consumer(
      builder: (context, ref, child) {
        // Listen for cross-tab music launches
        ref.listen(musicLaunchProvider, (previous, next) {
          if (next != null) {
            // Clear immediately so it doesn't re-trigger on rebuild
            ref.read(musicLaunchProvider.notifier).state = null;
            _openInAppPlayer(next.title, next.url);
          }
        });

        if (_isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
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
                        if (!_isConnected)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF475569),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      "PREVIEW MODE ACTIVE",
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF475569),
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn().slideY(begin: -0.1),
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
                                        )
                                        .animate(onPlay: (c) => c.repeat())
                                        .shimmer(
                                          duration: 1.5.seconds,
                                          delay: 3.seconds,
                                          color: Colors.black12,
                                        ),
                                  ],
                                ),
                                _buildFrequencyIndicator(),
                              ],
                            )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 800.ms)
                            .slideY(begin: 0.05, curve: Curves.easeOutQuart),
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
      },
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
      child: const Icon(Icons.waves_rounded, color: Color(0xFF0F172A), size: 20)
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.2,
            duration: 800.ms,
            curve: Curves.easeInOut,
          ),
    );
  }

  // Removed _buildGlowOrb as it's replaced by inline Positioned containers

  Widget _buildMasterHeader() {
    return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(44),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(44),
            child: Stack(
              children: [
                // Decorative Top Right Orb (Matching Playlist Cards)
                Positioned(
                  top: -60,
                  right: -40,
                  child:
                      Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scaleXY(
                            begin: 1.0,
                            end: 1.25,
                            duration: 4.seconds,
                            curve: Curves.easeInOut,
                          ),
                ),
                // Decorative Bottom Left Orb (Matching Playlist Cards)
                Positioned(
                  bottom: -60,
                  left: -40,
                  child:
                      Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scaleXY(
                            begin: 1.0,
                            end: 1.15,
                            duration: 6.seconds,
                            curve: Curves.easeInOut,
                          ),
                ),
                // Content (Restored to Clean Slate Colors)
                Padding(
                  padding: const EdgeInsets.all(40),
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
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
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
                            color: const Color(
                              0xFF0F172A,
                            ).withValues(alpha: 0.12),
                            letterSpacing: 6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Premium Badge matching the card aesthetic
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color(
                              0xFF0F172A,
                            ).withValues(alpha: 0.05),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF0F172A,
                              ).withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                  Icons.equalizer_rounded,
                                  color: AppColors.primary,
                                  size: 14,
                                )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scaleXY(begin: 1.0, end: 1.2),
                            const SizedBox(width: 6),
                            Text(
                              "LOSSLESS AUDIO ENGINE • 44.1KHZ",
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF475569),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
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
        .fadeIn(duration: 1.seconds)
        .slideY(begin: 0.05, curve: Curves.easeOutQuart);
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
          child: Column(
            children: [
              Row(
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
                    child:
                        const Icon(
                              Icons.bolt_rounded,
                              color: Color(0xFF0F172A),
                              size: 28,
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scaleXY(
                              begin: 1.0,
                              end: 1.2,
                              duration: 1.seconds,
                              curve: Curves.easeInOut,
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
                  if (_isConnected)
                    IconButton(
                      onPressed: _logoutSpotify,
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFF64748B),
                      ),
                      tooltip: "Logout Spotify",
                    ),
                ],
              ),
              if (!_isConnected) ...[
                const SizedBox(height: 32),
                InkWell(
                  onTap: _connectSpotify,
                  child:
                      Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1DB954), Color(0xFF15803D)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1DB954,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "LINK SPOTIFY ACCOUNT",
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .shimmer(
                            duration: 1.5.seconds,
                            delay: 3.seconds,
                            color: Colors.white54,
                          ),
                ),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 800.ms)
        .slideY(begin: 0.02, curve: Curves.easeOutQuart)
        .scale(begin: const Offset(0.98, 0.98), curve: Curves.easeOutQuart);
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
            height: 114,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  // Decorative top-right orb
                  Positioned(
                    right: -30,
                    top: -30,
                    child:
                        Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    accentColor.withValues(alpha: 0.2),
                                    accentColor.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scaleXY(
                              begin: 1.0,
                              end: 1.15,
                              duration: 3.seconds,
                              curve: Curves.easeInOut,
                            ),
                  ),
                  // Decorative bottom-left orb
                  Positioned(
                    left: -40,
                    bottom: -40,
                    child:
                        Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    accentColor.withValues(alpha: 0.15),
                                    accentColor.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scaleXY(
                              begin: 1.0,
                              end: 1.15,
                              duration: 4.seconds,
                              curve: Curves.easeInOut,
                            )
                            .moveY(
                              begin: -5,
                              end: 5,
                              duration: 3.seconds,
                              curve: Curves.easeInOut,
                            ),
                  ),
                  // Inner glassy border
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // Main Content
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'icon_$title',
                          child:
                              Container(
                                    width: 86,
                                    height: 86,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          accentColor.withValues(alpha: 0.15),
                                          accentColor.withValues(alpha: 0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: accentColor.withValues(
                                          alpha: 0.15,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: isMaterial
                                        ? Icon(
                                            mood['materialIcon'],
                                            color: accentColor,
                                            size: 38,
                                          )
                                        : Center(
                                            child: Image.network(
                                              mood['icon'],
                                              width: 44,
                                              height: 44,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .moveY(
                                    begin: -3,
                                    end: 3,
                                    duration: 2.seconds,
                                    curve: Curves.easeInOut,
                                  ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.outfit(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E293B),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mood['desc'],
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: accentColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (index * 100).ms, duration: 800.ms)
        .slideY(begin: 0.2, curve: Curves.easeOutBack, duration: 800.ms)
        .scaleXY(
          begin: 0.9,
          end: 1.0,
          curve: Curves.easeOutBack,
          duration: 800.ms,
        );
  }
}
