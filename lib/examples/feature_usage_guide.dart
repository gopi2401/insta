/// Example Usage Guide for New Features
///
/// This file demonstrates how to use the newly implemented features:
/// 1. Dark/Light Theme Toggle
/// 2. Download Progress Animations
/// 3. Undo/Recovery System
/// 4. Smart Notifications
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/download_progress_screen.dart';
import '../services/recovery_service.dart';
import '../services/notification_service.dart';
import '../services/file_download_service.dart';

/// FEATURE 1: Dark/Light Theme Toggle
///
/// The theme toggle is already integrated in the drawer.
/// To manually toggle theme from anywhere:
///
/// ```dart
/// final themeService = ThemeService.to;
/// await themeService.toggleTheme();
/// ```
///
/// To check current theme:
/// ```dart
/// final isDark = ThemeService.to.isDarkMode.value;
/// ```

/// FEATURE 2: Download Progress Animations
///
/// Usage in download process:
///
/// ```dart
/// // 1. Create a progress controller
/// final progressController = DownloadProgressController();
///
/// // 2. Show the progress dialog
/// Get.dialog(
///   DownloadProgressScreen(
///     title: 'Downloading Instagram Media',
///     controller: progressController,
///     onCancel: () {
///       // Handle cancel
///       Get.back();
///     },
///   ),
/// );
///
/// // 3. Update progress during download
/// progressController.setFileName('video.mp4');
/// progressController.updateProgress(25);
/// progressController.updateSpeed('1.2 MB/s');
/// progressController.updateETA('45s');
///
/// // 4. Reset when done
/// progressController.reset();
/// Get.back();
/// ```

class ExampleDownloadUsage {
  static Future<void> downloadWithProgress() async {
    final fileDownload = FileDownload();
    final progressController = DownloadProgressController();

    // Show progress dialog
    Get.dialog(
      DownloadProgressScreen(
        title: 'Downloading Instagram Media',
        controller: progressController,
        onCancel: () {
          Get.back();
          // Cancel download here if needed
        },
      ),
      barrierDismissible: false,
    );

    try {
      progressController.setFileName('instagram_video.mp4');
      progressController.setDownloading(true);

      // Download with progress tracking
      await fileDownload.downloadFile(
        'https://example.com/video.mp4',
        'instagram_video.mp4',
        null,
        downloadType: DownloadType.instagram,
      );

      progressController.reset();
      Get.back();
    } catch (e) {
      debugPrint('Download failed: $e');
      Get.back();
    }
  }
}

/// FEATURE 3: Undo/Recovery System
///
/// Delete files with recovery option:
///
/// ```dart
/// final recoveryService = RecoveryService.to;
///
/// // Delete a file (it will be moved to recovery bin)
/// await recoveryService.deleteFileForRecovery(
///   '/storage/emulated/0/Download/Insta/video.mp4'
/// );
///
/// // Recover a file
/// final deletedFile = recoveryService.deletedFiles[0];
/// await recoveryService.recoverFile(deletedFile);
///
/// // Permanently delete a file (after 30 days it's auto-deleted)
/// await recoveryService.permanentlyDelete(deletedFile);
///
/// // Check deleted files
/// final deletedFiles = recoveryService.deletedFiles;
/// for (var file in deletedFiles) {
///   print('${file.fileName} - ${recoveryService.getFormattedDaysLeft(file)}');
/// }
/// ```
///
/// Access recovery bin from drawer (already implemented)

class ExampleRecoveryUsage {
  static Future<void> deleteWithRecovery(String filePath) async {
    final recoveryService = RecoveryService.to;

    try {
      // Soft delete - file is moved to recovery bin
      await recoveryService.deleteFileForRecovery(filePath);

      Get.snackbar(
        'Deleted',
        'File moved to recovery bin',
        duration: const Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: () {
            // Navigate to recovery bin
            // Get.to(() => const RecoveryScreen());
          },
          child: const Text('View Bin'),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete file: $e');
    }
  }
}

/// FEATURE 4: Smart Notifications
///
/// The notification service automatically creates different channels
/// for different download types.
///
/// Usage:
/// ```dart
/// final notificationService = NotificationService.to;
///
/// // Show progress notification
/// await notificationService.showProgressNotification(
///   id: 1,
///   title: 'instagram_video.mp4',
///   progress: 50,
///   type: DownloadType.instagram,
/// );
///
/// // Show completion notification
/// await notificationService.showCompletionNotification(
///   id: 1,
///   title: 'Download Complete',
///   fileName: 'instagram_video.mp4',
///   type: DownloadType.instagram,
///   imagePath: '/path/to/thumbnail.jpg',
/// );
///
/// // Show error notification
/// await notificationService.showErrorNotification(
///   id: 1,
///   title: 'Download Failed',
///   errorMessage: 'Connection timeout',
/// );
///
/// // Cancel notification
/// await notificationService.cancelNotification(1);
/// ```
///
/// Notification Channels:
/// - instagram_downloads: Instagram posts and reels
/// - whatsapp_downloads: WhatsApp status
/// - youtube_downloads: YouTube videos and shorts
/// - story_downloads: Stories and highlights
/// - download_errors: Any download errors

class ExampleNotificationUsage {
  static Future<void> demonstrateNotifications() async {
    final notificationService = NotificationService.to;

    // Example 1: Instagram download
    await notificationService.showProgressNotification(
      id: 1,
      title: 'Instagram Reel',
      progress: 0,
      type: DownloadType.instagram,
    );

    // Simulate progress
    for (int i = 0; i <= 100; i += 25) {
      await Future.delayed(const Duration(seconds: 1));
      await notificationService.showProgressNotification(
        id: 1,
        title: 'Instagram Reel',
        progress: i,
        type: DownloadType.instagram,
      );
    }

    // Show completion
    await notificationService.showCompletionNotification(
      id: 1,
      title: 'Download Complete',
      fileName: 'reel_12345.mp4',
      type: DownloadType.instagram,
    );
  }
}

/// INTEGRATION EXAMPLE IN DOWNLOAD BUTTON
///
/// Here's how to integrate all features in your download button:

class IntegrationExample extends StatelessWidget {
  const IntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _downloadWithAllFeatures(),
      child: const Text('Download'),
    );
  }

  Future<void> _downloadWithAllFeatures() async {
    final fileDownload = FileDownload();
    final progressController = DownloadProgressController();

    // Show progress dialog
    Get.dialog(
      DownloadProgressScreen(
        title: 'Downloading Instagram Media',
        controller: progressController,
        onCancel: () {
          Get.back();
        },
      ),
      barrierDismissible: false,
    );

    try {
      progressController.setFileName('video.mp4');
      progressController.setDownloading(true);

      // Download
      await fileDownload.downloadFile(
        'https://example.com/video.mp4',
        'video.mp4',
        null,
        downloadType: DownloadType.instagram,
      );

      Get.back();
      Get.snackbar(
        'Success',
        'Download completed!',
        mainButton: TextButton(
          onPressed: () {
            // View downloaded file
          },
          child: const Text('View'),
        ),
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Download failed: $e',
        mainButton: TextButton(
          onPressed: () {
            // Retry download
          },
          child: const Text('Retry'),
        ),
      );
    }
  }
}
