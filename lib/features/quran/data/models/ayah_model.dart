import 'package:adhan_reminder/features/quran/domain/entities/ayah.dart';

class AyahModel extends Ayah {
  AyahModel({
    required super.nomorAyat,
    required super.teksArab,
    required super.teksLatin,
    required super.teksIndonesia,
    required super.audioUrls,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> parsedAudios = {};
    if (json['audio'] != null) {
      json['audio'].forEach((key, value) {
        parsedAudios[key] = value.toString();
      });
    }

    return AyahModel(
      nomorAyat: json['nomorAyat'] ?? 0,
      teksArab: json['teksArab'] ?? '',
      teksLatin: json['teksLatin'] ?? '',
      teksIndonesia: json['teksIndonesia'] ?? '',
      audioUrls: parsedAudios,
    );
  }

  Ayah toEntity() {
    return Ayah(
      nomorAyat: nomorAyat,
      teksArab: teksArab,
      teksLatin: teksLatin,
      teksIndonesia: teksIndonesia,
      audioUrls: audioUrls,
    );
  }

  factory AyahModel.fromEntity(Ayah entity) {
    return AyahModel(
      nomorAyat: entity.nomorAyat,
      teksArab: entity.teksArab,
      teksLatin: entity.teksLatin,
      teksIndonesia: entity.teksIndonesia,
      audioUrls: entity.audioUrls,
    );
  }
}
