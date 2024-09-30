import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import '../utils/function.dart';
import 'file_download.dart';

class FbDownloadController extends GetxController {
  FileDownload downloadController = Get.put(FileDownload());

  // Method to handle Facebook video download
  Future<void> fb(String link) async {
    try {
      const data =
          'c480452d9cc3afa9f8ba7051efd1d55695c2925d6d0a5a27c196b1066e0cf3a93e5cb078760b871ef5a40e198cd5853d';
      var httpClient = HttpClient();

      // Construct the request
      var request = await httpClient.postUrl(Uri.parse(decrypt(data)));
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode({"url": link})));
      request.add(utf8.encode(json.encode({"ts": 1706350101780})));
      request.add(utf8.encode(json.encode({"_ts": 1706136626989})));
      request.add(utf8.encode(json.encode({"_tsc": 0})));
      request.add(utf8.encode(json.encode({
        "_s": "9d0d423e9443dffe0d8d746e06c248499890200cbdb49dfed4f63b452fc8b805"
      })));

      // Handle the response
      var response = await request.close();
      if (response.statusCode == 200) {
        // var json = await response.transform(utf8.decoder).join();
        // var decodedResponse = jsonDecode(json);
        // Further handling of the decoded response
        // Add download logic here if necessary, depending on response content
      } else {
        print(
            'Error: Failed to retrieve data with status code ${response.statusCode}');
      }

      // Close the client
      httpClient.close();
    } catch (e, stackTrace) {
      // Log the error and the stack trace
      catchInfo(e, stackTrace);
    }
  }
}
