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
      // Create passcode
      final newPasscode = await _showPasscodeDialog("Create Passcode");
      if (newPasscode != null && newPasscode.isNotEmpty) {
        await SessionManager.saveLockboxPasscode(newPasscode);
        setState(() => _hasPasscode = true);
        _proceedToUnlock();
      }
    } else {
      // Enter passcode
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
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(title, style: GoogleFonts.outfit(color: Colors.white)),
          content: TextField(
            controller: passcodeController,
            obscureText: true,
            maxLength: 6,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(
              color: Colors.white,
              letterSpacing: 8,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "••••••",
              hintStyle: GoogleFonts.inter(color: Colors.white30),
              counterText: "",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add to Vault",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Label (e.g. Diary, Passwords)",
                hintStyle: GoogleFonts.inter(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: secretController,
              style: GoogleFonts.inter(color: Colors.white),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Your deepest secret...",
                hintStyle: GoogleFonts.inter(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(
                  "Encrypt & Save",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
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

        // AES Encrypt using passcode
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

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        final base64String = response.data['encrypted_data_base64'];

        final passcode = await SessionManager.getLockboxPasscode() ?? "000000";
        final keyString = passcode.padRight(32, '0');
        final key = enc.Key.fromUtf8(keyString);
        final iv = enc.IV.fromUtf8(keyString.substring(0, 16));
        final zeroIv = enc.IV.fromLength(16); // The old IV previously used

        final encrypterCBC = enc.Encrypter(
          enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'),
        );
        final encrypterSIC = enc.Encrypter(enc.AES(key));

        String secretText = "Error decrypting...";
        try {
          // Attempt 1: The new CBC method
          secretText = encrypterCBC.decrypt64(base64String, iv: iv);
        } catch (e1) {
          try {
            // Attempt 2: The old CTR/SIC method (without padding, zero IV)
            secretText = encrypterSIC.decrypt64(base64String, iv: zeroIv);
          } catch (e2) {
            // Attempt 3: Prior simply base64 encoded string data
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

        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(label, style: GoogleFonts.outfit(color: Colors.white)),
            content: SingleChildScrollView(
              child: Text(
                secretText,
                style: GoogleFonts.inter(
                  color: isCorrupt ? Colors.redAccent : Colors.white70,
                  height: 1.6,
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
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: Text(
                  "Close",
                  style: GoogleFonts.inter(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isLocked ? "Private Lockbox" : "Unlocked Vault",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLocked)
            IconButton(
              icon: const Icon(Icons.lock_rounded, color: AppColors.primary),
              onPressed: () {
                setState(() {
                  _isLocked = true;
                  _secrets = [];
                });
              },
            ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLocked ? _buildLockedState() : _buildUnlockedState(),
      floatingActionButton: !_isLocked && !_isLoading
          ? FloatingActionButton.extended(
              onPressed: _addSecret,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                "Add Secret",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ).animate().slideY(begin: 1.0)
          : null,
    );
  }

  Widget _buildLockedState() {
    return Stack(
      children: [
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.1),
                  blurRadius: 150,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3.seconds),
              const SizedBox(height: 48),
              if (_isLoading)
                const CircularProgressIndicator(color: AppColors.primary)
              else ...[
                Text(
                  "Deep Security",
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn().slideY(begin: 0.1),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Text(
                    "Your personal space, encrypted and protected. High-end privacy for your thoughts.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 56),
                _buildModernButton(
                  _hasPasscode ? "Enter Passcode" : "Create Passcode",
                  _unlockVault,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockedState() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_secrets.isEmpty) {
      return Center(
        child: Text(
          "Your vault is empty.\nStore your innermost secrets here.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['label'],
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Stored on ${DateFormat('MMM dd, yyyy').format(cDate)}",
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.remove_red_eye_rounded, color: Colors.white30),
              ],
            ),
          ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1),
        );
      },
    );
  }

  Widget _buildModernButton(String label, VoidCallback onPressed) {
    return Container(
      width: 240,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: AppColors.primaryGradient),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
