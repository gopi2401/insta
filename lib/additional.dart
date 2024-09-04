import 'package:flutter/material.dart';
import 'package:insta/story_saver/profilepage.dart';

import 'status_saver/whatsapp.dart';

class Additional extends StatefulWidget {
  const Additional({super.key});

  @override
  State<Additional> createState() => AdditionalState();
}

class AdditionalState extends State<Additional> {
  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      primary: false,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      maxCrossAxisExtent: 200.0,
      children: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.blue,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PorfilePage()),
            );
          },
          child: const Text(
            'insta profile',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.blue,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WhatsApp()),
            );
          },
          child: const Text(
            'WhatsApp',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
