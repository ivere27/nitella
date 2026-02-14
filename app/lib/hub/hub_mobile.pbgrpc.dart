// This is a generated file - do not edit.
//
// Generated from hub/hub_mobile.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;

import '../common/common.pb.dart' as $3;
import 'hub_common.pb.dart' as $2;
import 'hub_mobile.pb.dart' as $0;

export 'hub_mobile.pb.dart';

@$pb.GrpcServiceName('nitella.hub.MobileService')
class MobileServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  MobileServiceClient(super.channel, {super.options, super.interceptors});

  /// Node registration via CSR (Courier mode)
  $grpc.ResponseFuture<$1.Empty> registerNodeViaCSR(
    $0.RegisterNodeViaCSRRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$registerNodeViaCSR, request, options: options);
  }

  /// Node registration with existing Cert (PAKE mode)
  $grpc.ResponseFuture<$1.Empty> registerNodeWithCert(
    $0.RegisterNodeWithCertRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$registerNodeWithCert, request, options: options);
  }

  /// Node Management (owner's nodes only)
  $grpc.ResponseFuture<$0.ListNodesResponse> listNodes(
    $0.ListNodesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listNodes, request, options: options);
  }

  $grpc.ResponseFuture<$2.Node> getNode(
    $0.GetNodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getNode, request, options: options);
  }

  $grpc.ResponseFuture<$0.RegisterNodeResponse> registerNode(
    $0.RegisterNodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$registerNode, request, options: options);
  }

  $grpc.ResponseFuture<$2.Empty> approveNode(
    $0.ApproveNodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$approveNode, request, options: options);
  }

  $grpc.ResponseFuture<$2.Empty> deleteNode(
    $0.DeleteNodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteNode, request, options: options);
  }

  /// Commands (forwarded to owner's nodes)
  $grpc.ResponseFuture<$2.CommandResponse> sendCommand(
    $0.CommandRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendCommand, request, options: options);
  }

  /// Real-time Streams
  $grpc.ResponseStream<$2.EncryptedMetrics> streamMetrics(
    $0.StreamMetricsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamMetrics, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.GetMetricsHistoryResponse> getMetricsHistory(
    $0.GetMetricsHistoryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getMetricsHistory, request, options: options);
  }

  $grpc.ResponseStream<$3.Alert> streamAlerts(
    $0.StreamAlertsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamAlerts, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseStream<$2.SignalMessage> streamSignaling(
    $async.Stream<$2.SignalMessage> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$streamSignaling, request, options: options);
  }

  /// Proxy Management (Zero-Trust: encrypted content, Hub only sees IDs)
  $grpc.ResponseFuture<$0.CreateProxyConfigResponse> createProxyConfig(
    $0.CreateProxyConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createProxyConfig, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListProxyConfigsResponse> listProxyConfigs(
    $0.ListProxyConfigsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listProxyConfigs, request, options: options);
  }

  $grpc.ResponseFuture<$2.Empty> deleteProxyConfig(
    $0.DeleteProxyConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteProxyConfig, request, options: options);
  }

  /// Revision Management (E2E encrypted)
  $grpc.ResponseFuture<$0.PushRevisionResponse> pushRevision(
    $0.PushRevisionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pushRevision, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetRevisionResponse> getRevision(
    $0.GetRevisionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getRevision, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListRevisionsResponse> listRevisions(
    $0.ListRevisionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listRevisions, request, options: options);
  }

  $grpc.ResponseFuture<$0.FlushRevisionsResponse> flushRevisions(
    $0.FlushRevisionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$flushRevisions, request, options: options);
  }

  // method descriptors

  static final _$registerNodeViaCSR =
      $grpc.ClientMethod<$0.RegisterNodeViaCSRRequest, $1.Empty>(
          '/nitella.hub.MobileService/RegisterNodeViaCSR',
          ($0.RegisterNodeViaCSRRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$registerNodeWithCert =
      $grpc.ClientMethod<$0.RegisterNodeWithCertRequest, $1.Empty>(
          '/nitella.hub.MobileService/RegisterNodeWithCert',
          ($0.RegisterNodeWithCertRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$listNodes =
      $grpc.ClientMethod<$0.ListNodesRequest, $0.ListNodesResponse>(
          '/nitella.hub.MobileService/ListNodes',
          ($0.ListNodesRequest value) => value.writeToBuffer(),
          $0.ListNodesResponse.fromBuffer);
  static final _$getNode = $grpc.ClientMethod<$0.GetNodeRequest, $2.Node>(
      '/nitella.hub.MobileService/GetNode',
      ($0.GetNodeRequest value) => value.writeToBuffer(),
      $2.Node.fromBuffer);
  static final _$registerNode =
      $grpc.ClientMethod<$0.RegisterNodeRequest, $0.RegisterNodeResponse>(
          '/nitella.hub.MobileService/RegisterNode',
          ($0.RegisterNodeRequest value) => value.writeToBuffer(),
          $0.RegisterNodeResponse.fromBuffer);
  static final _$approveNode =
      $grpc.ClientMethod<$0.ApproveNodeRequest, $2.Empty>(
          '/nitella.hub.MobileService/ApproveNode',
          ($0.ApproveNodeRequest value) => value.writeToBuffer(),
          $2.Empty.fromBuffer);
  static final _$deleteNode =
      $grpc.ClientMethod<$0.DeleteNodeRequest, $2.Empty>(
          '/nitella.hub.MobileService/DeleteNode',
          ($0.DeleteNodeRequest value) => value.writeToBuffer(),
          $2.Empty.fromBuffer);
  static final _$sendCommand =
      $grpc.ClientMethod<$0.CommandRequest, $2.CommandResponse>(
          '/nitella.hub.MobileService/SendCommand',
          ($0.CommandRequest value) => value.writeToBuffer(),
          $2.CommandResponse.fromBuffer);
  static final _$streamMetrics =
      $grpc.ClientMethod<$0.StreamMetricsRequest, $2.EncryptedMetrics>(
          '/nitella.hub.MobileService/StreamMetrics',
          ($0.StreamMetricsRequest value) => value.writeToBuffer(),
          $2.EncryptedMetrics.fromBuffer);
  static final _$getMetricsHistory = $grpc.ClientMethod<
          $0.GetMetricsHistoryRequest, $0.GetMetricsHistoryResponse>(
      '/nitella.hub.MobileService/GetMetricsHistory',
      ($0.GetMetricsHistoryRequest value) => value.writeToBuffer(),
      $0.GetMetricsHistoryResponse.fromBuffer);
  static final _$streamAlerts =
      $grpc.ClientMethod<$0.StreamAlertsRequest, $3.Alert>(
          '/nitella.hub.MobileService/StreamAlerts',
          ($0.StreamAlertsRequest value) => value.writeToBuffer(),
          $3.Alert.fromBuffer);
  static final _$streamSignaling =
      $grpc.ClientMethod<$2.SignalMessage, $2.SignalMessage>(
          '/nitella.hub.MobileService/StreamSignaling',
          ($2.SignalMessage value) => value.writeToBuffer(),
          $2.SignalMessage.fromBuffer);
  static final _$createProxyConfig = $grpc.ClientMethod<
          $0.CreateProxyConfigRequest, $0.CreateProxyConfigResponse>(
      '/nitella.hub.MobileService/CreateProxyConfig',
      ($0.CreateProxyConfigRequest value) => value.writeToBuffer(),
      $0.CreateProxyConfigResponse.fromBuffer);
  static final _$listProxyConfigs = $grpc.ClientMethod<
          $0.ListProxyConfigsRequest, $0.ListProxyConfigsResponse>(
      '/nitella.hub.MobileService/ListProxyConfigs',
      ($0.ListProxyConfigsRequest value) => value.writeToBuffer(),
      $0.ListProxyConfigsResponse.fromBuffer);
  static final _$deleteProxyConfig =
      $grpc.ClientMethod<$0.DeleteProxyConfigRequest, $2.Empty>(
          '/nitella.hub.MobileService/DeleteProxyConfig',
          ($0.DeleteProxyConfigRequest value) => value.writeToBuffer(),
          $2.Empty.fromBuffer);
  static final _$pushRevision =
      $grpc.ClientMethod<$0.PushRevisionRequest, $0.PushRevisionResponse>(
          '/nitella.hub.MobileService/PushRevision',
          ($0.PushRevisionRequest value) => value.writeToBuffer(),
          $0.PushRevisionResponse.fromBuffer);
  static final _$getRevision =
      $grpc.ClientMethod<$0.GetRevisionRequest, $0.GetRevisionResponse>(
          '/nitella.hub.MobileService/GetRevision',
          ($0.GetRevisionRequest value) => value.writeToBuffer(),
          $0.GetRevisionResponse.fromBuffer);
  static final _$listRevisions =
      $grpc.ClientMethod<$0.ListRevisionsRequest, $0.ListRevisionsResponse>(
          '/nitella.hub.MobileService/ListRevisions',
          ($0.ListRevisionsRequest value) => value.writeToBuffer(),
          $0.ListRevisionsResponse.fromBuffer);
  static final _$flushRevisions =
      $grpc.ClientMethod<$0.FlushRevisionsRequest, $0.FlushRevisionsResponse>(
          '/nitella.hub.MobileService/FlushRevisions',
          ($0.FlushRevisionsRequest value) => value.writeToBuffer(),
          $0.FlushRevisionsResponse.fromBuffer);
}

@$pb.GrpcServiceName('nitella.hub.MobileService')
abstract class MobileServiceBase extends $grpc.Service {
  $core.String get $name => 'nitella.hub.MobileService';

  MobileServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.RegisterNodeViaCSRRequest, $1.Empty>(
        'RegisterNodeViaCSR',
        registerNodeViaCSR_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RegisterNodeViaCSRRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RegisterNodeWithCertRequest, $1.Empty>(
        'RegisterNodeWithCert',
        registerNodeWithCert_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RegisterNodeWithCertRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListNodesRequest, $0.ListNodesResponse>(
        'ListNodes',
        listNodes_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListNodesRequest.fromBuffer(value),
        ($0.ListNodesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetNodeRequest, $2.Node>(
        'GetNode',
        getNode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetNodeRequest.fromBuffer(value),
        ($2.Node value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.RegisterNodeRequest, $0.RegisterNodeResponse>(
            'RegisterNode',
            registerNode_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.RegisterNodeRequest.fromBuffer(value),
            ($0.RegisterNodeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ApproveNodeRequest, $2.Empty>(
        'ApproveNode',
        approveNode_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ApproveNodeRequest.fromBuffer(value),
        ($2.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteNodeRequest, $2.Empty>(
        'DeleteNode',
        deleteNode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteNodeRequest.fromBuffer(value),
        ($2.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CommandRequest, $2.CommandResponse>(
        'SendCommand',
        sendCommand_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CommandRequest.fromBuffer(value),
        ($2.CommandResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.StreamMetricsRequest, $2.EncryptedMetrics>(
            'StreamMetrics',
            streamMetrics_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.StreamMetricsRequest.fromBuffer(value),
            ($2.EncryptedMetrics value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetMetricsHistoryRequest,
            $0.GetMetricsHistoryResponse>(
        'GetMetricsHistory',
        getMetricsHistory_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetMetricsHistoryRequest.fromBuffer(value),
        ($0.GetMetricsHistoryResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamAlertsRequest, $3.Alert>(
        'StreamAlerts',
        streamAlerts_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamAlertsRequest.fromBuffer(value),
        ($3.Alert value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.SignalMessage, $2.SignalMessage>(
        'StreamSignaling',
        streamSignaling,
        true,
        true,
        ($core.List<$core.int> value) => $2.SignalMessage.fromBuffer(value),
        ($2.SignalMessage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateProxyConfigRequest,
            $0.CreateProxyConfigResponse>(
        'CreateProxyConfig',
        createProxyConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateProxyConfigRequest.fromBuffer(value),
        ($0.CreateProxyConfigResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListProxyConfigsRequest,
            $0.ListProxyConfigsResponse>(
        'ListProxyConfigs',
        listProxyConfigs_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListProxyConfigsRequest.fromBuffer(value),
        ($0.ListProxyConfigsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteProxyConfigRequest, $2.Empty>(
        'DeleteProxyConfig',
        deleteProxyConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteProxyConfigRequest.fromBuffer(value),
        ($2.Empty value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.PushRevisionRequest, $0.PushRevisionResponse>(
            'PushRevision',
            pushRevision_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.PushRevisionRequest.fromBuffer(value),
            ($0.PushRevisionResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetRevisionRequest, $0.GetRevisionResponse>(
            'GetRevision',
            getRevision_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetRevisionRequest.fromBuffer(value),
            ($0.GetRevisionResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListRevisionsRequest, $0.ListRevisionsResponse>(
            'ListRevisions',
            listRevisions_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListRevisionsRequest.fromBuffer(value),
            ($0.ListRevisionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FlushRevisionsRequest,
            $0.FlushRevisionsResponse>(
        'FlushRevisions',
        flushRevisions_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.FlushRevisionsRequest.fromBuffer(value),
        ($0.FlushRevisionsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$1.Empty> registerNodeViaCSR_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RegisterNodeViaCSRRequest> $request) async {
    return registerNodeViaCSR($call, await $request);
  }

  $async.Future<$1.Empty> registerNodeViaCSR(
      $grpc.ServiceCall call, $0.RegisterNodeViaCSRRequest request);

  $async.Future<$1.Empty> registerNodeWithCert_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RegisterNodeWithCertRequest> $request) async {
    return registerNodeWithCert($call, await $request);
  }

  $async.Future<$1.Empty> registerNodeWithCert(
      $grpc.ServiceCall call, $0.RegisterNodeWithCertRequest request);

  $async.Future<$0.ListNodesResponse> listNodes_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListNodesRequest> $request) async {
    return listNodes($call, await $request);
  }

  $async.Future<$0.ListNodesResponse> listNodes(
      $grpc.ServiceCall call, $0.ListNodesRequest request);

  $async.Future<$2.Node> getNode_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetNodeRequest> $request) async {
    return getNode($call, await $request);
  }

  $async.Future<$2.Node> getNode(
      $grpc.ServiceCall call, $0.GetNodeRequest request);

  $async.Future<$0.RegisterNodeResponse> registerNode_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RegisterNodeRequest> $request) async {
    return registerNode($call, await $request);
  }

  $async.Future<$0.RegisterNodeResponse> registerNode(
      $grpc.ServiceCall call, $0.RegisterNodeRequest request);

  $async.Future<$2.Empty> approveNode_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ApproveNodeRequest> $request) async {
    return approveNode($call, await $request);
  }

  $async.Future<$2.Empty> approveNode(
      $grpc.ServiceCall call, $0.ApproveNodeRequest request);

  $async.Future<$2.Empty> deleteNode_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteNodeRequest> $request) async {
    return deleteNode($call, await $request);
  }

  $async.Future<$2.Empty> deleteNode(
      $grpc.ServiceCall call, $0.DeleteNodeRequest request);

  $async.Future<$2.CommandResponse> sendCommand_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CommandRequest> $request) async {
    return sendCommand($call, await $request);
  }

  $async.Future<$2.CommandResponse> sendCommand(
      $grpc.ServiceCall call, $0.CommandRequest request);

  $async.Stream<$2.EncryptedMetrics> streamMetrics_Pre($grpc.ServiceCall $call,
      $async.Future<$0.StreamMetricsRequest> $request) async* {
    yield* streamMetrics($call, await $request);
  }

  $async.Stream<$2.EncryptedMetrics> streamMetrics(
      $grpc.ServiceCall call, $0.StreamMetricsRequest request);

  $async.Future<$0.GetMetricsHistoryResponse> getMetricsHistory_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetMetricsHistoryRequest> $request) async {
    return getMetricsHistory($call, await $request);
  }

  $async.Future<$0.GetMetricsHistoryResponse> getMetricsHistory(
      $grpc.ServiceCall call, $0.GetMetricsHistoryRequest request);

  $async.Stream<$3.Alert> streamAlerts_Pre($grpc.ServiceCall $call,
      $async.Future<$0.StreamAlertsRequest> $request) async* {
    yield* streamAlerts($call, await $request);
  }

  $async.Stream<$3.Alert> streamAlerts(
      $grpc.ServiceCall call, $0.StreamAlertsRequest request);

  $async.Stream<$2.SignalMessage> streamSignaling(
      $grpc.ServiceCall call, $async.Stream<$2.SignalMessage> request);

  $async.Future<$0.CreateProxyConfigResponse> createProxyConfig_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateProxyConfigRequest> $request) async {
    return createProxyConfig($call, await $request);
  }

  $async.Future<$0.CreateProxyConfigResponse> createProxyConfig(
      $grpc.ServiceCall call, $0.CreateProxyConfigRequest request);

  $async.Future<$0.ListProxyConfigsResponse> listProxyConfigs_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListProxyConfigsRequest> $request) async {
    return listProxyConfigs($call, await $request);
  }

  $async.Future<$0.ListProxyConfigsResponse> listProxyConfigs(
      $grpc.ServiceCall call, $0.ListProxyConfigsRequest request);

  $async.Future<$2.Empty> deleteProxyConfig_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteProxyConfigRequest> $request) async {
    return deleteProxyConfig($call, await $request);
  }

  $async.Future<$2.Empty> deleteProxyConfig(
      $grpc.ServiceCall call, $0.DeleteProxyConfigRequest request);

  $async.Future<$0.PushRevisionResponse> pushRevision_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PushRevisionRequest> $request) async {
    return pushRevision($call, await $request);
  }

  $async.Future<$0.PushRevisionResponse> pushRevision(
      $grpc.ServiceCall call, $0.PushRevisionRequest request);

  $async.Future<$0.GetRevisionResponse> getRevision_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetRevisionRequest> $request) async {
    return getRevision($call, await $request);
  }

  $async.Future<$0.GetRevisionResponse> getRevision(
      $grpc.ServiceCall call, $0.GetRevisionRequest request);

  $async.Future<$0.ListRevisionsResponse> listRevisions_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListRevisionsRequest> $request) async {
    return listRevisions($call, await $request);
  }

  $async.Future<$0.ListRevisionsResponse> listRevisions(
      $grpc.ServiceCall call, $0.ListRevisionsRequest request);

  $async.Future<$0.FlushRevisionsResponse> flushRevisions_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.FlushRevisionsRequest> $request) async {
    return flushRevisions($call, await $request);
  }

  $async.Future<$0.FlushRevisionsResponse> flushRevisions(
      $grpc.ServiceCall call, $0.FlushRevisionsRequest request);
}

@$pb.GrpcServiceName('nitella.hub.PairingService')
class PairingServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  PairingServiceClient(super.channel, {super.options, super.interceptors});

  /// PAKE-based pairing: CLI and Node exchange encrypted messages via Hub
  /// Hub only relays - cannot derive shared secret or decrypt payloads
  /// Flow:
  ///   1. CLI generates code "7-tiger-castle", starts PakeExchange
  ///   2. User tells code to node (verbally or types)
  ///   3. Node connects with same code, joins PakeExchange
  ///   4. Both derive shared secret (Hub cannot compute)
  ///   5. Node sends CSR encrypted with shared secret
  ///   6. CLI signs CSR, sends cert encrypted with shared secret
  $grpc.ResponseStream<$0.PakeMessage> pakeExchange(
    $async.Stream<$0.PakeMessage> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$pakeExchange, request, options: options);
  }

  /// QR-based pairing (offline/air-gapped mode)
  /// Node displays QR with CSR, user scans with CLI, CLI signs and displays cert QR
  /// Hub not involved at all - fully offline
  $grpc.ResponseFuture<$2.Empty> submitSignedCert(
    $0.SubmitSignedCertRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$submitSignedCert, request, options: options);
  }

  // method descriptors

  static final _$pakeExchange =
      $grpc.ClientMethod<$0.PakeMessage, $0.PakeMessage>(
          '/nitella.hub.PairingService/PakeExchange',
          ($0.PakeMessage value) => value.writeToBuffer(),
          $0.PakeMessage.fromBuffer);
  static final _$submitSignedCert =
      $grpc.ClientMethod<$0.SubmitSignedCertRequest, $2.Empty>(
          '/nitella.hub.PairingService/SubmitSignedCert',
          ($0.SubmitSignedCertRequest value) => value.writeToBuffer(),
          $2.Empty.fromBuffer);
}

@$pb.GrpcServiceName('nitella.hub.PairingService')
abstract class PairingServiceBase extends $grpc.Service {
  $core.String get $name => 'nitella.hub.PairingService';

  PairingServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.PakeMessage, $0.PakeMessage>(
        'PakeExchange',
        pakeExchange,
        true,
        true,
        ($core.List<$core.int> value) => $0.PakeMessage.fromBuffer(value),
        ($0.PakeMessage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SubmitSignedCertRequest, $2.Empty>(
        'SubmitSignedCert',
        submitSignedCert_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SubmitSignedCertRequest.fromBuffer(value),
        ($2.Empty value) => value.writeToBuffer()));
  }

  $async.Stream<$0.PakeMessage> pakeExchange(
      $grpc.ServiceCall call, $async.Stream<$0.PakeMessage> request);

  $async.Future<$2.Empty> submitSignedCert_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SubmitSignedCertRequest> $request) async {
    return submitSignedCert($call, await $request);
  }

  $async.Future<$2.Empty> submitSignedCert(
      $grpc.ServiceCall call, $0.SubmitSignedCertRequest request);
}

@$pb.GrpcServiceName('nitella.hub.AuthService')
class AuthServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AuthServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.RegisterUserResponse> registerUser(
    $0.RegisterUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$registerUser, request, options: options);
  }

  $grpc.ResponseFuture<$2.Empty> registerDevice(
    $0.RegisterDeviceRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$registerDevice, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateLicenseResponse> updateLicense(
    $0.UpdateLicenseRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateLicense, request, options: options);
  }

  // method descriptors

  static final _$registerUser =
      $grpc.ClientMethod<$0.RegisterUserRequest, $0.RegisterUserResponse>(
          '/nitella.hub.AuthService/RegisterUser',
          ($0.RegisterUserRequest value) => value.writeToBuffer(),
          $0.RegisterUserResponse.fromBuffer);
  static final _$registerDevice =
      $grpc.ClientMethod<$0.RegisterDeviceRequest, $2.Empty>(
          '/nitella.hub.AuthService/RegisterDevice',
          ($0.RegisterDeviceRequest value) => value.writeToBuffer(),
          $2.Empty.fromBuffer);
  static final _$updateLicense =
      $grpc.ClientMethod<$0.UpdateLicenseRequest, $0.UpdateLicenseResponse>(
          '/nitella.hub.AuthService/UpdateLicense',
          ($0.UpdateLicenseRequest value) => value.writeToBuffer(),
          $0.UpdateLicenseResponse.fromBuffer);
}

@$pb.GrpcServiceName('nitella.hub.AuthService')
abstract class AuthServiceBase extends $grpc.Service {
  $core.String get $name => 'nitella.hub.AuthService';

  AuthServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.RegisterUserRequest, $0.RegisterUserResponse>(
            'RegisterUser',
            registerUser_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.RegisterUserRequest.fromBuffer(value),
            ($0.RegisterUserResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RegisterDeviceRequest, $2.Empty>(
        'RegisterDevice',
        registerDevice_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RegisterDeviceRequest.fromBuffer(value),
        ($2.Empty value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UpdateLicenseRequest, $0.UpdateLicenseResponse>(
            'UpdateLicense',
            updateLicense_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UpdateLicenseRequest.fromBuffer(value),
            ($0.UpdateLicenseResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.RegisterUserResponse> registerUser_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RegisterUserRequest> $request) async {
    return registerUser($call, await $request);
  }

  $async.Future<$0.RegisterUserResponse> registerUser(
      $grpc.ServiceCall call, $0.RegisterUserRequest request);

  $async.Future<$2.Empty> registerDevice_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RegisterDeviceRequest> $request) async {
    return registerDevice($call, await $request);
  }

  $async.Future<$2.Empty> registerDevice(
      $grpc.ServiceCall call, $0.RegisterDeviceRequest request);

  $async.Future<$0.UpdateLicenseResponse> updateLicense_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateLicenseRequest> $request) async {
    return updateLicense($call, await $request);
  }

  $async.Future<$0.UpdateLicenseResponse> updateLicense(
      $grpc.ServiceCall call, $0.UpdateLicenseRequest request);
}
