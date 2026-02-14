import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/screens/node_detail_screen.dart';
import '../test_helpers.dart';
import '../mocks/mock_logic_service.dart';

void main() {
  group('NodeDetailScreen', () {
    late MockLogicServiceClient mockClient;
    late local.NodeInfo testNode;

    setUp(() {
      mockClient = MockLogicServiceClient();
      testNode = mockClient.nodes.first; // 'Test Node 1' - online, P2P
    });

    testWidgets('displays loading indicator initially', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: NodeDetailScreen(node: testNode),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays node name in app bar', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: NodeDetailScreen(node: testNode),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Test Node 1'), findsWidgets);
    });

    testWidgets('displays tab bar with Proxies, Rules, Stats', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: NodeDetailScreen(node: testNode),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Proxies'), findsOneWidget);
      expect(find.text('Rules'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
    });

    testWidgets('displays node status header with online indicator',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: NodeDetailScreen(node: testNode),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Online'), findsOneWidget);
      expect(find.text('via Hub'), findsOneWidget);
    });

    testWidgets('displays edit button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: NodeDetailScreen(node: testNode),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('edit button opens edit dialog', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: NodeDetailScreen(node: testNode),
      ));

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.text('Edit Node'), findsOneWidget);
      expect(find.text('Node Name'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('popup menu has refresh and remove options', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: NodeDetailScreen(node: testNode),
      ));

      await tester.pumpAndSettle();

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Refresh'), findsOneWidget);
      expect(find.text('Remove Node'), findsOneWidget);
    });

    testWidgets('remove node shows confirmation dialog', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: NodeDetailScreen(node: testNode),
      ));

      await tester.pumpAndSettle();

      // Open popup menu and tap Remove
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Node'));
      await tester.pumpAndSettle();

      expect(find.text('Remove Node'), findsWidgets);
      expect(find.textContaining('Are you sure'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('displays proxies in first tab', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: NodeDetailScreen(node: testNode),
      ));

      await tester.pumpAndSettle();

      // Proxies tab is active by default, shows proxy names
      expect(find.text('Web Proxy'), findsOneWidget);
      expect(find.text('SSH Proxy'), findsOneWidget);
    });

    testWidgets('displays pin and alert toggle buttons', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: NodeDetailScreen(node: testNode),
      ));

      await tester.pumpAndSettle();

      // Pin star icon (node is pinned)
      expect(find.byIcon(Icons.star), findsOneWidget);
      // Notification icon (alerts enabled)
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('displays offline status for offline node', (tester) async {
      final offlineNode = mockClient.nodes[1]; // node-2, offline

      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: NodeDetailScreen(node: offlineNode),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('displays offline status with connection type', (tester) async {
      final offlineHubNode = mockClient.nodes[1]; // node-2, offline, Hub

      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: NodeDetailScreen(node: offlineHubNode),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Offline'), findsOneWidget);
      expect(find.text('via Hub'), findsOneWidget);
    });
  });
}
