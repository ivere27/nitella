import 'package:nitella_app/local/nitella_local.pbenum.dart';

/// Returns a human-readable label for [NodeConnectionType].
String connTypeLabel(NodeConnectionType type) {
  switch (type) {
    case NodeConnectionType.NODE_CONNECTION_TYPE_DIRECT:
      return 'Direct';
    case NodeConnectionType.NODE_CONNECTION_TYPE_HUB:
      return 'Hub';
    default:
      return 'Hub';
  }
}
