import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/quran_download_repository.dart';

class DownloadAudioUseCase {
  final QuranDownloadRepository _repository;

  DownloadAudioUseCase(this._repository);

  Stream<double> execute(Surah surah, String qoriId, String audioUrl) {
    return _repository.downloadSurah(surah, qoriId, audioUrl);
  }
}
