import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/core/utils/location_helper.dart';
import 'package:adhan_reminder/features/qibla/domain/repositories/qibla_repository.dart';

class QiblaRepositoryImpl implements QiblaRepository {
  @override
  Future<Either<Failure, double>> getQiblaDirection() async {
    try {
      Position position = await LocationHelper.getCurrentPosition();
      final coordinates = Coordinates(position.latitude, position.longitude);
      final qibla = Qibla(coordinates);
      return Right(qibla.direction);
    } on LocationException catch (e) {
      return Left(LocationFailure(e.message));
    } catch (e) {
      return const Left(LocationFailure('Gagal mendapatkan lokasi. Pastikan GPS aktif dan coba lagi.'));
    }
  }
}
