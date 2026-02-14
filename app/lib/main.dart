import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';

import 'package:nitella_app/utils/logger.dart';
import 'package:synurang/synurang.dart' as synura;
import 'package:synurang/synurang.dart' hide Duration;
import 'package:nitella_app/local/nitella_local.pbgrpc.dart' as local;
import 'package:path_provider/path_provider.dart';
import 'services/mobile_ui_service.dart';
import 'services/logic_service_client.dart';
import 'screens/dashboard_screen.dart';
import 'screens/nodes_screen.dart';
import 'screens/proxies_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/requests_screen.dart';
import 'providers/active_approvals_provider.dart';

import 'screens/initial_setup_screen.dart';
import 'screens/auth_check_screen.dart';
import 'screens/hub_settings_screen.dart';
import 'services/hub_service.dart';

export 'services/logic_service_client.dart'
    show logicFfiChannel, logicServiceProvider;

/// Guard to prevent re-initialization when main() is called multiple times
/// (e.g., in integration tests where each testWidgets calls app.main())
bool _backendInitialized = false;

/// Set to true if the Go backend fails to start — shows fatal error screen.
bool _backendFailed = false;
String _backendError = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize backend once (critical for integration tests)
  if (!_backendInitialized) {
    // 1. Configure Synurang to load our library
    synura.configureSynurang(libraryName: 'nitella');

    // 2. Pre-warm isolate
    synura.prewarmIsolate();

    // 3. Register Dart Handler (UI Service)
    final uiService = MobileUIServiceImpl();
    synura.registerDartHandler(uiService.handleFfiRequest);

    // 4. Start Go Backend
    try {
      await synura.startGrpcServerAsync();
      logger.i("Go backend started.");
    } catch (e) {
      logger.f("Failed to start Go backend", error: e);
      _backendFailed = true;
      _backendError = e.toString();
    }

    // 5. Initialize Backend persistence
    try {
      String path;
      const testPath = String.fromEnvironment('TEST_DATA_DIR');
      if (testPath.isNotEmpty) {
        path = testPath;
      } else {
        final directory = await getApplicationSupportDirectory();
        path = directory.path;
      }
      final client = local.MobileLogicServiceClient(logicFfiChannel);
      await client.initialize(local.InitializeRequest(dataDir: path));
      logger.d("Go Backend initialized persistence at: $path");
    } catch (e) {
      logger.e("Failed to initialize persistence", error: e);
    }

    _backendInitialized = true;
  } else {
    logger.d("Go backend already initialized, skipping re-initialization.");
  }

  // 6. Initialize Firebase & Hub Service (optional)
  try {
    // For this environment (Linux dev), Firebase might fail. Let's wrap safely.
  } catch (e) {
    logger.w(
        "Failed to init Firebase/Hub (Expected on Linux dev if not config)",
        error: e);
  }

  runApp(
    const ProviderScope(
      child: NitellaApp(),
    ),
  );
}

class NitellaApp extends StatelessWidget {
  const NitellaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nitella',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  // States: loading, setup_needed, auth_needed, ready
  String _state = "loading";
  String? _initialRoute; // Handle deep linking

  @override
  void initState() {
    super.initState();
    _checkState();
    _checkInitialNotification();
  }

  // Simulates checking if app was launched via notification
  void _checkInitialNotification() {
    // In prod: RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    // For now, no-op or check environment for testing
  }

  Future<void> _checkState() async {
    final client = local.MobileLogicServiceClient(logicFfiChannel);
    try {
      final bootstrap = await client.getBootstrapState(Empty());
      if (bootstrap.stage ==
          local.BootstrapStage.BOOTSTRAP_STAGE_SETUP_NEEDED) {
        if (mounted) setState(() => _state = "setup_needed");
        return;
      }
      if (bootstrap.stage == local.BootstrapStage.BOOTSTRAP_STAGE_AUTH_NEEDED ||
          bootstrap.stage == local.BootstrapStage.BOOTSTRAP_STAGE_UNSPECIFIED) {
        if (mounted) setState(() => _state = "auth_needed");
        return;
      }

      // Auto-register with Hub BEFORE showing main screen
      try {
        await HubService().init();
        await HubService().ensureRegistered();
      } catch (e) {
        logger.w("Hub background init failed", error: e);
      }

      if (mounted) setState(() => _state = "ready");
    } catch (e) {
      logger.e("Failed to resolve app state", error: e);
      if (mounted) setState(() => _state = "auth_needed");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_backendFailed) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text("Backend Failed to Start",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_backendError,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    // Restart the app process
                    SystemNavigator.pop();
                  },
                  child: const Text("Close App"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    switch (_state) {
      case "setup_needed":
        return const InitialSetupScreen();
      case "auth_needed":
        return const AuthCheckScreen();
      case "ready":
        return MainScreen(initialRoute: _initialRoute);
      default:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}

/// Main screen with bottom navigation
class MainScreen extends ConsumerStatefulWidget {
  final String? initialRoute;
  const MainScreen({super.key, this.initialRoute});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  StreamSubscription? _approvalSub;
  StreamSubscription? _alertSub;
  DateTime _lastAlertSnackAt = DateTime.fromMillisecondsSinceEpoch(0);

  final _screens = const [
    DashboardScreen(),
    NodesScreen(),
    ProxiesScreen(),
    RequestsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final uiService = MobileUIServiceImpl();

    // Listen for approval callbacks (push path).
    _approvalSub = uiService.approvalRequestStream.listen((_) {
      _onIncomingAlert(message: 'New connection request received');
    });

    // Listen for raw alerts too (fallback path for hub-streamed events).
    _alertSub = uiService.alertStream.listen((alert) {
      final title = alert.title.trim();
      final message = title.isNotEmpty ? title : 'New alert received';
      _onIncomingAlert(message: message);
    });

    _showStartupSecurityWarningIfNeeded();
  }

  @override
  void dispose() {
    _approvalSub?.cancel();
    _alertSub?.cancel();
    super.dispose();
  }

  void _onIncomingAlert({required String message}) {
    if (!mounted) return;

    // Refresh from backend snapshot to keep Go as the source of truth.
    ref.read(activeApprovalsProvider.notifier).refresh();
    _showAlertSnackBar(message);
  }

  void _showAlertSnackBar(String message) {
    if (!mounted) return;
    final now = DateTime.now();
    if (now.difference(_lastAlertSnackAt) <
        const Duration(milliseconds: 1200)) {
      return;
    }
    _lastAlertSnackAt = now;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    // Alert notifications should feel real-time; do not wait behind older snackbars.
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'REVIEW',
          onPressed: () {
            setState(() => _currentIndex = 3); // Switch to Alerts tab
          },
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showStartupSecurityWarningIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      () async {
        if (!mounted) return;
        final warning = await HubService().getPendingTrustWarning();
        if (!mounted || warning == null) return;
        showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.security, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(child: Text('Security Verification Needed')),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hub certificate trust verification is pending. '
                    'Review and verify the Hub certificate before using Hub features.',
                  ),
                  const SizedBox(height: 12),
                  if (warning.hubAddress.isNotEmpty)
                    Text('Hub: ${warning.hubAddress}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (warning.subject.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Subject: ${warning.subject}'),
                  ],
                  if (warning.emojiHash.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Emoji: ${warning.emojiHash}',
                        style: const TextStyle(fontSize: 18)),
                  ],
                  if (warning.fingerprint.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                        'Fingerprint: ${_shortFingerprint(warning.fingerprint)}'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Later'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HubSettingsScreen()),
                  );
                },
                child: const Text('Open Hub Settings'),
              ),
            ],
          ),
        );
      }();
    });
  }

  static String _shortFingerprint(String fingerprint) {
    if (fingerprint.length <= 32) {
      return fingerprint;
    }
    return '${fingerprint.substring(0, 16)}...${fingerprint.substring(fingerprint.length - 16)}';
  }

  @override
  Widget build(BuildContext context) {
    // Fallback for cases where push callbacks are unavailable: notify on new IDs
    // when the polling snapshot changes.
    ref.listen<List<local.ApprovalRequest>>(activeApprovalsProvider,
        (prev, next) {
      if (!mounted || prev == null) {
        return;
      }
      final prevIds = prev.map((r) => r.requestId).toSet();
      final hasNew = next.any((r) => !prevIds.contains(r.requestId));
      if (hasNew) {
        _showAlertSnackBar('New connection request received');
      }
    });

    final pendingCount = ref.watch(activeApprovalsProvider).length;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.computer_outlined),
            selectedIcon: Icon(Icons.computer),
            label: 'Nodes',
          ),
          const NavigationDestination(
            icon: Icon(Icons.router_outlined),
            selectedIcon: Icon(Icons.router),
            label: 'Proxies',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.notifications),
            ),
            label: 'Alerts',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
