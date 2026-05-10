import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class WiFiPromptBanner extends StatelessWidget {
  final bool wifiOff;
  final bool bluetoothOff;
  final VoidCallback? onEnableWiFi;
  final VoidCallback? onEnableBluetooth;
  final VoidCallback? onDismiss;

  const WiFiPromptBanner({
    super.key,
    this.wifiOff = false,
    this.bluetoothOff = false,
    this.onEnableWiFi,
    this.onEnableBluetooth,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (!wifiOff && !bluetoothOff) return const SizedBox.shrink();

    final message = wifiOff && bluetoothOff
        ? 'Wi-Fi and Bluetooth are off. Turn them on to find nearby devices.'
        : wifiOff
            ? 'Wi-Fi is off. Turn it on to find nearby devices.'
            : 'Bluetooth is off. Turn it on to find nearby devices.';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: wifiOff ? onEnableWiFi : onEnableBluetooth,
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: const Size(0, 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Turn On'),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
              color: AppTheme.primary,
            ),
        ],
      ),
    );
  }
}
