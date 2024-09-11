import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:insta/main.dart';
import 'package:path_provider/path_provider.dart';

class FileDownload extends GetxController {
  // Download File and Show Progress
  void downloadFile(
      String url, String fileName, String? notificationImg) async {
    Dio dio = Dio();
    try {
      // Random ID for notifications
      Random random = Random();
      int progressId = random.nextInt(100);
      int progress = 0;

      // Ensure the directory exists
      final dir = Directory('/storage/emulated/0/Download/Insta');
      if (!(await dir.exists())) {
        await dir.create(recursive: true);
      }

      // Start file download
      await dio.download(
        url,
        '${dir.path}/$fileName',
        onReceiveProgress: (received, total) async {
          if (total != -1) {
            int progressValue = (received / total * 100).toInt();
            if (progressValue > progress) {
              progress = progressValue;
              print('$progressValue% downloaded');

              // Show notification at specific progress points
              if (progress == 0 || progress == 50 || progress == 85) {
                await _showProgressNotification(progress, progressId);
              }
            }
          }
        },
      );

      // Download complete, show the completion notification
      await _showNotificationMediaStyle(
          '$fileName downloaded', notificationImg, progressId);
    } catch (e) {
      print('Error during download: $e');
      // Optionally show error notification
      await _showErrorNotification();
    }
  }

  // Show progress notification
  Future<void> _showProgressNotification(int progress, int progressId) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'progress_channel',
      'Progress Channel',
      channelDescription: 'Shows the progress of the download',
      importance: Importance.max,
      priority: Priority.high,
      showProgress: true,
      maxProgress: 100,
      onlyAlertOnce: true,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      progressId,
      'Download in progress',
      '$progress% downloaded',
      notificationDetails,
    );
  }

  // Show download complete notification with media style
  Future<void> _showNotificationMediaStyle(
      String notificationBody, String? notificationImg, int idno) async {
    var largeIconPath;
    if (notificationImg != null) {
      largeIconPath = await _downloadAndSaveFile(notificationImg, 'largeIcon');
    }

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'media_channel',
      'Media Channel',
      channelDescription: 'Media style notification for downloads',
      largeIcon:
          largeIconPath != null ? FilePathAndroidBitmap(largeIconPath) : null,
      styleInformation: const MediaStyleInformation(),
    );
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      idno,
      'Download Complete',
      notificationBody,
      notificationDetails,
    );
  }

  // Show error notification (optional)
  Future<void> _showErrorNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'error_channel',
      'Error Channel',
      channelDescription: 'Channel for download errors',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Download Failed',
      'An error occurred during download',
      notificationDetails,
    );
  }

  // Helper to download and save a file (e.g., for large icon)
  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
