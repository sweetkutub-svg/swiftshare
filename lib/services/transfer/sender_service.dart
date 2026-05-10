import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import '../../core/constants.dart';
import '../../core/logger.dart';
import '../../models/peer_device.dart';
import '../../models/transfer_file.dart';
import '../../models/transfer_session.dart';
import '../../models/transfer_status.dart';
import '../../models/connection_mode.dart';
import '../connection/connection_manager.dart';
import '../connection/webrtc_service.dart';
import 'chunk_manager.dart';
import 'integrity_checker.dart';

class SenderService {
  final _logger = AppLogger.instance;
  final _connection = ConnectionManager.instance;
  final _chunkManager = ChunkManager();

  TransferSession? _currentSession;
  Timer? _progressTimer;

  final _sessionController = StreamController<TransferSession>.broadcast();
  Stream<TransferSession> get sessionStream => _sessionController.stream;

  Future<TransferSession?> sendFiles({
    required PeerDevice peer,
    required List<TransferFile> files,
  }) async {
    try {
      final result = await _connection.connectToPeer(peer);
      if (!result.success) {
        _logger.e('Connection failed: ${result.error}');
        return null;
      }

      final totalBytes = files.fold<int>(0, (s, f) => s + f.size);
      _currentSession = TransferSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        peer: peer,
        files: files,
        status: TransferStatus.connecting,
        mode: peer.connectionMode,
        startedAt: DateTime.now(),
        totalBytes: totalBytes,
      );
      _sessionController.add(_currentSession!);

      _currentSession = _currentSession!.copyWith(status: TransferStatus.active);
      _sessionController.add(_currentSession!);

      await _transferFiles(peer.connectionMode, files);

      return _currentSession;
    } catch (e, st) {
      _logger.e('Send failed', e: e, s: st);
      return null;
    }
  }

  Future<void> _transferFiles(ConnectionMode mode, List<TransferFile> files) async {
    int bytesTransferred = 0;
    final startTime = DateTime.now();

    for (final file in files) {
      final fileData = await File(file.path).readAsBytes();
      final hash = IntegrityChecker.computeHash(fileData);
      _logger.d('Sending ${file.name} | size: ${file.size} | hash: $hash');

      if (mode == ConnectionMode.remote) {
        await _sendOverWebRTC(file, fileData);
      }

      bytesTransferred += file.size;
      final elapsedSec = DateTime.now().difference(startTime).inSeconds;
      final speed = elapsedSec > 0 ? (bytesTransferred / elapsedSec / 1024 / 1024) : 0.0;

      _currentSession = _currentSession!.copyWith(
        bytesTransferred: bytesTransferred,
        speedMBps: speed,
      );
      _sessionController.add(_currentSession!);
    }

    _currentSession = _currentSession!.copyWith(
      status: TransferStatus.completed,
      completedAt: DateTime.now(),
    );
    _sessionController.add(_currentSession!);
    _logger.i('All files sent successfully');
  }

  Future<void> _sendOverWebRTC(TransferFile file, Uint8List data) async {
    final webrtc = WebRTCService();
    final chunks = _chunkManager.split(data, AppConstants.chunkSizeBytes);

    final meta = {
      'type': 'metadata',
      'payload': {
        'name': file.name,
        'size': file.size,
        'type': file.mimeType,
      },
    };
    await webrtc.send(meta.toString());

    for (final chunk in chunks) {
      await webrtc.sendBinary(chunk);
    }

    await webrtc.send('{"type":"done"}');
  }

  void cancel() {
    _progressTimer?.cancel();
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(status: TransferStatus.cancelled);
      _sessionController.add(_currentSession!);
    }
  }

  void dispose() {
    _sessionController.close();
  }
}
