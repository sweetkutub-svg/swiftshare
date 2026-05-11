import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/logger.dart';

class RadioStatus {
  final bool wifiEnabled;
  final bool bluetoothEnabled;
  final bool hasInternet;

  const RadioStatus({
    required this.wifiEnabled,
    required this.bluetoothEnabled,
    required this.hasInternet,
  });
}

class RadioManager {
  RadioManager._();
  static final RadioManager _instance = RadioManager._();
  static RadioManager get instance => _instance;

  final _logger = AppLogger.instance;
  final _connectivity = Connectivity();

  final _statusController = StreamController<RadioStatus>.broadcast();
  Stream<RadioStatus> get statusStream => _statusController.stream;

  RadioStatus _currentStatus = const RadioStatus(
    wifiEnabled: false,
    bluetoothEnabled: false,
    hasInternet: false,
  );
  RadioStatus get currentStatus => _currentStatus;

  Future<void> initialize() async {
    _connectivity.onConnectivityChanged.listen((results) {
      _updateFromConnectivity(results);
    });
    final results = await _connectivity.checkConnectivity();
    _updateFromConnectivity(results);
    _logger.i('RadioManager initialized: wifi=${_currentStatus.wifiEnabled}, internet=${_currentStatus.hasInternet}');
  }

  void _updateFromConnectivity(List<ConnectivityResult> results) {
    final hasWifi = results.contains(ConnectivityResult.wifi);
    final hasInternet = results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);

    _currentStatus = RadioStatus(
      wifiEnabled: hasWifi,
      bluetoothEnabled: _currentStatus.bluetoothEnabled,
      hasInternet: hasInternet,
    );
    _statusController.add(_currentStatus);
  }

  Future<bool> enableWiFi() async {
    _logger.i('Enable WiFi requested (platform-specific implementation required)');
    return false;
  }

  Future<bool> enableBluetooth() async {
    _logger.i('Enable Bluetooth requested (platform-specific implementation required)');
    return false;
  }
}
