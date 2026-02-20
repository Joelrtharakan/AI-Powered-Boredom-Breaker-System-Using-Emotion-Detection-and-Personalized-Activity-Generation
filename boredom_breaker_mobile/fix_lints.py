import re
import glob
import os

def process_file(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    # 1. replace withOpacity(x) with withValues(alpha: x)
    content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)
    
    # 2. replace (_, __) => with (_, _) => (only in history_screen.dart)
    if "history_screen.dart" in file_path:
        content = content.replace('(_, __) =>', '(_, _) =>')
    
    # 3. wrap if statements without blocks with { }
    # This targets something like: if (...) return ...;
    # It will match generic cases safely where it's all on one line.
    content = re.sub(r'if \(([^)]+)\)\s+return\s+([^;]+);', r'if (\1) {\n      return \2;\n    }', content)
    
    # 4. spotify specific
    if "spotify_player_screen.dart" in file_path:
        content = content.replace('onPopInvoked:', 'onPopInvokedWithResult: (didPop, result)')
    
    # 5. history_screen specific string interpolation
    if "history_screen.dart" in file_path:
        # line 701 is probably: "$percent%" or something. Wait, maybe the text interpolation.
        # Let's just fix the basic ones first.
        pass

    # 6. chat_screen unused import
    if "chat_screen.dart" in file_path:
        content = re.sub(r"import '../../theme/app_theme.dart'; *\n", "", content)

    with open(file_path, 'w') as f:
        f.write(content)

base_dir = '/Users/joeltharakan/Documents/AI Boredom System/boredom_breaker_mobile/lib'
files = [
    'screens/chat/chat_screen.dart',
    'screens/history/history_screen.dart',
    'screens/home/dashboard_screen.dart',
    'screens/music/spotify_player_screen.dart',
    'screens/profile/profile_screen.dart',
]

for file in files:
    full_path = os.path.join(base_dir, file)
    if os.path.exists(full_path):
        process_file(full_path)
