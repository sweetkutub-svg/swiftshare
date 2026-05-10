import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/logger.dart';
import '../../models/subscription_plan.dart';

class SubscriptionService {
  SubscriptionService._();
  static final SubscriptionService _instance = SubscriptionService._();
  static SubscriptionService get instance => _instance;

  final _logger = AppLogger.instance;
  final _storage = const FlutterSecureStorage();
  final _planController = StreamController<SubscriptionPlan>.broadcast();

  SubscriptionPlan _currentPlan = SubscriptionPlan.free;

  SubscriptionPlan get currentPlan => _currentPlan;
  Stream<SubscriptionPlan> get planStream => _planController.stream;

  Future<void> initialize() async {
    final stored = await _storage.read(key: 'subscription_plan');
    if (stored != null) {
      _currentPlan = SubscriptionPlan.values.firstWhere(
        (p) => p.name == stored,
        orElse: () => SubscriptionPlan.free,
      );
    }
    _logger.i('SubscriptionService initialized: ${_currentPlan.name}');
  }

  Future<void> upgradeToPro() async {
    _currentPlan = SubscriptionPlan.pro;
    await _storage.write(key: 'subscription_plan', value: _currentPlan.name);
    _planController.add(_currentPlan);
    _logger.i('Upgraded to Pro');
  }

  Future<void> downgradeToFree() async {
    _currentPlan = SubscriptionPlan.free;
    await _storage.write(key: 'subscription_plan', value: _currentPlan.name);
    _planController.add(_currentPlan);
    _logger.i('Downgraded to Free');
  }

  Future<void> restorePurchase() async {
    _logger.i('Purchase restoration requested');
  }
}
