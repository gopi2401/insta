import 'package:get/get.dart';

import '../utils/function.dart';
import 'insta_download.dart';
import 'yt_download.dart';

class DistribUrl extends GetxController {
  late InstaDownloadController instaController;
  late YTDownloadController ytController;

  handleUrl(String url) async {
    try {
      // Instagram URL patterns
      RegExp ins = RegExp(r'instagram.com');
      bool isInstagram = ins.hasMatch(url);

      // YouTube URL patterns
      RegExp you = RegExp(r'youtube.com');
      RegExp youm = RegExp(r'youtu.be');
      bool isYouTube = you.hasMatch(url);
      bool isYouTubeShort = youm.hasMatch(url);

      if (isInstagram) {
        instaController = Get.put(InstaDownloadController());
        var segments = url.split("/");
        if (segments.length > 3) {
          var option = segments[3];
          if (option == 'p' || option == 'reel') {
            await instaController.downloadReal(url);
            instaController.onClose();
          } else if (option == 'stories' && segments.length > 5) {
            if (segments[4] == 'highlights') {
              await instaController.highlight(segments[5]);
              instaController.onClose();
            } else {
              var userId = segments[4];
              var storyId = segments[5];
              RegExp regExp = RegExp(r'^(\d+)');
              var match = regExp.firstMatch(storyId);
              if (match != null) {
                await instaController.stories(userId, match.group(0)!);
                instaController.onClose();
              }
            }
          }
        }
      } else if (isYouTube || isYouTubeShort) {
        ytController = Get.put(YTDownloadController());
        ytController.youtube(url);
      }
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
    }
  }
}
