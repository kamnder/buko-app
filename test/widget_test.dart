import 'package:flutter_test/flutter_test.dart';
import 'package:buko/main.dart';

void main() {
  testWidgets('BUKO opens on authentication screen', (tester) async {
    await tester.pumpWidget(const BukoApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('BUKO'), findsOneWidget);
    expect(find.text('حبابك عشرة'), findsOneWidget);
    expect(find.text('رقم الهاتف السوداني'), findsOneWidget);
    expect(find.text('دخول إلى BUKO'), findsOneWidget);
    expect(find.text('حساب جديد'), findsOneWidget);
  });
}
