import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../widgets/connection_indicator.dart';
import '../../widgets/mode_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.layers, color: AppTheme.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                  const ConnectionIndicator(),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Transfer files at maximum speed — locally without internet, remotely without uploading.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textSecondary),
              ),
              const SizedBox(height: 40),
              _ActionCard(
                icon: Icons.upload_file,
                title: 'Send',
                subtitle: 'Select files and send to nearby devices',
                color: AppTheme.primary,
                onTap: () => Navigator.pushNamed(context, '/send'),
              ),
              const SizedBox(height: 16),
              _ActionCard(
                icon: Icons.download,
                title: 'Receive',
                subtitle: 'Accept incoming transfers',
                color: AppTheme.secondary,
                onTap: () => Navigator.pushNamed(context, '/receive'),
              ),
              const SizedBox(height: 16),
              _ActionCard(
                icon: Icons.qr_code,
                title: 'Scan QR',
                subtitle: 'Join a remote transfer room',
                color: AppTheme.primaryHover,
                onTap: () => Navigator.pushNamed(context, '/qr/scan'),
              ),
              const Spacer(),
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                  icon: Icon(Icons.settings, color: textSecondary, size: 18),
                  label: Text('Settings', style: TextStyle(color: textSecondary)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.displaySmall),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
