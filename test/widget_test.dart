import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/main.dart';

void main() {
  testWidgets('Stryde app smoke test loads main navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: StrydeApp(),
      ),
    );

    expect(find.text('STRYDE'), findsWidgets);
    expect(find.text('TRACK'), findsOneWidget);
    expect(find.text('HISTORY'), findsOneWidget);
    expect(find.text('ANALYTICS'), findsOneWidget);
    expect(find.text('GEAR'), findsOneWidget);
  });
}
