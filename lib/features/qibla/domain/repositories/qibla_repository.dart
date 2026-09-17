import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';

abstract class QiblaRepository {
  Future<Either<Failure, double>> getQiblaDirection();
}
