import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

enum DownloadType {
  instagram,
  whatsapp,
  youtube,
  story,
  highlight,
  other,
}

class NotificationService extends GetxController {
  static NotificationService get to => Get.find();

  late FlutterLocalNotificationsPlugin notificationsPlugin;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Create notification channels for different types
    const AndroidNotificationChannel instagramChannel =
        AndroidNotificationChannel(
      'instagram_downloads',
      'Instagram Downloads',
      description: 'Notifications for Instagram media downloads',
      importance: Importance.defaultImportance,
      enableVibration: true,
      playSound: true,
    );

    const AndroidNotificationChannel whatsappChannel =
        AndroidNotificationChannel(
      'whatsapp_downloads',
      'WhatsApp Downloads',
      description: 'Notifications for WhatsApp status downloads',
      importance: Importance.defaultImportance,
      enableVibration: true,
      playSound: true,
    );

    const AndroidNotificationChannel youtubeChannel =
        AndroidNotificationChannel(
      'youtube_downloads',
      'YouTube Downloads',
      description: 'Notifications for YouTube video downloads',
      importance: Importance.defaultImportance,
      enableVibration: true,
      playSound: true,
    );

    const AndroidNotificationChannel storyChannel =
        AndroidNotificationChannel(
      'story_downloads',
      'Story Downloads',
      description: 'Notifications for Story downloads',
      importance: Importance.defaultImportance,
      enableVibration: true,
      playSound: true,
    );

    const AndroidNotificationChannel errorChannel =
        AndroidNotificationChannel(
      'download_errors',
      'Download Errors',
      description: 'Notifications for download errors',
      importance: Importance.max,
      // priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    // Create all channels
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(instagramChannel);

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(whatsappChannel);

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(youtubeChannel);

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(storyChannel);

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(errorChannel);
  }

  String _getChannelId(DownloadType type) {
    switch (type) {
      case DownloadType.instagram:
        return 'instagram_downloads';
      case DownloadType.whatsapp:
        return 'whatsapp_downloads';
      case DownloadType.youtube:
        return 'youtube_downloads';
      case DownloadType.story:
        return 'story_downloads';
      case DownloadType.highlight:
        return 'story_downloads';
      case DownloadType.other:
        return 'instagram_downloads';
    }
  }

  String _getChannelName(DownloadType type) {
    switch (type) {
      case DownloadType.instagram:
        return 'Instagram Downloads';
      case DownloadType.whatsapp:
        return 'WhatsApp Downloads';
      case DownloadType.youtube:
        return 'YouTube Downloads';
      case DownloadType.story:
        return 'Story Downloads';
      case DownloadType.highlight:
        return 'Highlight Downloads';
      case DownloadType.other:
        return 'Downloads';
    }
  }

  Future<void> showProgressNotification({
    required int id,
    required String title,
    required int progress,
    required DownloadType type,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _getChannelId(type),
      _getChannelName(type),
      channelDescription: 'Download progress notification',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      onlyAlertOnce: true,
      enableVibration: false,
    );

    final notificationDetails =
        NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      id,
      'Downloading...',
      '$title - $progress%',
      notificationDetails,
    );
  }

  Future<void> showCompletionNotification({
    required int id,
    required String title,
    required String fileName,
    required DownloadType type,
    String? imagePath,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _getChannelId(type),
      _getChannelName(type),
      channelDescription: 'Download completed',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      largeIcon: imagePath != null ? FilePathAndroidBitmap(imagePath) : null,
    );

    final notificationDetails =
        NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      id,
      'Download Complete',
      fileName,
      notificationDetails,
    );
  }

  Future<void> showErrorNotification({
    required int id,
    required String title,
    required String errorMessage,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'download_errors',
      'Download Errors',
      channelDescription: 'Download error notification',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails =
        NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      id,
      'Download Failed',
      errorMessage,
      notificationDetails,
    );
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  String getTypeLabel(DownloadType type) {
    switch (type) {
      case DownloadType.instagram:
        return 'Instagram';
      case DownloadType.whatsapp:
        return 'WhatsApp';
      case DownloadType.youtube:
        return 'YouTube';
      case DownloadType.story:
        return 'Story';
      case DownloadType.highlight:
        return 'Highlight';
      case DownloadType.other:
        return 'Other';
    }
  }
}


