import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connection/radio_manager.dart';

final radioStatusProvider = StreamProvider<RadioStatus>((ref) {
  return RadioManager.instance.statusStream;
});
