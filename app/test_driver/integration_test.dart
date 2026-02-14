// Test driver for running integration tests with a visible window.
//
// This driver enables `flutter drive` to run integration tests
// on a real device or Linux desktop with visible UI.
//
// Usage:
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/app_test.dart \
//     -d linux

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
