import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/common/common.pb.dart' as common;
import 'package:nitella_app/screens/proxy_detail_screen.dart';
import '../test_helpers.dart';
import '../mocks/mock_logic_service.dart';

void main() {
  group('ProxyDetailScreen', () {
    late MockLogicServiceClient mockClient;
    late local.ProxyInfo testProxy;

    setUp(() {
      mockClient = MockLogicServiceClient();
      testProxy = local.ProxyInfo(
        proxyId: 'proxy-1',
        nodeId: 'node-1',
        name: 'Web Proxy',
        listenAddr: ':8080',
        defaultBackend: 'localhost:3000',
        running: true,
        defaultAction: common.ActionType.ACTION_TYPE_ALLOW,
        activeConnections: Int64(5),
        totalConnections: Int64(150),
        ruleCount: 3,
      );
    });

    testWidgets('displays loading indicator initially', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: testProxy,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays proxy name in app bar', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: testProxy,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Web Proxy'), findsOneWidget);
    });

    testWidgets('displays running status header', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: testProxy,
        ),
      ));

      await tester.pumpAndSettle();

      // Status text includes "Running" and connection count
      expect(find.textContaining('Running'), findsWidgets);
      // Listen address
      expect(find.textContaining(':8080'), findsWidgets);
      // Backend
      expect(find.textContaining('localhost:3000'), findsWidgets);
      // Node name
      expect(find.textContaining('Test Node 1'), findsWidgets);
    });

    testWidgets('displays default action label', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: testProxy,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Default: Allow'), findsWidgets);
    });

    testWidgets('displays action buttons', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: testProxy,
        ),
      ));

      await tester.pumpAndSettle();

      // Disable button (since proxy is running)
      expect(find.text('Disable'), findsOneWidget);
      // Disconnect All button (since proxy is running with active connections)
      expect(find.text('Disconnect All'), findsOneWidget);
      // Connections button
      expect(find.text('Connections'), findsOneWidget);
    });

    testWidgets('displays stats section', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: testProxy,
        ),
      ));

      await tester.pumpAndSettle();

      // Stats section header
      expect(find.text('Stats'), findsOneWidget);
      // Stat labels
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Allowed'), findsOneWidget);
      expect(find.text('Blocked'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('displays geo stats section', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: testProxy,
        ),
      ));

      await tester.pumpAndSettle();

      // Scroll down to find geo stats (they may be below the fold)
      await tester.scrollUntilVisible(
        find.text('Top Countries'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Top Countries'), findsOneWidget);
    });

    testWidgets('displays rules section with rules', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: testProxy,
        ),
      ));

      await tester.pumpAndSettle();

      // Scroll down to find rules section
      await tester.scrollUntilVisible(
        find.text('Rules'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      // Rules section header
      expect(find.text('Rules'), findsOneWidget);
      // Rule count
      expect(find.textContaining('3 rules'), findsOneWidget);
    });

    testWidgets('has edit button in app bar', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: testProxy,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('has refresh button in app bar', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: testProxy,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('has auto-refresh toggle', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: testProxy,
        ),
      ));

      await tester.pumpAndSettle();

      // Auto-refresh toggle (play icon when off)
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('opens edit dialog', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: testProxy,
        ),
      ));

      await tester.pumpAndSettle();

      // Tap edit
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Edit dialog should appear
      expect(find.text('Edit Proxy'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Listen Address'), findsOneWidget);
      expect(find.text('Default Backend'), findsOneWidget);
    });

    testWidgets('shows Enable button when proxy is stopped', (tester) async {
      final stoppedProxy = local.ProxyInfo(
        proxyId: 'proxy-2',
        nodeId: 'node-1',
        name: 'SSH Proxy',
        listenAddr: ':2222',
        defaultBackend: 'localhost:22',
        running: false,
        defaultAction: common.ActionType.ACTION_TYPE_REQUIRE_APPROVAL,
        activeConnections: Int64(0),
      );

      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: stoppedProxy,
        ),
      ));

      await tester.pumpAndSettle();

      // Should show Enable (not Disable)
      expect(find.text('Enable'), findsOneWidget);
      expect(find.text('Disable'), findsNothing);
      // No Disconnect All since no active connections
      expect(find.text('Disconnect All'), findsNothing);
    });

    testWidgets('shows disconnect all confirmation dialog', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: testProxy,
        ),
      ));

      await tester.pumpAndSettle();

      // Tap Disconnect All
      await tester.tap(find.text('Disconnect All'));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Disconnect All?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('displays empty rules state', (tester) async {
      mockClient.proxyRules.clear();

      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: testProxy,
        ),
      ));

      await tester.pumpAndSettle();

      // Scroll down to find rules section
      await tester.scrollUntilVisible(
        find.textContaining('No rules configured'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.textContaining('No rules configured'), findsOneWidget);
    });

    testWidgets('displays bandwidth stats', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: ProxyDetailScreen(
          nodeId: 'node-1',
          nodeName: 'Test Node 1',
          proxyInfo: testProxy,
        ),
      ));

      await tester.pumpAndSettle();

      // Bytes In/Out labels
      expect(find.text('Bytes In'), findsOneWidget);
      expect(find.text('Bytes Out'), findsOneWidget);
    });
  });
}
