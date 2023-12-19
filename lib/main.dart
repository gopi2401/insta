import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:insta/Functions/distribUrl.dart';
import 'package:insta/instagram_login_page.dart';
import 'package:insta/profilepage.dart';
// import 'Functions/create_folder.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

DistribUrl downloadController = Get.put(DistribUrl());
int id = 0;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

const String portName = 'notification_send_port';

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

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

void main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    // iOS: initializationSettingsDarwin,
    // macOS: initializationSettingsDarwin,
    // linux: initializationSettingsLinux,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          selectNotificationStream.add(notificationResponse.payload);
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (notificationResponse.actionId == navigationActionId) {
            selectNotificationStream.add(notificationResponse.payload);
          }
          break;
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );
  // _isAndroidPermissionGranted();
  runApp(const MyApp());
  // var isGranted = await Permission.manageExternalStorage.isGranted;
  // if (isGranted) {
  //   AppUtil.createFolder();
  // }

  const MethodChannel _channel = const MethodChannel('app.channel.shared.data');

  _channel.setMethodCallHandler((call) async {
    if (call.method == 'getSharedText') {
      String sharedText = call.arguments;
      // Handle the shared text as needed
      // print('hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii$sharedText');
      downloadController.url(sharedText);
    }
  });
}

var permission = false;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'insta',
      navigatorKey: navigatorKey,
      routes: {
        "login": (BuildContext context) => const InstaLogin(),
        "nextpage": (BuildContext context) => const PorfilePage(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController reelController = TextEditingController();
  late FToast fToast;
  bool isLogin = false;
  bool downloading = false;

  // ignore: unused_field
  bool _notificationsEnabled = false;
  @override
  void initState() {
    super.initState();
    _requestPermissions();
    fToast = FToast();
    fToast.init(context);
  }

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(FontAwesomeIcons.link, size: 15),
        SizedBox(
          width: 12.0,
        ),
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

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestPermission();
      setState(() {
        _notificationsEnabled = grantedNotificationPermission ?? false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            downloading ? const CupertinoActivityIndicator() : Container(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: reelController,
                decoration: const InputDecoration(
                  hintText: "Url",
                ),
              ),
            ),
            ElevatedButton(
              child: const Text('Download'),
              onPressed: () async {
                setState(() {
                  downloading = true;
                });
                var url = reelController.text.trim();
                if (url.isNotEmpty) {
                  final Uri uri = Uri.parse(url);
                  if (uri.hasAbsolutePath) {
                    downloadController.url(url);
                  } else {
                    print('else');
                  }
                } else {
                  showToast();
                }
                setState(() {
                  downloading = false;
                });
              },
            ),
            TextButton(
                onPressed: () async =>
                    {navigatorKey.currentState?.pushNamed('login')},
                child: const Text('Login')),
            // TextButton(
            //     onPressed: () async =>
            //         {navigatorKey.currentState?.pushNamed('nextpage')},
            //     child: const Text('Next Page')),
          ],
        ),
      ),
    );
  }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }

  Future<void> showNotificationMediaStyle() async {
    final String largeIconPath = await _downloadAndSaveFile(
        'https://dummyimage.com/128x128/00FF00/000000', 'largeIcon');
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
        id++, 'notification title', 'notification body', notificationDetails);
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
