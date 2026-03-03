# Quick Reference: Using the 4 New Features

## 🌓 Theme Toggle (Dark/Light Mode)

### Automatic (Drawer)
- User taps "Dark Mode" / "Light Mode" in drawer
- Theme switches instantly with animation
- Preference is saved automatically

### Programmatic
```dart
// Get the service
final themeService = ThemeService.to;

// Toggle theme (requires a BuildContext when using AdaptiveTheme)
await themeService.toggleTheme(context);

// Check current theme
if (themeService.isDarkMode.value) {
  // App is in dark mode
}

// Listen for theme changes
Obx(() {
  print(themeService.isDarkMode.value);
});
```

---

## 🎬 Download Progress (Circular Animation)

### Show Progress Dialog
```dart
final progressController = DownloadProgressController();

Get.dialog(
  DownloadProgressScreen(
    title: 'Downloading...',
    controller: progressController,
    onCancel: () => Get.back(),
  ),
  barrierDismissible: false,
);
```

### Update Progress During Download
```dart
progressController.setFileName('video.mp4');
progressController.updateProgress(25);    // 0-100
progressController.updateSpeed('2.5 MB/s');
progressController.updateETA('45 seconds');
```

### Close Dialog When Done
```dart
progressController.reset();
Get.back();
```

### Color Indicators
- 0-33%: 🔴 Red
- 33-66%: 🟠 Orange  
- 66-99%: 🟡 Amber
- 100%: 🟢 Green

---

## ♻️ Recovery Bin (Undo/Soft Delete)

### Delete File with Recovery
```dart
final recoveryService = RecoveryService.to;
await recoveryService.deleteFileForRecovery(filePath);
```

### Recover a File
```dart
final recoveryService = RecoveryService.to;
final deletedFile = recoveryService.deletedFiles[0];
await recoveryService.recoverFile(deletedFile);
```

### Permanently Delete
```dart
await recoveryService.permanentlyDelete(deletedFile);
```

### Get List of Deleted Files
```dart
final deletedFiles = recoveryService.deletedFiles;
for (var file in deletedFiles) {
  print('${file.fileName} - ${file.fileType}');
}
```

### Auto-Cleanup
- Runs automatically on app start
- Deletes files older than 30 days
- No manual intervention needed

---

## 🔔 Smart Notifications

### Show Progress Notification
```dart
final notificationService = NotificationService.to;

await notificationService.showProgressNotification(
  id: 1,
  title: 'video.mp4',
  progress: 50,
  type: DownloadType.instagram,
);
```

### Show Completion Notification
```dart
await notificationService.showCompletionNotification(
  id: 1,
  title: 'Download Complete',
  fileName: 'video.mp4',
  type: DownloadType.instagram,
  imagePath: '/path/to/thumbnail.jpg',
);
```

### Show Error Notification
```dart
await notificationService.showErrorNotification(
  id: 1,
  title: 'Download Failed',
  errorMessage: 'Connection timeout',
);
```

### Cancel Notification
```dart
await notificationService.cancelNotification(1);
```

### Download Types
- `DownloadType.instagram` → Instagram posts/reels
- `DownloadType.whatsapp` → WhatsApp status
- `DownloadType.youtube` → YouTube videos
- `DownloadType.story` → Stories/highlights
- `DownloadType.highlight` → Highlights
- `DownloadType.other` → Generic downloads

---

## 📝 Integration Example: Instagram Download

### Complete Flow
```dart
Future<void> downloadInstagramVideo(String url) async {
  final fileDownload = FileDownload();
  final progressController = DownloadProgressController();
  final notificationService = NotificationService.to;

  // Show progress dialog
  Get.dialog(
    DownloadProgressScreen(
      title: 'Downloading Instagram Video',
      controller: progressController,
      onCancel: () {
        Get.back();
        // Handle cancel
      },
    ),
    barrierDismissible: false,
  );

  try {
    // Set initial state
    progressController.setFileName('instagram_video.mp4');
    progressController.setDownloading(true);

    // Download
    await fileDownload.downloadFile(
      url,
      'instagram_video.mp4',
      null,
      downloadType: DownloadType.instagram,
    );

    // Success
    Get.back();
    Get.snackbar(
      'Success',
      'Instagram video downloaded!',
      backgroundColor: Colors.green,
    );

  } catch (e) {
    // Error
    Get.back();
    Get.snackbar(
      'Error',
      'Failed to download: $e',
      backgroundColor: Colors.red,
    );
  }
}
```

---

## 📱 Service Access Patterns

### Global Service Access
```dart
// Theme Service
final theme = ThemeService.to;

// Notification Service
final notifications = NotificationService.to;

// Recovery Service
final recovery = RecoveryService.to;

// File Download Service
final download = FileDownload();
```

### With Obx for Reactive Updates
```dart
Obx(() {
  return Text(
    ThemeService.to.isDarkMode.value ? 'Dark' : 'Light'
  );
});

Obx(() {
  return Text(
    'Deleted files: ${RecoveryService.to.deletedFiles.length}'
  );
});
```

---

## 🎯 Common Use Cases

### Use Case 1: Instagram Download with Progress
```dart
// Button click
final url = 'https://instagram.com/...';
final fileName = 'instagram_post.mp4';
final progressController = DownloadProgressController();

// Show dialog
Get.dialog(
  DownloadProgressScreen(
    title: 'Instagram',
    controller: progressController,
  ),
);

// Download
await FileDownload().downloadFile(
  url,
  fileName,
  null,
  downloadType: DownloadType.instagram,
);
```

### Use Case 2: File Cleanup with Recovery
```dart
// Delete file
final filePath = '/storage/emulated/0/Download/Insta/video.mp4';
await RecoveryService.to.deleteFileForRecovery(filePath);

// Show undo button
Get.snackbar(
  'Deleted',
  'File moved to recovery bin',
  duration: Duration(seconds: 3),
  mainButton: TextButton(
    onPressed: () {
      // Open Recovery Bin screen
      Get.to(() => const RecoveryScreen());
    },
    child: const Text('View Bin'),
  ),
);
```

### Use Case 3: Batch Notifications
```dart
final notifs = NotificationService.to;

// Download multiple files
for (int i = 0; i < files.length; i++) {
  await notifs.showProgressNotification(
    id: i + 1,
    title: files[i].name,
    progress: 0,
    type: DownloadType.instagram,
  );

  // ... download logic ...

  await notifs.showCompletionNotification(
    id: i + 1,
    title: 'Complete',
    fileName: files[i].name,
    type: DownloadType.instagram,
  );
}
```

---

## ⚙️ Configuration Tips

### Theme Customization
Edit `ThemeService.getLightTheme()` and `getDarkTheme()`:
```dart
// Change primary color
primaryColor: Colors.purple,

// Customize button styling
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.purple,
  ),
),
```

### Recovery Settings
Edit `RecoveryService`:
```dart
// Change recovery directory
recoveryDir = Directory('${appDir.path}/custom_bin');

// Change expiry days
bool get isExpired => DateTime.now()
  .difference(deletedAt).inDays > 30;  // Change 30
```

### Notification Channels
Edit `NotificationService._getChannelId()`:
```dart
// Add new channel
case DownloadType.custom:
  return 'custom_downloads';
```

---

## 🐛 Troubleshooting

### Theme not persisting?
- Ensure `adaptive_theme` is initialized in `main()`
- Check app is using `AdaptiveTheme` wrapper

### Progress not showing?
- Verify `DownloadProgressController` is created
- Check dialog is shown with `barrierDismissible: false`
- Ensure `updateProgress()` is called regularly

### Files not in recovery?
- Check `recoveryDir` exists
- Verify `deleteFileForRecovery()` is called (not `File.delete()`)
- Check app has write permissions

### No notifications?
- Verify `NotificationService` is initialized
- Check app has notification permissions
- For Android 8.0+, verify channel creation

---

## 📚 Additional Resources

- **Full Docs**: `IMPLEMENTATION_GUIDE.md`
- **Code Examples**: `lib/examples/feature_usage_guide.dart`
- **Service Code**: `lib/services/`
- **UI Code**: `lib/screens/` and `lib/widgets/`

---

**Last Updated**: March 2, 2026  
**Version**: 1.0  
**Status**: Ready for Production
