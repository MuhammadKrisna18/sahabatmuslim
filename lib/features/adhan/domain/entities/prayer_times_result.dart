import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';

class PrayerTimesResult {
  final String locationName;
  final List<AdhanSchedule> schedules;

  const PrayerTimesResult({
    required this.locationName,
    required this.schedules,
  });
}
