import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/download_job.dart';
import '../services/analytics_service.dart';
import '../services/download_queue_service.dart';
import '../services/notification_service.dart';

class DownloadQueueScreen extends StatefulWidget {
  const DownloadQueueScreen({super.key});

  @override
  State<DownloadQueueScreen> createState() => _DownloadQueueScreenState();
}

class _DownloadQueueScreenState extends State<DownloadQueueScreen> {
  final queue = DownloadQueueService.to;
  final searchController = TextEditingController();
  List<String> analyticsRows = const [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    if (!Get.isRegistered<AnalyticsService>()) return;
    final rows = await AnalyticsService.to.readRecentEvents(limit: 100);
    if (!mounted) return;
    setState(() {
      analyticsRows = rows;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Downloads'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Queue'),
              Tab(text: 'History'),
              Tab(text: 'Diagnostics'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildQueueTab(),
            _buildHistoryTab(),
            _buildDiagnosticsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueTab() {
    return Obx(() {
      final queueJobs = queue.jobs.where((j) {
        return j.status == DownloadStatus.queued ||
            j.status == DownloadStatus.running ||
            j.status == DownloadStatus.paused;
      }).toList();

      if (queueJobs.isEmpty) {
        return const Center(child: Text('No active downloads'));
      }

      return ReorderableListView.builder(
        itemCount: queueJobs.length,
        onReorder: (oldIndex, newIndex) async {
          final oldJob = queueJobs[oldIndex];
          final oldGlobal = queue.jobs.indexWhere((j) => j.id == oldJob.id);
          if (oldGlobal == -1) return;

          final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
          final targetJob = queueJobs[adjusted.clamp(0, queueJobs.length - 1)];
          final newGlobal = queue.jobs.indexWhere((j) => j.id == targetJob.id);
          if (newGlobal == -1) return;
          await queue.reorder(oldGlobal, newGlobal);
        },
        itemBuilder: (context, index) {
          final job = queueJobs[index];
          return ListTile(
            key: ValueKey(job.id),
            title: Text(job.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${job.status.name} - ${job.progress}%'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (job.status == DownloadStatus.running)
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () => queue.pause(job.id),
                  ),
                if (job.status == DownloadStatus.paused)
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => queue.resume(job.id),
                  ),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () => queue.cancel(job.id),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Search history',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: Obx(() {
            final query = searchController.text.trim().toLowerCase();
            final history = queue.jobs.where((j) {
              final done = j.status == DownloadStatus.success ||
                  j.status == DownloadStatus.failed ||
                  j.status == DownloadStatus.canceled;
              if (!done) return false;
              if (query.isEmpty) return true;
              return j.fileName.toLowerCase().contains(query) ||
                  NotificationService.to.getTypeLabel(j.type).toLowerCase().contains(query);
            }).toList();

            if (history.isEmpty) {
              return const Center(child: Text('No history found'));
            }

            return ListView.separated(
              itemCount: history.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final job = history[index];
                return ListTile(
                  title: Text(job.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${NotificationService.to.getTypeLabel(job.type)} - ${job.status.name}',
                  ),
                  trailing: job.status == DownloadStatus.failed
                      ? IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () => queue.retry(job.id),
                        )
                      : null,
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDiagnosticsTab() {
    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text(
            'Failed Jobs',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final failed = queue.jobs.where((j) => j.status == DownloadStatus.failed).toList();
            if (failed.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No failed jobs'),
              );
            }
            return Column(
              children: failed
                  .map(
                    (j) => Card(
                      child: ListTile(
                        title: Text(j.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(j.errorCode ?? 'unknown'),
                        trailing: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () => queue.retry(j.id),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
          const SizedBox(height: 16),
          const Text(
            'Recent Events',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (analyticsRows.isEmpty)
            const Text('No analytics events yet')
          else
            ...analyticsRows.map((line) {
              String title = line;
              try {
                final json = jsonDecode(line) as Map<String, dynamic>;
                title = '${json['event']} @ ${json['ts']}';
              } catch (_) {}
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(title, style: const TextStyle(fontSize: 12)),
              );
            }),
        ],
      ),
    );
  }
}
