import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../services/file_download.dart';
import '../models/highlight_model.dart';
import '../models/story_model.dart';
import '../models/user_info_model.dart';
import '../utils/appdata.dart';
import '../utils/function.dart';
import 'image_screen.dart';
import 'story_screen.dart';

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

  void _onLoading(bool t) {
    if (t) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SimpleDialog(
              backgroundColor: Colors.transparent,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    'assets/loading.gif',
                    width: 45,
                  ),
                )
              ],
            );
          });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    profileController.dispose();
    if (Get.isRegistered<FileDownload>()) {
      downloadController.dispose();
    }
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
                        return StoryScreen(
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
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'posts',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          )),
                    ],
                  ),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '${user.followerCount}\n',
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'followers',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          )),
                    ],
                  ),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '${user.followingCount}\n',
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'following',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          )),
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
            const SizedBox(
              height: 15,
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: highlights.map((highlight) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  _onLoading(true);
                                  final stories =
                                      await highlightStories(highlight.id);
                                  _onLoading(false);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    return StoryScreen(
                                      stories: stories!,
                                    );
                                  }));
                                },
                                child: CircleAvatar(
                                  radius: 37,
                                  backgroundColor: Colors.grey,
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundImage:
                                        NetworkImage(highlight.coverMedia),
                                  ),
                                ),
                              ),
                              Text(highlight.title),
                            ],
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

  Future<Highlight?> apiHighlight(int id) async {
    try {
      final uri = Uri.parse('${igs}highlights/$id');
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
      final uri = Uri.parse('${igs}stories/$id');
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

  Future<Story?> highlightStories(String id) async {
    try {
      final uri = Uri.parse('${igs}highlightStories/$id');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return Story.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to load stories. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
      return null;
    }
  }

  void profilePicDownload() {
    downloadController = Get.put(FileDownload());
    downloadController.downloadFile(
        widget.data.hdProfilePicUrl,
        widget.data.hdProfilePicUrl.split('?').first.split('/').last,
        widget.data.profilePicUrl);
  }
}
