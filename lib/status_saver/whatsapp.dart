import 'package:flutter/material.dart';
import 'package:insta/status_saver/ui/dashboard.dart';

class WhatsApp extends StatefulWidget {
  const WhatsApp({Key? key}) : super(key: key);
  @override
  WhatsAppState createState() => WhatsAppState();
}

class WhatsAppState extends State<WhatsApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          title: const Text('Status Saver'),
          backgroundColor: const Color(0xff128C7E),
          bottom: TabBar(tabs: [
            Container(
              padding: const EdgeInsets.all(12.0),
              child: const Text(
                'IMAGES',
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              child: const Text(
                'VIDEOS',
              ),
            ),
          ]),
        ),
        body: const Dashboard(),
      ),
    );
  }
}
