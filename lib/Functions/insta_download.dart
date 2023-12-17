// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:insta/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio/dio.dart';

import 'package:http/http.dart' as http;

import '../models/graphql.dart';
import '../models/items.dart';

class InstaDownloadController extends GetxController {
  final WebViewController controller = WebViewController();
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
              _downloadFile(video, 'storie_video_$sId', image);
            } else {
              _downloadFile(image, 'storie_image_$sId', image);
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
          _downloadFile(file.fileUrl, file.fileName, file.fileDisplayUrl);
        }
      }
    } else if (data['graphql'] != null) {
      Graphql post = Graphql.fromJson(data);
      var files = post.files;
      if (files != null) {
        for (var file in files) {
          _downloadFile(file.fileUrl, file.fileName, file.fileDisplayUrl);
        }
      }
    }
  }

  // void _showProgressNotification(int progress) async {
  //   var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
  //       'channelId', 'channelName',
  //       channelDescription: 'channelDescription',
  //       importance: Importance.high,
  //       priority: Priority.high);

  //   var platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);

  //   await _flutterLocalNotificationsPlugin.show(
  //     0,
  //     'Download in progress',
  //     '$progress% downloaded',
  //     platformChannelSpecifics,
  //     payload: 'Download in progress',
  //   );
  // }

  void _downloadFile(url, fileName, notificationImg) async {
    Dio _dio = Dio();
    try {
      Random random = new Random();
      int progressId = random.nextInt(100);
      await _dio.download(url, '/storage/emulated/0/Download/Insta/$fileName',
          onReceiveProgress: (received, total) async {
        if (total != -1) {
          int progress = (received / total * 100).toInt();
          print((received / total * 100).toStringAsFixed(0) + '%');
          if (progress == 0 || progress == 50 || progress == 85) {
            await _showProgressNotification(progress, progressId);
          }
        }
      });

      // Download completed, show a completion notification
      await _showNotificationMediaStyle(
          'Download/Insta/$fileName', notificationImg, progressId);
    } catch (e) {
      print('Error during download: $e');
      // Handle download error, show an error notification
      // await _flutterLocalNotificationsPlugin.show(
      //   0,
      //   'Download error',
      //   'An error occurred during download',
      //   NotificationDetails(),
      //   payload: 'Download error',
      // );
    }
  }

  // downloadFile(notificationImg, url, fileName) async {
  //   HttpClient httpClient = HttpClient();
  //   var dir = await Directory('/storage/emulated/0/Download/Insta')
  //       .create(recursive: true);
  //   File file;
  //   String filePath = '';
  //   String type = 'mp4';
  //   try {
  //     var request = await httpClient.getUrl(Uri.parse(url));
  //     var response = await request.close();
  //     if (response.statusCode == 200) {
  //       var arr = response.headers['content-type']!.toList();
  //       for (var element in arr) {
  //         if (element == 'video/mp4') {
  //           type = 'mp4';
  //         } else if (element == 'image/jpeg') {
  //           type = 'jpg';
  //         }
  //       }
  //       var bytes = await consolidateHttpClientResponseBytes(response);
  //       filePath = '${dir.path}/$fileName.$type';
  //       file = File(filePath);
  //       await file.writeAsBytes(bytes);
  //       // _showNotificationMediaStyle(
  //       //     'Download/Insta/$fileName', notificationImg);
  //     } else {
  //       debugPrint('Error code:${response.statusCode.toString()} ');
  //     }
  //   } catch (e) {
  //     debugPrint('Can not fetch url $e');
  //   }
  // }

  Future<void> _showProgressNotification(progress, progressId) async {
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('progress channel', 'progress channel',
            channelDescription: 'progress channel description',
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: 100,
            progress: progress);
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(progressId,
        'Download in progress', '$progress% downloaded', notificationDetails,
        payload: 'Download in progress');
  }

  Future<void> _showNotificationMediaStyle(
      notificationBody, notificationImg, idno) async {
    final String largeIconPath =
        await _downloadAndSaveFile(notificationImg, 'largeIcon');
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
        idno, 'Download Complete', notificationBody, notificationDetails);
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
