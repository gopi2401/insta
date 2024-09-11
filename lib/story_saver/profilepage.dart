import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:insta/models/user_info_model.dart';
import '../utils/appdata.dart';
import 'profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  TextEditingController profileController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: profileController,
                decoration: const InputDecoration(
                  hintText: "Profile Name",
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
              onPressed: () async {
                if (profileController.text.isNotEmpty) {
                  setState(() {
                    isLoading = true;
                    errorMessage = null; // Clear previous errors
                  });

                  var data = await apiUserData(profileController.text.trim());

                  setState(() {
                    isLoading = false;
                  });

                  if (data != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InstaProfile(data: data)),
                    );
                  } else {
                    setState(() {
                      errorMessage =
                          "Failed to load profile. Please try again.";
                    });
                  }
                } else {
                  setState(() {
                    errorMessage = "Profile name cannot be empty!";
                  });
                }
              },
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text('View Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Future<UserInfo?> apiUserData(String name) async {
    try {
      final uri = Uri.parse('${igs}userInfoByUsername/$name');
      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        return UserInfo.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to load user data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
