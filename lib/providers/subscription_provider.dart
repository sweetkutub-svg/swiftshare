import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_plan.dart';
import '../services/monetization/subscription_service.dart';

final subscriptionProvider = StreamProvider<SubscriptionPlan>((ref) {
  return SubscriptionService.instance.planStream;
});

final currentPlanProvider = Provider<SubscriptionPlan>((ref) {
  return SubscriptionService.instance.currentPlan;
});
