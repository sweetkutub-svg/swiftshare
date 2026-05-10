import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../models/peer_device.dart';
import '../../models/transfer_file.dart';
import '../../models/transfer_session.dart';
import '../../providers/transfer_provider.dart';
import '../../services/transfer/sender_service.dart';
import '../../widgets/speed_display.dart';
import '../../widgets/transfer_progress.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  late final SenderService _sender;

  @override
  void initState() {
    super.initState();
    _sender = ref.read(senderServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTransfer());
  }

  void _startTransfer() {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args == null) return;
    final peer = args['peer'] as PeerDevice;
    final files = args['files'] as List<TransferFile>;
    _sender.sendFiles(peer: peer, files: files);
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(activeSessionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sending'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmCancel(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: sessionAsync.when(
          data: (session) {
            if (session == null) {
              return const Center(child: Text('Preparing transfer...'));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.peer?.name ?? 'Unknown Device',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.fileCount} file(s)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                Center(
                  child: TransferProgress(
                    progress: session.progress,
                    status: session.status,
                  ),
                ),
                const SizedBox(height: 32),
                if (session.speedMBps != null)
                  SpeedDisplay(speedMBps: session.speedMBps!),
                const SizedBox(height: 16),
                Text(
                  'Current: ${session.currentFileName ?? '...'}',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                if (session.status == TransferStatus.completed)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                      child: const Text('Done'),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Transfer?'),
        content: const Text('The transfer will be stopped immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Sending'),
          ),
          ElevatedButton(
            onPressed: () {
              _sender.cancel();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
