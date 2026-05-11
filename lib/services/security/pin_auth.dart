import 'dart:convert';
import 'package:crypto/crypto.dart';

class PinAuth {
  PinAuth._();

  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return base64Encode(digest.bytes);
  }

  static bool verifyPin(String pin, String hash) {
    return hashPin(pin) == hash;
  }

  static bool isValidFormat(String pin) {
    return pin.length == 4 && RegExp(r'^\d{4}$').hasMatch(pin);
  }
}
