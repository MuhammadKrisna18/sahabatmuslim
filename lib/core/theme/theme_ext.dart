import 'package:flutter/material.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';

extension AppContextTheme on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get backgroundColor => isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get surfaceColor => isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get textPrimaryColor => isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondaryColor => isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get borderColor => isDarkMode ? AppColors.borderDark : AppColors.borderLight;
  Color get primaryColor => AppColors.primary;
  Color get accentColor => AppColors.accent;
}
