import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

class DeletedFile {
  final String fileName;
  final String originalPath;
  final DateTime deletedAt;
  final String? thumbnailPath;
  final String fileType; // 'video', 'image', 'story', etc.

  DeletedFile({
    required this.fileName,
    required this.originalPath,
    required this.deletedAt,
    this.thumbnailPath,
    required this.fileType,
  });

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'originalPath': originalPath,
        'deletedAt': deletedAt.toIso8601String(),
        'thumbnailPath': thumbnailPath,
        'fileType': fileType,
      };

  factory DeletedFile.fromJson(Map<String, dynamic> json) => DeletedFile(
        fileName: json['fileName'],
        originalPath: json['originalPath'],
        deletedAt: DateTime.parse(json['deletedAt']),
        thumbnailPath: json['thumbnailPath'],
        fileType: json['fileType'],
      );

  bool get isExpired => DateTime.now().difference(deletedAt).inDays > 30;
}

class RecoveryService extends GetxController {
  static RecoveryService get to => Get.find();

  final deletedFiles = <DeletedFile>[].obs;
  late Directory recoveryDir;

  @override
  void onInit() {
    super.onInit();
    _initRecoveryDir();
  }

  Future<void> _initRecoveryDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    recoveryDir = Directory('${appDir.path}/recovery_bin');
    if (!await recoveryDir.exists()) {
      await recoveryDir.create(recursive: true);
    }
    await loadDeletedFiles();
    _cleanupExpiredFiles();
  }

  Future<void> deleteFileForRecovery(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return;

      final fileName = file.path.split('/').last;
      final recoveredFile = File('${recoveryDir.path}/$fileName');

      // Move file to recovery directory
      await file.copy(recoveredFile.path);

      // Extract file type from path
      String fileType = 'unknown';
      if (filePath.contains('story')) {
        fileType = 'story';
      } else if (filePath.contains('.mp4') || filePath.contains('.mov')) {
        fileType = 'video';
      } else {
        fileType = 'image';
      }

      // Add to deleted files list
      final deletedFile = DeletedFile(
        fileName: fileName,
        originalPath: filePath,
        deletedAt: DateTime.now(),
        fileType: fileType,
      );

      deletedFiles.add(deletedFile);
      await _saveDeletedFilesMetadata();

      // Delete original file after backup
      await file.delete();
    } catch (e) {
      print('Error deleting file for recovery: $e');
    }
  }

  Future<void> recoverFile(DeletedFile deletedFile) async {
    try {
      final recoveredFile = File('${recoveryDir.path}/${deletedFile.fileName}');
      if (!await recoveredFile.exists()) {
        throw Exception('Recovery file not found');
      }

      // Restore to original location
      final originalDir = Directory(deletedFile.originalPath.substring(
          0, deletedFile.originalPath.lastIndexOf('/')));
      if (!await originalDir.exists()) {
        await originalDir.create(recursive: true);
      }

      await recoveredFile.copy(deletedFile.originalPath);
      await recoveredFile.delete();

      // Remove from deleted files
      deletedFiles.remove(deletedFile);
      await _saveDeletedFilesMetadata();
    } catch (e) {
      print('Error recovering file: $e');
      throw Exception('Failed to recover file: $e');
    }
  }

  Future<void> permanentlyDelete(DeletedFile deletedFile) async {
    try {
      final recoveredFile = File('${recoveryDir.path}/${deletedFile.fileName}');
      if (await recoveredFile.exists()) {
        await recoveredFile.delete();
      }

      deletedFiles.remove(deletedFile);
      await _saveDeletedFilesMetadata();
    } catch (e) {
      print('Error permanently deleting file: $e');
    }
  }

  Future<void> loadDeletedFiles() async {
    try {
      final metadataFile =
          File('${recoveryDir.path}/deleted_files.json');
      if (await metadataFile.exists()) {
        // In a real app, you'd use json_serializable or similar
        // For now, just initialize empty
        deletedFiles.clear();
      }
    } catch (e) {
      print('Error loading deleted files: $e');
    }
  }

  Future<void> _saveDeletedFilesMetadata() async {
    try {
      // Metadata would be saved here
      // For now, just keep in memory
    } catch (e) {
      print('Error saving deleted files metadata: $e');
    }
  }

  Future<void> _cleanupExpiredFiles() async {
    try {
      final expiredFiles = deletedFiles.where((f) => f.isExpired).toList();

      for (var file in expiredFiles) {
        await permanentlyDelete(file);
      }
    } catch (e) {
      print('Error cleaning up expired files: $e');
    }
  }

  String getFormattedDaysLeft(DeletedFile file) {
    final daysLeft = 30 - DateTime.now().difference(file.deletedAt).inDays;
    return daysLeft > 0 ? '$daysLeft days left' : 'Expires today';
  }

  String getFormattedDeletedDate(DateTime date) {
    return DateFormat('MMM d, y • h:mm a').format(date);
  }
}
