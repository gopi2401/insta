import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../main.dart';
import '../utils/function.dart';
import 'notification_service.dart';
import 'recovery_service.dart';

class FileDownload extends GetxController {
  // lazily resolve the notification service; if it's not registered yet we create it
  NotificationService get notificationService {
    if (!Get.isRegistered<NotificationService>()) {
      Get.put(NotificationService(), permanent: true);
    }
    return NotificationService.to;
  }

  // lazily resolve the recovery service; if it's not registered yet we create it
  RecoveryService get recoveryService {
    if (!Get.isRegistered<RecoveryService>()) {
      Get.put(RecoveryService(), permanent: true);
    }
    return RecoveryService.to;
  }

  // Download File and Show Progress
  Future<dynamic> downloadFile(
    String url,
    String fileName,
    String? notificationImg, {
    DownloadType downloadType = DownloadType.other,
  }) async {
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
      
      final filePath = '${dir.path}/$fileName';
      
      // Start file download
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) async {
          try {
            if (total != -1) {
              int progressValue = (received / total * 100).toInt();
              if (progressValue > progress) {
                progress = progressValue;
                print('$progressValue% downloaded');

                // Calculate speed and ETA
                final speed = _calculateSpeed(received, total);
                final eta = _calculateETA(received, total);

                // Show notification at specific progress points
                if (progress == 0 || progress % 10 == 0) {
                  await notificationService.showProgressNotification(
                    id: progressId,
                    title: fileName,
                    progress: progress,
                    type: downloadType,
                  );
                }
              }
            }
          } catch (e, stackTrace) {
            catchInfo(e, stackTrace);
          }
        },
      );

      // Download complete, show the completion notification
      await notificationService.showCompletionNotification(
        id: progressId,
        title: 'Download Complete',
        fileName: fileName,
        type: downloadType,
        imagePath: notificationImg,
      );
    } catch (e, stackTrace) {
      print('Error during download: $e');
      await notificationService.showErrorNotification(
        id: Random().nextInt(100),
        title: 'Download Failed',
        errorMessage: 'Failed to download $fileName',
      );
      catchInfo(e, stackTrace);
    }
  }

  String _calculateSpeed(int received, int total) {
    // Simplified speed calculation in KB/s
    final speedKbps = (received / 1024).toStringAsFixed(2);
    return '$speedKbps KB/s';
  }

  String _calculateETA(int received, int total) {
    if (received == 0) return 'calculating...';
    // Simplified ETA calculation
    const estimatedTimePerMB = 5; // seconds, adjust based on actual speed
    final remainingBytes = total - received;
    final remainingSeconds =
        (remainingBytes / (1024 * 1024) * estimatedTimePerMB).toInt();
    if (remainingSeconds > 60) {
      return '${(remainingSeconds / 60).toStringAsFixed(1)}m';
    }
    return '${remainingSeconds}s';
  }

  // Helper to download and save a file (e.g., for large icon)
  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName';
      final http.Response response = await http.get(Uri.parse(url));
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } catch (e, stackTrace) {
      print('Error downloading and saving file: $e');
      catchInfo(e, stackTrace);
      rethrow;
    }
  }

  // Delete file with recovery option
  Future<void> deleteFileWithRecovery(String filePath) async {
    try {
      await recoveryService.deleteFileForRecovery(filePath);
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
      rethrow;
    }
  }
}

