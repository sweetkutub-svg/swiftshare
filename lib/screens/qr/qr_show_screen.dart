import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../models/transfer_file.dart';
import '../../services/discovery/qr_generator.dart';
import '../../services/signaling/signaling_client.dart';

class QrShowScreen extends StatefulWidget {
  const QrShowScreen({super.key});

  @override
  State<QrShowScreen> createState() => _QrShowScreenState();
}

class _QrShowScreenState extends State<QrShowScreen> {
  String? _roomId;
  String? _qrData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _createRoom();
  }

  Future<void> _createRoom() async {
    final roomId = await SignalingClient.instance.createRoom();
    if (roomId == null) {
      setState(() => _loading = false);
      return;
    }
    final qrData = QRGenerator.buildRoomData(
      roomId: roomId,
      senderName: 'My Device',
      signalingUrl: AppConstants.signalingServerUrl,
    );
    setState(() {
      _roomId = roomId;
      _qrData = qrData;
      _loading = false;
    });
  }

  void _copyLink() {
    if (_roomId == null) return;
    final link = '${AppConstants.signalingServerUrl}/?room=$_roomId';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  void _shareLink() {
    if (_roomId == null) return;
    final link = '${AppConstants.signalingServerUrl}/?room=$_roomId';
    Share.share('Join my SwiftShare room: $link', subject: 'SwiftShare Transfer');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final fg = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Link'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  Text(
                    'Scan this QR code or share the link to start receiving.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                      border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                    ),
                    child: _qrData != null
                        ? QRGenerator.buildQR(
                            data: _qrData!,
                            size: 220,
                            backgroundColor: bg,
                            foregroundColor: fg,
                          )
                        : const SizedBox(width: 220, height: 220),
                  ),
                  const SizedBox(height: 24),
                  if (_roomId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _roomId!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: 'JetBrains Mono'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: _copyLink,
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _shareLink,
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Share Link'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
