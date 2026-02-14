import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nitella_app/screens/rules_screen.dart';
import '../test_helpers.dart';
import '../mocks/mock_logic_service.dart';

void main() {
  group('RulesScreen', () {
    late MockLogicServiceClient mockClient;

    setUp(() {
      mockClient = MockLogicServiceClient();
    });

    testWidgets('displays loading indicator initially', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const RulesScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: 'Web Proxy',
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays rules after loading', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const RulesScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: 'Web Proxy',
        ),
      ));

      await tester.pumpAndSettle();

      // Should display test rules
      expect(find.text('Block China'), findsOneWidget);
      expect(find.text('Allow Private IPs'), findsOneWidget);
      expect(find.text('Block Scanner ISP'), findsOneWidget);
    });

    testWidgets('displays proxy name in title', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const RulesScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: 'Web Proxy',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Web Proxy'), findsOneWidget);
    });

    testWidgets('has add rule FAB', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const RulesScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: 'Web Proxy',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('displays rule action icon as first letter', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const RulesScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: 'Web Proxy',
        ),
      ));

      await tester.pumpAndSettle();

      // Block rules show 'B', Allow rules show 'A'
      expect(find.text('B'), findsNWidgets(2)); // Block China + Block Scanner ISP
      expect(find.text('A'), findsOneWidget); // Allow Private IPs
    });

    testWidgets('displays structured condition descriptions', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const RulesScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: 'Web Proxy',
        ),
      ));

      await tester.pumpAndSettle();

      // Condition descriptions from _describeRule using structured conditions
      expect(find.textContaining('Country'), findsWidgets);
      expect(find.textContaining('CN'), findsWidgets);
      expect(find.textContaining('CIDR'), findsWidgets);
      expect(find.textContaining('10.0.0.0/8'), findsWidgets);
    });

    testWidgets('displays rule priority', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const RulesScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: 'Web Proxy',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Priority: 100'), findsOneWidget);
      expect(find.textContaining('Priority: 50'), findsOneWidget);
      expect(find.textContaining('Priority: 200'), findsOneWidget);
    });

    testWidgets('FAB opens quick add bottom sheet', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const RulesScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: 'Web Proxy',
        ),
      ));

      await tester.pumpAndSettle();

      // Tap FAB
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Quick add bottom sheet should appear with title and advanced option
      expect(find.text('Quick Add Rule'), findsOneWidget);
      expect(find.text('Advanced Rule Editor'), findsOneWidget);
    });

    testWidgets('quick add sheet opens advanced rule dialog', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const RulesScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: 'Web Proxy',
        ),
      ));

      await tester.pumpAndSettle();

      // Open quick add sheet
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Tap Advanced Rule Editor
      await tester.tap(find.text('Advanced Rule Editor'));
      await tester.pumpAndSettle();

      // Add Rule dialog should appear with condition-type fields
      expect(find.text('Add Rule'), findsWidgets);
      expect(find.text('Rule Name'), findsOneWidget);
      expect(find.text('Condition Type'), findsOneWidget);
      expect(find.text('Operator'), findsOneWidget);
    });

    testWidgets('add rule dialog has negate checkbox', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const RulesScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: 'Web Proxy',
        ),
      ));

      await tester.pumpAndSettle();

      // Open quick add -> advanced
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Advanced Rule Editor'));
      await tester.pumpAndSettle();

      // Should have negate checkbox
      expect(find.text('Negate (NOT)'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsOneWidget);
    });

    testWidgets('displays empty state when no rules', (tester) async {
      mockClient.proxyRules.clear();

      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const RulesScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: 'Web Proxy',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('No rules'), findsOneWidget);
      expect(find.textContaining('Tap +'), findsOneWidget);
    });

    testWidgets('has edit and delete buttons on rules', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const RulesScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: 'Web Proxy',
        ),
      ));

      await tester.pumpAndSettle();

      // 3 rules = 3 edit + 3 delete buttons
      expect(find.byIcon(Icons.edit_outlined), findsNWidgets(3));
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(3));
    });

    testWidgets('has refresh button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const RulesScreen(
          nodeId: 'node-1',
          proxyId: 'proxy-1',
          proxyName: 'Web Proxy',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
