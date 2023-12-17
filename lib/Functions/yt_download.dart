import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:insta/Functions/fileDownload.dart';

class YTDownloadController extends GetxController {
  FileDownload downloadController = Get.put(FileDownload());
  youtube(String link) async {
    var url = 'https://api.akuari.my.id/downloader/yt1?link=$link';
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var ytData = jsonDecode(response.body);
      var title = ytData['info']['title']
          .toString()
          .replaceAll(RegExp(r"[&/\\#,+()$~%.\':*?<>{}]+"), '')
          .replaceAll("\n", "_")
          .replaceAll("|", "_");
      var thumbnail = ytData['info']['thumbnail'];
      var videoLink = ytData['urldl_video']['link'];
      downloadController.downloadFile(thumbnail, videoLink, title);
    }
  }
}
