import 'dart:convert';
import 'dart:io';
import 'lib/features/quran/data/models/ayah_model.dart';

void main() async {
  final jsonString = await File('assets/quran/surat_1.json').readAsString();
  final data = json.decode(jsonString);
  final ayahData = data['data']['ayat'][0];
  final model = AyahModel.fromJson(ayahData);
  print('Audio for 01: ${model.audioUrls['01']}');
  print('Audio for 06: ${model.audioUrls['06']}');
}
