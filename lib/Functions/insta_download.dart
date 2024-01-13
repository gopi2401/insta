// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart' as foundation;
import 'package:get/get.dart';
import 'package:insta/Functions/fileDownload.dart';
import 'package:insta/main.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;

import '../models/graphql.dart';
import '../models/items.dart';

class InstaDownloadController extends GetxController {
  final WebViewController controller = WebViewController();
  final FileDownload downloadController = Get.put(FileDownload());
  downloadReal(String link) async {
    try {
      final url =
          "${link.replaceAll(" ", "").split("/").sublist(0, 5).join("/")}/?__a=1&__d=dis";

      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (String url) async {
            final cook = await controller.runJavaScriptReturningResult(
                'JSON.parse(document.documentElement.innerText)') as String;
            var data = jsonDecode(cook);
            foundation.debugPrint('Page finished loading: $cook');
            if (data['require_login'] != null && data['require_login']) {
              var httpClient = new HttpClient();
              var request = await httpClient.getUrl(
                  Uri.parse("https://backend.instavideosave.com/allinone"));
              request.headers.add('url', encryptFun(link));
              var response = await request.close();
              if (response.statusCode == HttpStatus.OK) {
                var json = await response.transform(utf8.decoder).join();
                var data = jsonDecode(json);
                if (data['video'] != null && data['video'].isNotEmpty) {
                  for (var file in data['video']) {
                    downloadController.downloadFile(
                        file['video'],
                        "ReelVideo-${Random().nextInt(900000) + 100000}",
                        file['thumbnail']);
                  }
                }
                if (data['image'] != null && data['image'].isNotEmpty) {
                  for (var url in data['image']) {
                    downloadController.downloadFile(url,
                        "ReelImage-${Random().nextInt(900000) + 100000}", url);
                  }
                }
              } else {
                navigatorKey.currentState?.pushNamed('login');
              }
            } else {
              postReel(data);
            }
          },
        ))
        ..loadRequest(Uri.parse(url));
    } catch (e) {
      foundation.debugPrint('downloadReal: $e');
    }
  }

  stories(String uName, String? sId) async {
    try {
      var url = 'https://igs.sf-converter.com/api/userInfoByUsername/$uName';
      final http.Response user = await http.get(Uri.parse(url));
      var userData = jsonDecode(user.body);
      var userId = userData['result']['user']['pk'];
      var url1 = 'https://igs.sf-converter.com/api/stories/$userId';
      final http.Response stories = await http.get(Uri.parse(url1));
      var storiesData = jsonDecode(stories.body);
      var arr = storiesData['result'];
      for (var storie in arr) {
        if (storie['pk'] == sId) {
          if (storie['image_versions2'] != null) {
            var image = storie['image_versions2']['candidates'][0]['url'];
            if (storie['video_versions'] != null) {
              var video = storie['video_versions'][0]['url'];
              downloadController.downloadFile(
                  video, 'storie_video_$sId', image);
            } else {
              downloadController.downloadFile(
                  image, 'storie_image_$sId', image);
            }
          }
        }
      }
      // arr.forEach((storie) {
      //   if (storie['pk'] == sId) {
      //     if (storie['image_versions2'] != null) {
      //       var image = storie['image_versions2']['candidates'][0]['url'];
      //       if (storie['video_versions'] != null) {
      //         var video = storie['video_versions'][0]['url'];
      //         downloadFile(image, video, 'storie_video_$sId');
      //       } else {
      //         downloadFile(image, image, 'storie_image_$sId');
      //       }
      //     }
      //   }
      // });
    } catch (e) {
      print(e);
    }
  }

  postReel(data) {
    if (data['require_login'] != null && data['require_login']) {
      navigatorKey.currentState?.pushNamed('login');
    }
    if (data['items'] != null) {
      Items post = Items.fromJson(data);
      var files = post.files;
      if (files != null) {
        for (var file in files) {
          downloadController.downloadFile(
              file.fileUrl, file.fileName, file.fileDisplayUrl);
        }
      }
    } else if (data['graphql'] != null) {
      Graphql post = Graphql.fromJson(data);
      var files = post.files;
      if (files != null) {
        for (var file in files) {
          downloadController.downloadFile(
              file.fileUrl, file.fileName, file.fileDisplayUrl);
        }
      }
    }
  }

  String encryptFun(String input) {
    final key = encrypt.Key.fromUtf8('qwertyuioplkjhgf');
    final iv = encrypt.IV.fromLength(16); // IV length is 16 for AES
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb));
    // Encrypt the input directly
    final encrypted = encrypter.encrypt(input, iv: iv);
    // Convert the encrypted bytes to a hex string
    final encryptedHex = encrypted.base16;
    return encryptedHex;
  }

  String nameFun(String input) {
    var text = input
        .toString()
        .replaceAll(RegExp(r"[&/\\#,+()$~%.\':*?<>{}]+"), '')
        .replaceAll("\n", "_")
        .replaceAll("|", "_");
    return text.length >= 60 ? text.substring(0, 60) : text;
  }
}
