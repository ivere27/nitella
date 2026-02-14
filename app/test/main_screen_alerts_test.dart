import 'package:flutter_test/flutter_test.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/main.dart';
import 'package:nitella_app/services/mobile_ui_service.dart';

import 'mocks/mock_logic_service.dart';
import 'test_helpers.dart';

void main() {
  group('MainScreen alerts', () {
    late MockLogicServiceClient mockClient;
    late MobileUIServiceImpl uiService;

    setUp(() {
      mockClient = MockLogicServiceClient();
      uiService = MobileUIServiceImpl();
    });

    testWidgets('shows alert snackbar immediately from UI callback stream',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          mockClient: mockClient,
          child: const MainScreen(),
        ),
      );
      await tester.pump();

      uiService.handleFfiRequest(
        '/nitella.local.MobileUIService/OnAlert',
        local.Alert(id: 'alert-1', title: 'First alert').writeToBuffer(),
      );
      await tester.pump();

      expect(find.text('First alert'), findsOneWidget);
      expect(find.text('REVIEW'), findsOneWidget);
    });

    testWidgets('new alert replaces current snackbar without waiting',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          mockClient: mockClient,
          child: const MainScreen(),
        ),
      );
      await tester.pump();

      uiService.handleFfiRequest(
        '/nitella.local.MobileUIService/OnAlert',
        local.Alert(id: 'alert-1', title: 'First alert').writeToBuffer(),
      );
      await tester.pump();
      expect(find.text('First alert'), findsOneWidget);

      // Pass real-time throttle window (1.2s), but still well before 5s snackbar duration.
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 1300));
      });
      await tester.pump();

      uiService.handleFfiRequest(
        '/nitella.local.MobileUIService/OnAlert',
        local.Alert(id: 'alert-2', title: 'Second alert').writeToBuffer(),
      );
      // Allow snackbar replacement transition, but keep well below 5s queue delay.
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Second alert'), findsOneWidget);
      expect(find.text('First alert'), findsNothing);
    });
  });
}
