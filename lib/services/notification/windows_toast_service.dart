import '../../core/logger.dart';

class WindowsToastService {
  WindowsToastService._();
  static final WindowsToastService _instance = WindowsToastService._();
  static WindowsToastService get instance => _instance;

  final _logger = AppLogger.instance;

  Future<void> initialize() async {
    _logger.i('WindowsToastService initialized');
  }

  Future<void> showIncomingTransfer({
    required String senderName,
    required int fileCount,
    required String totalSize,
  }) async {
    _logger.i('Toast: Incoming transfer from $senderName ($fileCount files, $totalSize)');
  }

  Future<void> showTransferComplete({required String fileName}) async {
    _logger.i('Toast: Transfer complete - $fileName');
  }

  Future<void> showTransferDeclined() async {
    _logger.i('Toast: Transfer declined');
  }
}
