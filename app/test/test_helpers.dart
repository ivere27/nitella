import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nitella_app/main.dart';
import 'mocks/mock_logic_service.dart';

/// Creates a testable widget wrapped with necessary providers.
Widget createTestWidget({
  required Widget child,
  MockLogicServiceClient? mockClient,
  Size? screenSize,
}) {
  final client = mockClient ?? MockLogicServiceClient();

  Widget app = ProviderScope(
    overrides: [
      logicServiceProvider.overrideWithValue(client),
    ],
    child: MaterialApp(
      home: child,
    ),
  );

  // Wrap with MediaQuery for custom screen size
  if (screenSize != null) {
    app = MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: app,
    );
  }

  return app;
}

/// Creates a testable widget with Scaffold wrapper.
Widget createTestWidgetWithScaffold({
  required Widget child,
  MockLogicServiceClient? mockClient,
}) {
  return createTestWidget(
    mockClient: mockClient,
    child: Scaffold(body: child),
  );
}

/// Extension to make pumping and settling easier.
extension WidgetTesterExtensions on WidgetTester {
  /// Pump widget and wait for all animations/futures to settle.
  Future<void> pumpAndSettle2([Duration duration = const Duration(milliseconds: 100)]) async {
    await pump(duration);
    await pumpAndSettle();
  }
}

/// Common test matchers.
Finder findByText(String text) => find.text(text);
Finder findByType<T>() => find.byType(T);
Finder findByIcon(IconData icon) => find.byIcon(icon);
