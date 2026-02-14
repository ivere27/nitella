import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nitella_app/screens/stats_screen.dart';
import '../test_helpers.dart';
import '../mocks/mock_logic_service.dart';

void main() {
  group('StatsScreen', () {
    late MockLogicServiceClient mockClient;

    setUp(() {
      mockClient = MockLogicServiceClient();
    });

    testWidgets('displays loading indicator initially', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const StatsScreen(),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays tabs after loading', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const StatsScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Geo'), findsOneWidget);
      expect(find.text('Top IPs'), findsOneWidget);
    });

    testWidgets('displays summary statistics', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const StatsScreen(),
      ));

      await tester.pumpAndSettle();

      // Check for stat values from mock
      expect(find.text('100'), findsOneWidget); // Total Connections
      expect(find.text('25'), findsOneWidget); // Unique IPs
      expect(find.text('10'), findsWidgets); // Countries / Blocked
    });

    testWidgets('has export menu button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const StatsScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.file_download), findsOneWidget);
    });

    testWidgets('opens export menu on tap', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const StatsScreen(),
      ));

      await tester.pumpAndSettle();

      // Tap export button
      await tester.tap(find.byIcon(Icons.file_download));
      await tester.pumpAndSettle();

      // Menu options should appear
      expect(find.text('Export as CSV'), findsOneWidget);
      expect(find.text('Export as YAML'), findsOneWidget);
      expect(find.text('Copy to Clipboard'), findsOneWidget);
    });

    testWidgets('has refresh button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const StatsScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('switches to Geo tab', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const StatsScreen(),
      ));

      await tester.pumpAndSettle();

      // Tap Geo tab
      await tester.tap(find.text('Geo'));
      await tester.pumpAndSettle();

      // Should show geo data
      expect(find.text('US'), findsWidgets);
      expect(find.text('KR'), findsWidgets);
    });

    testWidgets('switches to Top IPs tab', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const StatsScreen(),
      ));

      await tester.pumpAndSettle();

      // Tap Top IPs tab
      await tester.tap(find.text('Top IPs'));
      await tester.pumpAndSettle();

      // Should show IP data
      expect(find.text('192.168.1.100'), findsOneWidget);
    });

    testWidgets('displays error state', (tester) async {
      mockClient.simulateError = 'Network error';

      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const StatsScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('displays data transfer statistics', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const StatsScreen(),
      ));

      await tester.pumpAndSettle();

      // Should show data transfer section
      expect(find.text('Data Transfer'), findsOneWidget);
      expect(find.text('Inbound'), findsOneWidget);
      expect(find.text('Outbound'), findsOneWidget);
    });
  });
}
