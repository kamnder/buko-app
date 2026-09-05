import 'package:flutter_test/flutter_test.dart';
import 'package:buko/main.dart';

void main() {
  test('BUKO app can be constructed', () {
    const app = BukoApp();
    expect(app, isA<BukoApp>());
  });
}
