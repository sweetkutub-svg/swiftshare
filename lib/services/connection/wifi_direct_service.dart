import 'dart:async';
import '../../core/logger.dart';
import '../../models/connection_mode.dart';
import '../../models/peer_device.dart';
import 'connection_manager.dart';

class WifiDirectService {
  final _logger = AppLogger.instance;
  final _peersController = StreamController<List<PeerDevice>>.broadcast();
  Stream<List<PeerDevice>> get peersStream => _peersController.stream;

  Future<void> initialize() async {
    _logger.i('WifiDirectService initialized');
  }

  Future<void> startDiscovery() async {
    _logger.i('WiFi Direct discovery started (platform channel required)');
  }

  void stopDiscovery() {
    _logger.i('WiFi Direct discovery stopped');
  }

  Future<ConnectionResult> connect(PeerDevice peer) async {
    _logger.i('WiFi Direct connect to ${peer.name}');
    return const ConnectionResult(
      success: false,
      error: 'WiFi Direct requires native platform implementation.',
      mode: ConnectionMode.wifiDirect,
    );
  }

  Future<void> disconnect() async {
    _logger.i('WiFi Direct disconnected');
  }
}
