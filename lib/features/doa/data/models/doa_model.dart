import 'package:adhan_reminder/features/doa/domain/entities/doa.dart';

class DoaModel {
  final String title;
  final String arab;
  final String latin;
  final String arti;

  DoaModel({
    required this.title,
    required this.arab,
    required this.latin,
    required this.arti,
  });

  factory DoaModel.fromJson(Map<String, dynamic> json) {
    return DoaModel(
      title: json['title'] ?? '',
      arab: json['arab'] ?? '',
      latin: json['latin'] ?? '',
      arti: json['arti'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'arab': arab,
      'latin': latin,
      'arti': arti,
    };
  }

  Doa toEntity() {
    return Doa(
      title: title,
      arab: arab,
      latin: latin,
      arti: arti,
    );
  }

  factory DoaModel.fromEntity(Doa entity) {
    return DoaModel(
      title: entity.title,
      arab: entity.arab,
      latin: entity.latin,
      arti: entity.arti,
    );
  }
}
