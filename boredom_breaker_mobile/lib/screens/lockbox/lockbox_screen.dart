import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:encrypt/encrypt.dart' as enc;
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/session_manager.dart';

class LockboxScreen extends StatefulWidget {
  const LockboxScreen({super.key});

  @override
  State<LockboxScreen> createState() => _LockboxScreenState();
}

class _LockboxScreenState extends State<LockboxScreen> {
  bool _isLocked = true;
  bool _isLoading = false;
  bool _hasPasscode = false;
  List<dynamic> _secrets = [];

  @override
  void initState() {
    super.initState();
    _checkPasscode();
  }

  Future<void> _checkPasscode() async {
    final passcode = await SessionManager.getLockboxPasscode();
    setState(() {
      _hasPasscode = passcode != null && passcode.isNotEmpty;
    });
  }

  Future<void> _unlockVault() async {
    final correctPasscode = await SessionManager.getLockboxPasscode();

    if (!_hasPasscode) {
      final newPasscode = await _showPasscodeDialog("Create Passcode");
      if (newPasscode != null && newPasscode.isNotEmpty) {
        await SessionManager.saveLockboxPasscode(newPasscode);
        setState(() => _hasPasscode = true);
        _proceedToUnlock();
      }
    } else {
      final enteredPasscode = await _showPasscodeDialog("Enter Passcode");
      if (enteredPasscode == correctPasscode) {
        _proceedToUnlock();
      } else if (enteredPasscode != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Incorrect Passcode", style: GoogleFonts.inter()),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  Future<void> _resetPasscode() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Reset Passcode",
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          "This will remove your current passcode and allow you to create a new one.\n\n⚠️ Warning: Previously encrypted secrets may become unreadable with a new passcode.",
          style: GoogleFonts.inter(
            color: const Color(0xFF64748B),
            fontSize: 14,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.redAccent,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                "Reset",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SessionManager.clearLockboxPasscode();
      setState(() {
        _hasPasscode = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Passcode reset. You can create a new one.",
              style: GoogleFonts.inter(),
            ),
            backgroundColor: const Color(0xFF5E60CE),
          ),
        );
      }
    }
  }

  Future<void> _proceedToUnlock() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isLocked = false;
    });
    await _fetchSecrets();
  }

  Future<String?> _showPasscodeDialog(String title) async {
    final passcodeController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            title,
            style: GoogleFonts.outfit(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: passcodeController,
                  obscureText: true,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF1E293B),
                    letterSpacing: 8,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "••••••",
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFFCBD5E1),
                    ),
                    counterText: "",
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF5E60CE), Color(0xFF4EA8DE)],
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                ),
                onPressed: () =>
                    Navigator.pop(context, passcodeController.text.trim()),
                child: Text(
                  "Submit",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchSecrets() async {
    setState(() => _isLoading = true);
    try {
      final userId = await SessionManager.getUserId();
      if (userId != null) {
        final response = await ApiClient().client.get(
          '/lockbox/list',
          queryParameters: {'user_id': userId},
        );
        if (response.statusCode == 200) {
          setState(() {
            _secrets = response.data;
          });
        }
      }
    } catch (e) {
      debugPrint("Lockbox fetch error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addSecret() async {
    final titleController = TextEditingController();
    final secretController = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 28,
          right: 28,
          top: 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Add to Vault",
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E293B),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Your secret will be encrypted and stored securely.",
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            // Label field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: titleController,
                style: GoogleFonts.inter(color: const Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: "Label (e.g. Diary, Passwords)",
                  hintStyle: GoogleFonts.inter(color: const Color(0xFFCBD5E1)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Secret field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: secretController,
                style: GoogleFonts.inter(color: const Color(0xFF1E293B)),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Your deepest secret...",
                  hintStyle: GoogleFonts.inter(color: const Color(0xFFCBD5E1)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Submit button with gradient
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF5E60CE), Color(0xFF4EA8DE)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4EA8DE).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(
                  "Encrypt & Save",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );

    if (result == true) {
      final label = titleController.text.trim();
      final secret = secretController.text.trim();
      if (label.isEmpty || secret.isEmpty) return;

      try {
        setState(() => _isLoading = true);
        final userId = await SessionManager.getUserId();

        final passcode = await SessionManager.getLockboxPasscode() ?? "000000";
        final keyString = passcode.padRight(32, '0');
        final key = enc.Key.fromUtf8(keyString);
        final iv = enc.IV.fromUtf8(keyString.substring(0, 16));
        final encrypter = enc.Encrypter(
          enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'),
        );

        final encrypted = encrypter.encrypt(secret, iv: iv);
        final base64String = encrypted.base64;

        await ApiClient().client.post(
          '/lockbox/save',
          data: {
            'user_id': userId,
            'label': label,
            'encrypted_data_base64': base64String,
          },
        );
        await _fetchSecrets();
      } catch (e) {
        debugPrint("Save secret error: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _viewSecret(int id, String label) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      final response = await ApiClient().client.post(
        '/lockbox/unlock',
        data: {'id': id},
      );

      if (mounted) {
        Navigator.pop(context);
      }

      if (response.statusCode == 200) {
        final base64String = response.data['encrypted_data_base64'];

        final passcode = await SessionManager.getLockboxPasscode() ?? "000000";
        final keyString = passcode.padRight(32, '0');
        final key = enc.Key.fromUtf8(keyString);
        final iv = enc.IV.fromUtf8(keyString.substring(0, 16));
        final zeroIv = enc.IV.fromLength(16);

        final encrypterCBC = enc.Encrypter(
          enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'),
        );
        final encrypterSIC = enc.Encrypter(enc.AES(key));

        String secretText = "Error decrypting...";
        try {
          secretText = encrypterCBC.decrypt64(base64String, iv: iv);
        } catch (e1) {
          try {
            secretText = encrypterSIC.decrypt64(base64String, iv: zeroIv);
          } catch (e2) {
            try {
              final bytes = base64.decode(base64String);
              secretText = utf8.decode(bytes);
            } catch (e3) {
              debugPrint(
                "All decryption fallbacks failed. CBC Error: $e1. SIC Error: $e2. B64 Error: $e3",
              );
              secretText = "Corrupted or unreadable lockbox data.";
            }
          }
        }

        bool isCorrupt = secretText.contains(
          "Corrupted or unreadable lockbox data",
        );

        if (mounted) {
          showDialog(
            context: context,
            builder: (c) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                label,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    secretText,
                    style: GoogleFonts.inter(
                      color: isCorrupt
                          ? Colors.redAccent
                          : const Color(0xFF334155),
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(c);
                    await _deleteSecret(id);
                  },
                  child: Text(
                    "Delete",
                    style: GoogleFonts.inter(color: Colors.red),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5E60CE), Color(0xFF4EA8DE)],
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () => Navigator.pop(c),
                    child: Text(
                      "Close",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
      debugPrint("Read secret error: $e");
    }
  }

  Future<void> _deleteSecret(int id) async {
    try {
      setState(() => _isLoading = true);
      await ApiClient().client.delete('/lockbox/$id');
      await _fetchSecrets();
    } catch (e) {
      debugPrint("Delete error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Vibrant Gradient Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _isLocked ? size.height * 0.55 : size.height * 0.28,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutQuart,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF5E60CE),
                    Color(0xFF4EA8DE),
                    Color(0xFF56CFE1),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: 50,
                    right: -50,
                    child:
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ).animate().scale(
                          duration: 1.seconds,
                          curve: Curves.easeOutBack,
                        ),
                  ),
                  Positioned(
                    top: 140,
                    left: -40,
                    child:
                        Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            )
                            .animate(delay: 200.ms)
                            .scale(
                              duration: 1.seconds,
                              curve: Curves.easeOutBack,
                            ),
                  ),
                  if (_isLocked)
                    Positioned(
                      bottom: 80,
                      right: 30,
                      child:
                          Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              )
                              .animate(delay: 400.ms)
                              .scale(
                                duration: 1.seconds,
                                curve: Curves.easeOutBack,
                              ),
                    ),

                  // Header content
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              if (!_isLocked)
                                IconButton(
                                  icon: const Icon(
                                    Icons.lock_rounded,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isLocked = true;
                                      _secrets = [];
                                    });
                                  },
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                      _isLocked
                                          ? "Private Lockbox"
                                          : "Unlocked Vault",
                                      style: GoogleFonts.outfit(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 200.ms)
                                    .slideX(begin: -0.1),
                                const SizedBox(height: 4),
                                Text(
                                      _isLocked
                                          ? "Encrypted & protected"
                                          : "Your secrets are revealed",
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        color: Colors.white70,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 300.ms)
                                    .slideX(begin: -0.1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. White content area
          Positioned(
            top: _isLocked ? size.height * 0.50 : size.height * 0.24,
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutQuart,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                  top: Radius.circular(32),
                ),
                child: _isLocked
                    ? _buildLockedContent()
                    : _buildUnlockedContent(),
              ),
            ),
          ),

          // Lock icon floating between gradient and white (only when locked)
          if (_isLocked)
            Positioned(
              top: size.height * 0.44,
              left: 0,
              right: 0,
              child: Center(
                child:
                    Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF5E60CE,
                                ).withValues(alpha: 0.25),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_person_rounded,
                            size: 44,
                            color: Color(0xFF5E60CE),
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .slideY(
                          begin: -0.05,
                          end: 0.05,
                          duration: 2.seconds,
                          curve: Curves.easeInOutSine,
                        ),
              ),
            ),
        ],
      ),

      // FAB
      floatingActionButton: !_isLocked && !_isLoading
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF5E60CE), Color(0xFF4EA8DE)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4EA8DE).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _addSecret,
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  "Add Secret",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate().slideY(begin: 1.0)
          : null,
    );
  }

  Widget _buildLockedContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
      child: Column(
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else ...[
            Text(
              "Deep Security",
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            const SizedBox(height: 12),
            Text(
              "Your personal space, encrypted and protected.\nHigh-end privacy for your thoughts.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 15,
                height: 1.6,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
            const SizedBox(height: 44),
            // Unlock button with gradient
            Container(
                  width: 240,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5E60CE), Color(0xFF4EA8DE)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4EA8DE).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _unlockVault,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _hasPasscode ? "Enter Passcode" : "Create Passcode",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms)
                .scale(begin: const Offset(0.9, 0.9)),
            if (_hasPasscode) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: _resetPasscode,
                child: Text(
                  "Forgot Passcode?",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF94A3B8),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildUnlockedContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_secrets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_rounded,
              size: 64,
              color: const Color(0xFF94A3B8).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "Your vault is empty.\nStore your innermost secrets here.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
      itemCount: _secrets.length,
      itemBuilder: (context, index) {
        final item = _secrets[index];
        DateTime cDate;
        try {
          cDate = DateTime.parse(item['created_at']);
        } catch (_) {
          cDate = DateTime.now();
        }

        return GestureDetector(
          onTap: () => _viewSecret(item['id'], item['label']),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5E60CE).withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF5E60CE).withValues(alpha: 0.12),
                        const Color(0xFF4EA8DE).withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Color(0xFF5E60CE),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['label'],
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1E293B),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Stored on ${DateFormat('MMM dd, yyyy').format(cDate)}",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5E60CE).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.remove_red_eye_rounded,
                    color: Color(0xFF5E60CE),
                    size: 18,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.08),
        );
      },
    );
  }
}
