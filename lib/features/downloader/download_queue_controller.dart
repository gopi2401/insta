import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'package:insta/features/downloader/download_job_model.dart';
import 'package:insta/core/utils/app_utils.dart';
import 'package:insta/core/services/analytics_service.dart';
import 'package:insta/core/services/notification_service.dart';
import 'package:insta/core/services/storage_service.dart';

class DownloadQueueService extends GetxService {
  static DownloadQueueService get to => Get.find();

  final jobs = <DownloadJob>[].obs;

  final Map<int, CancelToken> _cancelTokens = <int, CancelToken>{};
  final Map<int, Completer<DownloadJob>> _waiters = <int, Completer<DownloadJob>>{};
  final Dio _dio = Dio();

  File? _jobsFile;
  bool _processing = false;
  final int _maxRetries = 3;

  @override
  void onInit() {
    super.onInit();
    unawaited(_init());
  }

  Stream<List<DownloadJob>> streamJobs() => jobs.stream;

  StorageService get _storageService {
    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService(), permanent: true);
    }
    return StorageService.to;
  }

  NotificationService get _notificationService {
    if (!Get.isRegistered<NotificationService>()) {
      Get.put(NotificationService(), permanent: true);
    }
    return NotificationService.to;
  }

  Future<DownloadJob> enqueue({
    required String url,
    required String fileName,
    required DownloadType type,
    String? thumbnailUrl,
  }) async {
    final now = DateTime.now();
    final id = _generateId();
    final job = DownloadJob(
      id: id,
      url: url,
      fileName: fileName,
      type: type,
      status: DownloadStatus.queued,
      progress: 0,
      speed: 0,
      eta: 0,
      createdAt: now,
      updatedAt: now,
      thumbnailUrl: thumbnailUrl,
    );
    jobs.insert(0, job);
    await _persistJobs();
    await _log('download_enqueued', {'id': id, 'type': type.name});
    unawaited(_processQueue());
    return job;
  }

  Future<DownloadJob> enqueueAndWait({
    required String url,
    required String fileName,
    required DownloadType type,
    String? thumbnailUrl,
  }) async {
    final job = await enqueue(
      url: url,
      fileName: fileName,
      type: type,
      thumbnailUrl: thumbnailUrl,
    );
    final completer = Completer<DownloadJob>();
    _waiters[job.id] = completer;
    return completer.future;
  }

  Future<void> pause(int id) async {
    final job = _byId(id);
    if (job == null) return;

    if (job.status == DownloadStatus.running) {
      _cancelTokens[id]?.cancel('paused');
    }
    _updateJob(job.copyWith(status: DownloadStatus.paused, updatedAt: DateTime.now()));
    await _persistJobs();
    await _log('download_paused', {'id': id});
  }

  Future<void> resume(int id) async {
    final job = _byId(id);
    if (job == null || job.status != DownloadStatus.paused) return;

    _updateJob(
      job.copyWith(
        status: DownloadStatus.queued,
        updatedAt: DateTime.now(),
      ),
    );
    await _persistJobs();
    await _log('download_resumed', {'id': id});
    unawaited(_processQueue());
  }

  Future<void> cancel(int id) async {
    final job = _byId(id);
    if (job == null) return;

    if (job.status == DownloadStatus.running) {
      _cancelTokens[id]?.cancel('canceled');
    }

    _updateJob(
      job.copyWith(
        status: DownloadStatus.canceled,
        updatedAt: DateTime.now(),
        errorCode: 'canceled',
      ),
    );
    await _persistJobs();
    await _notificationService.cancelNotification(id);
    await _log('download_canceled', {'id': id});
    _completeWaiter(id);
  }

  Future<void> retry(int id) async {
    final job = _byId(id);
    if (job == null) return;

    _updateJob(
      job.copyWith(
        status: DownloadStatus.queued,
        progress: 0,
        speed: 0,
        eta: 0,
        errorCode: null,
        updatedAt: DateTime.now(),
        retryCount: 0,
      ),
    );
    await _persistJobs();
    await _log('download_retry_requested', {'id': id});
    unawaited(_processQueue());
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= jobs.length) return;
    if (newIndex < 0 || newIndex > jobs.length) return;
    if (newIndex > oldIndex) newIndex -= 1;
    final item = jobs.removeAt(oldIndex);
    jobs.insert(newIndex, item);
    await _persistJobs();
  }

  Future<void> _init() async {
    _jobsFile = await _resolveJobsFile();
    await _loadJobs();
    _recoverUnfinishedJobs();
    unawaited(_processQueue());
  }

  void _recoverUnfinishedJobs() {
    final now = DateTime.now();
    bool changed = false;
    for (var i = 0; i < jobs.length; i++) {
      final job = jobs[i];
      if (job.status == DownloadStatus.running ||
          job.status == DownloadStatus.queued) {
        jobs[i] = job.copyWith(
          status: DownloadStatus.queued,
          updatedAt: now,
          errorCode: 'resumed_after_restart',
        );
        changed = true;
      }
    }
    if (changed) {
      unawaited(_persistJobs());
    }
  }

  Future<void> _processQueue() async {
    if (_processing) return;
    _processing = true;

    try {
      while (true) {
        final index = jobs.indexWhere((j) => j.status == DownloadStatus.queued);
        if (index == -1) break;
        await _executeWithRetry(jobs[index].id);
      }
    } finally {
      _processing = false;
    }
  }

  Future<void> _executeWithRetry(int id) async {
    final original = _byId(id);
    if (original == null) return;

    int attempt = original.retryCount;
    while (attempt < _maxRetries) {
      final current = _byId(id);
      if (current == null) return;
      if (current.status == DownloadStatus.canceled ||
          current.status == DownloadStatus.paused) {
        _completeWaiter(id);
        return;
      }

      _updateJob(current.copyWith(
        status: DownloadStatus.running,
        updatedAt: DateTime.now(),
        retryCount: attempt,
      ));
      await _persistJobs();
      await _log('download_started', {'id': id, 'attempt': attempt});

      final result = await _downloadOnce(id);
      if (result.success) {
        _completeWaiter(id);
        return;
      }

      if (result.canceled || result.paused) {
        _completeWaiter(id);
        return;
      }

      attempt += 1;
      final retriable = result.retryable && attempt < _maxRetries;
      if (!retriable) {
        final failed = _byId(id);
        if (failed != null) {
          _updateJob(
            failed.copyWith(
              status: DownloadStatus.failed,
              updatedAt: DateTime.now(),
              errorCode: result.errorCode ?? 'download_failed',
              retryCount: attempt,
            ),
          );
          await _persistJobs();
          await _notificationService.showErrorNotification(
            id: id,
            title: 'Download Failed',
            errorMessage: 'Failed to download ${failed.fileName}',
          );
          await _log('download_failed', {
            'id': id,
            'error': result.errorCode ?? 'download_failed',
            'attempts': attempt,
          });
        }
        _completeWaiter(id);
        return;
      }

      final failed = _byId(id);
      if (failed != null) {
        _updateJob(
          failed.copyWith(
            status: DownloadStatus.queued,
            updatedAt: DateTime.now(),
            retryCount: attempt,
            errorCode: result.errorCode ?? 'retrying',
          ),
        );
        await _persistJobs();
      }

      final delay = Duration(seconds: pow(2, attempt - 1).toInt());
      await Future.delayed(delay);
    }
  }

  Future<_DownloadAttemptResult> _downloadOnce(int id) async {
    final job = _byId(id);
    if (job == null) {
      return const _DownloadAttemptResult(
        success: false,
        retryable: false,
        errorCode: 'missing_job',
      );
    }

    final filePath = await _storageService.resolveDownloadPath(job.fileName, job.type);
    final token = CancelToken();
    _cancelTokens[id] = token;

    int lastBytes = 0;
    var lastTick = DateTime.now();

    try {
      await _dio.download(
        job.url,
        filePath,
        cancelToken: token,
        onReceiveProgress: (received, total) async {
          final current = _byId(id);
          if (current == null || total <= 0) return;

          final now = DateTime.now();
          final elapsedMs = max(now.difference(lastTick).inMilliseconds, 1);
          final bytesDelta = max(received - lastBytes, 0);
          final speed = (bytesDelta * 1000) / elapsedMs;
          final remaining = max(total - received, 0);
          final eta = speed > 0 ? (remaining / speed).round() : 0;
          final progress = ((received / total) * 100).floor().clamp(0, 100);
          lastBytes = received;
          lastTick = now;

          _updateJob(
            current.copyWith(
              progress: progress,
              speed: speed,
              eta: eta,
              updatedAt: now,
            ),
          );

          if (progress == 0 || progress % 10 == 0) {
            await _notificationService.showProgressNotification(
              id: current.id,
              title: current.fileName,
              progress: progress,
              type: current.type,
            );
          }
        },
      );

      final current = _byId(id);
      if (current != null) {
        _updateJob(
          current.copyWith(
            status: DownloadStatus.success,
            filePath: filePath,
            progress: 100,
            eta: 0,
            updatedAt: DateTime.now(),
            errorCode: null,
          ),
        );
        await _persistJobs();
        await _notificationService.showCompletionNotification(
          id: current.id,
          title: 'Download Complete',
          fileName: current.fileName,
          type: current.type,
          imagePath: current.thumbnailUrl,
        );
        await _log('download_success', {'id': id});
      }
      return const _DownloadAttemptResult(success: true);
    } on DioException catch (e, stackTrace) {
      final current = _byId(id);
      if (e.type == DioExceptionType.cancel) {
        final paused = current?.status == DownloadStatus.paused;
        await _persistJobs();
        return _DownloadAttemptResult(
          success: false,
          retryable: false,
          canceled: !paused,
          paused: paused,
          errorCode: paused ? 'paused' : 'canceled',
        );
      }

      catchInfo(e, stackTrace);
      return _DownloadAttemptResult(
        success: false,
        retryable: _isRetryable(e),
        errorCode: _dioErrorCode(e),
      );
    } catch (e, stackTrace) {
      catchInfo(e, stackTrace);
      return const _DownloadAttemptResult(
        success: false,
        retryable: false,
        errorCode: 'unknown_error',
      );
    } finally {
      _cancelTokens.remove(id);
      await _persistJobs();
    }
  }

  bool _isRetryable(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return true;
    }

    if (e.type == DioExceptionType.badResponse) {
      final status = e.response?.statusCode ?? 0;
      return status >= 500 || status == 429;
    }
    return false;
  }

  String _dioErrorCode(DioException e) {
    if (e.type == DioExceptionType.badResponse) {
      return 'http_${e.response?.statusCode ?? 0}';
    }
    return e.type.name;
  }

  DownloadJob? _byId(int id) {
    final index = jobs.indexWhere((j) => j.id == id);
    if (index == -1) return null;
    return jobs[index];
  }

  void _updateJob(DownloadJob job) {
    final index = jobs.indexWhere((j) => j.id == job.id);
    if (index == -1) return;
    jobs[index] = job;
  }

  void _completeWaiter(int id) {
    final completer = _waiters.remove(id);
    if (completer == null || completer.isCompleted) return;
    final finalJob = _byId(id);
    if (finalJob != null) {
      completer.complete(finalJob);
    }
  }

  Future<File> _resolveJobsFile() async {
    final root = await getApplicationDocumentsDirectory();
    final file = File('${root.path}/download_jobs.json');
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('[]');
    }
    return file;
  }

  Future<void> _loadJobs() async {
    if (_jobsFile == null) return;
    try {
      final raw = await _jobsFile!.readAsString();
      if (raw.trim().isEmpty) {
        jobs.assignAll(const []);
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        jobs.assignAll(
          decoded
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .map(DownloadJob.fromJson)
              .toList(),
        );
      }
    } catch (_) {
      jobs.assignAll(const []);
    }
  }

  Future<void> _persistJobs() async {
    if (_jobsFile == null) return;
    final encoded = jsonEncode(jobs.map((j) => j.toJson()).toList());
    await _jobsFile!.writeAsString(encoded, flush: true);
  }

  int _generateId() {
    final base = DateTime.now().millisecondsSinceEpoch % 2147483647;
    final next = base + Random().nextInt(1000);
    return next % 2147483647;
  }

  Future<void> _log(String event, Map<String, dynamic> payload) async {
    if (Get.isRegistered<AnalyticsService>()) {
      await AnalyticsService.to.logEvent(event, payload: payload);
    }
  }
}

class _DownloadAttemptResult {
  const _DownloadAttemptResult({
    required this.success,
    this.retryable = false,
    this.canceled = false,
    this.paused = false,
    this.errorCode,
  });

  final bool success;
  final bool retryable;
  final bool canceled;
  final bool paused;
  final String? errorCode;
}


