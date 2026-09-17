import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/domain/entities/bookmark.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:adhan_reminder/features/quran/data/datasources/bookmark_local_data_source.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final BookmarkLocalDataSource _localDataSource;

  BookmarkRepositoryImpl({required BookmarkLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, Bookmark?>> getBookmark() async {
    try {
      final bookmark = await _localDataSource.getBookmark();
      return Right(bookmark);
    } catch (e) {
      return Left(CacheFailure('Gagal memuat bookmark: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveBookmark(Bookmark bookmark) async {
    try {
      await _localDataSource.saveBookmark(bookmark);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Gagal menyimpan bookmark: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBookmark() async {
    try {
      await _localDataSource.deleteBookmark();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Gagal menghapus bookmark: ${e.toString()}'));
    }
  }
}
