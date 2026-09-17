import 'package:adhan_reminder/features/quran/domain/repositories/quran_download_repository.dart';

class CancelDownloadUseCase {
  final QuranDownloadRepository _repository;

  CancelDownloadUseCase(this._repository);

  void execute(int surahNomor, String qoriId) {
    _repository.cancelDownload(surahNomor, qoriId);
  }
}
