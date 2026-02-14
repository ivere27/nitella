import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nitella_app/screens/connections_screen.dart';
import '../test_helpers.dart';
import '../mocks/mock_logic_service.dart';

void main() {
  group('ConnectionsScreen', () {
    late MockLogicServiceClient mockClient;

    setUp(() {
      mockClient = MockLogicServiceClient();
    });

    testWidgets('displays loading indicator initially', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ConnectionsScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: ':8080',
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let timers complete to avoid pending timer errors
      await tester.pumpAndSettle();
    });

    testWidgets('displays app bar title', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ConnectionsScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: ':8080',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Connections'), findsOneWidget);
    });

    testWidgets('displays empty state when no connections', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ConnectionsScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: ':8080',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('No active connections'), findsOneWidget);
    });

    testWidgets('displays header with proxy info', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ConnectionsScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: ':8080',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining(':8080'), findsWidgets);
    });

    testWidgets('displays search field', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ConnectionsScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: ':8080',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays pause/resume button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ConnectionsScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: ':8080',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('displays LIVE indicator when auto-refresh is on',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ConnectionsScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: ':8080',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('displays footer hint', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ConnectionsScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: ':8080',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Tap for IP details'), findsOneWidget);
    });

    testWidgets('displays error state', (tester) async {
      mockClient.simulateError = 'Network error';

      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ConnectionsScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: ':8080',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
    });
  });
}
