import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/settings/domain/entities/app_settings.dart';
import 'package:adhan_reminder/features/settings/domain/repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository repository;

  GetSettingsUseCase(this.repository);

  Future<Either<Failure, AppSettings>> execute() async {
    return await repository.getSettings();
  }
}
