import 'package:geolocator/geolocator.dart';
import 'package:adhan_reminder/core/constants/app_strings.dart';

class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}

class LocationHelper {
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(AppStrings.errorGpsDisabled);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException(AppStrings.errorLocationDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(AppStrings.errorLocationBlocked);
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      throw LocationException('Gagal mendapatkan koordinat lokasi.');
    }
  }
}
