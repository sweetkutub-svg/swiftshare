import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../../core/logger.dart';
import '../../models/transfer_file.dart';
import '../../models/transfer_session.dart';
import '../../models/transfer_status.dart';
import '../connection/connection_manager.dart';
import 'integrity_checker.dart';

class ReceiverService {
  final _logger = AppLogger.instance;

  TransferSession? _currentSession;
  final List<Uint8List> _receivedChunks = [];
  int _bytesReceived = 0;

  final _sessionController = StreamController<TransferSession>.broadcast();
  Stream<TransferSession> get sessionStream => _sessionController.stream;

  Future<void> acceptTransfer(TransferSession session) async {
    _currentSession = session.copyWith(status: TransferStatus.active);
    _sessionController.add(_currentSession!);
    _logger.i('Transfer accepted: ${session.id}');
  }

  void onChunkReceived(Uint8List chunk) {
    _receivedChunks.add(chunk);
    _bytesReceived += chunk.length;
    if (_currentSession != null) {
      final elapsedSec = DateTime.now().difference(_currentSession!.startedAt).inSeconds;
      final speed = elapsedSec > 0 ? (_bytesReceived / elapsedSec / 1024 / 1024) : 0.0;
      _currentSession = _currentSession!.copyWith(
        bytesTransferred: _bytesReceived,
        speedMBps: speed,
      );
      _sessionController.add(_currentSession!);
    }
  }

  Future<void> finalizeFile(String name, int expectedSize, String expectedHash) async {
    try {
      final buffer = Uint8List(expectedSize);
      int offset = 0;
      for (final chunk in _receivedChunks) {
        buffer.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }
      _receivedChunks.clear();

      final computedHash = IntegrityChecker.computeHash(buffer);
      if (computedHash != expectedHash) {
        throw Exception('Integrity check failed');
      }

      final dir = await getDownloadsDirectory();
      final saveDir = dir ?? Directory.systemTemp;
      final filePath = '${saveDir.path}${Platform.pathSeparator}$name';
      final file = File(filePath);
      await file.writeAsBytes(buffer);

      _logger.i('File saved: $filePath');
    } catch (e, st) {
      _logger.e('Finalize file failed', e: e, s: st);
    }
  }

  void declineTransfer() {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(status: TransferStatus.declined);
      _sessionController.add(_currentSession!);
    }
    _receivedChunks.clear();
    _bytesReceived = 0;
  }

  void reset() {
    _currentSession = null;
    _receivedChunks.clear();
    _bytesReceived = 0;
  }

  void dispose() {
    _sessionController.close();
  }
}
