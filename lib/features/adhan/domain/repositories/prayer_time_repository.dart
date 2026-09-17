import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/prayer_times_result.dart';

abstract class PrayerTimeRepository {
  Future<Either<Failure, PrayerTimesResult>> fetchLocationAndCalculatePrayerTimes(List<AdhanSchedule> currentSchedules);
}
