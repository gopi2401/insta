import '../services/notification_service.dart';

enum DownloadStatus {
  queued,
  running,
  paused,
  success,
  failed,
  canceled,
}

class DownloadJob {
  static const Object _noChange = Object();

  DownloadJob({
    required this.id,
    required this.url,
    required this.fileName,
    required this.type,
    required this.status,
    required this.progress,
    required this.speed,
    required this.eta,
    required this.createdAt,
    required this.updatedAt,
    this.errorCode,
    this.filePath,
    this.thumbnailUrl,
    this.retryCount = 0,
  });

  final int id;
  final String url;
  final String fileName;
  final DownloadType type;
  final DownloadStatus status;
  final int progress;
  final double speed;
  final int eta;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? errorCode;
  final String? filePath;
  final String? thumbnailUrl;
  final int retryCount;

  DownloadJob copyWith({
    int? id,
    String? url,
    String? fileName,
    DownloadType? type,
    DownloadStatus? status,
    int? progress,
    double? speed,
    int? eta,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? errorCode = _noChange,
    Object? filePath = _noChange,
    Object? thumbnailUrl = _noChange,
    int? retryCount,
  }) {
    return DownloadJob(
      id: id ?? this.id,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      type: type ?? this.type,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      speed: speed ?? this.speed,
      eta: eta ?? this.eta,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      errorCode:
          identical(errorCode, _noChange) ? this.errorCode : errorCode as String?,
      filePath: identical(filePath, _noChange) ? this.filePath : filePath as String?,
      thumbnailUrl: identical(thumbnailUrl, _noChange)
          ? this.thumbnailUrl
          : thumbnailUrl as String?,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'fileName': fileName,
      'type': type.name,
      'status': status.name,
      'progress': progress,
      'speed': speed,
      'eta': eta,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'errorCode': errorCode,
      'filePath': filePath,
      'thumbnailUrl': thumbnailUrl,
      'retryCount': retryCount,
    };
  }

  factory DownloadJob.fromJson(Map<String, dynamic> json) {
    return DownloadJob(
      id: json['id'] as int,
      url: json['url'] as String,
      fileName: json['fileName'] as String,
      type: DownloadType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DownloadType.other,
      ),
      status: DownloadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DownloadStatus.queued,
      ),
      progress: (json['progress'] ?? 0) as int,
      speed: ((json['speed'] ?? 0.0) as num).toDouble(),
      eta: (json['eta'] ?? 0) as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      errorCode: json['errorCode'] as String?,
      filePath: json['filePath'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      retryCount: (json['retryCount'] ?? 0) as int,
    );
  }
}
