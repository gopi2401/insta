import 'package:flutter_test/flutter_test.dart';
import 'package:insta/services/yt_download.dart';

void main() {
  group('YT Download', () {
    final service = YTDownloadController();

    test('YouTube video download functionality', () {
      service.youtube("https://www.youtube.com/watch?v=oiGdgtCAZZA");
    });
  });
}
