import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:adhan_reminder/core/services/alarm_service.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';
import 'package:adhan_reminder/features/adhan/domain/services/adhan_alarm_orchestrator.dart';

class MockAlarmService extends Mock implements AlarmService {}

void main() {
  late MockAlarmService mockAlarmService;
  late AdhanAlarmOrchestrator orchestrator;

  setUp(() {
    mockAlarmService = MockAlarmService();
    orchestrator = AdhanAlarmOrchestratorImpl(alarmService: mockAlarmService);

    when(() => mockAlarmService.isRinging(any())).thenAnswer((_) async => false);
    when(() => mockAlarmService.stopAlarm(any())).thenAnswer((_) async => {});
    when(() => mockAlarmService.scheduleAdhan(
      id: any(named: 'id'),
      dateTime: any(named: 'dateTime'),
      audioPath: any(named: 'audioPath'),
      volume: any(named: 'volume'),
      title: any(named: 'title'),
      body: any(named: 'body'),
    )).thenAnswer((_) async => {});
  });

  final schedules = [
    AdhanSchedule(id: 'Subuh', hour: 4, minute: 21, soundName: 'Default', soundUrl: 'assets/adzan_default.mp3', isActive: true),
    AdhanSchedule(id: 'Dzuhur', hour: 12, minute: 0, soundName: 'Default', soundUrl: 'assets/adzan_default.mp3', isActive: false),
  ];

  test('syncAlarms schedules active alarms and stops inactive alarms', () async {
    await orchestrator.syncAlarms(schedules: schedules, volume: 0.8);

    verify(() => mockAlarmService.scheduleAdhan(
      id: 1,
      dateTime: any(named: 'dateTime'),
      audioPath: 'assets/adzan_default.mp3',
      volume: 0.8,
      title: any(named: 'title'),
      body: any(named: 'body'),
    )).called(1);

    verify(() => mockAlarmService.stopAlarm(2)).called(1);
  });

  test('cancelAlarm calls stopAlarm on AlarmService', () async {
    await orchestrator.cancelAlarm(1);

    verify(() => mockAlarmService.stopAlarm(1)).called(1);
  });
}
