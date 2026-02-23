import re

with open("boredom_breaker_mobile/lib/screens/chat/chat_screen.dart", "r") as f:
    content = f.read()

# Replace Background Gradient with Black & Purple Glows
content = re.sub(
    r'Positioned\.fill\(\s.*?(?=Positioned\(\s*top: -150,)',
    '''Positioned.fill(
            child: Container(
              color: const Color(0xFF000000),
            ),
          ),
          ''',
    content,
    flags=re.DOTALL
)

# Replace glows
content = content.replace('Color(0xFF0EA5E9)', 'Color(0xFF6D4EFF)')
content = content.replace('Color(0xFF10B981)', 'Color(0xFF8E2DE2)')

# Replace active indicator dot color explicitly if it was 0xFF10B981, wait I already did.
# Wait, let's fix the user chat bubbles
content = content.replace(
'''                      ? const LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF10B981)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )''',
'''                      ? const LinearGradient(
                          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )'''
)

# And action chip colors
content = content.replace(
'''      side: BorderSide(color: const Color(0xFF10B981).withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      avatar: Icon(icon, color: const Color(0xFF10B981), size: 16),''',
'''      side: BorderSide(color: const Color(0xFF8E2DE2).withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      avatar: Icon(icon, color: const Color(0xFF8E2DE2), size: 16),'''
)

# Replace Icon URL
content = content.replace('https://img.icons8.com/fluency/48/chatbot--v1.png', 'https://img.icons8.com/nolan/64/bot.png')

with open("boredom_breaker_mobile/lib/screens/chat/chat_screen.dart", "w") as f:
    f.write(content)

print("Updated theme and icon")
