import 'package:flutter_test/flutter_test.dart';
import 'package:insta/features/downloader/yt_download_service.dart';

void main() {
  group('YT Download', () {
    final service = YTDownloadController();

    test('YouTube video download functionality', () {
      service.youtube("https://www.youtube.com/watch?v=oiGdgtCAZZA");
    });
  });
}
