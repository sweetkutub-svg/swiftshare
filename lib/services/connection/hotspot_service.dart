import '../../core/logger.dart';

class HotspotService {
  final _logger = AppLogger.instance;

  Future<void> initialize() async {
    _logger.i('HotspotService initialized');
  }

  Future<bool> createHotspot() async {
    _logger.i('Hotspot creation requested (platform channel required)');
    return false;
  }

  Future<Map<String, String>?> getHotspotCredentials() async {
    _logger.i('Hotspot credentials requested');
    return null;
  }
}
