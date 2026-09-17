import 'package:flutter/foundation.dart';
import 'package:adhan_reminder/features/qibla/domain/usecases/get_qibla_direction_usecase.dart';

class QiblaProvider with ChangeNotifier {
  final GetQiblaDirectionUseCase _getQiblaDirectionUseCase;

  double? _qiblaDirection;
  double? get qiblaDirection => _qiblaDirection;

  bool _hasPermissions = false;
  bool get hasPermissions => _hasPermissions;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  QiblaProvider({required GetQiblaDirectionUseCase getQiblaDirectionUseCase})
      : _getQiblaDirectionUseCase = getQiblaDirectionUseCase {
    fetchQiblaDirection();
  }

  Future<void> fetchQiblaDirection() async {
    _isLoading = true;
    notifyListeners();

    final result = await _getQiblaDirectionUseCase.execute();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _hasPermissions = false;
      },
      (direction) {
        _qiblaDirection = direction;
        _errorMessage = '';
        _hasPermissions = true;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
