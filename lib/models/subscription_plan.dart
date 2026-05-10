enum SubscriptionPlan {
  free('Free', 0),
  pro('Pro', 1),
  team('Team', 2);

  final String label;
  final int tier;
  const SubscriptionPlan(this.label, this.tier);

  bool get isFree => this == SubscriptionPlan.free;
  bool get isPro => this == SubscriptionPlan.pro || this == SubscriptionPlan.team;
  bool get isTeam => this == SubscriptionPlan.team;
}
