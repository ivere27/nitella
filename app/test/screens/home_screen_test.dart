import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nitella_app/screens/home_screen.dart';
import '../test_helpers.dart';
import '../mocks/mock_logic_service.dart';

void main() {
  group('HomeScreen', () {
    late MockLogicServiceClient mockClient;

    setUp(() {
      mockClient = MockLogicServiceClient();
    });

    testWidgets('displays loading indicator initially', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const HomeScreen(),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays content after loading', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const HomeScreen(),
      ));

      await tester.pumpAndSettle();

      // App title
      expect(find.text('Nitella'), findsOneWidget);
    });

    testWidgets('displays summary stats when nodes exist', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const HomeScreen(),
      ));

      await tester.pumpAndSettle();

      // Summary shows online/total nodes
      expect(find.text('Nodes Online'), findsOneWidget);
      expect(find.text('Proxies'), findsOneWidget);
      expect(find.text('Connections'), findsOneWidget);
    });

    testWidgets('displays quick action buttons', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const HomeScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Pair'), findsOneWidget);
      expect(find.textContaining('Scan'), findsOneWidget);
      expect(find.textContaining('Block'), findsOneWidget);
      expect(find.text('GeoIP'), findsOneWidget);
    });

    testWidgets('displays pinned nodes section', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const HomeScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Pinned Nodes'), findsOneWidget);
      // Node 1 is pinned
      expect(find.text('Test Node 1'), findsOneWidget);
    });

    testWidgets('shows hub status indicator', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const HomeScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Hub: '), findsOneWidget);
      // Identity exists with fingerprint, so hub shows connected
      expect(find.text('Connected'), findsOneWidget);
    });

    testWidgets('has refresh button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const HomeScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays error state', (tester) async {
      mockClient.simulateError = 'Network error';

      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const HomeScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows no pinned nodes message when none pinned',
        (tester) async {
      // Make all nodes unpinned
      for (final node in mockClient.nodes) {
        node.pinned = false;
      }

      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const HomeScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('No pinned nodes'), findsOneWidget);
    });
  });
}
