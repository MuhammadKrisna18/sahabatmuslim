import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/quran_repository.dart';

class GetSurahsUseCase {
  final QuranRepository repository;

  GetSurahsUseCase(this.repository);

  Future<Either<Failure, List<Surah>>> execute() async {
    return await repository.getSurahList();
  }
}
