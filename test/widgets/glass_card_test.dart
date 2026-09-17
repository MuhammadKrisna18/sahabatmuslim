import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhan_reminder/core/widgets/glass_card.dart';

void main() {
  testWidgets('GlassCard renders child widget correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            child: Text('Test GlassCard Content'),
          ),
        ),
      ),
    );

    // Verify that our text is found inside the GlassCard
    expect(find.text('Test GlassCard Content'), findsOneWidget);
    expect(find.byType(GlassCard), findsOneWidget);
  });
}
