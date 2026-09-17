import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/bookmark_repository.dart';

class DeleteBookmarkUseCase {
  final BookmarkRepository _repository;

  DeleteBookmarkUseCase(this._repository);

  Future<Either<Failure, void>> execute() async {
    return await _repository.deleteBookmark();
  }
}
