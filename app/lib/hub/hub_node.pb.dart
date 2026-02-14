// This is a generated file - do not edit.
//
// Generated from hub/hub_node.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../proxy/proxy.pb.dart' as $3;
import 'hub_common.pbenum.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

enum NodeCommand_Command {
  addRule,
  removeRule,
  fetchRules,
  getConnections,
  closeConnection,
  closeAll,
  getIpStats,
  getGeoStats,
  getStatsSummary,
  resolveApproval,
  listProxies,
  createProxy,
  updateProxy,
  deleteProxy,
  enableProxy,
  disableProxy,
  notSet
}

/// NodeCommand for E2E Encrypted Payload (Inner)
class NodeCommand extends $pb.GeneratedMessage {
  factory NodeCommand({
    $3.AddRuleRequest? addRule,
    $3.RemoveRuleRequest? removeRule,
    $3.ListRulesRequest? fetchRules,
    $3.GetActiveConnectionsRequest? getConnections,
    $3.CloseConnectionRequest? closeConnection,
    $3.CloseAllConnectionsRequest? closeAll,
    $3.GetIPStatsRequest? getIpStats,
    $3.GetGeoStatsRequest? getGeoStats,
    $3.GetStatsSummaryRequest? getStatsSummary,
    $3.ResolveApprovalRequest? resolveApproval,
    $3.ListProxiesRequest? listProxies,
    $3.CreateProxyRequest? createProxy,
    $3.UpdateProxyRequest? updateProxy,
    $3.DeleteProxyRequest? deleteProxy,
    $3.EnableProxyRequest? enableProxy,
    $3.DisableProxyRequest? disableProxy,
  }) {
    final result = create();
    if (addRule != null) result.addRule = addRule;
    if (removeRule != null) result.removeRule = removeRule;
    if (fetchRules != null) result.fetchRules = fetchRules;
    if (getConnections != null) result.getConnections = getConnections;
    if (closeConnection != null) result.closeConnection = closeConnection;
    if (closeAll != null) result.closeAll = closeAll;
    if (getIpStats != null) result.getIpStats = getIpStats;
    if (getGeoStats != null) result.getGeoStats = getGeoStats;
    if (getStatsSummary != null) result.getStatsSummary = getStatsSummary;
    if (resolveApproval != null) result.resolveApproval = resolveApproval;
    if (listProxies != null) result.listProxies = listProxies;
    if (createProxy != null) result.createProxy = createProxy;
    if (updateProxy != null) result.updateProxy = updateProxy;
    if (deleteProxy != null) result.deleteProxy = deleteProxy;
    if (enableProxy != null) result.enableProxy = enableProxy;
    if (disableProxy != null) result.disableProxy = disableProxy;
    return result;
  }

  NodeCommand._();

  factory NodeCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NodeCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, NodeCommand_Command>
      _NodeCommand_CommandByTag = {
    1: NodeCommand_Command.addRule,
    2: NodeCommand_Command.removeRule,
    3: NodeCommand_Command.fetchRules,
    4: NodeCommand_Command.getConnections,
    5: NodeCommand_Command.closeConnection,
    6: NodeCommand_Command.closeAll,
    7: NodeCommand_Command.getIpStats,
    8: NodeCommand_Command.getGeoStats,
    9: NodeCommand_Command.getStatsSummary,
    10: NodeCommand_Command.resolveApproval,
    11: NodeCommand_Command.listProxies,
    12: NodeCommand_Command.createProxy,
    13: NodeCommand_Command.updateProxy,
    14: NodeCommand_Command.deleteProxy,
    15: NodeCommand_Command.enableProxy,
    16: NodeCommand_Command.disableProxy,
    0: NodeCommand_Command.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeCommand',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
    ..aOM<$3.AddRuleRequest>(1, _omitFieldNames ? '' : 'addRule',
        subBuilder: $3.AddRuleRequest.create)
    ..aOM<$3.RemoveRuleRequest>(2, _omitFieldNames ? '' : 'removeRule',
        subBuilder: $3.RemoveRuleRequest.create)
    ..aOM<$3.ListRulesRequest>(3, _omitFieldNames ? '' : 'fetchRules',
        subBuilder: $3.ListRulesRequest.create)
    ..aOM<$3.GetActiveConnectionsRequest>(
        4, _omitFieldNames ? '' : 'getConnections',
        subBuilder: $3.GetActiveConnectionsRequest.create)
    ..aOM<$3.CloseConnectionRequest>(
        5, _omitFieldNames ? '' : 'closeConnection',
        subBuilder: $3.CloseConnectionRequest.create)
    ..aOM<$3.CloseAllConnectionsRequest>(6, _omitFieldNames ? '' : 'closeAll',
        subBuilder: $3.CloseAllConnectionsRequest.create)
    ..aOM<$3.GetIPStatsRequest>(7, _omitFieldNames ? '' : 'getIpStats',
        subBuilder: $3.GetIPStatsRequest.create)
    ..aOM<$3.GetGeoStatsRequest>(8, _omitFieldNames ? '' : 'getGeoStats',
        subBuilder: $3.GetGeoStatsRequest.create)
    ..aOM<$3.GetStatsSummaryRequest>(
        9, _omitFieldNames ? '' : 'getStatsSummary',
        subBuilder: $3.GetStatsSummaryRequest.create)
    ..aOM<$3.ResolveApprovalRequest>(
        10, _omitFieldNames ? '' : 'resolveApproval',
        subBuilder: $3.ResolveApprovalRequest.create)
    ..aOM<$3.ListProxiesRequest>(11, _omitFieldNames ? '' : 'listProxies',
        subBuilder: $3.ListProxiesRequest.create)
    ..aOM<$3.CreateProxyRequest>(12, _omitFieldNames ? '' : 'createProxy',
        subBuilder: $3.CreateProxyRequest.create)
    ..aOM<$3.UpdateProxyRequest>(13, _omitFieldNames ? '' : 'updateProxy',
        subBuilder: $3.UpdateProxyRequest.create)
    ..aOM<$3.DeleteProxyRequest>(14, _omitFieldNames ? '' : 'deleteProxy',
        subBuilder: $3.DeleteProxyRequest.create)
    ..aOM<$3.EnableProxyRequest>(15, _omitFieldNames ? '' : 'enableProxy',
        subBuilder: $3.EnableProxyRequest.create)
    ..aOM<$3.DisableProxyRequest>(16, _omitFieldNames ? '' : 'disableProxy',
        subBuilder: $3.DisableProxyRequest.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeCommand copyWith(void Function(NodeCommand) updates) =>
      super.copyWith((message) => updates(message as NodeCommand))
          as NodeCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NodeCommand create() => NodeCommand._();
  @$core.override
  NodeCommand createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NodeCommand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NodeCommand>(create);
  static NodeCommand? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  NodeCommand_Command whichCommand() =>
      _NodeCommand_CommandByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  void clearCommand() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $3.AddRuleRequest get addRule => $_getN(0);
  @$pb.TagNumber(1)
  set addRule($3.AddRuleRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAddRule() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddRule() => $_clearField(1);
  @$pb.TagNumber(1)
  $3.AddRuleRequest ensureAddRule() => $_ensure(0);

  @$pb.TagNumber(2)
  $3.RemoveRuleRequest get removeRule => $_getN(1);
  @$pb.TagNumber(2)
  set removeRule($3.RemoveRuleRequest value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRemoveRule() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemoveRule() => $_clearField(2);
  @$pb.TagNumber(2)
  $3.RemoveRuleRequest ensureRemoveRule() => $_ensure(1);

  @$pb.TagNumber(3)
  $3.ListRulesRequest get fetchRules => $_getN(2);
  @$pb.TagNumber(3)
  set fetchRules($3.ListRulesRequest value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasFetchRules() => $_has(2);
  @$pb.TagNumber(3)
  void clearFetchRules() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.ListRulesRequest ensureFetchRules() => $_ensure(2);

  /// Connection Management
  @$pb.TagNumber(4)
  $3.GetActiveConnectionsRequest get getConnections => $_getN(3);
  @$pb.TagNumber(4)
  set getConnections($3.GetActiveConnectionsRequest value) =>
      $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasGetConnections() => $_has(3);
  @$pb.TagNumber(4)
  void clearGetConnections() => $_clearField(4);
  @$pb.TagNumber(4)
  $3.GetActiveConnectionsRequest ensureGetConnections() => $_ensure(3);

  @$pb.TagNumber(5)
  $3.CloseConnectionRequest get closeConnection => $_getN(4);
  @$pb.TagNumber(5)
  set closeConnection($3.CloseConnectionRequest value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCloseConnection() => $_has(4);
  @$pb.TagNumber(5)
  void clearCloseConnection() => $_clearField(5);
  @$pb.TagNumber(5)
  $3.CloseConnectionRequest ensureCloseConnection() => $_ensure(4);

  @$pb.TagNumber(6)
  $3.CloseAllConnectionsRequest get closeAll => $_getN(5);
  @$pb.TagNumber(6)
  set closeAll($3.CloseAllConnectionsRequest value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCloseAll() => $_has(5);
  @$pb.TagNumber(6)
  void clearCloseAll() => $_clearField(6);
  @$pb.TagNumber(6)
  $3.CloseAllConnectionsRequest ensureCloseAll() => $_ensure(5);

  /// Statistics Access (For UI)
  @$pb.TagNumber(7)
  $3.GetIPStatsRequest get getIpStats => $_getN(6);
  @$pb.TagNumber(7)
  set getIpStats($3.GetIPStatsRequest value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasGetIpStats() => $_has(6);
  @$pb.TagNumber(7)
  void clearGetIpStats() => $_clearField(7);
  @$pb.TagNumber(7)
  $3.GetIPStatsRequest ensureGetIpStats() => $_ensure(6);

  @$pb.TagNumber(8)
  $3.GetGeoStatsRequest get getGeoStats => $_getN(7);
  @$pb.TagNumber(8)
  set getGeoStats($3.GetGeoStatsRequest value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasGetGeoStats() => $_has(7);
  @$pb.TagNumber(8)
  void clearGetGeoStats() => $_clearField(8);
  @$pb.TagNumber(8)
  $3.GetGeoStatsRequest ensureGetGeoStats() => $_ensure(7);

  @$pb.TagNumber(9)
  $3.GetStatsSummaryRequest get getStatsSummary => $_getN(8);
  @$pb.TagNumber(9)
  set getStatsSummary($3.GetStatsSummaryRequest value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasGetStatsSummary() => $_has(8);
  @$pb.TagNumber(9)
  void clearGetStatsSummary() => $_clearField(9);
  @$pb.TagNumber(9)
  $3.GetStatsSummaryRequest ensureGetStatsSummary() => $_ensure(8);

  @$pb.TagNumber(10)
  $3.ResolveApprovalRequest get resolveApproval => $_getN(9);
  @$pb.TagNumber(10)
  set resolveApproval($3.ResolveApprovalRequest value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasResolveApproval() => $_has(9);
  @$pb.TagNumber(10)
  void clearResolveApproval() => $_clearField(10);
  @$pb.TagNumber(10)
  $3.ResolveApprovalRequest ensureResolveApproval() => $_ensure(9);

  /// Proxy Management
  @$pb.TagNumber(11)
  $3.ListProxiesRequest get listProxies => $_getN(10);
  @$pb.TagNumber(11)
  set listProxies($3.ListProxiesRequest value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasListProxies() => $_has(10);
  @$pb.TagNumber(11)
  void clearListProxies() => $_clearField(11);
  @$pb.TagNumber(11)
  $3.ListProxiesRequest ensureListProxies() => $_ensure(10);

  @$pb.TagNumber(12)
  $3.CreateProxyRequest get createProxy => $_getN(11);
  @$pb.TagNumber(12)
  set createProxy($3.CreateProxyRequest value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasCreateProxy() => $_has(11);
  @$pb.TagNumber(12)
  void clearCreateProxy() => $_clearField(12);
  @$pb.TagNumber(12)
  $3.CreateProxyRequest ensureCreateProxy() => $_ensure(11);

  @$pb.TagNumber(13)
  $3.UpdateProxyRequest get updateProxy => $_getN(12);
  @$pb.TagNumber(13)
  set updateProxy($3.UpdateProxyRequest value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasUpdateProxy() => $_has(12);
  @$pb.TagNumber(13)
  void clearUpdateProxy() => $_clearField(13);
  @$pb.TagNumber(13)
  $3.UpdateProxyRequest ensureUpdateProxy() => $_ensure(12);

  @$pb.TagNumber(14)
  $3.DeleteProxyRequest get deleteProxy => $_getN(13);
  @$pb.TagNumber(14)
  set deleteProxy($3.DeleteProxyRequest value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasDeleteProxy() => $_has(13);
  @$pb.TagNumber(14)
  void clearDeleteProxy() => $_clearField(14);
  @$pb.TagNumber(14)
  $3.DeleteProxyRequest ensureDeleteProxy() => $_ensure(13);

  @$pb.TagNumber(15)
  $3.EnableProxyRequest get enableProxy => $_getN(14);
  @$pb.TagNumber(15)
  set enableProxy($3.EnableProxyRequest value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasEnableProxy() => $_has(14);
  @$pb.TagNumber(15)
  void clearEnableProxy() => $_clearField(15);
  @$pb.TagNumber(15)
  $3.EnableProxyRequest ensureEnableProxy() => $_ensure(14);

  @$pb.TagNumber(16)
  $3.DisableProxyRequest get disableProxy => $_getN(15);
  @$pb.TagNumber(16)
  set disableProxy($3.DisableProxyRequest value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasDisableProxy() => $_has(15);
  @$pb.TagNumber(16)
  void clearDisableProxy() => $_clearField(16);
  @$pb.TagNumber(16)
  $3.DisableProxyRequest ensureDisableProxy() => $_ensure(15);
}

/// Registration
class NodeRegisterRequest extends $pb.GeneratedMessage {
  factory NodeRegisterRequest({
    $core.String? registrationCode,
    $core.String? csrPem,
    $core.List<$core.int>? encryptedMetadata,
    $core.Iterable<$core.int>? listenPorts,
    $core.String? version,
    $core.String? inviteCode,
    $core.String? pairingCode,
  }) {
    final result = create();
    if (registrationCode != null) result.registrationCode = registrationCode;
    if (csrPem != null) result.csrPem = csrPem;
    if (encryptedMetadata != null) result.encryptedMetadata = encryptedMetadata;
    if (listenPorts != null) result.listenPorts.addAll(listenPorts);
    if (version != null) result.version = version;
    if (inviteCode != null) result.inviteCode = inviteCode;
    if (pairingCode != null) result.pairingCode = pairingCode;
    return result;
  }

  NodeRegisterRequest._();

  factory NodeRegisterRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NodeRegisterRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeRegisterRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'registrationCode')
    ..aOS(2, _omitFieldNames ? '' : 'csrPem')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'encryptedMetadata', $pb.PbFieldType.OY)
    ..p<$core.int>(4, _omitFieldNames ? '' : 'listenPorts', $pb.PbFieldType.K3)
    ..aOS(5, _omitFieldNames ? '' : 'version')
    ..aOS(6, _omitFieldNames ? '' : 'inviteCode')
    ..aOS(7, _omitFieldNames ? '' : 'pairingCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeRegisterRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeRegisterRequest copyWith(void Function(NodeRegisterRequest) updates) =>
      super.copyWith((message) => updates(message as NodeRegisterRequest))
          as NodeRegisterRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NodeRegisterRequest create() => NodeRegisterRequest._();
  @$core.override
  NodeRegisterRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NodeRegisterRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NodeRegisterRequest>(create);
  static NodeRegisterRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get registrationCode => $_getSZ(0);
  @$pb.TagNumber(1)
  set registrationCode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRegistrationCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegistrationCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get csrPem => $_getSZ(1);
  @$pb.TagNumber(2)
  set csrPem($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCsrPem() => $_has(1);
  @$pb.TagNumber(2)
  void clearCsrPem() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get encryptedMetadata => $_getN(2);
  @$pb.TagNumber(3)
  set encryptedMetadata($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEncryptedMetadata() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncryptedMetadata() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.int> get listenPorts => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get version => $_getSZ(4);
  @$pb.TagNumber(5)
  set version($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get inviteCode => $_getSZ(5);
  @$pb.TagNumber(6)
  set inviteCode($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasInviteCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearInviteCode() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get pairingCode => $_getSZ(6);
  @$pb.TagNumber(7)
  set pairingCode($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPairingCode() => $_has(6);
  @$pb.TagNumber(7)
  void clearPairingCode() => $_clearField(7);
}

class NodeRegisterResponse extends $pb.GeneratedMessage {
  factory NodeRegisterResponse({
    $core.String? registrationCode,
    $1.RegistrationStatus? status,
    $core.String? certPem,
    $core.String? caPem,
    $core.String? watchSecret,
  }) {
    final result = create();
    if (registrationCode != null) result.registrationCode = registrationCode;
    if (status != null) result.status = status;
    if (certPem != null) result.certPem = certPem;
    if (caPem != null) result.caPem = caPem;
    if (watchSecret != null) result.watchSecret = watchSecret;
    return result;
  }

  NodeRegisterResponse._();

  factory NodeRegisterResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NodeRegisterResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeRegisterResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'registrationCode')
    ..aE<$1.RegistrationStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: $1.RegistrationStatus.values)
    ..aOS(3, _omitFieldNames ? '' : 'certPem')
    ..aOS(4, _omitFieldNames ? '' : 'caPem')
    ..aOS(5, _omitFieldNames ? '' : 'watchSecret')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeRegisterResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeRegisterResponse copyWith(void Function(NodeRegisterResponse) updates) =>
      super.copyWith((message) => updates(message as NodeRegisterResponse))
          as NodeRegisterResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NodeRegisterResponse create() => NodeRegisterResponse._();
  @$core.override
  NodeRegisterResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NodeRegisterResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NodeRegisterResponse>(create);
  static NodeRegisterResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get registrationCode => $_getSZ(0);
  @$pb.TagNumber(1)
  set registrationCode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRegistrationCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegistrationCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.RegistrationStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status($1.RegistrationStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get certPem => $_getSZ(2);
  @$pb.TagNumber(3)
  set certPem($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCertPem() => $_has(2);
  @$pb.TagNumber(3)
  void clearCertPem() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get caPem => $_getSZ(3);
  @$pb.TagNumber(4)
  set caPem($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCaPem() => $_has(3);
  @$pb.TagNumber(4)
  void clearCaPem() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get watchSecret => $_getSZ(4);
  @$pb.TagNumber(5)
  set watchSecret($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWatchSecret() => $_has(4);
  @$pb.TagNumber(5)
  void clearWatchSecret() => $_clearField(5);
}

class WatchRegistrationRequest extends $pb.GeneratedMessage {
  factory WatchRegistrationRequest({
    $core.String? registrationCode,
    $core.String? watchSecret,
  }) {
    final result = create();
    if (registrationCode != null) result.registrationCode = registrationCode;
    if (watchSecret != null) result.watchSecret = watchSecret;
    return result;
  }

  WatchRegistrationRequest._();

  factory WatchRegistrationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WatchRegistrationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchRegistrationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'registrationCode')
    ..aOS(2, _omitFieldNames ? '' : 'watchSecret')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchRegistrationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchRegistrationRequest copyWith(
          void Function(WatchRegistrationRequest) updates) =>
      super.copyWith((message) => updates(message as WatchRegistrationRequest))
          as WatchRegistrationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WatchRegistrationRequest create() => WatchRegistrationRequest._();
  @$core.override
  WatchRegistrationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WatchRegistrationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchRegistrationRequest>(create);
  static WatchRegistrationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get registrationCode => $_getSZ(0);
  @$pb.TagNumber(1)
  set registrationCode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRegistrationCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegistrationCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get watchSecret => $_getSZ(1);
  @$pb.TagNumber(2)
  set watchSecret($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWatchSecret() => $_has(1);
  @$pb.TagNumber(2)
  void clearWatchSecret() => $_clearField(2);
}

class WatchRegistrationResponse extends $pb.GeneratedMessage {
  factory WatchRegistrationResponse({
    $1.RegistrationStatus? status,
    $core.String? certPem,
    $core.String? caPem,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (certPem != null) result.certPem = certPem;
    if (caPem != null) result.caPem = caPem;
    return result;
  }

  WatchRegistrationResponse._();

  factory WatchRegistrationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WatchRegistrationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchRegistrationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aE<$1.RegistrationStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: $1.RegistrationStatus.values)
    ..aOS(2, _omitFieldNames ? '' : 'certPem')
    ..aOS(3, _omitFieldNames ? '' : 'caPem')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchRegistrationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchRegistrationResponse copyWith(
          void Function(WatchRegistrationResponse) updates) =>
      super.copyWith((message) => updates(message as WatchRegistrationResponse))
          as WatchRegistrationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WatchRegistrationResponse create() => WatchRegistrationResponse._();
  @$core.override
  WatchRegistrationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WatchRegistrationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchRegistrationResponse>(create);
  static WatchRegistrationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.RegistrationStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status($1.RegistrationStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

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
}

class CheckCertificateRequest extends $pb.GeneratedMessage {
  factory CheckCertificateRequest({
    $core.String? fingerprint,
  }) {
    final result = create();
    if (fingerprint != null) result.fingerprint = fingerprint;
    return result;
  }

  CheckCertificateRequest._();

  factory CheckCertificateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckCertificateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckCertificateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fingerprint')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckCertificateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckCertificateRequest copyWith(
          void Function(CheckCertificateRequest) updates) =>
      super.copyWith((message) => updates(message as CheckCertificateRequest))
          as CheckCertificateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckCertificateRequest create() => CheckCertificateRequest._();
  @$core.override
  CheckCertificateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckCertificateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckCertificateRequest>(create);
  static CheckCertificateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fingerprint => $_getSZ(0);
  @$pb.TagNumber(1)
  set fingerprint($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFingerprint() => $_has(0);
  @$pb.TagNumber(1)
  void clearFingerprint() => $_clearField(1);
}

class CheckCertificateResponse extends $pb.GeneratedMessage {
  factory CheckCertificateResponse({
    $core.bool? found,
    $core.String? certPem,
    $core.String? caPem,
  }) {
    final result = create();
    if (found != null) result.found = found;
    if (certPem != null) result.certPem = certPem;
    if (caPem != null) result.caPem = caPem;
    return result;
  }

  CheckCertificateResponse._();

  factory CheckCertificateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckCertificateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckCertificateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'found')
    ..aOS(2, _omitFieldNames ? '' : 'certPem')
    ..aOS(3, _omitFieldNames ? '' : 'caPem')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckCertificateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckCertificateResponse copyWith(
          void Function(CheckCertificateResponse) updates) =>
      super.copyWith((message) => updates(message as CheckCertificateResponse))
          as CheckCertificateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckCertificateResponse create() => CheckCertificateResponse._();
  @$core.override
  CheckCertificateResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckCertificateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckCertificateResponse>(create);
  static CheckCertificateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get found => $_getBF(0);
  @$pb.TagNumber(1)
  set found($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFound() => $_has(0);
  @$pb.TagNumber(1)
  void clearFound() => $_clearField(1);

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
}

/// Heartbeat
class HeartbeatRequest extends $pb.GeneratedMessage {
  factory HeartbeatRequest({
    $core.String? nodeId,
    $1.NodeStatus? status,
    $fixnum.Int64? uptimeSeconds,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (status != null) result.status = status;
    if (uptimeSeconds != null) result.uptimeSeconds = uptimeSeconds;
    return result;
  }

  HeartbeatRequest._();

  factory HeartbeatRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HeartbeatRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HeartbeatRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aE<$1.NodeStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: $1.NodeStatus.values)
    ..aInt64(3, _omitFieldNames ? '' : 'uptimeSeconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeartbeatRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeartbeatRequest copyWith(void Function(HeartbeatRequest) updates) =>
      super.copyWith((message) => updates(message as HeartbeatRequest))
          as HeartbeatRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HeartbeatRequest create() => HeartbeatRequest._();
  @$core.override
  HeartbeatRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HeartbeatRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HeartbeatRequest>(create);
  static HeartbeatRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.NodeStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status($1.NodeStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get uptimeSeconds => $_getI64(2);
  @$pb.TagNumber(3)
  set uptimeSeconds($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUptimeSeconds() => $_has(2);
  @$pb.TagNumber(3)
  void clearUptimeSeconds() => $_clearField(3);
}

class HeartbeatResponse extends $pb.GeneratedMessage {
  factory HeartbeatResponse({
    $core.bool? rulesChanged,
    $core.bool? configChanged,
  }) {
    final result = create();
    if (rulesChanged != null) result.rulesChanged = rulesChanged;
    if (configChanged != null) result.configChanged = configChanged;
    return result;
  }

  HeartbeatResponse._();

  factory HeartbeatResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HeartbeatResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HeartbeatResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'rulesChanged')
    ..aOB(2, _omitFieldNames ? '' : 'configChanged')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeartbeatResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeartbeatResponse copyWith(void Function(HeartbeatResponse) updates) =>
      super.copyWith((message) => updates(message as HeartbeatResponse))
          as HeartbeatResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HeartbeatResponse create() => HeartbeatResponse._();
  @$core.override
  HeartbeatResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HeartbeatResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HeartbeatResponse>(create);
  static HeartbeatResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get rulesChanged => $_getBF(0);
  @$pb.TagNumber(1)
  set rulesChanged($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRulesChanged() => $_has(0);
  @$pb.TagNumber(1)
  void clearRulesChanged() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get configChanged => $_getBF(1);
  @$pb.TagNumber(2)
  set configChanged($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConfigChanged() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfigChanged() => $_clearField(2);
}

/// Commands
class ReceiveCommandsRequest extends $pb.GeneratedMessage {
  factory ReceiveCommandsRequest({
    $core.String? nodeId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    return result;
  }

  ReceiveCommandsRequest._();

  factory ReceiveCommandsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReceiveCommandsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReceiveCommandsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveCommandsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveCommandsRequest copyWith(
          void Function(ReceiveCommandsRequest) updates) =>
      super.copyWith((message) => updates(message as ReceiveCommandsRequest))
          as ReceiveCommandsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReceiveCommandsRequest create() => ReceiveCommandsRequest._();
  @$core.override
  ReceiveCommandsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReceiveCommandsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReceiveCommandsRequest>(create);
  static ReceiveCommandsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);
}

/// Revocations
class StreamRevocationsRequest extends $pb.GeneratedMessage {
  factory StreamRevocationsRequest({
    $core.String? nodeId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    return result;
  }

  StreamRevocationsRequest._();

  factory StreamRevocationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamRevocationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamRevocationsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamRevocationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamRevocationsRequest copyWith(
          void Function(StreamRevocationsRequest) updates) =>
      super.copyWith((message) => updates(message as StreamRevocationsRequest))
          as StreamRevocationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamRevocationsRequest create() => StreamRevocationsRequest._();
  @$core.override
  StreamRevocationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamRevocationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamRevocationsRequest>(create);
  static StreamRevocationsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
