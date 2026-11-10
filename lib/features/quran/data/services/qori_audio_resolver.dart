import 'package:adhan_reminder/core/constants/api_constants.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';

class QoriAudioResolver {
  static const Map<String, String> qoriNames = {
    '05': 'Mishary Rashid Alafasy',
    '07': 'Saad Al Ghamdi',
    '09': 'Alaa Aqel',
  };

  static String getQoriName(String qoriId) {
    return qoriNames[qoriId] ?? "Qori";
  }

  static String? getAudioUrl(Surah surah, String qoriId) {
    final paddedNumber = surah.nomor.toString().padLeft(3, '0');
    if (qoriId == '07') {
      return '${ApiConstants.mp3QuranBaseUrl}/$paddedNumber.mp3';
    } else if (qoriId == '09') {
      return '${ApiConstants.archiveOrgBaseUrl}/$paddedNumber.mp3';
    } else {
      String? url = surah.audioUrls[qoriId];
      if (url == null && surah.audioUrls.isNotEmpty) {
        url = surah.audioUrls.values.first;
      }
      return url;
    }
  }
}
