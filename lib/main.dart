import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'about.dart';
import 'services/distrib_url.dart';
import 'services/permissions.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'services/recovery_service.dart';
import 'additional.dart';
import 'instagram_login_page.dart';
import 'screens/recovery_screen.dart';
import 'utils/appdata.dart';
import 'utils/app_utils.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // make sure the notification and recovery services are available immediately
  // (share-intent handler may create download controllers that depend on them)
  if (!Get.isRegistered<NotificationService>()) {
    Get.put(NotificationService(), permanent: true);
  }
  if (!Get.isRegistered<RecoveryService>()) {
    Get.put(RecoveryService(), permanent: true);
  }

  // call kotlin native share intent
  const MethodChannel channel = MethodChannel('app.channel.shared.data');
  channel.setMethodCallHandler((call) async {
    try {
      if (call.method == 'getSharedText') {
        final String sharedText = (call.arguments as String).trim();
        debugPrint('shared text = $sharedText');
        Get.snackbar('shared', sharedText);
        if (sharedText.isNotEmpty) {
          await DistribUrl().handleUrl(sharedText);
        }
      }
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
    }
  });

  // dotenv file load
  await dotenv.load(fileName: ".env");

  // Android notification settings
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // Initialize notifications
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: selectNotificationStream.add,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  // For Android, request notification permission
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();

  // Initialize GetX services
  Get.put(ThemeService(), permanent: true);
  // NotificationService may already be registered above; avoid double-putting
  if (!Get.isRegistered<NotificationService>()) {
    Get.put(NotificationService(), permanent: true);
  }
  // GuardRecoveryService similarly
  if (!Get.isRegistered<RecoveryService>()) {
    Get.put(RecoveryService(), permanent: true);
  }

  // Get saved theme mode
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
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  TextEditingController reelController = TextEditingController();
  late FToast fToast;
  bool downloading = false;
  int id = 0;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    Permissions.requestStoragePermission(context);
    fToast = FToast();
    fToast.init(context);
    appUpdate();
  }

  /// Centralises download-button logic so the build method stays clean.
  Future<void> _onDownloadPressed() async {
    setState(() {
      downloading = true;
      errorMessage = null;
    });

    try {
      final url = reelController.text.trim();
      if (url.isEmpty) {
        setState(() {
          errorMessage = 'URL cannot be empty';
        });
        showToast();
      } else {
        final uri = Uri.tryParse(url);
        final isHttpUrl =
            uri != null &&
            (uri.scheme == 'http' || uri.scheme == 'https') &&
            uri.hasAuthority;
        if (!isHttpUrl) {
          setState(() {
            errorMessage = 'Please enter a valid URL';
          });
          showToast();
        } else {
          final downloadController = Get.isRegistered<DistribUrl>()
              ? Get.find<DistribUrl>()
              : Get.put(DistribUrl());
          contexts = context;
          await downloadController.handleUrl(url);
          reelController.clear();
        }
      }
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
    } finally {
      setState(() {
        downloading = false;
      });
    }
  }

  appUpdate() async {
    var appVersion = await getAppVersion();
    var newVersion = await checkUpdate();
    if (appVersion != newVersion) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'New version download',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                TextSpan(
                  text: 'Link',
                  style: const TextStyle(fontSize: 20, color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(
                        Uri.parse('https://gopi2401.github.io/download/'),
                      );
                    },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(25.0)),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(FontAwesomeIcons.link, size: 15),
        SizedBox(width: 12.0),
        Text("url not found..!"),
      ],
    ),
  );

  void showToast() {
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    reelController.dispose();
    if (Get.isRegistered<DistribUrl>()) {
      Get.delete<DistribUrl>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const DrawerButton(),
        title: const Text('Instagram Downloader'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 8),
            Text(
              'Paste an Instagram URL below and tap download',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reelController,
              decoration: InputDecoration(
                labelText: 'Instagram URL',
                border: const OutlineInputBorder(),
                hintText: 'https://www.instagram.com/p/xyz',
                errorText: errorMessage,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => reelController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: downloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(downloading ? 'Downloading...' : 'Download'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: downloading ? null : _onDownloadPressed,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Login to Instagram'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InstaLogin()),
                );
              },
            ),
            const Spacer(),
            const Additional(),
          ],
        ),
      ),
      drawer: const DrawerWidget(),
    );
  }
}

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.to;
    final recoveryService = RecoveryService.to;

    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            duration: Duration(seconds: 1),
            curve: Curves.easeInCubic,
            decoration: BoxDecoration(
              image: DecorationImage(
                scale: 2.5,
                image: AssetImage('assets/logo.png'),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Welcome!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 33),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home', style: TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: const Text('About', style: TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ),
                    );
                  },
                ),
                const Divider(),
                // Recovery Bin
                ListTile(
                  leading: const Icon(Icons.restore_from_trash),
                  title: const Text(
                    'Recovery Bin',
                    style: TextStyle(fontSize: 18),
                  ),
                  trailing: Obx(
                    () => recoveryService.deletedFiles.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              recoveryService.deletedFiles.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecoveryScreenWrapper(),
                      ),
                    );
                  },
                ),
                const Divider(),
                // Theme Toggle
                ListTile(
                  leading: Obx(
                    () => Icon(
                      themeService.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                  ),
                  title: Obx(
                    () => Text(
                      themeService.isDarkMode ? 'Light Mode' : 'Dark Mode',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  onTap: () {
                    // keep service state in sync and let AdaptiveTheme
                    // actually switch the UI
                    themeService.toggleTheme(context);
                  },
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text('Made with love by gopi'),
          ),
        ],
      ),
    );
  }
}

class RecoveryScreenWrapper extends StatelessWidget {
  const RecoveryScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const RecoveryScreen();
  }
}

