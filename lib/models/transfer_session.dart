import 'transfer_file.dart';
import 'transfer_status.dart';
import 'connection_mode.dart';
import 'peer_device.dart';

class TransferSession {
  final String id;
  final PeerDevice? peer;
  final List<TransferFile> files;
  final TransferStatus status;
  final ConnectionMode mode;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int bytesTransferred;
  final int? totalBytes;
  final double? speedMBps;
  final String? errorMessage;
  final String? pinHash;

  const TransferSession({
    required this.id,
    this.peer,
    required this.files,
    this.status = TransferStatus.pending,
    required this.mode,
    required this.startedAt,
    this.completedAt,
    this.bytesTransferred = 0,
    this.totalBytes,
    this.speedMBps,
    this.errorMessage,
    this.pinHash,
  });

  int get fileCount => files.length;

  int get totalSize => totalBytes ?? files.fold<int>(0, (sum, f) => sum + f.size);

  double get progress {
    if (totalSize == 0) return 0.0;
    return (bytesTransferred / totalSize).clamp(0.0, 1.0);
  }

  String? get currentFileName {
    if (files.isEmpty) return null;
    final idx = ((files.length * progress).floor()).clamp(0, files.length - 1);
    return files[idx].name;
  }

  TransferSession copyWith({
    String? id,
    PeerDevice? peer,
    List<TransferFile>? files,
    TransferStatus? status,
    ConnectionMode? mode,
    DateTime? startedAt,
    DateTime? completedAt,
    int? bytesTransferred,
    int? totalBytes,
    double? speedMBps,
    String? errorMessage,
    String? pinHash,
  }) {
    return TransferSession(
      id: id ?? this.id,
      peer: peer ?? this.peer,
      files: files ?? this.files,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      bytesTransferred: bytesTransferred ?? this.bytesTransferred,
      totalBytes: totalBytes ?? this.totalBytes,
      speedMBps: speedMBps ?? this.speedMBps,
      errorMessage: errorMessage ?? this.errorMessage,
      pinHash: pinHash ?? this.pinHash,
    );
  }
}
