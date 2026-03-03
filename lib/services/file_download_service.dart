import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../main.dart';
import '../utils/app_utils.dart';
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
    final dio = Dio();
    try {
      // Lower collision risk for concurrent notifications
      final int progressId =
          DateTime.now().millisecondsSinceEpoch % 2147483647;
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

