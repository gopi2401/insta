import 'package:flutter_test/flutter_test.dart';
import 'package:insta/models/download_job.dart';
import 'package:insta/services/notification_service.dart';

void main() {
  test('DownloadJob serializes and deserializes', () {
    final now = DateTime.now();
    final job = DownloadJob(
      id: 1001,
      url: 'https://example.com/v.mp4',
      fileName: 'v.mp4',
      type: DownloadType.youtube,
      status: DownloadStatus.queued,
      progress: 10,
      speed: 1024,
      eta: 12,
      createdAt: now,
      updatedAt: now,
      errorCode: null,
      filePath: null,
      thumbnailUrl: null,
      retryCount: 1,
    );

    final decoded = DownloadJob.fromJson(job.toJson());
    expect(decoded.id, equals(job.id));
    expect(decoded.url, equals(job.url));
    expect(decoded.type, equals(DownloadType.youtube));
    expect(decoded.status, equals(DownloadStatus.queued));
    expect(decoded.retryCount, equals(1));
  });
}
