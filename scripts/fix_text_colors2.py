import os
import re

lib_dir = "C:/Users/Muhammad Krisna/Documents/ProjectSerius/Project Flutter/P2/adhan_reminder/lib"

def process_file(filepath):
    # Skip dynamic scaffold
    if "dynamic_scaffold.dart" in filepath.replace("\\", "/"):
        return

    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    modified = False
    for i, line in enumerate(lines):
        if "color: context.backgroundColor" in line and ".withOpacity(" not in line:
            lines[i] = line.replace("color: context.backgroundColor", "color: context.textPrimaryColor")
            modified = True

    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(lines)
        print(f"Fixed remaining text colors in: {filepath}")

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith(".dart"):
            process_file(os.path.join(root, file))

print("Done fixing remaining text colors.")
