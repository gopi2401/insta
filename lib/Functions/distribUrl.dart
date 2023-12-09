import 'package:get/get.dart';
import 'package:insta/Functions/insta_download.dart';
import 'package:insta/Functions/yt_download.dart';

class DistribUrl extends GetxController {
  InstaDownloadController instaController = Get.put(InstaDownloadController());
  YTDownloadController ytController = Get.put(YTDownloadController());
  url(url) {
    RegExp ins = RegExp(r'instagram.com');
    bool test = ins.hasMatch(url);
    RegExp you = RegExp(r'youtube.com');
    RegExp youm = RegExp(r'youtu.be');
    bool yt = you.hasMatch(url);
    bool ytm = youm.hasMatch(url);
    if (test) {
      var optIon = url.split("/")[3];
      if (optIon == 'p' || optIon == 'reel') {
        instaController.downloadReal(url);
      } else if (optIon == 'stories') {
        var data = url.split('/');
        RegExp regExp = RegExp(r'^(\d+)');
        var match = regExp.firstMatch(data[5]);
        if (match == null) return;
        instaController.stories(data[4], match.group(0));
      }
    } else if (yt || ytm) {
      ytController.youtube(url);
    }
  }
}
