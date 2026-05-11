import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/peer_device.dart';
import 'mode_badge.dart';

class PeerTile extends StatelessWidget {
  final PeerDevice peer;
  final VoidCallback? onTap;

  const PeerTile({
    super.key,
    required this.peer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.smartphone, color: AppTheme.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peer.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ModeBadge(mode: peer.connectionMode),
                        if (peer.ipAddress != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            peer.ipAddress!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'JetBrains Mono'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
