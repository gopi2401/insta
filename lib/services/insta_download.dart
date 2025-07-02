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
  late FileDownload downloadController;

  @override
  void onInit() {
    super.onInit();
    downloadController = Get.put(FileDownload());
  }

  @override
  void dispose() {
    downloadController.dispose();
    super.dispose();
  }

  // Downloads media from the provided link
  bool isLoading = false;

  Future<void> downloadReal(String link, BuildContext? context) async {
    HttpClient client = HttpClient();
    try {
      const instaallinone =
          "7e65999c1fcfd42c07ef9d3456f234ee39e52aa88f4dedc610ae5972decec4ab072c6f2d17e6e123b097eddaee9a63f5";
      HttpClientRequest request =
          await client.getUrl(Uri.parse(decrypt(instaallinone)));
      request.headers.add('url', encryption(link));

      HttpClientResponse response = await request.close();

      // Handle HTTP response
      if (response.statusCode == HttpStatus.ok) {
        var json = await response.transform(utf8.decoder).join();
        var responseData = jsonDecode(json);
        await downloadMedia(responseData);
      } else {
        if (context != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InstaLogin()),
          );
        }
      }
    } catch (e, stackTrace) {
      isLoading = false;
      catchInfo(e, stackTrace);
    }
  }

  // Fetches and downloads Instagram stories
  Future<void> stories(String uName, String? sId) async {
    try {
      final userResponse =
          await http.get(Uri.parse('${igs}userInfoByUsername/$uName'));
      if (userResponse.statusCode != 200) {
        throw Exception('Failed to load user info');
      }
      var userId = jsonDecode(userResponse.body)['result']['user']['id'];

      final storiesResponse =
          await http.get(Uri.parse('${igs}stories/$userId'));
      if (storiesResponse.statusCode != 200) {
        throw Exception('Failed to load stories');
      }
      var storiesData = Story.fromJson(jsonDecode(storiesResponse.body));

      if (storiesData.stories.isNotEmpty) {
        for (var story in storiesData.stories) {
          if (story.pk == sId) {
            var image = story.img;
            var video = story.storie;
            await downloadController.downloadFile(
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
