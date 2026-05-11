import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../models/transfer_file.dart';
import '../../providers/peers_provider.dart';
import '../../widgets/file_card.dart';

class SendScreen extends ConsumerStatefulWidget {
  const SendScreen({super.key});

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  final List<TransferFile> _selectedFiles = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        for (final f in result.files) {
          if (f.path != null) {
            _selectedFiles.add(TransferFile.fromFile(File(f.path!)));
          }
        }
      });
    }
  }

  void _removeFile(int index) {
    setState(() => _selectedFiles.removeAt(index));
  }

  int get totalSize => _selectedFiles.fold(0, (s, f) => s + f.size);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Files'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedFiles.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_open, size: 56, color: textSecondary.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('No files selected', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: textSecondary)),
                      const SizedBox(height: 8),
                      Text('Tap the button below to choose files', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _selectedFiles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final file = _selectedFiles[index];
                    return FileCard(
                      file: file,
                      onRemove: () => _removeFile(index),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            if (_selectedFiles.isNotEmpty)
              Text(
                '${_selectedFiles.length} file(s)  \u2022  ${_formatSize(totalSize)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Files'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedFiles.isEmpty
                        ? null
                        : () => Navigator.pushNamed(
                              context,
                              '/send/peers',
                              arguments: _selectedFiles,
                            ),
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
