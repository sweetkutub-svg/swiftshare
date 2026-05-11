import 'dart:async';
import 'package:multicast_dns/multicast_dns.dart';
import '../../core/constants.dart';
import '../../core/logger.dart';
import '../../models/connection_mode.dart';
import '../../models/peer_device.dart';

class MDnsScanner {
  final _logger = AppLogger.instance;
  MDnsClient? _client;
  Timer? _scanTimer;

  final _peersController = StreamController<List<PeerDevice>>.broadcast();
  Stream<List<PeerDevice>> get peersStream => _peersController.stream;

  Future<void> startScan() async {
    try {
      _client = MDnsClient();
      await _client!.start();

      _scanTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
        await _queryPeers();
      });
      await _queryPeers();
      _logger.i('mDNS scanner started');
    } catch (e) {
      _logger.e('mDNS scan failed', e: e);
    }
  }

  Future<void> _queryPeers() async {
    if (_client == null) return;
    final peers = <PeerDevice>[];

    await for (final ptr in _client!.lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer(AppConstants.mdnsServiceType))) {
      final domain = ptr.domainName;
      await for (final srv in _client!.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(domain))) {
        await for (final ip in _client!.lookup<IPAddressResourceRecord>(
            ResourceRecordQuery.addressIPv4(srv.target))) {
          peers.add(PeerDevice(
            id: '${srv.target}:${srv.port}',
            name: domain.split('.').first,
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

  void stopScan() {
    _scanTimer?.cancel();
    _client?.stop();
    _logger.i('mDNS scanner stopped');
  }
}
