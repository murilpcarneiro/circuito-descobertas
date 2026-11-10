import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prefixo do QR', () {
    expect('circuito:E01'.startsWith('circuito:'), isTrue);
  });
}
