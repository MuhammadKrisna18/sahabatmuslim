import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/sholat/domain/entities/cara_sholat_step.dart';

abstract class SholatRepository {
  Future<Either<Failure, List<CaraSholatStep>>> getCaraSholatList();
}
