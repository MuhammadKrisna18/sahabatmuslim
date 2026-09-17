import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:adhan_reminder/features/adhan/presentation/providers/adhan_provider.dart';
import 'package:adhan_reminder/features/adhan/domain/usecases/get_prayer_times_usecase.dart';
import 'package:adhan_reminder/core/services/storage_service.dart';
import 'package:adhan_reminder/core/services/alarm_service.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/prayer_times_result.dart';
import 'package:fpdart/fpdart.dart';

class MockGetPrayerTimesUseCase extends Mock implements GetPrayerTimesUseCase {}
class MockStorageService extends Mock implements StorageService {}
class MockAlarmService extends Mock implements AlarmService {}

void main() {
  late MockGetPrayerTimesUseCase mockUseCase;
  late MockStorageService mockStorageService;
  late MockAlarmService mockAlarmService;

  setUpAll(() {
    registerFallbackValue(<AdhanSchedule>[]);
  });

  setUp(() {
    mockUseCase = MockGetPrayerTimesUseCase();
    mockStorageService = MockStorageService();
    mockAlarmService = MockAlarmService();

    when(() => mockStorageService.getString(any())).thenReturn(null);
    when(() => mockStorageService.setString(any(), any())).thenAnswer((_) async => true);
    
    final defaultSchedules = [
      AdhanSchedule(id: 'Subuh', hour: 4, minute: 21, soundName: 'Default', soundUrl: 'assets/adzan_default.mp3'),
      AdhanSchedule(id: 'Dzuhur', hour: 11, minute: 36, soundName: 'Default', soundUrl: 'assets/adzan_default.mp3'),
      AdhanSchedule(id: 'Ashar', hour: 14, minute: 57, soundName: 'Default', soundUrl: 'assets/adzan_default.mp3'),
      AdhanSchedule(id: 'Maghrib', hour: 17, minute: 29, soundName: 'Default', soundUrl: 'assets/adzan_default.mp3'),
      AdhanSchedule(id: 'Isya', hour: 18, minute: 42, soundName: 'Default', soundUrl: 'assets/adzan_default.mp3'),
    ];

    when(() => mockUseCase.execute(any())).thenAnswer((_) async => Right(
      PrayerTimesResult(locationName: 'Test Location', schedules: defaultSchedules)
    ));

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

  test('AdhanProvider initializes with default schedules when storage is empty', () async {
    final provider = AdhanProvider(
      getPrayerTimesUseCase: mockUseCase,
      storageService: mockStorageService,
      alarmService: mockAlarmService,
    );

    // Tunggu _loadSchedules (Future) di dalam constructor selesai
    await Future.delayed(Duration.zero);
    
    expect(provider.schedules.length, 5);
    expect(provider.schedules[0].id, 'Subuh');
    expect(provider.schedules[1].id, 'Dzuhur');
    expect(provider.globalVolume, 1.0);
  });

  test('setGlobalVolume updates volume and calls saveSchedules', () async {
    final provider = AdhanProvider(
      getPrayerTimesUseCase: mockUseCase,
      storageService: mockStorageService,
      alarmService: mockAlarmService,
    );
    await Future.delayed(Duration.zero);

    provider.setGlobalVolume(0.5);

    expect(provider.globalVolume, 0.5);
    verify(() => mockStorageService.setString('globalVolume', '0.5')).called(1);
  });
}
