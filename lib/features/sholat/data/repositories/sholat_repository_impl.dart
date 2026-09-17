import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/sholat/data/models/cara_sholat_step_model.dart';
import 'package:adhan_reminder/features/sholat/domain/entities/cara_sholat_step.dart';
import 'package:adhan_reminder/features/sholat/domain/repositories/sholat_repository.dart';

class SholatRepositoryImpl implements SholatRepository {
  @override
  Future<Either<Failure, List<CaraSholatStep>>> getCaraSholatList() async {
    try {
      final String response = await rootBundle.loadString('assets/data/cara_sholat.json');
      final List<dynamic> data = json.decode(response);
      final steps = data.map((json) => CaraSholatStepModel.fromJson(json).toEntity()).toList();
      return Right(steps);
    } catch (e) {
      return const Left(CacheFailure('Gagal memuat data tata cara sholat'));
    }
  }
}
