import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:adhan_reminder/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Testing SahabatMuslim', () {
    testWidgets('Buka aplikasi, navigasi ke Qur\'an, lalu buka detail Surah', (WidgetTester tester) async {
      // Jalankan aplikasi
      app.main();

      // Tunggu splash screen dan animasi sampai selesai
      bool foundQuranTab = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(const Key('nav_quran')).evaluate().isNotEmpty) {
          foundQuranTab = true;
          break;
        }
      }
      
      final quranTab = find.byKey(const Key('nav_quran'));
      expect(quranTab, findsOneWidget);

      // Ketuk tab Qur'an
      await tester.tap(quranTab);
      
      // Tunggu rendering halaman daftar surah dan fetch API
      bool foundAlFatihah = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.text('Al-Fatihah').evaluate().isNotEmpty) {
          foundAlFatihah = true;
          break;
        }
      }

      // Pastikan ada surah pertama (misalnya Al-Fatihah atau indeks 1)
      final alFatihah = find.text('Al-Fatihah');
      expect(alFatihah, findsWidgets); // Mungkin ada di beberapa tempat (Latin/Arab), kita cukup pastikan ada

      // Tap elemen Al-Fatihah
      await tester.tap(alFatihah.first);

      // Tunggu animasi pindah layar ke SurahDetailScreen dan fetch ayat
      bool foundAyat = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.text('Ayat 1').evaluate().isNotEmpty) {
          foundAyat = true;
          break;
        }
      }

      // Pastikan halaman Detail Surah terbuka (harus ada "Ayat 1")
      final ayat1 = find.text('Ayat 1');
      expect(ayat1, findsWidgets);

      // Skenario berhasil. Aplikasi akan menutup koneksi.
    });
  });
}
