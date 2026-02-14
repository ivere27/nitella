// This is a generated file - do not edit.
//
// Generated from hub/hub_mobile.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $4;

import '../common/common.pb.dart' as $3;
import 'hub_common.pb.dart' as $2;
import 'hub_mobile.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'hub_mobile.pbenum.dart';

/// Node Management
class RegisterNodeViaCSRRequest extends $pb.GeneratedMessage {
  factory RegisterNodeViaCSRRequest({
    $core.String? certPem,
    $core.List<$core.int>? encryptedMetadata,
    $core.String? nodeId,
  }) {
    final result = create();
    if (certPem != null) result.certPem = certPem;
    if (encryptedMetadata != null) result.encryptedMetadata = encryptedMetadata;
    if (nodeId != null) result.nodeId = nodeId;
    return result;
  }

  RegisterNodeViaCSRRequest._();

  factory RegisterNodeViaCSRRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterNodeViaCSRRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterNodeViaCSRRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'certPem')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'encryptedMetadata', $pb.PbFieldType.OY)
    ..aOS(3, _omitFieldNames ? '' : 'nodeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterNodeViaCSRRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterNodeViaCSRRequest copyWith(
          void Function(RegisterNodeViaCSRRequest) updates) =>
      super.copyWith((message) => updates(message as RegisterNodeViaCSRRequest))
          as RegisterNodeViaCSRRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterNodeViaCSRRequest create() => RegisterNodeViaCSRRequest._();
  @$core.override
  RegisterNodeViaCSRRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterNodeViaCSRRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterNodeViaCSRRequest>(create);
  static RegisterNodeViaCSRRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get certPem => $_getSZ(0);
  @$pb.TagNumber(1)
  set certPem($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCertPem() => $_has(0);
  @$pb.TagNumber(1)
  void clearCertPem() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get encryptedMetadata => $_getN(1);
  @$pb.TagNumber(2)
  set encryptedMetadata($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEncryptedMetadata() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptedMetadata() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get nodeId => $_getSZ(2);
  @$pb.TagNumber(3)
  set nodeId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeId() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeId() => $_clearField(3);
}

class RegisterNodeWithCertRequest extends $pb.GeneratedMessage {
  factory RegisterNodeWithCertRequest({
    $core.String? nodeId,
    $core.String? certPem,
    $core.String? routingToken,
    $core.List<$core.int>? encryptedMetadata,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (certPem != null) result.certPem = certPem;
    if (routingToken != null) result.routingToken = routingToken;
    if (encryptedMetadata != null) result.encryptedMetadata = encryptedMetadata;
    return result;
  }

  RegisterNodeWithCertRequest._();

  factory RegisterNodeWithCertRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterNodeWithCertRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterNodeWithCertRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'certPem')
    ..aOS(3, _omitFieldNames ? '' : 'routingToken')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'encryptedMetadata', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterNodeWithCertRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterNodeWithCertRequest copyWith(
          void Function(RegisterNodeWithCertRequest) updates) =>
      super.copyWith(
              (message) => updates(message as RegisterNodeWithCertRequest))
          as RegisterNodeWithCertRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterNodeWithCertRequest create() =>
      RegisterNodeWithCertRequest._();
  @$core.override
  RegisterNodeWithCertRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterNodeWithCertRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterNodeWithCertRequest>(create);
  static RegisterNodeWithCertRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get certPem => $_getSZ(1);
  @$pb.TagNumber(2)
  set certPem($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCertPem() => $_has(1);
  @$pb.TagNumber(2)
  void clearCertPem() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get routingToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set routingToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRoutingToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoutingToken() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get encryptedMetadata => $_getN(3);
  @$pb.TagNumber(4)
  set encryptedMetadata($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEncryptedMetadata() => $_has(3);
  @$pb.TagNumber(4)
  void clearEncryptedMetadata() => $_clearField(4);
}

class ListNodesRequest extends $pb.GeneratedMessage {
  factory ListNodesRequest({
    $core.String? filter,
    $core.Iterable<$core.String>? routingTokens,
  }) {
    final result = create();
    if (filter != null) result.filter = filter;
    if (routingTokens != null) result.routingTokens.addAll(routingTokens);
    return result;
  }

  ListNodesRequest._();

  factory ListNodesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListNodesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListNodesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filter')
    ..pPS(2, _omitFieldNames ? '' : 'routingTokens')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListNodesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListNodesRequest copyWith(void Function(ListNodesRequest) updates) =>
      super.copyWith((message) => updates(message as ListNodesRequest))
          as ListNodesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListNodesRequest create() => ListNodesRequest._();
  @$core.override
  ListNodesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListNodesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListNodesRequest>(create);
  static ListNodesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filter => $_getSZ(0);
  @$pb.TagNumber(1)
  set filter($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFilter() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilter() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get routingTokens => $_getList(1);
}

class ListNodesResponse extends $pb.GeneratedMessage {
  factory ListNodesResponse({
    $core.Iterable<$2.Node>? nodes,
    $core.int? totalCount,
  }) {
    final result = create();
    if (nodes != null) result.nodes.addAll(nodes);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListNodesResponse._();

  factory ListNodesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListNodesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListNodesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<$2.Node>(1, _omitFieldNames ? '' : 'nodes',
        subBuilder: $2.Node.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListNodesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListNodesResponse copyWith(void Function(ListNodesResponse) updates) =>
      super.copyWith((message) => updates(message as ListNodesResponse))
          as ListNodesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListNodesResponse create() => ListNodesResponse._();
  @$core.override
  ListNodesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListNodesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListNodesResponse>(create);
  static ListNodesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$2.Node> get nodes => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class GetNodeRequest extends $pb.GeneratedMessage {
  factory GetNodeRequest({
    $core.String? nodeId,
    $core.String? routingToken,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (routingToken != null) result.routingToken = routingToken;
    return result;
  }

  GetNodeRequest._();

  factory GetNodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'routingToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNodeRequest copyWith(void Function(GetNodeRequest) updates) =>
      super.copyWith((message) => updates(message as GetNodeRequest))
          as GetNodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNodeRequest create() => GetNodeRequest._();
  @$core.override
  GetNodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNodeRequest>(create);
  static GetNodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get routingToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set routingToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRoutingToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoutingToken() => $_clearField(2);
}

class RegisterNodeRequest extends $pb.GeneratedMessage {
  factory RegisterNodeRequest({
    $core.String? registrationCode,
  }) {
    final result = create();
    if (registrationCode != null) result.registrationCode = registrationCode;
    return result;
  }

  RegisterNodeRequest._();

  factory RegisterNodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterNodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterNodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'registrationCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterNodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterNodeRequest copyWith(void Function(RegisterNodeRequest) updates) =>
      super.copyWith((message) => updates(message as RegisterNodeRequest))
          as RegisterNodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterNodeRequest create() => RegisterNodeRequest._();
  @$core.override
  RegisterNodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterNodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterNodeRequest>(create);
  static RegisterNodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get registrationCode => $_getSZ(0);
  @$pb.TagNumber(1)
  set registrationCode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRegistrationCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegistrationCode() => $_clearField(1);
}

class RegisterNodeResponse extends $pb.GeneratedMessage {
  factory RegisterNodeResponse({
    $core.String? nodeId,
    $core.List<$core.int>? encryptedMetadata,
    $core.String? csrPem,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (encryptedMetadata != null) result.encryptedMetadata = encryptedMetadata;
    if (csrPem != null) result.csrPem = csrPem;
    return result;
  }

  RegisterNodeResponse._();

  factory RegisterNodeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterNodeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterNodeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'encryptedMetadata', $pb.PbFieldType.OY)
    ..aOS(3, _omitFieldNames ? '' : 'csrPem')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterNodeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterNodeResponse copyWith(void Function(RegisterNodeResponse) updates) =>
      super.copyWith((message) => updates(message as RegisterNodeResponse))
          as RegisterNodeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterNodeResponse create() => RegisterNodeResponse._();
  @$core.override
  RegisterNodeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterNodeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterNodeResponse>(create);
  static RegisterNodeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get encryptedMetadata => $_getN(1);
  @$pb.TagNumber(2)
  set encryptedMetadata($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEncryptedMetadata() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptedMetadata() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get csrPem => $_getSZ(2);
  @$pb.TagNumber(3)
  set csrPem($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCsrPem() => $_has(2);
  @$pb.TagNumber(3)
  void clearCsrPem() => $_clearField(3);
}

class ApproveNodeRequest extends $pb.GeneratedMessage {
  factory ApproveNodeRequest({
    $core.String? registrationCode,
    $core.String? certPem,
    $core.String? caPem,
    $core.String? routingToken,
  }) {
    final result = create();
    if (registrationCode != null) result.registrationCode = registrationCode;
    if (certPem != null) result.certPem = certPem;
    if (caPem != null) result.caPem = caPem;
    if (routingToken != null) result.routingToken = routingToken;
    return result;
  }

  ApproveNodeRequest._();

  factory ApproveNodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApproveNodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApproveNodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'registrationCode')
    ..aOS(2, _omitFieldNames ? '' : 'certPem')
    ..aOS(3, _omitFieldNames ? '' : 'caPem')
    ..aOS(4, _omitFieldNames ? '' : 'routingToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApproveNodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApproveNodeRequest copyWith(void Function(ApproveNodeRequest) updates) =>
      super.copyWith((message) => updates(message as ApproveNodeRequest))
          as ApproveNodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApproveNodeRequest create() => ApproveNodeRequest._();
  @$core.override
  ApproveNodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApproveNodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApproveNodeRequest>(create);
  static ApproveNodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get registrationCode => $_getSZ(0);
  @$pb.TagNumber(1)
  set registrationCode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRegistrationCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegistrationCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get certPem => $_getSZ(1);
  @$pb.TagNumber(2)
  set certPem($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCertPem() => $_has(1);
  @$pb.TagNumber(2)
  void clearCertPem() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get caPem => $_getSZ(2);
  @$pb.TagNumber(3)
  set caPem($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCaPem() => $_has(2);
  @$pb.TagNumber(3)
  void clearCaPem() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get routingToken => $_getSZ(3);
  @$pb.TagNumber(4)
  set routingToken($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRoutingToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearRoutingToken() => $_clearField(4);
}

class DeleteNodeRequest extends $pb.GeneratedMessage {
  factory DeleteNodeRequest({
    $core.String? nodeId,
    $core.String? routingToken,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (routingToken != null) result.routingToken = routingToken;
    return result;
  }

  DeleteNodeRequest._();

  factory DeleteNodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteNodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteNodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'routingToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteNodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteNodeRequest copyWith(void Function(DeleteNodeRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteNodeRequest))
          as DeleteNodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteNodeRequest create() => DeleteNodeRequest._();
  @$core.override
  DeleteNodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteNodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteNodeRequest>(create);
  static DeleteNodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get routingToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set routingToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRoutingToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoutingToken() => $_clearField(2);
}

/// Commands (E2E encrypted only)
class CommandRequest extends $pb.GeneratedMessage {
  factory CommandRequest({
    $core.String? nodeId,
    $3.EncryptedPayload? encrypted,
    $core.String? routingToken,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (encrypted != null) result.encrypted = encrypted;
    if (routingToken != null) result.routingToken = routingToken;
    return result;
  }

  CommandRequest._();

  factory CommandRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommandRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOM<$3.EncryptedPayload>(2, _omitFieldNames ? '' : 'encrypted',
        subBuilder: $3.EncryptedPayload.create)
    ..aOS(3, _omitFieldNames ? '' : 'routingToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandRequest copyWith(void Function(CommandRequest) updates) =>
      super.copyWith((message) => updates(message as CommandRequest))
          as CommandRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommandRequest create() => CommandRequest._();
  @$core.override
  CommandRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CommandRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommandRequest>(create);
  static CommandRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $3.EncryptedPayload get encrypted => $_getN(1);
  @$pb.TagNumber(2)
  set encrypted($3.EncryptedPayload value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEncrypted() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncrypted() => $_clearField(2);
  @$pb.TagNumber(2)
  $3.EncryptedPayload ensureEncrypted() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get routingToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set routingToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRoutingToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoutingToken() => $_clearField(3);
}

/// Metrics
class StreamMetricsRequest extends $pb.GeneratedMessage {
  factory StreamMetricsRequest({
    $core.String? nodeId,
    $core.String? routingToken,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (routingToken != null) result.routingToken = routingToken;
    return result;
  }

  StreamMetricsRequest._();

  factory StreamMetricsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamMetricsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamMetricsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'routingToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamMetricsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamMetricsRequest copyWith(void Function(StreamMetricsRequest) updates) =>
      super.copyWith((message) => updates(message as StreamMetricsRequest))
          as StreamMetricsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamMetricsRequest create() => StreamMetricsRequest._();
  @$core.override
  StreamMetricsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamMetricsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamMetricsRequest>(create);
  static StreamMetricsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get routingToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set routingToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRoutingToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoutingToken() => $_clearField(2);
}

class GetMetricsHistoryRequest extends $pb.GeneratedMessage {
  factory GetMetricsHistoryRequest({
    $core.String? nodeId,
    $core.String? routingToken,
    $4.Timestamp? startTime,
    $4.Timestamp? endTime,
    $core.int? limit,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (routingToken != null) result.routingToken = routingToken;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (limit != null) result.limit = limit;
    return result;
  }

  GetMetricsHistoryRequest._();

  factory GetMetricsHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMetricsHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMetricsHistoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'routingToken')
    ..aOM<$4.Timestamp>(3, _omitFieldNames ? '' : 'startTime',
        subBuilder: $4.Timestamp.create)
    ..aOM<$4.Timestamp>(4, _omitFieldNames ? '' : 'endTime',
        subBuilder: $4.Timestamp.create)
    ..aI(5, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMetricsHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMetricsHistoryRequest copyWith(
          void Function(GetMetricsHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as GetMetricsHistoryRequest))
          as GetMetricsHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMetricsHistoryRequest create() => GetMetricsHistoryRequest._();
  @$core.override
  GetMetricsHistoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMetricsHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMetricsHistoryRequest>(create);
  static GetMetricsHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get routingToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set routingToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRoutingToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoutingToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $4.Timestamp get startTime => $_getN(2);
  @$pb.TagNumber(3)
  set startTime($4.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStartTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartTime() => $_clearField(3);
  @$pb.TagNumber(3)
  $4.Timestamp ensureStartTime() => $_ensure(2);

  @$pb.TagNumber(4)
  $4.Timestamp get endTime => $_getN(3);
  @$pb.TagNumber(4)
  set endTime($4.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasEndTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearEndTime() => $_clearField(4);
  @$pb.TagNumber(4)
  $4.Timestamp ensureEndTime() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.int get limit => $_getIZ(4);
  @$pb.TagNumber(5)
  set limit($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLimit() => $_has(4);
  @$pb.TagNumber(5)
  void clearLimit() => $_clearField(5);
}

class GetMetricsHistoryResponse extends $pb.GeneratedMessage {
  factory GetMetricsHistoryResponse({
    $core.Iterable<$2.EncryptedMetrics>? samples,
  }) {
    final result = create();
    if (samples != null) result.samples.addAll(samples);
    return result;
  }

  GetMetricsHistoryResponse._();

  factory GetMetricsHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMetricsHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMetricsHistoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<$2.EncryptedMetrics>(1, _omitFieldNames ? '' : 'samples',
        subBuilder: $2.EncryptedMetrics.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMetricsHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMetricsHistoryResponse copyWith(
          void Function(GetMetricsHistoryResponse) updates) =>
      super.copyWith((message) => updates(message as GetMetricsHistoryResponse))
          as GetMetricsHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMetricsHistoryResponse create() => GetMetricsHistoryResponse._();
  @$core.override
  GetMetricsHistoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMetricsHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMetricsHistoryResponse>(create);
  static GetMetricsHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$2.EncryptedMetrics> get samples => $_getList(0);
}

/// Alerts
class StreamAlertsRequest extends $pb.GeneratedMessage {
  factory StreamAlertsRequest({
    $core.String? nodeId,
    $core.Iterable<$core.String>? routingTokens,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (routingTokens != null) result.routingTokens.addAll(routingTokens);
    return result;
  }

  StreamAlertsRequest._();

  factory StreamAlertsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamAlertsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamAlertsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..pPS(2, _omitFieldNames ? '' : 'routingTokens')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamAlertsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamAlertsRequest copyWith(void Function(StreamAlertsRequest) updates) =>
      super.copyWith((message) => updates(message as StreamAlertsRequest))
          as StreamAlertsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamAlertsRequest create() => StreamAlertsRequest._();
  @$core.override
  StreamAlertsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamAlertsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamAlertsRequest>(create);
  static StreamAlertsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get routingTokens => $_getList(1);
}

/// QR-based pairing (for offline/air-gapped mode)
/// After CLI signs node's CSR offline via QR, node submits the signed cert
class SubmitSignedCertRequest extends $pb.GeneratedMessage {
  factory SubmitSignedCertRequest({
    $core.String? nodeId,
    $core.String? certPem,
    $core.String? caPem,
    $core.String? fingerprint,
    $core.String? routingToken,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (certPem != null) result.certPem = certPem;
    if (caPem != null) result.caPem = caPem;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (routingToken != null) result.routingToken = routingToken;
    return result;
  }

  SubmitSignedCertRequest._();

  factory SubmitSignedCertRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubmitSignedCertRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmitSignedCertRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'certPem')
    ..aOS(3, _omitFieldNames ? '' : 'caPem')
    ..aOS(4, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(5, _omitFieldNames ? '' : 'routingToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitSignedCertRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitSignedCertRequest copyWith(
          void Function(SubmitSignedCertRequest) updates) =>
      super.copyWith((message) => updates(message as SubmitSignedCertRequest))
          as SubmitSignedCertRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubmitSignedCertRequest create() => SubmitSignedCertRequest._();
  @$core.override
  SubmitSignedCertRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubmitSignedCertRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitSignedCertRequest>(create);
  static SubmitSignedCertRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get certPem => $_getSZ(1);
  @$pb.TagNumber(2)
  set certPem($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCertPem() => $_has(1);
  @$pb.TagNumber(2)
  void clearCertPem() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get caPem => $_getSZ(2);
  @$pb.TagNumber(3)
  set caPem($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCaPem() => $_has(2);
  @$pb.TagNumber(3)
  void clearCaPem() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fingerprint => $_getSZ(3);
  @$pb.TagNumber(4)
  set fingerprint($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFingerprint() => $_has(3);
  @$pb.TagNumber(4)
  void clearFingerprint() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get routingToken => $_getSZ(4);
  @$pb.TagNumber(5)
  set routingToken($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRoutingToken() => $_has(4);
  @$pb.TagNumber(5)
  void clearRoutingToken() => $_clearField(5);
}

/// PAKE (Password-Authenticated Key Exchange) Messages
/// Uses SPAKE2 protocol - Hub relays but cannot derive shared secret
class PakeMessage extends $pb.GeneratedMessage {
  factory PakeMessage({
    $core.String? sessionCode,
    PakeMessage_MessageType? type,
    $core.List<$core.int>? spake2Data,
    $core.List<$core.int>? encryptedPayload,
    $core.List<$core.int>? nonce,
    $core.String? role,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (sessionCode != null) result.sessionCode = sessionCode;
    if (type != null) result.type = type;
    if (spake2Data != null) result.spake2Data = spake2Data;
    if (encryptedPayload != null) result.encryptedPayload = encryptedPayload;
    if (nonce != null) result.nonce = nonce;
    if (role != null) result.role = role;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  PakeMessage._();

  factory PakeMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PakeMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PakeMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionCode')
    ..aE<PakeMessage_MessageType>(2, _omitFieldNames ? '' : 'type',
        enumValues: PakeMessage_MessageType.values)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'spake2Data', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'encryptedPayload', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'nonce', $pb.PbFieldType.OY)
    ..aOS(6, _omitFieldNames ? '' : 'role')
    ..aOS(7, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PakeMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PakeMessage copyWith(void Function(PakeMessage) updates) =>
      super.copyWith((message) => updates(message as PakeMessage))
          as PakeMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PakeMessage create() => PakeMessage._();
  @$core.override
  PakeMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PakeMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PakeMessage>(create);
  static PakeMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionCode => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionCode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionCode() => $_clearField(1);

  @$pb.TagNumber(2)
  PakeMessage_MessageType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(PakeMessage_MessageType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get spake2Data => $_getN(2);
  @$pb.TagNumber(3)
  set spake2Data($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSpake2Data() => $_has(2);
  @$pb.TagNumber(3)
  void clearSpake2Data() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get encryptedPayload => $_getN(3);
  @$pb.TagNumber(4)
  set encryptedPayload($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEncryptedPayload() => $_has(3);
  @$pb.TagNumber(4)
  void clearEncryptedPayload() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get nonce => $_getN(4);
  @$pb.TagNumber(5)
  set nonce($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNonce() => $_has(4);
  @$pb.TagNumber(5)
  void clearNonce() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get role => $_getSZ(5);
  @$pb.TagNumber(6)
  set role($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRole() => $_has(5);
  @$pb.TagNumber(6)
  void clearRole() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get errorMessage => $_getSZ(6);
  @$pb.TagNumber(7)
  set errorMessage($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasErrorMessage() => $_has(6);
  @$pb.TagNumber(7)
  void clearErrorMessage() => $_clearField(7);
}

/// Auth
class RegisterUserRequest extends $pb.GeneratedMessage {
  factory RegisterUserRequest({
    $core.String? rootCertPem,
    $core.String? blindIndex,
    $core.String? inviteCode,
    $core.List<$core.int>? biometricPublicKey,
    $core.List<$core.int>? encryptedProfile,
  }) {
    final result = create();
    if (rootCertPem != null) result.rootCertPem = rootCertPem;
    if (blindIndex != null) result.blindIndex = blindIndex;
    if (inviteCode != null) result.inviteCode = inviteCode;
    if (biometricPublicKey != null)
      result.biometricPublicKey = biometricPublicKey;
    if (encryptedProfile != null) result.encryptedProfile = encryptedProfile;
    return result;
  }

  RegisterUserRequest._();

  factory RegisterUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterUserRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'rootCertPem')
    ..aOS(2, _omitFieldNames ? '' : 'blindIndex')
    ..aOS(3, _omitFieldNames ? '' : 'inviteCode')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'biometricPublicKey', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'encryptedProfile', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterUserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterUserRequest copyWith(void Function(RegisterUserRequest) updates) =>
      super.copyWith((message) => updates(message as RegisterUserRequest))
          as RegisterUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterUserRequest create() => RegisterUserRequest._();
  @$core.override
  RegisterUserRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterUserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterUserRequest>(create);
  static RegisterUserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get rootCertPem => $_getSZ(0);
  @$pb.TagNumber(1)
  set rootCertPem($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRootCertPem() => $_has(0);
  @$pb.TagNumber(1)
  void clearRootCertPem() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get blindIndex => $_getSZ(1);
  @$pb.TagNumber(2)
  set blindIndex($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlindIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlindIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get inviteCode => $_getSZ(2);
  @$pb.TagNumber(3)
  set inviteCode($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInviteCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearInviteCode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get biometricPublicKey => $_getN(3);
  @$pb.TagNumber(4)
  set biometricPublicKey($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBiometricPublicKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearBiometricPublicKey() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get encryptedProfile => $_getN(4);
  @$pb.TagNumber(5)
  set encryptedProfile($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEncryptedProfile() => $_has(4);
  @$pb.TagNumber(5)
  void clearEncryptedProfile() => $_clearField(5);
}

class RegisterUserResponse extends $pb.GeneratedMessage {
  factory RegisterUserResponse({
    $core.String? userId,
    $core.String? tier,
    $core.int? maxNodes,
    $core.String? jwtToken,
    $core.String? refreshToken,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (tier != null) result.tier = tier;
    if (maxNodes != null) result.maxNodes = maxNodes;
    if (jwtToken != null) result.jwtToken = jwtToken;
    if (refreshToken != null) result.refreshToken = refreshToken;
    return result;
  }

  RegisterUserResponse._();

  factory RegisterUserResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterUserResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterUserResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'tier')
    ..aI(3, _omitFieldNames ? '' : 'maxNodes')
    ..aOS(4, _omitFieldNames ? '' : 'jwtToken')
    ..aOS(5, _omitFieldNames ? '' : 'refreshToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterUserResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterUserResponse copyWith(void Function(RegisterUserResponse) updates) =>
      super.copyWith((message) => updates(message as RegisterUserResponse))
          as RegisterUserResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterUserResponse create() => RegisterUserResponse._();
  @$core.override
  RegisterUserResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterUserResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterUserResponse>(create);
  static RegisterUserResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tier => $_getSZ(1);
  @$pb.TagNumber(2)
  set tier($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTier() => $_has(1);
  @$pb.TagNumber(2)
  void clearTier() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get maxNodes => $_getIZ(2);
  @$pb.TagNumber(3)
  set maxNodes($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxNodes() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxNodes() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get jwtToken => $_getSZ(3);
  @$pb.TagNumber(4)
  set jwtToken($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasJwtToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearJwtToken() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get refreshToken => $_getSZ(4);
  @$pb.TagNumber(5)
  set refreshToken($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRefreshToken() => $_has(4);
  @$pb.TagNumber(5)
  void clearRefreshToken() => $_clearField(5);
}

class RegisterDeviceRequest extends $pb.GeneratedMessage {
  factory RegisterDeviceRequest({
    $core.String? userId,
    $core.String? fcmToken,
    $core.String? deviceType,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (fcmToken != null) result.fcmToken = fcmToken;
    if (deviceType != null) result.deviceType = deviceType;
    return result;
  }

  RegisterDeviceRequest._();

  factory RegisterDeviceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterDeviceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterDeviceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'fcmToken')
    ..aOS(3, _omitFieldNames ? '' : 'deviceType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterDeviceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterDeviceRequest copyWith(
          void Function(RegisterDeviceRequest) updates) =>
      super.copyWith((message) => updates(message as RegisterDeviceRequest))
          as RegisterDeviceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterDeviceRequest create() => RegisterDeviceRequest._();
  @$core.override
  RegisterDeviceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterDeviceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterDeviceRequest>(create);
  static RegisterDeviceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fcmToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set fcmToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFcmToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearFcmToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get deviceType => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceType() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceType() => $_clearField(3);
}

class UpdateLicenseRequest extends $pb.GeneratedMessage {
  factory UpdateLicenseRequest({
    $core.String? userId,
    $core.String? licenseKey,
    $core.String? routingToken,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (licenseKey != null) result.licenseKey = licenseKey;
    if (routingToken != null) result.routingToken = routingToken;
    return result;
  }

  UpdateLicenseRequest._();

  factory UpdateLicenseRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateLicenseRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateLicenseRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'licenseKey')
    ..aOS(3, _omitFieldNames ? '' : 'routingToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLicenseRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLicenseRequest copyWith(void Function(UpdateLicenseRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateLicenseRequest))
          as UpdateLicenseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateLicenseRequest create() => UpdateLicenseRequest._();
  @$core.override
  UpdateLicenseRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateLicenseRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateLicenseRequest>(create);
  static UpdateLicenseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get licenseKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set licenseKey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLicenseKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearLicenseKey() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get routingToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set routingToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRoutingToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoutingToken() => $_clearField(3);
}

class UpdateLicenseResponse extends $pb.GeneratedMessage {
  factory UpdateLicenseResponse({
    $core.String? tier,
    $core.int? maxNodes,
    $core.bool? valid,
  }) {
    final result = create();
    if (tier != null) result.tier = tier;
    if (maxNodes != null) result.maxNodes = maxNodes;
    if (valid != null) result.valid = valid;
    return result;
  }

  UpdateLicenseResponse._();

  factory UpdateLicenseResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateLicenseResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateLicenseResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tier')
    ..aI(2, _omitFieldNames ? '' : 'maxNodes')
    ..aOB(3, _omitFieldNames ? '' : 'valid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLicenseResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLicenseResponse copyWith(
          void Function(UpdateLicenseResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateLicenseResponse))
          as UpdateLicenseResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateLicenseResponse create() => UpdateLicenseResponse._();
  @$core.override
  UpdateLicenseResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateLicenseResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateLicenseResponse>(create);
  static UpdateLicenseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tier => $_getSZ(0);
  @$pb.TagNumber(1)
  set tier($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTier() => $_has(0);
  @$pb.TagNumber(1)
  void clearTier() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get maxNodes => $_getIZ(1);
  @$pb.TagNumber(2)
  set maxNodes($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxNodes() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxNodes() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get valid => $_getBF(2);
  @$pb.TagNumber(3)
  set valid($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValid() => $_has(2);
  @$pb.TagNumber(3)
  void clearValid() => $_clearField(3);
}

/// Create new proxy config (just ID, no content yet)
class CreateProxyConfigRequest extends $pb.GeneratedMessage {
  factory CreateProxyConfigRequest({
    $core.String? proxyId,
    $core.String? routingToken,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (routingToken != null) result.routingToken = routingToken;
    return result;
  }

  CreateProxyConfigRequest._();

  factory CreateProxyConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateProxyConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateProxyConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'routingToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProxyConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProxyConfigRequest copyWith(
          void Function(CreateProxyConfigRequest) updates) =>
      super.copyWith((message) => updates(message as CreateProxyConfigRequest))
          as CreateProxyConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateProxyConfigRequest create() => CreateProxyConfigRequest._();
  @$core.override
  CreateProxyConfigRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateProxyConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateProxyConfigRequest>(create);
  static CreateProxyConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get routingToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set routingToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRoutingToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoutingToken() => $_clearField(2);
}

class CreateProxyConfigResponse extends $pb.GeneratedMessage {
  factory CreateProxyConfigResponse({
    $core.bool? success,
    $core.String? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  CreateProxyConfigResponse._();

  factory CreateProxyConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateProxyConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateProxyConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProxyConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProxyConfigResponse copyWith(
          void Function(CreateProxyConfigResponse) updates) =>
      super.copyWith((message) => updates(message as CreateProxyConfigResponse))
          as CreateProxyConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateProxyConfigResponse create() => CreateProxyConfigResponse._();
  @$core.override
  CreateProxyConfigResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateProxyConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateProxyConfigResponse>(create);
  static CreateProxyConfigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
}

/// List proxy configs (returns IDs only - names are encrypted in revisions)
class ListProxyConfigsRequest extends $pb.GeneratedMessage {
  factory ListProxyConfigsRequest({
    $core.String? routingToken,
  }) {
    final result = create();
    if (routingToken != null) result.routingToken = routingToken;
    return result;
  }

  ListProxyConfigsRequest._();

  factory ListProxyConfigsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListProxyConfigsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProxyConfigsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'routingToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProxyConfigsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProxyConfigsRequest copyWith(
          void Function(ListProxyConfigsRequest) updates) =>
      super.copyWith((message) => updates(message as ListProxyConfigsRequest))
          as ListProxyConfigsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProxyConfigsRequest create() => ListProxyConfigsRequest._();
  @$core.override
  ListProxyConfigsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListProxyConfigsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListProxyConfigsRequest>(create);
  static ListProxyConfigsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get routingToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set routingToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoutingToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoutingToken() => $_clearField(1);
}

class ListProxyConfigsResponse extends $pb.GeneratedMessage {
  factory ListProxyConfigsResponse({
    $core.Iterable<ProxyConfigInfo>? proxies,
  }) {
    final result = create();
    if (proxies != null) result.proxies.addAll(proxies);
    return result;
  }

  ListProxyConfigsResponse._();

  factory ListProxyConfigsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListProxyConfigsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProxyConfigsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<ProxyConfigInfo>(1, _omitFieldNames ? '' : 'proxies',
        subBuilder: ProxyConfigInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProxyConfigsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProxyConfigsResponse copyWith(
          void Function(ListProxyConfigsResponse) updates) =>
      super.copyWith((message) => updates(message as ListProxyConfigsResponse))
          as ListProxyConfigsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProxyConfigsResponse create() => ListProxyConfigsResponse._();
  @$core.override
  ListProxyConfigsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListProxyConfigsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListProxyConfigsResponse>(create);
  static ListProxyConfigsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ProxyConfigInfo> get proxies => $_getList(0);
}

class ProxyConfigInfo extends $pb.GeneratedMessage {
  factory ProxyConfigInfo({
    $core.String? proxyId,
    $fixnum.Int64? revisionCount,
    $fixnum.Int64? latestRevision,
    $4.Timestamp? createdAt,
    $4.Timestamp? updatedAt,
    $core.int? totalSizeBytes,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (revisionCount != null) result.revisionCount = revisionCount;
    if (latestRevision != null) result.latestRevision = latestRevision;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (totalSizeBytes != null) result.totalSizeBytes = totalSizeBytes;
    return result;
  }

  ProxyConfigInfo._();

  factory ProxyConfigInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProxyConfigInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProxyConfigInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aInt64(2, _omitFieldNames ? '' : 'revisionCount')
    ..aInt64(3, _omitFieldNames ? '' : 'latestRevision')
    ..aOM<$4.Timestamp>(4, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $4.Timestamp.create)
    ..aOM<$4.Timestamp>(5, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $4.Timestamp.create)
    ..aI(6, _omitFieldNames ? '' : 'totalSizeBytes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProxyConfigInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProxyConfigInfo copyWith(void Function(ProxyConfigInfo) updates) =>
      super.copyWith((message) => updates(message as ProxyConfigInfo))
          as ProxyConfigInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProxyConfigInfo create() => ProxyConfigInfo._();
  @$core.override
  ProxyConfigInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProxyConfigInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProxyConfigInfo>(create);
  static ProxyConfigInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get revisionCount => $_getI64(1);
  @$pb.TagNumber(2)
  set revisionCount($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevisionCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevisionCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get latestRevision => $_getI64(2);
  @$pb.TagNumber(3)
  set latestRevision($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLatestRevision() => $_has(2);
  @$pb.TagNumber(3)
  void clearLatestRevision() => $_clearField(3);

  @$pb.TagNumber(4)
  $4.Timestamp get createdAt => $_getN(3);
  @$pb.TagNumber(4)
  set createdAt($4.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $4.Timestamp ensureCreatedAt() => $_ensure(3);

  @$pb.TagNumber(5)
  $4.Timestamp get updatedAt => $_getN(4);
  @$pb.TagNumber(5)
  set updatedAt($4.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasUpdatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdatedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $4.Timestamp ensureUpdatedAt() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.int get totalSizeBytes => $_getIZ(5);
  @$pb.TagNumber(6)
  set totalSizeBytes($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalSizeBytes() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalSizeBytes() => $_clearField(6);
}

/// Delete proxy config
class DeleteProxyConfigRequest extends $pb.GeneratedMessage {
  factory DeleteProxyConfigRequest({
    $core.String? proxyId,
    $core.String? routingToken,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (routingToken != null) result.routingToken = routingToken;
    return result;
  }

  DeleteProxyConfigRequest._();

  factory DeleteProxyConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteProxyConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteProxyConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'routingToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteProxyConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteProxyConfigRequest copyWith(
          void Function(DeleteProxyConfigRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteProxyConfigRequest))
          as DeleteProxyConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteProxyConfigRequest create() => DeleteProxyConfigRequest._();
  @$core.override
  DeleteProxyConfigRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteProxyConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteProxyConfigRequest>(create);
  static DeleteProxyConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get routingToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set routingToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRoutingToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoutingToken() => $_clearField(2);
}

/// Push new revision
class PushRevisionRequest extends $pb.GeneratedMessage {
  factory PushRevisionRequest({
    $core.String? proxyId,
    $core.String? routingToken,
    $core.List<$core.int>? encryptedBlob,
    $core.int? sizeBytes,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (routingToken != null) result.routingToken = routingToken;
    if (encryptedBlob != null) result.encryptedBlob = encryptedBlob;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    return result;
  }

  PushRevisionRequest._();

  factory PushRevisionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushRevisionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushRevisionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'routingToken')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'encryptedBlob', $pb.PbFieldType.OY)
    ..aI(4, _omitFieldNames ? '' : 'sizeBytes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushRevisionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushRevisionRequest copyWith(void Function(PushRevisionRequest) updates) =>
      super.copyWith((message) => updates(message as PushRevisionRequest))
          as PushRevisionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushRevisionRequest create() => PushRevisionRequest._();
  @$core.override
  PushRevisionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushRevisionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushRevisionRequest>(create);
  static PushRevisionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get routingToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set routingToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRoutingToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoutingToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get encryptedBlob => $_getN(2);
  @$pb.TagNumber(3)
  set encryptedBlob($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEncryptedBlob() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncryptedBlob() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get sizeBytes => $_getIZ(3);
  @$pb.TagNumber(4)
  set sizeBytes($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSizeBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearSizeBytes() => $_clearField(4);
}

class PushRevisionResponse extends $pb.GeneratedMessage {
  factory PushRevisionResponse({
    $core.bool? success,
    $fixnum.Int64? revisionNum,
    $core.int? revisionsKept,
    $core.int? revisionsLimit,
    $core.int? storageUsedKb,
    $core.int? storageLimitKb,
    $core.String? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (revisionNum != null) result.revisionNum = revisionNum;
    if (revisionsKept != null) result.revisionsKept = revisionsKept;
    if (revisionsLimit != null) result.revisionsLimit = revisionsLimit;
    if (storageUsedKb != null) result.storageUsedKb = storageUsedKb;
    if (storageLimitKb != null) result.storageLimitKb = storageLimitKb;
    if (error != null) result.error = error;
    return result;
  }

  PushRevisionResponse._();

  factory PushRevisionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushRevisionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushRevisionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aInt64(2, _omitFieldNames ? '' : 'revisionNum')
    ..aI(3, _omitFieldNames ? '' : 'revisionsKept')
    ..aI(4, _omitFieldNames ? '' : 'revisionsLimit')
    ..aI(5, _omitFieldNames ? '' : 'storageUsedKb')
    ..aI(6, _omitFieldNames ? '' : 'storageLimitKb')
    ..aOS(7, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushRevisionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushRevisionResponse copyWith(void Function(PushRevisionResponse) updates) =>
      super.copyWith((message) => updates(message as PushRevisionResponse))
          as PushRevisionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushRevisionResponse create() => PushRevisionResponse._();
  @$core.override
  PushRevisionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushRevisionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushRevisionResponse>(create);
  static PushRevisionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get revisionNum => $_getI64(1);
  @$pb.TagNumber(2)
  set revisionNum($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevisionNum() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevisionNum() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get revisionsKept => $_getIZ(2);
  @$pb.TagNumber(3)
  set revisionsKept($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRevisionsKept() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevisionsKept() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get revisionsLimit => $_getIZ(3);
  @$pb.TagNumber(4)
  set revisionsLimit($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRevisionsLimit() => $_has(3);
  @$pb.TagNumber(4)
  void clearRevisionsLimit() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get storageUsedKb => $_getIZ(4);
  @$pb.TagNumber(5)
  set storageUsedKb($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStorageUsedKb() => $_has(4);
  @$pb.TagNumber(5)
  void clearStorageUsedKb() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get storageLimitKb => $_getIZ(5);
  @$pb.TagNumber(6)
  set storageLimitKb($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStorageLimitKb() => $_has(5);
  @$pb.TagNumber(6)
  void clearStorageLimitKb() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get error => $_getSZ(6);
  @$pb.TagNumber(7)
  set error($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasError() => $_has(6);
  @$pb.TagNumber(7)
  void clearError() => $_clearField(7);
}

/// Get specific revision
class GetRevisionRequest extends $pb.GeneratedMessage {
  factory GetRevisionRequest({
    $core.String? proxyId,
    $core.String? routingToken,
    $fixnum.Int64? revisionNum,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (routingToken != null) result.routingToken = routingToken;
    if (revisionNum != null) result.revisionNum = revisionNum;
    return result;
  }

  GetRevisionRequest._();

  factory GetRevisionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRevisionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRevisionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'routingToken')
    ..aInt64(3, _omitFieldNames ? '' : 'revisionNum')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRevisionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRevisionRequest copyWith(void Function(GetRevisionRequest) updates) =>
      super.copyWith((message) => updates(message as GetRevisionRequest))
          as GetRevisionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRevisionRequest create() => GetRevisionRequest._();
  @$core.override
  GetRevisionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRevisionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRevisionRequest>(create);
  static GetRevisionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get routingToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set routingToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRoutingToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoutingToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get revisionNum => $_getI64(2);
  @$pb.TagNumber(3)
  set revisionNum($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRevisionNum() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevisionNum() => $_clearField(3);
}

class GetRevisionResponse extends $pb.GeneratedMessage {
  factory GetRevisionResponse({
    $core.List<$core.int>? encryptedBlob,
    $fixnum.Int64? revisionNum,
    $4.Timestamp? createdAt,
    $core.int? sizeBytes,
  }) {
    final result = create();
    if (encryptedBlob != null) result.encryptedBlob = encryptedBlob;
    if (revisionNum != null) result.revisionNum = revisionNum;
    if (createdAt != null) result.createdAt = createdAt;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    return result;
  }

  GetRevisionResponse._();

  factory GetRevisionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRevisionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRevisionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'encryptedBlob', $pb.PbFieldType.OY)
    ..aInt64(2, _omitFieldNames ? '' : 'revisionNum')
    ..aOM<$4.Timestamp>(3, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $4.Timestamp.create)
    ..aI(4, _omitFieldNames ? '' : 'sizeBytes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRevisionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRevisionResponse copyWith(void Function(GetRevisionResponse) updates) =>
      super.copyWith((message) => updates(message as GetRevisionResponse))
          as GetRevisionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRevisionResponse create() => GetRevisionResponse._();
  @$core.override
  GetRevisionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRevisionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRevisionResponse>(create);
  static GetRevisionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get encryptedBlob => $_getN(0);
  @$pb.TagNumber(1)
  set encryptedBlob($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEncryptedBlob() => $_has(0);
  @$pb.TagNumber(1)
  void clearEncryptedBlob() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get revisionNum => $_getI64(1);
  @$pb.TagNumber(2)
  set revisionNum($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevisionNum() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevisionNum() => $_clearField(2);

  @$pb.TagNumber(3)
  $4.Timestamp get createdAt => $_getN(2);
  @$pb.TagNumber(3)
  set createdAt($4.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCreatedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreatedAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $4.Timestamp ensureCreatedAt() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.int get sizeBytes => $_getIZ(3);
  @$pb.TagNumber(4)
  set sizeBytes($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSizeBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearSizeBytes() => $_clearField(4);
}

/// List revisions (metadata only - no content)
class ListRevisionsRequest extends $pb.GeneratedMessage {
  factory ListRevisionsRequest({
    $core.String? proxyId,
    $core.String? routingToken,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (routingToken != null) result.routingToken = routingToken;
    return result;
  }

  ListRevisionsRequest._();

  factory ListRevisionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListRevisionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListRevisionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'routingToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRevisionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRevisionsRequest copyWith(void Function(ListRevisionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListRevisionsRequest))
          as ListRevisionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRevisionsRequest create() => ListRevisionsRequest._();
  @$core.override
  ListRevisionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListRevisionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListRevisionsRequest>(create);
  static ListRevisionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get routingToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set routingToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRoutingToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoutingToken() => $_clearField(2);
}

class ListRevisionsResponse extends $pb.GeneratedMessage {
  factory ListRevisionsResponse({
    $core.Iterable<RevisionMeta>? revisions,
  }) {
    final result = create();
    if (revisions != null) result.revisions.addAll(revisions);
    return result;
  }

  ListRevisionsResponse._();

  factory ListRevisionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListRevisionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListRevisionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<RevisionMeta>(1, _omitFieldNames ? '' : 'revisions',
        subBuilder: RevisionMeta.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRevisionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRevisionsResponse copyWith(
          void Function(ListRevisionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListRevisionsResponse))
          as ListRevisionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRevisionsResponse create() => ListRevisionsResponse._();
  @$core.override
  ListRevisionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListRevisionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListRevisionsResponse>(create);
  static ListRevisionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RevisionMeta> get revisions => $_getList(0);
}

class RevisionMeta extends $pb.GeneratedMessage {
  factory RevisionMeta({
    $fixnum.Int64? revisionNum,
    $core.int? sizeBytes,
    $4.Timestamp? createdAt,
  }) {
    final result = create();
    if (revisionNum != null) result.revisionNum = revisionNum;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  RevisionMeta._();

  factory RevisionMeta.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RevisionMeta.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevisionMeta',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'revisionNum')
    ..aI(2, _omitFieldNames ? '' : 'sizeBytes')
    ..aOM<$4.Timestamp>(3, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $4.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevisionMeta clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevisionMeta copyWith(void Function(RevisionMeta) updates) =>
      super.copyWith((message) => updates(message as RevisionMeta))
          as RevisionMeta;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevisionMeta create() => RevisionMeta._();
  @$core.override
  RevisionMeta createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RevisionMeta getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RevisionMeta>(create);
  static RevisionMeta? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get revisionNum => $_getI64(0);
  @$pb.TagNumber(1)
  set revisionNum($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRevisionNum() => $_has(0);
  @$pb.TagNumber(1)
  void clearRevisionNum() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get sizeBytes => $_getIZ(1);
  @$pb.TagNumber(2)
  set sizeBytes($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSizeBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearSizeBytes() => $_clearField(2);

  @$pb.TagNumber(3)
  $4.Timestamp get createdAt => $_getN(2);
  @$pb.TagNumber(3)
  set createdAt($4.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCreatedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreatedAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $4.Timestamp ensureCreatedAt() => $_ensure(2);
}

/// Flush old revisions
class FlushRevisionsRequest extends $pb.GeneratedMessage {
  factory FlushRevisionsRequest({
    $core.String? proxyId,
    $core.String? routingToken,
    $core.int? keepCount,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (routingToken != null) result.routingToken = routingToken;
    if (keepCount != null) result.keepCount = keepCount;
    return result;
  }

  FlushRevisionsRequest._();

  factory FlushRevisionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FlushRevisionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FlushRevisionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'routingToken')
    ..aI(3, _omitFieldNames ? '' : 'keepCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlushRevisionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlushRevisionsRequest copyWith(
          void Function(FlushRevisionsRequest) updates) =>
      super.copyWith((message) => updates(message as FlushRevisionsRequest))
          as FlushRevisionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FlushRevisionsRequest create() => FlushRevisionsRequest._();
  @$core.override
  FlushRevisionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FlushRevisionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FlushRevisionsRequest>(create);
  static FlushRevisionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get routingToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set routingToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRoutingToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoutingToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get keepCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set keepCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKeepCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearKeepCount() => $_clearField(3);
}

class FlushRevisionsResponse extends $pb.GeneratedMessage {
  factory FlushRevisionsResponse({
    $core.bool? success,
    $core.int? deletedCount,
    $core.int? remainingCount,
    $core.String? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (deletedCount != null) result.deletedCount = deletedCount;
    if (remainingCount != null) result.remainingCount = remainingCount;
    if (error != null) result.error = error;
    return result;
  }

  FlushRevisionsResponse._();

  factory FlushRevisionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FlushRevisionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FlushRevisionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aI(2, _omitFieldNames ? '' : 'deletedCount')
    ..aI(3, _omitFieldNames ? '' : 'remainingCount')
    ..aOS(4, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlushRevisionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlushRevisionsResponse copyWith(
          void Function(FlushRevisionsResponse) updates) =>
      super.copyWith((message) => updates(message as FlushRevisionsResponse))
          as FlushRevisionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FlushRevisionsResponse create() => FlushRevisionsResponse._();
  @$core.override
  FlushRevisionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FlushRevisionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FlushRevisionsResponse>(create);
  static FlushRevisionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get deletedCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set deletedCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeletedCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeletedCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get remainingCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set remainingCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRemainingCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearRemainingCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get error => $_getSZ(3);
  @$pb.TagNumber(4)
  set error($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => $_clearField(4);
}

/// ProxyRevisionPayload is the encrypted payload stored in Hub revisions.
/// This replaces JSON-encoded payload for type safety.
class ProxyRevisionPayload extends $pb.GeneratedMessage {
  factory ProxyRevisionPayload({
    $core.String? name,
    $core.String? description,
    $core.String? commitMessage,
    $core.String? protocolVersion,
    $core.String? configYaml,
    $core.String? configHash,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (commitMessage != null) result.commitMessage = commitMessage;
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    if (configYaml != null) result.configYaml = configYaml;
    if (configHash != null) result.configHash = configHash;
    return result;
  }

  ProxyRevisionPayload._();

  factory ProxyRevisionPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProxyRevisionPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProxyRevisionPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOS(3, _omitFieldNames ? '' : 'commitMessage')
    ..aOS(4, _omitFieldNames ? '' : 'protocolVersion')
    ..aOS(5, _omitFieldNames ? '' : 'configYaml')
    ..aOS(6, _omitFieldNames ? '' : 'configHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProxyRevisionPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProxyRevisionPayload copyWith(void Function(ProxyRevisionPayload) updates) =>
      super.copyWith((message) => updates(message as ProxyRevisionPayload))
          as ProxyRevisionPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProxyRevisionPayload create() => ProxyRevisionPayload._();
  @$core.override
  ProxyRevisionPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProxyRevisionPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProxyRevisionPayload>(create);
  static ProxyRevisionPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get commitMessage => $_getSZ(2);
  @$pb.TagNumber(3)
  set commitMessage($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCommitMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearCommitMessage() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get protocolVersion => $_getSZ(3);
  @$pb.TagNumber(4)
  set protocolVersion($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProtocolVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearProtocolVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get configYaml => $_getSZ(4);
  @$pb.TagNumber(5)
  set configYaml($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConfigYaml() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfigYaml() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get configHash => $_getSZ(5);
  @$pb.TagNumber(6)
  set configHash($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasConfigHash() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfigHash() => $_clearField(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
