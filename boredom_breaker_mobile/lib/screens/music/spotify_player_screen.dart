import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

    // Pop immediately
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

        // Find playlist, album, or track in parts
        for (int i = 0; i < parts.length - 1; i++) {
          if (parts[i] == 'playlist' ||
              parts[i] == 'album' ||
              parts[i] == 'track' ||
              parts[i] == 'artist') {
            type = parts[i];
            id = parts[i + 1];
            break;
          }
        }
      }

      if (type != null && id != null && id.isNotEmpty) {
        id = id.split('?').first;
        finalUrl = "https://open.spotify.com/embed/$type/$id?utm_source=generator";
      }
    }

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
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
            // Prime the player focus
            _controller.runJavaScript("document.body.click();");
            
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
      );

    _controller.loadRequest(Uri.parse(finalUrl));
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
          // Keep audio playing during transition if needed,
          // but usually cleanup is handled in dispose if crucial.
          // Removing about:blank to prevent sudden stops.
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 350,
                height: 350,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6366F1),
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
                  color: Color(0xFFEC4899),
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
                  color: Color(0xFFF43F5E),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.white.withValues(alpha: 0.75)),
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
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1DB954).withValues(alpha: 0.1),
                            const Color(0xFF191414).withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF1DB954).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1DB954),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Full Playback Mode",
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF0F172A),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      "For non-stop music, use the full app.",
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF64748B),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: _launchInFullApp,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1DB954),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1DB954)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    "Open App",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF6366F1)),
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
                SizedBox(
                  height: 22,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      widget.title.toUpperCase(),
                      maxLines: 1,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                   .shimmer(duration: const Duration(seconds: 3), color: Colors.white.withValues(alpha: 0.3)),
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
          if (!widget.isLoginOnly)
            IconButton(
              icon: const Icon(
                Icons.login_rounded,
                color: Color(0xFF1DB954),
                size: 24,
              ),
              onPressed: () async {
                final success = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SpotifyPlayerScreen(
                      title: "Spotify Login",
                      spotifyUrl: "https://accounts.spotify.com/login",
                      isLoginOnly: true,
                    ),
                    fullscreenDialog: true,
                  ),
                );
                if (success == true) {
                  _controller.reload();
                }
              },
              tooltip: "Login to fix playback",
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
    if (url.startsWith('spotify:')) {
      final parts = url.split(':');
      if (parts.length >= 3) {
        final type = parts[1];
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
