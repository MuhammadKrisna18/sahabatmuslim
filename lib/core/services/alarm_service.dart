import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';

class AlarmService {
  StreamController<int>? _ringController;

  Future<void> initialize() async {
    if (!kIsWeb) {
      await Alarm.init();
      _ringController = StreamController<int>.broadcast();
      Alarm.ringStream.stream.listen((alarmSettings) {
        _ringController?.add(alarmSettings.id);
      });
    }
  }

  Stream<int>? get ringStream => _ringController?.stream;

  Future<void> scheduleAdhan({
    required int id,
    required DateTime dateTime,
    required String audioPath,
    required double volume,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: audioPath,
      loopAudio: false,
      vibrate: false,
      volume: volume,
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'Stop',
      ),
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  Future<void> stopAlarm(int id) async {
    if (kIsWeb) return;
    await Alarm.stop(id);
  }

  Future<bool> isRinging(int id) async {
    if (kIsWeb) return false;
    return await Alarm.isRinging(id);
  }

  Future<List<int>> getRingingAlarms() async {
    if (kIsWeb) return [];
    final ringingAlarms = <int>[];
    final alarms = Alarm.getAlarms();
    for (final alarm in alarms) {
      if (await Alarm.isRinging(alarm.id)) {
        ringingAlarms.add(alarm.id);
      }
    }
    return ringingAlarms;
  }
}
