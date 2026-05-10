import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGenerator {
  static String buildRoomData({
    required String roomId,
    required String senderName,
    required String signalingUrl,
  }) {
    final data = {
      'v': 2,
      'room': roomId,
      'name': senderName,
      'server': signalingUrl,
    };
    return jsonEncode(data);
  }

  static Widget buildQR({
    required String data,
    double size = 200,
    Color backgroundColor = Colors.white,
    Color foregroundColor = const Color(0xFF0D0D1A),
  }) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: const EdgeInsets.all(12),
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );
  }
}
