import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class AnalyticsService extends GetxService {
  static AnalyticsService get to => Get.find();

  File? _logFile;

  Future<void> logEvent(
    String event, {
    Map<String, dynamic>? payload,
  }) async {
    try {
      _logFile ??= await _resolveLogFile();
      final row = jsonEncode({
        'event': event,
        'payload': payload ?? <String, dynamic>{},
        'ts': DateTime.now().toIso8601String(),
      });
      await _logFile!.writeAsString('$row\n', mode: FileMode.append);
    } catch (_) {
      // Analytics must never block user flows.
    }
  }

  Future<List<String>> readRecentEvents({int limit = 200}) async {
    try {
      _logFile ??= await _resolveLogFile();
      if (!await _logFile!.exists()) {
        return const [];
      }
      final lines = await _logFile!.readAsLines();
      if (lines.length <= limit) {
        return lines.reversed.toList();
      }
      return lines.sublist(lines.length - limit).reversed.toList();
    } catch (_) {
      return const [];
    }
  }

  Future<File> _resolveLogFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/analytics_events.log');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }
}
