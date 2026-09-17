import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/domain/entities/ayah.dart';

abstract class QuranRepository {
  Future<Either<Failure, List<Surah>>> getSurahList();
  Future<Either<Failure, List<Ayah>>> getSurahDetail(int nomorSurah);
}
