import '../../core/logger.dart';

class MobileNotificationService {
  MobileNotificationService._();
  static final MobileNotificationService _instance = MobileNotificationService._();
  static MobileNotificationService get instance => _instance;

  final _logger = AppLogger.instance;

  Future<void> initialize() async {
    _logger.i('MobileNotificationService initialized');
  }

  Future<void> showTransferProgress({
    required String fileName,
    required int progressPercent,
  }) async {
    _logger.i('Notification: $fileName at $progressPercent%');
  }

  Future<void> showTransferComplete({required String fileName}) async {
    _logger.i('Notification: Transfer complete - $fileName');
  }

  Future<void> cancelAll() async {
    _logger.i('All notifications cancelled');
  }
}
