import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/adhan/data/datasources/adhan_local_data_source.dart';
import 'package:adhan_reminder/features/adhan/data/models/adhan_schedule_model.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';
import 'package:adhan_reminder/features/adhan/domain/repositories/adhan_schedule_repository.dart';

class AdhanScheduleRepositoryImpl implements AdhanScheduleRepository {
  final AdhanLocalDataSource _localDataSource;

  AdhanScheduleRepositoryImpl({required AdhanLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<AdhanSchedule>>> getSchedules() async {
    try {
      final models = await _localDataSource.getCachedSchedules();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Gagal memuat jadwal adzan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSchedules(List<AdhanSchedule> schedules) async {
    try {
      final models = schedules.map((e) => AdhanScheduleModel.fromEntity(e)).toList();
      await _localDataSource.cacheSchedules(models);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Gagal menyimpan jadwal adzan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> getLocationName() async {
    try {
      final locationName = await _localDataSource.getCachedLocationName();
      return Right(locationName);
    } catch (e) {
      return Left(CacheFailure('Gagal memuat nama lokasi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveLocationName(String locationName) async {
    try {
      await _localDataSource.cacheLocationName(locationName);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Gagal menyimpan nama lokasi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getGlobalVolume() async {
    try {
      final volume = await _localDataSource.getCachedGlobalVolume();
      return Right(volume);
    } catch (e) {
      return Left(CacheFailure('Gagal memuat volume adzan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveGlobalVolume(double volume) async {
    try {
      await _localDataSource.cacheGlobalVolume(volume);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Gagal menyimpan volume adzan: ${e.toString()}'));
    }
  }
}
