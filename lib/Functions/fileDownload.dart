import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:insta/main.dart';
import 'package:path_provider/path_provider.dart';

class FileDownload extends GetxController {
  downloadFile(notificationImg, url, fileName) async {
    HttpClient httpClient = HttpClient();
    var dir = await Directory('/storage/emulated/0/Download/Insta')
        .create(recursive: true);
    File file;
    String filePath = '';
    String type = 'mp4';
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == 200) {
        var arr = response.headers['content-type']!.toList();
        for (var element in arr) {
          if (element == 'video/mp4') {
            type = 'mp4';
          } else if (element == 'image/jpeg') {
            type = 'jpg';
          }
        }
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '${dir.path}/$fileName.$type';
        file = File(filePath);
        await file.writeAsBytes(bytes);
        _showNotificationMediaStyle(
            'Download/Insta/$fileName', notificationImg);
      } else {
        debugPrint('Error code:${response.statusCode.toString()} ');
      }
    } catch (e) {
      debugPrint('Can not fetch url $e');
    }
  }

  Future<void> _showNotificationMediaStyle(
      notificationBody, notificationImg) async {
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
        id++, 'Download Complete', notificationBody, notificationDetails);
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
