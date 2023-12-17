// ignore_for_file: file_names

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:insta/Functions/fileDownload.dart';
import 'package:insta/main.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
            debugPrint('Page finished loading: $cook');
            postReel(data);
          },
        ))
        ..loadRequest(Uri.parse(url));
    } catch (e) {
      debugPrint('downloadReal: $e');
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
}
