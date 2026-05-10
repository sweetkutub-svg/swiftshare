import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class IntegrityChecker {
  IntegrityChecker._();

  static String computeHash(Uint8List data) {
    final digest = sha256.convert(data);
    return base64Encode(digest.bytes);
  }

  static bool verify(Uint8List data, String expectedHash) {
    final computed = computeHash(data);
    return computed == expectedHash;
  }
}
