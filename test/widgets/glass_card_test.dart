import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhan_reminder/core/widgets/glass_card.dart';

void main() {
  testWidgets('GlassCard renders child widget correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            child: Text('Test GlassCard Content'),
          ),
        ),
      ),
    );

    expect(find.text('Test GlassCard Content'), findsOneWidget);
    expect(find.byType(GlassCard), findsOneWidget);
  });
}
