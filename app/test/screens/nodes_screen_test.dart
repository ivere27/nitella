import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nitella_app/screens/nodes_screen.dart';
import '../test_helpers.dart';
import '../mocks/mock_logic_service.dart';

void main() {
  group('NodesScreen', () {
    late MockLogicServiceClient mockClient;

    setUp(() {
      mockClient = MockLogicServiceClient();
    });

    testWidgets('displays loading indicator initially', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const NodesScreen(),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays nodes after loading', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const NodesScreen(),
      ));

      await tester.pumpAndSettle();

      // Should display test nodes
      expect(find.text('Test Node 1'), findsOneWidget);
      expect(find.text('Test Node 2'), findsOneWidget);
    });

    testWidgets('displays online/offline status via connection types',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const NodesScreen(),
      ));

      await tester.pumpAndSettle();

      // Node 1 and Node 2 both use Hub transport in the mock.
      expect(find.textContaining('Hub'), findsNWidgets(2));
    });

    testWidgets('displays pin and alert icons', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const NodesScreen(),
      ));

      await tester.pumpAndSettle();

      // Should have pin star icons (one pinned, one not)
      expect(find.byIcon(Icons.star), findsOneWidget); // Pinned node
      expect(find.byIcon(Icons.star_border), findsOneWidget); // Unpinned node
    });

    testWidgets('has add node button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const NodesScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('has refresh button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const NodesScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays error state', (tester) async {
      mockClient.simulateError = 'Network error';

      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const NodesScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('displays empty state when no nodes', (tester) async {
      mockClient.nodes.clear();

      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const NodesScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('No nodes'), findsOneWidget);
    });
  });
}
