import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import '../instagram_login_page.dart';
import '../models/graphql.dart';
import '../models/items.dart';
import '../models/story_model.dart';
import '../story_saver/story_screen.dart';
import '../utils/appdata.dart';
import '../utils/function.dart';
import 'file_download.dart';

class InstaDownloadController extends GetxController {
  // Initialize the WebViewController
  // final WebViewController webViewController = WebViewController();
  final FileDownload downloadController = Get.put(FileDownload());

  // Downloads media from the provided link
  Future<void> downloadReal(String link) async {
    try {
      final insta = link.trim().split("/").sublist(0, 3).join("/");
      final url =
          "${link.trim().split("/").sublist(0, 5).join("/")}/?__a=1&__d=dis";

      final headers = {
        'accept': 'text/html,application/xhtml+xml,application/xml',
        'user-agent':
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36',
      };

      // First request (GET)
      HttpClient client = HttpClient();
      HttpClientRequest request = await client.getUrl(Uri.parse(insta));

      // Set initial headers
      headers.forEach((name, value) {
        request.headers.set(name, value);
      });

      HttpClientResponse response = await request.close();

      // Extract cookies from the response headers
      List<String> rawCookies = response.headers['set-cookie'] ?? [];
      String cookieHeader = rawCookies.map((cookie) {
        return cookie.split(';')[0]; // Take only the cookie name=value pair
      }).join('; ');

      // Add cookies to the headers for the next request
      headers['cookie'] = cookieHeader;

      // Make the GET request
      request = await client.getUrl(Uri.parse(url));

      // Set headers for GET request
      headers.forEach((name, value) {
        request.headers.set(name, value);
      });

      // Send request and get response
      response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw response.statusCode;
      }
      String responseBody = await response.transform(utf8.decoder).join();
      var data = jsonDecode(responseBody);

      if (data == null ||
          (data['require_login'] != null && data['require_login'])) {
        try {
          HttpClientRequest request =
              await client.getUrl(Uri.parse(decrypt(insta)));
          request.headers.add('url', encryption(link));

          HttpClientResponse response = await request.close();

          // Handle HTTP response
          if (response.statusCode == HttpStatus.ok) {
            var json = await response.transform(utf8.decoder).join();
            var responseData = jsonDecode(json);
            await downloadMedia(responseData);
          } else {
            Navigator.push(
              contexts,
              MaterialPageRoute(builder: (context) => const InstaLogin()),
            );
            contexts = null;
          }
        } catch (e, stackTrace) {
          isLoading = false;
          catchInfo(e, stackTrace);
        }
      } else {
        await postReel(data);
      }

      // // Set JavaScript mode, background color, and navigation delegate
      // webViewController
      //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
      //   ..setBackgroundColor(const Color(0x00000000))
      //   ..setNavigationDelegate(NavigationDelegate(
      //     onPageFinished: (String url) async {
      //       // Run JavaScript to retrieve JSON content from the page
      //       final cook = await webViewController.runJavaScriptReturningResult(
      //           'JSON.parse(document.documentElement.innerText)');

      //       // Ensure that the result is a String
      //       if (cook is String) {
      //         var data = jsonDecode(cook);
      //         debugPrint('Page finished loading: $cook');
      //         // Check if login is required
      //       } else {
      //         throw Exception("JavaScript did not return a valid JSON string.");
      //       }
      //     },
      //   ));

      // Load the constructed URL
      // await webViewController.loadRequest(Uri.parse(url));

      // Close the client
      client.close();
    } catch (e, stackTrace) {
      // Handle any errors in the initial function execution
      catchInfo(e, stackTrace);
    }
  }

  // Fetches and downloads Instagram stories
  Future<void> stories(String uName, String? sId) async {
    try {
      final userResponse =
          await http.get(Uri.parse('${igs}userInfoByUsername/$uName'));
      var userId = jsonDecode(userResponse.body)['result']['user']['id'];
      final storiesResponse =
          await http.get(Uri.parse('${igs}stories/$userId'));
      var storiesData = Story.fromJson(jsonDecode(storiesResponse.body));
      if (storiesData.stories.isNotEmpty) {
        for (var story in storiesData.stories) {
          if (story.pk == sId) {
            var image = story.img;
            var video = story.storie;
            downloadController.downloadFile(
                video.isNotEmpty ? video : image, 'story_$sId', image);
          }
        }
      }
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
    }
  }

  Future<void> highlight(String id) async {
    try {
      final uri = Uri.parse('${igs}highlightStories/highlight:$id');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        var stories = Story.fromJson(jsonDecode(response.body));
        Navigator.push(
          contexts,
          MaterialPageRoute(
              builder: (context) => StoryScreen(stories: stories)),
        );
        contexts = null;
      }
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
    }
  }

  // Handles downloading media files (video or image)
  Future downloadMedia(Map<String, dynamic> data) async {
    try {
      if (data['video'] != null && data['video'].isNotEmpty) {
        for (var file in data['video']) {
          await downloadController.downloadFile(
              file['video'],
              "ReelVideo-${Random().nextInt(900000) + 100000}.mp4",
              file['thumbnail']);
        }
      }

      if (data['image'] != null && data['image'].isNotEmpty) {
        for (var url in data['image']) {
          await downloadController.downloadFile(
              url, "ReelImage-${Random().nextInt(900000) + 100000}.jpg", url);
        }
      }
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
    }
  }

  // Handles post reel media
  Future<bool> postReel(Map<String, dynamic> data) async {
    try {
      if (data['items'] != null) {
        Items post = Items.fromJson(data);
        var files = post.files;
        if (files != null) {
          for (var file in files) {
            await downloadController.downloadFile(
                file.fileUrl!, file.fileName!, file.fileDisplayUrl);
          }
          return true;
        } else {
          return false;
        }
      } else if (data['graphql'] != null) {
        Graphql post = Graphql.fromJson(data);
        var files = post.files;
        if (files != null) {
          for (var file in files) {
            await downloadController.downloadFile(
                file.fileUrl!, file.fileName!, file.fileDisplayUrl);
          }
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
      return false;
    }
  }
}
