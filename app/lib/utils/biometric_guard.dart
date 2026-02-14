import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import 'package:nitella_app/services/auth_service.dart';
import 'package:nitella_app/services/logic_service_client.dart';

/// Returns true if the operation should proceed.
/// Backend decides if biometric is required for the current state.
Future<bool> biometricGuard(WidgetRef ref) async {
  final client = ref.read(logicServiceProvider);
  final bootstrap = await client.getBootstrapState(Empty());
  final requiresPrompt = bootstrap.requireBiometric ||
      bootstrap.stage == local.BootstrapStage.BOOTSTRAP_STAGE_AUTH_NEEDED;
  if (!requiresPrompt) return true;
  return await AuthService().authenticate();
}
