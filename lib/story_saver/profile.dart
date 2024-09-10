import 'package:flutter/material.dart';
import 'story.dart';

class InsataPorfile extends StatefulWidget {
  const InsataPorfile({super.key, required this.data});
  final data;
  @override
  State<InsataPorfile> createState() => InsataPorfileState();
}

class InsataPorfileState extends State<InsataPorfile> {
  late TextEditingController profileController;
  @override
  void initState() {
    super.initState();
    profileController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    profileController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.data[0];
    String username = data['result']['user']['username'];
    String profilePicUrl = data['result']['user']['profile_pic_url'];
    String fullName = data['result']['user']['full_name'];
    String bio = data['result']['user']['biography'];
    String followerCount = data['result']['user']['follower_count'].toString();
    String followingCount =
        data['result']['user']['following_count'].toString();
    var highlights = widget.data[1]['result'];
    var stories = widget.data[2]['result'];
    return Scaffold(
        appBar: AppBar(
          title: Text(username),
        ),
        body: Container(
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      if (stories.length > 0) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return Story(
                            stories: stories,
                          );
                        }));
                        // if (stories[0]['image_versions2'] != null) {
                        //   String img = stories[0]['image_versions2']
                        //       ['candidates'][0]['url'];
                        //   Navigator.push(context,
                        //       MaterialPageRoute(builder: (_) {
                        //     return ImageScreen(
                        //       imgUrl: img,
                        //     );
                        //   }));
                        // } else {}
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return ImageScreen(
                            imgUrl: profilePicUrl,
                          );
                        }));
                      }
                    },
                    onLongPress: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return ImageScreen(
                          imgUrl: profilePicUrl,
                        );
                      }));
                    },
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor:
                          stories.length > 0 ? Colors.green : Colors.grey,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(profilePicUrl),
                      ),
                    )),
                const Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0)),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '$followerCount\n',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0),
                    children: const <TextSpan>[
                      TextSpan(
                          text: 'Followers',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14.0)),
                    ],
                  ),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '$followingCount\n',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0),
                    children: const <TextSpan>[
                      TextSpan(
                          text: 'Following',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14.0)),
                    ],
                  ),
                ),
                const Padding(padding: EdgeInsets.only(left: 5.0, right: 5.0)),
              ],
            ),
            Row(
              children: [Text('$fullName\n$bio')],
            ),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (highlights.length > 0) ...[
                      for (var highlight in highlights) ...[
                        SizedBox(
                          // width: auto,
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 37,
                                backgroundColor: Colors.grey,
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundImage: NetworkImage(
                                      highlight['cover_media']
                                          ['cropped_image_version']['url']),
                                ),
                              ),
                              Text(highlight['title'])
                            ],
                          ),
                        ),
                      ],
                    ] else ...[
                      const CircleAvatar(
                        radius: 37,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.add),
                      ),
                    ]
                  ],
                ))
          ]),
        ));
  }
}

class ImageScreen extends StatelessWidget {
  const ImageScreen({super.key, required this.imgUrl});
  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: '',
            child: Image.network(
              imgUrl,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
