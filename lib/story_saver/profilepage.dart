import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'profile.dart';

class PorfilePage extends StatefulWidget {
  const PorfilePage({super.key});

  @override
  State<PorfilePage> createState() => PorfilePageState();
}

class PorfilePageState extends State<PorfilePage> {
  TextEditingController profileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            controller: profileController,
            decoration: const InputDecoration(
              hintText: "Profile Name",
            ),
          ),
        ),
        ElevatedButton(
            onPressed: () async {
              var data = await getData(profileController.text);
              print(data);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InsataPorfile(data: data)),
              );
            },
            child: const Text('View Profile'))
      ]),
    ));
  }

  getData(name) async {
    var url = 'https://igs.sf-converter.com/api/userInfoByUsername/' + name;
    final http.Response user = await http.get(Uri.parse(url));
    var userData = jsonDecode(user.body);
    var userID = userData['result']['user']['pk'];
    final http.Response highlights = await http
        .get(Uri.parse('https://igs.sf-converter.com/api/highlights/$userID'));
    var highlightsData = jsonDecode(highlights.body);
    final http.Response storie = await http
        .get(Uri.parse('https://igs.sf-converter.com/api/stories/$userID'));
    // ignore: unused_local_variable
    var storieData = jsonDecode(storie.body);
    print(userData);
    // print(highlightsData);
    // print(storieData);
    return [
      userData,
      highlightsData,
      // storieData
    ];
  }
}
