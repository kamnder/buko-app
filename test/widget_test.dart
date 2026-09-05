import 'package:flutter_test/flutter_test.dart';
import 'package:buko/main.dart';

void main() {
  testWidgets('BUKO app loads', (tester) async {
    await tester.pumpWidget(const BukoApp());
    expect(find.text('إبحث عن سيارتك'), findsOneWidget);
    expect(find.text('البحث المتقدم'), findsOneWidget);
  });
}
