import re
import os

log_file = "C:/Users/Muhammad Krisna/.gemini/antigravity-ide/brain/644b1ac6-d4a0-4cce-bc6e-470c26b6fec0/.system_generated/tasks/task-335.log"
project_dir = "C:/Users/Muhammad Krisna/Documents/ProjectSerius/Project Flutter/P2/adhan_reminder"

with open(log_file, "r", encoding="utf-8") as f:
    lines = f.readlines()

for line in lines:
    if "Invalid constant value" in line or "invalid_constant" in line or "non_constant_list_element" in line:
        # e.g., "error - Invalid constant value - lib\features\...\surah_detail_screen.dart:202:32 - invalid_constant"
        match = re.search(r'-\s(lib\\[^:]+):(\d+):(\d+)\s-', line)
        if match:
            filepath = os.path.join(project_dir, match.group(1))
            line_num = int(match.group(2)) - 1 # 0-indexed
            
            if os.path.exists(filepath):
                with open(filepath, "r", encoding="utf-8") as file:
                    file_content = file.readlines()
                
                # Check if line_num is within bounds
                if 0 <= line_num < len(file_content):
                    target_line = file_content[line_num]
                    # Attempt to remove 'const '
                    modified_line = re.sub(r'\bconst\s+', '', target_line)
                    if modified_line != target_line:
                        file_content[line_num] = modified_line
                        with open(filepath, "w", encoding="utf-8") as file:
                            file.writelines(file_content)
                        print(f"Fixed const on {filepath}:{line_num+1}")
                    else:
                        print(f"Could not find 'const' on {filepath}:{line_num+1} -> {target_line.strip()}")
