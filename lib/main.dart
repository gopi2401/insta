import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:insta/functions/distrib_url.dart';
import 'package:insta/about.dart';
import 'package:insta/instagram_login_page.dart';
import 'functions/permissions.dart';
import 'additional.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

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
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with payload: ${notificationResponse.payload}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      if (notificationResponse.notificationResponseType ==
          NotificationResponseType.selectedNotification) {
        selectNotificationStream.add(notificationResponse.payload);
      } else if (notificationResponse.actionId == 'navigation') {
        selectNotificationStream.add(notificationResponse.payload);
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'insta',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
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
  bool downloading = false;
  late DistribUrl downloadController;
  int id = 0;

  @override
  void initState() {
    super.initState();
    Permissions.requestStoragePermission(context);
    fToast = FToast();
    fToast.init(context);
    downloadController = Get.put(DistribUrl());
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
    downloadController.dispose();
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
                    downloadController.handleUrl(url);
                  } else {
                    showToast();
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InstaLogin()),
                );
              },
              child: const Text('Login'),
            ),
            const Additional()
          ],
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.black45,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.grey,
                ),
                child: Text(
                  'Drawer Header',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                title: const Text(
                  'Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  // Add your navigation logic here
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                ),
                title: const Text(
                  'About',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
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
