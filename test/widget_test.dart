import 'package:flutter_test/flutter_test.dart';
import 'package:buko/main.dart';

void main() {
  testWidgets('BUKO app loads after splash', (tester) async {
    await tester.pumpWidget(const BukoApp());
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();
    expect(find.text('BUKO'), findsOneWidget);
    expect(find.text('اعثر على سيارتك'), findsOneWidget);
    expect(find.text('بحث متقدم'), findsOneWidget);
  });
}
