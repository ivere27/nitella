import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nitella_app/screens/proxies_screen.dart';
import '../test_helpers.dart';
import '../mocks/mock_logic_service.dart';

void main() {
  group('ProxiesScreen', () {
    late MockLogicServiceClient mockClient;

    setUp(() {
      mockClient = MockLogicServiceClient();
    });

    testWidgets('displays loading indicator initially', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ProxiesScreen(),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays proxies after loading', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ProxiesScreen(),
      ));

      await tester.pumpAndSettle();

      // Should display test proxies
      expect(find.text('Web Proxy'), findsOneWidget);
      expect(find.text('SSH Proxy'), findsOneWidget);
      // Listen addresses in subtitles
      expect(find.textContaining(':8080'), findsWidgets);
      expect(find.textContaining(':2222'), findsWidgets);
    });

    testWidgets('displays search field', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ProxiesScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays filter chips', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ProxiesScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
      // "Stopped" appears in filter chip and as proxy status text
      expect(find.widgetWithText(FilterChip, 'Stopped'), findsOneWidget);
    });

    testWidgets('has add proxy FAB', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ProxiesScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Add Proxy'), findsOneWidget);
    });

    testWidgets('displays proxy toggle switch when node is online', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ProxiesScreen(),
      ));

      await tester.pumpAndSettle();

      // Should have switches for proxies on online node (node-1 is online, has 2 proxies)
      expect(find.byType(Switch), findsNWidgets(2));
    });

    testWidgets('filters by Running status', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ProxiesScreen(),
      ));

      await tester.pumpAndSettle();

      // Tap Running filter
      await tester.tap(find.text('Running'));
      await tester.pumpAndSettle();

      // Should see the running proxy, not the stopped one
      expect(find.text('Web Proxy'), findsOneWidget);
      expect(find.text('SSH Proxy'), findsNothing);
    });

    testWidgets('filters by Stopped status', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ProxiesScreen(),
      ));

      await tester.pumpAndSettle();

      // Tap Stopped filter chip (not the status text)
      await tester.tap(find.widgetWithText(FilterChip, 'Stopped'));
      await tester.pumpAndSettle();

      // Stopped proxy should be shown, running hidden
      expect(find.text('Web Proxy'), findsNothing);
      expect(find.text('SSH Proxy'), findsOneWidget);
    });

    testWidgets('search filters proxies', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ProxiesScreen(),
      ));

      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pumpAndSettle();

      // All proxies should be filtered out
      expect(find.text('Web Proxy'), findsNothing);
      expect(find.text('SSH Proxy'), findsNothing);
      expect(find.textContaining('No proxies match'), findsOneWidget);
    });

    testWidgets('search by name matches proxy', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ProxiesScreen(),
      ));

      await tester.pumpAndSettle();

      // Search for SSH
      await tester.enterText(find.byType(TextField), 'SSH');
      await tester.pumpAndSettle();

      // Only SSH proxy should be visible
      expect(find.text('Web Proxy'), findsNothing);
      expect(find.text('SSH Proxy'), findsOneWidget);
    });

    testWidgets('opens add proxy dialog', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ProxiesScreen(),
      ));

      await tester.pumpAndSettle();

      // Tap add button
      await tester.tap(find.text('Add Proxy'));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Listen Address'), findsOneWidget);
      expect(find.text('Default Backend (optional)'), findsOneWidget);
    });

    testWidgets('popup menu has Detail option', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ProxiesScreen(),
      ));

      await tester.pumpAndSettle();

      // Tap the more menu on first proxy
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // Should have Detail, Rules, Connections, Edit, Delete
      expect(find.text('Detail'), findsOneWidget);
      expect(find.text('Rules'), findsOneWidget);
      expect(find.text('Connections'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('displays empty state when no nodes', (tester) async {
      mockClient.nodes.clear();

      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const ProxiesScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('No nodes paired'), findsOneWidget);
    });
  });
}
