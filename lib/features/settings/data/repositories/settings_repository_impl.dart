import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/core/services/storage_service.dart';
import 'package:adhan_reminder/features/settings/domain/entities/app_settings.dart';
import 'package:adhan_reminder/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final StorageService _storage;

  static const String _arabicFontSizeKey = 'arabic_font_size';
  static const String _latinFontSizeKey = 'latin_font_size';
  static const String _themeModeKey = 'theme_mode';
  static const String _showArabicKey = 'show_arabic';
  static const String _showLatinKey = 'show_latin';
  static const String _showTranslationKey = 'show_translation';

  SettingsRepositoryImpl(this._storage);

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final arabicFontSize = _storage.getDouble(_arabicFontSizeKey) ?? 36.0;
      final latinFontSize = _storage.getDouble(_latinFontSizeKey) ?? 14.0;
      final showArabic = _storage.getBool(_showArabicKey) ?? true;
      final showLatin = _storage.getBool(_showLatinKey) ?? true;
      final showTranslation = _storage.getBool(_showTranslationKey) ?? true;
      
      ThemeMode themeMode = ThemeMode.system;
      final themeIdx = _storage.getInt(_themeModeKey);
      if (themeIdx != null && themeIdx >= 0 && themeIdx < ThemeMode.values.length) {
        themeMode = ThemeMode.values[themeIdx];
      }

      return Right(AppSettings(
        arabicFontSize: arabicFontSize,
        latinFontSize: latinFontSize,
        themeMode: themeMode,
        showArabic: showArabic,
        showLatin: showLatin,
        showTranslation: showTranslation,
      ));
    } catch (e) {
      return const Left(CacheFailure('Gagal memuat pengaturan'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(AppSettings settings) async {
    try {
      await _storage.setDouble(_arabicFontSizeKey, settings.arabicFontSize);
      await _storage.setDouble(_latinFontSizeKey, settings.latinFontSize);
      await _storage.setInt(_themeModeKey, settings.themeMode.index);
      await _storage.setBool(_showArabicKey, settings.showArabic);
      await _storage.setBool(_showLatinKey, settings.showLatin);
      await _storage.setBool(_showTranslationKey, settings.showTranslation);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Gagal menyimpan pengaturan'));
    }
  }
}
