import 'dart:async';
import '../../core/logger.dart';
import '../../models/connection_mode.dart';
import '../../models/peer_device.dart';
import 'lan_service.dart';
import 'wifi_direct_service.dart';
import 'hotspot_service.dart';
import 'webrtc_service.dart';

class ConnectionManager {
  ConnectionManager._();
  static final ConnectionManager _instance = ConnectionManager._();
  static ConnectionManager get instance => _instance;

  final _logger = AppLogger.instance;
  final _peersController = StreamController<List<PeerDevice>>.broadcast();
  Stream<List<PeerDevice>> get peersStream => _peersController.stream;

  final List<PeerDevice> _peers = [];
  ConnectionMode _currentMode = ConnectionMode.lan;

  ConnectionMode get currentMode => _currentMode;

  final _lanService = LanService();
  final _wifiDirectService = WifiDirectService();
  final _hotspotService = HotspotService();
  final _webrtcService = WebRTCService();

  bool _scanning = false;

  Future<void> initialize() async {
    _logger.i('ConnectionManager initializing...');
    await _lanService.initialize();
    await _webrtcService.initialize();
  }

  Future<void> startDiscovery() async {
    if (_scanning) return;
    _scanning = true;
    _logger.i('Starting peer discovery...');

    _lanService.peersStream.listen((peers) {
      _mergePeers(peers, ConnectionMode.lan);
    });
    _wifiDirectService.peersStream.listen((peers) {
      _mergePeers(peers, ConnectionMode.wifiDirect);
    });

    await _lanService.startDiscovery();
    await _wifiDirectService.startDiscovery();
  }

  void stopDiscovery() {
    _scanning = false;
    _lanService.stopDiscovery();
    _wifiDirectService.stopDiscovery();
    _logger.i('Peer discovery stopped.');
  }

  void _mergePeers(List<PeerDevice> newPeers, ConnectionMode mode) {
    final now = DateTime.now();
    for (final peer in newPeers) {
      final idx = _peers.indexWhere((p) => p.id == peer.id);
      if (idx >= 0) {
        _peers[idx] = peer.copyWith(discoveredAt: now);
      } else {
        _peers.add(peer);
      }
    }
    _peersController.add(List.unmodifiable(_peers));
  }

  Future<ConnectionResult> connectToPeer(PeerDevice peer) async {
    _logger.i('Connecting to peer: ${peer.name} via ${peer.connectionMode.label}');
    _currentMode = peer.connectionMode;

    switch (peer.connectionMode) {
      case ConnectionMode.lan:
        return _lanService.connect(peer);
      case ConnectionMode.wifiDirect:
        return _wifiDirectService.connect(peer);
      case ConnectionMode.remote:
        return _webrtcService.connect(peer);
    }
  }

  Future<void> disconnect() async {
    await _lanService.disconnect();
    await _wifiDirectService.disconnect();
    await _webrtcService.disconnect();
    _currentMode = ConnectionMode.lan;
  }

  void dispose() {
    stopDiscovery();
    _peersController.close();
  }
}

class ConnectionResult {
  final bool success;
  final String? error;
  final ConnectionMode mode;

  const ConnectionResult({
    required this.success,
    this.error,
    required this.mode,
  });
}
