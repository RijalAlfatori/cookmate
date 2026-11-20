import 'package:flutter_test/flutter_test.dart';
import 'package:cookmate/main.dart';

void main() {
  testWidgets('CookMate app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CookMateApp());
    // Pompa widget dan lewatkan timer timeout (15 detik) agar timer terselesaikan
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 16));
    expect(find.byType(CookMateApp), findsOneWidget);
  });
}
