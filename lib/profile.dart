import 'package:flutter/material.dart';

class InsataPorfile extends StatefulWidget {
  const InsataPorfile({super.key, required this.data});
  final data;
  @override
  State<InsataPorfile> createState() => InsataPorfileState();
}

class InsataPorfileState extends State<InsataPorfile> {
  TextEditingController profileController = TextEditingController();

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
                CircleAvatar(
                  radius: 53,
                  backgroundColor: Colors.grey,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profilePicUrl),
                  ),
                ),
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
            Row(
              children: [
                CircleAvatar(
                  radius: 37,
                  backgroundColor: Colors.grey,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(profilePicUrl),
                  ),
                ),
              ],
            )
          ]),
        ));
  }
}
