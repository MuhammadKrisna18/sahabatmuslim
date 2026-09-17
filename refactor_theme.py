import os
import re

lib_dir = "C:/Users/Muhammad Krisna/Documents/ProjectSerius/Project Flutter/P2/adhan_reminder/lib"

replacements = {
    "AppColors.backgroundDark": "context.backgroundColor",
    "AppColors.backgroundLight": "context.backgroundColor",
    "AppColors.surfaceDark": "context.surfaceColor",
    "AppColors.surfaceLight": "context.surfaceColor",
    "AppColors.textPrimaryDark": "context.textPrimaryColor",
    "AppColors.textPrimaryLight": "context.textPrimaryColor",
    "AppColors.textSecondaryDark": "context.textSecondaryColor",
    "AppColors.textSecondaryLight": "context.textSecondaryColor",
    "AppColors.borderDark": "context.borderColor",
    "AppColors.borderLight": "context.borderColor",
}

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    modified = False

    for old, new in replacements.items():
        if old in content:
            content = content.replace(old, new)
            modified = True

    if modified:
        if "theme_ext.dart" not in content:
            import_statement = "import 'package:adhan_reminder/core/theme/theme_ext.dart';\n"
            # Find the last import
            imports = list(re.finditer(r"^import\s+['\"].*?['\"];$", content, re.MULTILINE))
            if imports:
                last_import = imports[-1]
                insert_pos = last_import.end() + 1
                content = content[:insert_pos] + import_statement + content[insert_pos:]
            else:
                content = import_statement + content

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Refactored: {filepath}")

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith(".dart") and not file.endswith("app_colors.dart") and not file.endswith("theme_ext.dart") and not file.endswith("app_theme.dart"):
            process_file(os.path.join(root, file))

print("Done refactoring.")
