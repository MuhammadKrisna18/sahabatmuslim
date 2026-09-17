import 'package:adhan_reminder/features/sholat/domain/entities/cara_sholat_step.dart';

class CaraSholatStepModel {
  final String title;
  final String desc;
  final String? arab;
  final String? latin;
  final String? arti;

  CaraSholatStepModel({
    required this.title,
    required this.desc,
    this.arab,
    this.latin,
    this.arti,
  });

  factory CaraSholatStepModel.fromJson(Map<String, dynamic> json) {
    return CaraSholatStepModel(
      title: json['title'] ?? '',
      desc: json['desc'] ?? '',
      arab: json['arab'],
      latin: json['latin'],
      arti: json['arti'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'desc': desc,
      'arab': arab,
      'latin': latin,
      'arti': arti,
    };
  }

  CaraSholatStep toEntity() {
    return CaraSholatStep(
      title: title,
      desc: desc,
      arab: arab,
      latin: latin,
      arti: arti,
    );
  }

  factory CaraSholatStepModel.fromEntity(CaraSholatStep entity) {
    return CaraSholatStepModel(
      title: entity.title,
      desc: entity.desc,
      arab: entity.arab,
      latin: entity.latin,
      arti: entity.arti,
    );
  }
}
