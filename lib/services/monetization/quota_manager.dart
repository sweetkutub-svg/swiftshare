import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants.dart';
import '../../core/logger.dart';
import 'subscription_service.dart';

class QuotaManager {
  QuotaManager._();
  static final QuotaManager _instance = QuotaManager._();
  static QuotaManager get instance => _instance;

  final _logger = AppLogger.instance;
  final _storage = const FlutterSecureStorage();
  final _quotaController = StreamController<QuotaState>.broadcast();

  Stream<QuotaState> get stream => _quotaController.stream;

  QuotaState _state = const QuotaState(
    usedMB: 0,
    limitMB: AppConstants.freeDailyRemoteQuotaMB,
    adsWatchedToday: 0,
  );

  QuotaState get state => _state;

  Future<void> initialize() async {
    final used = await _storage.read(key: 'quota_used_mb');
    final ads = await _storage.read(key: 'quota_ads_today');
    final lastDate = await _storage.read(key: 'quota_last_date');
    final today = _todayKey;

    if (lastDate != today) {
      await _resetDaily();
    } else {
      _state = QuotaState(
        usedMB: int.tryParse(used ?? '0') ?? 0,
        limitMB: _calculateLimit(),
        adsWatchedToday: int.tryParse(ads ?? '0') ?? 0,
      );
    }
    _quotaController.add(_state);
    _logger.i('QuotaManager initialized: ${_state.usedMB}/${_state.limitMB} MB');
  }

  Future<void> recordUsage(int mb) async {
    final newUsed = _state.usedMB + mb;
    _state = _state.copyWith(usedMB: newUsed);
    await _storage.write(key: 'quota_used_mb', value: newUsed.toString());
    await _storage.write(key: 'quota_last_date', value: _todayKey);
    _quotaController.add(_state);
  }

  Future<void> addAdReward() async {
    if (_state.adsWatchedToday >= AppConstants.maxRewardedAdsPerDay) return;
    final newAds = _state.adsWatchedToday + 1;
    final newLimit = _state.limitMB + AppConstants.adRewardQuotaMB;
    _state = _state.copyWith(adsWatchedToday: newAds, limitMB: newLimit);
    await _storage.write(key: 'quota_ads_today', value: newAds.toString());
    await _storage.write(key: 'quota_used_mb', value: _state.usedMB.toString());
    _quotaController.add(_state);
  }

  Future<void> _resetDaily() async {
    final limit = _calculateLimit();
    _state = QuotaState(usedMB: 0, limitMB: limit, adsWatchedToday: 0);
    await _storage.write(key: 'quota_used_mb', value: '0');
    await _storage.write(key: 'quota_ads_today', value: '0');
    await _storage.write(key: 'quota_last_date', value: _todayKey);
  }

  int _calculateLimit() {
    final sub = SubscriptionService.instance.currentPlan;
    if (sub.isPro) return 1024 * 1024;
    return AppConstants.freeDailyRemoteQuotaMB;
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  void dispose() {
    _quotaController.close();
  }
}

class QuotaState {
  final int usedMB;
  final int limitMB;
  final int adsWatchedToday;

  const QuotaState({
    required this.usedMB,
    required this.limitMB,
    required this.adsWatchedToday,
  });

  double get percentUsed => limitMB > 0 ? (usedMB / limitMB).clamp(0.0, 1.0) : 0.0;
  bool get isExceeded => usedMB >= limitMB;
  int get remainingMB => (limitMB - usedMB).clamp(0, limitMB);

  QuotaState copyWith({int? usedMB, int? limitMB, int? adsWatchedToday}) {
    return QuotaState(
      usedMB: usedMB ?? this.usedMB,
      limitMB: limitMB ?? this.limitMB,
      adsWatchedToday: adsWatchedToday ?? this.adsWatchedToday,
    );
  }
}
