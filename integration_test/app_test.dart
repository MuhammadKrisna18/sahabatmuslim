import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:adhan_reminder/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Testing SahabatMuslim', () {
    testWidgets('Buka aplikasi, navigasi ke Qur\'an, lalu buka detail Surah', (WidgetTester tester) async {
      app.main();

      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byKey(const Key('nav_quran')).evaluate().isNotEmpty) {
          break;
        }
      }
      
      final quranTab = find.byKey(const Key('nav_quran'));
      expect(quranTab, findsOneWidget);

      await tester.tap(quranTab);
      
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.text('Al-Fatihah').evaluate().isNotEmpty) {
          break;
        }
      }

      final alFatihah = find.text('Al-Fatihah');
      expect(alFatihah, findsWidgets);

      await tester.tap(alFatihah.first);

      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.text('Ayat 1').evaluate().isNotEmpty) {
          break;
        }
      }

      final ayat1 = find.text('Ayat 1');
      expect(ayat1, findsWidgets);
    });
  });
}
