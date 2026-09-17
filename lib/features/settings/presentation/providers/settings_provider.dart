import 'package:flutter/material.dart';
import 'package:adhan_reminder/features/settings/domain/entities/app_settings.dart';
import 'package:adhan_reminder/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:adhan_reminder/features/settings/domain/usecases/save_settings_usecase.dart';

class SettingsProvider with ChangeNotifier {
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
        // Fallback to default if fail
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
