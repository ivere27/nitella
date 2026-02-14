import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nitella_app/screens/settings_screen.dart';
import '../test_helpers.dart';
import '../mocks/mock_logic_service.dart';

void main() {
  group('SettingsScreen', () {
    late MockLogicServiceClient mockClient;

    setUp(() {
      mockClient = MockLogicServiceClient();
    });

    testWidgets('displays section headers', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const SettingsScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Hub & Network'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Identity'), findsOneWidget);
    });

    testWidgets('displays hub server entry', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const SettingsScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Hub Server'), findsOneWidget);
    });

    testWidgets('displays biometric toggle', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const SettingsScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Biometric'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('displays auto-lock setting', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const SettingsScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Auto-Lock'), findsOneWidget);
      expect(find.text('Never'), findsOneWidget);
    });

    testWidgets('displays identity section items', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const SettingsScreen(),
      ));

      await tester.pumpAndSettle();

      // Scroll to identity section
      await tester.scrollUntilVisible(
        find.text('Export CA Certificate'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Export CA Certificate'), findsOneWidget);
      expect(find.text('Signed Certificates'), findsOneWidget);
    });

    testWidgets('displays version and reset after scrolling', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const SettingsScreen(),
      ));

      await tester.pumpAndSettle();

      // Scroll to bottom items
      await tester.scrollUntilVisible(
        find.text('Reset Identity'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Version'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
      expect(find.text('Reset Identity'), findsOneWidget);
    });

    testWidgets('reset identity shows confirmation dialog', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const SettingsScreen(),
      ));

      await tester.pumpAndSettle();

      // Scroll to and tap reset button
      await tester.scrollUntilVisible(
        find.text('Reset Identity'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Reset Identity'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Identity?'), findsOneWidget);
      expect(find.textContaining('permanently delete'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('displays P2P settings entry', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const SettingsScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('P2P Settings'), findsOneWidget);
    });

    testWidgets('displays push notifications entry', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const SettingsScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Push Notifications'), findsOneWidget);
    });

    testWidgets('displays change passphrase entry', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const SettingsScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Change Passphrase'), findsOneWidget);
    });

    testWidgets('displays embedded node section', (tester) async {
      await tester.pumpWidget(createTestWidget(
        mockClient: mockClient,
        child: const SettingsScreen(),
      ));

      await tester.pumpAndSettle();

      // Scroll down to see embedded node
      await tester.scrollUntilVisible(
        find.text('Embedded Node'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Embedded Node'), findsOneWidget);
      expect(find.text('Node Identity'), findsOneWidget);
    });
  });
}
