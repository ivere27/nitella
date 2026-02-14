// This is a generated file - do not edit.
//
// Generated from proxy/proxy.proto.

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

import '../common/common.pb.dart' as $1;
import 'proxy.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'proxy.pbenum.dart';

class ConfigureGeoIPRequest extends $pb.GeneratedMessage {
  factory ConfigureGeoIPRequest({
    ConfigureGeoIPRequest_Mode? mode,
    $core.String? cityDbPath,
    $core.String? ispDbPath,
    $core.String? provider,
    $core.String? apiKey,
  }) {
    final result = create();
    if (mode != null) result.mode = mode;
    if (cityDbPath != null) result.cityDbPath = cityDbPath;
    if (ispDbPath != null) result.ispDbPath = ispDbPath;
    if (provider != null) result.provider = provider;
    if (apiKey != null) result.apiKey = apiKey;
    return result;
  }

  ConfigureGeoIPRequest._();

  factory ConfigureGeoIPRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConfigureGeoIPRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConfigureGeoIPRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aE<ConfigureGeoIPRequest_Mode>(1, _omitFieldNames ? '' : 'mode',
        enumValues: ConfigureGeoIPRequest_Mode.values)
    ..aOS(2, _omitFieldNames ? '' : 'cityDbPath')
    ..aOS(3, _omitFieldNames ? '' : 'ispDbPath')
    ..aOS(4, _omitFieldNames ? '' : 'provider')
    ..aOS(5, _omitFieldNames ? '' : 'apiKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigureGeoIPRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigureGeoIPRequest copyWith(
          void Function(ConfigureGeoIPRequest) updates) =>
      super.copyWith((message) => updates(message as ConfigureGeoIPRequest))
          as ConfigureGeoIPRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConfigureGeoIPRequest create() => ConfigureGeoIPRequest._();
  @$core.override
  ConfigureGeoIPRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConfigureGeoIPRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConfigureGeoIPRequest>(create);
  static ConfigureGeoIPRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ConfigureGeoIPRequest_Mode get mode => $_getN(0);
  @$pb.TagNumber(1)
  set mode(ConfigureGeoIPRequest_Mode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);

  /// Local DB Options
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

  /// Remote API Options
  @$pb.TagNumber(4)
  $core.String get provider => $_getSZ(3);
  @$pb.TagNumber(4)
  set provider($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProvider() => $_has(3);
  @$pb.TagNumber(4)
  void clearProvider() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get apiKey => $_getSZ(4);
  @$pb.TagNumber(5)
  set apiKey($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasApiKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearApiKey() => $_clearField(5);
}

class ConfigureGeoIPResponse extends $pb.GeneratedMessage {
  factory ConfigureGeoIPResponse({
    $core.bool? success,
    $core.String? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  ConfigureGeoIPResponse._();

  factory ConfigureGeoIPResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConfigureGeoIPResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConfigureGeoIPResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigureGeoIPResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigureGeoIPResponse copyWith(
          void Function(ConfigureGeoIPResponse) updates) =>
      super.copyWith((message) => updates(message as ConfigureGeoIPResponse))
          as ConfigureGeoIPResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConfigureGeoIPResponse create() => ConfigureGeoIPResponse._();
  @$core.override
  ConfigureGeoIPResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConfigureGeoIPResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConfigureGeoIPResponse>(create);
  static ConfigureGeoIPResponse? _defaultInstance;

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

class LookupIPRequest extends $pb.GeneratedMessage {
  factory LookupIPRequest({
    $core.String? ip,
  }) {
    final result = create();
    if (ip != null) result.ip = ip;
    return result;
  }

  LookupIPRequest._();

  factory LookupIPRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LookupIPRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LookupIPRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ip')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LookupIPRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LookupIPRequest copyWith(void Function(LookupIPRequest) updates) =>
      super.copyWith((message) => updates(message as LookupIPRequest))
          as LookupIPRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LookupIPRequest create() => LookupIPRequest._();
  @$core.override
  LookupIPRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LookupIPRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LookupIPRequest>(create);
  static LookupIPRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ip => $_getSZ(0);
  @$pb.TagNumber(1)
  set ip($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIp() => $_has(0);
  @$pb.TagNumber(1)
  void clearIp() => $_clearField(1);
}

class LookupIPResponse extends $pb.GeneratedMessage {
  factory LookupIPResponse({
    $1.GeoInfo? geo,
    $core.bool? cached,
    $fixnum.Int64? lookupTimeMs,
  }) {
    final result = create();
    if (geo != null) result.geo = geo;
    if (cached != null) result.cached = cached;
    if (lookupTimeMs != null) result.lookupTimeMs = lookupTimeMs;
    return result;
  }

  LookupIPResponse._();

  factory LookupIPResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LookupIPResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LookupIPResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOM<$1.GeoInfo>(1, _omitFieldNames ? '' : 'geo',
        subBuilder: $1.GeoInfo.create)
    ..aOB(2, _omitFieldNames ? '' : 'cached')
    ..aInt64(3, _omitFieldNames ? '' : 'lookupTimeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LookupIPResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LookupIPResponse copyWith(void Function(LookupIPResponse) updates) =>
      super.copyWith((message) => updates(message as LookupIPResponse))
          as LookupIPResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LookupIPResponse create() => LookupIPResponse._();
  @$core.override
  LookupIPResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LookupIPResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LookupIPResponse>(create);
  static LookupIPResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.GeoInfo get geo => $_getN(0);
  @$pb.TagNumber(1)
  set geo($1.GeoInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGeo() => $_has(0);
  @$pb.TagNumber(1)
  void clearGeo() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.GeoInfo ensureGeo() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.bool get cached => $_getBF(1);
  @$pb.TagNumber(2)
  set cached($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCached() => $_has(1);
  @$pb.TagNumber(2)
  void clearCached() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get lookupTimeMs => $_getI64(2);
  @$pb.TagNumber(3)
  set lookupTimeMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLookupTimeMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearLookupTimeMs() => $_clearField(3);
}

class GetGeoIPStatusRequest extends $pb.GeneratedMessage {
  factory GetGeoIPStatusRequest() => create();

  GetGeoIPStatusRequest._();

  factory GetGeoIPStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGeoIPStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGeoIPStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGeoIPStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGeoIPStatusRequest copyWith(
          void Function(GetGeoIPStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetGeoIPStatusRequest))
          as GetGeoIPStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGeoIPStatusRequest create() => GetGeoIPStatusRequest._();
  @$core.override
  GetGeoIPStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGeoIPStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGeoIPStatusRequest>(create);
  static GetGeoIPStatusRequest? _defaultInstance;
}

class GetGeoIPStatusResponse extends $pb.GeneratedMessage {
  factory GetGeoIPStatusResponse({
    $core.bool? enabled,
    $core.String? mode,
    $core.String? cityDbPath,
    $core.String? ispDbPath,
    $core.String? provider,
    $core.Iterable<$core.String>? strategy,
    $fixnum.Int64? cacheHits,
    $fixnum.Int64? cacheMisses,
  }) {
    final result = create();
    if (enabled != null) result.enabled = enabled;
    if (mode != null) result.mode = mode;
    if (cityDbPath != null) result.cityDbPath = cityDbPath;
    if (ispDbPath != null) result.ispDbPath = ispDbPath;
    if (provider != null) result.provider = provider;
    if (strategy != null) result.strategy.addAll(strategy);
    if (cacheHits != null) result.cacheHits = cacheHits;
    if (cacheMisses != null) result.cacheMisses = cacheMisses;
    return result;
  }

  GetGeoIPStatusResponse._();

  factory GetGeoIPStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGeoIPStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGeoIPStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..aOS(2, _omitFieldNames ? '' : 'mode')
    ..aOS(3, _omitFieldNames ? '' : 'cityDbPath')
    ..aOS(4, _omitFieldNames ? '' : 'ispDbPath')
    ..aOS(5, _omitFieldNames ? '' : 'provider')
    ..pPS(6, _omitFieldNames ? '' : 'strategy')
    ..aInt64(7, _omitFieldNames ? '' : 'cacheHits')
    ..aInt64(8, _omitFieldNames ? '' : 'cacheMisses')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGeoIPStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGeoIPStatusResponse copyWith(
          void Function(GetGeoIPStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetGeoIPStatusResponse))
          as GetGeoIPStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGeoIPStatusResponse create() => GetGeoIPStatusResponse._();
  @$core.override
  GetGeoIPStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGeoIPStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGeoIPStatusResponse>(create);
  static GetGeoIPStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get mode => $_getSZ(1);
  @$pb.TagNumber(2)
  set mode($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearMode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get cityDbPath => $_getSZ(2);
  @$pb.TagNumber(3)
  set cityDbPath($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCityDbPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearCityDbPath() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get ispDbPath => $_getSZ(3);
  @$pb.TagNumber(4)
  set ispDbPath($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIspDbPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearIspDbPath() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get provider => $_getSZ(4);
  @$pb.TagNumber(5)
  set provider($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProvider() => $_has(4);
  @$pb.TagNumber(5)
  void clearProvider() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get strategy => $_getList(5);

  @$pb.TagNumber(7)
  $fixnum.Int64 get cacheHits => $_getI64(6);
  @$pb.TagNumber(7)
  set cacheHits($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCacheHits() => $_has(6);
  @$pb.TagNumber(7)
  void clearCacheHits() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get cacheMisses => $_getI64(7);
  @$pb.TagNumber(8)
  set cacheMisses($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCacheMisses() => $_has(7);
  @$pb.TagNumber(8)
  void clearCacheMisses() => $_clearField(8);
}

class CreateProxyRequest extends $pb.GeneratedMessage {
  factory CreateProxyRequest({
    $core.String? listenAddr,
    $core.String? defaultBackend,
    $core.String? name,
    $core.String? certPem,
    $core.String? keyPem,
    $core.String? caPem,
    $1.ActionType? defaultAction,
    $1.MockPreset? defaultMock,
    $1.FallbackAction? fallbackAction,
    $1.MockPreset? fallbackMock,
    ClientAuthType? clientAuthType,
    $core.Iterable<$core.String>? tags,
    HealthCheckConfig? healthCheck,
  }) {
    final result = create();
    if (listenAddr != null) result.listenAddr = listenAddr;
    if (defaultBackend != null) result.defaultBackend = defaultBackend;
    if (name != null) result.name = name;
    if (certPem != null) result.certPem = certPem;
    if (keyPem != null) result.keyPem = keyPem;
    if (caPem != null) result.caPem = caPem;
    if (defaultAction != null) result.defaultAction = defaultAction;
    if (defaultMock != null) result.defaultMock = defaultMock;
    if (fallbackAction != null) result.fallbackAction = fallbackAction;
    if (fallbackMock != null) result.fallbackMock = fallbackMock;
    if (clientAuthType != null) result.clientAuthType = clientAuthType;
    if (tags != null) result.tags.addAll(tags);
    if (healthCheck != null) result.healthCheck = healthCheck;
    return result;
  }

  CreateProxyRequest._();

  factory CreateProxyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateProxyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateProxyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'listenAddr')
    ..aOS(2, _omitFieldNames ? '' : 'defaultBackend')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'certPem')
    ..aOS(5, _omitFieldNames ? '' : 'keyPem')
    ..aOS(6, _omitFieldNames ? '' : 'caPem')
    ..aE<$1.ActionType>(7, _omitFieldNames ? '' : 'defaultAction',
        enumValues: $1.ActionType.values)
    ..aE<$1.MockPreset>(8, _omitFieldNames ? '' : 'defaultMock',
        enumValues: $1.MockPreset.values)
    ..aE<$1.FallbackAction>(9, _omitFieldNames ? '' : 'fallbackAction',
        enumValues: $1.FallbackAction.values)
    ..aE<$1.MockPreset>(10, _omitFieldNames ? '' : 'fallbackMock',
        enumValues: $1.MockPreset.values)
    ..aE<ClientAuthType>(11, _omitFieldNames ? '' : 'clientAuthType',
        enumValues: ClientAuthType.values)
    ..pPS(12, _omitFieldNames ? '' : 'tags')
    ..aOM<HealthCheckConfig>(13, _omitFieldNames ? '' : 'healthCheck',
        subBuilder: HealthCheckConfig.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProxyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProxyRequest copyWith(void Function(CreateProxyRequest) updates) =>
      super.copyWith((message) => updates(message as CreateProxyRequest))
          as CreateProxyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateProxyRequest create() => CreateProxyRequest._();
  @$core.override
  CreateProxyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateProxyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateProxyRequest>(create);
  static CreateProxyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get listenAddr => $_getSZ(0);
  @$pb.TagNumber(1)
  set listenAddr($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasListenAddr() => $_has(0);
  @$pb.TagNumber(1)
  void clearListenAddr() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get defaultBackend => $_getSZ(1);
  @$pb.TagNumber(2)
  set defaultBackend($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDefaultBackend() => $_has(1);
  @$pb.TagNumber(2)
  void clearDefaultBackend() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get certPem => $_getSZ(3);
  @$pb.TagNumber(4)
  set certPem($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCertPem() => $_has(3);
  @$pb.TagNumber(4)
  void clearCertPem() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get keyPem => $_getSZ(4);
  @$pb.TagNumber(5)
  set keyPem($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasKeyPem() => $_has(4);
  @$pb.TagNumber(5)
  void clearKeyPem() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get caPem => $_getSZ(5);
  @$pb.TagNumber(6)
  set caPem($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCaPem() => $_has(5);
  @$pb.TagNumber(6)
  void clearCaPem() => $_clearField(6);

  @$pb.TagNumber(7)
  $1.ActionType get defaultAction => $_getN(6);
  @$pb.TagNumber(7)
  set defaultAction($1.ActionType value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasDefaultAction() => $_has(6);
  @$pb.TagNumber(7)
  void clearDefaultAction() => $_clearField(7);

  @$pb.TagNumber(8)
  $1.MockPreset get defaultMock => $_getN(7);
  @$pb.TagNumber(8)
  set defaultMock($1.MockPreset value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasDefaultMock() => $_has(7);
  @$pb.TagNumber(8)
  void clearDefaultMock() => $_clearField(8);

  @$pb.TagNumber(9)
  $1.FallbackAction get fallbackAction => $_getN(8);
  @$pb.TagNumber(9)
  set fallbackAction($1.FallbackAction value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasFallbackAction() => $_has(8);
  @$pb.TagNumber(9)
  void clearFallbackAction() => $_clearField(9);

  @$pb.TagNumber(10)
  $1.MockPreset get fallbackMock => $_getN(9);
  @$pb.TagNumber(10)
  set fallbackMock($1.MockPreset value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasFallbackMock() => $_has(9);
  @$pb.TagNumber(10)
  void clearFallbackMock() => $_clearField(10);

  @$pb.TagNumber(11)
  ClientAuthType get clientAuthType => $_getN(10);
  @$pb.TagNumber(11)
  set clientAuthType(ClientAuthType value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasClientAuthType() => $_has(10);
  @$pb.TagNumber(11)
  void clearClientAuthType() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<$core.String> get tags => $_getList(11);

  @$pb.TagNumber(13)
  HealthCheckConfig get healthCheck => $_getN(12);
  @$pb.TagNumber(13)
  set healthCheck(HealthCheckConfig value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasHealthCheck() => $_has(12);
  @$pb.TagNumber(13)
  void clearHealthCheck() => $_clearField(13);
  @$pb.TagNumber(13)
  HealthCheckConfig ensureHealthCheck() => $_ensure(12);
}

class HealthCheckConfig extends $pb.GeneratedMessage {
  factory HealthCheckConfig({
    $core.String? interval,
    $core.String? timeout,
    HealthCheckType? type,
    $core.String? path,
    $core.int? expectedStatus,
  }) {
    final result = create();
    if (interval != null) result.interval = interval;
    if (timeout != null) result.timeout = timeout;
    if (type != null) result.type = type;
    if (path != null) result.path = path;
    if (expectedStatus != null) result.expectedStatus = expectedStatus;
    return result;
  }

  HealthCheckConfig._();

  factory HealthCheckConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HealthCheckConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HealthCheckConfig',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'interval')
    ..aOS(2, _omitFieldNames ? '' : 'timeout')
    ..aE<HealthCheckType>(3, _omitFieldNames ? '' : 'type',
        enumValues: HealthCheckType.values)
    ..aOS(4, _omitFieldNames ? '' : 'path')
    ..aI(5, _omitFieldNames ? '' : 'expectedStatus')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealthCheckConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealthCheckConfig copyWith(void Function(HealthCheckConfig) updates) =>
      super.copyWith((message) => updates(message as HealthCheckConfig))
          as HealthCheckConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HealthCheckConfig create() => HealthCheckConfig._();
  @$core.override
  HealthCheckConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HealthCheckConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HealthCheckConfig>(create);
  static HealthCheckConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get interval => $_getSZ(0);
  @$pb.TagNumber(1)
  set interval($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInterval() => $_has(0);
  @$pb.TagNumber(1)
  void clearInterval() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get timeout => $_getSZ(1);
  @$pb.TagNumber(2)
  set timeout($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimeout() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimeout() => $_clearField(2);

  @$pb.TagNumber(3)
  HealthCheckType get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(HealthCheckType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get path => $_getSZ(3);
  @$pb.TagNumber(4)
  set path($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearPath() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get expectedStatus => $_getIZ(4);
  @$pb.TagNumber(5)
  set expectedStatus($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpectedStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpectedStatus() => $_clearField(5);
}

class CreateProxyResponse extends $pb.GeneratedMessage {
  factory CreateProxyResponse({
    $core.bool? success,
    $core.String? errorMessage,
    $core.String? proxyId,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    if (proxyId != null) result.proxyId = proxyId;
    return result;
  }

  CreateProxyResponse._();

  factory CreateProxyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateProxyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateProxyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..aOS(3, _omitFieldNames ? '' : 'proxyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProxyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateProxyResponse copyWith(void Function(CreateProxyResponse) updates) =>
      super.copyWith((message) => updates(message as CreateProxyResponse))
          as CreateProxyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateProxyResponse create() => CreateProxyResponse._();
  @$core.override
  CreateProxyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateProxyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateProxyResponse>(create);
  static CreateProxyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get proxyId => $_getSZ(2);
  @$pb.TagNumber(3)
  set proxyId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProxyId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProxyId() => $_clearField(3);
}

class DisableProxyRequest extends $pb.GeneratedMessage {
  factory DisableProxyRequest({
    $core.String? proxyId,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    return result;
  }

  DisableProxyRequest._();

  factory DisableProxyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DisableProxyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisableProxyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisableProxyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisableProxyRequest copyWith(void Function(DisableProxyRequest) updates) =>
      super.copyWith((message) => updates(message as DisableProxyRequest))
          as DisableProxyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisableProxyRequest create() => DisableProxyRequest._();
  @$core.override
  DisableProxyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DisableProxyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisableProxyRequest>(create);
  static DisableProxyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);
}

class DisableProxyResponse extends $pb.GeneratedMessage {
  factory DisableProxyResponse({
    $core.bool? success,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  DisableProxyResponse._();

  factory DisableProxyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DisableProxyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisableProxyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisableProxyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisableProxyResponse copyWith(void Function(DisableProxyResponse) updates) =>
      super.copyWith((message) => updates(message as DisableProxyResponse))
          as DisableProxyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisableProxyResponse create() => DisableProxyResponse._();
  @$core.override
  DisableProxyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DisableProxyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisableProxyResponse>(create);
  static DisableProxyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);
}

class EnableProxyRequest extends $pb.GeneratedMessage {
  factory EnableProxyRequest({
    $core.String? proxyId,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    return result;
  }

  EnableProxyRequest._();

  factory EnableProxyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EnableProxyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EnableProxyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnableProxyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnableProxyRequest copyWith(void Function(EnableProxyRequest) updates) =>
      super.copyWith((message) => updates(message as EnableProxyRequest))
          as EnableProxyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EnableProxyRequest create() => EnableProxyRequest._();
  @$core.override
  EnableProxyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EnableProxyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EnableProxyRequest>(create);
  static EnableProxyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);
}

class EnableProxyResponse extends $pb.GeneratedMessage {
  factory EnableProxyResponse({
    $core.bool? success,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  EnableProxyResponse._();

  factory EnableProxyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EnableProxyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EnableProxyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnableProxyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnableProxyResponse copyWith(void Function(EnableProxyResponse) updates) =>
      super.copyWith((message) => updates(message as EnableProxyResponse))
          as EnableProxyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EnableProxyResponse create() => EnableProxyResponse._();
  @$core.override
  EnableProxyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EnableProxyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EnableProxyResponse>(create);
  static EnableProxyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);
}

class DeleteProxyRequest extends $pb.GeneratedMessage {
  factory DeleteProxyRequest({
    $core.String? proxyId,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    return result;
  }

  DeleteProxyRequest._();

  factory DeleteProxyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteProxyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteProxyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteProxyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteProxyRequest copyWith(void Function(DeleteProxyRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteProxyRequest))
          as DeleteProxyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteProxyRequest create() => DeleteProxyRequest._();
  @$core.override
  DeleteProxyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteProxyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteProxyRequest>(create);
  static DeleteProxyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);
}

class DeleteProxyResponse extends $pb.GeneratedMessage {
  factory DeleteProxyResponse({
    $core.bool? success,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  DeleteProxyResponse._();

  factory DeleteProxyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteProxyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteProxyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteProxyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteProxyResponse copyWith(void Function(DeleteProxyResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteProxyResponse))
          as DeleteProxyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteProxyResponse create() => DeleteProxyResponse._();
  @$core.override
  DeleteProxyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteProxyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteProxyResponse>(create);
  static DeleteProxyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);
}

class UpdateProxyRequest extends $pb.GeneratedMessage {
  factory UpdateProxyRequest({
    $core.String? proxyId,
    $core.String? listenAddr,
    $core.String? defaultBackend,
    $core.String? name,
    $core.String? certPem,
    $core.String? keyPem,
    $core.String? caPem,
    $1.ActionType? defaultAction,
    $1.MockPreset? defaultMock,
    $1.FallbackAction? fallbackAction,
    $1.MockPreset? fallbackMock,
    ClientAuthType? clientAuthType,
    $core.Iterable<$core.String>? tags,
    HealthCheckConfig? healthCheck,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (listenAddr != null) result.listenAddr = listenAddr;
    if (defaultBackend != null) result.defaultBackend = defaultBackend;
    if (name != null) result.name = name;
    if (certPem != null) result.certPem = certPem;
    if (keyPem != null) result.keyPem = keyPem;
    if (caPem != null) result.caPem = caPem;
    if (defaultAction != null) result.defaultAction = defaultAction;
    if (defaultMock != null) result.defaultMock = defaultMock;
    if (fallbackAction != null) result.fallbackAction = fallbackAction;
    if (fallbackMock != null) result.fallbackMock = fallbackMock;
    if (clientAuthType != null) result.clientAuthType = clientAuthType;
    if (tags != null) result.tags.addAll(tags);
    if (healthCheck != null) result.healthCheck = healthCheck;
    return result;
  }

  UpdateProxyRequest._();

  factory UpdateProxyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateProxyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateProxyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'listenAddr')
    ..aOS(3, _omitFieldNames ? '' : 'defaultBackend')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'certPem')
    ..aOS(6, _omitFieldNames ? '' : 'keyPem')
    ..aOS(7, _omitFieldNames ? '' : 'caPem')
    ..aE<$1.ActionType>(8, _omitFieldNames ? '' : 'defaultAction',
        enumValues: $1.ActionType.values)
    ..aE<$1.MockPreset>(9, _omitFieldNames ? '' : 'defaultMock',
        enumValues: $1.MockPreset.values)
    ..aE<$1.FallbackAction>(10, _omitFieldNames ? '' : 'fallbackAction',
        enumValues: $1.FallbackAction.values)
    ..aE<$1.MockPreset>(11, _omitFieldNames ? '' : 'fallbackMock',
        enumValues: $1.MockPreset.values)
    ..aE<ClientAuthType>(12, _omitFieldNames ? '' : 'clientAuthType',
        enumValues: ClientAuthType.values)
    ..pPS(13, _omitFieldNames ? '' : 'tags')
    ..aOM<HealthCheckConfig>(14, _omitFieldNames ? '' : 'healthCheck',
        subBuilder: HealthCheckConfig.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProxyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProxyRequest copyWith(void Function(UpdateProxyRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateProxyRequest))
          as UpdateProxyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateProxyRequest create() => UpdateProxyRequest._();
  @$core.override
  UpdateProxyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateProxyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateProxyRequest>(create);
  static UpdateProxyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get listenAddr => $_getSZ(1);
  @$pb.TagNumber(2)
  set listenAddr($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasListenAddr() => $_has(1);
  @$pb.TagNumber(2)
  void clearListenAddr() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get defaultBackend => $_getSZ(2);
  @$pb.TagNumber(3)
  set defaultBackend($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDefaultBackend() => $_has(2);
  @$pb.TagNumber(3)
  void clearDefaultBackend() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get certPem => $_getSZ(4);
  @$pb.TagNumber(5)
  set certPem($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCertPem() => $_has(4);
  @$pb.TagNumber(5)
  void clearCertPem() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get keyPem => $_getSZ(5);
  @$pb.TagNumber(6)
  set keyPem($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasKeyPem() => $_has(5);
  @$pb.TagNumber(6)
  void clearKeyPem() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get caPem => $_getSZ(6);
  @$pb.TagNumber(7)
  set caPem($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCaPem() => $_has(6);
  @$pb.TagNumber(7)
  void clearCaPem() => $_clearField(7);

  @$pb.TagNumber(8)
  $1.ActionType get defaultAction => $_getN(7);
  @$pb.TagNumber(8)
  set defaultAction($1.ActionType value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasDefaultAction() => $_has(7);
  @$pb.TagNumber(8)
  void clearDefaultAction() => $_clearField(8);

  @$pb.TagNumber(9)
  $1.MockPreset get defaultMock => $_getN(8);
  @$pb.TagNumber(9)
  set defaultMock($1.MockPreset value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasDefaultMock() => $_has(8);
  @$pb.TagNumber(9)
  void clearDefaultMock() => $_clearField(9);

  @$pb.TagNumber(10)
  $1.FallbackAction get fallbackAction => $_getN(9);
  @$pb.TagNumber(10)
  set fallbackAction($1.FallbackAction value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasFallbackAction() => $_has(9);
  @$pb.TagNumber(10)
  void clearFallbackAction() => $_clearField(10);

  @$pb.TagNumber(11)
  $1.MockPreset get fallbackMock => $_getN(10);
  @$pb.TagNumber(11)
  set fallbackMock($1.MockPreset value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasFallbackMock() => $_has(10);
  @$pb.TagNumber(11)
  void clearFallbackMock() => $_clearField(11);

  @$pb.TagNumber(12)
  ClientAuthType get clientAuthType => $_getN(11);
  @$pb.TagNumber(12)
  set clientAuthType(ClientAuthType value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasClientAuthType() => $_has(11);
  @$pb.TagNumber(12)
  void clearClientAuthType() => $_clearField(12);

  @$pb.TagNumber(13)
  $pb.PbList<$core.String> get tags => $_getList(12);

  @$pb.TagNumber(14)
  HealthCheckConfig get healthCheck => $_getN(13);
  @$pb.TagNumber(14)
  set healthCheck(HealthCheckConfig value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasHealthCheck() => $_has(13);
  @$pb.TagNumber(14)
  void clearHealthCheck() => $_clearField(14);
  @$pb.TagNumber(14)
  HealthCheckConfig ensureHealthCheck() => $_ensure(13);
}

class UpdateProxyResponse extends $pb.GeneratedMessage {
  factory UpdateProxyResponse({
    $core.bool? success,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  UpdateProxyResponse._();

  factory UpdateProxyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateProxyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateProxyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProxyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateProxyResponse copyWith(void Function(UpdateProxyResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateProxyResponse))
          as UpdateProxyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateProxyResponse create() => UpdateProxyResponse._();
  @$core.override
  UpdateProxyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateProxyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateProxyResponse>(create);
  static UpdateProxyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);
}

class RestartListenersResponse extends $pb.GeneratedMessage {
  factory RestartListenersResponse({
    $core.bool? success,
    $core.int? restartedCount,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (restartedCount != null) result.restartedCount = restartedCount;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  RestartListenersResponse._();

  factory RestartListenersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RestartListenersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RestartListenersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aI(2, _omitFieldNames ? '' : 'restartedCount')
    ..aOS(3, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestartListenersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestartListenersResponse copyWith(
          void Function(RestartListenersResponse) updates) =>
      super.copyWith((message) => updates(message as RestartListenersResponse))
          as RestartListenersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RestartListenersResponse create() => RestartListenersResponse._();
  @$core.override
  RestartListenersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RestartListenersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RestartListenersResponse>(create);
  static RestartListenersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get restartedCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set restartedCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRestartedCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearRestartedCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get errorMessage => $_getSZ(2);
  @$pb.TagNumber(3)
  set errorMessage($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasErrorMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrorMessage() => $_clearField(3);
}

class GetStatusRequest extends $pb.GeneratedMessage {
  factory GetStatusRequest({
    $core.String? proxyId,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    return result;
  }

  GetStatusRequest._();

  factory GetStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatusRequest copyWith(void Function(GetStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetStatusRequest))
          as GetStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatusRequest create() => GetStatusRequest._();
  @$core.override
  GetStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStatusRequest>(create);
  static GetStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);
}

class ProxyStatus extends $pb.GeneratedMessage {
  factory ProxyStatus({
    $core.String? proxyId,
    $core.bool? running,
    $core.String? listenAddr,
    $fixnum.Int64? activeConnections,
    $fixnum.Int64? totalConnections,
    $fixnum.Int64? bytesIn,
    $fixnum.Int64? bytesOut,
    $fixnum.Int64? uptimeSeconds,
    $fixnum.Int64? memoryRss,
    $1.ActionType? defaultAction,
    $1.MockPreset? defaultMock,
    $1.FallbackAction? fallbackAction,
    $1.MockPreset? fallbackMock,
    $core.String? defaultBackend,
    ClientAuthType? clientAuthType,
    $core.Iterable<$core.String>? tags,
    HealthCheckConfig? healthCheck,
    HealthStatus? healthStatus,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (running != null) result.running = running;
    if (listenAddr != null) result.listenAddr = listenAddr;
    if (activeConnections != null) result.activeConnections = activeConnections;
    if (totalConnections != null) result.totalConnections = totalConnections;
    if (bytesIn != null) result.bytesIn = bytesIn;
    if (bytesOut != null) result.bytesOut = bytesOut;
    if (uptimeSeconds != null) result.uptimeSeconds = uptimeSeconds;
    if (memoryRss != null) result.memoryRss = memoryRss;
    if (defaultAction != null) result.defaultAction = defaultAction;
    if (defaultMock != null) result.defaultMock = defaultMock;
    if (fallbackAction != null) result.fallbackAction = fallbackAction;
    if (fallbackMock != null) result.fallbackMock = fallbackMock;
    if (defaultBackend != null) result.defaultBackend = defaultBackend;
    if (clientAuthType != null) result.clientAuthType = clientAuthType;
    if (tags != null) result.tags.addAll(tags);
    if (healthCheck != null) result.healthCheck = healthCheck;
    if (healthStatus != null) result.healthStatus = healthStatus;
    return result;
  }

  ProxyStatus._();

  factory ProxyStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProxyStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProxyStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOB(2, _omitFieldNames ? '' : 'running')
    ..aOS(3, _omitFieldNames ? '' : 'listenAddr')
    ..aInt64(4, _omitFieldNames ? '' : 'activeConnections')
    ..aInt64(5, _omitFieldNames ? '' : 'totalConnections')
    ..aInt64(6, _omitFieldNames ? '' : 'bytesIn')
    ..aInt64(7, _omitFieldNames ? '' : 'bytesOut')
    ..aInt64(8, _omitFieldNames ? '' : 'uptimeSeconds')
    ..aInt64(9, _omitFieldNames ? '' : 'memoryRss')
    ..aE<$1.ActionType>(10, _omitFieldNames ? '' : 'defaultAction',
        enumValues: $1.ActionType.values)
    ..aE<$1.MockPreset>(11, _omitFieldNames ? '' : 'defaultMock',
        enumValues: $1.MockPreset.values)
    ..aE<$1.FallbackAction>(12, _omitFieldNames ? '' : 'fallbackAction',
        enumValues: $1.FallbackAction.values)
    ..aE<$1.MockPreset>(13, _omitFieldNames ? '' : 'fallbackMock',
        enumValues: $1.MockPreset.values)
    ..aOS(14, _omitFieldNames ? '' : 'defaultBackend')
    ..aE<ClientAuthType>(15, _omitFieldNames ? '' : 'clientAuthType',
        enumValues: ClientAuthType.values)
    ..pPS(16, _omitFieldNames ? '' : 'tags')
    ..aOM<HealthCheckConfig>(17, _omitFieldNames ? '' : 'healthCheck',
        subBuilder: HealthCheckConfig.create)
    ..aE<HealthStatus>(18, _omitFieldNames ? '' : 'healthStatus',
        enumValues: HealthStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProxyStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProxyStatus copyWith(void Function(ProxyStatus) updates) =>
      super.copyWith((message) => updates(message as ProxyStatus))
          as ProxyStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProxyStatus create() => ProxyStatus._();
  @$core.override
  ProxyStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProxyStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProxyStatus>(create);
  static ProxyStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get running => $_getBF(1);
  @$pb.TagNumber(2)
  set running($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRunning() => $_has(1);
  @$pb.TagNumber(2)
  void clearRunning() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get listenAddr => $_getSZ(2);
  @$pb.TagNumber(3)
  set listenAddr($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasListenAddr() => $_has(2);
  @$pb.TagNumber(3)
  void clearListenAddr() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get activeConnections => $_getI64(3);
  @$pb.TagNumber(4)
  set activeConnections($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasActiveConnections() => $_has(3);
  @$pb.TagNumber(4)
  void clearActiveConnections() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get totalConnections => $_getI64(4);
  @$pb.TagNumber(5)
  set totalConnections($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalConnections() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalConnections() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get bytesIn => $_getI64(5);
  @$pb.TagNumber(6)
  set bytesIn($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBytesIn() => $_has(5);
  @$pb.TagNumber(6)
  void clearBytesIn() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get bytesOut => $_getI64(6);
  @$pb.TagNumber(7)
  set bytesOut($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBytesOut() => $_has(6);
  @$pb.TagNumber(7)
  void clearBytesOut() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get uptimeSeconds => $_getI64(7);
  @$pb.TagNumber(8)
  set uptimeSeconds($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUptimeSeconds() => $_has(7);
  @$pb.TagNumber(8)
  void clearUptimeSeconds() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get memoryRss => $_getI64(8);
  @$pb.TagNumber(9)
  set memoryRss($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMemoryRss() => $_has(8);
  @$pb.TagNumber(9)
  void clearMemoryRss() => $_clearField(9);

  @$pb.TagNumber(10)
  $1.ActionType get defaultAction => $_getN(9);
  @$pb.TagNumber(10)
  set defaultAction($1.ActionType value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasDefaultAction() => $_has(9);
  @$pb.TagNumber(10)
  void clearDefaultAction() => $_clearField(10);

  @$pb.TagNumber(11)
  $1.MockPreset get defaultMock => $_getN(10);
  @$pb.TagNumber(11)
  set defaultMock($1.MockPreset value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasDefaultMock() => $_has(10);
  @$pb.TagNumber(11)
  void clearDefaultMock() => $_clearField(11);

  @$pb.TagNumber(12)
  $1.FallbackAction get fallbackAction => $_getN(11);
  @$pb.TagNumber(12)
  set fallbackAction($1.FallbackAction value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasFallbackAction() => $_has(11);
  @$pb.TagNumber(12)
  void clearFallbackAction() => $_clearField(12);

  @$pb.TagNumber(13)
  $1.MockPreset get fallbackMock => $_getN(12);
  @$pb.TagNumber(13)
  set fallbackMock($1.MockPreset value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasFallbackMock() => $_has(12);
  @$pb.TagNumber(13)
  void clearFallbackMock() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get defaultBackend => $_getSZ(13);
  @$pb.TagNumber(14)
  set defaultBackend($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasDefaultBackend() => $_has(13);
  @$pb.TagNumber(14)
  void clearDefaultBackend() => $_clearField(14);

  @$pb.TagNumber(15)
  ClientAuthType get clientAuthType => $_getN(14);
  @$pb.TagNumber(15)
  set clientAuthType(ClientAuthType value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasClientAuthType() => $_has(14);
  @$pb.TagNumber(15)
  void clearClientAuthType() => $_clearField(15);

  @$pb.TagNumber(16)
  $pb.PbList<$core.String> get tags => $_getList(15);

  @$pb.TagNumber(17)
  HealthCheckConfig get healthCheck => $_getN(16);
  @$pb.TagNumber(17)
  set healthCheck(HealthCheckConfig value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasHealthCheck() => $_has(16);
  @$pb.TagNumber(17)
  void clearHealthCheck() => $_clearField(17);
  @$pb.TagNumber(17)
  HealthCheckConfig ensureHealthCheck() => $_ensure(16);

  @$pb.TagNumber(18)
  HealthStatus get healthStatus => $_getN(17);
  @$pb.TagNumber(18)
  set healthStatus(HealthStatus value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasHealthStatus() => $_has(17);
  @$pb.TagNumber(18)
  void clearHealthStatus() => $_clearField(18);
}

class ReloadRulesRequest extends $pb.GeneratedMessage {
  factory ReloadRulesRequest({
    $core.Iterable<Rule>? rules,
  }) {
    final result = create();
    if (rules != null) result.rules.addAll(rules);
    return result;
  }

  ReloadRulesRequest._();

  factory ReloadRulesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReloadRulesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReloadRulesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..pPM<Rule>(1, _omitFieldNames ? '' : 'rules', subBuilder: Rule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReloadRulesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReloadRulesRequest copyWith(void Function(ReloadRulesRequest) updates) =>
      super.copyWith((message) => updates(message as ReloadRulesRequest))
          as ReloadRulesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReloadRulesRequest create() => ReloadRulesRequest._();
  @$core.override
  ReloadRulesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReloadRulesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReloadRulesRequest>(create);
  static ReloadRulesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Rule> get rules => $_getList(0);
}

class ReloadRulesResponse extends $pb.GeneratedMessage {
  factory ReloadRulesResponse({
    $core.bool? success,
    $core.int? rulesLoaded,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (rulesLoaded != null) result.rulesLoaded = rulesLoaded;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  ReloadRulesResponse._();

  factory ReloadRulesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReloadRulesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReloadRulesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aI(2, _omitFieldNames ? '' : 'rulesLoaded')
    ..aOS(3, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReloadRulesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReloadRulesResponse copyWith(void Function(ReloadRulesResponse) updates) =>
      super.copyWith((message) => updates(message as ReloadRulesResponse))
          as ReloadRulesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReloadRulesResponse create() => ReloadRulesResponse._();
  @$core.override
  ReloadRulesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReloadRulesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReloadRulesResponse>(create);
  static ReloadRulesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get rulesLoaded => $_getIZ(1);
  @$pb.TagNumber(2)
  set rulesLoaded($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRulesLoaded() => $_has(1);
  @$pb.TagNumber(2)
  void clearRulesLoaded() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get errorMessage => $_getSZ(2);
  @$pb.TagNumber(3)
  set errorMessage($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasErrorMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrorMessage() => $_clearField(3);
}

class ApplyProxyRequest extends $pb.GeneratedMessage {
  factory ApplyProxyRequest({
    $core.String? proxyId,
    $fixnum.Int64? revisionNum,
    $core.String? configYaml,
    $core.String? configHash,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (revisionNum != null) result.revisionNum = revisionNum;
    if (configYaml != null) result.configYaml = configYaml;
    if (configHash != null) result.configHash = configHash;
    return result;
  }

  ApplyProxyRequest._();

  factory ApplyProxyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApplyProxyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApplyProxyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aInt64(2, _omitFieldNames ? '' : 'revisionNum')
    ..aOS(3, _omitFieldNames ? '' : 'configYaml')
    ..aOS(4, _omitFieldNames ? '' : 'configHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyProxyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyProxyRequest copyWith(void Function(ApplyProxyRequest) updates) =>
      super.copyWith((message) => updates(message as ApplyProxyRequest))
          as ApplyProxyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApplyProxyRequest create() => ApplyProxyRequest._();
  @$core.override
  ApplyProxyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApplyProxyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApplyProxyRequest>(create);
  static ApplyProxyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get revisionNum => $_getI64(1);
  @$pb.TagNumber(2)
  set revisionNum($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevisionNum() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevisionNum() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get configYaml => $_getSZ(2);
  @$pb.TagNumber(3)
  set configYaml($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConfigYaml() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfigYaml() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get configHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set configHash($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfigHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfigHash() => $_clearField(4);
}

class ApplyProxyResponse extends $pb.GeneratedMessage {
  factory ApplyProxyResponse({
    $core.bool? success,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  ApplyProxyResponse._();

  factory ApplyProxyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApplyProxyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApplyProxyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyProxyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyProxyResponse copyWith(void Function(ApplyProxyResponse) updates) =>
      super.copyWith((message) => updates(message as ApplyProxyResponse))
          as ApplyProxyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApplyProxyResponse create() => ApplyProxyResponse._();
  @$core.override
  ApplyProxyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApplyProxyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApplyProxyResponse>(create);
  static ApplyProxyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);
}

class AppliedProxyStatus extends $pb.GeneratedMessage {
  factory AppliedProxyStatus({
    $core.String? proxyId,
    $fixnum.Int64? revisionNum,
    $core.String? appliedAt,
    $core.String? status,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (revisionNum != null) result.revisionNum = revisionNum;
    if (appliedAt != null) result.appliedAt = appliedAt;
    if (status != null) result.status = status;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  AppliedProxyStatus._();

  factory AppliedProxyStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AppliedProxyStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AppliedProxyStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aInt64(2, _omitFieldNames ? '' : 'revisionNum')
    ..aOS(3, _omitFieldNames ? '' : 'appliedAt')
    ..aOS(4, _omitFieldNames ? '' : 'status')
    ..aOS(5, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AppliedProxyStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AppliedProxyStatus copyWith(void Function(AppliedProxyStatus) updates) =>
      super.copyWith((message) => updates(message as AppliedProxyStatus))
          as AppliedProxyStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AppliedProxyStatus create() => AppliedProxyStatus._();
  @$core.override
  AppliedProxyStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AppliedProxyStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AppliedProxyStatus>(create);
  static AppliedProxyStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get revisionNum => $_getI64(1);
  @$pb.TagNumber(2)
  set revisionNum($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevisionNum() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevisionNum() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get appliedAt => $_getSZ(2);
  @$pb.TagNumber(3)
  set appliedAt($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAppliedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearAppliedAt() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get status => $_getSZ(3);
  @$pb.TagNumber(4)
  set status($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get errorMessage => $_getSZ(4);
  @$pb.TagNumber(5)
  set errorMessage($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasErrorMessage() => $_has(4);
  @$pb.TagNumber(5)
  void clearErrorMessage() => $_clearField(5);
}

class GetAppliedProxiesResponse extends $pb.GeneratedMessage {
  factory GetAppliedProxiesResponse({
    $core.Iterable<AppliedProxyStatus>? proxies,
  }) {
    final result = create();
    if (proxies != null) result.proxies.addAll(proxies);
    return result;
  }

  GetAppliedProxiesResponse._();

  factory GetAppliedProxiesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAppliedProxiesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAppliedProxiesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..pPM<AppliedProxyStatus>(1, _omitFieldNames ? '' : 'proxies',
        subBuilder: AppliedProxyStatus.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAppliedProxiesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAppliedProxiesResponse copyWith(
          void Function(GetAppliedProxiesResponse) updates) =>
      super.copyWith((message) => updates(message as GetAppliedProxiesResponse))
          as GetAppliedProxiesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAppliedProxiesResponse create() => GetAppliedProxiesResponse._();
  @$core.override
  GetAppliedProxiesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAppliedProxiesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAppliedProxiesResponse>(create);
  static GetAppliedProxiesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AppliedProxyStatus> get proxies => $_getList(0);
}

class Rule extends $pb.GeneratedMessage {
  factory Rule({
    $core.String? id,
    $core.String? name,
    $core.int? priority,
    $core.bool? enabled,
    $core.Iterable<Condition>? conditions,
    $1.ActionType? action,
    $core.String? targetBackend,
    RateLimitConfig? rateLimit,
    MockConfig? mockResponse,
    $core.String? expression,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (priority != null) result.priority = priority;
    if (enabled != null) result.enabled = enabled;
    if (conditions != null) result.conditions.addAll(conditions);
    if (action != null) result.action = action;
    if (targetBackend != null) result.targetBackend = targetBackend;
    if (rateLimit != null) result.rateLimit = rateLimit;
    if (mockResponse != null) result.mockResponse = mockResponse;
    if (expression != null) result.expression = expression;
    return result;
  }

  Rule._();

  factory Rule.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Rule.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Rule',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'priority')
    ..aOB(4, _omitFieldNames ? '' : 'enabled')
    ..pPM<Condition>(5, _omitFieldNames ? '' : 'conditions',
        subBuilder: Condition.create)
    ..aE<$1.ActionType>(6, _omitFieldNames ? '' : 'action',
        enumValues: $1.ActionType.values)
    ..aOS(7, _omitFieldNames ? '' : 'targetBackend')
    ..aOM<RateLimitConfig>(8, _omitFieldNames ? '' : 'rateLimit',
        subBuilder: RateLimitConfig.create)
    ..aOM<MockConfig>(9, _omitFieldNames ? '' : 'mockResponse',
        subBuilder: MockConfig.create)
    ..aOS(10, _omitFieldNames ? '' : 'expression')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Rule clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Rule copyWith(void Function(Rule) updates) =>
      super.copyWith((message) => updates(message as Rule)) as Rule;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Rule create() => Rule._();
  @$core.override
  Rule createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Rule getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Rule>(create);
  static Rule? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get priority => $_getIZ(2);
  @$pb.TagNumber(3)
  set priority($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPriority() => $_has(2);
  @$pb.TagNumber(3)
  void clearPriority() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get enabled => $_getBF(3);
  @$pb.TagNumber(4)
  set enabled($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEnabled() => $_has(3);
  @$pb.TagNumber(4)
  void clearEnabled() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<Condition> get conditions => $_getList(4);

  @$pb.TagNumber(6)
  $1.ActionType get action => $_getN(5);
  @$pb.TagNumber(6)
  set action($1.ActionType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasAction() => $_has(5);
  @$pb.TagNumber(6)
  void clearAction() => $_clearField(6);

  /// Target backend for this rule (overrides default).
  /// Can be a specific "IP:Port" or a named group.
  @$pb.TagNumber(7)
  $core.String get targetBackend => $_getSZ(6);
  @$pb.TagNumber(7)
  set targetBackend($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTargetBackend() => $_has(6);
  @$pb.TagNumber(7)
  void clearTargetBackend() => $_clearField(7);

  /// Additional configuration for specific actions
  @$pb.TagNumber(8)
  RateLimitConfig get rateLimit => $_getN(7);
  @$pb.TagNumber(8)
  set rateLimit(RateLimitConfig value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasRateLimit() => $_has(7);
  @$pb.TagNumber(8)
  void clearRateLimit() => $_clearField(8);
  @$pb.TagNumber(8)
  RateLimitConfig ensureRateLimit() => $_ensure(7);

  @$pb.TagNumber(9)
  MockConfig get mockResponse => $_getN(8);
  @$pb.TagNumber(9)
  set mockResponse(MockConfig value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasMockResponse() => $_has(8);
  @$pb.TagNumber(9)
  void clearMockResponse() => $_clearField(9);
  @$pb.TagNumber(9)
  MockConfig ensureMockResponse() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.String get expression => $_getSZ(9);
  @$pb.TagNumber(10)
  set expression($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasExpression() => $_has(9);
  @$pb.TagNumber(10)
  void clearExpression() => $_clearField(10);
}

class Condition extends $pb.GeneratedMessage {
  factory Condition({
    $1.ConditionType? type,
    $1.Operator? op,
    $core.String? value,
    $core.bool? negate,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (op != null) result.op = op;
    if (value != null) result.value = value;
    if (negate != null) result.negate = negate;
    return result;
  }

  Condition._();

  factory Condition.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Condition.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Condition',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aE<$1.ConditionType>(1, _omitFieldNames ? '' : 'type',
        enumValues: $1.ConditionType.values)
    ..aE<$1.Operator>(2, _omitFieldNames ? '' : 'op',
        enumValues: $1.Operator.values)
    ..aOS(3, _omitFieldNames ? '' : 'value')
    ..aOB(4, _omitFieldNames ? '' : 'negate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Condition clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Condition copyWith(void Function(Condition) updates) =>
      super.copyWith((message) => updates(message as Condition)) as Condition;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Condition create() => Condition._();
  @$core.override
  Condition createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Condition getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Condition>(create);
  static Condition? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ConditionType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type($1.ConditionType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Operator get op => $_getN(1);
  @$pb.TagNumber(2)
  set op($1.Operator value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasOp() => $_has(1);
  @$pb.TagNumber(2)
  void clearOp() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get value => $_getSZ(2);
  @$pb.TagNumber(3)
  set value($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get negate => $_getBF(3);
  @$pb.TagNumber(4)
  set negate($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNegate() => $_has(3);
  @$pb.TagNumber(4)
  void clearNegate() => $_clearField(4);
}

class RateLimitConfig extends $pb.GeneratedMessage {
  factory RateLimitConfig({
    $core.int? maxConnections,
    $core.int? intervalSeconds,
    $core.bool? autoBlock,
    $core.int? blockDurationSeconds,
    $core.Iterable<$core.int>? blockStepsSeconds,
    $core.bool? countOnlyFailures,
    $core.int? failureDurationThreshold,
  }) {
    final result = create();
    if (maxConnections != null) result.maxConnections = maxConnections;
    if (intervalSeconds != null) result.intervalSeconds = intervalSeconds;
    if (autoBlock != null) result.autoBlock = autoBlock;
    if (blockDurationSeconds != null)
      result.blockDurationSeconds = blockDurationSeconds;
    if (blockStepsSeconds != null)
      result.blockStepsSeconds.addAll(blockStepsSeconds);
    if (countOnlyFailures != null) result.countOnlyFailures = countOnlyFailures;
    if (failureDurationThreshold != null)
      result.failureDurationThreshold = failureDurationThreshold;
    return result;
  }

  RateLimitConfig._();

  factory RateLimitConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RateLimitConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RateLimitConfig',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'maxConnections')
    ..aI(2, _omitFieldNames ? '' : 'intervalSeconds')
    ..aOB(3, _omitFieldNames ? '' : 'autoBlock')
    ..aI(4, _omitFieldNames ? '' : 'blockDurationSeconds')
    ..p<$core.int>(
        5, _omitFieldNames ? '' : 'blockStepsSeconds', $pb.PbFieldType.K3)
    ..aOB(6, _omitFieldNames ? '' : 'countOnlyFailures')
    ..aI(7, _omitFieldNames ? '' : 'failureDurationThreshold')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RateLimitConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RateLimitConfig copyWith(void Function(RateLimitConfig) updates) =>
      super.copyWith((message) => updates(message as RateLimitConfig))
          as RateLimitConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RateLimitConfig create() => RateLimitConfig._();
  @$core.override
  RateLimitConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RateLimitConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RateLimitConfig>(create);
  static RateLimitConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get maxConnections => $_getIZ(0);
  @$pb.TagNumber(1)
  set maxConnections($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMaxConnections() => $_has(0);
  @$pb.TagNumber(1)
  void clearMaxConnections() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get intervalSeconds => $_getIZ(1);
  @$pb.TagNumber(2)
  set intervalSeconds($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIntervalSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearIntervalSeconds() => $_clearField(2);

  /// Auto-Block / Fail2Ban Logic
  @$pb.TagNumber(3)
  $core.bool get autoBlock => $_getBF(2);
  @$pb.TagNumber(3)
  set autoBlock($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAutoBlock() => $_has(2);
  @$pb.TagNumber(3)
  void clearAutoBlock() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get blockDurationSeconds => $_getIZ(3);
  @$pb.TagNumber(4)
  set blockDurationSeconds($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBlockDurationSeconds() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockDurationSeconds() => $_clearField(4);

  /// Escalation policy: [600, 3600, 86400] -> 10m, 1h, 24h.
  /// If empty, uses block_duration_seconds constantly.
  /// If last step is reached, subsequent blocks use the last step value.
  @$pb.TagNumber(5)
  $pb.PbList<$core.int> get blockStepsSeconds => $_getList(4);

  /// Heuristic for "Failure"
  @$pb.TagNumber(6)
  $core.bool get countOnlyFailures => $_getBF(5);
  @$pb.TagNumber(6)
  set countOnlyFailures($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCountOnlyFailures() => $_has(5);
  @$pb.TagNumber(6)
  void clearCountOnlyFailures() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get failureDurationThreshold => $_getIZ(6);
  @$pb.TagNumber(7)
  set failureDurationThreshold($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFailureDurationThreshold() => $_has(6);
  @$pb.TagNumber(7)
  void clearFailureDurationThreshold() => $_clearField(7);
}

class MockConfig extends $pb.GeneratedMessage {
  factory MockConfig({
    $1.MockPreset? preset,
    $core.String? protocol,
    $core.List<$core.int>? payload,
    $core.int? delayMs,
  }) {
    final result = create();
    if (preset != null) result.preset = preset;
    if (protocol != null) result.protocol = protocol;
    if (payload != null) result.payload = payload;
    if (delayMs != null) result.delayMs = delayMs;
    return result;
  }

  MockConfig._();

  factory MockConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MockConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MockConfig',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aE<$1.MockPreset>(1, _omitFieldNames ? '' : 'preset',
        enumValues: $1.MockPreset.values)
    ..aOS(2, _omitFieldNames ? '' : 'protocol')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aI(4, _omitFieldNames ? '' : 'delayMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MockConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MockConfig copyWith(void Function(MockConfig) updates) =>
      super.copyWith((message) => updates(message as MockConfig)) as MockConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MockConfig create() => MockConfig._();
  @$core.override
  MockConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MockConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MockConfig>(create);
  static MockConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $1.MockPreset get preset => $_getN(0);
  @$pb.TagNumber(1)
  set preset($1.MockPreset value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPreset() => $_has(0);
  @$pb.TagNumber(1)
  void clearPreset() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get protocol => $_getSZ(1);
  @$pb.TagNumber(2)
  set protocol($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProtocol() => $_has(1);
  @$pb.TagNumber(2)
  void clearProtocol() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get payload => $_getN(2);
  @$pb.TagNumber(3)
  set payload($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPayload() => $_has(2);
  @$pb.TagNumber(3)
  void clearPayload() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get delayMs => $_getIZ(3);
  @$pb.TagNumber(4)
  set delayMs($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDelayMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearDelayMs() => $_clearField(4);
}

class AddRuleRequest extends $pb.GeneratedMessage {
  factory AddRuleRequest({
    $core.String? proxyId,
    Rule? rule,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (rule != null) result.rule = rule;
    return result;
  }

  AddRuleRequest._();

  factory AddRuleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddRuleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddRuleRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOM<Rule>(2, _omitFieldNames ? '' : 'rule', subBuilder: Rule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddRuleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddRuleRequest copyWith(void Function(AddRuleRequest) updates) =>
      super.copyWith((message) => updates(message as AddRuleRequest))
          as AddRuleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddRuleRequest create() => AddRuleRequest._();
  @$core.override
  AddRuleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddRuleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddRuleRequest>(create);
  static AddRuleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  Rule get rule => $_getN(1);
  @$pb.TagNumber(2)
  set rule(Rule value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRule() => $_has(1);
  @$pb.TagNumber(2)
  void clearRule() => $_clearField(2);
  @$pb.TagNumber(2)
  Rule ensureRule() => $_ensure(1);
}

class RemoveRuleRequest extends $pb.GeneratedMessage {
  factory RemoveRuleRequest({
    $core.String? proxyId,
    $core.String? ruleId,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (ruleId != null) result.ruleId = ruleId;
    return result;
  }

  RemoveRuleRequest._();

  factory RemoveRuleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveRuleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveRuleRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'ruleId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveRuleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveRuleRequest copyWith(void Function(RemoveRuleRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveRuleRequest))
          as RemoveRuleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveRuleRequest create() => RemoveRuleRequest._();
  @$core.override
  RemoveRuleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveRuleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveRuleRequest>(create);
  static RemoveRuleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get ruleId => $_getSZ(1);
  @$pb.TagNumber(2)
  set ruleId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRuleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRuleId() => $_clearField(2);
}

class ListRulesRequest extends $pb.GeneratedMessage {
  factory ListRulesRequest({
    $core.String? proxyId,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    return result;
  }

  ListRulesRequest._();

  factory ListRulesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListRulesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListRulesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRulesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRulesRequest copyWith(void Function(ListRulesRequest) updates) =>
      super.copyWith((message) => updates(message as ListRulesRequest))
          as ListRulesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRulesRequest create() => ListRulesRequest._();
  @$core.override
  ListRulesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListRulesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListRulesRequest>(create);
  static ListRulesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);
}

class ListRulesResponse extends $pb.GeneratedMessage {
  factory ListRulesResponse({
    $core.Iterable<Rule>? rules,
  }) {
    final result = create();
    if (rules != null) result.rules.addAll(rules);
    return result;
  }

  ListRulesResponse._();

  factory ListRulesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListRulesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListRulesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..pPM<Rule>(1, _omitFieldNames ? '' : 'rules', subBuilder: Rule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRulesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRulesResponse copyWith(void Function(ListRulesResponse) updates) =>
      super.copyWith((message) => updates(message as ListRulesResponse))
          as ListRulesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRulesResponse create() => ListRulesResponse._();
  @$core.override
  ListRulesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListRulesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListRulesResponse>(create);
  static ListRulesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Rule> get rules => $_getList(0);
}

class ListProxiesRequest extends $pb.GeneratedMessage {
  factory ListProxiesRequest() => create();

  ListProxiesRequest._();

  factory ListProxiesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListProxiesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProxiesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProxiesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProxiesRequest copyWith(void Function(ListProxiesRequest) updates) =>
      super.copyWith((message) => updates(message as ListProxiesRequest))
          as ListProxiesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProxiesRequest create() => ListProxiesRequest._();
  @$core.override
  ListProxiesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListProxiesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListProxiesRequest>(create);
  static ListProxiesRequest? _defaultInstance;
}

class ListProxiesResponse extends $pb.GeneratedMessage {
  factory ListProxiesResponse({
    $core.Iterable<ProxyStatus>? proxies,
  }) {
    final result = create();
    if (proxies != null) result.proxies.addAll(proxies);
    return result;
  }

  ListProxiesResponse._();

  factory ListProxiesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListProxiesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProxiesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..pPM<ProxyStatus>(1, _omitFieldNames ? '' : 'proxies',
        subBuilder: ProxyStatus.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProxiesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProxiesResponse copyWith(void Function(ListProxiesResponse) updates) =>
      super.copyWith((message) => updates(message as ListProxiesResponse))
          as ListProxiesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProxiesResponse create() => ListProxiesResponse._();
  @$core.override
  ListProxiesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListProxiesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListProxiesResponse>(create);
  static ListProxiesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ProxyStatus> get proxies => $_getList(0);
}

class BlockIPRequest extends $pb.GeneratedMessage {
  factory BlockIPRequest({
    $core.String? ip,
    $fixnum.Int64? durationSeconds,
    $core.String? reason,
  }) {
    final result = create();
    if (ip != null) result.ip = ip;
    if (durationSeconds != null) result.durationSeconds = durationSeconds;
    if (reason != null) result.reason = reason;
    return result;
  }

  BlockIPRequest._();

  factory BlockIPRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockIPRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockIPRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ip')
    ..aInt64(2, _omitFieldNames ? '' : 'durationSeconds')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockIPRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockIPRequest copyWith(void Function(BlockIPRequest) updates) =>
      super.copyWith((message) => updates(message as BlockIPRequest))
          as BlockIPRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockIPRequest create() => BlockIPRequest._();
  @$core.override
  BlockIPRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockIPRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockIPRequest>(create);
  static BlockIPRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ip => $_getSZ(0);
  @$pb.TagNumber(1)
  set ip($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIp() => $_has(0);
  @$pb.TagNumber(1)
  void clearIp() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get durationSeconds => $_getI64(1);
  @$pb.TagNumber(2)
  set durationSeconds($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDurationSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearDurationSeconds() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => $_clearField(3);
}

class AllowIPRequest extends $pb.GeneratedMessage {
  factory AllowIPRequest({
    $core.String? ip,
    $fixnum.Int64? durationSeconds,
  }) {
    final result = create();
    if (ip != null) result.ip = ip;
    if (durationSeconds != null) result.durationSeconds = durationSeconds;
    return result;
  }

  AllowIPRequest._();

  factory AllowIPRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AllowIPRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AllowIPRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ip')
    ..aInt64(2, _omitFieldNames ? '' : 'durationSeconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllowIPRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllowIPRequest copyWith(void Function(AllowIPRequest) updates) =>
      super.copyWith((message) => updates(message as AllowIPRequest))
          as AllowIPRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AllowIPRequest create() => AllowIPRequest._();
  @$core.override
  AllowIPRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AllowIPRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AllowIPRequest>(create);
  static AllowIPRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ip => $_getSZ(0);
  @$pb.TagNumber(1)
  set ip($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIp() => $_has(0);
  @$pb.TagNumber(1)
  void clearIp() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get durationSeconds => $_getI64(1);
  @$pb.TagNumber(2)
  set durationSeconds($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDurationSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearDurationSeconds() => $_clearField(2);
}

class GlobalRule extends $pb.GeneratedMessage {
  factory GlobalRule({
    $core.String? id,
    $core.String? name,
    $core.String? sourceIp,
    $1.ActionType? action,
    $2.Timestamp? expiresAt,
    $2.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (sourceIp != null) result.sourceIp = sourceIp;
    if (action != null) result.action = action;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  GlobalRule._();

  factory GlobalRule.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GlobalRule.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GlobalRule',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'sourceIp')
    ..aE<$1.ActionType>(4, _omitFieldNames ? '' : 'action',
        enumValues: $1.ActionType.values)
    ..aOM<$2.Timestamp>(5, _omitFieldNames ? '' : 'expiresAt',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GlobalRule clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GlobalRule copyWith(void Function(GlobalRule) updates) =>
      super.copyWith((message) => updates(message as GlobalRule)) as GlobalRule;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GlobalRule create() => GlobalRule._();
  @$core.override
  GlobalRule createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GlobalRule getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GlobalRule>(create);
  static GlobalRule? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sourceIp => $_getSZ(2);
  @$pb.TagNumber(3)
  set sourceIp($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSourceIp() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourceIp() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.ActionType get action => $_getN(3);
  @$pb.TagNumber(4)
  set action($1.ActionType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAction() => $_has(3);
  @$pb.TagNumber(4)
  void clearAction() => $_clearField(4);

  @$pb.TagNumber(5)
  $2.Timestamp get expiresAt => $_getN(4);
  @$pb.TagNumber(5)
  set expiresAt($2.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasExpiresAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpiresAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $2.Timestamp ensureExpiresAt() => $_ensure(4);

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
}

class ListGlobalRulesRequest extends $pb.GeneratedMessage {
  factory ListGlobalRulesRequest() => create();

  ListGlobalRulesRequest._();

  factory ListGlobalRulesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListGlobalRulesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListGlobalRulesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListGlobalRulesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListGlobalRulesRequest copyWith(
          void Function(ListGlobalRulesRequest) updates) =>
      super.copyWith((message) => updates(message as ListGlobalRulesRequest))
          as ListGlobalRulesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListGlobalRulesRequest create() => ListGlobalRulesRequest._();
  @$core.override
  ListGlobalRulesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListGlobalRulesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListGlobalRulesRequest>(create);
  static ListGlobalRulesRequest? _defaultInstance;
}

class ListGlobalRulesResponse extends $pb.GeneratedMessage {
  factory ListGlobalRulesResponse({
    $core.Iterable<GlobalRule>? rules,
  }) {
    final result = create();
    if (rules != null) result.rules.addAll(rules);
    return result;
  }

  ListGlobalRulesResponse._();

  factory ListGlobalRulesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListGlobalRulesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListGlobalRulesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..pPM<GlobalRule>(1, _omitFieldNames ? '' : 'rules',
        subBuilder: GlobalRule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListGlobalRulesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListGlobalRulesResponse copyWith(
          void Function(ListGlobalRulesResponse) updates) =>
      super.copyWith((message) => updates(message as ListGlobalRulesResponse))
          as ListGlobalRulesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListGlobalRulesResponse create() => ListGlobalRulesResponse._();
  @$core.override
  ListGlobalRulesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListGlobalRulesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListGlobalRulesResponse>(create);
  static ListGlobalRulesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GlobalRule> get rules => $_getList(0);
}

class RemoveGlobalRuleRequest extends $pb.GeneratedMessage {
  factory RemoveGlobalRuleRequest({
    $core.String? ruleId,
  }) {
    final result = create();
    if (ruleId != null) result.ruleId = ruleId;
    return result;
  }

  RemoveGlobalRuleRequest._();

  factory RemoveGlobalRuleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveGlobalRuleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveGlobalRuleRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ruleId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGlobalRuleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGlobalRuleRequest copyWith(
          void Function(RemoveGlobalRuleRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveGlobalRuleRequest))
          as RemoveGlobalRuleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveGlobalRuleRequest create() => RemoveGlobalRuleRequest._();
  @$core.override
  RemoveGlobalRuleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveGlobalRuleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveGlobalRuleRequest>(create);
  static RemoveGlobalRuleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ruleId => $_getSZ(0);
  @$pb.TagNumber(1)
  set ruleId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRuleId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRuleId() => $_clearField(1);
}

class RemoveGlobalRuleResponse extends $pb.GeneratedMessage {
  factory RemoveGlobalRuleResponse({
    $core.bool? success,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  RemoveGlobalRuleResponse._();

  factory RemoveGlobalRuleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveGlobalRuleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveGlobalRuleResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGlobalRuleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGlobalRuleResponse copyWith(
          void Function(RemoveGlobalRuleResponse) updates) =>
      super.copyWith((message) => updates(message as RemoveGlobalRuleResponse))
          as RemoveGlobalRuleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveGlobalRuleResponse create() => RemoveGlobalRuleResponse._();
  @$core.override
  RemoveGlobalRuleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveGlobalRuleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveGlobalRuleResponse>(create);
  static RemoveGlobalRuleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);
}

class StreamConnectionsRequest extends $pb.GeneratedMessage {
  factory StreamConnectionsRequest({
    $core.bool? activeOnly,
    $core.List<$core.int>? viewerPubkey,
  }) {
    final result = create();
    if (activeOnly != null) result.activeOnly = activeOnly;
    if (viewerPubkey != null) result.viewerPubkey = viewerPubkey;
    return result;
  }

  StreamConnectionsRequest._();

  factory StreamConnectionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamConnectionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamConnectionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'activeOnly')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'viewerPubkey', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamConnectionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamConnectionsRequest copyWith(
          void Function(StreamConnectionsRequest) updates) =>
      super.copyWith((message) => updates(message as StreamConnectionsRequest))
          as StreamConnectionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamConnectionsRequest create() => StreamConnectionsRequest._();
  @$core.override
  StreamConnectionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamConnectionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamConnectionsRequest>(create);
  static StreamConnectionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get activeOnly => $_getBF(0);
  @$pb.TagNumber(1)
  set activeOnly($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasActiveOnly() => $_has(0);
  @$pb.TagNumber(1)
  void clearActiveOnly() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get viewerPubkey => $_getN(1);
  @$pb.TagNumber(2)
  set viewerPubkey($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasViewerPubkey() => $_has(1);
  @$pb.TagNumber(2)
  void clearViewerPubkey() => $_clearField(2);
}

class ConnectionEvent extends $pb.GeneratedMessage {
  factory ConnectionEvent({
    $core.String? connId,
    $core.String? sourceIp,
    $core.int? sourcePort,
    $core.String? targetAddr,
    EventType? eventType,
    $fixnum.Int64? timestamp,
    $core.String? ruleMatched,
    $1.ActionType? actionTaken,
    $fixnum.Int64? bytesIn,
    $fixnum.Int64? bytesOut,
    $1.GeoInfo? geo,
  }) {
    final result = create();
    if (connId != null) result.connId = connId;
    if (sourceIp != null) result.sourceIp = sourceIp;
    if (sourcePort != null) result.sourcePort = sourcePort;
    if (targetAddr != null) result.targetAddr = targetAddr;
    if (eventType != null) result.eventType = eventType;
    if (timestamp != null) result.timestamp = timestamp;
    if (ruleMatched != null) result.ruleMatched = ruleMatched;
    if (actionTaken != null) result.actionTaken = actionTaken;
    if (bytesIn != null) result.bytesIn = bytesIn;
    if (bytesOut != null) result.bytesOut = bytesOut;
    if (geo != null) result.geo = geo;
    return result;
  }

  ConnectionEvent._();

  factory ConnectionEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConnectionEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnectionEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'connId')
    ..aOS(2, _omitFieldNames ? '' : 'sourceIp')
    ..aI(3, _omitFieldNames ? '' : 'sourcePort')
    ..aOS(4, _omitFieldNames ? '' : 'targetAddr')
    ..aE<EventType>(5, _omitFieldNames ? '' : 'eventType',
        enumValues: EventType.values)
    ..aInt64(6, _omitFieldNames ? '' : 'timestamp')
    ..aOS(7, _omitFieldNames ? '' : 'ruleMatched')
    ..aE<$1.ActionType>(8, _omitFieldNames ? '' : 'actionTaken',
        enumValues: $1.ActionType.values)
    ..aInt64(9, _omitFieldNames ? '' : 'bytesIn')
    ..aInt64(10, _omitFieldNames ? '' : 'bytesOut')
    ..aOM<$1.GeoInfo>(11, _omitFieldNames ? '' : 'geo',
        subBuilder: $1.GeoInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectionEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectionEvent copyWith(void Function(ConnectionEvent) updates) =>
      super.copyWith((message) => updates(message as ConnectionEvent))
          as ConnectionEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnectionEvent create() => ConnectionEvent._();
  @$core.override
  ConnectionEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConnectionEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConnectionEvent>(create);
  static ConnectionEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get connId => $_getSZ(0);
  @$pb.TagNumber(1)
  set connId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConnId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConnId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sourceIp => $_getSZ(1);
  @$pb.TagNumber(2)
  set sourceIp($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSourceIp() => $_has(1);
  @$pb.TagNumber(2)
  void clearSourceIp() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get sourcePort => $_getIZ(2);
  @$pb.TagNumber(3)
  set sourcePort($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSourcePort() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourcePort() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get targetAddr => $_getSZ(3);
  @$pb.TagNumber(4)
  set targetAddr($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTargetAddr() => $_has(3);
  @$pb.TagNumber(4)
  void clearTargetAddr() => $_clearField(4);

  @$pb.TagNumber(5)
  EventType get eventType => $_getN(4);
  @$pb.TagNumber(5)
  set eventType(EventType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasEventType() => $_has(4);
  @$pb.TagNumber(5)
  void clearEventType() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get timestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set timestamp($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimestamp() => $_clearField(6);

  /// Context
  @$pb.TagNumber(7)
  $core.String get ruleMatched => $_getSZ(6);
  @$pb.TagNumber(7)
  set ruleMatched($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRuleMatched() => $_has(6);
  @$pb.TagNumber(7)
  void clearRuleMatched() => $_clearField(7);

  @$pb.TagNumber(8)
  $1.ActionType get actionTaken => $_getN(7);
  @$pb.TagNumber(8)
  set actionTaken($1.ActionType value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasActionTaken() => $_has(7);
  @$pb.TagNumber(8)
  void clearActionTaken() => $_clearField(8);

  /// Stats (for CLOSED events)
  @$pb.TagNumber(9)
  $fixnum.Int64 get bytesIn => $_getI64(8);
  @$pb.TagNumber(9)
  set bytesIn($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasBytesIn() => $_has(8);
  @$pb.TagNumber(9)
  void clearBytesIn() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get bytesOut => $_getI64(9);
  @$pb.TagNumber(10)
  set bytesOut($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasBytesOut() => $_has(9);
  @$pb.TagNumber(10)
  void clearBytesOut() => $_clearField(10);

  @$pb.TagNumber(11)
  $1.GeoInfo get geo => $_getN(10);
  @$pb.TagNumber(11)
  set geo($1.GeoInfo value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasGeo() => $_has(10);
  @$pb.TagNumber(11)
  void clearGeo() => $_clearField(11);
  @$pb.TagNumber(11)
  $1.GeoInfo ensureGeo() => $_ensure(10);
}

class StreamMetricsRequest extends $pb.GeneratedMessage {
  factory StreamMetricsRequest({
    $core.int? intervalSeconds,
    $core.List<$core.int>? viewerPubkey,
  }) {
    final result = create();
    if (intervalSeconds != null) result.intervalSeconds = intervalSeconds;
    if (viewerPubkey != null) result.viewerPubkey = viewerPubkey;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'intervalSeconds')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'viewerPubkey', $pb.PbFieldType.OY)
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
  $core.int get intervalSeconds => $_getIZ(0);
  @$pb.TagNumber(1)
  set intervalSeconds($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIntervalSeconds() => $_has(0);
  @$pb.TagNumber(1)
  void clearIntervalSeconds() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get viewerPubkey => $_getN(1);
  @$pb.TagNumber(2)
  set viewerPubkey($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasViewerPubkey() => $_has(1);
  @$pb.TagNumber(2)
  void clearViewerPubkey() => $_clearField(2);
}

class MetricsSample extends $pb.GeneratedMessage {
  factory MetricsSample({
    $fixnum.Int64? timestamp,
    $fixnum.Int64? activeConns,
    $fixnum.Int64? totalConns,
    $fixnum.Int64? bytesInRate,
    $fixnum.Int64? bytesOutRate,
    $fixnum.Int64? blockedTotal,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    if (activeConns != null) result.activeConns = activeConns;
    if (totalConns != null) result.totalConns = totalConns;
    if (bytesInRate != null) result.bytesInRate = bytesInRate;
    if (bytesOutRate != null) result.bytesOutRate = bytesOutRate;
    if (blockedTotal != null) result.blockedTotal = blockedTotal;
    return result;
  }

  MetricsSample._();

  factory MetricsSample.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MetricsSample.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MetricsSample',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'timestamp')
    ..aInt64(2, _omitFieldNames ? '' : 'activeConns')
    ..aInt64(3, _omitFieldNames ? '' : 'totalConns')
    ..aInt64(4, _omitFieldNames ? '' : 'bytesInRate')
    ..aInt64(5, _omitFieldNames ? '' : 'bytesOutRate')
    ..aInt64(6, _omitFieldNames ? '' : 'blockedTotal')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MetricsSample clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MetricsSample copyWith(void Function(MetricsSample) updates) =>
      super.copyWith((message) => updates(message as MetricsSample))
          as MetricsSample;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MetricsSample create() => MetricsSample._();
  @$core.override
  MetricsSample createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MetricsSample getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MetricsSample>(create);
  static MetricsSample? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get timestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set timestamp($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get activeConns => $_getI64(1);
  @$pb.TagNumber(2)
  set activeConns($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasActiveConns() => $_has(1);
  @$pb.TagNumber(2)
  void clearActiveConns() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get totalConns => $_getI64(2);
  @$pb.TagNumber(3)
  set totalConns($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalConns() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalConns() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get bytesInRate => $_getI64(3);
  @$pb.TagNumber(4)
  set bytesInRate($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBytesInRate() => $_has(3);
  @$pb.TagNumber(4)
  void clearBytesInRate() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get bytesOutRate => $_getI64(4);
  @$pb.TagNumber(5)
  set bytesOutRate($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBytesOutRate() => $_has(4);
  @$pb.TagNumber(5)
  void clearBytesOutRate() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get blockedTotal => $_getI64(5);
  @$pb.TagNumber(6)
  set blockedTotal($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBlockedTotal() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlockedTotal() => $_clearField(6);
}

/// EncryptedStreamPayload wraps E2E encrypted streaming data.
/// Used by StreamMetrics and StreamConnections to encrypt payloads
/// with the viewer's public key before sending over direct gRPC.
class EncryptedStreamPayload extends $pb.GeneratedMessage {
  factory EncryptedStreamPayload({
    $1.EncryptedPayload? encrypted,
    $core.String? payloadType,
  }) {
    final result = create();
    if (encrypted != null) result.encrypted = encrypted;
    if (payloadType != null) result.payloadType = payloadType;
    return result;
  }

  EncryptedStreamPayload._();

  factory EncryptedStreamPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EncryptedStreamPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EncryptedStreamPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOM<$1.EncryptedPayload>(1, _omitFieldNames ? '' : 'encrypted',
        subBuilder: $1.EncryptedPayload.create)
    ..aOS(2, _omitFieldNames ? '' : 'payloadType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptedStreamPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptedStreamPayload copyWith(
          void Function(EncryptedStreamPayload) updates) =>
      super.copyWith((message) => updates(message as EncryptedStreamPayload))
          as EncryptedStreamPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncryptedStreamPayload create() => EncryptedStreamPayload._();
  @$core.override
  EncryptedStreamPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EncryptedStreamPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EncryptedStreamPayload>(create);
  static EncryptedStreamPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $1.EncryptedPayload get encrypted => $_getN(0);
  @$pb.TagNumber(1)
  set encrypted($1.EncryptedPayload value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEncrypted() => $_has(0);
  @$pb.TagNumber(1)
  void clearEncrypted() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.EncryptedPayload ensureEncrypted() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get payloadType => $_getSZ(1);
  @$pb.TagNumber(2)
  set payloadType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPayloadType() => $_has(1);
  @$pb.TagNumber(2)
  void clearPayloadType() => $_clearField(2);
}

class ActiveConnection extends $pb.GeneratedMessage {
  factory ActiveConnection({
    $core.String? id,
    $core.String? sourceIp,
    $core.int? sourcePort,
    $core.String? destAddr,
    $2.Timestamp? startTime,
    $fixnum.Int64? bytesIn,
    $fixnum.Int64? bytesOut,
    $1.GeoInfo? geo,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (sourceIp != null) result.sourceIp = sourceIp;
    if (sourcePort != null) result.sourcePort = sourcePort;
    if (destAddr != null) result.destAddr = destAddr;
    if (startTime != null) result.startTime = startTime;
    if (bytesIn != null) result.bytesIn = bytesIn;
    if (bytesOut != null) result.bytesOut = bytesOut;
    if (geo != null) result.geo = geo;
    return result;
  }

  ActiveConnection._();

  factory ActiveConnection.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActiveConnection.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActiveConnection',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'sourceIp')
    ..aI(3, _omitFieldNames ? '' : 'sourcePort')
    ..aOS(4, _omitFieldNames ? '' : 'destAddr')
    ..aOM<$2.Timestamp>(5, _omitFieldNames ? '' : 'startTime',
        subBuilder: $2.Timestamp.create)
    ..aInt64(6, _omitFieldNames ? '' : 'bytesIn')
    ..aInt64(7, _omitFieldNames ? '' : 'bytesOut')
    ..aOM<$1.GeoInfo>(8, _omitFieldNames ? '' : 'geo',
        subBuilder: $1.GeoInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActiveConnection clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActiveConnection copyWith(void Function(ActiveConnection) updates) =>
      super.copyWith((message) => updates(message as ActiveConnection))
          as ActiveConnection;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActiveConnection create() => ActiveConnection._();
  @$core.override
  ActiveConnection createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ActiveConnection getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActiveConnection>(create);
  static ActiveConnection? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sourceIp => $_getSZ(1);
  @$pb.TagNumber(2)
  set sourceIp($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSourceIp() => $_has(1);
  @$pb.TagNumber(2)
  void clearSourceIp() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get sourcePort => $_getIZ(2);
  @$pb.TagNumber(3)
  set sourcePort($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSourcePort() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourcePort() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get destAddr => $_getSZ(3);
  @$pb.TagNumber(4)
  set destAddr($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDestAddr() => $_has(3);
  @$pb.TagNumber(4)
  void clearDestAddr() => $_clearField(4);

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
  $fixnum.Int64 get bytesIn => $_getI64(5);
  @$pb.TagNumber(6)
  set bytesIn($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBytesIn() => $_has(5);
  @$pb.TagNumber(6)
  void clearBytesIn() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get bytesOut => $_getI64(6);
  @$pb.TagNumber(7)
  set bytesOut($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBytesOut() => $_has(6);
  @$pb.TagNumber(7)
  void clearBytesOut() => $_clearField(7);

  @$pb.TagNumber(8)
  $1.GeoInfo get geo => $_getN(7);
  @$pb.TagNumber(8)
  set geo($1.GeoInfo value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasGeo() => $_has(7);
  @$pb.TagNumber(8)
  void clearGeo() => $_clearField(8);
  @$pb.TagNumber(8)
  $1.GeoInfo ensureGeo() => $_ensure(7);
}

class GetActiveConnectionsRequest extends $pb.GeneratedMessage {
  factory GetActiveConnectionsRequest({
    $core.String? nodeId,
    $core.String? proxyId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    return result;
  }

  GetActiveConnectionsRequest._();

  factory GetActiveConnectionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetActiveConnectionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetActiveConnectionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetActiveConnectionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetActiveConnectionsRequest copyWith(
          void Function(GetActiveConnectionsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetActiveConnectionsRequest))
          as GetActiveConnectionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetActiveConnectionsRequest create() =>
      GetActiveConnectionsRequest._();
  @$core.override
  GetActiveConnectionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetActiveConnectionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetActiveConnectionsRequest>(create);
  static GetActiveConnectionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get proxyId => $_getSZ(1);
  @$pb.TagNumber(2)
  set proxyId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProxyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProxyId() => $_clearField(2);
}

class GetActiveConnectionsResponse extends $pb.GeneratedMessage {
  factory GetActiveConnectionsResponse({
    $core.Iterable<ActiveConnection>? connections,
  }) {
    final result = create();
    if (connections != null) result.connections.addAll(connections);
    return result;
  }

  GetActiveConnectionsResponse._();

  factory GetActiveConnectionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetActiveConnectionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetActiveConnectionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..pPM<ActiveConnection>(1, _omitFieldNames ? '' : 'connections',
        subBuilder: ActiveConnection.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetActiveConnectionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetActiveConnectionsResponse copyWith(
          void Function(GetActiveConnectionsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetActiveConnectionsResponse))
          as GetActiveConnectionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetActiveConnectionsResponse create() =>
      GetActiveConnectionsResponse._();
  @$core.override
  GetActiveConnectionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetActiveConnectionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetActiveConnectionsResponse>(create);
  static GetActiveConnectionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ActiveConnection> get connections => $_getList(0);
}

class CloseConnectionRequest extends $pb.GeneratedMessage {
  factory CloseConnectionRequest({
    $core.String? proxyId,
    $core.String? connId,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (connId != null) result.connId = connId;
    return result;
  }

  CloseConnectionRequest._();

  factory CloseConnectionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CloseConnectionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CloseConnectionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'connId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseConnectionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseConnectionRequest copyWith(
          void Function(CloseConnectionRequest) updates) =>
      super.copyWith((message) => updates(message as CloseConnectionRequest))
          as CloseConnectionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CloseConnectionRequest create() => CloseConnectionRequest._();
  @$core.override
  CloseConnectionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CloseConnectionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CloseConnectionRequest>(create);
  static CloseConnectionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get connId => $_getSZ(1);
  @$pb.TagNumber(2)
  set connId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConnId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConnId() => $_clearField(2);
}

class CloseConnectionResponse extends $pb.GeneratedMessage {
  factory CloseConnectionResponse({
    $core.bool? success,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  CloseConnectionResponse._();

  factory CloseConnectionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CloseConnectionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CloseConnectionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseConnectionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseConnectionResponse copyWith(
          void Function(CloseConnectionResponse) updates) =>
      super.copyWith((message) => updates(message as CloseConnectionResponse))
          as CloseConnectionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CloseConnectionResponse create() => CloseConnectionResponse._();
  @$core.override
  CloseConnectionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CloseConnectionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CloseConnectionResponse>(create);
  static CloseConnectionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);
}

class CloseAllConnectionsRequest extends $pb.GeneratedMessage {
  factory CloseAllConnectionsRequest({
    $core.String? proxyId,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    return result;
  }

  CloseAllConnectionsRequest._();

  factory CloseAllConnectionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CloseAllConnectionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CloseAllConnectionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseAllConnectionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseAllConnectionsRequest copyWith(
          void Function(CloseAllConnectionsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CloseAllConnectionsRequest))
          as CloseAllConnectionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CloseAllConnectionsRequest create() => CloseAllConnectionsRequest._();
  @$core.override
  CloseAllConnectionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CloseAllConnectionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CloseAllConnectionsRequest>(create);
  static CloseAllConnectionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);
}

class CloseAllConnectionsResponse extends $pb.GeneratedMessage {
  factory CloseAllConnectionsResponse({
    $core.bool? success,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  CloseAllConnectionsResponse._();

  factory CloseAllConnectionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CloseAllConnectionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CloseAllConnectionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseAllConnectionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseAllConnectionsResponse copyWith(
          void Function(CloseAllConnectionsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CloseAllConnectionsResponse))
          as CloseAllConnectionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CloseAllConnectionsResponse create() =>
      CloseAllConnectionsResponse._();
  @$core.override
  CloseAllConnectionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CloseAllConnectionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CloseAllConnectionsResponse>(create);
  static CloseAllConnectionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);
}

class GetIPStatsRequest extends $pb.GeneratedMessage {
  factory GetIPStatsRequest({
    $core.int? limit,
    $core.int? offset,
    $core.String? sourceIpFilter,
    $core.String? countryFilter,
    $core.String? sortBy,
  }) {
    final result = create();
    if (limit != null) result.limit = limit;
    if (offset != null) result.offset = offset;
    if (sourceIpFilter != null) result.sourceIpFilter = sourceIpFilter;
    if (countryFilter != null) result.countryFilter = countryFilter;
    if (sortBy != null) result.sortBy = sortBy;
    return result;
  }

  GetIPStatsRequest._();

  factory GetIPStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetIPStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetIPStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'limit')
    ..aI(2, _omitFieldNames ? '' : 'offset')
    ..aOS(3, _omitFieldNames ? '' : 'sourceIpFilter')
    ..aOS(4, _omitFieldNames ? '' : 'countryFilter')
    ..aOS(5, _omitFieldNames ? '' : 'sortBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIPStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIPStatsRequest copyWith(void Function(GetIPStatsRequest) updates) =>
      super.copyWith((message) => updates(message as GetIPStatsRequest))
          as GetIPStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetIPStatsRequest create() => GetIPStatsRequest._();
  @$core.override
  GetIPStatsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetIPStatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetIPStatsRequest>(create);
  static GetIPStatsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get limit => $_getIZ(0);
  @$pb.TagNumber(1)
  set limit($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLimit() => $_has(0);
  @$pb.TagNumber(1)
  void clearLimit() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get offset => $_getIZ(1);
  @$pb.TagNumber(2)
  set offset($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearOffset() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sourceIpFilter => $_getSZ(2);
  @$pb.TagNumber(3)
  set sourceIpFilter($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSourceIpFilter() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourceIpFilter() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get countryFilter => $_getSZ(3);
  @$pb.TagNumber(4)
  set countryFilter($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCountryFilter() => $_has(3);
  @$pb.TagNumber(4)
  void clearCountryFilter() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get sortBy => $_getSZ(4);
  @$pb.TagNumber(5)
  set sortBy($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSortBy() => $_has(4);
  @$pb.TagNumber(5)
  void clearSortBy() => $_clearField(5);
}

class IPStatsResult extends $pb.GeneratedMessage {
  factory IPStatsResult({
    $core.String? sourceIp,
    $2.Timestamp? firstSeen,
    $2.Timestamp? lastSeen,
    $fixnum.Int64? connectionCount,
    $fixnum.Int64? totalBytesIn,
    $fixnum.Int64? totalBytesOut,
    $fixnum.Int64? totalDurationMs,
    $fixnum.Int64? blockedCount,
    $fixnum.Int64? allowedCount,
    $core.String? geoCountry,
    $core.String? geoCity,
    $core.String? geoIsp,
    $core.double? recencyWeight,
  }) {
    final result = create();
    if (sourceIp != null) result.sourceIp = sourceIp;
    if (firstSeen != null) result.firstSeen = firstSeen;
    if (lastSeen != null) result.lastSeen = lastSeen;
    if (connectionCount != null) result.connectionCount = connectionCount;
    if (totalBytesIn != null) result.totalBytesIn = totalBytesIn;
    if (totalBytesOut != null) result.totalBytesOut = totalBytesOut;
    if (totalDurationMs != null) result.totalDurationMs = totalDurationMs;
    if (blockedCount != null) result.blockedCount = blockedCount;
    if (allowedCount != null) result.allowedCount = allowedCount;
    if (geoCountry != null) result.geoCountry = geoCountry;
    if (geoCity != null) result.geoCity = geoCity;
    if (geoIsp != null) result.geoIsp = geoIsp;
    if (recencyWeight != null) result.recencyWeight = recencyWeight;
    return result;
  }

  IPStatsResult._();

  factory IPStatsResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IPStatsResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IPStatsResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sourceIp')
    ..aOM<$2.Timestamp>(2, _omitFieldNames ? '' : 'firstSeen',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(3, _omitFieldNames ? '' : 'lastSeen',
        subBuilder: $2.Timestamp.create)
    ..aInt64(4, _omitFieldNames ? '' : 'connectionCount')
    ..aInt64(5, _omitFieldNames ? '' : 'totalBytesIn')
    ..aInt64(6, _omitFieldNames ? '' : 'totalBytesOut')
    ..aInt64(7, _omitFieldNames ? '' : 'totalDurationMs')
    ..aInt64(8, _omitFieldNames ? '' : 'blockedCount')
    ..aInt64(9, _omitFieldNames ? '' : 'allowedCount')
    ..aOS(10, _omitFieldNames ? '' : 'geoCountry')
    ..aOS(11, _omitFieldNames ? '' : 'geoCity')
    ..aOS(12, _omitFieldNames ? '' : 'geoIsp')
    ..aD(13, _omitFieldNames ? '' : 'recencyWeight')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IPStatsResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IPStatsResult copyWith(void Function(IPStatsResult) updates) =>
      super.copyWith((message) => updates(message as IPStatsResult))
          as IPStatsResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IPStatsResult create() => IPStatsResult._();
  @$core.override
  IPStatsResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IPStatsResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IPStatsResult>(create);
  static IPStatsResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sourceIp => $_getSZ(0);
  @$pb.TagNumber(1)
  set sourceIp($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSourceIp() => $_has(0);
  @$pb.TagNumber(1)
  void clearSourceIp() => $_clearField(1);

  @$pb.TagNumber(2)
  $2.Timestamp get firstSeen => $_getN(1);
  @$pb.TagNumber(2)
  set firstSeen($2.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFirstSeen() => $_has(1);
  @$pb.TagNumber(2)
  void clearFirstSeen() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.Timestamp ensureFirstSeen() => $_ensure(1);

  @$pb.TagNumber(3)
  $2.Timestamp get lastSeen => $_getN(2);
  @$pb.TagNumber(3)
  set lastSeen($2.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasLastSeen() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastSeen() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.Timestamp ensureLastSeen() => $_ensure(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get connectionCount => $_getI64(3);
  @$pb.TagNumber(4)
  set connectionCount($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConnectionCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearConnectionCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get totalBytesIn => $_getI64(4);
  @$pb.TagNumber(5)
  set totalBytesIn($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalBytesIn() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalBytesIn() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get totalBytesOut => $_getI64(5);
  @$pb.TagNumber(6)
  set totalBytesOut($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalBytesOut() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalBytesOut() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get totalDurationMs => $_getI64(6);
  @$pb.TagNumber(7)
  set totalDurationMs($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTotalDurationMs() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalDurationMs() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get blockedCount => $_getI64(7);
  @$pb.TagNumber(8)
  set blockedCount($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBlockedCount() => $_has(7);
  @$pb.TagNumber(8)
  void clearBlockedCount() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get allowedCount => $_getI64(8);
  @$pb.TagNumber(9)
  set allowedCount($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasAllowedCount() => $_has(8);
  @$pb.TagNumber(9)
  void clearAllowedCount() => $_clearField(9);

  /// Geo Info
  @$pb.TagNumber(10)
  $core.String get geoCountry => $_getSZ(9);
  @$pb.TagNumber(10)
  set geoCountry($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasGeoCountry() => $_has(9);
  @$pb.TagNumber(10)
  void clearGeoCountry() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get geoCity => $_getSZ(10);
  @$pb.TagNumber(11)
  set geoCity($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasGeoCity() => $_has(10);
  @$pb.TagNumber(11)
  void clearGeoCity() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get geoIsp => $_getSZ(11);
  @$pb.TagNumber(12)
  set geoIsp($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasGeoIsp() => $_has(11);
  @$pb.TagNumber(12)
  void clearGeoIsp() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get recencyWeight => $_getN(12);
  @$pb.TagNumber(13)
  set recencyWeight($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasRecencyWeight() => $_has(12);
  @$pb.TagNumber(13)
  void clearRecencyWeight() => $_clearField(13);
}

class GetIPStatsResponse extends $pb.GeneratedMessage {
  factory GetIPStatsResponse({
    $core.Iterable<IPStatsResult>? stats,
    $fixnum.Int64? totalCount,
  }) {
    final result = create();
    if (stats != null) result.stats.addAll(stats);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  GetIPStatsResponse._();

  factory GetIPStatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetIPStatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetIPStatsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..pPM<IPStatsResult>(1, _omitFieldNames ? '' : 'stats',
        subBuilder: IPStatsResult.create)
    ..aInt64(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIPStatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIPStatsResponse copyWith(void Function(GetIPStatsResponse) updates) =>
      super.copyWith((message) => updates(message as GetIPStatsResponse))
          as GetIPStatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetIPStatsResponse create() => GetIPStatsResponse._();
  @$core.override
  GetIPStatsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetIPStatsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetIPStatsResponse>(create);
  static GetIPStatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<IPStatsResult> get stats => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalCount => $_getI64(1);
  @$pb.TagNumber(2)
  set totalCount($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class GetGeoStatsRequest extends $pb.GeneratedMessage {
  factory GetGeoStatsRequest({
    $core.String? type,
    $core.int? limit,
    $core.int? offset,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (limit != null) result.limit = limit;
    if (offset != null) result.offset = offset;
    return result;
  }

  GetGeoStatsRequest._();

  factory GetGeoStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGeoStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGeoStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aI(2, _omitFieldNames ? '' : 'limit')
    ..aI(3, _omitFieldNames ? '' : 'offset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGeoStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGeoStatsRequest copyWith(void Function(GetGeoStatsRequest) updates) =>
      super.copyWith((message) => updates(message as GetGeoStatsRequest))
          as GetGeoStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGeoStatsRequest create() => GetGeoStatsRequest._();
  @$core.override
  GetGeoStatsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGeoStatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGeoStatsRequest>(create);
  static GetGeoStatsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get offset => $_getIZ(2);
  @$pb.TagNumber(3)
  set offset($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearOffset() => $_clearField(3);
}

class GeoStatsResult extends $pb.GeneratedMessage {
  factory GeoStatsResult({
    $core.String? type,
    $core.String? value,
    $fixnum.Int64? connectionCount,
    $fixnum.Int64? uniqueIps,
    $fixnum.Int64? totalBytesIn,
    $fixnum.Int64? totalBytesOut,
    $fixnum.Int64? blockedCount,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (value != null) result.value = value;
    if (connectionCount != null) result.connectionCount = connectionCount;
    if (uniqueIps != null) result.uniqueIps = uniqueIps;
    if (totalBytesIn != null) result.totalBytesIn = totalBytesIn;
    if (totalBytesOut != null) result.totalBytesOut = totalBytesOut;
    if (blockedCount != null) result.blockedCount = blockedCount;
    return result;
  }

  GeoStatsResult._();

  factory GeoStatsResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GeoStatsResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GeoStatsResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..aInt64(3, _omitFieldNames ? '' : 'connectionCount')
    ..aInt64(4, _omitFieldNames ? '' : 'uniqueIps')
    ..aInt64(5, _omitFieldNames ? '' : 'totalBytesIn')
    ..aInt64(6, _omitFieldNames ? '' : 'totalBytesOut')
    ..aInt64(7, _omitFieldNames ? '' : 'blockedCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeoStatsResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeoStatsResult copyWith(void Function(GeoStatsResult) updates) =>
      super.copyWith((message) => updates(message as GeoStatsResult))
          as GeoStatsResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GeoStatsResult create() => GeoStatsResult._();
  @$core.override
  GeoStatsResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GeoStatsResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GeoStatsResult>(create);
  static GeoStatsResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get connectionCount => $_getI64(2);
  @$pb.TagNumber(3)
  set connectionCount($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConnectionCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearConnectionCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get uniqueIps => $_getI64(3);
  @$pb.TagNumber(4)
  set uniqueIps($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUniqueIps() => $_has(3);
  @$pb.TagNumber(4)
  void clearUniqueIps() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get totalBytesIn => $_getI64(4);
  @$pb.TagNumber(5)
  set totalBytesIn($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalBytesIn() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalBytesIn() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get totalBytesOut => $_getI64(5);
  @$pb.TagNumber(6)
  set totalBytesOut($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalBytesOut() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalBytesOut() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get blockedCount => $_getI64(6);
  @$pb.TagNumber(7)
  set blockedCount($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBlockedCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlockedCount() => $_clearField(7);
}

class GetGeoStatsResponse extends $pb.GeneratedMessage {
  factory GetGeoStatsResponse({
    $core.Iterable<GeoStatsResult>? stats,
  }) {
    final result = create();
    if (stats != null) result.stats.addAll(stats);
    return result;
  }

  GetGeoStatsResponse._();

  factory GetGeoStatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGeoStatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGeoStatsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..pPM<GeoStatsResult>(1, _omitFieldNames ? '' : 'stats',
        subBuilder: GeoStatsResult.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGeoStatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGeoStatsResponse copyWith(void Function(GetGeoStatsResponse) updates) =>
      super.copyWith((message) => updates(message as GetGeoStatsResponse))
          as GetGeoStatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGeoStatsResponse create() => GetGeoStatsResponse._();
  @$core.override
  GetGeoStatsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGeoStatsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGeoStatsResponse>(create);
  static GetGeoStatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GeoStatsResult> get stats => $_getList(0);
}

class GetStatsSummaryRequest extends $pb.GeneratedMessage {
  factory GetStatsSummaryRequest() => create();

  GetStatsSummaryRequest._();

  factory GetStatsSummaryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetStatsSummaryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStatsSummaryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsSummaryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsSummaryRequest copyWith(
          void Function(GetStatsSummaryRequest) updates) =>
      super.copyWith((message) => updates(message as GetStatsSummaryRequest))
          as GetStatsSummaryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatsSummaryRequest create() => GetStatsSummaryRequest._();
  @$core.override
  GetStatsSummaryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetStatsSummaryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStatsSummaryRequest>(create);
  static GetStatsSummaryRequest? _defaultInstance;
}

class StatsSummaryResponse extends $pb.GeneratedMessage {
  factory StatsSummaryResponse({
    $fixnum.Int64? totalConnections,
    $fixnum.Int64? totalBytesIn,
    $fixnum.Int64? totalBytesOut,
    $fixnum.Int64? uniqueIps,
    $fixnum.Int64? uniqueCountries,
    $fixnum.Int64? blockedTotal,
    $fixnum.Int64? allowedTotal,
    $fixnum.Int64? activeConnections,
    $core.int? proxyCount,
    $2.Timestamp? timestamp,
  }) {
    final result = create();
    if (totalConnections != null) result.totalConnections = totalConnections;
    if (totalBytesIn != null) result.totalBytesIn = totalBytesIn;
    if (totalBytesOut != null) result.totalBytesOut = totalBytesOut;
    if (uniqueIps != null) result.uniqueIps = uniqueIps;
    if (uniqueCountries != null) result.uniqueCountries = uniqueCountries;
    if (blockedTotal != null) result.blockedTotal = blockedTotal;
    if (allowedTotal != null) result.allowedTotal = allowedTotal;
    if (activeConnections != null) result.activeConnections = activeConnections;
    if (proxyCount != null) result.proxyCount = proxyCount;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  StatsSummaryResponse._();

  factory StatsSummaryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StatsSummaryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StatsSummaryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'totalConnections')
    ..aInt64(2, _omitFieldNames ? '' : 'totalBytesIn')
    ..aInt64(3, _omitFieldNames ? '' : 'totalBytesOut')
    ..aInt64(4, _omitFieldNames ? '' : 'uniqueIps')
    ..aInt64(5, _omitFieldNames ? '' : 'uniqueCountries')
    ..aInt64(6, _omitFieldNames ? '' : 'blockedTotal')
    ..aInt64(7, _omitFieldNames ? '' : 'allowedTotal')
    ..aInt64(8, _omitFieldNames ? '' : 'activeConnections')
    ..aI(9, _omitFieldNames ? '' : 'proxyCount')
    ..aOM<$2.Timestamp>(10, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatsSummaryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatsSummaryResponse copyWith(void Function(StatsSummaryResponse) updates) =>
      super.copyWith((message) => updates(message as StatsSummaryResponse))
          as StatsSummaryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StatsSummaryResponse create() => StatsSummaryResponse._();
  @$core.override
  StatsSummaryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StatsSummaryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StatsSummaryResponse>(create);
  static StatsSummaryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get totalConnections => $_getI64(0);
  @$pb.TagNumber(1)
  set totalConnections($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalConnections() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalConnections() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalBytesIn => $_getI64(1);
  @$pb.TagNumber(2)
  set totalBytesIn($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalBytesIn() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalBytesIn() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get totalBytesOut => $_getI64(2);
  @$pb.TagNumber(3)
  set totalBytesOut($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalBytesOut() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalBytesOut() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get uniqueIps => $_getI64(3);
  @$pb.TagNumber(4)
  set uniqueIps($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUniqueIps() => $_has(3);
  @$pb.TagNumber(4)
  void clearUniqueIps() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get uniqueCountries => $_getI64(4);
  @$pb.TagNumber(5)
  set uniqueCountries($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUniqueCountries() => $_has(4);
  @$pb.TagNumber(5)
  void clearUniqueCountries() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get blockedTotal => $_getI64(5);
  @$pb.TagNumber(6)
  set blockedTotal($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBlockedTotal() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlockedTotal() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get allowedTotal => $_getI64(6);
  @$pb.TagNumber(7)
  set allowedTotal($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAllowedTotal() => $_has(6);
  @$pb.TagNumber(7)
  void clearAllowedTotal() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get activeConnections => $_getI64(7);
  @$pb.TagNumber(8)
  set activeConnections($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasActiveConnections() => $_has(7);
  @$pb.TagNumber(8)
  void clearActiveConnections() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get proxyCount => $_getIZ(8);
  @$pb.TagNumber(9)
  set proxyCount($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasProxyCount() => $_has(8);
  @$pb.TagNumber(9)
  void clearProxyCount() => $_clearField(9);

  @$pb.TagNumber(10)
  $2.Timestamp get timestamp => $_getN(9);
  @$pb.TagNumber(10)
  set timestamp($2.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasTimestamp() => $_has(9);
  @$pb.TagNumber(10)
  void clearTimestamp() => $_clearField(10);
  @$pb.TagNumber(10)
  $2.Timestamp ensureTimestamp() => $_ensure(9);
}

class ResolveApprovalRequest extends $pb.GeneratedMessage {
  factory ResolveApprovalRequest({
    $core.String? reqId,
    $1.ApprovalActionType? action,
    $1.ApprovalRetentionMode? retentionMode,
    $fixnum.Int64? durationSeconds,
    $core.String? reason,
  }) {
    final result = create();
    if (reqId != null) result.reqId = reqId;
    if (action != null) result.action = action;
    if (retentionMode != null) result.retentionMode = retentionMode;
    if (durationSeconds != null) result.durationSeconds = durationSeconds;
    if (reason != null) result.reason = reason;
    return result;
  }

  ResolveApprovalRequest._();

  factory ResolveApprovalRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResolveApprovalRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolveApprovalRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'reqId')
    ..aE<$1.ApprovalActionType>(2, _omitFieldNames ? '' : 'action',
        enumValues: $1.ApprovalActionType.values)
    ..aE<$1.ApprovalRetentionMode>(3, _omitFieldNames ? '' : 'retentionMode',
        enumValues: $1.ApprovalRetentionMode.values)
    ..aInt64(4, _omitFieldNames ? '' : 'durationSeconds')
    ..aOS(5, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveApprovalRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveApprovalRequest copyWith(
          void Function(ResolveApprovalRequest) updates) =>
      super.copyWith((message) => updates(message as ResolveApprovalRequest))
          as ResolveApprovalRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResolveApprovalRequest create() => ResolveApprovalRequest._();
  @$core.override
  ResolveApprovalRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResolveApprovalRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolveApprovalRequest>(create);
  static ResolveApprovalRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get reqId => $_getSZ(0);
  @$pb.TagNumber(1)
  set reqId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReqId() => $_has(0);
  @$pb.TagNumber(1)
  void clearReqId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.ApprovalActionType get action => $_getN(1);
  @$pb.TagNumber(2)
  set action($1.ApprovalActionType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.ApprovalRetentionMode get retentionMode => $_getN(2);
  @$pb.TagNumber(3)
  set retentionMode($1.ApprovalRetentionMode value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRetentionMode() => $_has(2);
  @$pb.TagNumber(3)
  void clearRetentionMode() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get durationSeconds => $_getI64(3);
  @$pb.TagNumber(4)
  set durationSeconds($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDurationSeconds() => $_has(3);
  @$pb.TagNumber(4)
  void clearDurationSeconds() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get reason => $_getSZ(4);
  @$pb.TagNumber(5)
  set reason($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReason() => $_has(4);
  @$pb.TagNumber(5)
  void clearReason() => $_clearField(5);
}

class ResolveApprovalResponse extends $pb.GeneratedMessage {
  factory ResolveApprovalResponse({
    $core.bool? success,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  ResolveApprovalResponse._();

  factory ResolveApprovalResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResolveApprovalResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolveApprovalResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveApprovalResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveApprovalResponse copyWith(
          void Function(ResolveApprovalResponse) updates) =>
      super.copyWith((message) => updates(message as ResolveApprovalResponse))
          as ResolveApprovalResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResolveApprovalResponse create() => ResolveApprovalResponse._();
  @$core.override
  ResolveApprovalResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResolveApprovalResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolveApprovalResponse>(create);
  static ResolveApprovalResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);
}

class ActiveApproval extends $pb.GeneratedMessage {
  factory ActiveApproval({
    $core.String? key,
    $core.String? sourceIp,
    $core.String? ruleId,
    $core.String? proxyId,
    $core.String? tlsSessionId,
    $core.bool? allowed,
    $2.Timestamp? createdAt,
    $2.Timestamp? expiresAt,
    $fixnum.Int64? bytesIn,
    $fixnum.Int64? bytesOut,
    $fixnum.Int64? blockedCount,
    $core.Iterable<$core.String>? connIds,
    $core.String? geoCountry,
    $core.String? geoCity,
    $core.String? geoIsp,
  }) {
    final result = create();
    if (key != null) result.key = key;
    if (sourceIp != null) result.sourceIp = sourceIp;
    if (ruleId != null) result.ruleId = ruleId;
    if (proxyId != null) result.proxyId = proxyId;
    if (tlsSessionId != null) result.tlsSessionId = tlsSessionId;
    if (allowed != null) result.allowed = allowed;
    if (createdAt != null) result.createdAt = createdAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (bytesIn != null) result.bytesIn = bytesIn;
    if (bytesOut != null) result.bytesOut = bytesOut;
    if (blockedCount != null) result.blockedCount = blockedCount;
    if (connIds != null) result.connIds.addAll(connIds);
    if (geoCountry != null) result.geoCountry = geoCountry;
    if (geoCity != null) result.geoCity = geoCity;
    if (geoIsp != null) result.geoIsp = geoIsp;
    return result;
  }

  ActiveApproval._();

  factory ActiveApproval.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActiveApproval.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActiveApproval',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOS(2, _omitFieldNames ? '' : 'sourceIp')
    ..aOS(3, _omitFieldNames ? '' : 'ruleId')
    ..aOS(4, _omitFieldNames ? '' : 'proxyId')
    ..aOS(5, _omitFieldNames ? '' : 'tlsSessionId')
    ..aOB(6, _omitFieldNames ? '' : 'allowed')
    ..aOM<$2.Timestamp>(7, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(8, _omitFieldNames ? '' : 'expiresAt',
        subBuilder: $2.Timestamp.create)
    ..aInt64(9, _omitFieldNames ? '' : 'bytesIn')
    ..aInt64(10, _omitFieldNames ? '' : 'bytesOut')
    ..aInt64(11, _omitFieldNames ? '' : 'blockedCount')
    ..pPS(12, _omitFieldNames ? '' : 'connIds')
    ..aOS(13, _omitFieldNames ? '' : 'geoCountry')
    ..aOS(14, _omitFieldNames ? '' : 'geoCity')
    ..aOS(15, _omitFieldNames ? '' : 'geoIsp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActiveApproval clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActiveApproval copyWith(void Function(ActiveApproval) updates) =>
      super.copyWith((message) => updates(message as ActiveApproval))
          as ActiveApproval;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActiveApproval create() => ActiveApproval._();
  @$core.override
  ActiveApproval createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ActiveApproval getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActiveApproval>(create);
  static ActiveApproval? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sourceIp => $_getSZ(1);
  @$pb.TagNumber(2)
  set sourceIp($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSourceIp() => $_has(1);
  @$pb.TagNumber(2)
  void clearSourceIp() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get ruleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ruleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRuleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRuleId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get proxyId => $_getSZ(3);
  @$pb.TagNumber(4)
  set proxyId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProxyId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProxyId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get tlsSessionId => $_getSZ(4);
  @$pb.TagNumber(5)
  set tlsSessionId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTlsSessionId() => $_has(4);
  @$pb.TagNumber(5)
  void clearTlsSessionId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get allowed => $_getBF(5);
  @$pb.TagNumber(6)
  set allowed($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAllowed() => $_has(5);
  @$pb.TagNumber(6)
  void clearAllowed() => $_clearField(6);

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
  $fixnum.Int64 get bytesIn => $_getI64(8);
  @$pb.TagNumber(9)
  set bytesIn($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasBytesIn() => $_has(8);
  @$pb.TagNumber(9)
  void clearBytesIn() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get bytesOut => $_getI64(9);
  @$pb.TagNumber(10)
  set bytesOut($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasBytesOut() => $_has(9);
  @$pb.TagNumber(10)
  void clearBytesOut() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get blockedCount => $_getI64(10);
  @$pb.TagNumber(11)
  set blockedCount($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasBlockedCount() => $_has(10);
  @$pb.TagNumber(11)
  void clearBlockedCount() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<$core.String> get connIds => $_getList(11);

  @$pb.TagNumber(13)
  $core.String get geoCountry => $_getSZ(12);
  @$pb.TagNumber(13)
  set geoCountry($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasGeoCountry() => $_has(12);
  @$pb.TagNumber(13)
  void clearGeoCountry() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get geoCity => $_getSZ(13);
  @$pb.TagNumber(14)
  set geoCity($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasGeoCity() => $_has(13);
  @$pb.TagNumber(14)
  void clearGeoCity() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get geoIsp => $_getSZ(14);
  @$pb.TagNumber(15)
  set geoIsp($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasGeoIsp() => $_has(14);
  @$pb.TagNumber(15)
  void clearGeoIsp() => $_clearField(15);
}

class ListActiveApprovalsRequest extends $pb.GeneratedMessage {
  factory ListActiveApprovalsRequest({
    $core.String? proxyId,
    $core.String? sourceIp,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (sourceIp != null) result.sourceIp = sourceIp;
    return result;
  }

  ListActiveApprovalsRequest._();

  factory ListActiveApprovalsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListActiveApprovalsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListActiveApprovalsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'sourceIp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActiveApprovalsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActiveApprovalsRequest copyWith(
          void Function(ListActiveApprovalsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ListActiveApprovalsRequest))
          as ListActiveApprovalsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListActiveApprovalsRequest create() => ListActiveApprovalsRequest._();
  @$core.override
  ListActiveApprovalsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListActiveApprovalsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListActiveApprovalsRequest>(create);
  static ListActiveApprovalsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sourceIp => $_getSZ(1);
  @$pb.TagNumber(2)
  set sourceIp($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSourceIp() => $_has(1);
  @$pb.TagNumber(2)
  void clearSourceIp() => $_clearField(2);
}

class ListActiveApprovalsResponse extends $pb.GeneratedMessage {
  factory ListActiveApprovalsResponse({
    $core.Iterable<ActiveApproval>? approvals,
  }) {
    final result = create();
    if (approvals != null) result.approvals.addAll(approvals);
    return result;
  }

  ListActiveApprovalsResponse._();

  factory ListActiveApprovalsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListActiveApprovalsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListActiveApprovalsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..pPM<ActiveApproval>(1, _omitFieldNames ? '' : 'approvals',
        subBuilder: ActiveApproval.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActiveApprovalsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActiveApprovalsResponse copyWith(
          void Function(ListActiveApprovalsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListActiveApprovalsResponse))
          as ListActiveApprovalsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListActiveApprovalsResponse create() =>
      ListActiveApprovalsResponse._();
  @$core.override
  ListActiveApprovalsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListActiveApprovalsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListActiveApprovalsResponse>(create);
  static ListActiveApprovalsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ActiveApproval> get approvals => $_getList(0);
}

class CancelApprovalRequest extends $pb.GeneratedMessage {
  factory CancelApprovalRequest({
    $core.String? key,
    $core.bool? closeConnections,
  }) {
    final result = create();
    if (key != null) result.key = key;
    if (closeConnections != null) result.closeConnections = closeConnections;
    return result;
  }

  CancelApprovalRequest._();

  factory CancelApprovalRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CancelApprovalRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelApprovalRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOB(2, _omitFieldNames ? '' : 'closeConnections')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelApprovalRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelApprovalRequest copyWith(
          void Function(CancelApprovalRequest) updates) =>
      super.copyWith((message) => updates(message as CancelApprovalRequest))
          as CancelApprovalRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelApprovalRequest create() => CancelApprovalRequest._();
  @$core.override
  CancelApprovalRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CancelApprovalRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelApprovalRequest>(create);
  static CancelApprovalRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get closeConnections => $_getBF(1);
  @$pb.TagNumber(2)
  set closeConnections($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCloseConnections() => $_has(1);
  @$pb.TagNumber(2)
  void clearCloseConnections() => $_clearField(2);
}

class CancelApprovalResponse extends $pb.GeneratedMessage {
  factory CancelApprovalResponse({
    $core.bool? success,
    $core.String? errorMessage,
    $core.int? connectionsClosed,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    if (connectionsClosed != null) result.connectionsClosed = connectionsClosed;
    return result;
  }

  CancelApprovalResponse._();

  factory CancelApprovalResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CancelApprovalResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelApprovalResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..aI(3, _omitFieldNames ? '' : 'connectionsClosed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelApprovalResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelApprovalResponse copyWith(
          void Function(CancelApprovalResponse) updates) =>
      super.copyWith((message) => updates(message as CancelApprovalResponse))
          as CancelApprovalResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelApprovalResponse create() => CancelApprovalResponse._();
  @$core.override
  CancelApprovalResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CancelApprovalResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelApprovalResponse>(create);
  static CancelApprovalResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get connectionsClosed => $_getIZ(2);
  @$pb.TagNumber(3)
  set connectionsClosed($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConnectionsClosed() => $_has(2);
  @$pb.TagNumber(3)
  void clearConnectionsClosed() => $_clearField(3);
}

class SendCommandRequest extends $pb.GeneratedMessage {
  factory SendCommandRequest({
    $1.EncryptedPayload? encrypted,
    $core.List<$core.int>? viewerPubkey,
  }) {
    final result = create();
    if (encrypted != null) result.encrypted = encrypted;
    if (viewerPubkey != null) result.viewerPubkey = viewerPubkey;
    return result;
  }

  SendCommandRequest._();

  factory SendCommandRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendCommandRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendCommandRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOM<$1.EncryptedPayload>(1, _omitFieldNames ? '' : 'encrypted',
        subBuilder: $1.EncryptedPayload.create)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'viewerPubkey', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendCommandRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendCommandRequest copyWith(void Function(SendCommandRequest) updates) =>
      super.copyWith((message) => updates(message as SendCommandRequest))
          as SendCommandRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendCommandRequest create() => SendCommandRequest._();
  @$core.override
  SendCommandRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendCommandRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendCommandRequest>(create);
  static SendCommandRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $1.EncryptedPayload get encrypted => $_getN(0);
  @$pb.TagNumber(1)
  set encrypted($1.EncryptedPayload value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEncrypted() => $_has(0);
  @$pb.TagNumber(1)
  void clearEncrypted() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.EncryptedPayload ensureEncrypted() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get viewerPubkey => $_getN(1);
  @$pb.TagNumber(2)
  set viewerPubkey($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasViewerPubkey() => $_has(1);
  @$pb.TagNumber(2)
  void clearViewerPubkey() => $_clearField(2);
}

class SendCommandResponse extends $pb.GeneratedMessage {
  factory SendCommandResponse({
    $1.EncryptedPayload? encrypted,
    $core.String? status,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (encrypted != null) result.encrypted = encrypted;
    if (status != null) result.status = status;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  SendCommandResponse._();

  factory SendCommandResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendCommandResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendCommandResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.proxy'),
      createEmptyInstance: create)
    ..aOM<$1.EncryptedPayload>(1, _omitFieldNames ? '' : 'encrypted',
        subBuilder: $1.EncryptedPayload.create)
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aOS(3, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendCommandResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendCommandResponse copyWith(void Function(SendCommandResponse) updates) =>
      super.copyWith((message) => updates(message as SendCommandResponse))
          as SendCommandResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendCommandResponse create() => SendCommandResponse._();
  @$core.override
  SendCommandResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendCommandResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendCommandResponse>(create);
  static SendCommandResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.EncryptedPayload get encrypted => $_getN(0);
  @$pb.TagNumber(1)
  set encrypted($1.EncryptedPayload value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEncrypted() => $_has(0);
  @$pb.TagNumber(1)
  void clearEncrypted() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.EncryptedPayload ensureEncrypted() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get errorMessage => $_getSZ(2);
  @$pb.TagNumber(3)
  set errorMessage($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasErrorMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrorMessage() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
