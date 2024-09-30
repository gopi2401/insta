import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:get/get.dart';

import '../utils/function.dart';
import 'file_download.dart';

class YTDownloadController extends GetxController {
  FileDownload downloadController = Get.put(FileDownload());

  // Method to handle YouTube video download
  Future<void> youtube(String link) async {
    try {
      const data =
          '28092c5adf73dfe1043e22afc831a963d8926e00376069b4fa6f11f2a749ca71c3858d6b92e169c7eddae27198e9db04';
      var httpClient = HttpClient();

      // Sending the initial request
      var request = await httpClient.postUrl(Uri.parse(decrypt(data)));
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode({"url": link})));

      var response = await request.close();
      if (response.statusCode == 200) {
        var json = await response.transform(utf8.decoder).join();
        var jsons = jsonDecode(json);

        const jobCheckUrl =
            "28092c5adf73dfe1043e22afc831a9630f64a4da5e3ff0e33ce8f4c48fb2ec78a429ae8534d4463fb501aef3331ac7ea";
        dynamic payload;

        // Polling for the job result
        do {
          await Future.delayed(const Duration(seconds: 1));
          var req = await httpClient
              .getUrl(Uri.parse(decrypt(jobCheckUrl) + jsons['job_id']));
          req.headers.set('content-type', 'application/json');
          var res = await req.close();

          if (res.statusCode == 200) {
            var json = await res.transform(utf8.decoder).join();
            payload = jsonDecode(json);
          }
        } while (payload['status'] == 'working');

        // Handle the result once the job is finished
        if (payload["payload"] != null) {
          var file = payload["payload"][0]['path'];
          downloadController.downloadFile(file,
              "YoutubeVideo-${Random().nextInt(900000) + 100000}.mp4", null);
          httpClient.close();
        }
      }
    } catch (e, stackTrace) {
      // Log the error and the stack trace
      catchInfo(e, stackTrace);
    }
  }
}
