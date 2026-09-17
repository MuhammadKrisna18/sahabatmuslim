import 'package:flutter/foundation.dart';
import 'package:adhan_reminder/features/doa/domain/entities/doa.dart';
import 'package:adhan_reminder/features/doa/domain/usecases/get_doa_list_usecase.dart';

class DoaProvider with ChangeNotifier {
  final GetDoaListUseCase _getDoaListUseCase;

  DoaProvider({required GetDoaListUseCase getDoaListUseCase})
      : _getDoaListUseCase = getDoaListUseCase;

  List<Doa> _doaList = [];
  List<Doa> get doaList => _doaList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadDoaList() async {
    if (_doaList.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getDoaListUseCase.execute();

    result.fold(
      (failure) => _errorMessage = failure.message,
      (doas) => _doaList = doas,
    );

    _isLoading = false;
    notifyListeners();
  }
}
