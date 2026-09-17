import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/domain/entities/bookmark.dart';

abstract class BookmarkRepository {
  Future<Either<Failure, Bookmark?>> getBookmark();
  Future<Either<Failure, void>> saveBookmark(Bookmark bookmark);
  Future<Either<Failure, void>> deleteBookmark();
}
