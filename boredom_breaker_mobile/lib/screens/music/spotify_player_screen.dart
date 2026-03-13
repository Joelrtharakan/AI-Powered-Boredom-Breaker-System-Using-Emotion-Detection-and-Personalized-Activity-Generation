import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyPlayerScreen extends StatefulWidget {
  final String title;
  final String spotifyUrl;
  final bool isLoginOnly;

  const SpotifyPlayerScreen({
    super.key,
    required this.title,
    required this.spotifyUrl,
    this.isLoginOnly = false,
  });

  @override
  State<SpotifyPlayerScreen> createState() => _SpotifyPlayerScreenState();
}

class _SpotifyPlayerScreenState extends State<SpotifyPlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _error = "";

  void _handlePop([dynamic result]) {
    if (!mounted) return;

    // Stop playback immediately
    try {
      _controller.loadRequest(Uri.parse('about:blank'));
    } catch (e) {
      debugPrint("Error stopping playback: $e");
    }

    // Pop immediately to unleash the silky smooth native flutter route animation!
    Navigator.of(context).pop(result);
  }

  @override
  void initState() {
    super.initState();

    String finalUrl = widget.spotifyUrl;

    if (widget.isLoginOnly) {
      finalUrl = "https://accounts.spotify.com/login";
    } else {
      String? type;
      String? id;

      // Handle URIs (spotify:track:ID)
      if (finalUrl.contains("spotify:")) {
        final uriParts = finalUrl.split(':');
        if (uriParts.length >= 3) {
          type = uriParts[1];
          id = uriParts[2];
        }
      }
      // Handle URLs (open.spotify.com/track/ID)
      else if (finalUrl.contains("spotify.com/")) {
        final path = finalUrl.split("spotify.com/").last.split("?").first;
        final parts = path.split('/');
        if (parts.length >= 2) {
          type = parts[0];
          id = parts[1];
        }
      }

      if (type != null && id != null && id.isNotEmpty) {
        // ID might still have query params if split failed
        id = id.split('?').first;
        finalUrl =
            "https://open.spotify.com/embed/$type/$id?utm_source=generator";
      }
    }

    debugPrint("DEBUG: Loading Spotify URL: $finalUrl");

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(
        "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = "";
            });
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            if (widget.isLoginOnly &&
                !url.contains("accounts.spotify.com") &&
                url.contains("spotify.com")) {
              _handlePop(true);
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("Spotify WebView Error: ${error.description}");
            setState(() {
              _isLoading = false;
              _error = error.description;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(finalUrl),
        headers: {
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
        },
      );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          try {
            _controller.loadRequest(Uri.parse('about:blank'));
          } catch (e) {
            // Ignore if controller is already disposed
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white, // Base background
        body: Stack(
          children: [
            // Vibrant Animated Background Gradient Orbs Match Music Page
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 350,
                height: 350,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6366F1), // Indigo
                ),
              ),
            ),
            Positioned(
              top: 100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEC4899), // Pink
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF43F5E), // Rose
                ),
              ),
            ),
            // Heavy Frosted Glass Overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  color: Colors.white.withValues(
                    alpha: 0.75,
                  ), // Lightens it for light theme
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: Container(
                      margin: widget.isLoginOnly
                          ? EdgeInsets.zero
                          : const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          widget.isLoginOnly ? 0 : 24,
                        ),
                        border: Border.all(
                          color: const Color(
                            0xFF0F172A,
                          ).withValues(alpha: 0.05),
                        ),
                        boxShadow: [
                          if (!widget.isLoginOnly)
                            BoxShadow(
                              color: const Color(
                                0xFF0F172A,
                              ).withValues(alpha: 0.08),
                              blurRadius: 32,
                              offset: const Offset(0, 16),
                            ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          widget.isLoginOnly ? 0 : 24,
                        ),
                        child: Container(
                          color: Colors.white,
                          child: WebViewWidget(controller: _controller),
                        ),
                      ),
                    ),
                  ),
                  if (!widget.isLoginOnly) ...[
                    const SizedBox(height: 12),
                    // Preview limitation banner
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DB954).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF1DB954).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF16A34A),
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Preview only · Open in Spotify for full playback",
                              style: GoogleFonts.inter(
                                color: const Color(0xFF475569),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _launchInFullApp,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1DB954),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1DB954,
                                    ).withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                "Open",
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6366F1),
                ), // Primary
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              widget.isLoginOnly
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.close_rounded,
              color: const Color(0xFF475569),
              size: 24,
            ),
            onPressed: () => _handlePop(false),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                if (_error.isNotEmpty)
                  Text(
                    "CONNECTION ERROR",
                    style: GoogleFonts.inter(
                      color: Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF94A3B8),
              size: 24,
            ),
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            icon: const Icon(
              Icons.open_in_new_rounded,
              color: Color(0xFF94A3B8),
              size: 24,
            ),
            onPressed: () => _launchInFullApp(),
            tooltip: "Open in App",
          ),
        ],
      ),
    );
  }

  Future<void> _launchInFullApp() async {
    String url = widget.spotifyUrl;

    // Convert spotify:playlist:ID or spotify:track:ID to a proper URL
    if (url.startsWith('spotify:')) {
      final parts = url.split(':'); // ["spotify", "playlist", "ID"]
      if (parts.length >= 3) {
        final type = parts[1]; // "playlist" or "track"
        final id = parts[2];
        url = 'https://open.spotify.com/$type/$id';
      }
    }

    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Failed to launch Spotify: $e");
    }
  }
}
