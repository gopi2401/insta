import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:insta/Functions/fileDownload.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class YTDownloadController extends GetxController {
  FileDownload downloadController = Get.put(FileDownload());
  fb(String link) async {
    const data =
        'c480452d9cc3afa9f8ba7051efd1d55695c2925d6d0a5a27c196b1066e0cf3a93e5cb078760b871ef5a40e198cd5853d';
    var httpClient = HttpClient();
    var request = await httpClient.postUrl(Uri.parse(decryptFun(data)));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode({"url": link})));
    request.add(utf8.encode(json.encode({"ts": 1706350101780})));
    request.add(utf8.encode(json.encode({"_ts": 1706136626989})));
    request.add(utf8.encode(json.encode({"_tsc": 0})));
    request.add(utf8.encode(json.encode({
      "_s": "9d0d423e9443dffe0d8d746e06c248499890200cbdb49dfed4f63b452fc8b805"
    })));
    var response = await request.close();
    if (response.statusCode == 200) {
      var json = await response.transform(utf8.decoder).join();
      jsonDecode(json);
    }
  }

  String decryptFun(String encryptedHex) {
    final key = encrypt.Key.fromUtf8('qwertyuioplkjhgf');
    final iv = encrypt.IV.fromLength(16); // IV length is 16 for AES
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb));

    // Convert the hex string back to encrypted bytes
    final encryptedBytes = encrypt.Encrypted.fromBase16(encryptedHex);

    // Decrypt the encrypted bytes
    final decrypted = encrypter.decrypt(encryptedBytes, iv: iv);

    return decrypted;
  }

  String titleFun(String title) {
    return title
        .replaceAll(RegExp(r"[&/\\#,+()$~%.\':*?<>{}]+"), '')
        .replaceAll("\n", "_")
        .replaceAll("|", "_");
  }
}
