import os
import re

SCREEN_DIR = "screens"

def upgrade_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Strip OLED/Dark backgrounds
    content = re.sub(r'backgroundColor:\s*const\s*Color\(0xFF000000\),.*?\n', 'backgroundColor: Colors.transparent,\n', content)
    content = re.sub(r'backgroundColor:\s*const\s*Color\(0xFF09090B\),.*?\n', 'backgroundColor: Colors.transparent,\n', content)
    content = re.sub(r'backgroundColor:\s*Colors\.black,.*?\n', 'backgroundColor: Colors.transparent,\n', content)
    
    # Strip text color forcing to white where possible, or change to Slate
    content = re.sub(r'color:\s*Colors\.white,', 'color: const Color(0xFF1E293B),', content)
    content = re.sub(r'color:\s*Colors\.white70,', 'color: const Color(0xFF64748B),', content)
    content = re.sub(r'color:\s*Colors\.white54,', 'color: const Color(0xFF94A3B8),', content)
    
    # Swap out some typical neon elements
    content = re.sub(r'Color\(0xFF22D3EE\)', 'Color(0xFF56CFE1)', content) # Cyan to new Cyan
    content = re.sub(r'Color\(0xFFA855F7\)', 'Color(0xFF5E60CE)', content) # Neon purple to Indigo
    
    # Write back
    with open(filepath, 'w') as f:
        f.write(content)

for root, dirs, files in os.walk(SCREEN_DIR):
    for f in files:
        if f.endswith(".dart") and f != "landing_screen.dart":
            upgrade_file(os.path.join(root, f))
print("Done patching.")
