import 'dart:async';
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
import 'functions/distrib_url.dart';
import 'functions/permissions.dart';
import 'additional.dart';
import 'instagram_login_page.dart';
import 'utils/appdata.dart';
import 'utils/function.dart';

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

  // call kotlin native share intent
  const MethodChannel channel = MethodChannel('app.channel.shared.data');
  channel.setMethodCallHandler((call) async {
    try {
      if (call.method == 'getSharedText') {
        String sharedText = call.arguments;
        if (sharedText != '') {
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
      AndroidInitializationSettings('ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // Initialize notifications
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

  // For Android, request notification permission
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'insta',
      scaffoldMessengerKey: scaffoldMessengerKey, // Assigning the key
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
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  TextEditingController reelController = TextEditingController();
  late FToast fToast;
  bool downloading = false;
  late DistribUrl downloadController;
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

  appUpdate() async {
    var appVersion = await getAppVersion();
    var newVersion = await checkUpdate();
    if (appVersion != newVersion) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: RichText(
            text: TextSpan(children: [
          const TextSpan(
            text: 'New version download',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          TextSpan(
              text: 'Link',
              style: const TextStyle(fontSize: 20, color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchUrl(Uri.parse('https:gopi2401.github.io/download/'));
                })
        ])),
      ));
    }
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
      appBar: AppBar(leading: const DrawerButton()),
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
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text('Download'),
              onPressed: () async {
                if (!isLoading) {
                  try {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    var url = reelController.text.trim();
                    if (url.isNotEmpty) {
                      final Uri uri = Uri.parse(url);
                      if (uri.hasAbsolutePath) {
                        downloadController = Get.put(DistribUrl());
                        contexts = context;
                        await downloadController.handleUrl(url);
                        reelController.clear();
                        setState(() {
                          isLoading = false;
                        });
                      } else {
                        setState(() {
                          isLoading = false;
                          errorMessage = "Please enter valid url";
                        });
                        showToast();
                      }
                    } else {
                      setState(() {
                        isLoading = false;
                        errorMessage = "url not found!. please enter url";
                      });
                      showToast();
                    }
                  } catch (e, stackTrace) {
                    setState(() {
                      isLoading = false;
                    });
                    catchInfo(e, stackTrace);
                  }
                }
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
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
              duration: Duration(seconds: 1),
              curve: Curves.easeInCubic,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      scale: 2.5, image: AssetImage('assets/logo.png'))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Welcome!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 33),
                  )
                ],
              )),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.home,
                  ),
                  title: const Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.error_outline,
                  ),
                  title: const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          const Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text('Made with 💙 by gopi'),
            ),
          ),
        ],
      ),
    );
  }
}
