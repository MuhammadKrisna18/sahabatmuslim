import 'package:flutter/foundation.dart';
import 'package:adhan_reminder/features/sholat/domain/entities/cara_sholat_step.dart';
import 'package:adhan_reminder/features/sholat/domain/usecases/get_cara_sholat_usecase.dart';

class SholatProvider with ChangeNotifier {
  final GetCaraSholatUseCase _getCaraSholatUseCase;

  SholatProvider({required GetCaraSholatUseCase getCaraSholatUseCase})
      : _getCaraSholatUseCase = getCaraSholatUseCase;

  List<CaraSholatStep> _caraSholatList = [];
  List<CaraSholatStep> get caraSholatList => _caraSholatList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadCaraSholatList() async {
    if (_caraSholatList.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getCaraSholatUseCase.execute();

    result.fold(
      (failure) => _errorMessage = failure.message,
      (steps) => _caraSholatList = steps,
    );

    _isLoading = false;
    notifyListeners();
  }
}
