import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/adhan/data/datasources/adhan_local_data_source.dart';
import 'package:adhan_reminder/features/adhan/data/models/adhan_schedule_model.dart';
import 'package:adhan_reminder/features/adhan/data/repositories/adhan_schedule_repository_impl.dart';

class MockAdhanLocalDataSource extends Mock implements AdhanLocalDataSource {}

void main() {
  late MockAdhanLocalDataSource mockDataSource;
  late AdhanScheduleRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAdhanLocalDataSource();
    repository = AdhanScheduleRepositoryImpl(localDataSource: mockDataSource);
  });

  final tModel = AdhanScheduleModel(
    id: 'Subuh',
    hour: 4,
    minute: 21,
    soundName: 'Default',
    soundUrl: 'assets/adzan_default.mp3',
  );

  group('getSchedules', () {
    test('returns list of AdhanSchedule when data source succeeds', () async {
      when(() => mockDataSource.getCachedSchedules()).thenAnswer((_) async => [tModel]);

      final result = await repository.getSchedules();

      expect(result.isRight(), true);
      result.fold((_) => fail('Should succeed'), (schedules) {
        expect(schedules.length, 1);
        expect(schedules[0].id, 'Subuh');
      });
      verify(() => mockDataSource.getCachedSchedules()).called(1);
    });

    test('returns CacheFailure when data source throws an exception', () async {
      when(() => mockDataSource.getCachedSchedules()).thenThrow(Exception('Disk read failed'));

      final result = await repository.getSchedules();

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<CacheFailure>());
      }, (_) => fail('Should fail'));
    });
  });

  group('saveSchedules', () {
    test('returns Right(null) when data source succeeds', () async {
      when(() => mockDataSource.cacheSchedules(any())).thenAnswer((_) async => {});

      final result = await repository.saveSchedules([tModel.toEntity()]);

      expect(result, const Right(null));
      verify(() => mockDataSource.cacheSchedules(any())).called(1);
    });

    test('returns CacheFailure when data source throws an exception', () async {
      when(() => mockDataSource.cacheSchedules(any())).thenThrow(Exception('Disk write failed'));

      final result = await repository.saveSchedules([tModel.toEntity()]);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<CacheFailure>());
      }, (_) => fail('Should fail'));
    });
  });

  group('volume and location repository methods', () {
    test('getLocationName returns Right(String)', () async {
      when(() => mockDataSource.getCachedLocationName()).thenAnswer((_) async => 'Jakarta');

      final result = await repository.getLocationName();

      expect(result, const Right('Jakarta'));
    });

    test('saveLocationName calls cacheLocationName', () async {
      when(() => mockDataSource.cacheLocationName('Bandung')).thenAnswer((_) async => {});

      final result = await repository.saveLocationName('Bandung');

      expect(result, const Right(null));
      verify(() => mockDataSource.cacheLocationName('Bandung')).called(1);
    });

    test('getGlobalVolume returns Right(double)', () async {
      when(() => mockDataSource.getCachedGlobalVolume()).thenAnswer((_) async => 0.8);

      final result = await repository.getGlobalVolume();

      expect(result, const Right(0.8));
    });

    test('saveGlobalVolume calls cacheGlobalVolume', () async {
      when(() => mockDataSource.cacheGlobalVolume(0.5)).thenAnswer((_) async => {});

      final result = await repository.saveGlobalVolume(0.5);

      expect(result, const Right(null));
      verify(() => mockDataSource.cacheGlobalVolume(0.5)).called(1);
    });
  });
}
