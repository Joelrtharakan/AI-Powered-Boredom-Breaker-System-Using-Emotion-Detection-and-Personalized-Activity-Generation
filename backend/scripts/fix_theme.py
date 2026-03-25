import re

with open("boredom_breaker_mobile/lib/screens/chat/chat_screen.dart", "r") as f:
    text = f.read()

text = text.replace(
'''          // Dynamic gradient background (Calming Emerald & Blue)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF020617),
                    Color(0xFF0F172A),
                    Color(0xFF064E3B),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
          ),
          // Floating glow accents
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0EA5E9).withOpacity(0.15),
                    blurRadius: 200,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    blurRadius: 200,
                  ),
                ],
              ),
            ),
          ),''',
'''          // Pure Black Background matching Dashboard
          Positioned.fill(
            child: Container(
              color: const Color(0xFF000000), // OLED Black
            ),
          ),
          // Floating glow accents (Purple & Blue)
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8E2DE2).withOpacity(0.15), // Deep Purple
                    blurRadius: 200,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6D4EFF).withOpacity(0.15), // Primary Purple
                    blurRadius: 200,
                  ),
                ],
              ),
            ),
          ),'''
)

text = text.replace(
'''                decoration: BoxDecoration(
                  // Calming Emerald gradient for user
                  gradient: isUser
                      ? const LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF10B981)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isUser ? null : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 6),
                    bottomRight: Radius.circular(isUser ? 6 : 20),
                  ),
                  border: isUser
                      ? null
                      : Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    if (isUser)
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                  ],
                ),''',
'''                decoration: BoxDecoration(
                  // Deep Purple gradient for user to match Dashboard
                  gradient: isUser
                      ? const LinearGradient(
                          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isUser ? null : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 6),
                    bottomRight: Radius.circular(isUser ? 6 : 20),
                  ),
                  border: isUser
                      ? null
                      : Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    if (isUser)
                      BoxShadow(
                        color: const Color(0xFF8E2DE2).withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                  ],
                ),'''
)

text = text.replace(
'''  Widget _buildActionChip(IconData icon, String label, Widget screen) {
    return ActionChip(
      backgroundColor: Colors.white.withOpacity(0.08),
      side: BorderSide(color: const Color(0xFF10B981).withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      avatar: Icon(icon, color: const Color(0xFF10B981), size: 16),''',
'''  Widget _buildActionChip(IconData icon, String label, Widget screen) {
    return ActionChip(
      backgroundColor: Colors.white.withOpacity(0.08),
      side: BorderSide(color: const Color(0xFF6D4EFF).withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      avatar: Icon(icon, color: const Color(0xFF6D4EFF), size: 16),'''
)

text = text.replace('https://img.icons8.com/fluency/48/chatbot--v1.png', 'https://img.icons8.com/nolan/64/bot.png')

text = text.replace(
'''                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),''',
'''                        BoxShadow(
                          color: const Color(0xFF6D4EFF).withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),'''
)

text = text.replace(
'''                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(0.6),''',
'''                              decoration: BoxDecoration(
                                color: const Color(0xFF6D4EFF),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF6D4EFF,
                                    ).withOpacity(0.6),'''
)

text = text.replace(
'''                                  // Send Button Outline Glow based on input state
                                  BoxShadow(
                                    color: hasText
                                        ? const Color(0xFF10B981).withOpacity(0.3)
                                        : Colors.transparent,
                                    blurRadius: 12,
                                  ),''',
'''                                  // Send Button Outline Glow based on input state
                                  BoxShadow(
                                    color: hasText
                                        ? const Color(0xFF6D4EFF).withOpacity(0.3)
                                        : Colors.transparent,
                                    blurRadius: 12,
                                  ),'''
)
text = text.replace(
'''                                        ? const Color(0xFF10B981)
                                        : Colors.white.withOpacity(0.3),''',
'''                                        ? const Color(0xFF6D4EFF)
                                        : Colors.white.withOpacity(0.3),'''
)
text = text.replace(
'''                          ? BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, -5),
                            )''',
'''                          ? BoxShadow(
                              color: const Color(0xFF6D4EFF).withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, -5),
                            )'''
)

with open("boredom_breaker_mobile/lib/screens/chat/chat_screen.dart", "w") as f:
    f.write(text)

print("Theme sync successful")
