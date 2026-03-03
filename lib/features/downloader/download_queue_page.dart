import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'package:insta/features/downloader/download_job_model.dart';
import 'package:insta/features/downloader/download_queue_controller.dart';
import 'package:insta/core/services/notification_service.dart';
import 'package:insta/features/status_saver/video_player_page.dart';

class DownloadQueueScreen extends StatefulWidget {
  const DownloadQueueScreen({super.key});

  @override
  State<DownloadQueueScreen> createState() => _DownloadQueueScreenState();
}

class _DownloadQueueScreenState extends State<DownloadQueueScreen> {
  final queue = DownloadQueueService.to;
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  bool _isPlayableVideo(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.3gp');
  }

  Future<void> _shareDownloadedFile(DownloadJob job) async {
    final path = job.filePath;
    if (path == null || path.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File path unavailable for sharing.')),
      );
      return;
    }

    final file = File(path);
    if (!await file.exists()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloaded file is missing.')),
      );
      return;
    }

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        text: job.fileName,
        subject: 'Shared from Insta Downloader',
      ),
    );
  }

  Future<void> _playDownloadedVideo(DownloadJob job) async {
    final path = job.filePath;
    if (path == null || path.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video path unavailable.')),
      );
      return;
    }

    final file = File(path);
    if (!await file.exists()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video file is missing.')),
      );
      return;
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayStatus(videoFile: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search downloads',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(child: _buildMergedDownloadsList()),
        ],
      ),
    );
  }

  int _statusPriority(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.running:
        return 0;
      case DownloadStatus.paused:
        return 1;
      case DownloadStatus.queued:
        return 2;
      case DownloadStatus.failed:
        return 3;
      case DownloadStatus.canceled:
        return 4;
      case DownloadStatus.success:
        return 5;
    }
  }

  Widget _buildMergedDownloadsList() {
    return Obx(() {
      final query = searchController.text.trim().toLowerCase();
      final indexedJobs = queue.jobs.asMap().entries.toList();

      final filtered = indexedJobs.where((entry) {
        if (query.isEmpty) return true;
        final job = entry.value;
        return job.fileName.toLowerCase().contains(query) ||
            NotificationService.to.getTypeLabel(job.type).toLowerCase().contains(query) ||
            job.status.name.toLowerCase().contains(query);
      }).toList();

      filtered.sort((a, b) {
        final byPriority = _statusPriority(a.value.status).compareTo(
          _statusPriority(b.value.status),
        );
        if (byPriority != 0) return byPriority;
        return a.key.compareTo(b.key);
      });

      if (queue.jobs.isEmpty) {
        return const Center(child: Text('No downloads yet'));
      }
      if (filtered.isEmpty) {
        return const Center(child: Text('No matching downloads'));
      }

      return ListView.separated(
        itemCount: filtered.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final job = filtered[index].value;
          return ListTile(
            key: ValueKey(job.id),
            title: Text(
              job.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${NotificationService.to.getTypeLabel(job.type)} - ${job.status.name} - ${job.progress}%',
            ),
            trailing: _buildTrailingActions(job),
          );
        },
      );
    });
  }

  Widget _buildTrailingActions(DownloadJob job) {
    final isActive = job.status == DownloadStatus.queued ||
        job.status == DownloadStatus.running ||
        job.status == DownloadStatus.paused;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (job.status == DownloadStatus.running)
          IconButton(
            tooltip: 'Pause',
            icon: const Icon(Icons.pause),
            onPressed: () => queue.pause(job.id),
          ),
        if (job.status == DownloadStatus.paused)
          IconButton(
            tooltip: 'Resume',
            icon: const Icon(Icons.play_arrow),
            onPressed: () => queue.resume(job.id),
          ),
        if (job.status == DownloadStatus.failed)
          IconButton(
            tooltip: 'Retry',
            icon: const Icon(Icons.refresh),
            onPressed: () => queue.retry(job.id),
          ),
        if (job.status == DownloadStatus.success && job.filePath != null)
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share),
            onPressed: () => _shareDownloadedFile(job),
          ),
        if (job.status == DownloadStatus.success &&
            job.filePath != null &&
            _isPlayableVideo(job.filePath!))
          IconButton(
            tooltip: 'Play',
            icon: const Icon(Icons.play_circle),
            onPressed: () => _playDownloadedVideo(job),
          ),
        if (isActive)
          IconButton(
            tooltip: 'Cancel',
            icon: const Icon(Icons.cancel),
            onPressed: () => queue.cancel(job.id),
          ),
      ],
    );
  }
}


