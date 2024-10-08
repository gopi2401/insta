import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import 'appdata.dart';

String title(String title) {
  return title
      .replaceAll(RegExp(r"[&/\\#,+()$~%.\':*?<>{}]+"), '')
      .replaceAll("\n", "_")
      .replaceAll("|", "_");
}

// Cleans and formats the filename
String filename(String input) {
  var text = input
      .replaceAll(RegExp(r"[&/\\#,+()$~%.\':*?<>{}]+"), '')
      .replaceAll("\n", "_")
      .replaceAll("|", "_");
  return text.length >= 60 ? text.substring(0, 60) : text;
}

String encryption(String input) {
  final key = encrypt.Key.fromUtf8('qwertyuioplkjhgf');
  final iv = encrypt.IV.fromLength(16);
  final encrypter =
      encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb));
  return encrypter.encrypt(input, iv: iv).base16;
}

String decrypt(String encryptedHex) {
  final key = encrypt.Key.fromUtf8('qwertyuioplkjhgf');
  final iv = encrypt.IV.fromLength(16); // IV length is 16 for AES
  final encrypter =
      encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb));

  // Convert the hex string back to encrypted bytes
  final encryptedBytes = encrypt.Encrypted.fromBase16(encryptedHex);

  // Decrypt the encrypted bytes
  final decrypted = encrypter.decrypt(encryptedBytes, iv: iv);

  return decrypted;
}

void catchInfo(dynamic e, dynamic stackTrace) {
  MyApp.scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Expanded(
            child: Text(
              'Error in ${stackTrace.toString().split("\n")[0]}: ${e.toString()}',
            ),
          ),
          TextButton(
            onPressed: () async {
              var body = """
**${e.toString()}**

`${stackTrace.toString()}`""";
              await createIssue(e.toString().split(':')[0], body);
            },
            child: const Text('Send issue'),
          ),
        ],
      ),
      duration: const Duration(seconds: 5),
    ),
  );
}

Future<String> getAppVersion() async {
  const platform = MethodChannel('app.channel.shared.data');
  try {
    return await platform.invokeMethod('getAppVersion');
  } on PlatformException catch (e, stackTrace) {
    catchInfo(e, stackTrace);
    return 'Failed to get app version: ${e.message}';
  }
}

Future<String?> checkUpdate() async {
  final response = await http
      .get(Uri.parse('https://api.github.com/repos/gopi2401/insta/releases'));
  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    var version1 = jsonData[0]['tag_name'];
    if (version1.startsWith("v")) {
      version1 = version1.substring(1);
      return version1;
    } else {
      return null;
    }
  } else {
    return null;
  }
}

Future<void> createIssue(String title, String body) async {
  final issueBody = body;

  final response = await http.post(
    Uri.parse('$githubApi/issues'),
    headers: {
      'Authorization': 'token ${dotenv.env['githubToken']}',
      'Accept': 'application/vnd.github.v3+json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'title': title,
      'body': issueBody,
      'labels': ['bug'],
    }),
  );

  if (response.statusCode == 201) {
    // Success
    MyApp.scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Expanded(
          child: Text('You rock! thanks for your feedback.👍'),
        ),
      ),
    );
  } else {
    print('Failed to create issue: ${response.statusCode}');
    print(response.body);
  }
}
