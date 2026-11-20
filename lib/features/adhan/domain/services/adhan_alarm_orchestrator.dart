import 'package:flutter/foundation.dart';
import 'package:adhan_reminder/core/services/alarm_service.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';

abstract class AdhanAlarmOrchestrator {
  Future<void> syncAlarms({
    required List<AdhanSchedule> schedules,
    required double volume,
  });
  Future<void> cancelAlarm(int id);
}

class AdhanAlarmOrchestratorImpl implements AdhanAlarmOrchestrator {
  final AlarmService _alarmService;

  AdhanAlarmOrchestratorImpl({required AlarmService alarmService})
      : _alarmService = alarmService;

  @override
  Future<void> syncAlarms({
    required List<AdhanSchedule> schedules,
    required double volume,
  }) async {
    if (kIsWeb) return;

    for (int i = 0; i < schedules.length; i++) {
      final schedule = schedules[i];
      final alarmId = i + 1;

      if (!schedule.isActive) {
        await _alarmService.stopAlarm(alarmId);
        continue;
      }

      if (await _alarmService.isRinging(alarmId)) {
        continue;
      }

      final now = DateTime.now();
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

      final isFridayDzuhur = schedule.id.toLowerCase() == 'dzuhur' && alarmTime.weekday == DateTime.friday;
      final displayName = isFridayDzuhur ? "Jum'at" : schedule.id;

      await _alarmService.scheduleAdhan(
        id: alarmId,
        dateTime: alarmTime,
        audioPath: schedule.soundUrl,
        volume: volume,
        title: 'Waktunya Adzan $displayName!',
        body: 'Jadwal sholat pada ${schedule.formattedTime} telah tiba.',
      );
    }
  }

  @override
  Future<void> cancelAlarm(int id) async {
    if (kIsWeb) return;
    await _alarmService.stopAlarm(id);
  }
}
