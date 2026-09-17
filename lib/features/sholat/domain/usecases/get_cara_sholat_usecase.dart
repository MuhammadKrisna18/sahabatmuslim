import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/sholat/domain/entities/cara_sholat_step.dart';
import 'package:adhan_reminder/features/sholat/domain/repositories/sholat_repository.dart';

class GetCaraSholatUseCase {
  final SholatRepository repository;

  GetCaraSholatUseCase(this.repository);

  Future<Either<Failure, List<CaraSholatStep>>> execute() async {
    return await repository.getCaraSholatList();
  }
}
