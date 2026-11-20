import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:adhan_reminder/features/adhan/presentation/providers/adhan_provider.dart';
import 'package:adhan_reminder/features/adhan/domain/usecases/get_prayer_times_usecase.dart';
import 'package:adhan_reminder/features/adhan/domain/repositories/adhan_schedule_repository.dart';
import 'package:adhan_reminder/features/adhan/domain/services/adhan_alarm_orchestrator.dart';
import 'package:adhan_reminder/core/services/prayer_widget_service.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/prayer_times_result.dart';
import 'package:fpdart/fpdart.dart';

class MockGetPrayerTimesUseCase extends Mock implements GetPrayerTimesUseCase {}
class MockAdhanScheduleRepository extends Mock implements AdhanScheduleRepository {}
class MockAdhanAlarmOrchestrator extends Mock implements AdhanAlarmOrchestrator {}
class MockPrayerWidgetService extends Mock implements PrayerWidgetService {}

void main() {
  late MockGetPrayerTimesUseCase mockUseCase;
  late MockAdhanScheduleRepository mockScheduleRepository;
  late MockAdhanAlarmOrchestrator mockAlarmOrchestrator;
  late MockPrayerWidgetService mockPrayerWidgetService;

  final defaultSchedules = [
    AdhanSchedule(id: 'Subuh', hour: 4, minute: 21, soundName: 'Default', soundUrl: 'assets/adzan_default.mp3'),
    AdhanSchedule(id: 'Dzuhur', hour: 11, minute: 36, soundName: 'Default', soundUrl: 'assets/adzan_default.mp3'),
    AdhanSchedule(id: 'Ashar', hour: 14, minute: 57, soundName: 'Default', soundUrl: 'assets/adzan_default.mp3'),
    AdhanSchedule(id: 'Maghrib', hour: 17, minute: 29, soundName: 'Default', soundUrl: 'assets/adzan_default.mp3'),
    AdhanSchedule(id: 'Isya', hour: 18, minute: 42, soundName: 'Default', soundUrl: 'assets/adzan_default.mp3'),
  ];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(<AdhanSchedule>[]);
  });

  setUp(() {
    mockUseCase = MockGetPrayerTimesUseCase();
    mockScheduleRepository = MockAdhanScheduleRepository();
    mockAlarmOrchestrator = MockAdhanAlarmOrchestrator();
    mockPrayerWidgetService = MockPrayerWidgetService();

    when(() => mockScheduleRepository.getLocationName()).thenAnswer((_) async => const Right('Test Location'));
    when(() => mockScheduleRepository.saveLocationName(any())).thenAnswer((_) async => const Right(null));
    when(() => mockScheduleRepository.getGlobalVolume()).thenAnswer((_) async => const Right(1.0));
    when(() => mockScheduleRepository.saveGlobalVolume(any())).thenAnswer((_) async => const Right(null));
    when(() => mockScheduleRepository.getSchedules()).thenAnswer((_) async => Right(defaultSchedules));
    when(() => mockScheduleRepository.saveSchedules(any())).thenAnswer((_) async => const Right(null));

    when(() => mockUseCase.execute(any())).thenAnswer((_) async => Right(
      PrayerTimesResult(locationName: 'Test Location', schedules: defaultSchedules),
    ));

    when(() => mockAlarmOrchestrator.syncAlarms(
      schedules: any(named: 'schedules'),
      volume: any(named: 'volume'),
    )).thenAnswer((_) async => {});

    when(() => mockPrayerWidgetService.updateWidgetData(
      nextAdhanName: any(named: 'nextAdhanName'),
      nextAdhanTime: any(named: 'nextAdhanTime'),
      locationName: any(named: 'locationName'),
    )).thenAnswer((_) async => {});
  });

  test('AdhanProvider initializes with default schedules when repository loads', () async {
    final provider = AdhanProvider(
      getPrayerTimesUseCase: mockUseCase,
      scheduleRepository: mockScheduleRepository,
      alarmOrchestrator: mockAlarmOrchestrator,
      prayerWidgetService: mockPrayerWidgetService,
    );

    await Future.delayed(Duration.zero);
    
    expect(provider.schedules.length, 5);
    expect(provider.schedules[0].id, 'Subuh');
    expect(provider.schedules[1].id, 'Dzuhur');
    expect(provider.globalVolume, 1.0);
  });

  test('setGlobalVolume updates volume and calls saveGlobalVolume', () async {
    final provider = AdhanProvider(
      getPrayerTimesUseCase: mockUseCase,
      scheduleRepository: mockScheduleRepository,
      alarmOrchestrator: mockAlarmOrchestrator,
      prayerWidgetService: mockPrayerWidgetService,
    );
    await Future.delayed(Duration.zero);

    provider.setGlobalVolume(0.5);
    await Future.delayed(Duration.zero);

    expect(provider.globalVolume, 0.5);
    verify(() => mockScheduleRepository.saveGlobalVolume(0.5)).called(1);
  });
}
