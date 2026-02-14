// This is a generated file - do not edit.
//
// Generated from hub/hub_node.proto.

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

import '../common/common.pb.dart' as $2;
import 'hub_common.pb.dart' as $1;
import 'hub_node.pb.dart' as $0;

export 'hub_node.pb.dart';

@$pb.GrpcServiceName('nitella.hub.NodeService')
class NodeServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  NodeServiceClient(super.channel, {super.options, super.interceptors});

  /// Registration
  $grpc.ResponseFuture<$0.NodeRegisterResponse> register(
    $0.NodeRegisterRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$register, request, options: options);
  }

  $grpc.ResponseStream<$0.WatchRegistrationResponse> watchRegistration(
    $0.WatchRegistrationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$watchRegistration, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.CheckCertificateResponse> checkCertificate(
    $0.CheckCertificateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$checkCertificate, request, options: options);
  }

  /// Heartbeat / Status
  $grpc.ResponseFuture<$0.HeartbeatResponse> heartbeat(
    $0.HeartbeatRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$heartbeat, request, options: options);
  }

  /// Command Reception (Hub -> Node)
  $grpc.ResponseStream<$1.Command> receiveCommands(
    $0.ReceiveCommandsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$receiveCommands, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Command Response (Node -> Hub) - For Sync E2E
  $grpc.ResponseFuture<$1.Empty> respondToCommand(
    $1.CommandResponse request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$respondToCommand, request, options: options);
  }

  /// Metrics/Logs Push (Node -> Hub) - Zero-Trust: Encrypted
  $grpc.ResponseFuture<$1.Empty> pushMetrics(
    $async.Stream<$1.EncryptedMetrics> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$pushMetrics, request, options: options)
        .single;
  }

  $grpc.ResponseFuture<$1.Empty> pushLogs(
    $async.Stream<$1.EncryptedLogEntry> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$pushLogs, request, options: options).single;
  }

  $grpc.ResponseFuture<$1.Empty> pushAlert(
    $2.Alert request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pushAlert, request, options: options);
  }

  /// Certificate Revocation (Hub -> Node broadcast)
  $grpc.ResponseStream<$1.RevocationEvent> streamRevocations(
    $0.StreamRevocationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamRevocations, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// P2P Signaling (Node <-> Hub <-> Mobile)
  $grpc.ResponseStream<$1.SignalMessage> streamSignaling(
    $async.Stream<$1.SignalMessage> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$streamSignaling, request, options: options);
  }

  // method descriptors

  static final _$register =
      $grpc.ClientMethod<$0.NodeRegisterRequest, $0.NodeRegisterResponse>(
          '/nitella.hub.NodeService/Register',
          ($0.NodeRegisterRequest value) => value.writeToBuffer(),
          $0.NodeRegisterResponse.fromBuffer);
  static final _$watchRegistration = $grpc.ClientMethod<
          $0.WatchRegistrationRequest, $0.WatchRegistrationResponse>(
      '/nitella.hub.NodeService/WatchRegistration',
      ($0.WatchRegistrationRequest value) => value.writeToBuffer(),
      $0.WatchRegistrationResponse.fromBuffer);
  static final _$checkCertificate = $grpc.ClientMethod<
          $0.CheckCertificateRequest, $0.CheckCertificateResponse>(
      '/nitella.hub.NodeService/CheckCertificate',
      ($0.CheckCertificateRequest value) => value.writeToBuffer(),
      $0.CheckCertificateResponse.fromBuffer);
  static final _$heartbeat =
      $grpc.ClientMethod<$0.HeartbeatRequest, $0.HeartbeatResponse>(
          '/nitella.hub.NodeService/Heartbeat',
          ($0.HeartbeatRequest value) => value.writeToBuffer(),
          $0.HeartbeatResponse.fromBuffer);
  static final _$receiveCommands =
      $grpc.ClientMethod<$0.ReceiveCommandsRequest, $1.Command>(
          '/nitella.hub.NodeService/ReceiveCommands',
          ($0.ReceiveCommandsRequest value) => value.writeToBuffer(),
          $1.Command.fromBuffer);
  static final _$respondToCommand =
      $grpc.ClientMethod<$1.CommandResponse, $1.Empty>(
          '/nitella.hub.NodeService/RespondToCommand',
          ($1.CommandResponse value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$pushMetrics =
      $grpc.ClientMethod<$1.EncryptedMetrics, $1.Empty>(
          '/nitella.hub.NodeService/PushMetrics',
          ($1.EncryptedMetrics value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$pushLogs = $grpc.ClientMethod<$1.EncryptedLogEntry, $1.Empty>(
      '/nitella.hub.NodeService/PushLogs',
      ($1.EncryptedLogEntry value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$pushAlert = $grpc.ClientMethod<$2.Alert, $1.Empty>(
      '/nitella.hub.NodeService/PushAlert',
      ($2.Alert value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$streamRevocations =
      $grpc.ClientMethod<$0.StreamRevocationsRequest, $1.RevocationEvent>(
          '/nitella.hub.NodeService/StreamRevocations',
          ($0.StreamRevocationsRequest value) => value.writeToBuffer(),
          $1.RevocationEvent.fromBuffer);
  static final _$streamSignaling =
      $grpc.ClientMethod<$1.SignalMessage, $1.SignalMessage>(
          '/nitella.hub.NodeService/StreamSignaling',
          ($1.SignalMessage value) => value.writeToBuffer(),
          $1.SignalMessage.fromBuffer);
}

@$pb.GrpcServiceName('nitella.hub.NodeService')
abstract class NodeServiceBase extends $grpc.Service {
  $core.String get $name => 'nitella.hub.NodeService';

  NodeServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.NodeRegisterRequest, $0.NodeRegisterResponse>(
            'Register',
            register_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.NodeRegisterRequest.fromBuffer(value),
            ($0.NodeRegisterResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WatchRegistrationRequest,
            $0.WatchRegistrationResponse>(
        'WatchRegistration',
        watchRegistration_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.WatchRegistrationRequest.fromBuffer(value),
        ($0.WatchRegistrationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CheckCertificateRequest,
            $0.CheckCertificateResponse>(
        'CheckCertificate',
        checkCertificate_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CheckCertificateRequest.fromBuffer(value),
        ($0.CheckCertificateResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HeartbeatRequest, $0.HeartbeatResponse>(
        'Heartbeat',
        heartbeat_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HeartbeatRequest.fromBuffer(value),
        ($0.HeartbeatResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ReceiveCommandsRequest, $1.Command>(
        'ReceiveCommands',
        receiveCommands_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.ReceiveCommandsRequest.fromBuffer(value),
        ($1.Command value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.CommandResponse, $1.Empty>(
        'RespondToCommand',
        respondToCommand_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.CommandResponse.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.EncryptedMetrics, $1.Empty>(
        'PushMetrics',
        pushMetrics,
        true,
        false,
        ($core.List<$core.int> value) => $1.EncryptedMetrics.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.EncryptedLogEntry, $1.Empty>(
        'PushLogs',
        pushLogs,
        true,
        false,
        ($core.List<$core.int> value) => $1.EncryptedLogEntry.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.Alert, $1.Empty>(
        'PushAlert',
        pushAlert_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.Alert.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.StreamRevocationsRequest, $1.RevocationEvent>(
            'StreamRevocations',
            streamRevocations_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.StreamRevocationsRequest.fromBuffer(value),
            ($1.RevocationEvent value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.SignalMessage, $1.SignalMessage>(
        'StreamSignaling',
        streamSignaling,
        true,
        true,
        ($core.List<$core.int> value) => $1.SignalMessage.fromBuffer(value),
        ($1.SignalMessage value) => value.writeToBuffer()));
  }

  $async.Future<$0.NodeRegisterResponse> register_Pre($grpc.ServiceCall $call,
      $async.Future<$0.NodeRegisterRequest> $request) async {
    return register($call, await $request);
  }

  $async.Future<$0.NodeRegisterResponse> register(
      $grpc.ServiceCall call, $0.NodeRegisterRequest request);

  $async.Stream<$0.WatchRegistrationResponse> watchRegistration_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.WatchRegistrationRequest> $request) async* {
    yield* watchRegistration($call, await $request);
  }

  $async.Stream<$0.WatchRegistrationResponse> watchRegistration(
      $grpc.ServiceCall call, $0.WatchRegistrationRequest request);

  $async.Future<$0.CheckCertificateResponse> checkCertificate_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CheckCertificateRequest> $request) async {
    return checkCertificate($call, await $request);
  }

  $async.Future<$0.CheckCertificateResponse> checkCertificate(
      $grpc.ServiceCall call, $0.CheckCertificateRequest request);

  $async.Future<$0.HeartbeatResponse> heartbeat_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HeartbeatRequest> $request) async {
    return heartbeat($call, await $request);
  }

  $async.Future<$0.HeartbeatResponse> heartbeat(
      $grpc.ServiceCall call, $0.HeartbeatRequest request);

  $async.Stream<$1.Command> receiveCommands_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ReceiveCommandsRequest> $request) async* {
    yield* receiveCommands($call, await $request);
  }

  $async.Stream<$1.Command> receiveCommands(
      $grpc.ServiceCall call, $0.ReceiveCommandsRequest request);

  $async.Future<$1.Empty> respondToCommand_Pre($grpc.ServiceCall $call,
      $async.Future<$1.CommandResponse> $request) async {
    return respondToCommand($call, await $request);
  }

  $async.Future<$1.Empty> respondToCommand(
      $grpc.ServiceCall call, $1.CommandResponse request);

  $async.Future<$1.Empty> pushMetrics(
      $grpc.ServiceCall call, $async.Stream<$1.EncryptedMetrics> request);

  $async.Future<$1.Empty> pushLogs(
      $grpc.ServiceCall call, $async.Stream<$1.EncryptedLogEntry> request);

  $async.Future<$1.Empty> pushAlert_Pre(
      $grpc.ServiceCall $call, $async.Future<$2.Alert> $request) async {
    return pushAlert($call, await $request);
  }

  $async.Future<$1.Empty> pushAlert($grpc.ServiceCall call, $2.Alert request);

  $async.Stream<$1.RevocationEvent> streamRevocations_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamRevocationsRequest> $request) async* {
    yield* streamRevocations($call, await $request);
  }

  $async.Stream<$1.RevocationEvent> streamRevocations(
      $grpc.ServiceCall call, $0.StreamRevocationsRequest request);

  $async.Stream<$1.SignalMessage> streamSignaling(
      $grpc.ServiceCall call, $async.Stream<$1.SignalMessage> request);
}
