import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/peer_device.dart';
import '../services/connection/connection_manager.dart';

final peersProvider = StreamProvider<List<PeerDevice>>((ref) {
  return ConnectionManager.instance.peersStream;
});

final selectedPeerProvider = StateProvider<PeerDevice?>((ref) => null);
