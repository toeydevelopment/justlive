import 'package:flutter_test/flutter_test.dart';
import 'package:justlive/main.dart';

void main() {
  testWidgets('Home screen contains greeting', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Hello, Justlive!'), findsOneWidget);
  });
}
