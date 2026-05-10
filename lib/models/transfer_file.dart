import 'dart:io';

class TransferFile {
  final String id;
  final String name;
  final String path;
  final int size;
  final String mimeType;
  final DateTime? modifiedAt;
  final String? thumbnailPath;

  const TransferFile({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.mimeType,
    this.modifiedAt,
    this.thumbnailPath,
  });

  factory TransferFile.fromFile(File file) {
    final name = file.path.split(Platform.pathSeparator).last;
    final stat = file.statSync();
    return TransferFile(
      id: '${DateTime.now().millisecondsSinceEpoch}_$name',
      name: name,
      path: file.path,
      size: stat.size,
      mimeType: 'application/octet-stream',
      modifiedAt: stat.modified,
    );
  }

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(dot + 1).toLowerCase() : '';
  }

  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'].contains(extension);
  bool get isVideo => ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);
  bool get isAudio => ['mp3', 'wav', 'aac', 'flac', 'm4a'].contains(extension);
  bool get isDocument => ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'].contains(extension);

  TransferFile copyWith({
    String? id,
    String? name,
    String? path,
    int? size,
    String? mimeType,
    DateTime? modifiedAt,
    String? thumbnailPath,
  }) {
    return TransferFile(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}
