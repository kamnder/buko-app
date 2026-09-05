import 'package:flutter_test/flutter_test.dart';
import 'package:buko/main.dart';

void main() {
  testWidgets('BUKO opens with welcome splash then home', (tester) async {
    await tester.pumpWidget(const BukoApp());
    expect(find.text('حبابك عشرة'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pumpAndSettle();
    expect(find.text('إبحث عن سيارتك'), findsOneWidget);
    expect(find.text('البحث المتقدم'), findsOneWidget);
  });
}
