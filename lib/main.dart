import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'package:insta/core/routing/app_router.dart';
import 'package:insta/core/routing/app_routes.dart';
import 'package:insta/core/services/analytics_service.dart';
import 'package:insta/core/services/feedback_service.dart';
import 'package:insta/core/services/notification_service.dart';
import 'package:insta/core/services/storage_service.dart';
import 'package:insta/core/services/theme_service.dart';
import 'package:insta/features/downloader/distrib_url_controller.dart';
import 'package:insta/features/downloader/download_queue_controller.dart';
import 'package:insta/features/recovery/recovery_controller.dart';
import 'package:insta/core/utils/app_utils.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with payload: ${notificationResponse.payload}',
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Get.isRegistered<NotificationService>()) {
    Get.put(NotificationService(), permanent: true);
  }
  if (!Get.isRegistered<RecoveryService>()) {
    Get.put(RecoveryService(), permanent: true);
  }
  if (!Get.isRegistered<StorageService>()) {
    Get.put(StorageService(), permanent: true);
  }
  if (!Get.isRegistered<DownloadQueueService>()) {
    Get.put(DownloadQueueService(), permanent: true);
  }
  if (!Get.isRegistered<FeedbackService>()) {
    Get.put(FeedbackService(), permanent: true);
  }
  if (!Get.isRegistered<AnalyticsService>()) {
    Get.put(AnalyticsService(), permanent: true);
  }

  const MethodChannel channel = MethodChannel('app.channel.shared.data');
  channel.setMethodCallHandler((call) async {
    try {
      if (call.method == 'getSharedText') {
        final String sharedText = (call.arguments as String).trim();
        if (sharedText.isNotEmpty) {
          await DistribUrl().handleUrl(sharedText);
        }
      }
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
    }
  });

  await dotenv.load(fileName: '.env');

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: selectNotificationStream.add,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();

  Get.put(ThemeService(), permanent: true);

  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.to;

    return AdaptiveTheme(
      light: themeService.lightTheme,
      dark: themeService.darkTheme,
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (lightTheme, darkTheme) => MaterialApp(
        title: 'insta',
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: savedThemeMode == null
            ? ThemeMode.system
            : savedThemeMode == AdaptiveThemeMode.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
