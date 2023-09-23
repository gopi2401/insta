import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:insta/Controller/DownloadController.dart';
import 'package:insta/Controller/instagram_login.dart';
import 'package:insta/create_folder.dart';
import 'package:insta/model/insta_post_with_login.dart';
import 'package:insta/model/insta_post_without_login.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart' as wb;

void main() async {
  runApp(const MyApp());
  var isGranted = await Permission.manageExternalStorage.isGranted;
  if (isGranted) {
    AppUtil.createFolder();
  }
}

var permission = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
  DownloadController downloadController = Get.put(DownloadController());
  TextEditingController reelController = TextEditingController();
  late FToast fToast;
  bool isLogin = false;
  Dio dio = Dio();
  bool downloading = false;
  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
    ),
    child: Row(
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
      toastDuration: Duration(seconds: 2),
    );
  }
  // Future<String> downloadFile() async {
  //   var url = await downloadReels(reelController.text);
  //   HttpClient httpClient = new HttpClient();
  //   File file;
  //   String filePath = '';
  //   String myUrl = '';
  //   String fileName = 'video.mp4';
  //   var dir = Platform.isAndroid
  //       ? '/storage/emulated/0/Download'
  //       : (await getApplicationDocumentsDirectory()).path;
  //   try {
  //     myUrl = url + '/' + fileName;
  //     var request = await httpClient.getUrl(Uri.parse(myUrl));
  //     var response = await request.close();
  //     if (response.statusCode == 200) {
  //       var bytes = await consolidateHttpClientResponseBytes(response);
  //       filePath = '$dir/$fileName';
  //       file = File(filePath);
  //       await file.writeAsBytes(bytes);
  //     } else
  //       filePath = 'Error code: ' + response.statusCode.toString();
  //   } catch (ex) {
  //     filePath = 'Can not fetch url';
  //   }

  //   return filePath;
  // }
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
            downloading ? CupertinoActivityIndicator() : Container(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: reelController,
                decoration: InputDecoration(
                  hintText: "Url",
                ),
              ),
            ),
            ElevatedButton(
              child: Text('Download'),
              onPressed: () async {
                setState(() {
                  downloading = true;
                });
                if (!reelController.text.trim().isEmpty) {
                  downloadController.downloadReal(reelController.text, context);
                } else {
                  showToast();
                }
                setState(() {
                  downloading = false;
                });
              },
            ),
            TextButton(
                onPressed: () async => {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => InstaLogin()))
                    },
                child: Text('Login')),
          ],
        ),
      ),
    );
  }

  Future<String?> downloadReels(String link) async {
    // Asking for video storage permission
    await Permission.storage.request();
    isLogin = false;
    // Checking for Cookies
    final cookieManager = wb.WebviewCookieManager();
    final gotCookies =
        await cookieManager.getCookies('https://www.instagram.com/');
    // is Cookie found then set isLogin to true
    if (gotCookies.length > 0) isLogin = true;
    try {
      // Build the url
      var linkEdit = link.replaceAll(" ", "").split("/");
      var url = '${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' +
          "?__a=1&__d=dis";
      HttpClient httpClient = new HttpClient();
      var request = await httpClient.getUrl(Uri.parse(url));
      gotCookies.forEach((element) {
        request.cookies.add(Cookie(element.name, element.value));
      });
      var response = await request.close();
      if (response.statusCode == 200) {
        var responseBody = await response.transform(utf8.decoder).join();
        var data = json.decode(responseBody);
        String? videoUrl;
        if (isLogin) {
          InstaPostWithLogin postWithLogin = InstaPostWithLogin.fromJson(data);
          videoUrl = postWithLogin.items?.first.videoVersions?.first.url;
        } else {
          InstaPostWithoutLogin post = InstaPostWithoutLogin.fromJson(data);
          videoUrl = post.graphql?.shortcodeMedia?.videoUrl;
        }
        await savefile(videoUrl);
        return videoUrl; // return the actual download link
      } else {
        fToast.showToast(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FontAwesomeIcons.ban, size: 15),
                SizedBox(
                  width: 12.0,
                ),
                Text("url loading failed"),
              ],
            ),
          ),
          gravity: ToastGravity.TOP,
          toastDuration: Duration(seconds: 2),
        );
      }
    } catch (exception) {
      {
        fToast.showToast(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FontAwesomeIcons.unlink, size: 15),
                SizedBox(
                  width: 12.0,
                ),
                Text("url invalid..!"),
              ],
            ),
          ),
          gravity: ToastGravity.TOP,
          toastDuration: Duration(seconds: 2),
        );
      }
    }
  }

  Future<String> savefile(String? videoUrl) async {
    // Download video & save
    if (videoUrl == null) {
      return 'null';
    } else {
      String savePath = '/storage/emulated/0/download' + "/temp.mp4";
      var result = await dio.download(videoUrl, savePath);
      // final result =
      //     await ImageGallerySaver.saveFile(savePath, isReturnPathOfIOS: true);
      if (result.statusCode == 200) {
        fToast.showToast(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FontAwesomeIcons.download, size: 15),
                SizedBox(
                  width: 12.0,
                ),
                Text("file download"),
              ],
            ),
          ),
          gravity: ToastGravity.TOP,
          toastDuration: Duration(seconds: 2),
        );
      }
      return 'result';
    }
  }
}
