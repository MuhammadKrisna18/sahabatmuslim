import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:adhan_reminder/core/services/prayer_widget_service.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';
import 'package:adhan_reminder/features/adhan/domain/repositories/adhan_schedule_repository.dart';
import 'package:adhan_reminder/features/adhan/domain/services/adhan_alarm_orchestrator.dart';
import 'package:adhan_reminder/features/adhan/domain/usecases/get_prayer_times_usecase.dart';

class AdhanProvider with ChangeNotifier {
  final GetPrayerTimesUseCase _getPrayerTimesUseCase;
  final AdhanScheduleRepository _scheduleRepository;
  final AdhanAlarmOrchestrator _alarmOrchestrator;
  final PrayerWidgetService _prayerWidgetService;

  AdhanProvider({
    required GetPrayerTimesUseCase getPrayerTimesUseCase,
    required AdhanScheduleRepository scheduleRepository,
    required AdhanAlarmOrchestrator alarmOrchestrator,
    required PrayerWidgetService prayerWidgetService,
  })  : _getPrayerTimesUseCase = getPrayerTimesUseCase,
        _scheduleRepository = scheduleRepository,
        _alarmOrchestrator = alarmOrchestrator,
        _prayerWidgetService = prayerWidgetService {
    _loadSchedules();
    _startClock();
  }

  List<AdhanSchedule> _schedules = [];
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();
  final ValueNotifier<DateTime> currentTimeNotifier = ValueNotifier<DateTime>(DateTime.now());
  String _locationName = '';
  double _globalVolume = 0.4;
  String? _errorMessage;

  List<AdhanSchedule> get schedules => _schedules;
  DateTime get currentTime => _currentTime;
  String get locationName => _locationName;
  double get globalVolume => _globalVolume;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _clockTimer?.cancel();
    currentTimeNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    final locationResult = await _scheduleRepository.getLocationName();
    locationResult.fold((_) {}, (name) => _locationName = name);

    final volumeResult = await _scheduleRepository.getGlobalVolume();
    volumeResult.fold((_) {}, (vol) => _globalVolume = vol);

    final schedulesResult = await _scheduleRepository.getSchedules();
    schedulesResult.fold((_) {}, (loaded) {
      _schedules = loaded;
    });

    _sortSchedules();
    notifyListeners();

    await fetchLocationAndCalculatePrayerTimes();
    await _syncAlarms();
  }

  Future<void> fetchLocationAndCalculatePrayerTimes() async {
    _errorMessage = null;
    final result = await _getPrayerTimesUseCase.execute(_schedules);
    await result.fold(
      (failure) async {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (data) async {
        _locationName = data.locationName;
        _schedules = data.schedules;
        _sortSchedules();
        notifyListeners();
        await _saveSchedules();
        await updateWidgetData();
      },
    );
  }

  Future<void> updateWidgetData() async {
    final nextSched = nextSchedule;
    if (nextSched != null) {
      await _prayerWidgetService.updateWidgetData(
        nextAdhanName: nextSched.id,
        nextAdhanTime: nextSched.formattedTime,
        locationName: _locationName,
      );
    }
  }

  Future<void> _saveSchedules() async {
    await _scheduleRepository.saveSchedules(_schedules);
    await _scheduleRepository.saveLocationName(_locationName);
    await _scheduleRepository.saveGlobalVolume(_globalVolume);
  }

  void setGlobalVolume(double volume) {
    _globalVolume = volume;
    notifyListeners();
    _saveSchedules();
    _syncAlarms();
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
      final now = DateTime.now();
      final minuteChanged = now.minute != _currentTime.minute || now.hour != _currentTime.hour;
      _currentTime = now;
      currentTimeNotifier.value = now;
      if (minuteChanged) {
        notifyListeners();
      }
    });
  }

  Future<void> _syncAlarms() async {
    await _alarmOrchestrator.syncAlarms(
      schedules: _schedules,
      volume: _globalVolume,
    );
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
      _schedules = List.from(_schedules);
      notifyListeners();
      _saveSchedules();
      _syncAlarms();
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
      _schedules = List.from(_schedules);
      notifyListeners();
      _saveSchedules();
      _syncAlarms();
      updateWidgetData();
    }
  }

  AdhanSchedule? get nextSchedule {
    if (_schedules.isEmpty) return null;

    final nowMinutes = _currentTime.hour * 60 + _currentTime.minute;

    for (var schedule in _schedules) {
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
