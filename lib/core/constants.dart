import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'SwiftShare';
  static const String appVersion = '2.0.0';

  // Networking
  static const int lanWebSocketPort = 56789;
  static const int localHttpPort = 56790;
  static const int mdnsPort = 56791;
  static const String mdnsServiceType = '_swiftshare._tcp';

  // Signaling Server
  static const String signalingServerUrl = 'https://your-railway-url.railway.app';
  static const int signalingConnectTimeoutMs = 10000;

  // Transfer
  static const int chunkSizeBytes = 65536; // 64 KB
  static const int maxConcurrentTransfers = 3;
  static const int transferTimeoutSeconds = 300;

  // Quota (Free Tier)
  static const int freeDailyRemoteQuotaMB = 2048; // 2 GB
  static const int freeMaxFileSizeMB = 4096; // 4 GB
  static const int freeMaxConnections = 1;
  static const int freeHistoryDays = 7;

  // Ads
  static const int maxRewardedAdsPerDay = 3;
  static const int adRewardQuotaMB = 1024; // 1 GB per ad

  // UI
  static const double defaultPadding = 20.0;
  static const double cardRadius = 14.0;
  static const double buttonRadius = 10.0;
  static const double minTouchTarget = 48.0;

  // Security
  static const int pinLength = 4;
  static const int roomExpiryHours = 24;
}
