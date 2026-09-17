import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/domain/entities/bookmark.dart';
import 'package:adhan_reminder/features/quran/data/datasources/bookmark_local_data_source.dart';
import 'package:adhan_reminder/features/quran/data/repositories/bookmark_repository_impl.dart';

class MockBookmarkLocalDataSource extends Mock implements BookmarkLocalDataSource {}

void main() {
  late BookmarkRepositoryImpl repository;
  late MockBookmarkLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockBookmarkLocalDataSource();
    repository = BookmarkRepositoryImpl(localDataSource: mockDataSource);
  });

  final tBookmark = Bookmark(
    surahNomor: 1,
    surahNama: 'Al-Fatihah',
    ayahNomor: 1,
  );

  group('getBookmark', () {
    test('should return bookmark when data source returns a bookmark', () async {
      // arrange
      when(() => mockDataSource.getBookmark())
          .thenAnswer((_) async => tBookmark);
      
      // act
      final result = await repository.getBookmark();
      
      // assert
      expect(result, Right(tBookmark));
      verify(() => mockDataSource.getBookmark()).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });

    test('should return null when there is no bookmark', () async {
      // arrange
      when(() => mockDataSource.getBookmark())
          .thenAnswer((_) async => null);
      
      // act
      final result = await repository.getBookmark();
      
      // assert
      expect(result, const Right(null));
    });

    test('should return CacheFailure when data source throws an exception', () async {
      // arrange
      when(() => mockDataSource.getBookmark())
          .thenThrow(Exception('Storage error'));
      
      // act
      final result = await repository.getBookmark();
      
      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should not return right'),
      );
    });
  });

  group('saveBookmark', () {
    test('should return void when save is successful', () async {
      // arrange
      when(() => mockDataSource.saveBookmark(tBookmark))
          .thenAnswer((_) async => Future.value());
      
      // act
      final result = await repository.saveBookmark(tBookmark);
      
      // assert
      expect(result, const Right(null));
      verify(() => mockDataSource.saveBookmark(tBookmark)).called(1);
    });
  });

  group('deleteBookmark', () {
    test('should return void when delete is successful', () async {
      // arrange
      when(() => mockDataSource.deleteBookmark())
          .thenAnswer((_) async => Future.value());
      
      // act
      final result = await repository.deleteBookmark();
      
      // assert
      expect(result, const Right(null));
      verify(() => mockDataSource.deleteBookmark()).called(1);
    });
  });
}
