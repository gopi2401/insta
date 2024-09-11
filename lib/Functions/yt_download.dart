import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:get/get.dart';

import '../utils/function.dart';
import 'file_download.dart';

class YTDownloadController extends GetxController {
  FileDownload downloadController = Get.put(FileDownload());
  youtube(String link) async {
    try {
      const data =
          '28092c5adf73dfe1043e22afc831a963d8926e00376069b4fa6f11f2a749ca71c3858d6b92e169c7eddae27198e9db04';
      var httpClient = HttpClient();
      var request = await httpClient.postUrl(Uri.parse(decrypt(data)));
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode({"url": link})));
      var response = await request.close();
      if (response.statusCode == 200) {
        var json = await response.transform(utf8.decoder).join();
        var jsons = jsonDecode(json);
        const d =
            "28092c5adf73dfe1043e22afc831a9630f64a4da5e3ff0e33ce8f4c48fb2ec78a429ae8534d4463fb501aef3331ac7ea";
        // ignore: prefer_typing_uninitialized_variables
        var payload;
        do {
          await Future.delayed(const Duration(seconds: 1));
          var req =
              await httpClient.getUrl(Uri.parse(decrypt(d) + jsons['job_id']));
          req.headers.set('content-type', 'application/json');
          var res = await req.close();
          if (res.statusCode == 200) {
            var json = await res.transform(utf8.decoder).join();
            payload = jsonDecode(json);
          }
        } while (payload['status'] == 'working');
        if (payload["payload"] != null) {
          var file = payload["payload"][0]['path'];
          // Uri uri = Uri.parse(file);
          // var title = Functions.titleFun(uri.queryParameters['title']!);
          downloadController.downloadFile(file,
              "YoutubeVideo-${Random().nextInt(900000) + 100000}.mp4", null);
          httpClient.close();
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
