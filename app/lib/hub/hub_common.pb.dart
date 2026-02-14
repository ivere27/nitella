// This is a generated file - do not edit.
//
// Generated from hub/hub_common.proto.

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
    as $0;

import '../common/common.pb.dart' as $1;
import 'hub_common.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'hub_common.pbenum.dart';

class Empty extends $pb.GeneratedMessage {
  factory Empty() => create();

  Empty._();

  factory Empty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Empty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Empty',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty copyWith(void Function(Empty) updates) =>
      super.copyWith((message) => updates(message as Empty)) as Empty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Empty create() => Empty._();
  @$core.override
  Empty createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Empty>(create);
  static Empty? _defaultInstance;
}

/// Node represents a managed proxy node
class Node extends $pb.GeneratedMessage {
  factory Node({
    $core.String? id,
    $core.List<$core.int>? encryptedMetadata,
    $core.String? ownerId,
    NodeStatus? status,
    $0.Timestamp? lastSeen,
    $core.String? publicIp,
    $core.Iterable<$core.int>? listenPorts,
    $core.bool? geoipEnabled,
    $core.String? version,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (encryptedMetadata != null) result.encryptedMetadata = encryptedMetadata;
    if (ownerId != null) result.ownerId = ownerId;
    if (status != null) result.status = status;
    if (lastSeen != null) result.lastSeen = lastSeen;
    if (publicIp != null) result.publicIp = publicIp;
    if (listenPorts != null) result.listenPorts.addAll(listenPorts);
    if (geoipEnabled != null) result.geoipEnabled = geoipEnabled;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  Node._();

  factory Node.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Node.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Node',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'encryptedMetadata', $pb.PbFieldType.OY)
    ..aOS(3, _omitFieldNames ? '' : 'ownerId')
    ..aE<NodeStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: NodeStatus.values)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'lastSeen',
        subBuilder: $0.Timestamp.create)
    ..aOS(6, _omitFieldNames ? '' : 'publicIp')
    ..p<$core.int>(7, _omitFieldNames ? '' : 'listenPorts', $pb.PbFieldType.K3)
    ..aOB(8, _omitFieldNames ? '' : 'geoipEnabled')
    ..aOS(9, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Node clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Node copyWith(void Function(Node) updates) =>
      super.copyWith((message) => updates(message as Node)) as Node;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Node create() => Node._();
  @$core.override
  Node createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Node getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Node>(create);
  static Node? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get encryptedMetadata => $_getN(1);
  @$pb.TagNumber(2)
  set encryptedMetadata($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEncryptedMetadata() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptedMetadata() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get ownerId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ownerId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOwnerId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOwnerId() => $_clearField(3);

  @$pb.TagNumber(4)
  NodeStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(NodeStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get lastSeen => $_getN(4);
  @$pb.TagNumber(5)
  set lastSeen($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLastSeen() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastSeen() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureLastSeen() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get publicIp => $_getSZ(5);
  @$pb.TagNumber(6)
  set publicIp($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPublicIp() => $_has(5);
  @$pb.TagNumber(6)
  void clearPublicIp() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.int> get listenPorts => $_getList(6);

  @$pb.TagNumber(8)
  $core.bool get geoipEnabled => $_getBF(7);
  @$pb.TagNumber(8)
  set geoipEnabled($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasGeoipEnabled() => $_has(7);
  @$pb.TagNumber(8)
  void clearGeoipEnabled() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get version => $_getSZ(8);
  @$pb.TagNumber(9)
  set version($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasVersion() => $_has(8);
  @$pb.TagNumber(9)
  void clearVersion() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Timestamp get createdAt => $_getN(9);
  @$pb.TagNumber(10)
  set createdAt($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureCreatedAt() => $_ensure(9);
}

/// Metrics data (plaintext - for local use only)
class Metrics extends $pb.GeneratedMessage {
  factory Metrics({
    $core.String? nodeId,
    $0.Timestamp? timestamp,
    $fixnum.Int64? connectionsActive,
    $fixnum.Int64? connectionsTotal,
    $fixnum.Int64? bytesIn,
    $fixnum.Int64? bytesOut,
    $fixnum.Int64? blockedCount,
    $core.Iterable<$core.MapEntry<$core.String, $fixnum.Int64>>? rulesHitCount,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (timestamp != null) result.timestamp = timestamp;
    if (connectionsActive != null) result.connectionsActive = connectionsActive;
    if (connectionsTotal != null) result.connectionsTotal = connectionsTotal;
    if (bytesIn != null) result.bytesIn = bytesIn;
    if (bytesOut != null) result.bytesOut = bytesOut;
    if (blockedCount != null) result.blockedCount = blockedCount;
    if (rulesHitCount != null) result.rulesHitCount.addEntries(rulesHitCount);
    return result;
  }

  Metrics._();

  factory Metrics.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Metrics.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Metrics',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aInt64(3, _omitFieldNames ? '' : 'connectionsActive')
    ..aInt64(4, _omitFieldNames ? '' : 'connectionsTotal')
    ..aInt64(5, _omitFieldNames ? '' : 'bytesIn')
    ..aInt64(6, _omitFieldNames ? '' : 'bytesOut')
    ..aInt64(7, _omitFieldNames ? '' : 'blockedCount')
    ..m<$core.String, $fixnum.Int64>(8, _omitFieldNames ? '' : 'rulesHitCount',
        entryClassName: 'Metrics.RulesHitCountEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O6,
        packageName: const $pb.PackageName('nitella.hub'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Metrics clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Metrics copyWith(void Function(Metrics) updates) =>
      super.copyWith((message) => updates(message as Metrics)) as Metrics;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Metrics create() => Metrics._();
  @$core.override
  Metrics createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Metrics getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Metrics>(create);
  static Metrics? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get connectionsActive => $_getI64(2);
  @$pb.TagNumber(3)
  set connectionsActive($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConnectionsActive() => $_has(2);
  @$pb.TagNumber(3)
  void clearConnectionsActive() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get connectionsTotal => $_getI64(3);
  @$pb.TagNumber(4)
  set connectionsTotal($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConnectionsTotal() => $_has(3);
  @$pb.TagNumber(4)
  void clearConnectionsTotal() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get bytesIn => $_getI64(4);
  @$pb.TagNumber(5)
  set bytesIn($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBytesIn() => $_has(4);
  @$pb.TagNumber(5)
  void clearBytesIn() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get bytesOut => $_getI64(5);
  @$pb.TagNumber(6)
  set bytesOut($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBytesOut() => $_has(5);
  @$pb.TagNumber(6)
  void clearBytesOut() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get blockedCount => $_getI64(6);
  @$pb.TagNumber(7)
  set blockedCount($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBlockedCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlockedCount() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbMap<$core.String, $fixnum.Int64> get rulesHitCount => $_getMap(7);
}

/// Encrypted Metrics for Hub storage (Zero-Trust)
class EncryptedMetrics extends $pb.GeneratedMessage {
  factory EncryptedMetrics({
    $core.String? nodeId,
    $0.Timestamp? timestamp,
    $1.EncryptedPayload? encrypted,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (timestamp != null) result.timestamp = timestamp;
    if (encrypted != null) result.encrypted = encrypted;
    return result;
  }

  EncryptedMetrics._();

  factory EncryptedMetrics.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EncryptedMetrics.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EncryptedMetrics',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOM<$1.EncryptedPayload>(3, _omitFieldNames ? '' : 'encrypted',
        subBuilder: $1.EncryptedPayload.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptedMetrics clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptedMetrics copyWith(void Function(EncryptedMetrics) updates) =>
      super.copyWith((message) => updates(message as EncryptedMetrics))
          as EncryptedMetrics;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncryptedMetrics create() => EncryptedMetrics._();
  @$core.override
  EncryptedMetrics createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EncryptedMetrics getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EncryptedMetrics>(create);
  static EncryptedMetrics? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.EncryptedPayload get encrypted => $_getN(2);
  @$pb.TagNumber(3)
  set encrypted($1.EncryptedPayload value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEncrypted() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncrypted() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.EncryptedPayload ensureEncrypted() => $_ensure(2);
}

/// Log entry (plaintext - for local/internal use only)
class LogEntry extends $pb.GeneratedMessage {
  factory LogEntry({
    $core.String? nodeId,
    $0.Timestamp? timestamp,
    $core.String? level,
    $core.String? message,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? fields,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (timestamp != null) result.timestamp = timestamp;
    if (level != null) result.level = level;
    if (message != null) result.message = message;
    if (fields != null) result.fields.addEntries(fields);
    return result;
  }

  LogEntry._();

  factory LogEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'level')
    ..aOS(4, _omitFieldNames ? '' : 'message')
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'fields',
        entryClassName: 'LogEntry.FieldsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('nitella.hub'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogEntry copyWith(void Function(LogEntry) updates) =>
      super.copyWith((message) => updates(message as LogEntry)) as LogEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogEntry create() => LogEntry._();
  @$core.override
  LogEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogEntry getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LogEntry>(create);
  static LogEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get level => $_getSZ(2);
  @$pb.TagNumber(3)
  set level($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLevel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get fields => $_getMap(4);
}

/// Encrypted Log Entry for Hub relay (Zero-Trust)
/// Hub cannot read log contents - only User can decrypt
class EncryptedLogEntry extends $pb.GeneratedMessage {
  factory EncryptedLogEntry({
    $core.String? nodeId,
    $0.Timestamp? timestamp,
    $1.EncryptedPayload? encrypted,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (timestamp != null) result.timestamp = timestamp;
    if (encrypted != null) result.encrypted = encrypted;
    return result;
  }

  EncryptedLogEntry._();

  factory EncryptedLogEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EncryptedLogEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EncryptedLogEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOM<$1.EncryptedPayload>(3, _omitFieldNames ? '' : 'encrypted',
        subBuilder: $1.EncryptedPayload.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptedLogEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptedLogEntry copyWith(void Function(EncryptedLogEntry) updates) =>
      super.copyWith((message) => updates(message as EncryptedLogEntry))
          as EncryptedLogEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncryptedLogEntry create() => EncryptedLogEntry._();
  @$core.override
  EncryptedLogEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EncryptedLogEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EncryptedLogEntry>(create);
  static EncryptedLogEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.EncryptedPayload get encrypted => $_getN(2);
  @$pb.TagNumber(3)
  set encrypted($1.EncryptedPayload value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEncrypted() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncrypted() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.EncryptedPayload ensureEncrypted() => $_ensure(2);
}

/// User
class User extends $pb.GeneratedMessage {
  factory User({
    $core.String? id,
    $core.String? blindIndex,
    $core.List<$core.int>? encryptedProfile,
    $core.String? role,
    $core.String? tier,
    $core.int? maxNodes,
    $0.Timestamp? lastLogin,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (blindIndex != null) result.blindIndex = blindIndex;
    if (encryptedProfile != null) result.encryptedProfile = encryptedProfile;
    if (role != null) result.role = role;
    if (tier != null) result.tier = tier;
    if (maxNodes != null) result.maxNodes = maxNodes;
    if (lastLogin != null) result.lastLogin = lastLogin;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  User._();

  factory User.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory User.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'User',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'blindIndex')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'encryptedProfile', $pb.PbFieldType.OY)
    ..aOS(4, _omitFieldNames ? '' : 'role')
    ..aOS(5, _omitFieldNames ? '' : 'tier')
    ..aI(6, _omitFieldNames ? '' : 'maxNodes')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'lastLogin',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User copyWith(void Function(User) updates) =>
      super.copyWith((message) => updates(message as User)) as User;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static User create() => User._();
  @$core.override
  User createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static User getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<User>(create);
  static User? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get blindIndex => $_getSZ(1);
  @$pb.TagNumber(2)
  set blindIndex($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlindIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlindIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get encryptedProfile => $_getN(2);
  @$pb.TagNumber(3)
  set encryptedProfile($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEncryptedProfile() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncryptedProfile() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get role => $_getSZ(3);
  @$pb.TagNumber(4)
  set role($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRole() => $_has(3);
  @$pb.TagNumber(4)
  void clearRole() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get tier => $_getSZ(4);
  @$pb.TagNumber(5)
  set tier($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTier() => $_has(4);
  @$pb.TagNumber(5)
  void clearTier() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get maxNodes => $_getIZ(5);
  @$pb.TagNumber(6)
  set maxNodes($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxNodes() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxNodes() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get lastLogin => $_getN(6);
  @$pb.TagNumber(7)
  set lastLogin($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasLastLogin() => $_has(6);
  @$pb.TagNumber(7)
  void clearLastLogin() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureLastLogin() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Timestamp get createdAt => $_getN(7);
  @$pb.TagNumber(8)
  set createdAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureCreatedAt() => $_ensure(7);
}

/// Response from Node to Hub (and back to Mobile)
class CommandResponse extends $pb.GeneratedMessage {
  factory CommandResponse({
    $core.String? commandId,
    $1.EncryptedPayload? encryptedData,
  }) {
    final result = create();
    if (commandId != null) result.commandId = commandId;
    if (encryptedData != null) result.encryptedData = encryptedData;
    return result;
  }

  CommandResponse._();

  factory CommandResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommandResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'commandId')
    ..aOM<$1.EncryptedPayload>(2, _omitFieldNames ? '' : 'encryptedData',
        subBuilder: $1.EncryptedPayload.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandResponse copyWith(void Function(CommandResponse) updates) =>
      super.copyWith((message) => updates(message as CommandResponse))
          as CommandResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommandResponse create() => CommandResponse._();
  @$core.override
  CommandResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CommandResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommandResponse>(create);
  static CommandResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get commandId => $_getSZ(0);
  @$pb.TagNumber(1)
  set commandId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommandId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommandId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.EncryptedPayload get encryptedData => $_getN(1);
  @$pb.TagNumber(2)
  set encryptedData($1.EncryptedPayload value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEncryptedData() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptedData() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.EncryptedPayload ensureEncryptedData() => $_ensure(1);
}

/// CommandResult matches the structure of CommandResponse but is intended to be encrypted
class CommandResult extends $pb.GeneratedMessage {
  factory CommandResult({
    $core.String? status,
    $core.String? errorMessage,
    $core.List<$core.int>? responsePayload,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (errorMessage != null) result.errorMessage = errorMessage;
    if (responsePayload != null) result.responsePayload = responsePayload;
    return result;
  }

  CommandResult._();

  factory CommandResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommandResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'status')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'responsePayload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandResult copyWith(void Function(CommandResult) updates) =>
      super.copyWith((message) => updates(message as CommandResult))
          as CommandResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommandResult create() => CommandResult._();
  @$core.override
  CommandResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CommandResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommandResult>(create);
  static CommandResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get status => $_getSZ(0);
  @$pb.TagNumber(1)
  set status($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get responsePayload => $_getN(2);
  @$pb.TagNumber(3)
  set responsePayload($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasResponsePayload() => $_has(2);
  @$pb.TagNumber(3)
  void clearResponsePayload() => $_clearField(3);
}

/// Command from Hub to Node (E2E encrypted only)
class Command extends $pb.GeneratedMessage {
  factory Command({
    $core.String? id,
    $1.EncryptedPayload? encrypted,
    $0.Timestamp? expiresAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (encrypted != null) result.encrypted = encrypted;
    if (expiresAt != null) result.expiresAt = expiresAt;
    return result;
  }

  Command._();

  factory Command.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Command.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Command',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$1.EncryptedPayload>(2, _omitFieldNames ? '' : 'encrypted',
        subBuilder: $1.EncryptedPayload.create)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'expiresAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Command clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Command copyWith(void Function(Command) updates) =>
      super.copyWith((message) => updates(message as Command)) as Command;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Command create() => Command._();
  @$core.override
  Command createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Command getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Command>(create);
  static Command? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.EncryptedPayload get encrypted => $_getN(1);
  @$pb.TagNumber(2)
  set encrypted($1.EncryptedPayload value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEncrypted() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncrypted() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.EncryptedPayload ensureEncrypted() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.Timestamp get expiresAt => $_getN(2);
  @$pb.TagNumber(3)
  set expiresAt($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasExpiresAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpiresAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureExpiresAt() => $_ensure(2);
}

class EncryptedCommandPayload extends $pb.GeneratedMessage {
  factory EncryptedCommandPayload({
    CommandType? type,
    $core.List<$core.int>? payload,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (payload != null) result.payload = payload;
    return result;
  }

  EncryptedCommandPayload._();

  factory EncryptedCommandPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EncryptedCommandPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EncryptedCommandPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aE<CommandType>(1, _omitFieldNames ? '' : 'type',
        enumValues: CommandType.values)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptedCommandPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptedCommandPayload copyWith(
          void Function(EncryptedCommandPayload) updates) =>
      super.copyWith((message) => updates(message as EncryptedCommandPayload))
          as EncryptedCommandPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncryptedCommandPayload create() => EncryptedCommandPayload._();
  @$core.override
  EncryptedCommandPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EncryptedCommandPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EncryptedCommandPayload>(create);
  static EncryptedCommandPayload? _defaultInstance;

  @$pb.TagNumber(1)
  CommandType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(CommandType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get payload => $_getN(1);
  @$pb.TagNumber(2)
  set payload($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearPayload() => $_clearField(2);
}

/// Certificate Revocation Event
class RevocationEvent extends $pb.GeneratedMessage {
  factory RevocationEvent({
    $core.String? serialNumber,
    $core.String? fingerprint,
    $0.Timestamp? revokedAt,
    $core.String? reason,
  }) {
    final result = create();
    if (serialNumber != null) result.serialNumber = serialNumber;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (revokedAt != null) result.revokedAt = revokedAt;
    if (reason != null) result.reason = reason;
    return result;
  }

  RevocationEvent._();

  factory RevocationEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RevocationEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevocationEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'serialNumber')
    ..aOS(2, _omitFieldNames ? '' : 'fingerprint')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'revokedAt',
        subBuilder: $0.Timestamp.create)
    ..aOS(4, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevocationEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevocationEvent copyWith(void Function(RevocationEvent) updates) =>
      super.copyWith((message) => updates(message as RevocationEvent))
          as RevocationEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevocationEvent create() => RevocationEvent._();
  @$core.override
  RevocationEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RevocationEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RevocationEvent>(create);
  static RevocationEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get serialNumber => $_getSZ(0);
  @$pb.TagNumber(1)
  set serialNumber($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSerialNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSerialNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fingerprint => $_getSZ(1);
  @$pb.TagNumber(2)
  set fingerprint($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFingerprint() => $_has(1);
  @$pb.TagNumber(2)
  void clearFingerprint() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get revokedAt => $_getN(2);
  @$pb.TagNumber(3)
  set revokedAt($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRevokedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevokedAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureRevokedAt() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get reason => $_getSZ(3);
  @$pb.TagNumber(4)
  set reason($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReason() => $_has(3);
  @$pb.TagNumber(4)
  void clearReason() => $_clearField(4);
}

/// WebRTC Signaling
class SignalMessage extends $pb.GeneratedMessage {
  factory SignalMessage({
    $core.String? targetId,
    $core.String? sourceId,
    $core.String? type,
    $core.String? payload,
    $core.String? sourceUserId,
  }) {
    final result = create();
    if (targetId != null) result.targetId = targetId;
    if (sourceId != null) result.sourceId = sourceId;
    if (type != null) result.type = type;
    if (payload != null) result.payload = payload;
    if (sourceUserId != null) result.sourceUserId = sourceUserId;
    return result;
  }

  SignalMessage._();

  factory SignalMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SignalMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SignalMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'targetId')
    ..aOS(2, _omitFieldNames ? '' : 'sourceId')
    ..aOS(3, _omitFieldNames ? '' : 'type')
    ..aOS(4, _omitFieldNames ? '' : 'payload')
    ..aOS(5, _omitFieldNames ? '' : 'sourceUserId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignalMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignalMessage copyWith(void Function(SignalMessage) updates) =>
      super.copyWith((message) => updates(message as SignalMessage))
          as SignalMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignalMessage create() => SignalMessage._();
  @$core.override
  SignalMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SignalMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignalMessage>(create);
  static SignalMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get targetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set targetId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTargetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTargetId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sourceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sourceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSourceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSourceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get payload => $_getSZ(3);
  @$pb.TagNumber(4)
  set payload($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPayload() => $_has(3);
  @$pb.TagNumber(4)
  void clearPayload() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get sourceUserId => $_getSZ(4);
  @$pb.TagNumber(5)
  set sourceUserId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSourceUserId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSourceUserId() => $_clearField(5);
}

/// PairingRequest: Node -> CLI (encrypted with PAKE shared secret)
class PairingRequest extends $pb.GeneratedMessage {
  factory PairingRequest({
    $core.String? csrPem,
    $core.List<$core.int>? nodePublicKey,
    $core.String? nodeVersion,
  }) {
    final result = create();
    if (csrPem != null) result.csrPem = csrPem;
    if (nodePublicKey != null) result.nodePublicKey = nodePublicKey;
    if (nodeVersion != null) result.nodeVersion = nodeVersion;
    return result;
  }

  PairingRequest._();

  factory PairingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PairingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PairingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'csrPem')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'nodePublicKey', $pb.PbFieldType.OY)
    ..aOS(3, _omitFieldNames ? '' : 'nodeVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingRequest copyWith(void Function(PairingRequest) updates) =>
      super.copyWith((message) => updates(message as PairingRequest))
          as PairingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PairingRequest create() => PairingRequest._();
  @$core.override
  PairingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PairingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PairingRequest>(create);
  static PairingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get csrPem => $_getSZ(0);
  @$pb.TagNumber(1)
  set csrPem($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCsrPem() => $_has(0);
  @$pb.TagNumber(1)
  void clearCsrPem() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get nodePublicKey => $_getN(1);
  @$pb.TagNumber(2)
  set nodePublicKey($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodePublicKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodePublicKey() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get nodeVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set nodeVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeVersion() => $_clearField(3);
}

/// PairingResponse: CLI -> Node (encrypted with PAKE shared secret)
/// Contains everything the node needs to operate securely
class PairingResponse extends $pb.GeneratedMessage {
  factory PairingResponse({
    $core.String? certPem,
    $core.String? caPem,
    $core.List<$core.int>? viewerPublicKey,
    $core.String? routingToken,
  }) {
    final result = create();
    if (certPem != null) result.certPem = certPem;
    if (caPem != null) result.caPem = caPem;
    if (viewerPublicKey != null) result.viewerPublicKey = viewerPublicKey;
    if (routingToken != null) result.routingToken = routingToken;
    return result;
  }

  PairingResponse._();

  factory PairingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PairingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PairingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'certPem')
    ..aOS(2, _omitFieldNames ? '' : 'caPem')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'viewerPublicKey', $pb.PbFieldType.OY)
    ..aOS(4, _omitFieldNames ? '' : 'routingToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PairingResponse copyWith(void Function(PairingResponse) updates) =>
      super.copyWith((message) => updates(message as PairingResponse))
          as PairingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PairingResponse create() => PairingResponse._();
  @$core.override
  PairingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PairingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PairingResponse>(create);
  static PairingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get certPem => $_getSZ(0);
  @$pb.TagNumber(1)
  set certPem($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCertPem() => $_has(0);
  @$pb.TagNumber(1)
  void clearCertPem() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get caPem => $_getSZ(1);
  @$pb.TagNumber(2)
  set caPem($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCaPem() => $_has(1);
  @$pb.TagNumber(2)
  void clearCaPem() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get viewerPublicKey => $_getN(2);
  @$pb.TagNumber(3)
  set viewerPublicKey($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasViewerPublicKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearViewerPublicKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get routingToken => $_getSZ(3);
  @$pb.TagNumber(4)
  set routingToken($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRoutingToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearRoutingToken() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
