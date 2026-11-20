import 'package:flutter/material.dart';
import 'package:adhan_reminder/features/settings/domain/entities/app_settings.dart';
import 'package:adhan_reminder/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:adhan_reminder/features/settings/domain/usecases/save_settings_usecase.dart';

class SettingsProvider with ChangeNotifier {
  static const double minArabicFontSize = 20.0;
  static const double maxArabicFontSize = 56.0;
  static const double minLatinFontSize = 10.0;
  static const double maxLatinFontSize = 24.0;

  final GetSettingsUseCase _getSettingsUseCase;
  final SaveSettingsUseCase _saveSettingsUseCase;
  
  AppSettings _settings = AppSettings();

  double get arabicFontSize => _settings.arabicFontSize;
  double get latinFontSize => _settings.latinFontSize;
  ThemeMode get themeMode => _settings.themeMode;
  bool get showArabic => _settings.showArabic;
  bool get showLatin => _settings.showLatin;
  bool get showTranslation => _settings.showTranslation;

  SettingsProvider({
    required GetSettingsUseCase getSettingsUseCase,
    required SaveSettingsUseCase saveSettingsUseCase,
  })  : _getSettingsUseCase = getSettingsUseCase,
        _saveSettingsUseCase = saveSettingsUseCase {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final result = await _getSettingsUseCase.execute();
    result.fold(
      (failure) {
        _settings = AppSettings();
      },
      (settings) {
        _settings = settings;
      },
    );
    notifyListeners();
  }

  Future<void> _updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await _saveSettingsUseCase.execute(_settings);
  }

  Future<void> setArabicFontSize(double size) async {
    await _updateSettings(_settings.copyWith(arabicFontSize: size));
  }

  Future<void> setLatinFontSize(double size) async {
    await _updateSettings(_settings.copyWith(latinFontSize: size));
  }

  Future<void> increaseArabicFontSize([double step = 2.0]) async {
    final newSize = (_settings.arabicFontSize + step).clamp(minArabicFontSize, maxArabicFontSize);
    await setArabicFontSize(newSize);
  }

  Future<void> decreaseArabicFontSize([double step = 2.0]) async {
    final newSize = (_settings.arabicFontSize - step).clamp(minArabicFontSize, maxArabicFontSize);
    await setArabicFontSize(newSize);
  }

  Future<void> increaseLatinFontSize([double step = 1.0]) async {
    final newSize = (_settings.latinFontSize + step).clamp(minLatinFontSize, maxLatinFontSize);
    await setLatinFontSize(newSize);
  }

  Future<void> decreaseLatinFontSize([double step = 1.0]) async {
    final newSize = (_settings.latinFontSize - step).clamp(minLatinFontSize, maxLatinFontSize);
    await setLatinFontSize(newSize);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _updateSettings(_settings.copyWith(themeMode: mode));
  }

  Future<void> setShowArabic(bool show) async {
    await _updateSettings(_settings.copyWith(showArabic: show));
  }

  Future<void> setShowLatin(bool show) async {
    await _updateSettings(_settings.copyWith(showLatin: show));
  }

  Future<void> setShowTranslation(bool show) async {
    await _updateSettings(_settings.copyWith(showTranslation: show));
  }
}
