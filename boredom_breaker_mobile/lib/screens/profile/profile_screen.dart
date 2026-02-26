import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_client.dart';
import '../../services/session_manager.dart';
import '../login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await _apiClient.client.get('/auth/me');
      if (mounted) {
        setState(() {
          _userData = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        // Handle 401 Unauthorized - Token Expired
        if (e is DioException && e.response?.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Session expired. Please sign in again."),
            ),
          );

          await SessionManager.clearSession();

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to load profile: $e")));
      }
    }
  }

  Future<void> _updateProfilePicture() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isLoading = true);

      // Read bytes and convert to Base64
      final bytes = await image.readAsBytes();
      final String base64Image = base64Encode(bytes);

      // Send to backend
      await _apiClient.client.post(
        '/auth/update-profile-picture',
        data: {'image_base64': base64Image},
      );

      // Refresh profile
      await _fetchProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated!")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update photo: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Glows (Optimized with RadialGradients for smoother transitions)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6D4EFF).withValues(alpha: 0.15),
                    const Color(0xFF6D4EFF).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00C6FF).withValues(alpha: 0.12),
                    const Color(0xFF00C6FF).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6D4EFF)),
                )
              : _userData == null
              ? const Center(
                  child: Text(
                    "No profile data found",
                    style: TextStyle(color: Color(0xFF1E293B)),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Profile Picture
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8E2DE2),
                                    Color(0xFF4A00E0),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF8E2DE2,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 64,
                                backgroundColor: const Color(0xFFF1F5F9),
                                backgroundImage:
                                    _userData!['profile_picture'] != null
                                    ? MemoryImage(
                                        base64Decode(
                                          _userData!['profile_picture'],
                                        ),
                                      )
                                    : null,
                                child: _userData!['profile_picture'] == null
                                    ? const Icon(
                                        Icons.person_rounded,
                                        size: 64,
                                        color: Color(0xFFCBD5E1),
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: _updateProfilePicture,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // User Info
                      _buildInfoTile(
                        "Username",
                        _userData!['username'] ?? "Unknown",
                      ),
                      _buildInfoTile("Email", _userData!['email'] ?? "Unknown"),

                      const SizedBox(height: 32),

                      // Interests
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "YOUR INTERESTS",
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children:
                              (_userData!['interests'] as List<dynamic>? ?? [])
                                  .map((interest) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Text(
                                        interest.toString(),
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF1E293B),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              label == "Username"
                  ? Icons.person_outline_rounded
                  : Icons.email_outlined,
              color: const Color(0xFF6D4EFF),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
