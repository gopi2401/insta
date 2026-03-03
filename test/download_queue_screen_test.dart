import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:insta/core/services/notification_service.dart';
import 'package:insta/features/downloader/download_job_model.dart';
import 'package:insta/features/downloader/download_queue_controller.dart';
import 'package:insta/features/downloader/download_queue_page.dart';

class _FakeDownloadQueueService extends DownloadQueueService {
  _FakeDownloadQueueService(this.initialJobs);

  final List<DownloadJob> initialJobs;
  final List<int> pausedIds = <int>[];
  final List<int> resumedIds = <int>[];
  final List<int> canceledIds = <int>[];
  final List<int> retriedIds = <int>[];

  @override
  void onInit() {
    super.onInit();
    jobs.assignAll(initialJobs);
  }

  @override
  Future<void> pause(int id) async {
    pausedIds.add(id);
  }

  @override
  Future<void> resume(int id) async {
    resumedIds.add(id);
  }

  @override
  Future<void> cancel(int id) async {
    canceledIds.add(id);
  }

  @override
  Future<void> retry(int id) async {
    retriedIds.add(id);
  }
}

class _FakeNotificationService extends NotificationService {}

DownloadJob _job({
  required int id,
  required String fileName,
  required DownloadStatus status,
  DownloadType type = DownloadType.youtube,
  int progress = 0,
  String? filePath,
}) {
  final now = DateTime.now();
  return DownloadJob(
    id: id,
    url: 'https://example.com/$fileName',
    fileName: fileName,
    type: type,
    status: status,
    progress: progress,
    speed: 0,
    eta: 0,
    createdAt: now,
    updatedAt: now,
    filePath: filePath,
  );
}

Future<void> _pumpDownloadsScreen(
  WidgetTester tester, {
  required _FakeDownloadQueueService queueService,
}) async {
  Get.testMode = true;
  Get.put<DownloadQueueService>(queueService);
  Get.put<NotificationService>(_FakeNotificationService());
  await tester.pumpWidget(const GetMaterialApp(home: DownloadQueueScreen()));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() async {
    await Get.deleteAll(force: true);
  });

  testWidgets('shows no downloads message when queue is empty', (tester) async {
    await _pumpDownloadsScreen(
      tester,
      queueService: _FakeDownloadQueueService(const []),
    );

    expect(find.text('Downloads'), findsOneWidget);
    expect(find.text('No downloads yet'), findsOneWidget);
    expect(find.text('Diagnostics'), findsNothing);
  });

  testWidgets('shows active and terminal jobs in merged list', (tester) async {
    await _pumpDownloadsScreen(
      tester,
      queueService: _FakeDownloadQueueService([
        _job(
          id: 1,
          fileName: 'queued.mp4',
          status: DownloadStatus.queued,
          progress: 20,
        ),
        _job(
          id: 2,
          fileName: 'done.mp4',
          status: DownloadStatus.success,
          filePath: 'done.mp4',
        ),
        _job(id: 3, fileName: 'failed.mp4', status: DownloadStatus.failed),
        _job(id: 4, fileName: 'canceled.mp4', status: DownloadStatus.canceled),
      ]),
    );

    expect(find.text('queued.mp4'), findsOneWidget);
    expect(find.text('done.mp4'), findsOneWidget);
    expect(find.text('failed.mp4'), findsOneWidget);
    expect(find.text('canceled.mp4'), findsOneWidget);
  });

  testWidgets('search filters across file, type and status', (tester) async {
    await _pumpDownloadsScreen(
      tester,
      queueService: _FakeDownloadQueueService([
        _job(
          id: 1,
          fileName: 'holiday.mp4',
          status: DownloadStatus.success,
          filePath: 'holiday.mp4',
        ),
        _job(id: 2, fileName: 'meeting.mp4', status: DownloadStatus.failed),
      ]),
    );

    await tester.enterText(find.byType(TextField), 'failed');
    await tester.pumpAndSettle();

    expect(find.text('meeting.mp4'), findsOneWidget);
    expect(find.text('holiday.mp4'), findsNothing);
    expect(find.text('No matching downloads'), findsNothing);
  });

  testWidgets('failed job shows retry action and triggers retry', (
    tester,
  ) async {
    final queueService = _FakeDownloadQueueService([
      _job(id: 11, fileName: 'bad.mp4', status: DownloadStatus.failed),
    ]);
    await _pumpDownloadsScreen(tester, queueService: queueService);

    await tester.tap(find.byTooltip('Retry'));
    await tester.pump();

    expect(queueService.retriedIds, equals(<int>[11]));
  });

  testWidgets('successful video shows share and play actions', (tester) async {
    await _pumpDownloadsScreen(
      tester,
      queueService: _FakeDownloadQueueService([
        _job(
          id: 12,
          fileName: 'clip.mp4',
          status: DownloadStatus.success,
          filePath: 'clip.mp4',
        ),
      ]),
    );

    expect(find.byTooltip('Share'), findsOneWidget);
    expect(find.byTooltip('Play'), findsOneWidget);
  });
}
