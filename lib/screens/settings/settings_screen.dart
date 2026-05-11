import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../providers/subscription_provider.dart';
import '../../services/monetization/subscription_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(currentPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionTitle('Account'),
          ListTile(
            leading: const Icon(Icons.workspace_premium, color: AppTheme.primary),
            title: const Text('Subscription'),
            subtitle: Text(plan.label),
            trailing: plan.isFree
                ? ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/upgrade'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 32), padding: const EdgeInsets.symmetric(horizontal: 12)),
                    child: const Text('Upgrade'),
                  )
                : const Icon(Icons.check_circle, color: AppTheme.secondary),
          ),
          const Divider(),
          _SectionTitle('General'),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('Device Name'),
            subtitle: const Text('My SwiftShare Device'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Storage Location'),
            subtitle: const Text('Downloads / SwiftShare'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Transfer History'),
            onTap: () {},
          ),
          const Divider(),
          _SectionTitle('About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: const Text(AppConstants.appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Privacy Policy'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
