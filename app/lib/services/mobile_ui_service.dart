import 'dart:async';
import 'dart:typed_data';
import 'package:grpc/grpc.dart';
import 'package:nitella_app/local/nitella_local.pbgrpc.dart' as local;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import 'package:nitella_app/utils/logger.dart';

class MobileUIServiceImpl extends local.MobileUIServiceBase {
  static final MobileUIServiceImpl _instance = MobileUIServiceImpl._internal();
  factory MobileUIServiceImpl() => _instance;
  MobileUIServiceImpl._internal();

  // Approval requests stream
  final _approvalRequestController =
      StreamController<local.ApprovalRequest>.broadcast();
  Stream<local.ApprovalRequest> get approvalRequestStream =>
      _approvalRequestController.stream;

  // Node status changes stream
  final _nodeStatusController =
      StreamController<local.NodeStatusChange>.broadcast();
  Stream<local.NodeStatusChange> get nodeStatusStream =>
      _nodeStatusController.stream;

  // Connection events stream
  final _connectionEventController =
      StreamController<local.ConnectionEvent>.broadcast();
  Stream<local.ConnectionEvent> get connectionEventStream =>
      _connectionEventController.stream;

  // Alerts stream
  final _alertController = StreamController<local.Alert>.broadcast();
  Stream<local.Alert> get alertStream => _alertController.stream;

  // Toast messages stream
  final _toastController = StreamController<local.ToastMessage>.broadcast();
  Stream<local.ToastMessage> get toastStream => _toastController.stream;

  // Request removal stream (triggered when approval is cancelled/resolved elsewhere)
  final _requestRemovalController = StreamController<String>.broadcast();
  Stream<String> get requestRemovalStream => _requestRemovalController.stream;

  // Dispatcher for FFI
  Uint8List handleFfiRequest(String method, Uint8List data) {
    logger.d("FFI Request: $method");
    try {
      switch (method) {
        case '/nitella.local.MobileUIService/OnApprovalRequest':
        case 'nitella.local.MobileUIService/OnApprovalRequest':
        case 'OnApprovalRequest':
          final request = local.ApprovalRequest.fromBuffer(data);
          _onApprovalRequestSync(request);
          return Empty().writeToBuffer();

        case '/nitella.local.MobileUIService/OnNodeStatusChange':
        case 'nitella.local.MobileUIService/OnNodeStatusChange':
        case 'OnNodeStatusChange':
          final request = local.NodeStatusChange.fromBuffer(data);
          _onNodeStatusChangeSync(request);
          return Empty().writeToBuffer();

        case '/nitella.local.MobileUIService/OnConnectionEvent':
        case 'nitella.local.MobileUIService/OnConnectionEvent':
        case 'OnConnectionEvent':
          final request = local.ConnectionEvent.fromBuffer(data);
          _onConnectionEventSync(request);
          return Empty().writeToBuffer();

        case '/nitella.local.MobileUIService/OnAlert':
        case 'nitella.local.MobileUIService/OnAlert':
        case 'OnAlert':
          final request = local.Alert.fromBuffer(data);
          _onAlertSync(request);
          return Empty().writeToBuffer();

        case '/nitella.local.MobileUIService/OnToast':
        case 'nitella.local.MobileUIService/OnToast':
        case 'OnToast':
          final request = local.ToastMessage.fromBuffer(data);
          _onToastSync(request);
          return Empty().writeToBuffer();

        default:
          logger.w("Unknown FFI method: $method");
          return Uint8List(0);
      }
    } catch (e) {
      logger.e("Error handling FFI request", error: e);
      return Uint8List(0);
    }
  }

  void _onApprovalRequestSync(local.ApprovalRequest request) {
    logger.d("MobileUIService: Approval Request: ${request.requestId}");
    _approvalRequestController.add(request);
  }

  void _onNodeStatusChangeSync(local.NodeStatusChange request) {
    logger.d("MobileUIService: Node status change: ${request.nodeId} online=${request.online}");
    _nodeStatusController.add(request);
  }

  void _onConnectionEventSync(local.ConnectionEvent request) {
    logger.d("MobileUIService: Connection event: ${request.connId}");
    _connectionEventController.add(request);
  }

  void _onAlertSync(local.Alert request) {
    logger.d("MobileUIService: Alert: ${request.id} - ${request.title}");
    _alertController.add(request);
  }

  void _onToastSync(local.ToastMessage request) {
    logger.d("MobileUIService: Toast: ${request.message}");
    _toastController.add(request);
  }

  // gRPC method implementations (for standard gRPC server if used)
  @override
  Future<Empty> onApprovalRequest(
      ServiceCall call, local.ApprovalRequest request) async {
    _onApprovalRequestSync(request);
    return Empty();
  }

  @override
  Future<Empty> onNodeStatusChange(
      ServiceCall call, local.NodeStatusChange request) async {
    _onNodeStatusChangeSync(request);
    return Empty();
  }

  @override
  Future<Empty> onConnectionEvent(
      ServiceCall call, local.ConnectionEvent request) async {
    _onConnectionEventSync(request);
    return Empty();
  }

  @override
  Future<Empty> onAlert(ServiceCall call, local.Alert request) async {
    _onAlertSync(request);
    return Empty();
  }

  @override
  Future<Empty> onToast(ServiceCall call, local.ToastMessage request) async {
    _onToastSync(request);
    return Empty();
  }
}
