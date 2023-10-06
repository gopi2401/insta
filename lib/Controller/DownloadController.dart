import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:insta/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../model/insta_post_with_login.dart';
import '../model/insta_post_without_login.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart' as wb;
import 'package:http/http.dart' as http;

class DownloadController extends GetxController {
  var processing = false.obs;
  bool isLogin = false;
  String? path;
  var box = GetStorage();
  Dio dio = Dio();
  Future<String?> _startDownload(String link) async {
    // Asking for video storage permission
    await Permission.storage.request();
    isLogin = false;
    // Checking for Cookies
    final cookieManager = wb.WebviewCookieManager();
    final gotCookies =
        await cookieManager.getCookies('https://www.instagram.com/');
    // is Cookie found then set isLogin to true
    if (gotCookies.length > 0) isLogin = true;

    // Build the url
    var linkParts = link.replaceAll(" ", "").split("/");
    var url =
        '${linkParts[0]}//${linkParts[2]}/${linkParts[3]}/${linkParts[4]}' +
            "?__a=1&__d=dis";

    // Make Http requiest to get the download link of video
    var httpClient = new HttpClient();
    String? videoURLLLLL;
    String? ImgURLLLLL;
    String? fileName;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      for (var element in gotCookies) {
        request.cookies.add(Cookie(element.name, element.value));
      }
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        // print(response);
        var json = await response.transform(utf8.decoder).join();
        var data = jsonDecode(json);
        // print(data);
        if (isLogin) {
          if (data['items'] != null) {
            InstaPostWithLogin postWithLogin =
                InstaPostWithLogin.fromJson(data);
            videoURLLLLL = postWithLogin.items?.first.videoVersions?.first.url;
            data['items'].forEach((json) {
              if (json['caption'] != null) {
                var dddddd = json['caption'];
                var ssss = dddddd['text']
                    .toString()
                    .replaceAll("\n", "_")
                    .replaceAll("#", "_");
                ssss.length >= 60
                    ? fileName = ssss.substring(0, 60)
                    : fileName = ssss;
              }
            });
          } else if (data['graphql'] != null) {
            InstaPostWithoutLogin post = InstaPostWithoutLogin.fromJson(data);
            videoURLLLLL = post.graphql?.shortcodeMedia?.videoUrl;
            var s = data['graphql']['shortcode_media']['edge_media_to_caption']
                    ['edges'][0]['node']['text']
                .toString()
                .replaceAll("\n", "_")
                .replaceAll("#", "_");
            s.length >= 60 ? fileName = s.substring(0, 60) : fileName = s;
            ImgURLLLLL = data['graphql']['shortcode_media']['display_url'];
          }
        } else {
          InstaPostWithoutLogin post = InstaPostWithoutLogin.fromJson(data);
          videoURLLLLL = post.graphql?.shortcodeMedia?.videoUrl;
        }
      } else {
        navigatorKey.currentState?.pushNamed('login');
      }
      // Download video & save
      if (videoURLLLLL == null) {
        return null;
      } else {
        // var knockDir = await new Directory('/storage/emulated/0/Download/Insta')
        //     .create(recursive: true);
        // var appDocDir = await getTemporaryDirectory();
        // String savePath = knockDir.path + '/$fileName.mp4';
        // String savePath = '/storage/emulated/0/insta' + '/$fileName.mp4';
        // await dio.download(videoURLLLLL, savePath);
        downloadFile(ImgURLLLLL, videoURLLLLL, fileName);
      }
    } catch (exception) {
      log(exception.toString());
    }
  }

  Future<String> downloadFile(ImgURLLLLL, url, fileName) async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';
    // String fileName = 'video.mp4';

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        var Dir = await new Directory('/storage/emulated/0/Download/Insta')
            .create(recursive: true);
        filePath = '${Dir.path}/$fileName.mp4';
        file = File(filePath);
        await file.writeAsBytes(bytes);
        _showNotificationMediaStyle(filePath, ImgURLLLLL);
      } else
        filePath = 'Error code: ' + response.statusCode.toString();
    } catch (ex) {
      filePath = 'Can not fetch url';
    }

    return filePath;
  }

  downloadReal(String link) async {
    processing.value = true;
    try {
      await _startDownload(link).then((value) {});
    } catch (e) {
      Fluttertoast.showToast(
          msg: "failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    processing.value = false;
  }

  Future<void> _showNotificationMediaStyle(
      notification_body, ImgURLLLLL) async {
    final String largeIconPath =
        await _downloadAndSaveFile(ImgURLLLLL, 'largeIcon');
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'media channel id',
      'media channel name',
      channelDescription: 'media channel description',
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: const MediaStyleInformation(),
    );
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        id++, 'Download Complete', notification_body, notificationDetails);
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
