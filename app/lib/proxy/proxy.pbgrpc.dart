// This is a generated file - do not edit.
//
// Generated from proxy/proxy.proto.

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

import 'proxy.pb.dart' as $0;

export 'proxy.pb.dart';

@$pb.GrpcServiceName('nitella.proxy.ProxyControlService')
class ProxyControlServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ProxyControlServiceClient(super.channel, {super.options, super.interceptors});

  /// E2E Encrypted Command (same envelope as Hub relay)
  $grpc.ResponseFuture<$0.SendCommandResponse> sendCommand(
    $0.SendCommandRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendCommand, request, options: options);
  }

  /// Observability (E2E encrypted streams)
  $grpc.ResponseStream<$0.EncryptedStreamPayload> streamConnections(
    $0.StreamConnectionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamConnections, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseStream<$0.EncryptedStreamPayload> streamMetrics(
    $0.StreamMetricsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamMetrics, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$sendCommand =
      $grpc.ClientMethod<$0.SendCommandRequest, $0.SendCommandResponse>(
          '/nitella.proxy.ProxyControlService/SendCommand',
          ($0.SendCommandRequest value) => value.writeToBuffer(),
          $0.SendCommandResponse.fromBuffer);
  static final _$streamConnections = $grpc.ClientMethod<
          $0.StreamConnectionsRequest, $0.EncryptedStreamPayload>(
      '/nitella.proxy.ProxyControlService/StreamConnections',
      ($0.StreamConnectionsRequest value) => value.writeToBuffer(),
      $0.EncryptedStreamPayload.fromBuffer);
  static final _$streamMetrics =
      $grpc.ClientMethod<$0.StreamMetricsRequest, $0.EncryptedStreamPayload>(
          '/nitella.proxy.ProxyControlService/StreamMetrics',
          ($0.StreamMetricsRequest value) => value.writeToBuffer(),
          $0.EncryptedStreamPayload.fromBuffer);
}

@$pb.GrpcServiceName('nitella.proxy.ProxyControlService')
abstract class ProxyControlServiceBase extends $grpc.Service {
  $core.String get $name => 'nitella.proxy.ProxyControlService';

  ProxyControlServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.SendCommandRequest, $0.SendCommandResponse>(
            'SendCommand',
            sendCommand_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SendCommandRequest.fromBuffer(value),
            ($0.SendCommandResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamConnectionsRequest,
            $0.EncryptedStreamPayload>(
        'StreamConnections',
        streamConnections_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamConnectionsRequest.fromBuffer(value),
        ($0.EncryptedStreamPayload value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.StreamMetricsRequest, $0.EncryptedStreamPayload>(
            'StreamMetrics',
            streamMetrics_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.StreamMetricsRequest.fromBuffer(value),
            ($0.EncryptedStreamPayload value) => value.writeToBuffer()));
  }

  $async.Future<$0.SendCommandResponse> sendCommand_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SendCommandRequest> $request) async {
    return sendCommand($call, await $request);
  }

  $async.Future<$0.SendCommandResponse> sendCommand(
      $grpc.ServiceCall call, $0.SendCommandRequest request);

  $async.Stream<$0.EncryptedStreamPayload> streamConnections_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamConnectionsRequest> $request) async* {
    yield* streamConnections($call, await $request);
  }

  $async.Stream<$0.EncryptedStreamPayload> streamConnections(
      $grpc.ServiceCall call, $0.StreamConnectionsRequest request);

  $async.Stream<$0.EncryptedStreamPayload> streamMetrics_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamMetricsRequest> $request) async* {
    yield* streamMetrics($call, await $request);
  }

  $async.Stream<$0.EncryptedStreamPayload> streamMetrics(
      $grpc.ServiceCall call, $0.StreamMetricsRequest request);
}
