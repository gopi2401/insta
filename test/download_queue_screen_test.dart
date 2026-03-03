import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:insta/models/download_job.dart';
import 'package:insta/screens/download_queue_screen.dart';
import 'package:insta/services/download_queue_service.dart';
import 'package:insta/services/notification_service.dart';

class _FakeDownloadQueueService extends DownloadQueueService {
  @override
  void onInit() {
    super.onInit();
    jobs.assignAll([
      DownloadJob(
        id: 1,
        url: 'https://example.com/v.mp4',
        fileName: 'video.mp4',
        type: DownloadType.youtube,
        status: DownloadStatus.queued,
        progress: 0,
        speed: 0,
        eta: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);
  }
}

class _FakeNotificationService extends NotificationService {}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<DownloadQueueService>(_FakeDownloadQueueService());
    Get.put<NotificationService>(_FakeNotificationService());
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
  });

  testWidgets('renders downloads screen with queued item', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: DownloadQueueScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Downloads'), findsOneWidget);
    expect(find.text('video.mp4'), findsOneWidget);
  });
}
