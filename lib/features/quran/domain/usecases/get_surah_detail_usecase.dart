import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/domain/entities/ayah.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/quran_repository.dart';

class GetSurahDetailUseCase {
  final QuranRepository repository;

  GetSurahDetailUseCase(this.repository);

  Future<Either<Failure, List<Ayah>>> execute(int nomorSurah) async {
    return await repository.getSurahDetail(nomorSurah);
  }
}
