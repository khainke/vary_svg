import 'package:test/test.dart';

void main() {
  group('Behavior of Uri functions', () {
    test('Relative path should be resolved correctly', () {
      final dir = 'some/directory/';
      final path = 'a/subdir/';
      final test = Uri().resolve(dir).resolve(path);
      final expected = Uri().resolve('some/directory/a/subdir/');
      expect(
        test,
        expected,
      );
    });

    test('Absolute path should remain the same when resolved', () {
      final dir = 'some/directory/';
      final path = '/c/some/absolute/path/';
      final test = Uri().resolve(dir).resolve(path);
      final expected = Uri().resolve(path);
      expect(
        test,
        expected,
      );
    });

    test('Resolving from an empty Uri should not change the path', () {
      final dir = '';
      final path = 'some/path/';
      final test = Uri().resolve(dir).resolve(path);
      final expected = Uri().resolve(path);
      expect(
        test,
        expected,
      );
    });
  });
}
