import 'package:flutter/material.dart';

import 'package:insta/core/routing/app_routes.dart';
import 'package:insta/features/auth/instagram_login_page.dart';
import 'package:insta/features/downloader/download_queue_page.dart';
import 'package:insta/features/home/home_page.dart';
import 'package:insta/features/recovery/recovery_page.dart';
import 'package:insta/features/settings_about/about_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.about:
        return MaterialPageRoute(builder: (_) => const AboutPage());
      case AppRoutes.downloads:
        return MaterialPageRoute(builder: (_) => const DownloadQueueScreen());
      case AppRoutes.recovery:
        return MaterialPageRoute(builder: (_) => const RecoveryScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const InstaLogin());
      case AppRoutes.home:
      default:
        return MaterialPageRoute(builder: (_) => const HomePage());
    }
  }
}
