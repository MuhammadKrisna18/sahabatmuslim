import 'package:flutter/material.dart';
import 'package:adhan_reminder/core/services/storage_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storage;
  
  static const String _arabicFontSizeKey = 'arabic_font_size';
  static const String _latinFontSizeKey = 'latin_font_size';
  static const String _themeModeKey = 'theme_mode';

  double _arabicFontSize = 36.0;
  double _latinFontSize = 14.0;
  ThemeMode _themeMode = ThemeMode.system;

  double get arabicFontSize => _arabicFontSize;
  double get latinFontSize => _latinFontSize;
  ThemeMode get themeMode => _themeMode;

  SettingsProvider({required StorageService storageService}) : _storage = storageService {
    _loadSettings();
  }

  void _loadSettings() {
    _arabicFontSize = _storage.getDouble(_arabicFontSizeKey) ?? 36.0;
    _latinFontSize = _storage.getDouble(_latinFontSizeKey) ?? 14.0;
    
    final themeIdx = _storage.getInt(_themeModeKey);
    if (themeIdx != null && themeIdx >= 0 && themeIdx < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIdx];
    }
    
    notifyListeners();
  }

  Future<void> setArabicFontSize(double size) async {
    _arabicFontSize = size;
    notifyListeners();
    await _storage.setDouble(_arabicFontSizeKey, size);
  }

  Future<void> setLatinFontSize(double size) async {
    _latinFontSize = size;
    notifyListeners();
    await _storage.setDouble(_latinFontSizeKey, size);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _storage.setInt(_themeModeKey, mode.index);
  }
}
