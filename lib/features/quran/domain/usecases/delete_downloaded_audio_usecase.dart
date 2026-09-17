import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/quran_download_repository.dart';

class DeleteDownloadedAudioUseCase {
  final QuranDownloadRepository _repository;

  DeleteDownloadedAudioUseCase(this._repository);

  Future<Either<Failure, void>> execute(int surahNomor, String qoriId) async {
    return await _repository.deleteDownloadedItem(surahNomor, qoriId);
  }
}
