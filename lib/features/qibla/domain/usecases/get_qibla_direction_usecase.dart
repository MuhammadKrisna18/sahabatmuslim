import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/qibla/domain/repositories/qibla_repository.dart';

class GetQiblaDirectionUseCase {
  final QiblaRepository repository;

  GetQiblaDirectionUseCase(this.repository);

  Future<Either<Failure, double>> execute() async {
    return await repository.getQiblaDirection();
  }
}
