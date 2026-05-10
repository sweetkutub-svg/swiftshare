import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class ConnectionIndicator extends StatelessWidget {
  final bool connected;

  const ConnectionIndicator({
    super.key,
    this.connected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: connected ? AppTheme.secondary : AppTheme.error,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          connected ? 'Online' : 'Offline',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
