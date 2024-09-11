import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:insta/models/highlight_model.dart';
import 'package:insta/models/story_model.dart';
import 'package:insta/models/user_info_model.dart';
import 'package:insta/story_saver/image_screen.dart';
import '../Functions/fileDownload.dart';
import 'story_view.dart';
import 'package:path/path.dart' as path;

class InstaProfile extends StatefulWidget {
  const InstaProfile({super.key, required this.data});
  final UserInfo data;

  @override
  State<InstaProfile> createState() => InstaProfileState();
}

class InstaProfileState extends State<InstaProfile> {
  late TextEditingController profileController;
  late FileDownload downloadController;
  late Future<Highlight?> highlightsFuture;
  late Future<Story?> storiesFuture;

  @override
  void initState() {
    super.initState();
    profileController = TextEditingController();
    downloadController = Get.put(FileDownload());

    // Fetch highlights and stories only if the profile is public
    highlightsFuture = widget.data.isPrivate
        ? Future.value(null)
        : apiHighlight(widget.data.id);

    storiesFuture =
        widget.data.isPrivate ? Future.value(null) : apiStories(widget.data.id);
  }

  @override
  void dispose() {
    profileController.dispose();
    downloadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var user = widget.data;
    return Scaffold(
      appBar: AppBar(
        title: Text(user.username),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    final stories = await storiesFuture;
                    if (stories != null && stories.stories.isNotEmpty) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return StoryView(
                          stories: stories,
                        );
                      }));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return ImageScreen(
                            imgUrl: user.hdProfilePicUrl,
                            profilePicDownload: profilePicDownload);
                      }));
                    }
                  },
                  onLongPress: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return ImageScreen(
                          imgUrl: user.hdProfilePicUrl,
                          profilePicDownload: profilePicDownload);
                    }));
                  },
                  child: CircleAvatar(
                    radius: 54,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(user.profilePicUrl),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '${user.mediaCount}\n',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0),
                    children: const <TextSpan>[
                      TextSpan(
                          text: 'posts',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14.0)),
                    ],
                  ),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '${user.followerCount}\n',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0),
                    children: const <TextSpan>[
                      TextSpan(
                          text: 'followers',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14.0)),
                    ],
                  ),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '${user.followingCount}\n',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0),
                    children: const <TextSpan>[
                      TextSpan(
                          text: 'following',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14.0)),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
            Row(
              children: [
                Text('${user.fullname}\n${user.category}\n${user.biography}')
              ],
            ),
            SizedBox(
              child: FutureBuilder<Highlight?>(
                future: highlightsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('Failed to load highlights.');
                  } else if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.highlights.isEmpty) {
                    return const Row(
                      children: [
                        CircleAvatar(
                          radius: 37,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.add),
                        ),
                      ],
                    );
                  } else {
                    var highlights = snapshot.data!.highlights;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: highlights.map((highlight) {
                          return SizedBox(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 37,
                                  backgroundColor: Colors.grey,
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundImage:
                                        NetworkImage(highlight.coverMedia),
                                  ),
                                ),
                                Text(highlight.title),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String baseUrl = 'https://igs.sf-converter.com/api/';
  Future<Highlight?> apiHighlight(int id) async {
    try {
      final uri = Uri.parse('${baseUrl}highlights/$id');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return Highlight.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to load highlights. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Story?> apiStories(int id) async {
    try {
      final uri = Uri.parse('${baseUrl}stories/$id');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return Story.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to load stories. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  void profilePicDownload() {
    downloadController.downloadFile(
        widget.data.hdProfilePicUrl,
        widget.data.hdProfilePicUrl.split('?').first.split('/').last,
        widget.data.profilePicUrl);
  }
}
