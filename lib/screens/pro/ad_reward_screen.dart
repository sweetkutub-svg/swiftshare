import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../services/monetization/ad_service.dart';
import '../../services/monetization/quota_manager.dart';

class AdRewardScreen extends StatefulWidget {
  const AdRewardScreen({super.key});

  @override
  State<AdRewardScreen> createState() => _AdRewardScreenState();
}

class _AdRewardScreenState extends State<AdRewardScreen> {
  bool _loading = false;
  bool _adWatched = false;

  Future<void> _watchAd() async {
    setState(() => _loading = true);
    final success = await AdService.instance.showRewardedAd();
    if (success) {
      await QuotaManager.instance.addAdReward();
      setState(() => _adWatched = true);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch Ad to Unlock'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            const Spacer(),
            Icon(Icons.videocam, size: 64, color: textSecondary.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              'Daily limit reached.',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Watch a short ad to unlock 1 GB more today, or upgrade to Pro for unlimited transfers.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_adWatched)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.secondary),
                    SizedBox(width: 8),
                    Text('1 GB added to your quota!'),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _watchAd,
                  icon: _loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.play_circle, size: 20),
                  label: Text(_loading ? 'Loading Ad...' : 'Watch Ad'),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/upgrade'),
                child: const Text('Get Pro'),
              ),
            ),
            const Spacer(),
            Text(
              'Max ${AppConstants.maxRewardedAdsPerDay} ads per day. No ad? Try again later.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
