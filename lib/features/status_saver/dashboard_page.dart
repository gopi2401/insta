import 'package:flutter/material.dart';
import 'package:insta/features/status_saver/image_grid_page.dart';
import 'video_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: <Widget>[
        ImageScreen(),
        VideoScreen(),
      ],
    );
  }
}


