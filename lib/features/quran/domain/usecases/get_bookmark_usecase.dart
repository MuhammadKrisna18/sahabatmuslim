import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/domain/entities/bookmark.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/bookmark_repository.dart';

class GetBookmarkUseCase {
  final BookmarkRepository _repository;

  GetBookmarkUseCase(this._repository);

  Future<Either<Failure, Bookmark?>> execute() async {
    return await _repository.getBookmark();
  }
}
