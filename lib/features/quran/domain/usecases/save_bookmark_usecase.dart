import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/domain/entities/bookmark.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/bookmark_repository.dart';

class SaveBookmarkUseCase {
  final BookmarkRepository _repository;

  SaveBookmarkUseCase(this._repository);

  Future<Either<Failure, void>> execute(Bookmark bookmark) async {
    return await _repository.saveBookmark(bookmark);
  }
}
