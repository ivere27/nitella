// This is a generated file - do not edit.
//
// Generated from geoip/geoip.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'geoip.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'geoip.pbenum.dart';

class LookupRequest extends $pb.GeneratedMessage {
  factory LookupRequest({
    $core.String? ip,
  }) {
    final result = create();
    if (ip != null) result.ip = ip;
    return result;
  }

  LookupRequest._();

  factory LookupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LookupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LookupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ip')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LookupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LookupRequest copyWith(void Function(LookupRequest) updates) =>
      super.copyWith((message) => updates(message as LookupRequest))
          as LookupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LookupRequest create() => LookupRequest._();
  @$core.override
  LookupRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LookupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LookupRequest>(create);
  static LookupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ip => $_getSZ(0);
  @$pb.TagNumber(1)
  set ip($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIp() => $_has(0);
  @$pb.TagNumber(1)
  void clearIp() => $_clearField(1);
}

class ServiceStatus extends $pb.GeneratedMessage {
  factory ServiceStatus({
    $core.bool? ready,
    $fixnum.Int64? l1CacheSize,
    $fixnum.Int64? l2CacheSize,
    $core.Iterable<$core.String>? activeProviders,
    $core.String? strategy,
    $core.bool? localDbLoaded,
    $core.int? l2TtlHours,
  }) {
    final result = create();
    if (ready != null) result.ready = ready;
    if (l1CacheSize != null) result.l1CacheSize = l1CacheSize;
    if (l2CacheSize != null) result.l2CacheSize = l2CacheSize;
    if (activeProviders != null) result.activeProviders.addAll(activeProviders);
    if (strategy != null) result.strategy = strategy;
    if (localDbLoaded != null) result.localDbLoaded = localDbLoaded;
    if (l2TtlHours != null) result.l2TtlHours = l2TtlHours;
    return result;
  }

  ServiceStatus._();

  factory ServiceStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ServiceStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServiceStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'ready')
    ..aInt64(2, _omitFieldNames ? '' : 'l1CacheSize')
    ..aInt64(3, _omitFieldNames ? '' : 'l2CacheSize')
    ..pPS(4, _omitFieldNames ? '' : 'activeProviders')
    ..aOS(5, _omitFieldNames ? '' : 'strategy')
    ..aOB(6, _omitFieldNames ? '' : 'localDbLoaded')
    ..aI(7, _omitFieldNames ? '' : 'l2TtlHours')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServiceStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServiceStatus copyWith(void Function(ServiceStatus) updates) =>
      super.copyWith((message) => updates(message as ServiceStatus))
          as ServiceStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServiceStatus create() => ServiceStatus._();
  @$core.override
  ServiceStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ServiceStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServiceStatus>(create);
  static ServiceStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get ready => $_getBF(0);
  @$pb.TagNumber(1)
  set ready($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReady() => $_has(0);
  @$pb.TagNumber(1)
  void clearReady() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get l1CacheSize => $_getI64(1);
  @$pb.TagNumber(2)
  set l1CacheSize($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasL1CacheSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearL1CacheSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get l2CacheSize => $_getI64(2);
  @$pb.TagNumber(3)
  set l2CacheSize($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasL2CacheSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearL2CacheSize() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get activeProviders => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get strategy => $_getSZ(4);
  @$pb.TagNumber(5)
  set strategy($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStrategy() => $_has(4);
  @$pb.TagNumber(5)
  void clearStrategy() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get localDbLoaded => $_getBF(5);
  @$pb.TagNumber(6)
  set localDbLoaded($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLocalDbLoaded() => $_has(5);
  @$pb.TagNumber(6)
  void clearLocalDbLoaded() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get l2TtlHours => $_getIZ(6);
  @$pb.TagNumber(7)
  set l2TtlHours($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasL2TtlHours() => $_has(6);
  @$pb.TagNumber(7)
  void clearL2TtlHours() => $_clearField(7);
}

class LoadLocalDBRequest extends $pb.GeneratedMessage {
  factory LoadLocalDBRequest({
    $core.String? cityDbPath,
    $core.String? ispDbPath,
  }) {
    final result = create();
    if (cityDbPath != null) result.cityDbPath = cityDbPath;
    if (ispDbPath != null) result.ispDbPath = ispDbPath;
    return result;
  }

  LoadLocalDBRequest._();

  factory LoadLocalDBRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LoadLocalDBRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoadLocalDBRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cityDbPath')
    ..aOS(2, _omitFieldNames ? '' : 'ispDbPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadLocalDBRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadLocalDBRequest copyWith(void Function(LoadLocalDBRequest) updates) =>
      super.copyWith((message) => updates(message as LoadLocalDBRequest))
          as LoadLocalDBRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoadLocalDBRequest create() => LoadLocalDBRequest._();
  @$core.override
  LoadLocalDBRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LoadLocalDBRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoadLocalDBRequest>(create);
  static LoadLocalDBRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cityDbPath => $_getSZ(0);
  @$pb.TagNumber(1)
  set cityDbPath($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCityDbPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearCityDbPath() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get ispDbPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set ispDbPath($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIspDbPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearIspDbPath() => $_clearField(2);
}

class LocalDBStatus extends $pb.GeneratedMessage {
  factory LocalDBStatus({
    $core.bool? loaded,
    $core.String? cityDbPath,
    $core.String? ispDbPath,
    $fixnum.Int64? cityDbSize,
    $fixnum.Int64? ispDbSize,
  }) {
    final result = create();
    if (loaded != null) result.loaded = loaded;
    if (cityDbPath != null) result.cityDbPath = cityDbPath;
    if (ispDbPath != null) result.ispDbPath = ispDbPath;
    if (cityDbSize != null) result.cityDbSize = cityDbSize;
    if (ispDbSize != null) result.ispDbSize = ispDbSize;
    return result;
  }

  LocalDBStatus._();

  factory LocalDBStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LocalDBStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LocalDBStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'loaded')
    ..aOS(2, _omitFieldNames ? '' : 'cityDbPath')
    ..aOS(3, _omitFieldNames ? '' : 'ispDbPath')
    ..aInt64(4, _omitFieldNames ? '' : 'cityDbSize')
    ..aInt64(5, _omitFieldNames ? '' : 'ispDbSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocalDBStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocalDBStatus copyWith(void Function(LocalDBStatus) updates) =>
      super.copyWith((message) => updates(message as LocalDBStatus))
          as LocalDBStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LocalDBStatus create() => LocalDBStatus._();
  @$core.override
  LocalDBStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LocalDBStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LocalDBStatus>(create);
  static LocalDBStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get loaded => $_getBF(0);
  @$pb.TagNumber(1)
  set loaded($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLoaded() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoaded() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cityDbPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set cityDbPath($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCityDbPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearCityDbPath() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get ispDbPath => $_getSZ(2);
  @$pb.TagNumber(3)
  set ispDbPath($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIspDbPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearIspDbPath() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get cityDbSize => $_getI64(3);
  @$pb.TagNumber(4)
  set cityDbSize($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCityDbSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearCityDbSize() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get ispDbSize => $_getI64(4);
  @$pb.TagNumber(5)
  set ispDbSize($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIspDbSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearIspDbSize() => $_clearField(5);
}

class ProviderNameRequest extends $pb.GeneratedMessage {
  factory ProviderNameRequest({
    $core.String? name,
  }) {
    final result = create();
    if (name != null) result.name = name;
    return result;
  }

  ProviderNameRequest._();

  factory ProviderNameRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProviderNameRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProviderNameRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProviderNameRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProviderNameRequest copyWith(void Function(ProviderNameRequest) updates) =>
      super.copyWith((message) => updates(message as ProviderNameRequest))
          as ProviderNameRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProviderNameRequest create() => ProviderNameRequest._();
  @$core.override
  ProviderNameRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProviderNameRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProviderNameRequest>(create);
  static ProviderNameRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);
}

class ListProvidersResponse extends $pb.GeneratedMessage {
  factory ListProvidersResponse({
    $core.Iterable<ProviderInfo>? providers,
  }) {
    final result = create();
    if (providers != null) result.providers.addAll(providers);
    return result;
  }

  ListProvidersResponse._();

  factory ListProvidersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListProvidersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProvidersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..pPM<ProviderInfo>(1, _omitFieldNames ? '' : 'providers',
        subBuilder: ProviderInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProvidersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProvidersResponse copyWith(
          void Function(ListProvidersResponse) updates) =>
      super.copyWith((message) => updates(message as ListProvidersResponse))
          as ListProvidersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProvidersResponse create() => ListProvidersResponse._();
  @$core.override
  ListProvidersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListProvidersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListProvidersResponse>(create);
  static ListProvidersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ProviderInfo> get providers => $_getList(0);
}

class ProviderInfo extends $pb.GeneratedMessage {
  factory ProviderInfo({
    $core.String? name,
    $core.String? url,
    $core.bool? enabled,
    $core.int? priority,
    FieldMapping? fieldMapping,
    ProviderStats? stats,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (url != null) result.url = url;
    if (enabled != null) result.enabled = enabled;
    if (priority != null) result.priority = priority;
    if (fieldMapping != null) result.fieldMapping = fieldMapping;
    if (stats != null) result.stats = stats;
    return result;
  }

  ProviderInfo._();

  factory ProviderInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProviderInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProviderInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..aOB(3, _omitFieldNames ? '' : 'enabled')
    ..aI(4, _omitFieldNames ? '' : 'priority')
    ..aOM<FieldMapping>(5, _omitFieldNames ? '' : 'fieldMapping',
        subBuilder: FieldMapping.create)
    ..aOM<ProviderStats>(6, _omitFieldNames ? '' : 'stats',
        subBuilder: ProviderStats.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProviderInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProviderInfo copyWith(void Function(ProviderInfo) updates) =>
      super.copyWith((message) => updates(message as ProviderInfo))
          as ProviderInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProviderInfo create() => ProviderInfo._();
  @$core.override
  ProviderInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProviderInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProviderInfo>(create);
  static ProviderInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get enabled => $_getBF(2);
  @$pb.TagNumber(3)
  set enabled($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEnabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnabled() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get priority => $_getIZ(3);
  @$pb.TagNumber(4)
  set priority($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPriority() => $_has(3);
  @$pb.TagNumber(4)
  void clearPriority() => $_clearField(4);

  @$pb.TagNumber(5)
  FieldMapping get fieldMapping => $_getN(4);
  @$pb.TagNumber(5)
  set fieldMapping(FieldMapping value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasFieldMapping() => $_has(4);
  @$pb.TagNumber(5)
  void clearFieldMapping() => $_clearField(5);
  @$pb.TagNumber(5)
  FieldMapping ensureFieldMapping() => $_ensure(4);

  @$pb.TagNumber(6)
  ProviderStats get stats => $_getN(5);
  @$pb.TagNumber(6)
  set stats(ProviderStats value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStats() => $_has(5);
  @$pb.TagNumber(6)
  void clearStats() => $_clearField(6);
  @$pb.TagNumber(6)
  ProviderStats ensureStats() => $_ensure(5);
}

class AddProviderRequest extends $pb.GeneratedMessage {
  factory AddProviderRequest({
    $core.String? name,
    $core.String? url,
    $core.int? priority,
    FieldMapping? fieldMapping,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (url != null) result.url = url;
    if (priority != null) result.priority = priority;
    if (fieldMapping != null) result.fieldMapping = fieldMapping;
    return result;
  }

  AddProviderRequest._();

  factory AddProviderRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddProviderRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddProviderRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..aI(3, _omitFieldNames ? '' : 'priority')
    ..aOM<FieldMapping>(4, _omitFieldNames ? '' : 'fieldMapping',
        subBuilder: FieldMapping.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddProviderRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddProviderRequest copyWith(void Function(AddProviderRequest) updates) =>
      super.copyWith((message) => updates(message as AddProviderRequest))
          as AddProviderRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddProviderRequest create() => AddProviderRequest._();
  @$core.override
  AddProviderRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddProviderRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddProviderRequest>(create);
  static AddProviderRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get priority => $_getIZ(2);
  @$pb.TagNumber(3)
  set priority($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPriority() => $_has(2);
  @$pb.TagNumber(3)
  void clearPriority() => $_clearField(3);

  @$pb.TagNumber(4)
  FieldMapping get fieldMapping => $_getN(3);
  @$pb.TagNumber(4)
  set fieldMapping(FieldMapping value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldMapping() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldMapping() => $_clearField(4);
  @$pb.TagNumber(4)
  FieldMapping ensureFieldMapping() => $_ensure(3);
}

class RemoveProviderRequest extends $pb.GeneratedMessage {
  factory RemoveProviderRequest({
    $core.String? name,
  }) {
    final result = create();
    if (name != null) result.name = name;
    return result;
  }

  RemoveProviderRequest._();

  factory RemoveProviderRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveProviderRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveProviderRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveProviderRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveProviderRequest copyWith(
          void Function(RemoveProviderRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveProviderRequest))
          as RemoveProviderRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveProviderRequest create() => RemoveProviderRequest._();
  @$core.override
  RemoveProviderRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveProviderRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveProviderRequest>(create);
  static RemoveProviderRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);
}

class UpdateProviderRequest extends $pb.GeneratedMessage {
  factory UpdateProviderRequest({
    $core.String? name,
    $core.String? url,
    $core.int? priority,
    FieldMapping? fieldMapping,
    $core.bool? enabled,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (url != null) result.url = url;
    if (priority != null) result.priority = priority;
    if (fieldMapping != null) result.fieldMapping = fieldMapping;
    if (enabled != null) result.enabled = enabled;
    return result;
  }

  UpdateProviderRequest._();

  factory UpdateProviderRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateProviderRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateProviderRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..aI(3, _omitFieldNames ? '' : 'priority')
    ..aOM<FieldMapping>(4, _omitFieldNames ? '' : 'fieldMapping',
        subBuilder: FieldMapping.create)
    ..aOB(5, _omitFieldNames ? '' : 'enabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProviderRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProviderRequest copyWith(
          void Function(UpdateProviderRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateProviderRequest))
          as UpdateProviderRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateProviderRequest create() => UpdateProviderRequest._();
  @$core.override
  UpdateProviderRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateProviderRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateProviderRequest>(create);
  static UpdateProviderRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get priority => $_getIZ(2);
  @$pb.TagNumber(3)
  set priority($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPriority() => $_has(2);
  @$pb.TagNumber(3)
  void clearPriority() => $_clearField(3);

  @$pb.TagNumber(4)
  FieldMapping get fieldMapping => $_getN(3);
  @$pb.TagNumber(4)
  set fieldMapping(FieldMapping value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldMapping() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldMapping() => $_clearField(4);
  @$pb.TagNumber(4)
  FieldMapping ensureFieldMapping() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.bool get enabled => $_getBF(4);
  @$pb.TagNumber(5)
  set enabled($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEnabled() => $_has(4);
  @$pb.TagNumber(5)
  void clearEnabled() => $_clearField(5);
}

class ReorderProvidersRequest extends $pb.GeneratedMessage {
  factory ReorderProvidersRequest({
    $core.Iterable<$core.String>? providerNames,
  }) {
    final result = create();
    if (providerNames != null) result.providerNames.addAll(providerNames);
    return result;
  }

  ReorderProvidersRequest._();

  factory ReorderProvidersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReorderProvidersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReorderProvidersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'providerNames')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReorderProvidersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReorderProvidersRequest copyWith(
          void Function(ReorderProvidersRequest) updates) =>
      super.copyWith((message) => updates(message as ReorderProvidersRequest))
          as ReorderProvidersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReorderProvidersRequest create() => ReorderProvidersRequest._();
  @$core.override
  ReorderProvidersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReorderProvidersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReorderProvidersRequest>(create);
  static ReorderProvidersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get providerNames => $_getList(0);
}

class ProviderStats extends $pb.GeneratedMessage {
  factory ProviderStats({
    $core.String? name,
    $fixnum.Int64? lookupCount,
    $fixnum.Int64? successCount,
    $fixnum.Int64? errorCount,
    $fixnum.Int64? totalLatencyMs,
    $fixnum.Int64? avgLatencyMs,
    $fixnum.Int64? lastUsedUnix,
    $core.String? lastError,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (lookupCount != null) result.lookupCount = lookupCount;
    if (successCount != null) result.successCount = successCount;
    if (errorCount != null) result.errorCount = errorCount;
    if (totalLatencyMs != null) result.totalLatencyMs = totalLatencyMs;
    if (avgLatencyMs != null) result.avgLatencyMs = avgLatencyMs;
    if (lastUsedUnix != null) result.lastUsedUnix = lastUsedUnix;
    if (lastError != null) result.lastError = lastError;
    return result;
  }

  ProviderStats._();

  factory ProviderStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProviderStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProviderStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aInt64(2, _omitFieldNames ? '' : 'lookupCount')
    ..aInt64(3, _omitFieldNames ? '' : 'successCount')
    ..aInt64(4, _omitFieldNames ? '' : 'errorCount')
    ..aInt64(5, _omitFieldNames ? '' : 'totalLatencyMs')
    ..aInt64(6, _omitFieldNames ? '' : 'avgLatencyMs')
    ..aInt64(7, _omitFieldNames ? '' : 'lastUsedUnix')
    ..aOS(8, _omitFieldNames ? '' : 'lastError')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProviderStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProviderStats copyWith(void Function(ProviderStats) updates) =>
      super.copyWith((message) => updates(message as ProviderStats))
          as ProviderStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProviderStats create() => ProviderStats._();
  @$core.override
  ProviderStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProviderStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProviderStats>(create);
  static ProviderStats? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get lookupCount => $_getI64(1);
  @$pb.TagNumber(2)
  set lookupCount($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLookupCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearLookupCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get successCount => $_getI64(2);
  @$pb.TagNumber(3)
  set successCount($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSuccessCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearSuccessCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get errorCount => $_getI64(3);
  @$pb.TagNumber(4)
  set errorCount($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasErrorCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearErrorCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get totalLatencyMs => $_getI64(4);
  @$pb.TagNumber(5)
  set totalLatencyMs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalLatencyMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalLatencyMs() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get avgLatencyMs => $_getI64(5);
  @$pb.TagNumber(6)
  set avgLatencyMs($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAvgLatencyMs() => $_has(5);
  @$pb.TagNumber(6)
  void clearAvgLatencyMs() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get lastUsedUnix => $_getI64(6);
  @$pb.TagNumber(7)
  set lastUsedUnix($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLastUsedUnix() => $_has(6);
  @$pb.TagNumber(7)
  void clearLastUsedUnix() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get lastError => $_getSZ(7);
  @$pb.TagNumber(8)
  set lastError($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLastError() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastError() => $_clearField(8);
}

class FieldMapping extends $pb.GeneratedMessage {
  factory FieldMapping({
    $core.Iterable<$core.String>? country,
    $core.Iterable<$core.String>? countryCode,
    $core.Iterable<$core.String>? region,
    $core.Iterable<$core.String>? regionName,
    $core.Iterable<$core.String>? city,
    $core.Iterable<$core.String>? zip,
    $core.Iterable<$core.String>? timezone,
    $core.Iterable<$core.String>? latitude,
    $core.Iterable<$core.String>? longitude,
    $core.Iterable<$core.String>? isp,
    $core.Iterable<$core.String>? org,
    $core.Iterable<$core.String>? as,
  }) {
    final result = create();
    if (country != null) result.country.addAll(country);
    if (countryCode != null) result.countryCode.addAll(countryCode);
    if (region != null) result.region.addAll(region);
    if (regionName != null) result.regionName.addAll(regionName);
    if (city != null) result.city.addAll(city);
    if (zip != null) result.zip.addAll(zip);
    if (timezone != null) result.timezone.addAll(timezone);
    if (latitude != null) result.latitude.addAll(latitude);
    if (longitude != null) result.longitude.addAll(longitude);
    if (isp != null) result.isp.addAll(isp);
    if (org != null) result.org.addAll(org);
    if (as != null) result.as.addAll(as);
    return result;
  }

  FieldMapping._();

  factory FieldMapping.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FieldMapping.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldMapping',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'country')
    ..pPS(2, _omitFieldNames ? '' : 'countryCode')
    ..pPS(3, _omitFieldNames ? '' : 'region')
    ..pPS(4, _omitFieldNames ? '' : 'regionName')
    ..pPS(5, _omitFieldNames ? '' : 'city')
    ..pPS(6, _omitFieldNames ? '' : 'zip')
    ..pPS(7, _omitFieldNames ? '' : 'timezone')
    ..pPS(8, _omitFieldNames ? '' : 'latitude')
    ..pPS(9, _omitFieldNames ? '' : 'longitude')
    ..pPS(10, _omitFieldNames ? '' : 'isp')
    ..pPS(11, _omitFieldNames ? '' : 'org')
    ..pPS(12, _omitFieldNames ? '' : 'as')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldMapping clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldMapping copyWith(void Function(FieldMapping) updates) =>
      super.copyWith((message) => updates(message as FieldMapping))
          as FieldMapping;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FieldMapping create() => FieldMapping._();
  @$core.override
  FieldMapping createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FieldMapping getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldMapping>(create);
  static FieldMapping? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get country => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get countryCode => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get region => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get regionName => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get city => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get zip => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get timezone => $_getList(6);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get latitude => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get longitude => $_getList(8);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get isp => $_getList(9);

  @$pb.TagNumber(11)
  $pb.PbList<$core.String> get org => $_getList(10);

  @$pb.TagNumber(12)
  $pb.PbList<$core.String> get as => $_getList(11);
}

class CacheStats extends $pb.GeneratedMessage {
  factory CacheStats({
    $fixnum.Int64? l1Size,
    $fixnum.Int64? l1Capacity,
    $fixnum.Int64? l1Hits,
    $fixnum.Int64? l1Misses,
    $fixnum.Int64? l2Size,
    $core.bool? l2Enabled,
    $core.String? l2Path,
    $fixnum.Int64? l2Hits,
    $fixnum.Int64? l2Misses,
    $core.int? l2TtlHours,
  }) {
    final result = create();
    if (l1Size != null) result.l1Size = l1Size;
    if (l1Capacity != null) result.l1Capacity = l1Capacity;
    if (l1Hits != null) result.l1Hits = l1Hits;
    if (l1Misses != null) result.l1Misses = l1Misses;
    if (l2Size != null) result.l2Size = l2Size;
    if (l2Enabled != null) result.l2Enabled = l2Enabled;
    if (l2Path != null) result.l2Path = l2Path;
    if (l2Hits != null) result.l2Hits = l2Hits;
    if (l2Misses != null) result.l2Misses = l2Misses;
    if (l2TtlHours != null) result.l2TtlHours = l2TtlHours;
    return result;
  }

  CacheStats._();

  factory CacheStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CacheStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CacheStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'l1Size')
    ..aInt64(2, _omitFieldNames ? '' : 'l1Capacity')
    ..aInt64(3, _omitFieldNames ? '' : 'l1Hits')
    ..aInt64(4, _omitFieldNames ? '' : 'l1Misses')
    ..aInt64(5, _omitFieldNames ? '' : 'l2Size')
    ..aOB(6, _omitFieldNames ? '' : 'l2Enabled')
    ..aOS(7, _omitFieldNames ? '' : 'l2Path')
    ..aInt64(8, _omitFieldNames ? '' : 'l2Hits')
    ..aInt64(9, _omitFieldNames ? '' : 'l2Misses')
    ..aI(10, _omitFieldNames ? '' : 'l2TtlHours')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CacheStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CacheStats copyWith(void Function(CacheStats) updates) =>
      super.copyWith((message) => updates(message as CacheStats)) as CacheStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CacheStats create() => CacheStats._();
  @$core.override
  CacheStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CacheStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CacheStats>(create);
  static CacheStats? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get l1Size => $_getI64(0);
  @$pb.TagNumber(1)
  set l1Size($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasL1Size() => $_has(0);
  @$pb.TagNumber(1)
  void clearL1Size() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get l1Capacity => $_getI64(1);
  @$pb.TagNumber(2)
  set l1Capacity($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasL1Capacity() => $_has(1);
  @$pb.TagNumber(2)
  void clearL1Capacity() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get l1Hits => $_getI64(2);
  @$pb.TagNumber(3)
  set l1Hits($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasL1Hits() => $_has(2);
  @$pb.TagNumber(3)
  void clearL1Hits() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get l1Misses => $_getI64(3);
  @$pb.TagNumber(4)
  set l1Misses($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasL1Misses() => $_has(3);
  @$pb.TagNumber(4)
  void clearL1Misses() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get l2Size => $_getI64(4);
  @$pb.TagNumber(5)
  set l2Size($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasL2Size() => $_has(4);
  @$pb.TagNumber(5)
  void clearL2Size() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get l2Enabled => $_getBF(5);
  @$pb.TagNumber(6)
  set l2Enabled($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasL2Enabled() => $_has(5);
  @$pb.TagNumber(6)
  void clearL2Enabled() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get l2Path => $_getSZ(6);
  @$pb.TagNumber(7)
  set l2Path($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasL2Path() => $_has(6);
  @$pb.TagNumber(7)
  void clearL2Path() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get l2Hits => $_getI64(7);
  @$pb.TagNumber(8)
  set l2Hits($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasL2Hits() => $_has(7);
  @$pb.TagNumber(8)
  void clearL2Hits() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get l2Misses => $_getI64(8);
  @$pb.TagNumber(9)
  set l2Misses($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasL2Misses() => $_has(8);
  @$pb.TagNumber(9)
  void clearL2Misses() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get l2TtlHours => $_getIZ(9);
  @$pb.TagNumber(10)
  set l2TtlHours($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasL2TtlHours() => $_has(9);
  @$pb.TagNumber(10)
  void clearL2TtlHours() => $_clearField(10);
}

class ClearCacheRequest extends $pb.GeneratedMessage {
  factory ClearCacheRequest({
    CacheLayer? layer,
  }) {
    final result = create();
    if (layer != null) result.layer = layer;
    return result;
  }

  ClearCacheRequest._();

  factory ClearCacheRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClearCacheRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClearCacheRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..aE<CacheLayer>(1, _omitFieldNames ? '' : 'layer',
        enumValues: CacheLayer.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearCacheRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearCacheRequest copyWith(void Function(ClearCacheRequest) updates) =>
      super.copyWith((message) => updates(message as ClearCacheRequest))
          as ClearCacheRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClearCacheRequest create() => ClearCacheRequest._();
  @$core.override
  ClearCacheRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClearCacheRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClearCacheRequest>(create);
  static ClearCacheRequest? _defaultInstance;

  @$pb.TagNumber(1)
  CacheLayer get layer => $_getN(0);
  @$pb.TagNumber(1)
  set layer(CacheLayer value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasLayer() => $_has(0);
  @$pb.TagNumber(1)
  void clearLayer() => $_clearField(1);
}

class CacheSettings extends $pb.GeneratedMessage {
  factory CacheSettings({
    $core.int? l1Capacity,
    $core.int? l1TtlHours,
    $core.bool? l2Enabled,
    $core.String? l2Path,
    $core.int? l2TtlHours,
  }) {
    final result = create();
    if (l1Capacity != null) result.l1Capacity = l1Capacity;
    if (l1TtlHours != null) result.l1TtlHours = l1TtlHours;
    if (l2Enabled != null) result.l2Enabled = l2Enabled;
    if (l2Path != null) result.l2Path = l2Path;
    if (l2TtlHours != null) result.l2TtlHours = l2TtlHours;
    return result;
  }

  CacheSettings._();

  factory CacheSettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CacheSettings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CacheSettings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'l1Capacity')
    ..aI(2, _omitFieldNames ? '' : 'l1TtlHours')
    ..aOB(3, _omitFieldNames ? '' : 'l2Enabled')
    ..aOS(4, _omitFieldNames ? '' : 'l2Path')
    ..aI(5, _omitFieldNames ? '' : 'l2TtlHours')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CacheSettings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CacheSettings copyWith(void Function(CacheSettings) updates) =>
      super.copyWith((message) => updates(message as CacheSettings))
          as CacheSettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CacheSettings create() => CacheSettings._();
  @$core.override
  CacheSettings createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CacheSettings getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CacheSettings>(create);
  static CacheSettings? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get l1Capacity => $_getIZ(0);
  @$pb.TagNumber(1)
  set l1Capacity($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasL1Capacity() => $_has(0);
  @$pb.TagNumber(1)
  void clearL1Capacity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get l1TtlHours => $_getIZ(1);
  @$pb.TagNumber(2)
  set l1TtlHours($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasL1TtlHours() => $_has(1);
  @$pb.TagNumber(2)
  void clearL1TtlHours() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get l2Enabled => $_getBF(2);
  @$pb.TagNumber(3)
  set l2Enabled($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasL2Enabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearL2Enabled() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get l2Path => $_getSZ(3);
  @$pb.TagNumber(4)
  set l2Path($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasL2Path() => $_has(3);
  @$pb.TagNumber(4)
  void clearL2Path() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get l2TtlHours => $_getIZ(4);
  @$pb.TagNumber(5)
  set l2TtlHours($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasL2TtlHours() => $_has(4);
  @$pb.TagNumber(5)
  void clearL2TtlHours() => $_clearField(5);
}

class UpdateCacheSettingsRequest extends $pb.GeneratedMessage {
  factory UpdateCacheSettingsRequest({
    $core.int? l1Capacity,
    $core.int? l1TtlHours,
    $core.bool? l2Enabled,
    $core.String? l2Path,
    $core.int? l2TtlHours,
  }) {
    final result = create();
    if (l1Capacity != null) result.l1Capacity = l1Capacity;
    if (l1TtlHours != null) result.l1TtlHours = l1TtlHours;
    if (l2Enabled != null) result.l2Enabled = l2Enabled;
    if (l2Path != null) result.l2Path = l2Path;
    if (l2TtlHours != null) result.l2TtlHours = l2TtlHours;
    return result;
  }

  UpdateCacheSettingsRequest._();

  factory UpdateCacheSettingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateCacheSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateCacheSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'l1Capacity')
    ..aI(2, _omitFieldNames ? '' : 'l1TtlHours')
    ..aOB(3, _omitFieldNames ? '' : 'l2Enabled')
    ..aOS(4, _omitFieldNames ? '' : 'l2Path')
    ..aI(5, _omitFieldNames ? '' : 'l2TtlHours')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCacheSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCacheSettingsRequest copyWith(
          void Function(UpdateCacheSettingsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateCacheSettingsRequest))
          as UpdateCacheSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateCacheSettingsRequest create() => UpdateCacheSettingsRequest._();
  @$core.override
  UpdateCacheSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateCacheSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateCacheSettingsRequest>(create);
  static UpdateCacheSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get l1Capacity => $_getIZ(0);
  @$pb.TagNumber(1)
  set l1Capacity($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasL1Capacity() => $_has(0);
  @$pb.TagNumber(1)
  void clearL1Capacity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get l1TtlHours => $_getIZ(1);
  @$pb.TagNumber(2)
  set l1TtlHours($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasL1TtlHours() => $_has(1);
  @$pb.TagNumber(2)
  void clearL1TtlHours() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get l2Enabled => $_getBF(2);
  @$pb.TagNumber(3)
  set l2Enabled($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasL2Enabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearL2Enabled() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get l2Path => $_getSZ(3);
  @$pb.TagNumber(4)
  set l2Path($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasL2Path() => $_has(3);
  @$pb.TagNumber(4)
  void clearL2Path() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get l2TtlHours => $_getIZ(4);
  @$pb.TagNumber(5)
  set l2TtlHours($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasL2TtlHours() => $_has(4);
  @$pb.TagNumber(5)
  void clearL2TtlHours() => $_clearField(5);
}

class StrategyResponse extends $pb.GeneratedMessage {
  factory StrategyResponse({
    $core.Iterable<$core.String>? steps,
    $core.int? timeoutMs,
  }) {
    final result = create();
    if (steps != null) result.steps.addAll(steps);
    if (timeoutMs != null) result.timeoutMs = timeoutMs;
    return result;
  }

  StrategyResponse._();

  factory StrategyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StrategyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StrategyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'steps')
    ..aI(2, _omitFieldNames ? '' : 'timeoutMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StrategyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StrategyResponse copyWith(void Function(StrategyResponse) updates) =>
      super.copyWith((message) => updates(message as StrategyResponse))
          as StrategyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StrategyResponse create() => StrategyResponse._();
  @$core.override
  StrategyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StrategyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StrategyResponse>(create);
  static StrategyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get steps => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get timeoutMs => $_getIZ(1);
  @$pb.TagNumber(2)
  set timeoutMs($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimeoutMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimeoutMs() => $_clearField(2);
}

class SetStrategyRequest extends $pb.GeneratedMessage {
  factory SetStrategyRequest({
    $core.Iterable<$core.String>? steps,
    $core.int? timeoutMs,
  }) {
    final result = create();
    if (steps != null) result.steps.addAll(steps);
    if (timeoutMs != null) result.timeoutMs = timeoutMs;
    return result;
  }

  SetStrategyRequest._();

  factory SetStrategyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetStrategyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetStrategyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.geoip'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'steps')
    ..aI(2, _omitFieldNames ? '' : 'timeoutMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetStrategyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetStrategyRequest copyWith(void Function(SetStrategyRequest) updates) =>
      super.copyWith((message) => updates(message as SetStrategyRequest))
          as SetStrategyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetStrategyRequest create() => SetStrategyRequest._();
  @$core.override
  SetStrategyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetStrategyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetStrategyRequest>(create);
  static SetStrategyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get steps => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get timeoutMs => $_getIZ(1);
  @$pb.TagNumber(2)
  set timeoutMs($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimeoutMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimeoutMs() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
