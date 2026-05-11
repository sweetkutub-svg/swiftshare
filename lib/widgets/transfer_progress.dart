import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/transfer_status.dart';

class TransferProgress extends StatelessWidget {
  final double progress;
  final TransferStatus status;

  const TransferProgress({
    super.key,
    required this.progress,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toStringAsFixed(0);

    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: 10,
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$pct%',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 36),
                ),
                const SizedBox(height: 4),
                Text(
                  status.label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
