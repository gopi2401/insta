import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'package:insta/core/services/notification_service.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  Future<bool> canWrite() async {
    final preferred = await _preferredPublicDownloadDir();
    if (preferred == null) {
      return true;
    }
    return _canWriteToDir(preferred);
  }

  Future<String> resolveDownloadPath(String fileName, DownloadType type) async {
    final normalized = _normalizeName(fileName, type);
    final publicDir = await _preferredPublicDownloadDir();

    if (publicDir != null && await _canWriteToDir(publicDir)) {
      return '${publicDir.path}/$normalized';
    }

    final fallbackRoot = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    final fallback = Directory('${fallbackRoot.path}/downloads');
    if (!await fallback.exists()) {
      await fallback.create(recursive: true);
    }
    return '${fallback.path}/$normalized';
  }

  Future<Directory?> _preferredPublicDownloadDir() async {
    if (!Platform.isAndroid) {
      return null;
    }

    final info = await DeviceInfoPlugin().androidInfo;
    final sdkInt = info.version.sdkInt;

    // Android 10+ often restricts direct public Download writes for many paths.
    if (sdkInt >= 29) {
      return null;
    }

    return Directory('/storage/emulated/0/Download/Insta');
  }

  Future<bool> _canWriteToDir(Directory dir) async {
    try {
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final probe = File('${dir.path}/.write_probe');
      await probe.writeAsString(DateTime.now().toIso8601String());
      if (await probe.exists()) {
        await probe.delete();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  String _normalizeName(String fileName, DownloadType type) {
    final sanitized =
        fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    if (sanitized.isNotEmpty) {
      return sanitized;
    }

    final ext = type == DownloadType.instagram ||
            type == DownloadType.story ||
            type == DownloadType.youtube ||
            type == DownloadType.highlight
        ? 'mp4'
        : 'jpg';
    return 'download_${DateTime.now().millisecondsSinceEpoch}.$ext';
  }
}


