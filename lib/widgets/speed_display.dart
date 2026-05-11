import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class SpeedDisplay extends StatelessWidget {
  final double speedMBps;

  const SpeedDisplay({
    super.key,
    required this.speedMBps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.speed, size: 18, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text(
            '${speedMBps.toStringAsFixed(1)} MB/s',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'JetBrains Mono',
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
