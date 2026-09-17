import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/doa/domain/entities/doa.dart';
import 'package:adhan_reminder/features/doa/domain/repositories/doa_repository.dart';
import 'package:adhan_reminder/features/doa/domain/usecases/get_doa_list_usecase.dart';

class MockDoaRepository extends Mock implements DoaRepository {}

void main() {
  late GetDoaListUseCase usecase;
  late MockDoaRepository mockRepository;

  setUp(() {
    mockRepository = MockDoaRepository();
    usecase = GetDoaListUseCase(mockRepository);
  });

  final tDoa = Doa(
    title: 'Doa Makan',
    arab: 'Bismillah',
    latin: 'Bismillah',
    arti: 'Dengan nama Allah',
  );

  final List<Doa> tDoaList = [tDoa];

  test('should get list of doa from the repository', () async {
    // arrange
    when(() => mockRepository.getDoaList())
        .thenAnswer((_) async => Right(tDoaList));
    
    // act
    final result = await usecase.execute();
    
    // assert
    expect(result, Right(tDoaList));
    verify(() => mockRepository.getDoaList()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    when(() => mockRepository.getDoaList())
        .thenAnswer((_) async => const Left(CacheFailure('Error')));
    
    // act
    final result = await usecase.execute();
    
    // assert
    expect(result, const Left(CacheFailure('Error')));
    verify(() => mockRepository.getDoaList()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
