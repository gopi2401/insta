import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:insta/core/services/permissions_service.dart';
import 'package:insta/features/auth/instagram_login_page.dart';
import 'package:insta/features/home/home_controller.dart';
import 'package:insta/features/home/home_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Get.put(HomeController());
  late FToast fToast;

  final Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(25.0)),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(FontAwesomeIcons.link, size: 15),
        SizedBox(width: 12.0),
        Text('url not found..!'),
      ],
    ),
  );

  @override
  void initState() {
    super.initState();
    Permissions.requestStoragePermission(context);
    fToast = FToast()..init(context);
    controller.appUpdate(context);
  }

  void showToast() {
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const DrawerButton(),
        title: const Text('Instagram Downloader'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 8),
              Text(
                'Paste an Instagram URL below and tap download',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.reelController,
                decoration: InputDecoration(
                  labelText: 'Instagram URL',
                  border: const OutlineInputBorder(),
                  hintText: 'https://www.instagram.com/p/xyz',
                  errorText: controller.errorMessage.value,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.reelController.clear(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: controller.downloading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(
                  controller.downloading.value ? 'Downloading...' : 'Download',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: controller.downloading.value
                    ? null
                    : () => controller.onDownloadPressed(
                          context: context,
                          onValidationError: showToast,
                        ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Login to Instagram'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InstaLogin()),
                  );
                },
              ),
              const Spacer(),
              const Additional(),
            ],
          ),
        ),
      ),
      drawer: const AppDrawer(),
    );
  }
}
