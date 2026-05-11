import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/transfer_file.dart';

class FileCard extends StatelessWidget {
  final TransferFile file;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const FileCard({
    super.key,
    required this.file,
    this.onRemove,
    this.onTap,
  });

  IconData get _icon {
    if (file.isImage) return Icons.image;
    if (file.isVideo) return Icons.videocam;
    if (file.isAudio) return Icons.music_note;
    if (file.isDocument) return Icons.description;
    return Icons.insert_drive_file;
  }

  Color get _iconColor {
    if (file.isImage) return const Color(0xFF00A88A);
    if (file.isVideo) return const Color(0xFFEF4444);
    if (file.isAudio) return const Color(0xFF5B4EFF);
    if (file.isDocument) return const Color(0xFFF59E0B);
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, color: _iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatSize(file.size)} \u2022 ${file.extension.toUpperCase()}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onRemove,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
            ],
          ),
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
