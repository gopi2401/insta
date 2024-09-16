import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import '../instagram_login_page.dart';
import '../models/graphql.dart';
import '../models/items.dart';
import '../models/story_model.dart';
import '../utils/appdata.dart';
import '../utils/function.dart';
import 'file_download.dart';

class InstaDownloadController extends GetxController {
  final WebViewController controller = WebViewController();
  final FileDownload downloadController = Get.put(FileDownload());

  // Downloads media from the provided link
  Future<void> downloadReal(String link) async {
    try {
      final url =
          "${link.trim().split("/").sublist(0, 5).join("/")}/?__a=1&__d=dis";

      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (String url) async {
            try {
              final cook = await controller.runJavaScriptReturningResult(
                  'JSON.parse(document.documentElement.innerText)') as String;
              var data = jsonDecode(cook);
              debugPrint('Page finished loading: $cook');
              if (data == null ||
                  (data['require_login'] != null && data['require_login'])) {
                try {
                  var httpClient = HttpClient();
                  var request =
                      await httpClient.getUrl(Uri.parse(decrypt(insta)));
                  request.headers.add('url', encryption(link));
                  var response = await request.close();
                  if (response.statusCode == HttpStatus.ok) {
                    var json = await response.transform(utf8.decoder).join();
                    var responseData = jsonDecode(json);
                    downloadMedia(responseData);
                  } else {
                    isLoading = false;
                    Get.to(() => const InstaLogin());
                  }
                } catch (e, stackTrace) {
                  isLoading = false;
                  catchInfo(e, stackTrace);
                }
              } else {
                postReel(data);
              }
            } catch (e, stackTrace) {
              catchInfo(e, stackTrace);
            }
          },
        ))
        ..loadRequest(Uri.parse(url));
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
    }
  }

  // Fetches and downloads Instagram stories
  Future<void> stories(String uName, String? sId) async {
    try {
      final userResponse =
          await http.get(Uri.parse('${igs}userInfoByUsername/$uName'));
      var userId = jsonDecode(userResponse.body)['result']['user']['id'];
      final storiesResponse =
          await http.get(Uri.parse('${igs}stories/$userId'));
      var storiesData = Story.fromJson(jsonDecode(storiesResponse.body));
      if (storiesData.stories.isNotEmpty) {
        for (var story in storiesData.stories) {
          if (story.pk == sId) {
            var image = story.img;
            var video = story.storie;
            downloadController.downloadFile(
                video.isNotEmpty ? video : image, 'story_$sId', image);
          }
        }
      }
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
    }
  }

  // Handles downloading media files (video or image)
  void downloadMedia(Map<String, dynamic> data) {
    try {
      if (data['video'] != null && data['video'].isNotEmpty) {
        for (var file in data['video']) {
          downloadController.downloadFile(
              file['video'],
              "ReelVideo-${Random().nextInt(900000) + 100000}.mp4",
              file['thumbnail']);
        }
      }

      if (data['image'] != null && data['image'].isNotEmpty) {
        for (var url in data['image']) {
          downloadController.downloadFile(
              url, "ReelImage-${Random().nextInt(900000) + 100000}.jpg", url);
        }
      }
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
    }
  }

  // Handles post reel media
  bool postReel(Map<String, dynamic> data) {
    try {
      if (data['items'] != null) {
        Items post = Items.fromJson(data);
        var files = post.files;
        if (files != null) {
          for (var file in files) {
            downloadController.downloadFile(
                file.fileUrl!, file.fileName!, file.fileDisplayUrl);
          }
          return true;
        } else {
          return false;
        }
      } else if (data['graphql'] != null) {
        Graphql post = Graphql.fromJson(data);
        var files = post.files;
        if (files != null) {
          for (var file in files) {
            downloadController.downloadFile(
                file.fileUrl!, file.fileName!, file.fileDisplayUrl);
          }
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
      return false;
    }
  }
}
