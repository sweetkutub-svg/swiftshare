import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/monetization/quota_manager.dart';

final quotaProvider = StreamProvider<QuotaState>((ref) {
  return QuotaManager.instance.stream;
});

final quotaStateProvider = Provider<QuotaState>((ref) {
  return QuotaManager.instance.state;
});
