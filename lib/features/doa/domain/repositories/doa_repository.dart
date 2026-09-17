import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/doa/domain/entities/doa.dart';

abstract class DoaRepository {
  Future<Either<Failure, List<Doa>>> getDoaList();
}
