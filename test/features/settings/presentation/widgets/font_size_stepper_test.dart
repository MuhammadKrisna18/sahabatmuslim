import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhan_reminder/features/settings/presentation/widgets/font_size_stepper.dart';

void main() {
  testWidgets('FontSizeStepper renders title, current size, and triggers callbacks', (tester) async {
    int decreaseCount = 0;
    int increaseCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FontSizeStepper(
            title: 'Ukuran Teks Arab',
            currentSize: 36.0,
            minSize: 20.0,
            maxSize: 56.0,
            onDecrease: () => decreaseCount++,
            onIncrease: () => increaseCount++,
          ),
        ),
      ),
    );

    expect(find.text('Ukuran Teks Arab'), findsOneWidget);
    expect(find.text('36 pt'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    expect(increaseCount, 1);

    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pump();
    expect(decreaseCount, 1);
  });

  testWidgets('FontSizeStepper disables buttons when at boundaries', (tester) async {
    int decreaseCount = 0;
    int increaseCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FontSizeStepper(
            title: 'Min Boundary',
            currentSize: 20.0,
            minSize: 20.0,
            maxSize: 56.0,
            onDecrease: () => decreaseCount++,
            onIncrease: () => increaseCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pump();
    expect(decreaseCount, 0);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    expect(increaseCount, 1);
  });
}
