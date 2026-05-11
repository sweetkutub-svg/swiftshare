import '../../core/logger.dart';
import '../../core/constants.dart';

class AdService {
  AdService._();
  static final AdService _instance = AdService._();
  static AdService get instance => _instance;

  final _logger = AppLogger.instance;
  bool _initialized = false;

  Future<void> initialize() async {
    _initialized = true;
    _logger.i('AdService initialized');
  }

  Future<bool> isRewardedAdAvailable() async {
    return _initialized;
  }

  Future<bool> showRewardedAd() async {
    _logger.i('Rewarded ad displayed');
    return true;
  }

  void dispose() {
    _initialized = false;
  }
}
