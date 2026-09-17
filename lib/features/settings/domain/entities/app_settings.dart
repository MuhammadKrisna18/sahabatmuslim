import 'package:flutter/material.dart';

class AppSettings {
  final double arabicFontSize;
  final double latinFontSize;
  final ThemeMode themeMode;
  final bool showArabic;
  final bool showLatin;
  final bool showTranslation;

  AppSettings({
    this.arabicFontSize = 36.0,
    this.latinFontSize = 14.0,
    this.themeMode = ThemeMode.system,
    this.showArabic = true,
    this.showLatin = true,
    this.showTranslation = true,
  });

  AppSettings copyWith({
    double? arabicFontSize,
    double? latinFontSize,
    ThemeMode? themeMode,
    bool? showArabic,
    bool? showLatin,
    bool? showTranslation,
  }) {
    return AppSettings(
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      latinFontSize: latinFontSize ?? this.latinFontSize,
      themeMode: themeMode ?? this.themeMode,
      showArabic: showArabic ?? this.showArabic,
      showLatin: showLatin ?? this.showLatin,
      showTranslation: showTranslation ?? this.showTranslation,
    );
  }
}
