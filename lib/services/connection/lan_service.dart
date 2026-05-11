import 'dart:async';
import 'dart:io';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/constants.dart';
import '../../core/logger.dart';
import '../../models/connection_mode.dart';
import '../../models/peer_device.dart';
import 'connection_manager.dart';

class LanService {
  final _logger = AppLogger.instance;
  MDnsClient? _mdnsClient;
  WebSocketChannel? _wsChannel;
  Timer? _discoveryTimer;

  final _peersController = StreamController<List<PeerDevice>>.broadcast();
  Stream<List<PeerDevice>> get peersStream => _peersController.stream;

  Future<void> initialize() async {
    _logger.i('LanService initialized');
  }

  Future<void> startDiscovery() async {
    try {
      _mdnsClient = MDnsClient(rawDatagramSocketFactory: _socketFactory);
      await _mdnsClient!.start();

      _discoveryTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
        await _queryService();
      });
      await _queryService();
      _logger.i('LAN mDNS discovery started');
    } catch (e) {
      _logger.e('Failed to start mDNS discovery', e: e);
    }
  }

  Future<RawDatagramSocket> _socketFactory(
      dynamic host, int port, {bool? reuseAddress, bool? reusePort, int? ttl}) async {
    return RawDatagramSocket.bind(
      host ?? InternetAddress.anyIPv4,
      port,
      reuseAddress: reuseAddress ?? true,
      reusePort: reusePort ?? false,
      ttl: ttl ?? 255,
    );
  }

  Future<void> _queryService() async {
    if (_mdnsClient == null) return;
    final peers = <PeerDevice>[];
    await for (final ptr in _mdnsClient!.lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer(AppConstants.mdnsServiceType))) {
      await for (final srv in _mdnsClient!.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(ptr.domainName))) {
        await for (final ip in _mdnsClient!.lookup<IPAddressResourceRecord>(
            ResourceRecordQuery.addressIPv4(srv.target))) {
          peers.add(PeerDevice(
            id: '${srv.target}:${srv.port}',
            name: ptr.domainName.split('.').first,
            ipAddress: ip.address.address,
            connectionMode: ConnectionMode.lan,
            discoveredAt: DateTime.now(),
          ));
        }
      }
    }
    if (peers.isNotEmpty) {
      _peersController.add(peers);
    }
  }

  void stopDiscovery() {
    _discoveryTimer?.cancel();
    _mdnsClient?.stop();
    _mdnsClient = null;
    _logger.i('LAN mDNS discovery stopped');
  }

  Future<ConnectionResult> connect(PeerDevice peer) async {
    try {
      final ip = peer.ipAddress;
      if (ip == null) {
        return const ConnectionResult(success: false, error: 'No IP address', mode: ConnectionMode.lan);
      }
      final wsUrl = 'ws://$ip:${AppConstants.lanWebSocketPort}';
      _wsChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      await _wsChannel!.ready;
      _logger.i('LAN WebSocket connected to $ip');
      return const ConnectionResult(success: true, mode: ConnectionMode.lan);
    } catch (e) {
      _logger.e('LAN connect failed', e: e);
      return ConnectionResult(success: false, error: e.toString(), mode: ConnectionMode.lan);
    }
  }

  Future<void> disconnect() async {
    await _wsChannel?.sink.close();
    _wsChannel = null;
  }

  void sendData(dynamic data) {
    if (_wsChannel != null) {
      _wsChannel!.sink.add(data);
    }
  }

  Stream<dynamic> get dataStream => _wsChannel?.stream ?? const Stream.empty();
}
