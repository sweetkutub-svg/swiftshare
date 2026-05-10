import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/connection_mode.dart';

class ModeBadge extends StatelessWidget {
  final ConnectionMode mode;

  const ModeBadge({
    super.key,
    required this.mode,
  });

  Color get _color {
    switch (mode) {
      case ConnectionMode.lan:
        return AppTheme.secondary;
      case ConnectionMode.wifiDirect:
        return const Color(0xFFF59E0B);
      case ConnectionMode.remote:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        mode.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
