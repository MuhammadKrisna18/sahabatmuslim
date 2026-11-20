import 'dart:convert';
import 'package:adhan_reminder/core/constants/app_strings.dart';
import 'package:adhan_reminder/core/services/storage_service.dart';
import 'package:adhan_reminder/features/adhan/data/models/adhan_schedule_model.dart';

abstract class AdhanLocalDataSource {
  Future<List<AdhanScheduleModel>> getCachedSchedules();
  Future<void> cacheSchedules(List<AdhanScheduleModel> schedules);
  Future<String> getCachedLocationName();
  Future<void> cacheLocationName(String locationName);
  Future<double> getCachedGlobalVolume();
  Future<void> cacheGlobalVolume(double volume);
}

class AdhanLocalDataSourceImpl implements AdhanLocalDataSource {
  final StorageService _storageService;

  static const String _keySchedules = 'schedules';
  static const String _keyLocationName = 'locationName';
  static const String _keyGlobalVolume = 'globalVolume';

  final List<AdhanScheduleModel> _defaultSchedules = [
    AdhanScheduleModel(id: 'Subuh', hour: 4, minute: 21, soundName: AppStrings.defaultAdhanName, soundUrl: AppStrings.defaultAdhanAssetPath),
    AdhanScheduleModel(id: 'Dzuhur', hour: 11, minute: 36, soundName: AppStrings.defaultAdhanName, soundUrl: AppStrings.defaultAdhanAssetPath),
    AdhanScheduleModel(id: 'Ashar', hour: 14, minute: 57, soundName: AppStrings.defaultAdhanName, soundUrl: AppStrings.defaultAdhanAssetPath),
    AdhanScheduleModel(id: 'Maghrib', hour: 17, minute: 29, soundName: AppStrings.defaultAdhanName, soundUrl: AppStrings.defaultAdhanAssetPath),
    AdhanScheduleModel(id: 'Isya', hour: 18, minute: 42, soundName: AppStrings.defaultAdhanName, soundUrl: AppStrings.defaultAdhanAssetPath),
  ];

  AdhanLocalDataSourceImpl({required StorageService storageService})
      : _storageService = storageService;

  @override
  Future<List<AdhanScheduleModel>> getCachedSchedules() async {
    final String? schedulesJson = _storageService.getString(_keySchedules);

    List<AdhanScheduleModel> loadedSchedules = [];
    if (schedulesJson != null) {
      final List<dynamic> decoded = json.decode(schedulesJson);
      loadedSchedules = decoded.map((e) => AdhanScheduleModel.fromJson(e)).toList();
    }

    final isValid = loadedSchedules.length == 5 &&
        loadedSchedules.every((s) => ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'].contains(s.id));

    if (isValid) {
      return loadedSchedules.map((s) {
        if (s.soundUrl == 'assets/makkah.mp3' || s.soundUrl == 'assets/adzan_default.mp3') {
          return AdhanScheduleModel(
            id: s.id,
            hour: s.hour,
            minute: s.minute,
            soundName: AppStrings.defaultAdhanName,
            soundUrl: AppStrings.defaultAdhanAssetPath,
            isLocal: s.isLocal,
            isActive: s.isActive,
            volume: s.volume,
          );
        }
        return s;
      }).toList();
    }

    await cacheSchedules(_defaultSchedules);
    return _defaultSchedules;
  }

  @override
  Future<void> cacheSchedules(List<AdhanScheduleModel> schedules) async {
    final List<Map<String, dynamic>> encoded = schedules.map((e) => e.toJson()).toList();
    await _storageService.setString(_keySchedules, json.encode(encoded));
  }

  @override
  Future<String> getCachedLocationName() async {
    return _storageService.getString(_keyLocationName) ?? '';
  }

  @override
  Future<void> cacheLocationName(String locationName) async {
    await _storageService.setString(_keyLocationName, locationName);
  }

  @override
  Future<double> getCachedGlobalVolume() async {
    final volStr = _storageService.getString(_keyGlobalVolume);
    if (volStr != null) {
      final parsed = double.tryParse(volStr);
      if (parsed != null) return parsed;
    }
    return 1.0;
  }

  @override
  Future<void> cacheGlobalVolume(double volume) async {
    await _storageService.setString(_keyGlobalVolume, volume.toString());
  }
}
