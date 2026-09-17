import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/domain/entities/download_item.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/quran_download_repository.dart';

class GetDownloadedAudioUseCase {
  final QuranDownloadRepository _repository;

  GetDownloadedAudioUseCase(this._repository);

  Future<Either<Failure, List<DownloadItem>>> execute() async {
    return await _repository.getDownloadedItems();
  }
}
