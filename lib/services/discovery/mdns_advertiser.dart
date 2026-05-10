import 'dart:convert';
import 'dart:io';
import '../../core/constants.dart';
import '../../core/logger.dart';

class MDnsAdvertiser {
  final _logger = AppLogger.instance;
  RawDatagramSocket? _socket;
  Timer? _advertiseTimer;

  Future<void> startAdvertising(String deviceName) async {
    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _advertiseTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        _sendAdvertisement(deviceName);
      });
      _sendAdvertisement(deviceName);
      _logger.i('mDNS advertising started: $deviceName');
    } catch (e) {
      _logger.e('mDNS advertise failed', e: e);
    }
  }

  void _sendAdvertisement(String deviceName) {
    final packet = _buildMdnsPacket(deviceName);
    _socket?.send(packet, InternetAddress('224.0.0.251'), 5353);
  }

  List<int> _buildMdnsPacket(String name) {
    return utf8.encode('$name.${AppConstants.mdnsServiceType}');
  }

  void stopAdvertising() {
    _advertiseTimer?.cancel();
    _socket?.close();
    _logger.i('mDNS advertising stopped');
  }
}
