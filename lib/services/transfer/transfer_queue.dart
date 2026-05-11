import 'dart:async';
import 'dart:collection';
import '../../models/transfer_file.dart';
import '../../models/peer_device.dart';

class QueuedTransfer {
  final String id;
  final PeerDevice peer;
  final List<TransferFile> files;
  final DateTime queuedAt;

  QueuedTransfer({
    required this.id,
    required this.peer,
    required this.files,
    required this.queuedAt,
  });
}

class TransferQueue {
  final _queue = Queue<QueuedTransfer>();
  final _controller = StreamController<List<QueuedTransfer>>.broadcast();

  Stream<List<QueuedTransfer>> get stream => _controller.stream;

  void enqueue(QueuedTransfer transfer) {
    _queue.add(transfer);
    _notify();
  }

  QueuedTransfer? dequeue() {
    if (_queue.isEmpty) return null;
    final item = _queue.removeFirst();
    _notify();
    return item;
  }

  void remove(String id) {
    _queue.removeWhere((t) => t.id == id);
    _notify();
  }

  List<QueuedTransfer> get pending => List.unmodifiable(_queue);

  int get length => _queue.length;

  bool get isEmpty => _queue.isEmpty;

  void _notify() {
    _controller.add(List.unmodifiable(_queue));
  }

  void dispose() {
    _controller.close();
  }
}
