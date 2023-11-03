// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:insta/main.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:webview_cookie_manager/webview_cookie_manager.dart' as wb;
// import 'package:http/http.dart' as http;

// import '../models/items.dart';
// import '../models/graphql.dart';

// class DownloadController extends GetxController {
//   var processing = false.obs;
//   bool isLogin = false;
//   String? path;
//   var box = GetStorage();
//   Dio dio = Dio();
//   Future<String?> _startDownload(String link) async {
//     // Asking for video storage permission
//     await Permission.storage.request();
//     isLogin = false;
//     // Checking for Cookies
//     final cookieManager = wb.WebviewCookieManager();
//     final gotCookies =
//         await cookieManager.getCookies('https://www.instagram.com/');
//     // is Cookie found then set isLogin to true
//     if (gotCookies.length > 0) isLogin = true;

//     // Build the url
//     var linkParts = link.replaceAll(" ", "").split("/");
//     var url =
//         '${linkParts[0]}//${linkParts[2]}/${linkParts[3]}/${linkParts[4]}' +
//             "?__a=1&__d=dis";

//     // Make Http requiest to get the download link of video
//     var httpClient = new HttpClient();
//     String? videoURLLLLL;
//     String? ImgURLLLLL;
//     String? fileName;
//     var Urls = [];
//     try {
//       var request = await httpClient.getUrl(Uri.parse(url));
//       for (var element in gotCookies) {
//         request.cookies.add(Cookie(element.name, element.value));
//       }
//       var response = await request.close();
//       if (response.statusCode == HttpStatus.OK) {
//         // print(response);
//         var json = await response.transform(utf8.decoder).join();
//         var data = jsonDecode(json);
//         // print(data);
//         // if (isLogin) {
//         if (data['items'] != null) {
//           Items post = Items.fromJson(data);
//           var files = post.files;
//           if (files != null) {
//             for (var file in files) {
//               downloadFile(file.fileDisplayUrl, file.fileUrl, file.fileName);
//             }
//           }
//         } else if (data['graphql'] != null) {
//           Graphql post = Graphql.fromJson(data);
//           var files = post.files;
//           if (files != null) {
//             for (var file in files) {
//               downloadFile(file.fileDisplayUrl, file.fileUrl, file.fileName);
//             }
//           }
//         }
//         // }
//       } else {
//         navigatorKey.currentState?.pushNamed('login');
//       }
//     } catch (exception) {
//       log(exception.toString());
//     }
//   }

//   Future<String> downloadFile(ImgURLLLLL, url, fileName) async {
//     HttpClient httpClient = new HttpClient();
//     var Dir = await new Directory('/storage/emulated/0/Download/Insta')
//         .create(recursive: true);
//     File file;
//     String filePath = '';
//     String type = 'mp4';
//     try {
//       var request = await httpClient.getUrl(Uri.parse(url));
//       var response = await request.close();
//       if (response.statusCode == 200) {
//         var arr = response.headers['content-type']!.toList();
//         for (var element in arr) {
//           if (element == 'video/mp4') {
//             type = 'mp4';
//           } else if (element == 'image/jpeg') {
//             type = 'jpg';
//           }
//         }
//         var bytes = await consolidateHttpClientResponseBytes(response);
//         filePath = '${Dir.path}/$fileName.$type';
//         file = File(filePath);
//         await file.writeAsBytes(bytes);
//         _showNotificationMediaStyle('Download/Insta/$fileName', ImgURLLLLL);
//       } else
//         filePath = 'Error code: ' + response.statusCode.toString();
//     } catch (ex) {
//       filePath = 'Can not fetch url';
//     }

//     return filePath;
//   }

//   downloadReal(String link) async {
//     processing.value = true;
//     try {
//       await _startDownload(link).then((value) {});
//     } catch (e) {
//       Fluttertoast.showToast(
//           msg: "failed",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.CENTER,
//           timeInSecForIosWeb: 1,
//           textColor: Colors.white,
//           fontSize: 16.0);
//     }
//     processing.value = false;
//   }

//   Future<void> _showNotificationMediaStyle(
//       notification_body, ImgURLLLLL) async {
//     final String largeIconPath =
//         await _downloadAndSaveFile(ImgURLLLLL, 'largeIcon');
//     final AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//       'media channel id',
//       'media channel name',
//       channelDescription: 'media channel description',
//       largeIcon: FilePathAndroidBitmap(largeIconPath),
//       styleInformation: const MediaStyleInformation(),
//     );
//     final NotificationDetails notificationDetails =
//         NotificationDetails(android: androidNotificationDetails);
//     await flutterLocalNotificationsPlugin.show(
//         id++, 'Download Complete', notification_body, notificationDetails);
//   }

//   Future<String> _downloadAndSaveFile(String url, String fileName) async {
//     final Directory directory = await getApplicationDocumentsDirectory();
//     final String filePath = '${directory.path}/$fileName';
//     final http.Response response = await http.get(Uri.parse(url));
//     final File file = File(filePath);
//     await file.writeAsBytes(response.bodyBytes);
//     return filePath;
//   }
// }
