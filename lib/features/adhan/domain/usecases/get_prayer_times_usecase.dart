import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/prayer_times_result.dart';
import 'package:adhan_reminder/features/adhan/domain/repositories/prayer_time_repository.dart';

class GetPrayerTimesUseCase {
  final PrayerTimeRepository repository;

  GetPrayerTimesUseCase(this.repository);

  Future<Either<Failure, PrayerTimesResult>> execute(List<AdhanSchedule> currentSchedules) async {
    return await repository.fetchLocationAndCalculatePrayerTimes(currentSchedules);
  }
}
