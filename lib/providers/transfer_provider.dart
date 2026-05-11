import 'package:async/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transfer_session.dart';
import '../services/transfer/sender_service.dart';
import '../services/transfer/receiver_service.dart';

final senderServiceProvider = Provider<SenderService>((ref) {
  final service = SenderService();
  ref.onDispose(service.dispose);
  return service;
});

final receiverServiceProvider = Provider<ReceiverService>((ref) {
  final service = ReceiverService();
  ref.onDispose(service.dispose);
  return service;
});

final activeSessionProvider = StreamProvider<TransferSession?>((ref) {
  final sender = ref.watch(senderServiceProvider);
  final receiver = ref.watch(receiverServiceProvider);
  return StreamGroup.merge<TransferSession>([
    sender.sessionStream,
    receiver.sessionStream,
  ]);
});
