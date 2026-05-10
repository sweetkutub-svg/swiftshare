import 'dart:io';
import 'package:mime/mime.dart';

extension FileExtensions on File {
  String get mimeType {
    final path = this.path;
    final type = lookupMimeType(path);
    return type ?? 'application/octet-stream';
  }

  String get extensionName {
    final name = path.split(Platform.pathSeparator).last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(dot + 1).toUpperCase() : '';
  }
}

String formatBytes(int bytes, {int decimals = 2}) {
  if (bytes <= 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  final i = (bytes.bitLength ~/ 10).clamp(0, suffixes.length - 1);
  return '${(bytes / (1 << (i * 10))).toStringAsFixed(decimals)} ${suffixes[i]}';
}
