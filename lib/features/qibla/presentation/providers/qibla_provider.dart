import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:adhan_reminder/core/utils/location_helper.dart';

class QiblaProvider with ChangeNotifier {
  double? _qiblaDirection;
  double? get qiblaDirection => _qiblaDirection;

  bool _hasPermissions = false;
  bool get hasPermissions => _hasPermissions;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  QiblaProvider() {
    fetchQiblaDirection();
  }

  Future<void> fetchQiblaDirection() async {
    _isLoading = true;
    notifyListeners();

    try {
      Position position = await LocationHelper.getCurrentPosition();

      _errorMessage = '';
      _hasPermissions = true;

      final coordinates = Coordinates(position.latitude, position.longitude);
      final qibla = Qibla(coordinates);
      
      _qiblaDirection = qibla.direction;
    } on LocationException catch (e) {
      _errorMessage = e.message;
      _hasPermissions = false;
    } catch (e) {
      _errorMessage = 'Gagal mendapatkan lokasi. Pastikan GPS aktif dan coba lagi.';
      _hasPermissions = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
