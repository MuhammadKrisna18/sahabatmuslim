import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/doa/domain/entities/doa.dart';
import 'package:adhan_reminder/features/doa/domain/repositories/doa_repository.dart';

class GetDoaListUseCase {
  final DoaRepository repository;

  GetDoaListUseCase(this.repository);

  Future<Either<Failure, List<Doa>>> execute() async {
    return await repository.getDoaList();
  }
}
