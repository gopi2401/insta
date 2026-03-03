import 'package:flutter_test/flutter_test.dart';
import 'package:insta/utils/url_validation.dart';

void main() {
  group('isValidHttpUrl', () {
    test('accepts valid http and https URLs', () {
      expect(isValidHttpUrl('https://instagram.com/p/abc123'), isTrue);
      expect(isValidHttpUrl('http://example.com/video.mp4'), isTrue);
    });

    test('rejects invalid inputs', () {
      expect(isValidHttpUrl(''), isFalse);
      expect(isValidHttpUrl('instagram.com/p/abc123'), isFalse);
      expect(isValidHttpUrl('ftp://example.com/file'), isFalse);
      expect(isValidHttpUrl('not-a-url'), isFalse);
    });
  });
}
