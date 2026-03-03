import 'package:get/get.dart';

import '../utils/app_utils.dart';
import 'download_queue_service.dart';
import 'notification_service.dart';
import 'recovery_service.dart';

class FileDownload extends GetxController {
  // Compatibility wrapper: existing call sites keep using downloadFile while
  // queue/persistence/retry is handled by DownloadQueueService.
  DownloadQueueService get queueService {
    if (!Get.isRegistered<DownloadQueueService>()) {
      Get.put(DownloadQueueService(), permanent: true);
    }
    return DownloadQueueService.to;
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
    try {
      return queueService.enqueueAndWait(
        url: url,
        fileName: fileName,
        type: downloadType,
        thumbnailUrl: notificationImg,
      );
    } catch (e, stackTrace) {
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

