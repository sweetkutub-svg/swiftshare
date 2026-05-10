import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/app_theme.dart';
import 'core/constants.dart';
import 'providers/theme_provider.dart';
import 'services/connection/radio_manager.dart';
import 'services/monetization/subscription_service.dart';
import 'services/notification/mobile_notif_service.dart';
import 'services/signaling/signaling_client.dart';
import 'screens/home/home_screen.dart';
import 'screens/send/send_screen.dart';
import 'screens/send/peer_list_screen.dart';
import 'screens/send/progress_screen.dart';
import 'screens/receive/receive_screen.dart';
import 'screens/receive/received_files_screen.dart';
import 'screens/pro/upgrade_screen.dart';
import 'screens/pro/ad_reward_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/qr/qr_show_screen.dart';
import 'screens/qr/qr_scan_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  await SubscriptionService.instance.initialize();
  await MobileNotificationService.instance.initialize();
  await RadioManager.instance.initialize();
  await SignalingClient.instance.initialize();

  runApp(const ProviderScope(child: SwiftShareApp()));
}

class SwiftShareApp extends ConsumerStatefulWidget {
  const SwiftShareApp({super.key});

  @override
  ConsumerState<SwiftShareApp> createState() => _SwiftShareAppState();
}

class _SwiftShareAppState extends ConsumerState<SwiftShareApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    ref.read(themeProvider.notifier).syncWithSystem();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/send': (context) => const SendScreen(),
        '/send/peers': (context) => const PeerListScreen(),
        '/send/progress': (context) => const ProgressScreen(),
        '/receive': (context) => const ReceiveScreen(),
        '/receive/files': (context) => const ReceivedFilesScreen(),
        '/upgrade': (context) => const UpgradeScreen(),
        '/ad-reward': (context) => const AdRewardScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/qr/show': (context) => const QrShowScreen(),
        '/qr/scan': (context) => const QrScanScreen(),
      },
    );
  }
}
