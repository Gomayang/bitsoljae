import 'package:bitsoljae/sleepover/sleepover.dart';
import 'package:test/test.dart';

void main() async {
  test('get sleepover list', () {
    expect(getDegreeList("2024038099", "040609"), 1);
  });
}
