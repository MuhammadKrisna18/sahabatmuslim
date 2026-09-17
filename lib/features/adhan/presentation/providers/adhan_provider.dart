import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:adhan_reminder/core/services/alarm_service.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';
import 'package:adhan_reminder/features/adhan/data/models/adhan_schedule_model.dart';
import 'package:adhan_reminder/features/adhan/domain/usecases/get_prayer_times_usecase.dart';
import 'package:adhan_reminder/core/services/storage_service.dart';
import 'package:adhan_reminder/core/constants/app_strings.dart';

class AdhanProvider with ChangeNotifier {
  final GetPrayerTimesUseCase _getPrayerTimesUseCase;
  final StorageService _storage;
  final AlarmService _alarmService;

  AdhanProvider({
    required GetPrayerTimesUseCase getPrayerTimesUseCase,
    required StorageService storageService,
    required AlarmService alarmService,
  })  : _getPrayerTimesUseCase = getPrayerTimesUseCase,
        _storage = storageService,
        _alarmService = alarmService {
    _loadSchedules();
    _startClock();
  }
  List<AdhanSchedule> _schedules = [];
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();
  String _locationName = '';
  double _globalVolume = 1.0;
  String? _errorMessage;

  List<AdhanSchedule> get schedules => _schedules;
  DateTime get currentTime => _currentTime;
  String get locationName => _locationName;
  double get globalVolume => _globalVolume;
  String? get errorMessage => _errorMessage;

  final List<AdhanSchedule> _defaultSchedules = [
    AdhanSchedule(id: 'Subuh', hour: 4, minute: 21, soundName: AppStrings.defaultAdhanName, soundUrl: AppStrings.defaultAdhanAssetPath),
    AdhanSchedule(id: 'Dzuhur', hour: 11, minute: 36, soundName: AppStrings.defaultAdhanName, soundUrl: AppStrings.defaultAdhanAssetPath),
    AdhanSchedule(id: 'Ashar', hour: 14, minute: 57, soundName: AppStrings.defaultAdhanName, soundUrl: AppStrings.defaultAdhanAssetPath),
    AdhanSchedule(id: 'Maghrib', hour: 17, minute: 29, soundName: AppStrings.defaultAdhanName, soundUrl: AppStrings.defaultAdhanAssetPath),
    AdhanSchedule(id: 'Isya', hour: 18, minute: 42, soundName: AppStrings.defaultAdhanName, soundUrl: AppStrings.defaultAdhanAssetPath),
  ];

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    final String? schedulesJson = _storage.getString('schedules');
    _locationName = _storage.getString('locationName') ?? '';
    final volStr = _storage.getString('globalVolume');
    _globalVolume = volStr != null ? double.parse(volStr) : 1.0;

    List<AdhanSchedule> loadedSchedules = [];
    if (schedulesJson != null) {
      final List<dynamic> decoded = json.decode(schedulesJson);
      loadedSchedules = decoded.map((e) => AdhanScheduleModel.fromJson(e).toEntity()).toList();
    }

    bool isValid = loadedSchedules.length == 5 &&
        loadedSchedules.every((s) => ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'].contains(s.id));

    if (isValid) {
      _schedules = loadedSchedules.map((s) {
        if (s.soundUrl == 'assets/makkah.mp3' || s.soundUrl == 'assets/adzan_default.mp3') {
          return AdhanSchedule(
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
    } else {
      _schedules = _defaultSchedules;
      await _saveSchedules();
    }
    _sortSchedules();
    notifyListeners();

    await fetchLocationAndCalculatePrayerTimes();
    _scheduleAlarms();
  }

  Future<void> fetchLocationAndCalculatePrayerTimes() async {
    _errorMessage = null;
    final result = await _getPrayerTimesUseCase.execute(_schedules);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (data) async {
        _locationName = data.locationName;
        _schedules = data.schedules;
        _sortSchedules();
        notifyListeners();
        await _saveSchedules();
        updateWidgetData();
      }
    );
  }

  Future<void> updateWidgetData() async {
    try {
      final nextSched = nextSchedule;
      if (nextSched != null) {
        await HomeWidget.saveWidgetData<String>('next_adhan_name', nextSched.id);
        await HomeWidget.saveWidgetData<String>('next_adhan_time', nextSched.formattedTime);
        await HomeWidget.saveWidgetData<String>('location_name', _locationName);
        await HomeWidget.updateWidget(androidName: 'PrayerWidgetProvider');
      }
    } catch (e) {
      debugPrint('Error updating home widget: $e');
    }
  }

  Future<void> _saveSchedules() async {
    final List<Map<String, dynamic>> encoded =
        _schedules.map((e) => AdhanScheduleModel.fromEntity(e).toJson()).toList();
    _storage.setString('schedules', json.encode(encoded));
    _storage.setString('locationName', _locationName);
    _storage.setString('globalVolume', _globalVolume.toString());
  }

  void setGlobalVolume(double volume) {
    _globalVolume = volume;
    notifyListeners();
    _saveSchedules();
    _scheduleAlarms();
  }

  void _sortSchedules() {
    _schedules.sort((a, b) {
      int aMinutes = a.hour * 60 + a.minute;
      int bMinutes = b.hour * 60 + b.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentTime = DateTime.now();
      notifyListeners();
    });
  }

  Future<void> _scheduleAlarms() async {
    if (kIsWeb) return;

    for (int i = 0; i < _schedules.length; i++) {
      final schedule = _schedules[i];
      final alarmId = i + 1;

      if (!schedule.isActive) {
        await _alarmService.stopAlarm(alarmId);
        continue;
      }

      if (await _alarmService.isRinging(alarmId)) {
        continue;
      }

      DateTime now = DateTime.now();
      DateTime alarmTime = DateTime(
        now.year,
        now.month,
        now.day,
        schedule.hour,
        schedule.minute,
      );

      if (alarmTime.isBefore(now)) {
        alarmTime = alarmTime.add(const Duration(days: 1));
      }

      if (schedule.id.toLowerCase() == 'dzuhur' && alarmTime.weekday == DateTime.friday) {
        await _alarmService.stopAlarm(alarmId);
        continue;
      }

      await _alarmService.scheduleAdhan(
        id: alarmId,
        dateTime: alarmTime,
        audioPath: schedule.soundUrl,
        volume: _globalVolume,
        title: 'Waktunya Adzan ${schedule.id}!',
        body: 'Jadwal sholat pada ${schedule.formattedTime} telah tiba.',
      );
    }
  }

  void toggleSchedule(String id, bool isActive) {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      final old = _schedules[index];
      _schedules[index] = AdhanSchedule(
        id: old.id,
        hour: old.hour,
        minute: old.minute,
        soundName: old.soundName,
        soundUrl: old.soundUrl,
        isLocal: old.isLocal,
        isActive: isActive,
        volume: old.volume,
      );
      notifyListeners();
      _saveSchedules();
      _scheduleAlarms();
      updateWidgetData();
    }
  }

  void updateSchedule(AdhanSchedule newSchedule) {
    final index = _schedules.indexWhere((s) => s.id == newSchedule.id);
    if (index != -1) {
      final old = _schedules[index];
      _schedules[index] = AdhanSchedule(
        id: old.id,
        hour: old.hour,
        minute: old.minute,
        soundName: newSchedule.soundName,
        soundUrl: newSchedule.soundUrl,
        isLocal: newSchedule.isLocal,
        isActive: old.isActive,
        volume: newSchedule.volume,
      );
      _sortSchedules();
      notifyListeners();
      _saveSchedules();
      _scheduleAlarms();
      updateWidgetData();
    }
  }

  AdhanSchedule? get nextSchedule {
    if (_schedules.isEmpty) return null;

    final nowMinutes = _currentTime.hour * 60 + _currentTime.minute;

    for (var schedule in _schedules) {
      if (schedule.id.toLowerCase() == 'dzuhur' && _currentTime.weekday == DateTime.friday) {
        continue;
      }
      final sMinutes = schedule.hour * 60 + schedule.minute;
      if (sMinutes > nowMinutes) {
        return schedule;
      }
    }
    return _schedules.first;
  }

  String getNextAdhanText() {
    if (_schedules.isEmpty) return "Belum ada jadwal";

    final nowMinutes = _currentTime.hour * 60 + _currentTime.minute;
    AdhanSchedule? nextSched = nextSchedule;

    String locText = _locationName.isNotEmpty ? " untuk $_locationName" : "";

    if (nextSched == null) return "Belum ada jadwal";

    final sMinutes = nextSched.hour * 60 + nextSched.minute;

    int diff;
    if (sMinutes <= nowMinutes) {

      diff = (24 * 60 - nowMinutes) + sMinutes;
    } else {
      diff = sMinutes - nowMinutes;
    }

    final h = diff ~/ 60;
    final m = diff % 60;

    if (h == 0 && m == 0) return "Tiba waktunya Adzan!";
    final timeStr = nextSched.formattedTime;
    return "Adzan ${nextSched.id}$locText pukul $timeStr\n($h jam $m mnt lagi)";
  }
}
