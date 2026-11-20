import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:adhan_reminder/core/services/storage_service.dart';
import 'package:adhan_reminder/features/adhan/data/datasources/adhan_local_data_source.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockStorageService mockStorageService;
  late AdhanLocalDataSource dataSource;

  setUp(() {
    mockStorageService = MockStorageService();
    dataSource = AdhanLocalDataSourceImpl(storageService: mockStorageService);
  });

  group('getCachedSchedules', () {
    test('returns default schedules and caches them when storage is empty', () async {
      when(() => mockStorageService.getString('schedules')).thenReturn(null);
      when(() => mockStorageService.setString(any(), any())).thenAnswer((_) async => true);

      final result = await dataSource.getCachedSchedules();

      expect(result.length, 5);
      expect(result[0].id, 'Subuh');
      verify(() => mockStorageService.setString('schedules', any())).called(1);
    });

    test('returns decoded schedules when valid json exists in storage', () async {
      final validJson = json.encode([
        {'id': 'Subuh', 'time_hour': 4, 'time_minute': 30, 'soundName': 'Default', 'soundUrl': 'assets/sound.mp3'},
        {'id': 'Dzuhur', 'time_hour': 12, 'time_minute': 0, 'soundName': 'Default', 'soundUrl': 'assets/sound.mp3'},
        {'id': 'Ashar', 'time_hour': 15, 'time_minute': 15, 'soundName': 'Default', 'soundUrl': 'assets/sound.mp3'},
        {'id': 'Maghrib', 'time_hour': 18, 'time_minute': 0, 'soundName': 'Default', 'soundUrl': 'assets/sound.mp3'},
        {'id': 'Isya', 'time_hour': 19, 'time_minute': 15, 'soundName': 'Default', 'soundUrl': 'assets/sound.mp3'},
      ]);
      when(() => mockStorageService.getString('schedules')).thenReturn(validJson);

      final result = await dataSource.getCachedSchedules();

      expect(result.length, 5);
      expect(result[0].hour, 4);
      expect(result[0].minute, 30);
    });
  });

  group('volume and location caching', () {
    test('getCachedGlobalVolume returns 1.0 when unset or invalid', () async {
      when(() => mockStorageService.getString('globalVolume')).thenReturn(null);

      final volume = await dataSource.getCachedGlobalVolume();

      expect(volume, 1.0);
    });

    test('getCachedGlobalVolume returns parsed double when set', () async {
      when(() => mockStorageService.getString('globalVolume')).thenReturn('0.7');

      final volume = await dataSource.getCachedGlobalVolume();

      expect(volume, 0.7);
    });

    test('cacheGlobalVolume sets string volume in storage', () async {
      when(() => mockStorageService.setString('globalVolume', '0.5')).thenAnswer((_) async => true);

      await dataSource.cacheGlobalVolume(0.5);

      verify(() => mockStorageService.setString('globalVolume', '0.5')).called(1);
    });

    test('getCachedLocationName returns string from storage', () async {
      when(() => mockStorageService.getString('locationName')).thenReturn('Jakarta');

      final location = await dataSource.getCachedLocationName();

      expect(location, 'Jakarta');
    });

    test('cacheLocationName sets location string in storage', () async {
      when(() => mockStorageService.setString('locationName', 'Bandung')).thenAnswer((_) async => true);

      await dataSource.cacheLocationName('Bandung');

      verify(() => mockStorageService.setString('locationName', 'Bandung')).called(1);
    });
  });
}
