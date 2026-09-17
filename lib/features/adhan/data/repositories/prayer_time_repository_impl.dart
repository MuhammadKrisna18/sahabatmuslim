import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:adhan/adhan.dart';
import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';
import 'package:adhan_reminder/features/adhan/domain/repositories/prayer_time_repository.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/prayer_times_result.dart';
import 'package:adhan_reminder/core/utils/location_helper.dart';

class PrayerTimeRepositoryImpl implements PrayerTimeRepository {
  @override
  Future<Either<Failure, PrayerTimesResult>> fetchLocationAndCalculatePrayerTimes(List<AdhanSchedule> currentSchedules) async {
    if (kIsWeb) return const Left(LocationFailure('Tidak didukung di web'));

    try {
      Position position = await LocationHelper.getCurrentPosition();
      final coordinates = Coordinates(position.latitude, position.longitude);

      String locationName = 'Lokasi Saat Ini';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final kecamatan = place.locality ?? place.subLocality ?? '';
          final kabupaten = place.subAdministrativeArea ?? '';
          
          final parts = {kecamatan, kabupaten}..remove('');
          
          locationName = parts.isNotEmpty 
              ? parts.join(', ') 
              : (place.administrativeArea ?? 'Lokasi Saat Ini');
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
      }

      final params = CalculationMethod.singapore.getParameters();
      params.fajrAngle = 20.0;
      params.ishaAngle = 18.0;

      final prayerTimes = PrayerTimes.today(coordinates, params);

      final updatedSchedules = currentSchedules.map((schedule) {
        final newTime = switch (schedule.id) {
          'Subuh' => prayerTimes.fajr,
          'Dzuhur' => prayerTimes.dhuhr,
          'Ashar' => prayerTimes.asr,
          'Maghrib' => prayerTimes.maghrib,
          'Isya' => prayerTimes.isha,
          _ => null,
        };

        if (newTime != null) {
          return schedule.copyWith(
            hour: newTime.hour,
            minute: newTime.minute,
          );
        }

        return schedule;
      }).toList();

      return Right(PrayerTimesResult(
        locationName: locationName,
        schedules: updatedSchedules,
      ));
    } catch (e) {
      return Left(LocationFailure(e.toString()));
    }
  }
}
