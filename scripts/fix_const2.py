import re
import os

log_file = "C:/Users/Muhammad Krisna/.gemini/antigravity-ide/brain/644b1ac6-d4a0-4cce-bc6e-470c26b6fec0/.system_generated/tasks/task-335.log"
project_dir = "C:/Users/Muhammad Krisna/Documents/ProjectSerius/Project Flutter/P2/adhan_reminder"

with open(log_file, "r", encoding="utf-8") as f:
    lines = f.readlines()

for line in lines:
    if "Invalid constant value" in line or "invalid_constant" in line or "non_constant_list_element" in line:
        match = re.search(r'-\s(lib\\[^:]+):(\d+):(\d+)\s-', line)
        if match:
            filepath = os.path.join(project_dir, match.group(1))
            line_num = int(match.group(2)) - 1 # 0-indexed
            
            if os.path.exists(filepath):
                with open(filepath, "r", encoding="utf-8") as file:
                    file_content = file.readlines()
                
                # Walk backwards from line_num up to 10 lines
                found_const = False
                for i in range(line_num, max(-1, line_num - 10), -1):
                    if "const " in file_content[i]:
                        # Remove the last occurrence of 'const ' (or all of them just in case)
                        file_content[i] = re.sub(r'\bconst\s+', '', file_content[i])
                        found_const = True
                        break
                
                if found_const:
                    with open(filepath, "w", encoding="utf-8") as file:
                        file.writelines(file_content)
                    print(f"Fixed const near {filepath}:{line_num+1}")
                else:
                    print(f"Still could not find 'const' near {filepath}:{line_num+1}")
