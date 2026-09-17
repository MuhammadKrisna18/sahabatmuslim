class Ayah {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;
  final Map<String, String> audioUrls;

  Ayah({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    required this.audioUrls,
  });

  String get teksLatinSanitized {
    return teksLatin
        .replaceAll('ṡ', 'ts')
        .replaceAll('Ṡ', 'Ts')
        .replaceAll('ḥ', 'h')
        .replaceAll('Ḥ', 'H')
        .replaceAll('ṭ', 't')
        .replaceAll('Ṭ', 'T')
        .replaceAll('ṣ', 'sh')
        .replaceAll('Ṣ', 'Sh')
        .replaceAll('ḍ', 'dh')
        .replaceAll('Ḍ', 'Dh')
        .replaceAll('ẓ', 'zh')
        .replaceAll('Ẓ', 'Zh')
        .replaceAll('ż', 'dz')
        .replaceAll('Ż', 'Dz')
        .replaceAll('ś', 'sy')
        .replaceAll('Ś', 'Sy')
        .replaceAll('<strong>', '')
        .replaceAll('</strong>', '');
  }
}
