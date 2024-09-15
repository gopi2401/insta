import 'package:get/get.dart';
import 'package:insta/functions/insta_download.dart';
import 'package:insta/functions/yt_download.dart';

import '../utils/function.dart';

class DistribUrl extends GetxController {
  InstaDownloadController instaController = Get.put(InstaDownloadController());
  YTDownloadController ytController = Get.put(YTDownloadController());

  void handleUrl(String url) {
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
        var segments = url.split("/");
        if (segments.length > 3) {
          var option = segments[3];
          if (option == 'p' || option == 'reel') {
            instaController.downloadReal(url);
          } else if (option == 'stories' && segments.length > 5) {
            var userId = segments[4];
            var storyId = segments[5];
            RegExp regExp = RegExp(r'^(\d+)');
            var match = regExp.firstMatch(storyId);
            if (match != null) {
              instaController.stories(userId, match.group(0)!);
            }
          }
        }
      } else if (isYouTube || isYouTubeShort) {
        ytController.youtube(url);
      }
    } catch (e, stackTrace) {
      // Log the error and the stack trace
      catchInfo(e, stackTrace);
    }
  }
}
