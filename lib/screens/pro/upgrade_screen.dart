import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Pro'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unlock unlimited transfers and premium features.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _PlanCard(
              title: 'Monthly',
              price: 'INR 149',
              subtitle: '/ month',
              features: const [
                'Unlimited remote transfers',
                'No file size limit',
                '5 simultaneous devices',
                'Transfer history forever',
              ],
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _PlanCard(
              title: 'Annual',
              price: 'INR 999',
              subtitle: '/ year',
              badge: 'Save 44%',
              features: const [
                'Everything in Monthly',
                'Priority TURN servers',
                'Background transfers',
                'Folder transfer support',
              ],
              isPopular: true,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _PlanCard(
              title: 'Lifetime',
              price: 'INR 2,499',
              subtitle: 'one-time',
              features: const [
                'All Pro features forever',
                'No recurring payments',
                'Early access to v3.0',
              ],
              onTap: () {},
            ),
            const Spacer(),
            Center(
              child: Text(
                'Payments processed securely via Razorpay / Stripe.\nCancel anytime.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final String? badge;
  final List<String> features;
  final bool isPopular;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    this.badge,
    required this.features,
    this.isPopular = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        side: isPopular
            ? const BorderSide(color: AppTheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title, style: Theme.of(context).textTheme.displaySmall),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(price, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22)),
                  const SizedBox(width: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 12),
              ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppTheme.secondary),
                    const SizedBox(width: 8),
                    Text(f, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13)),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
