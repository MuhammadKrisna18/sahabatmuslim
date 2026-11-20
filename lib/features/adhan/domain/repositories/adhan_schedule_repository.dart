import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';

abstract class AdhanScheduleRepository {
  Future<Either<Failure, List<AdhanSchedule>>> getSchedules();
  Future<Either<Failure, void>> saveSchedules(List<AdhanSchedule> schedules);
  Future<Either<Failure, String>> getLocationName();
  Future<Either<Failure, void>> saveLocationName(String locationName);
  Future<Either<Failure, double>> getGlobalVolume();
  Future<Either<Failure, void>> saveGlobalVolume(double volume);
}
