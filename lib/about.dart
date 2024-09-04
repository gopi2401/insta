import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late String version;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/logo.png', width: 175),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: getAppVersion(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return TextButton(
                    child: Text('Version: ${snapshot.data}',
                        style: const TextStyle(
                          fontSize: 18,
                        )),
                    onPressed: () => checkUpdate(context),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ))),
              onPressed: () => {
                launchUrl(Uri.parse(
                    'upi://pay?pa=gopi24012002-1@okhdfcbank&pn=gopi2401&cu=INR'))
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Donate with'),
                  const SizedBox(
                    width: 5,
                  ),
                  Image.asset(
                    'assets/gpay.png',
                    width: 50,
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            RichText(
                text: TextSpan(children: [
              const TextSpan(
                text: 'Author:',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              TextSpan(
                  text: ' gopi ❤️',
                  style: const TextStyle(fontSize: 18, color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse('https://git.histb.com/gopi2401'));
                    })
            ])),
            const SizedBox(height: 10),
            // InkWell(
            //     child: new Text('Open Browser'), onTap: () => launchUrl(_url)),
            // SizedBox(height: 10),
            const Text(
              'Description: This is instagram post,reel,story & youtube video, short easy downloader app.',
              style: TextStyle(
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkUpdate(context) async {
    final response = await http
        .get(Uri.parse('https://api.github.com/repos/gopi2401/insta/releases'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      var version1 = jsonData[0]['tag_name'];
      if (version1.startsWith("v")) {
        version1 = version1.substring(1);
      }
      if (version == version1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Already updated! 😉', style: TextStyle(fontSize: 18)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: RichText(
                text: TextSpan(children: [
              const TextSpan(
                text: 'New version download',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              TextSpan(
                  text: 'Link',
                  style: const TextStyle(fontSize: 20, color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(
                          Uri.parse('https:gopi2401.github.io/download/'));
                    })
            ])),
          ),
        );
      }
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception or handle the error
      throw Exception('Failed to load data');
    }
  }

  Future<String> getAppVersion() async {
    const platform = MethodChannel('app.channel.shared.data');
    try {
      version = await platform.invokeMethod('getAppVersion');
      return version;
    } on PlatformException catch (e) {
      return 'Failed to get app version: ${e.message}';
    }
  }
}
