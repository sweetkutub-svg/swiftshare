import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../models/peer_device.dart';
import '../../models/transfer_file.dart';
import '../../providers/peers_provider.dart';
import '../../services/connection/connection_manager.dart';
import '../../widgets/mode_badge.dart';
import '../../widgets/peer_tile.dart';
import 'progress_screen.dart';

class PeerListScreen extends ConsumerStatefulWidget {
  const PeerListScreen({super.key});

  @override
  ConsumerState<PeerListScreen> createState() => _PeerListScreenState();
}

class _PeerListScreenState extends ConsumerState<PeerListScreen> {
  bool _scanning = true;

  @override
  void initState() {
    super.initState();
    ConnectionManager.instance.startDiscovery();
  }

  @override
  void dispose() {
    ConnectionManager.instance.stopDiscovery();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peersAsync = ref.watch(peersProvider);
    final files = ModalRoute.of(context)!.settings.arguments as List<TransferFile>? ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Devices'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Scanning for devices...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure both devices are on the same Wi-Fi network or have Bluetooth enabled.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: peersAsync.when(
                data: (peers) {
                  if (peers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.devices_other, size: 56, color: textSecondary.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text('No devices found yet', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: textSecondary)),
                          const SizedBox(height: 8),
                          Text('Keep waiting or try remote mode', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: peers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final peer = peers[index];
                      return PeerTile(
                        peer: peer,
                        onTap: () => _onPeerSelected(peer, files),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showRemoteModeDialog(files);
                },
                icon: const Icon(Icons.public, size: 18),
                label: const Text('Use Remote Mode'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPeerSelected(PeerDevice peer, List<TransferFile> files) async {
    final result = await ConnectionManager.instance.connectToPeer(peer);
    if (result.success && mounted) {
      Navigator.pushNamed(context, '/send/progress', arguments: {
        'peer': peer,
        'files': files,
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection failed: ${result.error}')),
      );
    }
  }

  void _showRemoteModeDialog(List<TransferFile> files) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remote Mode'),
        content: const Text('Generate a shareable link or QR code to send files over the internet using peer-to-peer encryption.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/qr/show', arguments: files);
            },
            child: const Text('Generate Link'),
          ),
        ],
      ),
    );
  }
}
