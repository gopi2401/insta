import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/recovery_service.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({Key? key}) : super(key: key);

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  late RecoveryService recoveryService;
  late int totalSize = 0;

  @override
  void initState() {
    super.initState();
    // Lazily initialize the recovery service
    if (!Get.isRegistered<RecoveryService>()) {
      Get.put(RecoveryService(), permanent: true);
    }
    recoveryService = RecoveryService.to;
    _calculateTotalSize();
  }

  void _calculateTotalSize() {
    // Calculate total size of deleted files
    for (var file in recoveryService.deletedFiles) {
      // In a real implementation, calculate actual file sizes
      totalSize += 0; // placeholder
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Bin'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(
        () => recoveryService.deletedFiles.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Recovery Bin is Empty',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Deleted files appear here for 30 days',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: recoveryService.deletedFiles.length,
                itemBuilder: (context, index) {
                  final file = recoveryService.deletedFiles[index];
                  return _buildDeletedFileCard(file);
                },
              ),
      ),
    );
  }

  Widget _buildDeletedFileCard(DeletedFile file) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _getFileIcon(file.fileType),
        title: Text(
          file.fileName,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              recoveryService.getFormattedDeletedDate(file.deletedAt),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: file.isExpired
                        ? Colors.red.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    recoveryService.getFormattedDaysLeft(file),
                    style: TextStyle(
                      fontSize: 11,
                      color: file.isExpired ? Colors.red : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => _showRecoverConfirmation(file),
              child: const Row(
                children: [
                  Icon(Icons.restore, size: 18),
                  SizedBox(width: 8),
                  Text('Recover'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => _showDeleteConfirmation(file),
              child: const Row(
                children: [
                  Icon(Icons.delete_forever, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Permanently'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getFileIcon(String fileType) {
    switch (fileType) {
      case 'video':
        return Icon(
          Icons.video_library,
          color: Colors.blue[400],
        );
      case 'image':
        return Icon(
          Icons.image,
          color: Colors.purple[400],
        );
      case 'story':
        return Icon(
          Icons.layers,
          color: Colors.pink[400],
        );
      default:
        return Icon(
          Icons.file_present,
          color: Colors.grey[400],
        );
    }
  }

  void _showRecoverConfirmation(DeletedFile file) {
    Get.dialog(
      AlertDialog(
        title: const Text('Recover File'),
        content: Text(
          'Do you want to recover "${file.fileName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await recoveryService.recoverFile(file);
                Get.back();
                Get.snackbar(
                  'Success',
                  '"${file.fileName}" has been recovered',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to recover file: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Recover'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(DeletedFile file) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Permanently'),
        content: Text(
          'This will permanently delete "${file.fileName}". This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await recoveryService.permanentlyDelete(file);
              Get.back();
              Get.snackbar(
                'Deleted',
                '"${file.fileName}" has been permanently deleted',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
