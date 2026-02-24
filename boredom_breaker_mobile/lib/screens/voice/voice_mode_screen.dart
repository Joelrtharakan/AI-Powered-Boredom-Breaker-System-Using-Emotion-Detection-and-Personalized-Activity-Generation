import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/session_manager.dart';

class VoiceModeScreen extends StatefulWidget {
  const VoiceModeScreen({super.key});

  @override
  State<VoiceModeScreen> createState() => _VoiceModeScreenState();
}

class _VoiceModeScreenState extends State<VoiceModeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final Dio _dio = ApiClient().client;

  bool _isListening = false;
  bool _isProcessing = false;

  String _lastWords = '';
  String _lunoReply = "Hi! I'm Luno. How are you feeling today?";
  final List<Map<String, String>> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _initSpeechAndTts();
  }

  void _initSpeechAndTts() async {
    await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
          if (_lastWords.isNotEmpty && !_isProcessing) {
            _processVoiceCommand(_lastWords);
          }
        }
      },
      onError: (error) {
        if (kDebugMode) {
          debugPrint('STT Error: ${error.errorMsg}');
        }
        if (mounted) setState(() => _isListening = false);

        // iOS sometimes throws an error when stopping recording due to silence.
        // If we captured words, force process them anyway!
        if (_lastWords.isNotEmpty && !_isProcessing) {
          _processVoiceCommand(_lastWords);
        } else if (error.errorMsg.contains('retry') && !_isProcessing) {
          _processVoiceCommand(
            "Hi Luno! The audio was silent, so I'm sending a test message. I'm feeling bored and tired today.",
          );
        }
      },
    );

    await _flutterTts.setSharedInstance(true);
    await _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playAndRecord,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
      ],
      IosTextToSpeechAudioMode.defaultMode,
    );

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Greet immediately
    _speak(_lunoReply);

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _toggleListening() async {
    if (_isProcessing) return;

    if (_isListening) {
      await _speechToText.stop();
      if (mounted) setState(() => _isListening = false);
      if (_lastWords.isNotEmpty && !_isProcessing) {
        _processVoiceCommand(_lastWords);
      }
    } else {
      await _flutterTts.stop(); // Stop talking if we start listening
      await Future.delayed(
        const Duration(milliseconds: 300),
      ); // Allow iOS AudioSession to reset
      _lastWords = '';
      _lunoReply = '';

      await _speechToText.listen(onResult: _onSpeechResult);
      if (mounted) setState(() => _isListening = true);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  Future<void> _processVoiceCommand(String transcript) async {
    setState(() {
      _isProcessing = true;
      _isListening = false;
    });

    try {
      final userId = await SessionManager.getUserId() ?? 1;

      final formData = FormData.fromMap({
        'transcript': transcript,
        'user_id': userId.toString(),
        'history': jsonEncode(_conversationHistory),
      });

      final response = await _dio.post('/api/voice/chat', data: formData);

      if (response.statusCode == 200) {
        final reply = response.data['reply'];

        // Update history
        _conversationHistory.add({"role": "user", "content": transcript});
        _conversationHistory.add({"role": "luno", "content": reply});

        setState(() {
          _lunoReply = reply;
          _lastWords = ''; // Clear user words
        });

        await _speak(reply);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Voice API Error: $e");
      }
      setState(() {
        _lunoReply =
            "Sorry, I had trouble understanding that. Could you repeat?";
      });
      await _speak(_lunoReply);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Voice Mode",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1E293B),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF1E293B),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: 100,
            left: -100,
            child: _GlowDisk(color: AppColors.primary.withValues(alpha: 0.1)),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Pulsing Mic
                GestureDetector(
                  onTap: _toggleListening,
                  onLongPress: () {
                    // Tap and hold to simulate a voice command!
                    if (!_isProcessing) {
                      _processVoiceCommand(
                        "It's a beautiful day, but I have absolutely nothing to do right now.",
                      );
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      double scale = 1.0;
                      double opacity = 0.0;

                      if (_isListening) {
                        scale = 1.0 + (_pulseController.value * 0.2);
                        opacity = 0.2 - (_pulseController.value * 0.1);
                      } else if (_isProcessing) {
                        // Fast pulse while thinking
                        scale = 1.0 + (_pulseController.value * 0.1);
                        opacity = 0.3 - (_pulseController.value * 0.15);
                      }

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isListening || _isProcessing) ...[
                            _MicAura(
                              scale: scale * 1.5,
                              opacity: opacity * 0.5,
                            ),
                            _MicAura(scale: scale * 1.2, opacity: opacity),
                          ],
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _isListening
                                    ? AppColors.primaryGradient
                                    : _isProcessing
                                    ? [Colors.deepPurpleAccent, Colors.purple]
                                    : [
                                        Colors.grey.shade800,
                                        Colors.grey.shade900,
                                      ],
                              ),
                              boxShadow: [
                                if (_isListening || _isProcessing)
                                  BoxShadow(
                                    color:
                                        (_isProcessing
                                                ? Colors.purple
                                                : AppColors.primary)
                                            .withValues(alpha: 0.4),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                              ],
                            ),
                            child: Icon(
                              _isProcessing
                                  ? Icons.auto_awesome
                                  : (_isListening
                                        ? Icons.mic_rounded
                                        : Icons.mic_off_rounded),
                              size: 60,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 60),

                Text(
                      _isProcessing
                          ? "Thinking..."
                          : _isListening
                          ? "Listening..."
                          : "Tap to Speak",
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    )
                    .animate(target: (_isListening || _isProcessing) ? 1 : 0)
                    .shimmer(duration: 2.seconds),

                const SizedBox(height: 16),

                // Show User's transcribed text
                if (_lastWords.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      '"$_lastWords"',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const Spacer(flex: 3),

                // Luno's Reply Box
                if (_lunoReply.isNotEmpty && !_isListening)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      _lunoReply,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1E293B),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        elevation: 0,
        child: const Icon(
          Icons.close_rounded,
          color: const Color(0xFF1E293B),
          size: 36,
        ),
      ).animate().scale(delay: 1.seconds),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _MicAura extends StatelessWidget {
  final double scale;
  final double opacity;
  const _MicAura({required this.scale, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _GlowDisk extends StatelessWidget {
  final Color color;
  const _GlowDisk({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 150, spreadRadius: 50)],
      ),
    );
  }
}
