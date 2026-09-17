import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/prayer_times_result.dart';
import 'package:adhan_reminder/features/adhan/domain/repositories/prayer_time_repository.dart';
import 'package:adhan_reminder/features/adhan/domain/usecases/get_prayer_times_usecase.dart';

class MockPrayerTimeRepository extends Mock implements PrayerTimeRepository {}

void main() {
  late GetPrayerTimesUseCase usecase;
  late MockPrayerTimeRepository mockRepository;

  setUp(() {
    mockRepository = MockPrayerTimeRepository();
    usecase = GetPrayerTimesUseCase(mockRepository);
  });

  final List<AdhanSchedule> tSchedules = [
    AdhanSchedule(
      id: 'Subuh',
      hour: 4,
      minute: 30,
      soundName: 'Default',
      soundUrl: '',
      isActive: true,
    )
  ];

  final tResult = PrayerTimesResult(
    locationName: 'Jakarta',
    schedules: tSchedules,
  );

  test('should get prayer times result from the repository', () async {
    // arrange
    when(() => mockRepository.fetchLocationAndCalculatePrayerTimes(tSchedules))
        .thenAnswer((_) async => Right(tResult));
    
    // act
    final result = await usecase.execute(tSchedules);
    
    // assert
    expect(result, Right(tResult));
    verify(() => mockRepository.fetchLocationAndCalculatePrayerTimes(tSchedules)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return location failure when repository fails', () async {
    // arrange
    when(() => mockRepository.fetchLocationAndCalculatePrayerTimes(tSchedules))
        .thenAnswer((_) async => const Left(LocationFailure('Gagal lokasi')));
    
    // act
    final result = await usecase.execute(tSchedules);
    
    // assert
    expect(result, const Left(LocationFailure('Gagal lokasi')));
    verify(() => mockRepository.fetchLocationAndCalculatePrayerTimes(tSchedules)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
