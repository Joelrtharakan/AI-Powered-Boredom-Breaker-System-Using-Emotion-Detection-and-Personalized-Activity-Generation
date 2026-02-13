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
            "https://open.spotify.com/embed/$type/$id?utm_source=generator&theme=0";
      }
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F0F12))
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
              Navigator.pop(context, true);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Stack(
        children: [
          // Background Glow for immersive feel
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6D4EFF).withValues(alpha: 0.12),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(widget.isLoginOnly ? 0 : 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        widget.isLoginOnly ? 0 : 32,
                      ),
                      boxShadow: [
                        if (!widget.isLoginOnly)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 40,
                            spreadRadius: -10,
                          ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        widget.isLoginOnly ? 0 : 32,
                      ),
                      child: WebViewWidget(controller: _controller),
                    ),
                  ),
                ),
                if (!widget.isLoginOnly) const SizedBox(height: 20),
              ],
            ),
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF4EEBFF)),
            ),
        ],
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
              color: Colors.white70,
              size: 22,
            ),
            onPressed: () => Navigator.pop(context, false),
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
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
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
              color: Colors.white38,
              size: 22,
            ),
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            icon: const Icon(
              Icons.open_in_new_rounded,
              color: Colors.white38,
              size: 22,
            ),
            onPressed: () => _launchInFullApp(),
            tooltip: "Open in App",
          ),
        ],
      ),
    );
  }

  Future<void> _launchInFullApp() async {
    final uri = Uri.parse(widget.spotifyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
