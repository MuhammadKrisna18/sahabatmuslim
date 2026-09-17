import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';

class SurahModel extends Surah {
  SurahModel({
    required super.nomor,
    required super.nama,
    required super.namaLatin,
    required super.jumlahAyat,
    required super.tempatTurun,
    required super.arti,
    required super.deskripsi,
    required super.audioUrls,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> parsedAudios = {};
    if (json['audioFull'] != null) {
      json['audioFull'].forEach((key, value) {
        parsedAudios[key] = value.toString();
      });
    }

    return SurahModel(
      nomor: json['nomor'] ?? 0,
      nama: json['nama'] ?? '',
      namaLatin: json['namaLatin'] ?? '',
      jumlahAyat: json['jumlahAyat'] ?? 0,
      tempatTurun: json['tempatTurun'] ?? '',
      arti: json['arti'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      audioUrls: parsedAudios,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomor': nomor,
      'nama': nama,
      'namaLatin': namaLatin,
      'jumlahAyat': jumlahAyat,
      'tempatTurun': tempatTurun,
      'arti': arti,
      'deskripsi': deskripsi,
      'audioFull': audioUrls,
    };
  }

  Surah toEntity() {
    return Surah(
      nomor: nomor,
      nama: nama,
      namaLatin: namaLatin,
      jumlahAyat: jumlahAyat,
      tempatTurun: tempatTurun,
      arti: arti,
      deskripsi: deskripsi,
      audioUrls: audioUrls,
    );
  }

  factory SurahModel.fromEntity(Surah entity) {
    return SurahModel(
      nomor: entity.nomor,
      nama: entity.nama,
      namaLatin: entity.namaLatin,
      jumlahAyat: entity.jumlahAyat,
      tempatTurun: entity.tempatTurun,
      arti: entity.arti,
      deskripsi: entity.deskripsi,
      audioUrls: entity.audioUrls,
    );
  }
}
