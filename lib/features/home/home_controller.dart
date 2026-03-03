import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:insta/core/utils/app_data.dart';
import 'package:insta/core/utils/app_utils.dart';
import 'package:insta/core/utils/url_validation.dart';
import 'package:insta/features/downloader/distrib_url_controller.dart';

class HomeController extends GetxController {
  final TextEditingController reelController = TextEditingController();

  final RxBool downloading = false.obs;
  final RxnString errorMessage = RxnString();

  Future<void> onDownloadPressed({
    required BuildContext context,
    required VoidCallback onValidationError,
  }) async {
    downloading.value = true;
    errorMessage.value = null;

    try {
      final url = reelController.text.trim();
      if (url.isEmpty) {
        errorMessage.value = 'URL cannot be empty';
        onValidationError();
      } else if (!isValidHttpUrl(url)) {
        errorMessage.value = 'Please enter a valid URL';
        onValidationError();
      } else {
        final downloadController = Get.isRegistered<DistribUrl>()
            ? Get.find<DistribUrl>()
            : Get.put(DistribUrl());
        contexts = context;
        await downloadController.handleUrl(url);
        reelController.clear();
      }
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
    } finally {
      downloading.value = false;
    }
  }

  Future<void> appUpdate(BuildContext context) async {
    final appVersion = await getAppVersion();
    final newVersion = await checkUpdate();
    if (appVersion != newVersion) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'New version download',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                const TextSpan(
                  text: 'Link: https://gopi2401.github.io/download/',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  void onClose() {
    reelController.dispose();
    if (Get.isRegistered<DistribUrl>()) {
      Get.delete<DistribUrl>();
    }
    super.onClose();
  }
}
