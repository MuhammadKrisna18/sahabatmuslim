import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/doa/data/models/doa_model.dart';
import 'package:adhan_reminder/features/doa/domain/entities/doa.dart';
import 'package:adhan_reminder/features/doa/domain/repositories/doa_repository.dart';

class DoaRepositoryImpl implements DoaRepository {
  @override
  Future<Either<Failure, List<Doa>>> getDoaList() async {
    try {
      final String response = await rootBundle.loadString('assets/data/doa_list.json');
      final List<dynamic> data = json.decode(response);
      final doaList = data.map((json) => DoaModel.fromJson(json).toEntity()).toList();
      return Right(doaList);
    } catch (e) {
      return const Left(CacheFailure('Gagal memuat data doa lokal'));
    }
  }
}
