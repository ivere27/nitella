import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import 'package:nitella_app/local/nitella_local.pbgrpc.dart' as local;
import 'package:synurang/synurang.dart';

/// Shared FFI channel for all app-side MobileLogicService clients.
final FfiClientChannel logicFfiChannel = FfiClientChannel(
  options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
);

final logicServiceProvider = Provider<local.MobileLogicServiceClient>((ref) {
  return local.MobileLogicServiceClient(logicFfiChannel);
});

local.MobileLogicServiceClient createLogicServiceClient() {
  return local.MobileLogicServiceClient(logicFfiChannel);
}
