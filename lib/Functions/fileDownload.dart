import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:insta/main.dart';
import 'package:path_provider/path_provider.dart';

class FileDownload extends GetxController {
  void downloadFile(url, fileName, notificationImg) async {
    Dio _dio = Dio();
    try {
      Random random = new Random();
      int progressId = random.nextInt(100);
      int progress = 0;
      await _dio.download(url, '/storage/emulated/0/Download/Insta/$fileName',
          onReceiveProgress: (received, total) async {
        if (total != -1) {
          int progre = (received / total * 100).toInt();
          if (progre == 0 || progre > progress) {
            progress = progre;
            print((received / total * 100).toStringAsFixed(0) + '%');
            if (progress == 0 || progress == 50 || progress == 85) {
              await _showProgressNotification(progress, progressId);
            }
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
    var largeIconPath;
    if (notificationImg != null) {
      final String file =
          await _downloadAndSaveFile(notificationImg, 'largeIcon');
      largeIconPath = FilePathAndroidBitmap(file);
    }
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'media channel id',
      'media channel name',
      channelDescription: 'media channel description',
      largeIcon: largeIconPath,
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
