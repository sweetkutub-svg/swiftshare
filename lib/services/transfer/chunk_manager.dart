import 'dart:typed_data';

class ChunkManager {
  List<Uint8List> split(Uint8List data, int chunkSize) {
    final chunks = <Uint8List>[];
    int offset = 0;
    while (offset < data.length) {
      final end = (offset + chunkSize < data.length) ? offset + chunkSize : data.length;
      chunks.add(Uint8List.sublistView(data, offset, end));
      offset = end;
    }
    return chunks;
  }

  Uint8List merge(List<Uint8List> chunks, int totalSize) {
    final result = Uint8List(totalSize);
    int offset = 0;
    for (final chunk in chunks) {
      result.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    return result;
  }
}
