import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:insta/core/services/theme_service.dart';
import 'package:insta/features/downloader/download_queue_page.dart';
import 'package:insta/features/recovery/recovery_controller.dart';
import 'package:insta/features/recovery/recovery_page.dart';
import 'package:insta/features/settings_about/about_page.dart';
import 'package:insta/features/status_saver/status_saver_page.dart';
import 'package:insta/features/story_saver/profile_page.dart';

class Additional extends StatefulWidget {
  const Additional({super.key});

  @override
  State<Additional> createState() => AdditionalState();
}

class AdditionalState extends State<Additional> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: const Text(
                'insta profile',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: TextButton(
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
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.to;
    final recoveryService = RecoveryService.to;

    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            duration: Duration(seconds: 1),
            curve: Curves.easeInCubic,
            decoration: BoxDecoration(
              image: DecorationImage(
                scale: 2.5,
                image: AssetImage('assets/logo.png'),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Welcome!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 33),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home', style: TextStyle(fontSize: 18)),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: const Text('About', style: TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutPage()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.restore_from_trash),
                  title: const Text('Recovery Bin', style: TextStyle(fontSize: 18)),
                  trailing: Obx(
                    () => recoveryService.deletedFiles.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              recoveryService.deletedFiles.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecoveryScreenWrapper(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download_for_offline),
                  title: const Text('Downloads', style: TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DownloadQueueScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Obx(
                    () => Icon(
                      themeService.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                  ),
                  title: Obx(
                    () => Text(
                      themeService.isDarkMode ? 'Light Mode' : 'Dark Mode',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  onTap: () => themeService.toggleTheme(context),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text('Made with love by gopi'),
          ),
        ],
      ),
    );
  }
}

class RecoveryScreenWrapper extends StatelessWidget {
  const RecoveryScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const RecoveryScreen();
  }
}
