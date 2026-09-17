import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/settings/domain/entities/app_settings.dart';
import 'package:adhan_reminder/features/settings/domain/repositories/settings_repository.dart';

class SaveSettingsUseCase {
  final SettingsRepository repository;

  SaveSettingsUseCase(this.repository);

  Future<Either<Failure, void>> execute(AppSettings settings) async {
    return await repository.saveSettings(settings);
  }
}
