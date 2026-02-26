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
  bool _isClosing = false;
  String _error = "";

  Future<void> _handlePop([dynamic result]) async {
    if (!mounted || _isClosing) return;
    setState(() => _isClosing = true);

    // Stop playback immediately
    try {
      await _controller.loadRequest(Uri.parse('about:blank'));
    } catch (e) {
      debugPrint("Error stopping playback: $e");
    }

    // Determine wait time based on whether we are already in a frame or not,
    // but a small fixed delay ensures the UI has updated to hide the WebView.
    // Also gives time for the 'about:blank' request to process.
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      Navigator.of(context).pop(result);
    }
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

      if (finalUrl.contains("spotify:playlist:")) {
        type = "playlist";
        id = finalUrl.split("spotify:playlist:").last;
      } else if (finalUrl.contains("playlist/")) {
        type = "playlist";
        id = finalUrl.split("playlist/").last.split("?").first;
      } else if (finalUrl.contains("spotify:track:")) {
        type = "track";
        id = finalUrl.split("spotify:track:").last;
      } else if (finalUrl.contains("track/")) {
        type = "track";
        id = finalUrl.split("track/").last.split("?").first;
      }
      id = id?.split(':').first;

      if (type != null && id != null && id.isNotEmpty) {
        finalUrl =
            "https://open.spotify.com/embed/$type/$id?utm_source=generator";
      }
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
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
      ..loadRequest(Uri.parse(finalUrl));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handlePop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(
          0xFFF8FAFC,
        ), // Beautiful soft light gray page
        body: Stack(
          children: [
            // Background Glow (match the Music page)
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(
                    0xFF6366F1,
                  ).withValues(alpha: 0.08), // Soft primary glow
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                            color: const Color(
                              0xFF0F172A,
                            ).withValues(alpha: 0.05),
                          ),
                          bottom: BorderSide(
                            color: const Color(
                              0xFF0F172A,
                            ).withValues(alpha: 0.05),
                          ),
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
                      child: _isClosing
                          ? Container(color: Colors.white)
                          : WebViewWidget(controller: _controller),
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
