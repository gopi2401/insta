import 'package:get/get.dart';

import '../utils/app_utils.dart';
import 'insta_download.dart';
import 'yt_download.dart';

class DistribUrl extends GetxController {
  late InstaDownloadController instaController;
  late YTDownloadController ytController;

  Future<void> handleUrl(String url) async {
    try {
      // If the incoming text contains other words (e.g. "Check this out: https://..."),
      // extract the first http(s) URL found. Fall back to the original string if none.
      final urlMatch = RegExp(r'https?://[^\s]+').firstMatch(url);
      final incoming = urlMatch != null ? urlMatch.group(0)!.trim() : url.trim();

      // Instagram URL patterns
      final isInstagram = RegExp(r'instagram\.com|instagr\.am', caseSensitive: false)
          .hasMatch(incoming);

        // YouTube URL patterns (check the extracted incoming text)
        final isYouTube = RegExp(r'youtube\.com|youtube\.googleapis|youtu\.be|youtube',
            caseSensitive: false)
          .hasMatch(incoming);
        final isYouTubeShort = RegExp(r'youtu\.be|/shorts/', caseSensitive: false)
          .hasMatch(incoming);

      if (isInstagram) {
        instaController = Get.put(InstaDownloadController());
        final uri = Uri.tryParse(incoming);
        if (uri != null) {
          final segments = uri.pathSegments;

          // Find which Instagram resource this URL points to
          if (segments.isNotEmpty) {
            // common: /p/{shortcode}/ or /reel/{shortcode}/
            final first = segments[0].toLowerCase();
            if (first == 'p' || first == 'reel') {
              await instaController.downloadReal(incoming, null);
              instaController.onClose();
            } else if (first == 'stories' && segments.length >= 3) {
              // /stories/{username}/{storyId}
              final userId = segments[1];
              final storyId = segments[2];
              final idMatch = RegExp(r'^(\d+)').firstMatch(storyId);
              if (idMatch != null) {
                await instaController.stories(userId, idMatch.group(0)!);
                instaController.onClose();
              }
            } else if (segments.contains('highlights')) {
              // /stories/highlights/{highlightId} or /{username}/highlights/{id}
              final idx = segments.indexOf('highlights');
              if (idx + 1 < segments.length) {
                final highlightId = segments[idx + 1];
                await instaController.highlight(highlightId);
                instaController.onClose();
              }
            } else {
              // fallback: try to detect shortcode in the path and attempt download
              // e.g. instagram.com/{username}/p/{shortcode} or embedded links
              if (incoming.contains('/p/') || incoming.contains('/reel/')) {
                await instaController.downloadReal(incoming, null);
                instaController.onClose();
              }
            }
          }
        } else {
          // If parsing failed, attempt naive match for /p/ or /reel/ in the raw text
          if (incoming.contains('/p/') || incoming.contains('/reel/')) {
            instaController = Get.put(InstaDownloadController());
            await instaController.downloadReal(incoming, null);
            instaController.onClose();
          }
        }
      } else if (isYouTube || isYouTubeShort) {
        ytController = Get.put(YTDownloadController());
        // pass the cleaned/extracted URL (incoming) so short links and embedded
        // text are handled correctly by the YouTube downloader
        await ytController.youtube(incoming);
      }
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
    }
  }
}
