// This is a generated file - do not edit.
//
// Generated from hub/hub_admin.proto.

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
    as $2;

import 'hub_common.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// System Stats
class GetSystemStatsRequest extends $pb.GeneratedMessage {
  factory GetSystemStatsRequest() => create();

  GetSystemStatsRequest._();

  factory GetSystemStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSystemStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSystemStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSystemStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSystemStatsRequest copyWith(
          void Function(GetSystemStatsRequest) updates) =>
      super.copyWith((message) => updates(message as GetSystemStatsRequest))
          as GetSystemStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSystemStatsRequest create() => GetSystemStatsRequest._();
  @$core.override
  GetSystemStatsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSystemStatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSystemStatsRequest>(create);
  static GetSystemStatsRequest? _defaultInstance;
}

class SystemStats extends $pb.GeneratedMessage {
  factory SystemStats({
    $core.int? totalUsers,
    $core.int? totalNodes,
    $core.int? onlineNodes,
    $fixnum.Int64? totalConnectionsToday,
    $fixnum.Int64? totalBytesToday,
    $fixnum.Int64? blockedRequestsToday,
    $core.Iterable<$core.MapEntry<$core.String, $core.int>>? usersByTier,
  }) {
    final result = create();
    if (totalUsers != null) result.totalUsers = totalUsers;
    if (totalNodes != null) result.totalNodes = totalNodes;
    if (onlineNodes != null) result.onlineNodes = onlineNodes;
    if (totalConnectionsToday != null)
      result.totalConnectionsToday = totalConnectionsToday;
    if (totalBytesToday != null) result.totalBytesToday = totalBytesToday;
    if (blockedRequestsToday != null)
      result.blockedRequestsToday = blockedRequestsToday;
    if (usersByTier != null) result.usersByTier.addEntries(usersByTier);
    return result;
  }

  SystemStats._();

  factory SystemStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SystemStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SystemStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'totalUsers')
    ..aI(2, _omitFieldNames ? '' : 'totalNodes')
    ..aI(3, _omitFieldNames ? '' : 'onlineNodes')
    ..aInt64(4, _omitFieldNames ? '' : 'totalConnectionsToday')
    ..aInt64(5, _omitFieldNames ? '' : 'totalBytesToday')
    ..aInt64(6, _omitFieldNames ? '' : 'blockedRequestsToday')
    ..m<$core.String, $core.int>(7, _omitFieldNames ? '' : 'usersByTier',
        entryClassName: 'SystemStats.UsersByTierEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('nitella.hub'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemStats copyWith(void Function(SystemStats) updates) =>
      super.copyWith((message) => updates(message as SystemStats))
          as SystemStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SystemStats create() => SystemStats._();
  @$core.override
  SystemStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SystemStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SystemStats>(create);
  static SystemStats? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get totalUsers => $_getIZ(0);
  @$pb.TagNumber(1)
  set totalUsers($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalUsers() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalUsers() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get totalNodes => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalNodes($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalNodes() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalNodes() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get onlineNodes => $_getIZ(2);
  @$pb.TagNumber(3)
  set onlineNodes($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOnlineNodes() => $_has(2);
  @$pb.TagNumber(3)
  void clearOnlineNodes() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get totalConnectionsToday => $_getI64(3);
  @$pb.TagNumber(4)
  set totalConnectionsToday($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalConnectionsToday() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalConnectionsToday() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get totalBytesToday => $_getI64(4);
  @$pb.TagNumber(5)
  set totalBytesToday($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalBytesToday() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalBytesToday() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get blockedRequestsToday => $_getI64(5);
  @$pb.TagNumber(6)
  set blockedRequestsToday($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBlockedRequestsToday() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlockedRequestsToday() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbMap<$core.String, $core.int> get usersByTier => $_getMap(6);
}

/// Audit Log
class GetAuditLogRequest extends $pb.GeneratedMessage {
  factory GetAuditLogRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? filterUserId,
    $core.String? filterAction,
    $2.Timestamp? startTime,
    $2.Timestamp? endTime,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (filterUserId != null) result.filterUserId = filterUserId;
    if (filterAction != null) result.filterAction = filterAction;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    return result;
  }

  GetAuditLogRequest._();

  factory GetAuditLogRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAuditLogRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAuditLogRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOS(3, _omitFieldNames ? '' : 'filterUserId')
    ..aOS(4, _omitFieldNames ? '' : 'filterAction')
    ..aOM<$2.Timestamp>(5, _omitFieldNames ? '' : 'startTime',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'endTime',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAuditLogRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAuditLogRequest copyWith(void Function(GetAuditLogRequest) updates) =>
      super.copyWith((message) => updates(message as GetAuditLogRequest))
          as GetAuditLogRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAuditLogRequest create() => GetAuditLogRequest._();
  @$core.override
  GetAuditLogRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAuditLogRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAuditLogRequest>(create);
  static GetAuditLogRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set pageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get filterUserId => $_getSZ(2);
  @$pb.TagNumber(3)
  set filterUserId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFilterUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilterUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get filterAction => $_getSZ(3);
  @$pb.TagNumber(4)
  set filterAction($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFilterAction() => $_has(3);
  @$pb.TagNumber(4)
  void clearFilterAction() => $_clearField(4);

  @$pb.TagNumber(5)
  $2.Timestamp get startTime => $_getN(4);
  @$pb.TagNumber(5)
  set startTime($2.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStartTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearStartTime() => $_clearField(5);
  @$pb.TagNumber(5)
  $2.Timestamp ensureStartTime() => $_ensure(4);

  @$pb.TagNumber(6)
  $2.Timestamp get endTime => $_getN(5);
  @$pb.TagNumber(6)
  set endTime($2.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasEndTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearEndTime() => $_clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureEndTime() => $_ensure(5);
}

class GetAuditLogResponse extends $pb.GeneratedMessage {
  factory GetAuditLogResponse({
    $core.Iterable<AuditEntry>? entries,
    $core.String? nextPageToken,
  }) {
    final result = create();
    if (entries != null) result.entries.addAll(entries);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    return result;
  }

  GetAuditLogResponse._();

  factory GetAuditLogResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAuditLogResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAuditLogResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<AuditEntry>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: AuditEntry.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAuditLogResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAuditLogResponse copyWith(void Function(GetAuditLogResponse) updates) =>
      super.copyWith((message) => updates(message as GetAuditLogResponse))
          as GetAuditLogResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAuditLogResponse create() => GetAuditLogResponse._();
  @$core.override
  GetAuditLogResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAuditLogResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAuditLogResponse>(create);
  static GetAuditLogResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AuditEntry> get entries => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);
}

class AuditEntry extends $pb.GeneratedMessage {
  factory AuditEntry({
    $core.String? id,
    $2.Timestamp? timestamp,
    $core.String? userId,
    $core.String? action,
    $core.String? targetType,
    $core.String? targetId,
    $core.String? ipAddress,
    $core.String? details,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (timestamp != null) result.timestamp = timestamp;
    if (userId != null) result.userId = userId;
    if (action != null) result.action = action;
    if (targetType != null) result.targetType = targetType;
    if (targetId != null) result.targetId = targetId;
    if (ipAddress != null) result.ipAddress = ipAddress;
    if (details != null) result.details = details;
    return result;
  }

  AuditEntry._();

  factory AuditEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AuditEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AuditEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$2.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $2.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'userId')
    ..aOS(4, _omitFieldNames ? '' : 'action')
    ..aOS(5, _omitFieldNames ? '' : 'targetType')
    ..aOS(6, _omitFieldNames ? '' : 'targetId')
    ..aOS(7, _omitFieldNames ? '' : 'ipAddress')
    ..aOS(8, _omitFieldNames ? '' : 'details')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuditEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuditEntry copyWith(void Function(AuditEntry) updates) =>
      super.copyWith((message) => updates(message as AuditEntry)) as AuditEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuditEntry create() => AuditEntry._();
  @$core.override
  AuditEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AuditEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AuditEntry>(create);
  static AuditEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $2.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($2.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.Timestamp ensureTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get action => $_getSZ(3);
  @$pb.TagNumber(4)
  set action($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAction() => $_has(3);
  @$pb.TagNumber(4)
  void clearAction() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get targetType => $_getSZ(4);
  @$pb.TagNumber(5)
  set targetType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTargetType() => $_has(4);
  @$pb.TagNumber(5)
  void clearTargetType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get targetId => $_getSZ(5);
  @$pb.TagNumber(6)
  set targetId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTargetId() => $_has(5);
  @$pb.TagNumber(6)
  void clearTargetId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get ipAddress => $_getSZ(6);
  @$pb.TagNumber(7)
  set ipAddress($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIpAddress() => $_has(6);
  @$pb.TagNumber(7)
  void clearIpAddress() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get details => $_getSZ(7);
  @$pb.TagNumber(8)
  set details($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDetails() => $_has(7);
  @$pb.TagNumber(8)
  void clearDetails() => $_clearField(8);
}

/// User Management
class ListAllUsersRequest extends $pb.GeneratedMessage {
  factory ListAllUsersRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? filterTier,
    $core.String? filterStatus,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (filterTier != null) result.filterTier = filterTier;
    if (filterStatus != null) result.filterStatus = filterStatus;
    return result;
  }

  ListAllUsersRequest._();

  factory ListAllUsersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAllUsersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAllUsersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOS(3, _omitFieldNames ? '' : 'filterTier')
    ..aOS(4, _omitFieldNames ? '' : 'filterStatus')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAllUsersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAllUsersRequest copyWith(void Function(ListAllUsersRequest) updates) =>
      super.copyWith((message) => updates(message as ListAllUsersRequest))
          as ListAllUsersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAllUsersRequest create() => ListAllUsersRequest._();
  @$core.override
  ListAllUsersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAllUsersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAllUsersRequest>(create);
  static ListAllUsersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set pageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get filterTier => $_getSZ(2);
  @$pb.TagNumber(3)
  set filterTier($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFilterTier() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilterTier() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get filterStatus => $_getSZ(3);
  @$pb.TagNumber(4)
  set filterStatus($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFilterStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearFilterStatus() => $_clearField(4);
}

class ListAllUsersResponse extends $pb.GeneratedMessage {
  factory ListAllUsersResponse({
    $core.Iterable<$1.User>? users,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (users != null) result.users.addAll(users);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListAllUsersResponse._();

  factory ListAllUsersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAllUsersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAllUsersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<$1.User>(1, _omitFieldNames ? '' : 'users',
        subBuilder: $1.User.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAllUsersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAllUsersResponse copyWith(void Function(ListAllUsersResponse) updates) =>
      super.copyWith((message) => updates(message as ListAllUsersResponse))
          as ListAllUsersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAllUsersResponse create() => ListAllUsersResponse._();
  @$core.override
  ListAllUsersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAllUsersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAllUsersResponse>(create);
  static ListAllUsersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.User> get users => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class GetUserDetailsRequest extends $pb.GeneratedMessage {
  factory GetUserDetailsRequest({
    $core.String? userId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    return result;
  }

  GetUserDetailsRequest._();

  factory GetUserDetailsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUserDetailsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUserDetailsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserDetailsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserDetailsRequest copyWith(
          void Function(GetUserDetailsRequest) updates) =>
      super.copyWith((message) => updates(message as GetUserDetailsRequest))
          as GetUserDetailsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUserDetailsRequest create() => GetUserDetailsRequest._();
  @$core.override
  GetUserDetailsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUserDetailsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUserDetailsRequest>(create);
  static GetUserDetailsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
}

class UserDetails extends $pb.GeneratedMessage {
  factory UserDetails({
    $1.User? user,
    $core.int? nodeCount,
    $fixnum.Int64? totalBytesMonth,
    $2.Timestamp? registrationDate,
    $core.Iterable<$1.Node>? nodes,
  }) {
    final result = create();
    if (user != null) result.user = user;
    if (nodeCount != null) result.nodeCount = nodeCount;
    if (totalBytesMonth != null) result.totalBytesMonth = totalBytesMonth;
    if (registrationDate != null) result.registrationDate = registrationDate;
    if (nodes != null) result.nodes.addAll(nodes);
    return result;
  }

  UserDetails._();

  factory UserDetails.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserDetails.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserDetails',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOM<$1.User>(1, _omitFieldNames ? '' : 'user', subBuilder: $1.User.create)
    ..aI(2, _omitFieldNames ? '' : 'nodeCount')
    ..aInt64(3, _omitFieldNames ? '' : 'totalBytesMonth')
    ..aOM<$2.Timestamp>(4, _omitFieldNames ? '' : 'registrationDate',
        subBuilder: $2.Timestamp.create)
    ..pPM<$1.Node>(5, _omitFieldNames ? '' : 'nodes',
        subBuilder: $1.Node.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserDetails clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserDetails copyWith(void Function(UserDetails) updates) =>
      super.copyWith((message) => updates(message as UserDetails))
          as UserDetails;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserDetails create() => UserDetails._();
  @$core.override
  UserDetails createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserDetails getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserDetails>(create);
  static UserDetails? _defaultInstance;

  @$pb.TagNumber(1)
  $1.User get user => $_getN(0);
  @$pb.TagNumber(1)
  set user($1.User value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUser() => $_has(0);
  @$pb.TagNumber(1)
  void clearUser() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.User ensureUser() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get nodeCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set nodeCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get totalBytesMonth => $_getI64(2);
  @$pb.TagNumber(3)
  set totalBytesMonth($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalBytesMonth() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalBytesMonth() => $_clearField(3);

  @$pb.TagNumber(4)
  $2.Timestamp get registrationDate => $_getN(3);
  @$pb.TagNumber(4)
  set registrationDate($2.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasRegistrationDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearRegistrationDate() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.Timestamp ensureRegistrationDate() => $_ensure(3);

  @$pb.TagNumber(5)
  $pb.PbList<$1.Node> get nodes => $_getList(4);
}

class SetUserTierRequest extends $pb.GeneratedMessage {
  factory SetUserTierRequest({
    $core.String? userId,
    $core.String? tier,
    $core.int? maxNodes,
    $2.Timestamp? expiresAt,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (tier != null) result.tier = tier;
    if (maxNodes != null) result.maxNodes = maxNodes;
    if (expiresAt != null) result.expiresAt = expiresAt;
    return result;
  }

  SetUserTierRequest._();

  factory SetUserTierRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetUserTierRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetUserTierRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'tier')
    ..aI(3, _omitFieldNames ? '' : 'maxNodes')
    ..aOM<$2.Timestamp>(4, _omitFieldNames ? '' : 'expiresAt',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetUserTierRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetUserTierRequest copyWith(void Function(SetUserTierRequest) updates) =>
      super.copyWith((message) => updates(message as SetUserTierRequest))
          as SetUserTierRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetUserTierRequest create() => SetUserTierRequest._();
  @$core.override
  SetUserTierRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetUserTierRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetUserTierRequest>(create);
  static SetUserTierRequest? _defaultInstance;

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
  $2.Timestamp get expiresAt => $_getN(3);
  @$pb.TagNumber(4)
  set expiresAt($2.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasExpiresAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpiresAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.Timestamp ensureExpiresAt() => $_ensure(3);
}

class BanUserRequest extends $pb.GeneratedMessage {
  factory BanUserRequest({
    $core.String? userId,
    $core.String? reason,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (reason != null) result.reason = reason;
    return result;
  }

  BanUserRequest._();

  factory BanUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BanUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BanUserRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BanUserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BanUserRequest copyWith(void Function(BanUserRequest) updates) =>
      super.copyWith((message) => updates(message as BanUserRequest))
          as BanUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BanUserRequest create() => BanUserRequest._();
  @$core.override
  BanUserRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BanUserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BanUserRequest>(create);
  static BanUserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class UnbanUserRequest extends $pb.GeneratedMessage {
  factory UnbanUserRequest({
    $core.String? userId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    return result;
  }

  UnbanUserRequest._();

  factory UnbanUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnbanUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnbanUserRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnbanUserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnbanUserRequest copyWith(void Function(UnbanUserRequest) updates) =>
      super.copyWith((message) => updates(message as UnbanUserRequest))
          as UnbanUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnbanUserRequest create() => UnbanUserRequest._();
  @$core.override
  UnbanUserRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnbanUserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnbanUserRequest>(create);
  static UnbanUserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
}

/// Node Management
class ListAllNodesRequest extends $pb.GeneratedMessage {
  factory ListAllNodesRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? filterStatus,
    $core.String? filterOwnerId,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (filterStatus != null) result.filterStatus = filterStatus;
    if (filterOwnerId != null) result.filterOwnerId = filterOwnerId;
    return result;
  }

  ListAllNodesRequest._();

  factory ListAllNodesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAllNodesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAllNodesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOS(3, _omitFieldNames ? '' : 'filterStatus')
    ..aOS(4, _omitFieldNames ? '' : 'filterOwnerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAllNodesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAllNodesRequest copyWith(void Function(ListAllNodesRequest) updates) =>
      super.copyWith((message) => updates(message as ListAllNodesRequest))
          as ListAllNodesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAllNodesRequest create() => ListAllNodesRequest._();
  @$core.override
  ListAllNodesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAllNodesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAllNodesRequest>(create);
  static ListAllNodesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set pageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get filterStatus => $_getSZ(2);
  @$pb.TagNumber(3)
  set filterStatus($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFilterStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilterStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get filterOwnerId => $_getSZ(3);
  @$pb.TagNumber(4)
  set filterOwnerId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFilterOwnerId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFilterOwnerId() => $_clearField(4);
}

class ListAllNodesResponse extends $pb.GeneratedMessage {
  factory ListAllNodesResponse({
    $core.Iterable<$1.Node>? nodes,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (nodes != null) result.nodes.addAll(nodes);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListAllNodesResponse._();

  factory ListAllNodesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAllNodesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAllNodesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<$1.Node>(1, _omitFieldNames ? '' : 'nodes',
        subBuilder: $1.Node.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAllNodesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAllNodesResponse copyWith(void Function(ListAllNodesResponse) updates) =>
      super.copyWith((message) => updates(message as ListAllNodesResponse))
          as ListAllNodesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAllNodesResponse create() => ListAllNodesResponse._();
  @$core.override
  ListAllNodesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAllNodesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAllNodesResponse>(create);
  static ListAllNodesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.Node> get nodes => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class ForceDisconnectNodeRequest extends $pb.GeneratedMessage {
  factory ForceDisconnectNodeRequest({
    $core.String? nodeId,
    $core.String? reason,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (reason != null) result.reason = reason;
    return result;
  }

  ForceDisconnectNodeRequest._();

  factory ForceDisconnectNodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ForceDisconnectNodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForceDisconnectNodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForceDisconnectNodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForceDisconnectNodeRequest copyWith(
          void Function(ForceDisconnectNodeRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ForceDisconnectNodeRequest))
          as ForceDisconnectNodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForceDisconnectNodeRequest create() => ForceDisconnectNodeRequest._();
  @$core.override
  ForceDisconnectNodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ForceDisconnectNodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ForceDisconnectNodeRequest>(create);
  static ForceDisconnectNodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

/// License Management
class ListLicensesRequest extends $pb.GeneratedMessage {
  factory ListLicensesRequest({
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListLicensesRequest._();

  factory ListLicensesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListLicensesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListLicensesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLicensesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLicensesRequest copyWith(void Function(ListLicensesRequest) updates) =>
      super.copyWith((message) => updates(message as ListLicensesRequest))
          as ListLicensesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListLicensesRequest create() => ListLicensesRequest._();
  @$core.override
  ListLicensesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListLicensesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListLicensesRequest>(create);
  static ListLicensesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set pageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageToken() => $_clearField(2);
}

class ListLicensesResponse extends $pb.GeneratedMessage {
  factory ListLicensesResponse({
    $core.Iterable<License>? licenses,
    $core.String? nextPageToken,
  }) {
    final result = create();
    if (licenses != null) result.licenses.addAll(licenses);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    return result;
  }

  ListLicensesResponse._();

  factory ListLicensesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListLicensesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListLicensesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<License>(1, _omitFieldNames ? '' : 'licenses',
        subBuilder: License.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLicensesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLicensesResponse copyWith(void Function(ListLicensesResponse) updates) =>
      super.copyWith((message) => updates(message as ListLicensesResponse))
          as ListLicensesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListLicensesResponse create() => ListLicensesResponse._();
  @$core.override
  ListLicensesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListLicensesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListLicensesResponse>(create);
  static ListLicensesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<License> get licenses => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);
}

class License extends $pb.GeneratedMessage {
  factory License({
    $core.String? key,
    $core.String? userId,
    $core.String? tier,
    $core.String? status,
    $2.Timestamp? createdAt,
    $2.Timestamp? expiresAt,
  }) {
    final result = create();
    if (key != null) result.key = key;
    if (userId != null) result.userId = userId;
    if (tier != null) result.tier = tier;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    return result;
  }

  License._();

  factory License.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory License.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'License',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'tier')
    ..aOS(4, _omitFieldNames ? '' : 'status')
    ..aOM<$2.Timestamp>(5, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'expiresAt',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  License clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  License copyWith(void Function(License) updates) =>
      super.copyWith((message) => updates(message as License)) as License;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static License create() => License._();
  @$core.override
  License createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static License getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<License>(create);
  static License? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tier => $_getSZ(2);
  @$pb.TagNumber(3)
  set tier($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTier() => $_has(2);
  @$pb.TagNumber(3)
  void clearTier() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get status => $_getSZ(3);
  @$pb.TagNumber(4)
  set status($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $2.Timestamp get createdAt => $_getN(4);
  @$pb.TagNumber(5)
  set createdAt($2.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $2.Timestamp ensureCreatedAt() => $_ensure(4);

  @$pb.TagNumber(6)
  $2.Timestamp get expiresAt => $_getN(5);
  @$pb.TagNumber(6)
  set expiresAt($2.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasExpiresAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpiresAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureExpiresAt() => $_ensure(5);
}

class RevokeLicenseRequest extends $pb.GeneratedMessage {
  factory RevokeLicenseRequest({
    $core.String? licenseKey,
    $core.String? reason,
  }) {
    final result = create();
    if (licenseKey != null) result.licenseKey = licenseKey;
    if (reason != null) result.reason = reason;
    return result;
  }

  RevokeLicenseRequest._();

  factory RevokeLicenseRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RevokeLicenseRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevokeLicenseRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'licenseKey')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeLicenseRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeLicenseRequest copyWith(void Function(RevokeLicenseRequest) updates) =>
      super.copyWith((message) => updates(message as RevokeLicenseRequest))
          as RevokeLicenseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevokeLicenseRequest create() => RevokeLicenseRequest._();
  @$core.override
  RevokeLicenseRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RevokeLicenseRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RevokeLicenseRequest>(create);
  static RevokeLicenseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get licenseKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set licenseKey($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLicenseKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearLicenseKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class CreatePromoCodeRequest extends $pb.GeneratedMessage {
  factory CreatePromoCodeRequest({
    $core.String? code,
    $core.String? tier,
    $core.int? durationDays,
    $core.int? maxUses,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (tier != null) result.tier = tier;
    if (durationDays != null) result.durationDays = durationDays;
    if (maxUses != null) result.maxUses = maxUses;
    return result;
  }

  CreatePromoCodeRequest._();

  factory CreatePromoCodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreatePromoCodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreatePromoCodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'tier')
    ..aI(3, _omitFieldNames ? '' : 'durationDays')
    ..aI(4, _omitFieldNames ? '' : 'maxUses')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePromoCodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePromoCodeRequest copyWith(
          void Function(CreatePromoCodeRequest) updates) =>
      super.copyWith((message) => updates(message as CreatePromoCodeRequest))
          as CreatePromoCodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePromoCodeRequest create() => CreatePromoCodeRequest._();
  @$core.override
  CreatePromoCodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreatePromoCodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreatePromoCodeRequest>(create);
  static CreatePromoCodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tier => $_getSZ(1);
  @$pb.TagNumber(2)
  set tier($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTier() => $_has(1);
  @$pb.TagNumber(2)
  void clearTier() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get durationDays => $_getIZ(2);
  @$pb.TagNumber(3)
  set durationDays($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDurationDays() => $_has(2);
  @$pb.TagNumber(3)
  void clearDurationDays() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get maxUses => $_getIZ(3);
  @$pb.TagNumber(4)
  set maxUses($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMaxUses() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxUses() => $_clearField(4);
}

class PromoCode extends $pb.GeneratedMessage {
  factory PromoCode({
    $core.String? code,
    $core.String? tier,
    $core.int? durationDays,
    $core.int? maxUses,
    $core.int? currentUses,
    $2.Timestamp? expiresAt,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (tier != null) result.tier = tier;
    if (durationDays != null) result.durationDays = durationDays;
    if (maxUses != null) result.maxUses = maxUses;
    if (currentUses != null) result.currentUses = currentUses;
    if (expiresAt != null) result.expiresAt = expiresAt;
    return result;
  }

  PromoCode._();

  factory PromoCode.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PromoCode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PromoCode',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'tier')
    ..aI(3, _omitFieldNames ? '' : 'durationDays')
    ..aI(4, _omitFieldNames ? '' : 'maxUses')
    ..aI(5, _omitFieldNames ? '' : 'currentUses')
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'expiresAt',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromoCode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromoCode copyWith(void Function(PromoCode) updates) =>
      super.copyWith((message) => updates(message as PromoCode)) as PromoCode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PromoCode create() => PromoCode._();
  @$core.override
  PromoCode createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PromoCode getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PromoCode>(create);
  static PromoCode? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tier => $_getSZ(1);
  @$pb.TagNumber(2)
  set tier($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTier() => $_has(1);
  @$pb.TagNumber(2)
  void clearTier() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get durationDays => $_getIZ(2);
  @$pb.TagNumber(3)
  set durationDays($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDurationDays() => $_has(2);
  @$pb.TagNumber(3)
  void clearDurationDays() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get maxUses => $_getIZ(3);
  @$pb.TagNumber(4)
  set maxUses($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMaxUses() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxUses() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get currentUses => $_getIZ(4);
  @$pb.TagNumber(5)
  set currentUses($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCurrentUses() => $_has(4);
  @$pb.TagNumber(5)
  void clearCurrentUses() => $_clearField(5);

  @$pb.TagNumber(6)
  $2.Timestamp get expiresAt => $_getN(5);
  @$pb.TagNumber(6)
  set expiresAt($2.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasExpiresAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpiresAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureExpiresAt() => $_ensure(5);
}

/// System Config
class GetConfigRequest extends $pb.GeneratedMessage {
  factory GetConfigRequest() => create();

  GetConfigRequest._();

  factory GetConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConfigRequest copyWith(void Function(GetConfigRequest) updates) =>
      super.copyWith((message) => updates(message as GetConfigRequest))
          as GetConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetConfigRequest create() => GetConfigRequest._();
  @$core.override
  GetConfigRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetConfigRequest>(create);
  static GetConfigRequest? _defaultInstance;
}

class UpdateConfigRequest extends $pb.GeneratedMessage {
  factory UpdateConfigRequest({
    HubConfig? config,
  }) {
    final result = create();
    if (config != null) result.config = config;
    return result;
  }

  UpdateConfigRequest._();

  factory UpdateConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOM<HubConfig>(1, _omitFieldNames ? '' : 'config',
        subBuilder: HubConfig.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateConfigRequest copyWith(void Function(UpdateConfigRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateConfigRequest))
          as UpdateConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateConfigRequest create() => UpdateConfigRequest._();
  @$core.override
  UpdateConfigRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateConfigRequest>(create);
  static UpdateConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  HubConfig get config => $_getN(0);
  @$pb.TagNumber(1)
  set config(HubConfig value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasConfig() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfig() => $_clearField(1);
  @$pb.TagNumber(1)
  HubConfig ensureConfig() => $_ensure(0);
}

class HubConfig extends $pb.GeneratedMessage {
  factory HubConfig({
    $core.int? freeTierRateLimit,
    $core.int? proTierRateLimit,
    $core.int? businessTierRateLimit,
    $core.int? freeTierMaxNodes,
    $core.int? proTierMaxNodes,
    $core.bool? registrationEnabled,
    $core.bool? requireEmailVerification,
  }) {
    final result = create();
    if (freeTierRateLimit != null) result.freeTierRateLimit = freeTierRateLimit;
    if (proTierRateLimit != null) result.proTierRateLimit = proTierRateLimit;
    if (businessTierRateLimit != null)
      result.businessTierRateLimit = businessTierRateLimit;
    if (freeTierMaxNodes != null) result.freeTierMaxNodes = freeTierMaxNodes;
    if (proTierMaxNodes != null) result.proTierMaxNodes = proTierMaxNodes;
    if (registrationEnabled != null)
      result.registrationEnabled = registrationEnabled;
    if (requireEmailVerification != null)
      result.requireEmailVerification = requireEmailVerification;
    return result;
  }

  HubConfig._();

  factory HubConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HubConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HubConfig',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'freeTierRateLimit')
    ..aI(2, _omitFieldNames ? '' : 'proTierRateLimit')
    ..aI(3, _omitFieldNames ? '' : 'businessTierRateLimit')
    ..aI(4, _omitFieldNames ? '' : 'freeTierMaxNodes')
    ..aI(5, _omitFieldNames ? '' : 'proTierMaxNodes')
    ..aOB(6, _omitFieldNames ? '' : 'registrationEnabled')
    ..aOB(7, _omitFieldNames ? '' : 'requireEmailVerification')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HubConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HubConfig copyWith(void Function(HubConfig) updates) =>
      super.copyWith((message) => updates(message as HubConfig)) as HubConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HubConfig create() => HubConfig._();
  @$core.override
  HubConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HubConfig getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HubConfig>(create);
  static HubConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get freeTierRateLimit => $_getIZ(0);
  @$pb.TagNumber(1)
  set freeTierRateLimit($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFreeTierRateLimit() => $_has(0);
  @$pb.TagNumber(1)
  void clearFreeTierRateLimit() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get proTierRateLimit => $_getIZ(1);
  @$pb.TagNumber(2)
  set proTierRateLimit($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProTierRateLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearProTierRateLimit() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get businessTierRateLimit => $_getIZ(2);
  @$pb.TagNumber(3)
  set businessTierRateLimit($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBusinessTierRateLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearBusinessTierRateLimit() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get freeTierMaxNodes => $_getIZ(3);
  @$pb.TagNumber(4)
  set freeTierMaxNodes($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFreeTierMaxNodes() => $_has(3);
  @$pb.TagNumber(4)
  void clearFreeTierMaxNodes() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get proTierMaxNodes => $_getIZ(4);
  @$pb.TagNumber(5)
  set proTierMaxNodes($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProTierMaxNodes() => $_has(4);
  @$pb.TagNumber(5)
  void clearProTierMaxNodes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get registrationEnabled => $_getBF(5);
  @$pb.TagNumber(6)
  set registrationEnabled($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRegistrationEnabled() => $_has(5);
  @$pb.TagNumber(6)
  void clearRegistrationEnabled() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get requireEmailVerification => $_getBF(6);
  @$pb.TagNumber(7)
  set requireEmailVerification($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRequireEmailVerification() => $_has(6);
  @$pb.TagNumber(7)
  void clearRequireEmailVerification() => $_clearField(7);
}

/// Revocations
class ListAllRevocationsRequest extends $pb.GeneratedMessage {
  factory ListAllRevocationsRequest({
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListAllRevocationsRequest._();

  factory ListAllRevocationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAllRevocationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAllRevocationsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAllRevocationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAllRevocationsRequest copyWith(
          void Function(ListAllRevocationsRequest) updates) =>
      super.copyWith((message) => updates(message as ListAllRevocationsRequest))
          as ListAllRevocationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAllRevocationsRequest create() => ListAllRevocationsRequest._();
  @$core.override
  ListAllRevocationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAllRevocationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAllRevocationsRequest>(create);
  static ListAllRevocationsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set pageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageToken() => $_clearField(2);
}

class ListAllRevocationsResponse extends $pb.GeneratedMessage {
  factory ListAllRevocationsResponse({
    $core.Iterable<$1.RevocationEvent>? revocations,
    $core.String? nextPageToken,
  }) {
    final result = create();
    if (revocations != null) result.revocations.addAll(revocations);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    return result;
  }

  ListAllRevocationsResponse._();

  factory ListAllRevocationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAllRevocationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAllRevocationsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<$1.RevocationEvent>(1, _omitFieldNames ? '' : 'revocations',
        subBuilder: $1.RevocationEvent.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAllRevocationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAllRevocationsResponse copyWith(
          void Function(ListAllRevocationsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListAllRevocationsResponse))
          as ListAllRevocationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAllRevocationsResponse create() => ListAllRevocationsResponse._();
  @$core.override
  ListAllRevocationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAllRevocationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAllRevocationsResponse>(create);
  static ListAllRevocationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.RevocationEvent> get revocations => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);
}

/// Invite Codes
class InviteCode extends $pb.GeneratedMessage {
  factory InviteCode({
    $core.String? code,
    $core.int? limit,
    $core.int? used,
    $2.Timestamp? createdAt,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (limit != null) result.limit = limit;
    if (used != null) result.used = used;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  InviteCode._();

  factory InviteCode.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InviteCode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InviteCode',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aI(2, _omitFieldNames ? '' : 'limit')
    ..aI(3, _omitFieldNames ? '' : 'used')
    ..aOM<$2.Timestamp>(4, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteCode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteCode copyWith(void Function(InviteCode) updates) =>
      super.copyWith((message) => updates(message as InviteCode)) as InviteCode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InviteCode create() => InviteCode._();
  @$core.override
  InviteCode createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InviteCode getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InviteCode>(create);
  static InviteCode? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get used => $_getIZ(2);
  @$pb.TagNumber(3)
  set used($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUsed() => $_has(2);
  @$pb.TagNumber(3)
  void clearUsed() => $_clearField(3);

  @$pb.TagNumber(4)
  $2.Timestamp get createdAt => $_getN(3);
  @$pb.TagNumber(4)
  set createdAt($2.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.Timestamp ensureCreatedAt() => $_ensure(3);
}

class DeleteInviteCodeRequest extends $pb.GeneratedMessage {
  factory DeleteInviteCodeRequest({
    $core.String? code,
  }) {
    final result = create();
    if (code != null) result.code = code;
    return result;
  }

  DeleteInviteCodeRequest._();

  factory DeleteInviteCodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteInviteCodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteInviteCodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteInviteCodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteInviteCodeRequest copyWith(
          void Function(DeleteInviteCodeRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteInviteCodeRequest))
          as DeleteInviteCodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteInviteCodeRequest create() => DeleteInviteCodeRequest._();
  @$core.override
  DeleteInviteCodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteInviteCodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteInviteCodeRequest>(create);
  static DeleteInviteCodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);
}

class RecalculateInviteCodeUsageRequest extends $pb.GeneratedMessage {
  factory RecalculateInviteCodeUsageRequest({
    $core.String? code,
  }) {
    final result = create();
    if (code != null) result.code = code;
    return result;
  }

  RecalculateInviteCodeUsageRequest._();

  factory RecalculateInviteCodeUsageRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecalculateInviteCodeUsageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecalculateInviteCodeUsageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecalculateInviteCodeUsageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecalculateInviteCodeUsageRequest copyWith(
          void Function(RecalculateInviteCodeUsageRequest) updates) =>
      super.copyWith((message) =>
              updates(message as RecalculateInviteCodeUsageRequest))
          as RecalculateInviteCodeUsageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecalculateInviteCodeUsageRequest create() =>
      RecalculateInviteCodeUsageRequest._();
  @$core.override
  RecalculateInviteCodeUsageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecalculateInviteCodeUsageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecalculateInviteCodeUsageRequest>(
          create);
  static RecalculateInviteCodeUsageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);
}

/// Hub TLS Certificate Management
class GetHubCertInfoRequest extends $pb.GeneratedMessage {
  factory GetHubCertInfoRequest() => create();

  GetHubCertInfoRequest._();

  factory GetHubCertInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHubCertInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHubCertInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHubCertInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHubCertInfoRequest copyWith(
          void Function(GetHubCertInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetHubCertInfoRequest))
          as GetHubCertInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHubCertInfoRequest create() => GetHubCertInfoRequest._();
  @$core.override
  GetHubCertInfoRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHubCertInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHubCertInfoRequest>(create);
  static GetHubCertInfoRequest? _defaultInstance;
}

class RotateHubLeafCertRequest extends $pb.GeneratedMessage {
  factory RotateHubLeafCertRequest({
    $core.Iterable<$core.String>? additionalSans,
  }) {
    final result = create();
    if (additionalSans != null) result.additionalSans.addAll(additionalSans);
    return result;
  }

  RotateHubLeafCertRequest._();

  factory RotateHubLeafCertRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RotateHubLeafCertRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RotateHubLeafCertRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'additionalSans')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RotateHubLeafCertRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RotateHubLeafCertRequest copyWith(
          void Function(RotateHubLeafCertRequest) updates) =>
      super.copyWith((message) => updates(message as RotateHubLeafCertRequest))
          as RotateHubLeafCertRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RotateHubLeafCertRequest create() => RotateHubLeafCertRequest._();
  @$core.override
  RotateHubLeafCertRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RotateHubLeafCertRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RotateHubLeafCertRequest>(create);
  static RotateHubLeafCertRequest? _defaultInstance;

  /// Optional: Additional SANs to include in the new cert
  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get additionalSans => $_getList(0);
}

class HubCertInfo extends $pb.GeneratedMessage {
  factory HubCertInfo({
    $core.String? caFingerprint,
    $core.String? caEmoji,
    $2.Timestamp? caExpiresAt,
    $core.String? leafSerial,
    $2.Timestamp? leafExpiresAt,
    $2.Timestamp? leafNotBefore,
    $core.Iterable<$core.String>? leafDnsNames,
    $core.Iterable<$core.String>? leafIpAddresses,
  }) {
    final result = create();
    if (caFingerprint != null) result.caFingerprint = caFingerprint;
    if (caEmoji != null) result.caEmoji = caEmoji;
    if (caExpiresAt != null) result.caExpiresAt = caExpiresAt;
    if (leafSerial != null) result.leafSerial = leafSerial;
    if (leafExpiresAt != null) result.leafExpiresAt = leafExpiresAt;
    if (leafNotBefore != null) result.leafNotBefore = leafNotBefore;
    if (leafDnsNames != null) result.leafDnsNames.addAll(leafDnsNames);
    if (leafIpAddresses != null) result.leafIpAddresses.addAll(leafIpAddresses);
    return result;
  }

  HubCertInfo._();

  factory HubCertInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HubCertInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HubCertInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'caFingerprint')
    ..aOS(2, _omitFieldNames ? '' : 'caEmoji')
    ..aOM<$2.Timestamp>(3, _omitFieldNames ? '' : 'caExpiresAt',
        subBuilder: $2.Timestamp.create)
    ..aOS(4, _omitFieldNames ? '' : 'leafSerial')
    ..aOM<$2.Timestamp>(5, _omitFieldNames ? '' : 'leafExpiresAt',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'leafNotBefore',
        subBuilder: $2.Timestamp.create)
    ..pPS(7, _omitFieldNames ? '' : 'leafDnsNames')
    ..pPS(8, _omitFieldNames ? '' : 'leafIpAddresses')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HubCertInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HubCertInfo copyWith(void Function(HubCertInfo) updates) =>
      super.copyWith((message) => updates(message as HubCertInfo))
          as HubCertInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HubCertInfo create() => HubCertInfo._();
  @$core.override
  HubCertInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HubCertInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HubCertInfo>(create);
  static HubCertInfo? _defaultInstance;

  /// Hub CA (trust anchor)
  @$pb.TagNumber(1)
  $core.String get caFingerprint => $_getSZ(0);
  @$pb.TagNumber(1)
  set caFingerprint($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCaFingerprint() => $_has(0);
  @$pb.TagNumber(1)
  void clearCaFingerprint() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get caEmoji => $_getSZ(1);
  @$pb.TagNumber(2)
  set caEmoji($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCaEmoji() => $_has(1);
  @$pb.TagNumber(2)
  void clearCaEmoji() => $_clearField(2);

  @$pb.TagNumber(3)
  $2.Timestamp get caExpiresAt => $_getN(2);
  @$pb.TagNumber(3)
  set caExpiresAt($2.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCaExpiresAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearCaExpiresAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.Timestamp ensureCaExpiresAt() => $_ensure(2);

  /// Current Leaf Certificate
  @$pb.TagNumber(4)
  $core.String get leafSerial => $_getSZ(3);
  @$pb.TagNumber(4)
  set leafSerial($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLeafSerial() => $_has(3);
  @$pb.TagNumber(4)
  void clearLeafSerial() => $_clearField(4);

  @$pb.TagNumber(5)
  $2.Timestamp get leafExpiresAt => $_getN(4);
  @$pb.TagNumber(5)
  set leafExpiresAt($2.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLeafExpiresAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearLeafExpiresAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $2.Timestamp ensureLeafExpiresAt() => $_ensure(4);

  @$pb.TagNumber(6)
  $2.Timestamp get leafNotBefore => $_getN(5);
  @$pb.TagNumber(6)
  set leafNotBefore($2.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasLeafNotBefore() => $_has(5);
  @$pb.TagNumber(6)
  void clearLeafNotBefore() => $_clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureLeafNotBefore() => $_ensure(5);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get leafDnsNames => $_getList(6);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get leafIpAddresses => $_getList(7);
}

class GetDatabaseStatsRequest extends $pb.GeneratedMessage {
  factory GetDatabaseStatsRequest() => create();

  GetDatabaseStatsRequest._();

  factory GetDatabaseStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDatabaseStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDatabaseStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDatabaseStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDatabaseStatsRequest copyWith(
          void Function(GetDatabaseStatsRequest) updates) =>
      super.copyWith((message) => updates(message as GetDatabaseStatsRequest))
          as GetDatabaseStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDatabaseStatsRequest create() => GetDatabaseStatsRequest._();
  @$core.override
  GetDatabaseStatsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDatabaseStatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDatabaseStatsRequest>(create);
  static GetDatabaseStatsRequest? _defaultInstance;
}

class DatabaseStats extends $pb.GeneratedMessage {
  factory DatabaseStats({
    $fixnum.Int64? dbSizeBytes,
    $core.int? userCount,
    $core.int? nodeCount,
    $core.int? orgCount,
    $core.int? deviceCount,
    $core.int? templateCount,
    $core.int? revocationCount,
    $core.int? inviteCodeCount,
    $core.int? licenseCount,
    $core.int? pendingRegistrationCount,
    $core.int? auditEntryCount,
    $2.Timestamp? oldestAuditEntry,
    $2.Timestamp? newestAuditEntry,
  }) {
    final result = create();
    if (dbSizeBytes != null) result.dbSizeBytes = dbSizeBytes;
    if (userCount != null) result.userCount = userCount;
    if (nodeCount != null) result.nodeCount = nodeCount;
    if (orgCount != null) result.orgCount = orgCount;
    if (deviceCount != null) result.deviceCount = deviceCount;
    if (templateCount != null) result.templateCount = templateCount;
    if (revocationCount != null) result.revocationCount = revocationCount;
    if (inviteCodeCount != null) result.inviteCodeCount = inviteCodeCount;
    if (licenseCount != null) result.licenseCount = licenseCount;
    if (pendingRegistrationCount != null)
      result.pendingRegistrationCount = pendingRegistrationCount;
    if (auditEntryCount != null) result.auditEntryCount = auditEntryCount;
    if (oldestAuditEntry != null) result.oldestAuditEntry = oldestAuditEntry;
    if (newestAuditEntry != null) result.newestAuditEntry = newestAuditEntry;
    return result;
  }

  DatabaseStats._();

  factory DatabaseStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DatabaseStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DatabaseStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'dbSizeBytes')
    ..aI(2, _omitFieldNames ? '' : 'userCount')
    ..aI(3, _omitFieldNames ? '' : 'nodeCount')
    ..aI(4, _omitFieldNames ? '' : 'orgCount')
    ..aI(5, _omitFieldNames ? '' : 'deviceCount')
    ..aI(6, _omitFieldNames ? '' : 'templateCount')
    ..aI(7, _omitFieldNames ? '' : 'revocationCount')
    ..aI(8, _omitFieldNames ? '' : 'inviteCodeCount')
    ..aI(9, _omitFieldNames ? '' : 'licenseCount')
    ..aI(10, _omitFieldNames ? '' : 'pendingRegistrationCount')
    ..aI(11, _omitFieldNames ? '' : 'auditEntryCount')
    ..aOM<$2.Timestamp>(12, _omitFieldNames ? '' : 'oldestAuditEntry',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(13, _omitFieldNames ? '' : 'newestAuditEntry',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DatabaseStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DatabaseStats copyWith(void Function(DatabaseStats) updates) =>
      super.copyWith((message) => updates(message as DatabaseStats))
          as DatabaseStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DatabaseStats create() => DatabaseStats._();
  @$core.override
  DatabaseStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DatabaseStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DatabaseStats>(create);
  static DatabaseStats? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get dbSizeBytes => $_getI64(0);
  @$pb.TagNumber(1)
  set dbSizeBytes($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDbSizeBytes() => $_has(0);
  @$pb.TagNumber(1)
  void clearDbSizeBytes() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get userCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set userCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get nodeCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set nodeCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get orgCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set orgCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOrgCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrgCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get deviceCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set deviceCount($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDeviceCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeviceCount() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get templateCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set templateCount($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTemplateCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearTemplateCount() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get revocationCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set revocationCount($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRevocationCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearRevocationCount() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get inviteCodeCount => $_getIZ(7);
  @$pb.TagNumber(8)
  set inviteCodeCount($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasInviteCodeCount() => $_has(7);
  @$pb.TagNumber(8)
  void clearInviteCodeCount() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get licenseCount => $_getIZ(8);
  @$pb.TagNumber(9)
  set licenseCount($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLicenseCount() => $_has(8);
  @$pb.TagNumber(9)
  void clearLicenseCount() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get pendingRegistrationCount => $_getIZ(9);
  @$pb.TagNumber(10)
  set pendingRegistrationCount($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPendingRegistrationCount() => $_has(9);
  @$pb.TagNumber(10)
  void clearPendingRegistrationCount() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get auditEntryCount => $_getIZ(10);
  @$pb.TagNumber(11)
  set auditEntryCount($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAuditEntryCount() => $_has(10);
  @$pb.TagNumber(11)
  void clearAuditEntryCount() => $_clearField(11);

  @$pb.TagNumber(12)
  $2.Timestamp get oldestAuditEntry => $_getN(11);
  @$pb.TagNumber(12)
  set oldestAuditEntry($2.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasOldestAuditEntry() => $_has(11);
  @$pb.TagNumber(12)
  void clearOldestAuditEntry() => $_clearField(12);
  @$pb.TagNumber(12)
  $2.Timestamp ensureOldestAuditEntry() => $_ensure(11);

  @$pb.TagNumber(13)
  $2.Timestamp get newestAuditEntry => $_getN(12);
  @$pb.TagNumber(13)
  set newestAuditEntry($2.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasNewestAuditEntry() => $_has(12);
  @$pb.TagNumber(13)
  void clearNewestAuditEntry() => $_clearField(13);
  @$pb.TagNumber(13)
  $2.Timestamp ensureNewestAuditEntry() => $_ensure(12);
}

class DeleteUserRequest extends $pb.GeneratedMessage {
  factory DeleteUserRequest({
    $core.String? userId,
    $core.bool? cascade,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (cascade != null) result.cascade = cascade;
    return result;
  }

  DeleteUserRequest._();

  factory DeleteUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteUserRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOB(2, _omitFieldNames ? '' : 'cascade')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteUserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteUserRequest copyWith(void Function(DeleteUserRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteUserRequest))
          as DeleteUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteUserRequest create() => DeleteUserRequest._();
  @$core.override
  DeleteUserRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteUserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteUserRequest>(create);
  static DeleteUserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get cascade => $_getBF(1);
  @$pb.TagNumber(2)
  set cascade($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCascade() => $_has(1);
  @$pb.TagNumber(2)
  void clearCascade() => $_clearField(2);
}

class GetNodeDetailsRequest extends $pb.GeneratedMessage {
  factory GetNodeDetailsRequest({
    $core.String? nodeId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    return result;
  }

  GetNodeDetailsRequest._();

  factory GetNodeDetailsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNodeDetailsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNodeDetailsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNodeDetailsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNodeDetailsRequest copyWith(
          void Function(GetNodeDetailsRequest) updates) =>
      super.copyWith((message) => updates(message as GetNodeDetailsRequest))
          as GetNodeDetailsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNodeDetailsRequest create() => GetNodeDetailsRequest._();
  @$core.override
  GetNodeDetailsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNodeDetailsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNodeDetailsRequest>(create);
  static GetNodeDetailsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);
}

class NodeDetails extends $pb.GeneratedMessage {
  factory NodeDetails({
    $1.Node? node,
    $core.String? ownerId,
    $core.String? ownerTier,
    $fixnum.Int64? totalBytesMonth,
    $fixnum.Int64? totalConnectionsMonth,
    $2.Timestamp? registrationDate,
    $core.String? certSerial,
    $core.String? certFingerprint,
    $2.Timestamp? certExpiresAt,
    $core.Iterable<$core.String>? blindIndices,
    $core.int? encryptedMetadataSize,
  }) {
    final result = create();
    if (node != null) result.node = node;
    if (ownerId != null) result.ownerId = ownerId;
    if (ownerTier != null) result.ownerTier = ownerTier;
    if (totalBytesMonth != null) result.totalBytesMonth = totalBytesMonth;
    if (totalConnectionsMonth != null)
      result.totalConnectionsMonth = totalConnectionsMonth;
    if (registrationDate != null) result.registrationDate = registrationDate;
    if (certSerial != null) result.certSerial = certSerial;
    if (certFingerprint != null) result.certFingerprint = certFingerprint;
    if (certExpiresAt != null) result.certExpiresAt = certExpiresAt;
    if (blindIndices != null) result.blindIndices.addAll(blindIndices);
    if (encryptedMetadataSize != null)
      result.encryptedMetadataSize = encryptedMetadataSize;
    return result;
  }

  NodeDetails._();

  factory NodeDetails.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NodeDetails.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeDetails',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOM<$1.Node>(1, _omitFieldNames ? '' : 'node', subBuilder: $1.Node.create)
    ..aOS(2, _omitFieldNames ? '' : 'ownerId')
    ..aOS(3, _omitFieldNames ? '' : 'ownerTier')
    ..aInt64(4, _omitFieldNames ? '' : 'totalBytesMonth')
    ..aInt64(5, _omitFieldNames ? '' : 'totalConnectionsMonth')
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'registrationDate',
        subBuilder: $2.Timestamp.create)
    ..aOS(7, _omitFieldNames ? '' : 'certSerial')
    ..aOS(8, _omitFieldNames ? '' : 'certFingerprint')
    ..aOM<$2.Timestamp>(9, _omitFieldNames ? '' : 'certExpiresAt',
        subBuilder: $2.Timestamp.create)
    ..pPS(10, _omitFieldNames ? '' : 'blindIndices')
    ..aI(11, _omitFieldNames ? '' : 'encryptedMetadataSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeDetails clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeDetails copyWith(void Function(NodeDetails) updates) =>
      super.copyWith((message) => updates(message as NodeDetails))
          as NodeDetails;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NodeDetails create() => NodeDetails._();
  @$core.override
  NodeDetails createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NodeDetails getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NodeDetails>(create);
  static NodeDetails? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Node get node => $_getN(0);
  @$pb.TagNumber(1)
  set node($1.Node value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasNode() => $_has(0);
  @$pb.TagNumber(1)
  void clearNode() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Node ensureNode() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get ownerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set ownerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOwnerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOwnerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get ownerTier => $_getSZ(2);
  @$pb.TagNumber(3)
  set ownerTier($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOwnerTier() => $_has(2);
  @$pb.TagNumber(3)
  void clearOwnerTier() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get totalBytesMonth => $_getI64(3);
  @$pb.TagNumber(4)
  set totalBytesMonth($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalBytesMonth() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalBytesMonth() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get totalConnectionsMonth => $_getI64(4);
  @$pb.TagNumber(5)
  set totalConnectionsMonth($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalConnectionsMonth() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalConnectionsMonth() => $_clearField(5);

  @$pb.TagNumber(6)
  $2.Timestamp get registrationDate => $_getN(5);
  @$pb.TagNumber(6)
  set registrationDate($2.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasRegistrationDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearRegistrationDate() => $_clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureRegistrationDate() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get certSerial => $_getSZ(6);
  @$pb.TagNumber(7)
  set certSerial($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCertSerial() => $_has(6);
  @$pb.TagNumber(7)
  void clearCertSerial() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get certFingerprint => $_getSZ(7);
  @$pb.TagNumber(8)
  set certFingerprint($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCertFingerprint() => $_has(7);
  @$pb.TagNumber(8)
  void clearCertFingerprint() => $_clearField(8);

  @$pb.TagNumber(9)
  $2.Timestamp get certExpiresAt => $_getN(8);
  @$pb.TagNumber(9)
  set certExpiresAt($2.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasCertExpiresAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCertExpiresAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $2.Timestamp ensureCertExpiresAt() => $_ensure(8);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get blindIndices => $_getList(9);

  @$pb.TagNumber(11)
  $core.int get encryptedMetadataSize => $_getIZ(10);
  @$pb.TagNumber(11)
  set encryptedMetadataSize($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasEncryptedMetadataSize() => $_has(10);
  @$pb.TagNumber(11)
  void clearEncryptedMetadataSize() => $_clearField(11);
}

class AdminDeleteNodeRequest extends $pb.GeneratedMessage {
  factory AdminDeleteNodeRequest({
    $core.String? nodeId,
    $core.String? reason,
    $core.bool? revokeCert,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (reason != null) result.reason = reason;
    if (revokeCert != null) result.revokeCert = revokeCert;
    return result;
  }

  AdminDeleteNodeRequest._();

  factory AdminDeleteNodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AdminDeleteNodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AdminDeleteNodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..aOB(3, _omitFieldNames ? '' : 'revokeCert')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdminDeleteNodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdminDeleteNodeRequest copyWith(
          void Function(AdminDeleteNodeRequest) updates) =>
      super.copyWith((message) => updates(message as AdminDeleteNodeRequest))
          as AdminDeleteNodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AdminDeleteNodeRequest create() => AdminDeleteNodeRequest._();
  @$core.override
  AdminDeleteNodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AdminDeleteNodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AdminDeleteNodeRequest>(create);
  static AdminDeleteNodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get revokeCert => $_getBF(2);
  @$pb.TagNumber(3)
  set revokeCert($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRevokeCert() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevokeCert() => $_clearField(3);
}

class Organization extends $pb.GeneratedMessage {
  factory Organization({
    $core.String? id,
    $core.String? tier,
    $core.int? maxMembers,
    $core.int? memberCount,
    $core.int? nodeCount,
    $2.Timestamp? createdAt,
    $core.List<$core.int>? encryptedMetadata,
    $core.int? encryptedMetadataSize,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tier != null) result.tier = tier;
    if (maxMembers != null) result.maxMembers = maxMembers;
    if (memberCount != null) result.memberCount = memberCount;
    if (nodeCount != null) result.nodeCount = nodeCount;
    if (createdAt != null) result.createdAt = createdAt;
    if (encryptedMetadata != null) result.encryptedMetadata = encryptedMetadata;
    if (encryptedMetadataSize != null)
      result.encryptedMetadataSize = encryptedMetadataSize;
    return result;
  }

  Organization._();

  factory Organization.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Organization.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Organization',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tier')
    ..aI(3, _omitFieldNames ? '' : 'maxMembers')
    ..aI(4, _omitFieldNames ? '' : 'memberCount')
    ..aI(5, _omitFieldNames ? '' : 'nodeCount')
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $2.Timestamp.create)
    ..a<$core.List<$core.int>>(
        7, _omitFieldNames ? '' : 'encryptedMetadata', $pb.PbFieldType.OY)
    ..aI(8, _omitFieldNames ? '' : 'encryptedMetadataSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Organization clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Organization copyWith(void Function(Organization) updates) =>
      super.copyWith((message) => updates(message as Organization))
          as Organization;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Organization create() => Organization._();
  @$core.override
  Organization createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Organization getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Organization>(create);
  static Organization? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tier => $_getSZ(1);
  @$pb.TagNumber(2)
  set tier($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTier() => $_has(1);
  @$pb.TagNumber(2)
  void clearTier() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get maxMembers => $_getIZ(2);
  @$pb.TagNumber(3)
  set maxMembers($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxMembers() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxMembers() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get memberCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set memberCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMemberCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearMemberCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get nodeCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set nodeCount($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNodeCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearNodeCount() => $_clearField(5);

  @$pb.TagNumber(6)
  $2.Timestamp get createdAt => $_getN(5);
  @$pb.TagNumber(6)
  set createdAt($2.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureCreatedAt() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.List<$core.int> get encryptedMetadata => $_getN(6);
  @$pb.TagNumber(7)
  set encryptedMetadata($core.List<$core.int> value) => $_setBytes(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEncryptedMetadata() => $_has(6);
  @$pb.TagNumber(7)
  void clearEncryptedMetadata() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get encryptedMetadataSize => $_getIZ(7);
  @$pb.TagNumber(8)
  set encryptedMetadataSize($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEncryptedMetadataSize() => $_has(7);
  @$pb.TagNumber(8)
  void clearEncryptedMetadataSize() => $_clearField(8);
}

class ListOrganizationsRequest extends $pb.GeneratedMessage {
  factory ListOrganizationsRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? filterTier,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (filterTier != null) result.filterTier = filterTier;
    return result;
  }

  ListOrganizationsRequest._();

  factory ListOrganizationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListOrganizationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListOrganizationsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOS(3, _omitFieldNames ? '' : 'filterTier')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrganizationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrganizationsRequest copyWith(
          void Function(ListOrganizationsRequest) updates) =>
      super.copyWith((message) => updates(message as ListOrganizationsRequest))
          as ListOrganizationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListOrganizationsRequest create() => ListOrganizationsRequest._();
  @$core.override
  ListOrganizationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListOrganizationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListOrganizationsRequest>(create);
  static ListOrganizationsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set pageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get filterTier => $_getSZ(2);
  @$pb.TagNumber(3)
  set filterTier($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFilterTier() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilterTier() => $_clearField(3);
}

class ListOrganizationsResponse extends $pb.GeneratedMessage {
  factory ListOrganizationsResponse({
    $core.Iterable<Organization>? organizations,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (organizations != null) result.organizations.addAll(organizations);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListOrganizationsResponse._();

  factory ListOrganizationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListOrganizationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListOrganizationsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<Organization>(1, _omitFieldNames ? '' : 'organizations',
        subBuilder: Organization.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrganizationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrganizationsResponse copyWith(
          void Function(ListOrganizationsResponse) updates) =>
      super.copyWith((message) => updates(message as ListOrganizationsResponse))
          as ListOrganizationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListOrganizationsResponse create() => ListOrganizationsResponse._();
  @$core.override
  ListOrganizationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListOrganizationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListOrganizationsResponse>(create);
  static ListOrganizationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Organization> get organizations => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class GetOrganizationRequest extends $pb.GeneratedMessage {
  factory GetOrganizationRequest({
    $core.String? orgId,
  }) {
    final result = create();
    if (orgId != null) result.orgId = orgId;
    return result;
  }

  GetOrganizationRequest._();

  factory GetOrganizationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetOrganizationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetOrganizationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'orgId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOrganizationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOrganizationRequest copyWith(
          void Function(GetOrganizationRequest) updates) =>
      super.copyWith((message) => updates(message as GetOrganizationRequest))
          as GetOrganizationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetOrganizationRequest create() => GetOrganizationRequest._();
  @$core.override
  GetOrganizationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetOrganizationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetOrganizationRequest>(create);
  static GetOrganizationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orgId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orgId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrgId() => $_clearField(1);
}

class OrganizationDetails extends $pb.GeneratedMessage {
  factory OrganizationDetails({
    Organization? org,
    $core.Iterable<$1.User>? members,
    $core.Iterable<$1.Node>? nodes,
    $fixnum.Int64? totalStorageBytes,
    $core.int? activeInvites,
  }) {
    final result = create();
    if (org != null) result.org = org;
    if (members != null) result.members.addAll(members);
    if (nodes != null) result.nodes.addAll(nodes);
    if (totalStorageBytes != null) result.totalStorageBytes = totalStorageBytes;
    if (activeInvites != null) result.activeInvites = activeInvites;
    return result;
  }

  OrganizationDetails._();

  factory OrganizationDetails.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OrganizationDetails.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrganizationDetails',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOM<Organization>(1, _omitFieldNames ? '' : 'org',
        subBuilder: Organization.create)
    ..pPM<$1.User>(2, _omitFieldNames ? '' : 'members',
        subBuilder: $1.User.create)
    ..pPM<$1.Node>(3, _omitFieldNames ? '' : 'nodes',
        subBuilder: $1.Node.create)
    ..aInt64(4, _omitFieldNames ? '' : 'totalStorageBytes')
    ..aI(5, _omitFieldNames ? '' : 'activeInvites')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrganizationDetails clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrganizationDetails copyWith(void Function(OrganizationDetails) updates) =>
      super.copyWith((message) => updates(message as OrganizationDetails))
          as OrganizationDetails;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrganizationDetails create() => OrganizationDetails._();
  @$core.override
  OrganizationDetails createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static OrganizationDetails getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OrganizationDetails>(create);
  static OrganizationDetails? _defaultInstance;

  @$pb.TagNumber(1)
  Organization get org => $_getN(0);
  @$pb.TagNumber(1)
  set org(Organization value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOrg() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrg() => $_clearField(1);
  @$pb.TagNumber(1)
  Organization ensureOrg() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<$1.User> get members => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$1.Node> get nodes => $_getList(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get totalStorageBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set totalStorageBytes($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalStorageBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalStorageBytes() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get activeInvites => $_getIZ(4);
  @$pb.TagNumber(5)
  set activeInvites($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasActiveInvites() => $_has(4);
  @$pb.TagNumber(5)
  void clearActiveInvites() => $_clearField(5);
}

class SetOrganizationTierRequest extends $pb.GeneratedMessage {
  factory SetOrganizationTierRequest({
    $core.String? orgId,
    $core.String? tier,
    $core.int? maxMembers,
  }) {
    final result = create();
    if (orgId != null) result.orgId = orgId;
    if (tier != null) result.tier = tier;
    if (maxMembers != null) result.maxMembers = maxMembers;
    return result;
  }

  SetOrganizationTierRequest._();

  factory SetOrganizationTierRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetOrganizationTierRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetOrganizationTierRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'orgId')
    ..aOS(2, _omitFieldNames ? '' : 'tier')
    ..aI(3, _omitFieldNames ? '' : 'maxMembers')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetOrganizationTierRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetOrganizationTierRequest copyWith(
          void Function(SetOrganizationTierRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SetOrganizationTierRequest))
          as SetOrganizationTierRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetOrganizationTierRequest create() => SetOrganizationTierRequest._();
  @$core.override
  SetOrganizationTierRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetOrganizationTierRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetOrganizationTierRequest>(create);
  static SetOrganizationTierRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orgId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orgId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tier => $_getSZ(1);
  @$pb.TagNumber(2)
  set tier($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTier() => $_has(1);
  @$pb.TagNumber(2)
  void clearTier() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get maxMembers => $_getIZ(2);
  @$pb.TagNumber(3)
  set maxMembers($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxMembers() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxMembers() => $_clearField(3);
}

class DeleteOrganizationRequest extends $pb.GeneratedMessage {
  factory DeleteOrganizationRequest({
    $core.String? orgId,
    $core.bool? cascade,
  }) {
    final result = create();
    if (orgId != null) result.orgId = orgId;
    if (cascade != null) result.cascade = cascade;
    return result;
  }

  DeleteOrganizationRequest._();

  factory DeleteOrganizationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteOrganizationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteOrganizationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'orgId')
    ..aOB(2, _omitFieldNames ? '' : 'cascade')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteOrganizationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteOrganizationRequest copyWith(
          void Function(DeleteOrganizationRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteOrganizationRequest))
          as DeleteOrganizationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteOrganizationRequest create() => DeleteOrganizationRequest._();
  @$core.override
  DeleteOrganizationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteOrganizationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteOrganizationRequest>(create);
  static DeleteOrganizationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get orgId => $_getSZ(0);
  @$pb.TagNumber(1)
  set orgId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get cascade => $_getBF(1);
  @$pb.TagNumber(2)
  set cascade($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCascade() => $_has(1);
  @$pb.TagNumber(2)
  void clearCascade() => $_clearField(2);
}

class PendingRegistration extends $pb.GeneratedMessage {
  factory PendingRegistration({
    $core.String? registrationCode,
    $core.String? csrPem,
    $core.List<$core.int>? encryptedMetadata,
    $core.int? encryptedMetadataSize,
    $core.Iterable<$core.int>? listenPorts,
    $core.String? version,
    $core.String? inviteCode,
    $core.String? pairingCode,
    $1.RegistrationStatus? status,
    $2.Timestamp? createdAt,
    $2.Timestamp? expiresAt,
    $core.String? sourceIp,
  }) {
    final result = create();
    if (registrationCode != null) result.registrationCode = registrationCode;
    if (csrPem != null) result.csrPem = csrPem;
    if (encryptedMetadata != null) result.encryptedMetadata = encryptedMetadata;
    if (encryptedMetadataSize != null)
      result.encryptedMetadataSize = encryptedMetadataSize;
    if (listenPorts != null) result.listenPorts.addAll(listenPorts);
    if (version != null) result.version = version;
    if (inviteCode != null) result.inviteCode = inviteCode;
    if (pairingCode != null) result.pairingCode = pairingCode;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (sourceIp != null) result.sourceIp = sourceIp;
    return result;
  }

  PendingRegistration._();

  factory PendingRegistration.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PendingRegistration.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PendingRegistration',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'registrationCode')
    ..aOS(2, _omitFieldNames ? '' : 'csrPem')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'encryptedMetadata', $pb.PbFieldType.OY)
    ..aI(4, _omitFieldNames ? '' : 'encryptedMetadataSize')
    ..p<$core.int>(5, _omitFieldNames ? '' : 'listenPorts', $pb.PbFieldType.K3)
    ..aOS(6, _omitFieldNames ? '' : 'version')
    ..aOS(7, _omitFieldNames ? '' : 'inviteCode')
    ..aOS(8, _omitFieldNames ? '' : 'pairingCode')
    ..aE<$1.RegistrationStatus>(9, _omitFieldNames ? '' : 'status',
        enumValues: $1.RegistrationStatus.values)
    ..aOM<$2.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(11, _omitFieldNames ? '' : 'expiresAt',
        subBuilder: $2.Timestamp.create)
    ..aOS(12, _omitFieldNames ? '' : 'sourceIp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PendingRegistration clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PendingRegistration copyWith(void Function(PendingRegistration) updates) =>
      super.copyWith((message) => updates(message as PendingRegistration))
          as PendingRegistration;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PendingRegistration create() => PendingRegistration._();
  @$core.override
  PendingRegistration createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PendingRegistration getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PendingRegistration>(create);
  static PendingRegistration? _defaultInstance;

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
  $core.int get encryptedMetadataSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set encryptedMetadataSize($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEncryptedMetadataSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearEncryptedMetadataSize() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.int> get listenPorts => $_getList(4);

  @$pb.TagNumber(6)
  $core.String get version => $_getSZ(5);
  @$pb.TagNumber(6)
  set version($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersion() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get inviteCode => $_getSZ(6);
  @$pb.TagNumber(7)
  set inviteCode($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasInviteCode() => $_has(6);
  @$pb.TagNumber(7)
  void clearInviteCode() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get pairingCode => $_getSZ(7);
  @$pb.TagNumber(8)
  set pairingCode($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPairingCode() => $_has(7);
  @$pb.TagNumber(8)
  void clearPairingCode() => $_clearField(8);

  @$pb.TagNumber(9)
  $1.RegistrationStatus get status => $_getN(8);
  @$pb.TagNumber(9)
  set status($1.RegistrationStatus value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => $_clearField(9);

  @$pb.TagNumber(10)
  $2.Timestamp get createdAt => $_getN(9);
  @$pb.TagNumber(10)
  set createdAt($2.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $2.Timestamp ensureCreatedAt() => $_ensure(9);

  @$pb.TagNumber(11)
  $2.Timestamp get expiresAt => $_getN(10);
  @$pb.TagNumber(11)
  set expiresAt($2.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasExpiresAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearExpiresAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $2.Timestamp ensureExpiresAt() => $_ensure(10);

  @$pb.TagNumber(12)
  $core.String get sourceIp => $_getSZ(11);
  @$pb.TagNumber(12)
  set sourceIp($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasSourceIp() => $_has(11);
  @$pb.TagNumber(12)
  void clearSourceIp() => $_clearField(12);
}

class ListPendingRegistrationsRequest extends $pb.GeneratedMessage {
  factory ListPendingRegistrationsRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? filterStatus,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (filterStatus != null) result.filterStatus = filterStatus;
    return result;
  }

  ListPendingRegistrationsRequest._();

  factory ListPendingRegistrationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPendingRegistrationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPendingRegistrationsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOS(3, _omitFieldNames ? '' : 'filterStatus')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPendingRegistrationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPendingRegistrationsRequest copyWith(
          void Function(ListPendingRegistrationsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ListPendingRegistrationsRequest))
          as ListPendingRegistrationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPendingRegistrationsRequest create() =>
      ListPendingRegistrationsRequest._();
  @$core.override
  ListPendingRegistrationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPendingRegistrationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPendingRegistrationsRequest>(
          create);
  static ListPendingRegistrationsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set pageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get filterStatus => $_getSZ(2);
  @$pb.TagNumber(3)
  set filterStatus($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFilterStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilterStatus() => $_clearField(3);
}

class ListPendingRegistrationsResponse extends $pb.GeneratedMessage {
  factory ListPendingRegistrationsResponse({
    $core.Iterable<PendingRegistration>? registrations,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (registrations != null) result.registrations.addAll(registrations);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListPendingRegistrationsResponse._();

  factory ListPendingRegistrationsResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPendingRegistrationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPendingRegistrationsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<PendingRegistration>(1, _omitFieldNames ? '' : 'registrations',
        subBuilder: PendingRegistration.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPendingRegistrationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPendingRegistrationsResponse copyWith(
          void Function(ListPendingRegistrationsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListPendingRegistrationsResponse))
          as ListPendingRegistrationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPendingRegistrationsResponse create() =>
      ListPendingRegistrationsResponse._();
  @$core.override
  ListPendingRegistrationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPendingRegistrationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPendingRegistrationsResponse>(
          create);
  static ListPendingRegistrationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PendingRegistration> get registrations => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class ForceApproveRegistrationRequest extends $pb.GeneratedMessage {
  factory ForceApproveRegistrationRequest({
    $core.String? registrationCode,
    $core.String? certPem,
    $core.String? caPem,
    $core.String? assignedOwnerId,
  }) {
    final result = create();
    if (registrationCode != null) result.registrationCode = registrationCode;
    if (certPem != null) result.certPem = certPem;
    if (caPem != null) result.caPem = caPem;
    if (assignedOwnerId != null) result.assignedOwnerId = assignedOwnerId;
    return result;
  }

  ForceApproveRegistrationRequest._();

  factory ForceApproveRegistrationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ForceApproveRegistrationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForceApproveRegistrationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'registrationCode')
    ..aOS(2, _omitFieldNames ? '' : 'certPem')
    ..aOS(3, _omitFieldNames ? '' : 'caPem')
    ..aOS(4, _omitFieldNames ? '' : 'assignedOwnerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForceApproveRegistrationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForceApproveRegistrationRequest copyWith(
          void Function(ForceApproveRegistrationRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ForceApproveRegistrationRequest))
          as ForceApproveRegistrationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForceApproveRegistrationRequest create() =>
      ForceApproveRegistrationRequest._();
  @$core.override
  ForceApproveRegistrationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ForceApproveRegistrationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ForceApproveRegistrationRequest>(
          create);
  static ForceApproveRegistrationRequest? _defaultInstance;

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
  $core.String get assignedOwnerId => $_getSZ(3);
  @$pb.TagNumber(4)
  set assignedOwnerId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAssignedOwnerId() => $_has(3);
  @$pb.TagNumber(4)
  void clearAssignedOwnerId() => $_clearField(4);
}

class RejectRegistrationRequest extends $pb.GeneratedMessage {
  factory RejectRegistrationRequest({
    $core.String? registrationCode,
    $core.String? reason,
  }) {
    final result = create();
    if (registrationCode != null) result.registrationCode = registrationCode;
    if (reason != null) result.reason = reason;
    return result;
  }

  RejectRegistrationRequest._();

  factory RejectRegistrationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RejectRegistrationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RejectRegistrationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'registrationCode')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectRegistrationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectRegistrationRequest copyWith(
          void Function(RejectRegistrationRequest) updates) =>
      super.copyWith((message) => updates(message as RejectRegistrationRequest))
          as RejectRegistrationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RejectRegistrationRequest create() => RejectRegistrationRequest._();
  @$core.override
  RejectRegistrationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RejectRegistrationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RejectRegistrationRequest>(create);
  static RejectRegistrationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get registrationCode => $_getSZ(0);
  @$pb.TagNumber(1)
  set registrationCode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRegistrationCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegistrationCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class ClearStalePairingsRequest extends $pb.GeneratedMessage {
  factory ClearStalePairingsRequest({
    $core.int? olderThanMinutes,
  }) {
    final result = create();
    if (olderThanMinutes != null) result.olderThanMinutes = olderThanMinutes;
    return result;
  }

  ClearStalePairingsRequest._();

  factory ClearStalePairingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClearStalePairingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClearStalePairingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'olderThanMinutes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearStalePairingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearStalePairingsRequest copyWith(
          void Function(ClearStalePairingsRequest) updates) =>
      super.copyWith((message) => updates(message as ClearStalePairingsRequest))
          as ClearStalePairingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClearStalePairingsRequest create() => ClearStalePairingsRequest._();
  @$core.override
  ClearStalePairingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClearStalePairingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClearStalePairingsRequest>(create);
  static ClearStalePairingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get olderThanMinutes => $_getIZ(0);
  @$pb.TagNumber(1)
  set olderThanMinutes($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOlderThanMinutes() => $_has(0);
  @$pb.TagNumber(1)
  void clearOlderThanMinutes() => $_clearField(1);
}

class ClearStalePairingsResponse extends $pb.GeneratedMessage {
  factory ClearStalePairingsResponse({
    $core.int? clearedCount,
  }) {
    final result = create();
    if (clearedCount != null) result.clearedCount = clearedCount;
    return result;
  }

  ClearStalePairingsResponse._();

  factory ClearStalePairingsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClearStalePairingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClearStalePairingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'clearedCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearStalePairingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearStalePairingsResponse copyWith(
          void Function(ClearStalePairingsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ClearStalePairingsResponse))
          as ClearStalePairingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClearStalePairingsResponse create() => ClearStalePairingsResponse._();
  @$core.override
  ClearStalePairingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClearStalePairingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClearStalePairingsResponse>(create);
  static ClearStalePairingsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get clearedCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set clearedCount($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClearedCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearClearedCount() => $_clearField(1);
}

class Device extends $pb.GeneratedMessage {
  factory Device({
    $core.String? id,
    $core.String? userId,
    $core.String? fcmToken,
    $core.String? deviceType,
    $2.Timestamp? registeredAt,
    $2.Timestamp? lastPushAt,
    $core.int? pushSuccessCount,
    $core.int? pushFailureCount,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (userId != null) result.userId = userId;
    if (fcmToken != null) result.fcmToken = fcmToken;
    if (deviceType != null) result.deviceType = deviceType;
    if (registeredAt != null) result.registeredAt = registeredAt;
    if (lastPushAt != null) result.lastPushAt = lastPushAt;
    if (pushSuccessCount != null) result.pushSuccessCount = pushSuccessCount;
    if (pushFailureCount != null) result.pushFailureCount = pushFailureCount;
    return result;
  }

  Device._();

  factory Device.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Device.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Device',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'fcmToken')
    ..aOS(4, _omitFieldNames ? '' : 'deviceType')
    ..aOM<$2.Timestamp>(5, _omitFieldNames ? '' : 'registeredAt',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'lastPushAt',
        subBuilder: $2.Timestamp.create)
    ..aI(7, _omitFieldNames ? '' : 'pushSuccessCount')
    ..aI(8, _omitFieldNames ? '' : 'pushFailureCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Device clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Device copyWith(void Function(Device) updates) =>
      super.copyWith((message) => updates(message as Device)) as Device;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Device create() => Device._();
  @$core.override
  Device createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Device getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Device>(create);
  static Device? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fcmToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set fcmToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFcmToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearFcmToken() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get deviceType => $_getSZ(3);
  @$pb.TagNumber(4)
  set deviceType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDeviceType() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeviceType() => $_clearField(4);

  @$pb.TagNumber(5)
  $2.Timestamp get registeredAt => $_getN(4);
  @$pb.TagNumber(5)
  set registeredAt($2.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRegisteredAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearRegisteredAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $2.Timestamp ensureRegisteredAt() => $_ensure(4);

  @$pb.TagNumber(6)
  $2.Timestamp get lastPushAt => $_getN(5);
  @$pb.TagNumber(6)
  set lastPushAt($2.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasLastPushAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearLastPushAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureLastPushAt() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.int get pushSuccessCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set pushSuccessCount($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPushSuccessCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearPushSuccessCount() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get pushFailureCount => $_getIZ(7);
  @$pb.TagNumber(8)
  set pushFailureCount($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPushFailureCount() => $_has(7);
  @$pb.TagNumber(8)
  void clearPushFailureCount() => $_clearField(8);
}

class ListDevicesRequest extends $pb.GeneratedMessage {
  factory ListDevicesRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? filterType,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (filterType != null) result.filterType = filterType;
    return result;
  }

  ListDevicesRequest._();

  factory ListDevicesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListDevicesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListDevicesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOS(3, _omitFieldNames ? '' : 'filterType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDevicesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDevicesRequest copyWith(void Function(ListDevicesRequest) updates) =>
      super.copyWith((message) => updates(message as ListDevicesRequest))
          as ListDevicesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDevicesRequest create() => ListDevicesRequest._();
  @$core.override
  ListDevicesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListDevicesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDevicesRequest>(create);
  static ListDevicesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set pageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get filterType => $_getSZ(2);
  @$pb.TagNumber(3)
  set filterType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFilterType() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilterType() => $_clearField(3);
}

class ListDevicesResponse extends $pb.GeneratedMessage {
  factory ListDevicesResponse({
    $core.Iterable<Device>? devices,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (devices != null) result.devices.addAll(devices);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListDevicesResponse._();

  factory ListDevicesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListDevicesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListDevicesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<Device>(1, _omitFieldNames ? '' : 'devices',
        subBuilder: Device.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDevicesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDevicesResponse copyWith(void Function(ListDevicesResponse) updates) =>
      super.copyWith((message) => updates(message as ListDevicesResponse))
          as ListDevicesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDevicesResponse create() => ListDevicesResponse._();
  @$core.override
  ListDevicesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListDevicesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDevicesResponse>(create);
  static ListDevicesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Device> get devices => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class GetUserDevicesRequest extends $pb.GeneratedMessage {
  factory GetUserDevicesRequest({
    $core.String? userId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    return result;
  }

  GetUserDevicesRequest._();

  factory GetUserDevicesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUserDevicesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUserDevicesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserDevicesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserDevicesRequest copyWith(
          void Function(GetUserDevicesRequest) updates) =>
      super.copyWith((message) => updates(message as GetUserDevicesRequest))
          as GetUserDevicesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUserDevicesRequest create() => GetUserDevicesRequest._();
  @$core.override
  GetUserDevicesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUserDevicesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUserDevicesRequest>(create);
  static GetUserDevicesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
}

class RemoveDeviceRequest extends $pb.GeneratedMessage {
  factory RemoveDeviceRequest({
    $core.String? deviceId,
    $core.String? reason,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (reason != null) result.reason = reason;
    return result;
  }

  RemoveDeviceRequest._();

  factory RemoveDeviceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveDeviceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveDeviceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveDeviceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveDeviceRequest copyWith(void Function(RemoveDeviceRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveDeviceRequest))
          as RemoveDeviceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveDeviceRequest create() => RemoveDeviceRequest._();
  @$core.override
  RemoveDeviceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveDeviceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveDeviceRequest>(create);
  static RemoveDeviceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class OrgInvite extends $pb.GeneratedMessage {
  factory OrgInvite({
    $core.String? token,
    $core.String? orgId,
    $core.String? orgName,
    $core.String? inviterUserId,
    $core.String? inviteePublicKeyId,
    $core.int? encryptedKeySize,
    $core.bool? passphraseRequired,
    $2.Timestamp? createdAt,
    $2.Timestamp? expiresAt,
    $core.bool? accepted,
  }) {
    final result = create();
    if (token != null) result.token = token;
    if (orgId != null) result.orgId = orgId;
    if (orgName != null) result.orgName = orgName;
    if (inviterUserId != null) result.inviterUserId = inviterUserId;
    if (inviteePublicKeyId != null)
      result.inviteePublicKeyId = inviteePublicKeyId;
    if (encryptedKeySize != null) result.encryptedKeySize = encryptedKeySize;
    if (passphraseRequired != null)
      result.passphraseRequired = passphraseRequired;
    if (createdAt != null) result.createdAt = createdAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (accepted != null) result.accepted = accepted;
    return result;
  }

  OrgInvite._();

  factory OrgInvite.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OrgInvite.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OrgInvite',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..aOS(2, _omitFieldNames ? '' : 'orgId')
    ..aOS(3, _omitFieldNames ? '' : 'orgName')
    ..aOS(4, _omitFieldNames ? '' : 'inviterUserId')
    ..aOS(5, _omitFieldNames ? '' : 'inviteePublicKeyId')
    ..aI(6, _omitFieldNames ? '' : 'encryptedKeySize')
    ..aOB(7, _omitFieldNames ? '' : 'passphraseRequired')
    ..aOM<$2.Timestamp>(8, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(9, _omitFieldNames ? '' : 'expiresAt',
        subBuilder: $2.Timestamp.create)
    ..aOB(10, _omitFieldNames ? '' : 'accepted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgInvite clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OrgInvite copyWith(void Function(OrgInvite) updates) =>
      super.copyWith((message) => updates(message as OrgInvite)) as OrgInvite;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrgInvite create() => OrgInvite._();
  @$core.override
  OrgInvite createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static OrgInvite getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrgInvite>(create);
  static OrgInvite? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get orgId => $_getSZ(1);
  @$pb.TagNumber(2)
  set orgId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOrgId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrgId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get orgName => $_getSZ(2);
  @$pb.TagNumber(3)
  set orgName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOrgName() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrgName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get inviterUserId => $_getSZ(3);
  @$pb.TagNumber(4)
  set inviterUserId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInviterUserId() => $_has(3);
  @$pb.TagNumber(4)
  void clearInviterUserId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get inviteePublicKeyId => $_getSZ(4);
  @$pb.TagNumber(5)
  set inviteePublicKeyId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasInviteePublicKeyId() => $_has(4);
  @$pb.TagNumber(5)
  void clearInviteePublicKeyId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get encryptedKeySize => $_getIZ(5);
  @$pb.TagNumber(6)
  set encryptedKeySize($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEncryptedKeySize() => $_has(5);
  @$pb.TagNumber(6)
  void clearEncryptedKeySize() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get passphraseRequired => $_getBF(6);
  @$pb.TagNumber(7)
  set passphraseRequired($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPassphraseRequired() => $_has(6);
  @$pb.TagNumber(7)
  void clearPassphraseRequired() => $_clearField(7);

  @$pb.TagNumber(8)
  $2.Timestamp get createdAt => $_getN(7);
  @$pb.TagNumber(8)
  set createdAt($2.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $2.Timestamp ensureCreatedAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $2.Timestamp get expiresAt => $_getN(8);
  @$pb.TagNumber(9)
  set expiresAt($2.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasExpiresAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearExpiresAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $2.Timestamp ensureExpiresAt() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.bool get accepted => $_getBF(9);
  @$pb.TagNumber(10)
  set accepted($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasAccepted() => $_has(9);
  @$pb.TagNumber(10)
  void clearAccepted() => $_clearField(10);
}

class ListActiveOrgInvitesRequest extends $pb.GeneratedMessage {
  factory ListActiveOrgInvitesRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? filterOrgId,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (filterOrgId != null) result.filterOrgId = filterOrgId;
    return result;
  }

  ListActiveOrgInvitesRequest._();

  factory ListActiveOrgInvitesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListActiveOrgInvitesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListActiveOrgInvitesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOS(3, _omitFieldNames ? '' : 'filterOrgId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActiveOrgInvitesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActiveOrgInvitesRequest copyWith(
          void Function(ListActiveOrgInvitesRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ListActiveOrgInvitesRequest))
          as ListActiveOrgInvitesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListActiveOrgInvitesRequest create() =>
      ListActiveOrgInvitesRequest._();
  @$core.override
  ListActiveOrgInvitesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListActiveOrgInvitesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListActiveOrgInvitesRequest>(create);
  static ListActiveOrgInvitesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set pageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get filterOrgId => $_getSZ(2);
  @$pb.TagNumber(3)
  set filterOrgId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFilterOrgId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilterOrgId() => $_clearField(3);
}

class ListActiveOrgInvitesResponse extends $pb.GeneratedMessage {
  factory ListActiveOrgInvitesResponse({
    $core.Iterable<OrgInvite>? invites,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (invites != null) result.invites.addAll(invites);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListActiveOrgInvitesResponse._();

  factory ListActiveOrgInvitesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListActiveOrgInvitesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListActiveOrgInvitesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<OrgInvite>(1, _omitFieldNames ? '' : 'invites',
        subBuilder: OrgInvite.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActiveOrgInvitesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActiveOrgInvitesResponse copyWith(
          void Function(ListActiveOrgInvitesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListActiveOrgInvitesResponse))
          as ListActiveOrgInvitesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListActiveOrgInvitesResponse create() =>
      ListActiveOrgInvitesResponse._();
  @$core.override
  ListActiveOrgInvitesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListActiveOrgInvitesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListActiveOrgInvitesResponse>(create);
  static ListActiveOrgInvitesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<OrgInvite> get invites => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class RevokeOrgInviteRequest extends $pb.GeneratedMessage {
  factory RevokeOrgInviteRequest({
    $core.String? token,
    $core.String? reason,
  }) {
    final result = create();
    if (token != null) result.token = token;
    if (reason != null) result.reason = reason;
    return result;
  }

  RevokeOrgInviteRequest._();

  factory RevokeOrgInviteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RevokeOrgInviteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevokeOrgInviteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeOrgInviteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeOrgInviteRequest copyWith(
          void Function(RevokeOrgInviteRequest) updates) =>
      super.copyWith((message) => updates(message as RevokeOrgInviteRequest))
          as RevokeOrgInviteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevokeOrgInviteRequest create() => RevokeOrgInviteRequest._();
  @$core.override
  RevokeOrgInviteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RevokeOrgInviteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RevokeOrgInviteRequest>(create);
  static RevokeOrgInviteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class TemplateBlob extends $pb.GeneratedMessage {
  factory TemplateBlob({
    $core.String? id,
    $core.String? userId,
    $core.String? orgId,
    $core.String? encryptionType,
    $core.int? encryptedSizeBytes,
    $fixnum.Int64? version,
    $2.Timestamp? createdAt,
    $2.Timestamp? expiresAt,
    $core.bool? expired,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (userId != null) result.userId = userId;
    if (orgId != null) result.orgId = orgId;
    if (encryptionType != null) result.encryptionType = encryptionType;
    if (encryptedSizeBytes != null)
      result.encryptedSizeBytes = encryptedSizeBytes;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (expired != null) result.expired = expired;
    return result;
  }

  TemplateBlob._();

  factory TemplateBlob.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TemplateBlob.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemplateBlob',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'orgId')
    ..aOS(4, _omitFieldNames ? '' : 'encryptionType')
    ..aI(5, _omitFieldNames ? '' : 'encryptedSizeBytes')
    ..aInt64(6, _omitFieldNames ? '' : 'version')
    ..aOM<$2.Timestamp>(7, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(8, _omitFieldNames ? '' : 'expiresAt',
        subBuilder: $2.Timestamp.create)
    ..aOB(9, _omitFieldNames ? '' : 'expired')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateBlob clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateBlob copyWith(void Function(TemplateBlob) updates) =>
      super.copyWith((message) => updates(message as TemplateBlob))
          as TemplateBlob;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TemplateBlob create() => TemplateBlob._();
  @$core.override
  TemplateBlob createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TemplateBlob getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TemplateBlob>(create);
  static TemplateBlob? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get orgId => $_getSZ(2);
  @$pb.TagNumber(3)
  set orgId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOrgId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrgId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get encryptionType => $_getSZ(3);
  @$pb.TagNumber(4)
  set encryptionType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEncryptionType() => $_has(3);
  @$pb.TagNumber(4)
  void clearEncryptionType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get encryptedSizeBytes => $_getIZ(4);
  @$pb.TagNumber(5)
  set encryptedSizeBytes($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEncryptedSizeBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearEncryptedSizeBytes() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get version => $_getI64(5);
  @$pb.TagNumber(6)
  set version($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersion() => $_clearField(6);

  @$pb.TagNumber(7)
  $2.Timestamp get createdAt => $_getN(6);
  @$pb.TagNumber(7)
  set createdAt($2.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $2.Timestamp ensureCreatedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $2.Timestamp get expiresAt => $_getN(7);
  @$pb.TagNumber(8)
  set expiresAt($2.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasExpiresAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearExpiresAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $2.Timestamp ensureExpiresAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.bool get expired => $_getBF(8);
  @$pb.TagNumber(9)
  set expired($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasExpired() => $_has(8);
  @$pb.TagNumber(9)
  void clearExpired() => $_clearField(9);
}

class ListUserTemplatesRequest extends $pb.GeneratedMessage {
  factory ListUserTemplatesRequest({
    $core.String? userId,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListUserTemplatesRequest._();

  factory ListUserTemplatesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListUserTemplatesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListUserTemplatesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aI(2, _omitFieldNames ? '' : 'pageSize')
    ..aOS(3, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUserTemplatesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUserTemplatesRequest copyWith(
          void Function(ListUserTemplatesRequest) updates) =>
      super.copyWith((message) => updates(message as ListUserTemplatesRequest))
          as ListUserTemplatesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUserTemplatesRequest create() => ListUserTemplatesRequest._();
  @$core.override
  ListUserTemplatesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListUserTemplatesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListUserTemplatesRequest>(create);
  static ListUserTemplatesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get pageToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set pageToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageToken() => $_clearField(3);
}

class ListUserTemplatesResponse extends $pb.GeneratedMessage {
  factory ListUserTemplatesResponse({
    $core.Iterable<TemplateBlob>? templates,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (templates != null) result.templates.addAll(templates);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListUserTemplatesResponse._();

  factory ListUserTemplatesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListUserTemplatesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListUserTemplatesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<TemplateBlob>(1, _omitFieldNames ? '' : 'templates',
        subBuilder: TemplateBlob.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUserTemplatesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUserTemplatesResponse copyWith(
          void Function(ListUserTemplatesResponse) updates) =>
      super.copyWith((message) => updates(message as ListUserTemplatesResponse))
          as ListUserTemplatesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUserTemplatesResponse create() => ListUserTemplatesResponse._();
  @$core.override
  ListUserTemplatesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListUserTemplatesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListUserTemplatesResponse>(create);
  static ListUserTemplatesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TemplateBlob> get templates => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class GetTemplateStatsRequest extends $pb.GeneratedMessage {
  factory GetTemplateStatsRequest() => create();

  GetTemplateStatsRequest._();

  factory GetTemplateStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTemplateStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTemplateStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTemplateStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTemplateStatsRequest copyWith(
          void Function(GetTemplateStatsRequest) updates) =>
      super.copyWith((message) => updates(message as GetTemplateStatsRequest))
          as GetTemplateStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTemplateStatsRequest create() => GetTemplateStatsRequest._();
  @$core.override
  GetTemplateStatsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTemplateStatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTemplateStatsRequest>(create);
  static GetTemplateStatsRequest? _defaultInstance;
}

class TemplateStats extends $pb.GeneratedMessage {
  factory TemplateStats({
    $core.int? totalTemplates,
    $fixnum.Int64? totalStorageBytes,
    $core.int? personalTemplates,
    $core.int? orgTemplates,
    $core.int? expiredTemplates,
    $core.Iterable<$core.MapEntry<$core.String, $core.int>>? templatesByUser,
  }) {
    final result = create();
    if (totalTemplates != null) result.totalTemplates = totalTemplates;
    if (totalStorageBytes != null) result.totalStorageBytes = totalStorageBytes;
    if (personalTemplates != null) result.personalTemplates = personalTemplates;
    if (orgTemplates != null) result.orgTemplates = orgTemplates;
    if (expiredTemplates != null) result.expiredTemplates = expiredTemplates;
    if (templatesByUser != null)
      result.templatesByUser.addEntries(templatesByUser);
    return result;
  }

  TemplateStats._();

  factory TemplateStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TemplateStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemplateStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'totalTemplates')
    ..aInt64(2, _omitFieldNames ? '' : 'totalStorageBytes')
    ..aI(3, _omitFieldNames ? '' : 'personalTemplates')
    ..aI(4, _omitFieldNames ? '' : 'orgTemplates')
    ..aI(5, _omitFieldNames ? '' : 'expiredTemplates')
    ..m<$core.String, $core.int>(6, _omitFieldNames ? '' : 'templatesByUser',
        entryClassName: 'TemplateStats.TemplatesByUserEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('nitella.hub'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemplateStats copyWith(void Function(TemplateStats) updates) =>
      super.copyWith((message) => updates(message as TemplateStats))
          as TemplateStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TemplateStats create() => TemplateStats._();
  @$core.override
  TemplateStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TemplateStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TemplateStats>(create);
  static TemplateStats? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get totalTemplates => $_getIZ(0);
  @$pb.TagNumber(1)
  set totalTemplates($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalTemplates() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalTemplates() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalStorageBytes => $_getI64(1);
  @$pb.TagNumber(2)
  set totalStorageBytes($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalStorageBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalStorageBytes() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get personalTemplates => $_getIZ(2);
  @$pb.TagNumber(3)
  set personalTemplates($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPersonalTemplates() => $_has(2);
  @$pb.TagNumber(3)
  void clearPersonalTemplates() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get orgTemplates => $_getIZ(3);
  @$pb.TagNumber(4)
  set orgTemplates($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOrgTemplates() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrgTemplates() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get expiredTemplates => $_getIZ(4);
  @$pb.TagNumber(5)
  set expiredTemplates($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpiredTemplates() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpiredTemplates() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbMap<$core.String, $core.int> get templatesByUser => $_getMap(5);
}

class DeleteUserTemplatesRequest extends $pb.GeneratedMessage {
  factory DeleteUserTemplatesRequest({
    $core.String? userId,
    $core.bool? expiredOnly,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (expiredOnly != null) result.expiredOnly = expiredOnly;
    return result;
  }

  DeleteUserTemplatesRequest._();

  factory DeleteUserTemplatesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteUserTemplatesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteUserTemplatesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOB(2, _omitFieldNames ? '' : 'expiredOnly')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteUserTemplatesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteUserTemplatesRequest copyWith(
          void Function(DeleteUserTemplatesRequest) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteUserTemplatesRequest))
          as DeleteUserTemplatesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteUserTemplatesRequest create() => DeleteUserTemplatesRequest._();
  @$core.override
  DeleteUserTemplatesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteUserTemplatesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteUserTemplatesRequest>(create);
  static DeleteUserTemplatesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get expiredOnly => $_getBF(1);
  @$pb.TagNumber(2)
  set expiredOnly($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpiredOnly() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpiredOnly() => $_clearField(2);
}

class ListPromoCodesRequest extends $pb.GeneratedMessage {
  factory ListPromoCodesRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.bool? includeExpired,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (includeExpired != null) result.includeExpired = includeExpired;
    return result;
  }

  ListPromoCodesRequest._();

  factory ListPromoCodesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPromoCodesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPromoCodesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOB(3, _omitFieldNames ? '' : 'includeExpired')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPromoCodesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPromoCodesRequest copyWith(
          void Function(ListPromoCodesRequest) updates) =>
      super.copyWith((message) => updates(message as ListPromoCodesRequest))
          as ListPromoCodesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPromoCodesRequest create() => ListPromoCodesRequest._();
  @$core.override
  ListPromoCodesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPromoCodesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPromoCodesRequest>(create);
  static ListPromoCodesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set pageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get includeExpired => $_getBF(2);
  @$pb.TagNumber(3)
  set includeExpired($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIncludeExpired() => $_has(2);
  @$pb.TagNumber(3)
  void clearIncludeExpired() => $_clearField(3);
}

class ListPromoCodesResponse extends $pb.GeneratedMessage {
  factory ListPromoCodesResponse({
    $core.Iterable<PromoCode>? codes,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (codes != null) result.codes.addAll(codes);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListPromoCodesResponse._();

  factory ListPromoCodesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPromoCodesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPromoCodesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<PromoCode>(1, _omitFieldNames ? '' : 'codes',
        subBuilder: PromoCode.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPromoCodesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPromoCodesResponse copyWith(
          void Function(ListPromoCodesResponse) updates) =>
      super.copyWith((message) => updates(message as ListPromoCodesResponse))
          as ListPromoCodesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPromoCodesResponse create() => ListPromoCodesResponse._();
  @$core.override
  ListPromoCodesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPromoCodesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPromoCodesResponse>(create);
  static ListPromoCodesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PromoCode> get codes => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class GetMaintenanceStatusRequest extends $pb.GeneratedMessage {
  factory GetMaintenanceStatusRequest() => create();

  GetMaintenanceStatusRequest._();

  factory GetMaintenanceStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMaintenanceStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMaintenanceStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMaintenanceStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMaintenanceStatusRequest copyWith(
          void Function(GetMaintenanceStatusRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetMaintenanceStatusRequest))
          as GetMaintenanceStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMaintenanceStatusRequest create() =>
      GetMaintenanceStatusRequest._();
  @$core.override
  GetMaintenanceStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMaintenanceStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMaintenanceStatusRequest>(create);
  static GetMaintenanceStatusRequest? _defaultInstance;
}

class MaintenanceStatus extends $pb.GeneratedMessage {
  factory MaintenanceStatus({
    $core.bool? enabled,
    $core.String? message,
    $2.Timestamp? startedAt,
    $2.Timestamp? expectedEnd,
    $core.bool? rejectNewConnections,
    $core.bool? allowAdminAccess,
  }) {
    final result = create();
    if (enabled != null) result.enabled = enabled;
    if (message != null) result.message = message;
    if (startedAt != null) result.startedAt = startedAt;
    if (expectedEnd != null) result.expectedEnd = expectedEnd;
    if (rejectNewConnections != null)
      result.rejectNewConnections = rejectNewConnections;
    if (allowAdminAccess != null) result.allowAdminAccess = allowAdminAccess;
    return result;
  }

  MaintenanceStatus._();

  factory MaintenanceStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MaintenanceStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MaintenanceStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<$2.Timestamp>(3, _omitFieldNames ? '' : 'startedAt',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(4, _omitFieldNames ? '' : 'expectedEnd',
        subBuilder: $2.Timestamp.create)
    ..aOB(5, _omitFieldNames ? '' : 'rejectNewConnections')
    ..aOB(6, _omitFieldNames ? '' : 'allowAdminAccess')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MaintenanceStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MaintenanceStatus copyWith(void Function(MaintenanceStatus) updates) =>
      super.copyWith((message) => updates(message as MaintenanceStatus))
          as MaintenanceStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MaintenanceStatus create() => MaintenanceStatus._();
  @$core.override
  MaintenanceStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MaintenanceStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MaintenanceStatus>(create);
  static MaintenanceStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $2.Timestamp get startedAt => $_getN(2);
  @$pb.TagNumber(3)
  set startedAt($2.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStartedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartedAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.Timestamp ensureStartedAt() => $_ensure(2);

  @$pb.TagNumber(4)
  $2.Timestamp get expectedEnd => $_getN(3);
  @$pb.TagNumber(4)
  set expectedEnd($2.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasExpectedEnd() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpectedEnd() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.Timestamp ensureExpectedEnd() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.bool get rejectNewConnections => $_getBF(4);
  @$pb.TagNumber(5)
  set rejectNewConnections($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRejectNewConnections() => $_has(4);
  @$pb.TagNumber(5)
  void clearRejectNewConnections() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get allowAdminAccess => $_getBF(5);
  @$pb.TagNumber(6)
  set allowAdminAccess($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAllowAdminAccess() => $_has(5);
  @$pb.TagNumber(6)
  void clearAllowAdminAccess() => $_clearField(6);
}

class SetMaintenanceModeRequest extends $pb.GeneratedMessage {
  factory SetMaintenanceModeRequest({
    $core.bool? enabled,
    $core.String? message,
    $core.int? durationMinutes,
    $core.bool? rejectNewConnections,
  }) {
    final result = create();
    if (enabled != null) result.enabled = enabled;
    if (message != null) result.message = message;
    if (durationMinutes != null) result.durationMinutes = durationMinutes;
    if (rejectNewConnections != null)
      result.rejectNewConnections = rejectNewConnections;
    return result;
  }

  SetMaintenanceModeRequest._();

  factory SetMaintenanceModeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetMaintenanceModeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetMaintenanceModeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aI(3, _omitFieldNames ? '' : 'durationMinutes')
    ..aOB(4, _omitFieldNames ? '' : 'rejectNewConnections')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMaintenanceModeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMaintenanceModeRequest copyWith(
          void Function(SetMaintenanceModeRequest) updates) =>
      super.copyWith((message) => updates(message as SetMaintenanceModeRequest))
          as SetMaintenanceModeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetMaintenanceModeRequest create() => SetMaintenanceModeRequest._();
  @$core.override
  SetMaintenanceModeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetMaintenanceModeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetMaintenanceModeRequest>(create);
  static SetMaintenanceModeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get durationMinutes => $_getIZ(2);
  @$pb.TagNumber(3)
  set durationMinutes($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDurationMinutes() => $_has(2);
  @$pb.TagNumber(3)
  void clearDurationMinutes() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get rejectNewConnections => $_getBF(3);
  @$pb.TagNumber(4)
  set rejectNewConnections($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRejectNewConnections() => $_has(3);
  @$pb.TagNumber(4)
  void clearRejectNewConnections() => $_clearField(4);
}

class BroadcastAnnouncementRequest extends $pb.GeneratedMessage {
  factory BroadcastAnnouncementRequest({
    $core.String? title,
    $core.String? message,
    $core.String? severity,
    $core.Iterable<$core.String>? targetUserIds,
    $core.Iterable<$core.String>? targetNodeIds,
    $core.bool? persistent,
  }) {
    final result = create();
    if (title != null) result.title = title;
    if (message != null) result.message = message;
    if (severity != null) result.severity = severity;
    if (targetUserIds != null) result.targetUserIds.addAll(targetUserIds);
    if (targetNodeIds != null) result.targetNodeIds.addAll(targetNodeIds);
    if (persistent != null) result.persistent = persistent;
    return result;
  }

  BroadcastAnnouncementRequest._();

  factory BroadcastAnnouncementRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BroadcastAnnouncementRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BroadcastAnnouncementRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'severity')
    ..pPS(4, _omitFieldNames ? '' : 'targetUserIds')
    ..pPS(5, _omitFieldNames ? '' : 'targetNodeIds')
    ..aOB(6, _omitFieldNames ? '' : 'persistent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastAnnouncementRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastAnnouncementRequest copyWith(
          void Function(BroadcastAnnouncementRequest) updates) =>
      super.copyWith(
              (message) => updates(message as BroadcastAnnouncementRequest))
          as BroadcastAnnouncementRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BroadcastAnnouncementRequest create() =>
      BroadcastAnnouncementRequest._();
  @$core.override
  BroadcastAnnouncementRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BroadcastAnnouncementRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BroadcastAnnouncementRequest>(create);
  static BroadcastAnnouncementRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get severity => $_getSZ(2);
  @$pb.TagNumber(3)
  set severity($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSeverity() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeverity() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get targetUserIds => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get targetNodeIds => $_getList(4);

  @$pb.TagNumber(6)
  $core.bool get persistent => $_getBF(5);
  @$pb.TagNumber(6)
  set persistent($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPersistent() => $_has(5);
  @$pb.TagNumber(6)
  void clearPersistent() => $_clearField(6);
}

class BroadcastAnnouncementResponse extends $pb.GeneratedMessage {
  factory BroadcastAnnouncementResponse({
    $core.int? nodesNotified,
    $core.int? usersNotified,
    $core.int? devicesPushed,
  }) {
    final result = create();
    if (nodesNotified != null) result.nodesNotified = nodesNotified;
    if (usersNotified != null) result.usersNotified = usersNotified;
    if (devicesPushed != null) result.devicesPushed = devicesPushed;
    return result;
  }

  BroadcastAnnouncementResponse._();

  factory BroadcastAnnouncementResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BroadcastAnnouncementResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BroadcastAnnouncementResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'nodesNotified')
    ..aI(2, _omitFieldNames ? '' : 'usersNotified')
    ..aI(3, _omitFieldNames ? '' : 'devicesPushed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastAnnouncementResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastAnnouncementResponse copyWith(
          void Function(BroadcastAnnouncementResponse) updates) =>
      super.copyWith(
              (message) => updates(message as BroadcastAnnouncementResponse))
          as BroadcastAnnouncementResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BroadcastAnnouncementResponse create() =>
      BroadcastAnnouncementResponse._();
  @$core.override
  BroadcastAnnouncementResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BroadcastAnnouncementResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BroadcastAnnouncementResponse>(create);
  static BroadcastAnnouncementResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get nodesNotified => $_getIZ(0);
  @$pb.TagNumber(1)
  set nodesNotified($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodesNotified() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodesNotified() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get usersNotified => $_getIZ(1);
  @$pb.TagNumber(2)
  set usersNotified($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUsersNotified() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsersNotified() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get devicesPushed => $_getIZ(2);
  @$pb.TagNumber(3)
  set devicesPushed($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDevicesPushed() => $_has(2);
  @$pb.TagNumber(3)
  void clearDevicesPushed() => $_clearField(3);
}

class GetActiveStreamsRequest extends $pb.GeneratedMessage {
  factory GetActiveStreamsRequest() => create();

  GetActiveStreamsRequest._();

  factory GetActiveStreamsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetActiveStreamsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetActiveStreamsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetActiveStreamsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetActiveStreamsRequest copyWith(
          void Function(GetActiveStreamsRequest) updates) =>
      super.copyWith((message) => updates(message as GetActiveStreamsRequest))
          as GetActiveStreamsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetActiveStreamsRequest create() => GetActiveStreamsRequest._();
  @$core.override
  GetActiveStreamsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetActiveStreamsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetActiveStreamsRequest>(create);
  static GetActiveStreamsRequest? _defaultInstance;
}

class ActiveStream extends $pb.GeneratedMessage {
  factory ActiveStream({
    $core.String? streamId,
    $core.String? userId,
    $core.String? nodeId,
    $core.String? streamType,
    $2.Timestamp? startedAt,
    $fixnum.Int64? messagesSent,
    $fixnum.Int64? messagesReceived,
    $core.String? sourceIp,
  }) {
    final result = create();
    if (streamId != null) result.streamId = streamId;
    if (userId != null) result.userId = userId;
    if (nodeId != null) result.nodeId = nodeId;
    if (streamType != null) result.streamType = streamType;
    if (startedAt != null) result.startedAt = startedAt;
    if (messagesSent != null) result.messagesSent = messagesSent;
    if (messagesReceived != null) result.messagesReceived = messagesReceived;
    if (sourceIp != null) result.sourceIp = sourceIp;
    return result;
  }

  ActiveStream._();

  factory ActiveStream.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActiveStream.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActiveStream',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'streamId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'nodeId')
    ..aOS(4, _omitFieldNames ? '' : 'streamType')
    ..aOM<$2.Timestamp>(5, _omitFieldNames ? '' : 'startedAt',
        subBuilder: $2.Timestamp.create)
    ..aInt64(6, _omitFieldNames ? '' : 'messagesSent')
    ..aInt64(7, _omitFieldNames ? '' : 'messagesReceived')
    ..aOS(8, _omitFieldNames ? '' : 'sourceIp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActiveStream clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActiveStream copyWith(void Function(ActiveStream) updates) =>
      super.copyWith((message) => updates(message as ActiveStream))
          as ActiveStream;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActiveStream create() => ActiveStream._();
  @$core.override
  ActiveStream createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ActiveStream getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActiveStream>(create);
  static ActiveStream? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get streamId => $_getSZ(0);
  @$pb.TagNumber(1)
  set streamId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStreamId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStreamId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get nodeId => $_getSZ(2);
  @$pb.TagNumber(3)
  set nodeId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeId() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get streamType => $_getSZ(3);
  @$pb.TagNumber(4)
  set streamType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStreamType() => $_has(3);
  @$pb.TagNumber(4)
  void clearStreamType() => $_clearField(4);

  @$pb.TagNumber(5)
  $2.Timestamp get startedAt => $_getN(4);
  @$pb.TagNumber(5)
  set startedAt($2.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStartedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearStartedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $2.Timestamp ensureStartedAt() => $_ensure(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get messagesSent => $_getI64(5);
  @$pb.TagNumber(6)
  set messagesSent($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMessagesSent() => $_has(5);
  @$pb.TagNumber(6)
  void clearMessagesSent() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get messagesReceived => $_getI64(6);
  @$pb.TagNumber(7)
  set messagesReceived($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMessagesReceived() => $_has(6);
  @$pb.TagNumber(7)
  void clearMessagesReceived() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get sourceIp => $_getSZ(7);
  @$pb.TagNumber(8)
  set sourceIp($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSourceIp() => $_has(7);
  @$pb.TagNumber(8)
  void clearSourceIp() => $_clearField(8);
}

class GetActiveStreamsResponse extends $pb.GeneratedMessage {
  factory GetActiveStreamsResponse({
    $core.Iterable<ActiveStream>? streams,
    $core.int? totalCount,
    $core.Iterable<$core.MapEntry<$core.String, $core.int>>? streamsByType,
  }) {
    final result = create();
    if (streams != null) result.streams.addAll(streams);
    if (totalCount != null) result.totalCount = totalCount;
    if (streamsByType != null) result.streamsByType.addEntries(streamsByType);
    return result;
  }

  GetActiveStreamsResponse._();

  factory GetActiveStreamsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetActiveStreamsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetActiveStreamsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<ActiveStream>(1, _omitFieldNames ? '' : 'streams',
        subBuilder: ActiveStream.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..m<$core.String, $core.int>(3, _omitFieldNames ? '' : 'streamsByType',
        entryClassName: 'GetActiveStreamsResponse.StreamsByTypeEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('nitella.hub'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetActiveStreamsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetActiveStreamsResponse copyWith(
          void Function(GetActiveStreamsResponse) updates) =>
      super.copyWith((message) => updates(message as GetActiveStreamsResponse))
          as GetActiveStreamsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetActiveStreamsResponse create() => GetActiveStreamsResponse._();
  @$core.override
  GetActiveStreamsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetActiveStreamsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetActiveStreamsResponse>(create);
  static GetActiveStreamsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ActiveStream> get streams => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.int> get streamsByType => $_getMap(2);
}

class GetRateLimitStatusRequest extends $pb.GeneratedMessage {
  factory GetRateLimitStatusRequest({
    $core.String? filterUserId,
    $core.String? filterTier,
  }) {
    final result = create();
    if (filterUserId != null) result.filterUserId = filterUserId;
    if (filterTier != null) result.filterTier = filterTier;
    return result;
  }

  GetRateLimitStatusRequest._();

  factory GetRateLimitStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRateLimitStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRateLimitStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filterUserId')
    ..aOS(2, _omitFieldNames ? '' : 'filterTier')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRateLimitStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRateLimitStatusRequest copyWith(
          void Function(GetRateLimitStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetRateLimitStatusRequest))
          as GetRateLimitStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRateLimitStatusRequest create() => GetRateLimitStatusRequest._();
  @$core.override
  GetRateLimitStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRateLimitStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRateLimitStatusRequest>(create);
  static GetRateLimitStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filterUserId => $_getSZ(0);
  @$pb.TagNumber(1)
  set filterUserId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFilterUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilterUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get filterTier => $_getSZ(1);
  @$pb.TagNumber(2)
  set filterTier($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFilterTier() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilterTier() => $_clearField(2);
}

class RateLimitEntry extends $pb.GeneratedMessage {
  factory RateLimitEntry({
    $core.String? userId,
    $core.String? tier,
    $core.int? requestsPerSecond,
    $core.int? burstSize,
    $core.int? currentTokens,
    $core.int? requestsLastMinute,
    $core.int? throttledCount,
    $2.Timestamp? lastRequest,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (tier != null) result.tier = tier;
    if (requestsPerSecond != null) result.requestsPerSecond = requestsPerSecond;
    if (burstSize != null) result.burstSize = burstSize;
    if (currentTokens != null) result.currentTokens = currentTokens;
    if (requestsLastMinute != null)
      result.requestsLastMinute = requestsLastMinute;
    if (throttledCount != null) result.throttledCount = throttledCount;
    if (lastRequest != null) result.lastRequest = lastRequest;
    return result;
  }

  RateLimitEntry._();

  factory RateLimitEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RateLimitEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RateLimitEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'tier')
    ..aI(3, _omitFieldNames ? '' : 'requestsPerSecond')
    ..aI(4, _omitFieldNames ? '' : 'burstSize')
    ..aI(5, _omitFieldNames ? '' : 'currentTokens')
    ..aI(6, _omitFieldNames ? '' : 'requestsLastMinute')
    ..aI(7, _omitFieldNames ? '' : 'throttledCount')
    ..aOM<$2.Timestamp>(8, _omitFieldNames ? '' : 'lastRequest',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RateLimitEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RateLimitEntry copyWith(void Function(RateLimitEntry) updates) =>
      super.copyWith((message) => updates(message as RateLimitEntry))
          as RateLimitEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RateLimitEntry create() => RateLimitEntry._();
  @$core.override
  RateLimitEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RateLimitEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RateLimitEntry>(create);
  static RateLimitEntry? _defaultInstance;

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
  $core.int get requestsPerSecond => $_getIZ(2);
  @$pb.TagNumber(3)
  set requestsPerSecond($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRequestsPerSecond() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequestsPerSecond() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get burstSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set burstSize($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBurstSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearBurstSize() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get currentTokens => $_getIZ(4);
  @$pb.TagNumber(5)
  set currentTokens($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCurrentTokens() => $_has(4);
  @$pb.TagNumber(5)
  void clearCurrentTokens() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get requestsLastMinute => $_getIZ(5);
  @$pb.TagNumber(6)
  set requestsLastMinute($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRequestsLastMinute() => $_has(5);
  @$pb.TagNumber(6)
  void clearRequestsLastMinute() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get throttledCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set throttledCount($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasThrottledCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearThrottledCount() => $_clearField(7);

  @$pb.TagNumber(8)
  $2.Timestamp get lastRequest => $_getN(7);
  @$pb.TagNumber(8)
  set lastRequest($2.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasLastRequest() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastRequest() => $_clearField(8);
  @$pb.TagNumber(8)
  $2.Timestamp ensureLastRequest() => $_ensure(7);
}

class GetRateLimitStatusResponse extends $pb.GeneratedMessage {
  factory GetRateLimitStatusResponse({
    $core.Iterable<RateLimitEntry>? entries,
    $core.int? totalThrottledToday,
  }) {
    final result = create();
    if (entries != null) result.entries.addAll(entries);
    if (totalThrottledToday != null)
      result.totalThrottledToday = totalThrottledToday;
    return result;
  }

  GetRateLimitStatusResponse._();

  factory GetRateLimitStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRateLimitStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRateLimitStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<RateLimitEntry>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: RateLimitEntry.create)
    ..aI(2, _omitFieldNames ? '' : 'totalThrottledToday')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRateLimitStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRateLimitStatusResponse copyWith(
          void Function(GetRateLimitStatusResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetRateLimitStatusResponse))
          as GetRateLimitStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRateLimitStatusResponse create() => GetRateLimitStatusResponse._();
  @$core.override
  GetRateLimitStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRateLimitStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRateLimitStatusResponse>(create);
  static GetRateLimitStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RateLimitEntry> get entries => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalThrottledToday => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalThrottledToday($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalThrottledToday() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalThrottledToday() => $_clearField(2);
}

class RevokeCertificateRequest extends $pb.GeneratedMessage {
  factory RevokeCertificateRequest({
    $core.String? serialNumber,
    $core.String? reason,
    $core.bool? notifyNodes,
  }) {
    final result = create();
    if (serialNumber != null) result.serialNumber = serialNumber;
    if (reason != null) result.reason = reason;
    if (notifyNodes != null) result.notifyNodes = notifyNodes;
    return result;
  }

  RevokeCertificateRequest._();

  factory RevokeCertificateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RevokeCertificateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevokeCertificateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'serialNumber')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..aOB(3, _omitFieldNames ? '' : 'notifyNodes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeCertificateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeCertificateRequest copyWith(
          void Function(RevokeCertificateRequest) updates) =>
      super.copyWith((message) => updates(message as RevokeCertificateRequest))
          as RevokeCertificateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevokeCertificateRequest create() => RevokeCertificateRequest._();
  @$core.override
  RevokeCertificateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RevokeCertificateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RevokeCertificateRequest>(create);
  static RevokeCertificateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get serialNumber => $_getSZ(0);
  @$pb.TagNumber(1)
  set serialNumber($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSerialNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSerialNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get notifyNodes => $_getBF(2);
  @$pb.TagNumber(3)
  set notifyNodes($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNotifyNodes() => $_has(2);
  @$pb.TagNumber(3)
  void clearNotifyNodes() => $_clearField(3);
}

class ListInviteCodesRequest extends $pb.GeneratedMessage {
  factory ListInviteCodesRequest({
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListInviteCodesRequest._();

  factory ListInviteCodesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListInviteCodesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListInviteCodesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInviteCodesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInviteCodesRequest copyWith(
          void Function(ListInviteCodesRequest) updates) =>
      super.copyWith((message) => updates(message as ListInviteCodesRequest))
          as ListInviteCodesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListInviteCodesRequest create() => ListInviteCodesRequest._();
  @$core.override
  ListInviteCodesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListInviteCodesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListInviteCodesRequest>(create);
  static ListInviteCodesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set pageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageToken() => $_clearField(2);
}

class ListInviteCodesResponse extends $pb.GeneratedMessage {
  factory ListInviteCodesResponse({
    $core.Iterable<InviteCode>? codes,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (codes != null) result.codes.addAll(codes);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListInviteCodesResponse._();

  factory ListInviteCodesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListInviteCodesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListInviteCodesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<InviteCode>(1, _omitFieldNames ? '' : 'codes',
        subBuilder: InviteCode.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInviteCodesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInviteCodesResponse copyWith(
          void Function(ListInviteCodesResponse) updates) =>
      super.copyWith((message) => updates(message as ListInviteCodesResponse))
          as ListInviteCodesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListInviteCodesResponse create() => ListInviteCodesResponse._();
  @$core.override
  ListInviteCodesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListInviteCodesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListInviteCodesResponse>(create);
  static ListInviteCodesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<InviteCode> get codes => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class DumpEncryptedBlobsRequest extends $pb.GeneratedMessage {
  factory DumpEncryptedBlobsRequest({
    $core.String? blobType,
    $core.int? limit,
    $core.bool? includeRawBytes,
  }) {
    final result = create();
    if (blobType != null) result.blobType = blobType;
    if (limit != null) result.limit = limit;
    if (includeRawBytes != null) result.includeRawBytes = includeRawBytes;
    return result;
  }

  DumpEncryptedBlobsRequest._();

  factory DumpEncryptedBlobsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DumpEncryptedBlobsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DumpEncryptedBlobsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'blobType')
    ..aI(2, _omitFieldNames ? '' : 'limit')
    ..aOB(3, _omitFieldNames ? '' : 'includeRawBytes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DumpEncryptedBlobsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DumpEncryptedBlobsRequest copyWith(
          void Function(DumpEncryptedBlobsRequest) updates) =>
      super.copyWith((message) => updates(message as DumpEncryptedBlobsRequest))
          as DumpEncryptedBlobsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DumpEncryptedBlobsRequest create() => DumpEncryptedBlobsRequest._();
  @$core.override
  DumpEncryptedBlobsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DumpEncryptedBlobsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DumpEncryptedBlobsRequest>(create);
  static DumpEncryptedBlobsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get blobType => $_getSZ(0);
  @$pb.TagNumber(1)
  set blobType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlobType() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlobType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get includeRawBytes => $_getBF(2);
  @$pb.TagNumber(3)
  set includeRawBytes($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIncludeRawBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearIncludeRawBytes() => $_clearField(3);
}

class EncryptedBlobInfo extends $pb.GeneratedMessage {
  factory EncryptedBlobInfo({
    $core.String? id,
    $core.String? ownerId,
    $core.String? blobType,
    $core.int? sizeBytes,
    $core.List<$core.int>? rawBytes,
    $core.String? encryptionAlgorithm,
    $2.Timestamp? createdAt,
    $2.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (ownerId != null) result.ownerId = ownerId;
    if (blobType != null) result.blobType = blobType;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (rawBytes != null) result.rawBytes = rawBytes;
    if (encryptionAlgorithm != null)
      result.encryptionAlgorithm = encryptionAlgorithm;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  EncryptedBlobInfo._();

  factory EncryptedBlobInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EncryptedBlobInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EncryptedBlobInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'ownerId')
    ..aOS(3, _omitFieldNames ? '' : 'blobType')
    ..aI(4, _omitFieldNames ? '' : 'sizeBytes')
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'rawBytes', $pb.PbFieldType.OY)
    ..aOS(6, _omitFieldNames ? '' : 'encryptionAlgorithm')
    ..aOM<$2.Timestamp>(7, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(8, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptedBlobInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptedBlobInfo copyWith(void Function(EncryptedBlobInfo) updates) =>
      super.copyWith((message) => updates(message as EncryptedBlobInfo))
          as EncryptedBlobInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncryptedBlobInfo create() => EncryptedBlobInfo._();
  @$core.override
  EncryptedBlobInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EncryptedBlobInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EncryptedBlobInfo>(create);
  static EncryptedBlobInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get ownerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set ownerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOwnerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOwnerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get blobType => $_getSZ(2);
  @$pb.TagNumber(3)
  set blobType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBlobType() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlobType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get sizeBytes => $_getIZ(3);
  @$pb.TagNumber(4)
  set sizeBytes($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSizeBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearSizeBytes() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get rawBytes => $_getN(4);
  @$pb.TagNumber(5)
  set rawBytes($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRawBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearRawBytes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get encryptionAlgorithm => $_getSZ(5);
  @$pb.TagNumber(6)
  set encryptionAlgorithm($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEncryptionAlgorithm() => $_has(5);
  @$pb.TagNumber(6)
  void clearEncryptionAlgorithm() => $_clearField(6);

  @$pb.TagNumber(7)
  $2.Timestamp get createdAt => $_getN(6);
  @$pb.TagNumber(7)
  set createdAt($2.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $2.Timestamp ensureCreatedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $2.Timestamp get updatedAt => $_getN(7);
  @$pb.TagNumber(8)
  set updatedAt($2.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasUpdatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearUpdatedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $2.Timestamp ensureUpdatedAt() => $_ensure(7);
}

class DumpEncryptedBlobsResponse extends $pb.GeneratedMessage {
  factory DumpEncryptedBlobsResponse({
    $core.Iterable<EncryptedBlobInfo>? blobs,
    $core.int? totalCount,
    $core.String? warning,
  }) {
    final result = create();
    if (blobs != null) result.blobs.addAll(blobs);
    if (totalCount != null) result.totalCount = totalCount;
    if (warning != null) result.warning = warning;
    return result;
  }

  DumpEncryptedBlobsResponse._();

  factory DumpEncryptedBlobsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DumpEncryptedBlobsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DumpEncryptedBlobsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<EncryptedBlobInfo>(1, _omitFieldNames ? '' : 'blobs',
        subBuilder: EncryptedBlobInfo.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..aOS(3, _omitFieldNames ? '' : 'warning')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DumpEncryptedBlobsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DumpEncryptedBlobsResponse copyWith(
          void Function(DumpEncryptedBlobsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DumpEncryptedBlobsResponse))
          as DumpEncryptedBlobsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DumpEncryptedBlobsResponse create() => DumpEncryptedBlobsResponse._();
  @$core.override
  DumpEncryptedBlobsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DumpEncryptedBlobsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DumpEncryptedBlobsResponse>(create);
  static DumpEncryptedBlobsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<EncryptedBlobInfo> get blobs => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get warning => $_getSZ(2);
  @$pb.TagNumber(3)
  set warning($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWarning() => $_has(2);
  @$pb.TagNumber(3)
  void clearWarning() => $_clearField(3);
}

class GetBlindIndicesRequest extends $pb.GeneratedMessage {
  factory GetBlindIndicesRequest({
    $core.String? filterType,
  }) {
    final result = create();
    if (filterType != null) result.filterType = filterType;
    return result;
  }

  GetBlindIndicesRequest._();

  factory GetBlindIndicesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBlindIndicesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBlindIndicesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filterType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlindIndicesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlindIndicesRequest copyWith(
          void Function(GetBlindIndicesRequest) updates) =>
      super.copyWith((message) => updates(message as GetBlindIndicesRequest))
          as GetBlindIndicesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlindIndicesRequest create() => GetBlindIndicesRequest._();
  @$core.override
  GetBlindIndicesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBlindIndicesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlindIndicesRequest>(create);
  static GetBlindIndicesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filterType => $_getSZ(0);
  @$pb.TagNumber(1)
  set filterType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFilterType() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilterType() => $_clearField(1);
}

class BlindIndexInfo extends $pb.GeneratedMessage {
  factory BlindIndexInfo({
    $core.String? indexHash,
    $core.String? ownerType,
    $core.String? ownerId,
    $core.int? referenceCount,
    $2.Timestamp? firstSeen,
    $2.Timestamp? lastUsed,
  }) {
    final result = create();
    if (indexHash != null) result.indexHash = indexHash;
    if (ownerType != null) result.ownerType = ownerType;
    if (ownerId != null) result.ownerId = ownerId;
    if (referenceCount != null) result.referenceCount = referenceCount;
    if (firstSeen != null) result.firstSeen = firstSeen;
    if (lastUsed != null) result.lastUsed = lastUsed;
    return result;
  }

  BlindIndexInfo._();

  factory BlindIndexInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlindIndexInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlindIndexInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'indexHash')
    ..aOS(2, _omitFieldNames ? '' : 'ownerType')
    ..aOS(3, _omitFieldNames ? '' : 'ownerId')
    ..aI(4, _omitFieldNames ? '' : 'referenceCount')
    ..aOM<$2.Timestamp>(5, _omitFieldNames ? '' : 'firstSeen',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'lastUsed',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlindIndexInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlindIndexInfo copyWith(void Function(BlindIndexInfo) updates) =>
      super.copyWith((message) => updates(message as BlindIndexInfo))
          as BlindIndexInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlindIndexInfo create() => BlindIndexInfo._();
  @$core.override
  BlindIndexInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlindIndexInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlindIndexInfo>(create);
  static BlindIndexInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get indexHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set indexHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIndexHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndexHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get ownerType => $_getSZ(1);
  @$pb.TagNumber(2)
  set ownerType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOwnerType() => $_has(1);
  @$pb.TagNumber(2)
  void clearOwnerType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get ownerId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ownerId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOwnerId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOwnerId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get referenceCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set referenceCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReferenceCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearReferenceCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $2.Timestamp get firstSeen => $_getN(4);
  @$pb.TagNumber(5)
  set firstSeen($2.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasFirstSeen() => $_has(4);
  @$pb.TagNumber(5)
  void clearFirstSeen() => $_clearField(5);
  @$pb.TagNumber(5)
  $2.Timestamp ensureFirstSeen() => $_ensure(4);

  @$pb.TagNumber(6)
  $2.Timestamp get lastUsed => $_getN(5);
  @$pb.TagNumber(6)
  set lastUsed($2.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasLastUsed() => $_has(5);
  @$pb.TagNumber(6)
  void clearLastUsed() => $_clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureLastUsed() => $_ensure(5);
}

class GetBlindIndicesResponse extends $pb.GeneratedMessage {
  factory GetBlindIndicesResponse({
    $core.Iterable<BlindIndexInfo>? indices,
    $core.int? totalCount,
    $core.String? warning,
  }) {
    final result = create();
    if (indices != null) result.indices.addAll(indices);
    if (totalCount != null) result.totalCount = totalCount;
    if (warning != null) result.warning = warning;
    return result;
  }

  GetBlindIndicesResponse._();

  factory GetBlindIndicesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBlindIndicesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBlindIndicesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.hub'),
      createEmptyInstance: create)
    ..pPM<BlindIndexInfo>(1, _omitFieldNames ? '' : 'indices',
        subBuilder: BlindIndexInfo.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..aOS(3, _omitFieldNames ? '' : 'warning')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlindIndicesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlindIndicesResponse copyWith(
          void Function(GetBlindIndicesResponse) updates) =>
      super.copyWith((message) => updates(message as GetBlindIndicesResponse))
          as GetBlindIndicesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlindIndicesResponse create() => GetBlindIndicesResponse._();
  @$core.override
  GetBlindIndicesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBlindIndicesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlindIndicesResponse>(create);
  static GetBlindIndicesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<BlindIndexInfo> get indices => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get warning => $_getSZ(2);
  @$pb.TagNumber(3)
  set warning($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWarning() => $_has(2);
  @$pb.TagNumber(3)
  void clearWarning() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
