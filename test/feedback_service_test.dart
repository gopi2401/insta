import 'package:flutter_test/flutter_test.dart';
import 'package:insta/services/feedback_service.dart';

void main() {
  group('FeedbackService issue body', () {
    final service = FeedbackService();

    test('builds issue body with reporter and screenshot', () {
      final body = service.buildIssueBodyForTesting(
        body: 'Something broke',
        category: FeedbackCategory.issue,
        reporter: 'Alice',
        imageUrl: 'https://example.com/s.png',
      );

      expect(body, contains('Something broke'));
      expect(body, contains('img src="https://example.com/s.png"'));
      expect(body, contains('Issue raised by Alice.'));
    });

    test('builds suggestion body without optional fields', () {
      final body = service.buildIssueBodyForTesting(
        body: 'Add queue filters',
        category: FeedbackCategory.suggestion,
      );

      expect(body, equals('Add queue filters'));
    });
  });
}
