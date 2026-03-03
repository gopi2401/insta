import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/circular_progress_widget.dart';

class DownloadProgressController extends GetxController {
  final progress = 0.0.obs;
  final speed = '0 KB/s'.obs;
  final eta = '0s'.obs;
  final fileName = ''.obs;
  final isDownloading = false.obs;

  void updateProgress(double newProgress) {
    progress.value = newProgress;
  }

  void updateSpeed(String newSpeed) {
    speed.value = newSpeed;
  }

  void updateETA(String newETA) {
    eta.value = newETA;
  }

  void setFileName(String name) {
    fileName.value = name;
  }

  void setDownloading(bool value) {
    isDownloading.value = value;
  }

  void reset() {
    progress.value = 0;
    speed.value = '0 KB/s';
    eta.value = '0s';
    fileName.value = '';
    isDownloading.value = false;
  }
}

class DownloadProgressScreen extends StatelessWidget {
  final String title;
  final VoidCallback? onCancel;
  final DownloadProgressController controller;

  const DownloadProgressScreen({
    super.key,
    required this.title,
    this.onCancel,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 300,
        child: SingleChildScrollView(
          child: Obx(
            () => CircularProgressWidget(
              progress: controller.progress.value,
              fileName: controller.fileName.value,
              speed: controller.speed.value,
              eta: controller.eta.value,
              onCancel: onCancel,
            ),
          ),
        ),
      ),
    );
  }
}
