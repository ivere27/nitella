// This is a generated file - do not edit.
//
// Generated from local/nitella_local.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/field_mask.pb.dart'
    as $4;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $3;

import '../common/common.pb.dart' as $5;
import '../proxy/proxy.pb.dart' as $2;
import 'nitella_local.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'nitella_local.pbenum.dart';

class InitializeRequest extends $pb.GeneratedMessage {
  factory InitializeRequest({
    $core.String? dataDir,
    $core.String? cacheDir,
    $core.String? hubAddress,
    $core.bool? debugMode,
  }) {
    final result = create();
    if (dataDir != null) result.dataDir = dataDir;
    if (cacheDir != null) result.cacheDir = cacheDir;
    if (hubAddress != null) result.hubAddress = hubAddress;
    if (debugMode != null) result.debugMode = debugMode;
    return result;
  }

  InitializeRequest._();

  factory InitializeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InitializeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InitializeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'dataDir')
    ..aOS(2, _omitFieldNames ? '' : 'cacheDir')
    ..aOS(3, _omitFieldNames ? '' : 'hubAddress')
    ..aOB(4, _omitFieldNames ? '' : 'debugMode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitializeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitializeRequest copyWith(void Function(InitializeRequest) updates) =>
      super.copyWith((message) => updates(message as InitializeRequest))
          as InitializeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InitializeRequest create() => InitializeRequest._();
  @$core.override
  InitializeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InitializeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InitializeRequest>(create);
  static InitializeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dataDir => $_getSZ(0);
  @$pb.TagNumber(1)
  set dataDir($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDataDir() => $_has(0);
  @$pb.TagNumber(1)
  void clearDataDir() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cacheDir => $_getSZ(1);
  @$pb.TagNumber(2)
  set cacheDir($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCacheDir() => $_has(1);
  @$pb.TagNumber(2)
  void clearCacheDir() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get hubAddress => $_getSZ(2);
  @$pb.TagNumber(3)
  set hubAddress($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHubAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearHubAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get debugMode => $_getBF(3);
  @$pb.TagNumber(4)
  set debugMode($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDebugMode() => $_has(3);
  @$pb.TagNumber(4)
  void clearDebugMode() => $_clearField(4);
}

class InitializeResponse extends $pb.GeneratedMessage {
  factory InitializeResponse({
    $core.bool? success,
    $core.String? error,
    $core.bool? identityExists,
    $core.bool? identityLocked,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (identityExists != null) result.identityExists = identityExists;
    if (identityLocked != null) result.identityLocked = identityLocked;
    return result;
  }

  InitializeResponse._();

  factory InitializeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InitializeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InitializeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOB(3, _omitFieldNames ? '' : 'identityExists')
    ..aOB(4, _omitFieldNames ? '' : 'identityLocked')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitializeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitializeResponse copyWith(void Function(InitializeResponse) updates) =>
      super.copyWith((message) => updates(message as InitializeResponse))
          as InitializeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InitializeResponse create() => InitializeResponse._();
  @$core.override
  InitializeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InitializeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InitializeResponse>(create);
  static InitializeResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.bool get identityExists => $_getBF(2);
  @$pb.TagNumber(3)
  set identityExists($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIdentityExists() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentityExists() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get identityLocked => $_getBF(3);
  @$pb.TagNumber(4)
  set identityLocked($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIdentityLocked() => $_has(3);
  @$pb.TagNumber(4)
  void clearIdentityLocked() => $_clearField(4);
}

class BootstrapStateResponse extends $pb.GeneratedMessage {
  factory BootstrapStateResponse({
    BootstrapStage? stage,
    $core.bool? identityExists,
    $core.bool? identityLocked,
    $core.bool? requireBiometric,
  }) {
    final result = create();
    if (stage != null) result.stage = stage;
    if (identityExists != null) result.identityExists = identityExists;
    if (identityLocked != null) result.identityLocked = identityLocked;
    if (requireBiometric != null) result.requireBiometric = requireBiometric;
    return result;
  }

  BootstrapStateResponse._();

  factory BootstrapStateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BootstrapStateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BootstrapStateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aE<BootstrapStage>(1, _omitFieldNames ? '' : 'stage',
        enumValues: BootstrapStage.values)
    ..aOB(2, _omitFieldNames ? '' : 'identityExists')
    ..aOB(3, _omitFieldNames ? '' : 'identityLocked')
    ..aOB(4, _omitFieldNames ? '' : 'requireBiometric')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BootstrapStateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BootstrapStateResponse copyWith(
          void Function(BootstrapStateResponse) updates) =>
      super.copyWith((message) => updates(message as BootstrapStateResponse))
          as BootstrapStateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BootstrapStateResponse create() => BootstrapStateResponse._();
  @$core.override
  BootstrapStateResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BootstrapStateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BootstrapStateResponse>(create);
  static BootstrapStateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BootstrapStage get stage => $_getN(0);
  @$pb.TagNumber(1)
  set stage(BootstrapStage value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStage() => $_has(0);
  @$pb.TagNumber(1)
  void clearStage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get identityExists => $_getBF(1);
  @$pb.TagNumber(2)
  set identityExists($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIdentityExists() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentityExists() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get identityLocked => $_getBF(2);
  @$pb.TagNumber(3)
  set identityLocked($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIdentityLocked() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentityLocked() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get requireBiometric => $_getBF(3);
  @$pb.TagNumber(4)
  set requireBiometric($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRequireBiometric() => $_has(3);
  @$pb.TagNumber(4)
  void clearRequireBiometric() => $_clearField(4);
}

class IdentityInfo extends $pb.GeneratedMessage {
  factory IdentityInfo({
    $core.bool? exists,
    $core.bool? locked,
    $core.String? fingerprint,
    $core.String? emojiHash,
    $core.String? rootCertPem,
    $3.Timestamp? createdAt,
    $core.int? pairedNodes,
  }) {
    final result = create();
    if (exists != null) result.exists = exists;
    if (locked != null) result.locked = locked;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (emojiHash != null) result.emojiHash = emojiHash;
    if (rootCertPem != null) result.rootCertPem = rootCertPem;
    if (createdAt != null) result.createdAt = createdAt;
    if (pairedNodes != null) result.pairedNodes = pairedNodes;
    return result;
  }

  IdentityInfo._();

  factory IdentityInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IdentityInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IdentityInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'exists')
    ..aOB(2, _omitFieldNames ? '' : 'locked')
    ..aOS(3, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(4, _omitFieldNames ? '' : 'emojiHash')
    ..aOS(5, _omitFieldNames ? '' : 'rootCertPem')
    ..aOM<$3.Timestamp>(6, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $3.Timestamp.create)
    ..aI(7, _omitFieldNames ? '' : 'pairedNodes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdentityInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdentityInfo copyWith(void Function(IdentityInfo) updates) =>
      super.copyWith((message) => updates(message as IdentityInfo))
          as IdentityInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IdentityInfo create() => IdentityInfo._();
  @$core.override
  IdentityInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IdentityInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IdentityInfo>(create);
  static IdentityInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get exists => $_getBF(0);
  @$pb.TagNumber(1)
  set exists($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasExists() => $_has(0);
  @$pb.TagNumber(1)
  void clearExists() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get locked => $_getBF(1);
  @$pb.TagNumber(2)
  set locked($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLocked() => $_has(1);
  @$pb.TagNumber(2)
  void clearLocked() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fingerprint => $_getSZ(2);
  @$pb.TagNumber(3)
  set fingerprint($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFingerprint() => $_has(2);
  @$pb.TagNumber(3)
  void clearFingerprint() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get emojiHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set emojiHash($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEmojiHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmojiHash() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get rootCertPem => $_getSZ(4);
  @$pb.TagNumber(5)
  set rootCertPem($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRootCertPem() => $_has(4);
  @$pb.TagNumber(5)
  void clearRootCertPem() => $_clearField(5);

  @$pb.TagNumber(6)
  $3.Timestamp get createdAt => $_getN(5);
  @$pb.TagNumber(6)
  set createdAt($3.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $3.Timestamp ensureCreatedAt() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.int get pairedNodes => $_getIZ(6);
  @$pb.TagNumber(7)
  set pairedNodes($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPairedNodes() => $_has(6);
  @$pb.TagNumber(7)
  void clearPairedNodes() => $_clearField(7);
}

class CreateIdentityRequest extends $pb.GeneratedMessage {
  factory CreateIdentityRequest({
    $core.String? passphrase,
    $core.String? commonName,
    $core.String? organization,
    $core.bool? allowWeakPassphrase,
  }) {
    final result = create();
    if (passphrase != null) result.passphrase = passphrase;
    if (commonName != null) result.commonName = commonName;
    if (organization != null) result.organization = organization;
    if (allowWeakPassphrase != null)
      result.allowWeakPassphrase = allowWeakPassphrase;
    return result;
  }

  CreateIdentityRequest._();

  factory CreateIdentityRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateIdentityRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateIdentityRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'passphrase')
    ..aOS(2, _omitFieldNames ? '' : 'commonName')
    ..aOS(3, _omitFieldNames ? '' : 'organization')
    ..aOB(4, _omitFieldNames ? '' : 'allowWeakPassphrase')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateIdentityRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateIdentityRequest copyWith(
          void Function(CreateIdentityRequest) updates) =>
      super.copyWith((message) => updates(message as CreateIdentityRequest))
          as CreateIdentityRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateIdentityRequest create() => CreateIdentityRequest._();
  @$core.override
  CreateIdentityRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateIdentityRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateIdentityRequest>(create);
  static CreateIdentityRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get passphrase => $_getSZ(0);
  @$pb.TagNumber(1)
  set passphrase($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPassphrase() => $_has(0);
  @$pb.TagNumber(1)
  void clearPassphrase() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commonName => $_getSZ(1);
  @$pb.TagNumber(2)
  set commonName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommonName() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommonName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get organization => $_getSZ(2);
  @$pb.TagNumber(3)
  set organization($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOrganization() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrganization() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get allowWeakPassphrase => $_getBF(3);
  @$pb.TagNumber(4)
  set allowWeakPassphrase($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAllowWeakPassphrase() => $_has(3);
  @$pb.TagNumber(4)
  void clearAllowWeakPassphrase() => $_clearField(4);
}

class CreateIdentityResponse extends $pb.GeneratedMessage {
  factory CreateIdentityResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? mnemonic,
    IdentityInfo? identity,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (mnemonic != null) result.mnemonic = mnemonic;
    if (identity != null) result.identity = identity;
    return result;
  }

  CreateIdentityResponse._();

  factory CreateIdentityResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateIdentityResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateIdentityResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'mnemonic')
    ..aOM<IdentityInfo>(4, _omitFieldNames ? '' : 'identity',
        subBuilder: IdentityInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateIdentityResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateIdentityResponse copyWith(
          void Function(CreateIdentityResponse) updates) =>
      super.copyWith((message) => updates(message as CreateIdentityResponse))
          as CreateIdentityResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateIdentityResponse create() => CreateIdentityResponse._();
  @$core.override
  CreateIdentityResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateIdentityResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateIdentityResponse>(create);
  static CreateIdentityResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get mnemonic => $_getSZ(2);
  @$pb.TagNumber(3)
  set mnemonic($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMnemonic() => $_has(2);
  @$pb.TagNumber(3)
  void clearMnemonic() => $_clearField(3);

  @$pb.TagNumber(4)
  IdentityInfo get identity => $_getN(3);
  @$pb.TagNumber(4)
  set identity(IdentityInfo value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasIdentity() => $_has(3);
  @$pb.TagNumber(4)
  void clearIdentity() => $_clearField(4);
  @$pb.TagNumber(4)
  IdentityInfo ensureIdentity() => $_ensure(3);
}

class RestoreIdentityRequest extends $pb.GeneratedMessage {
  factory RestoreIdentityRequest({
    $core.String? mnemonic,
    $core.String? passphrase,
    $core.String? commonName,
    $core.String? organization,
    $core.bool? allowWeakPassphrase,
  }) {
    final result = create();
    if (mnemonic != null) result.mnemonic = mnemonic;
    if (passphrase != null) result.passphrase = passphrase;
    if (commonName != null) result.commonName = commonName;
    if (organization != null) result.organization = organization;
    if (allowWeakPassphrase != null)
      result.allowWeakPassphrase = allowWeakPassphrase;
    return result;
  }

  RestoreIdentityRequest._();

  factory RestoreIdentityRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RestoreIdentityRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RestoreIdentityRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mnemonic')
    ..aOS(2, _omitFieldNames ? '' : 'passphrase')
    ..aOS(3, _omitFieldNames ? '' : 'commonName')
    ..aOS(4, _omitFieldNames ? '' : 'organization')
    ..aOB(5, _omitFieldNames ? '' : 'allowWeakPassphrase')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreIdentityRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreIdentityRequest copyWith(
          void Function(RestoreIdentityRequest) updates) =>
      super.copyWith((message) => updates(message as RestoreIdentityRequest))
          as RestoreIdentityRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RestoreIdentityRequest create() => RestoreIdentityRequest._();
  @$core.override
  RestoreIdentityRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RestoreIdentityRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RestoreIdentityRequest>(create);
  static RestoreIdentityRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mnemonic => $_getSZ(0);
  @$pb.TagNumber(1)
  set mnemonic($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMnemonic() => $_has(0);
  @$pb.TagNumber(1)
  void clearMnemonic() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get passphrase => $_getSZ(1);
  @$pb.TagNumber(2)
  set passphrase($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassphrase() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassphrase() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get commonName => $_getSZ(2);
  @$pb.TagNumber(3)
  set commonName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCommonName() => $_has(2);
  @$pb.TagNumber(3)
  void clearCommonName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get organization => $_getSZ(3);
  @$pb.TagNumber(4)
  set organization($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOrganization() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrganization() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get allowWeakPassphrase => $_getBF(4);
  @$pb.TagNumber(5)
  set allowWeakPassphrase($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAllowWeakPassphrase() => $_has(4);
  @$pb.TagNumber(5)
  void clearAllowWeakPassphrase() => $_clearField(5);
}

class RestoreIdentityResponse extends $pb.GeneratedMessage {
  factory RestoreIdentityResponse({
    $core.bool? success,
    $core.String? error,
    IdentityInfo? identity,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (identity != null) result.identity = identity;
    return result;
  }

  RestoreIdentityResponse._();

  factory RestoreIdentityResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RestoreIdentityResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RestoreIdentityResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOM<IdentityInfo>(3, _omitFieldNames ? '' : 'identity',
        subBuilder: IdentityInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreIdentityResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreIdentityResponse copyWith(
          void Function(RestoreIdentityResponse) updates) =>
      super.copyWith((message) => updates(message as RestoreIdentityResponse))
          as RestoreIdentityResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RestoreIdentityResponse create() => RestoreIdentityResponse._();
  @$core.override
  RestoreIdentityResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RestoreIdentityResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RestoreIdentityResponse>(create);
  static RestoreIdentityResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  IdentityInfo get identity => $_getN(2);
  @$pb.TagNumber(3)
  set identity(IdentityInfo value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasIdentity() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentity() => $_clearField(3);
  @$pb.TagNumber(3)
  IdentityInfo ensureIdentity() => $_ensure(2);
}

class ImportIdentityRequest extends $pb.GeneratedMessage {
  factory ImportIdentityRequest({
    $core.String? certPem,
    $core.String? keyPem,
    $core.String? keyPassphrase,
  }) {
    final result = create();
    if (certPem != null) result.certPem = certPem;
    if (keyPem != null) result.keyPem = keyPem;
    if (keyPassphrase != null) result.keyPassphrase = keyPassphrase;
    return result;
  }

  ImportIdentityRequest._();

  factory ImportIdentityRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportIdentityRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportIdentityRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'certPem')
    ..aOS(2, _omitFieldNames ? '' : 'keyPem')
    ..aOS(3, _omitFieldNames ? '' : 'keyPassphrase')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportIdentityRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportIdentityRequest copyWith(
          void Function(ImportIdentityRequest) updates) =>
      super.copyWith((message) => updates(message as ImportIdentityRequest))
          as ImportIdentityRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportIdentityRequest create() => ImportIdentityRequest._();
  @$core.override
  ImportIdentityRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportIdentityRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportIdentityRequest>(create);
  static ImportIdentityRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get certPem => $_getSZ(0);
  @$pb.TagNumber(1)
  set certPem($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCertPem() => $_has(0);
  @$pb.TagNumber(1)
  void clearCertPem() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get keyPem => $_getSZ(1);
  @$pb.TagNumber(2)
  set keyPem($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKeyPem() => $_has(1);
  @$pb.TagNumber(2)
  void clearKeyPem() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get keyPassphrase => $_getSZ(2);
  @$pb.TagNumber(3)
  set keyPassphrase($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKeyPassphrase() => $_has(2);
  @$pb.TagNumber(3)
  void clearKeyPassphrase() => $_clearField(3);
}

class ImportIdentityResponse extends $pb.GeneratedMessage {
  factory ImportIdentityResponse({
    $core.bool? success,
    $core.String? error,
    IdentityInfo? identity,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (identity != null) result.identity = identity;
    return result;
  }

  ImportIdentityResponse._();

  factory ImportIdentityResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportIdentityResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportIdentityResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOM<IdentityInfo>(3, _omitFieldNames ? '' : 'identity',
        subBuilder: IdentityInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportIdentityResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportIdentityResponse copyWith(
          void Function(ImportIdentityResponse) updates) =>
      super.copyWith((message) => updates(message as ImportIdentityResponse))
          as ImportIdentityResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportIdentityResponse create() => ImportIdentityResponse._();
  @$core.override
  ImportIdentityResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportIdentityResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportIdentityResponse>(create);
  static ImportIdentityResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  IdentityInfo get identity => $_getN(2);
  @$pb.TagNumber(3)
  set identity(IdentityInfo value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasIdentity() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentity() => $_clearField(3);
  @$pb.TagNumber(3)
  IdentityInfo ensureIdentity() => $_ensure(2);
}

class UnlockIdentityRequest extends $pb.GeneratedMessage {
  factory UnlockIdentityRequest({
    $core.String? passphrase,
  }) {
    final result = create();
    if (passphrase != null) result.passphrase = passphrase;
    return result;
  }

  UnlockIdentityRequest._();

  factory UnlockIdentityRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnlockIdentityRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnlockIdentityRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'passphrase')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockIdentityRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockIdentityRequest copyWith(
          void Function(UnlockIdentityRequest) updates) =>
      super.copyWith((message) => updates(message as UnlockIdentityRequest))
          as UnlockIdentityRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnlockIdentityRequest create() => UnlockIdentityRequest._();
  @$core.override
  UnlockIdentityRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnlockIdentityRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnlockIdentityRequest>(create);
  static UnlockIdentityRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get passphrase => $_getSZ(0);
  @$pb.TagNumber(1)
  set passphrase($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPassphrase() => $_has(0);
  @$pb.TagNumber(1)
  void clearPassphrase() => $_clearField(1);
}

class UnlockIdentityResponse extends $pb.GeneratedMessage {
  factory UnlockIdentityResponse({
    $core.bool? success,
    $core.String? error,
    IdentityInfo? identity,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (identity != null) result.identity = identity;
    return result;
  }

  UnlockIdentityResponse._();

  factory UnlockIdentityResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnlockIdentityResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnlockIdentityResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOM<IdentityInfo>(3, _omitFieldNames ? '' : 'identity',
        subBuilder: IdentityInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockIdentityResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockIdentityResponse copyWith(
          void Function(UnlockIdentityResponse) updates) =>
      super.copyWith((message) => updates(message as UnlockIdentityResponse))
          as UnlockIdentityResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnlockIdentityResponse create() => UnlockIdentityResponse._();
  @$core.override
  UnlockIdentityResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnlockIdentityResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnlockIdentityResponse>(create);
  static UnlockIdentityResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  IdentityInfo get identity => $_getN(2);
  @$pb.TagNumber(3)
  set identity(IdentityInfo value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasIdentity() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentity() => $_clearField(3);
  @$pb.TagNumber(3)
  IdentityInfo ensureIdentity() => $_ensure(2);
}

class ChangePassphraseRequest extends $pb.GeneratedMessage {
  factory ChangePassphraseRequest({
    $core.String? oldPassphrase,
    $core.String? newPassphrase,
    $core.bool? allowWeakPassphrase,
  }) {
    final result = create();
    if (oldPassphrase != null) result.oldPassphrase = oldPassphrase;
    if (newPassphrase != null) result.newPassphrase = newPassphrase;
    if (allowWeakPassphrase != null)
      result.allowWeakPassphrase = allowWeakPassphrase;
    return result;
  }

  ChangePassphraseRequest._();

  factory ChangePassphraseRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChangePassphraseRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChangePassphraseRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'oldPassphrase')
    ..aOS(2, _omitFieldNames ? '' : 'newPassphrase')
    ..aOB(3, _omitFieldNames ? '' : 'allowWeakPassphrase')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePassphraseRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePassphraseRequest copyWith(
          void Function(ChangePassphraseRequest) updates) =>
      super.copyWith((message) => updates(message as ChangePassphraseRequest))
          as ChangePassphraseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangePassphraseRequest create() => ChangePassphraseRequest._();
  @$core.override
  ChangePassphraseRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChangePassphraseRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChangePassphraseRequest>(create);
  static ChangePassphraseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get oldPassphrase => $_getSZ(0);
  @$pb.TagNumber(1)
  set oldPassphrase($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOldPassphrase() => $_has(0);
  @$pb.TagNumber(1)
  void clearOldPassphrase() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get newPassphrase => $_getSZ(1);
  @$pb.TagNumber(2)
  set newPassphrase($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewPassphrase() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewPassphrase() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get allowWeakPassphrase => $_getBF(2);
  @$pb.TagNumber(3)
  set allowWeakPassphrase($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAllowWeakPassphrase() => $_has(2);
  @$pb.TagNumber(3)
  void clearAllowWeakPassphrase() => $_clearField(3);
}

class EvaluatePassphraseRequest extends $pb.GeneratedMessage {
  factory EvaluatePassphraseRequest({
    $core.String? passphrase,
  }) {
    final result = create();
    if (passphrase != null) result.passphrase = passphrase;
    return result;
  }

  EvaluatePassphraseRequest._();

  factory EvaluatePassphraseRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EvaluatePassphraseRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EvaluatePassphraseRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'passphrase')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EvaluatePassphraseRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EvaluatePassphraseRequest copyWith(
          void Function(EvaluatePassphraseRequest) updates) =>
      super.copyWith((message) => updates(message as EvaluatePassphraseRequest))
          as EvaluatePassphraseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EvaluatePassphraseRequest create() => EvaluatePassphraseRequest._();
  @$core.override
  EvaluatePassphraseRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EvaluatePassphraseRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EvaluatePassphraseRequest>(create);
  static EvaluatePassphraseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get passphrase => $_getSZ(0);
  @$pb.TagNumber(1)
  set passphrase($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPassphrase() => $_has(0);
  @$pb.TagNumber(1)
  void clearPassphrase() => $_clearField(1);
}

class EvaluatePassphraseResponse extends $pb.GeneratedMessage {
  factory EvaluatePassphraseResponse({
    PassphraseStrength? strength,
    $core.double? entropy,
    $core.String? message,
    $core.String? crackTime,
    $core.String? gpuScenario,
    $core.bool? shouldWarn,
    $core.String? report,
  }) {
    final result = create();
    if (strength != null) result.strength = strength;
    if (entropy != null) result.entropy = entropy;
    if (message != null) result.message = message;
    if (crackTime != null) result.crackTime = crackTime;
    if (gpuScenario != null) result.gpuScenario = gpuScenario;
    if (shouldWarn != null) result.shouldWarn = shouldWarn;
    if (report != null) result.report = report;
    return result;
  }

  EvaluatePassphraseResponse._();

  factory EvaluatePassphraseResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EvaluatePassphraseResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EvaluatePassphraseResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aE<PassphraseStrength>(1, _omitFieldNames ? '' : 'strength',
        enumValues: PassphraseStrength.values)
    ..aD(2, _omitFieldNames ? '' : 'entropy')
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..aOS(4, _omitFieldNames ? '' : 'crackTime')
    ..aOS(5, _omitFieldNames ? '' : 'gpuScenario')
    ..aOB(6, _omitFieldNames ? '' : 'shouldWarn')
    ..aOS(7, _omitFieldNames ? '' : 'report')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EvaluatePassphraseResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EvaluatePassphraseResponse copyWith(
          void Function(EvaluatePassphraseResponse) updates) =>
      super.copyWith(
              (message) => updates(message as EvaluatePassphraseResponse))
          as EvaluatePassphraseResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EvaluatePassphraseResponse create() => EvaluatePassphraseResponse._();
  @$core.override
  EvaluatePassphraseResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EvaluatePassphraseResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EvaluatePassphraseResponse>(create);
  static EvaluatePassphraseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PassphraseStrength get strength => $_getN(0);
  @$pb.TagNumber(1)
  set strength(PassphraseStrength value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStrength() => $_has(0);
  @$pb.TagNumber(1)
  void clearStrength() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get entropy => $_getN(1);
  @$pb.TagNumber(2)
  set entropy($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEntropy() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntropy() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get crackTime => $_getSZ(3);
  @$pb.TagNumber(4)
  set crackTime($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCrackTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearCrackTime() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get gpuScenario => $_getSZ(4);
  @$pb.TagNumber(5)
  set gpuScenario($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasGpuScenario() => $_has(4);
  @$pb.TagNumber(5)
  void clearGpuScenario() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get shouldWarn => $_getBF(5);
  @$pb.TagNumber(6)
  set shouldWarn($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasShouldWarn() => $_has(5);
  @$pb.TagNumber(6)
  void clearShouldWarn() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get report => $_getSZ(6);
  @$pb.TagNumber(7)
  set report($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasReport() => $_has(6);
  @$pb.TagNumber(7)
  void clearReport() => $_clearField(7);
}

class NodeInfo extends $pb.GeneratedMessage {
  factory NodeInfo({
    $core.String? nodeId,
    $core.String? name,
    $core.String? fingerprint,
    $core.String? emojiHash,
    $core.bool? online,
    $3.Timestamp? lastSeen,
    $3.Timestamp? pairedAt,
    $core.Iterable<$core.String>? tags,
    NodeMetrics? metrics,
    $core.String? version,
    $core.String? os,
    $core.bool? pinned,
    $core.bool? alertsEnabled,
    $core.int? proxyCount,
    NodeConnectionType? connType,
    $core.String? directAddress,
    $core.String? directToken,
    $core.String? directCaPem,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (name != null) result.name = name;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (emojiHash != null) result.emojiHash = emojiHash;
    if (online != null) result.online = online;
    if (lastSeen != null) result.lastSeen = lastSeen;
    if (pairedAt != null) result.pairedAt = pairedAt;
    if (tags != null) result.tags.addAll(tags);
    if (metrics != null) result.metrics = metrics;
    if (version != null) result.version = version;
    if (os != null) result.os = os;
    if (pinned != null) result.pinned = pinned;
    if (alertsEnabled != null) result.alertsEnabled = alertsEnabled;
    if (proxyCount != null) result.proxyCount = proxyCount;
    if (connType != null) result.connType = connType;
    if (directAddress != null) result.directAddress = directAddress;
    if (directToken != null) result.directToken = directToken;
    if (directCaPem != null) result.directCaPem = directCaPem;
    return result;
  }

  NodeInfo._();

  factory NodeInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NodeInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(4, _omitFieldNames ? '' : 'emojiHash')
    ..aOB(5, _omitFieldNames ? '' : 'online')
    ..aOM<$3.Timestamp>(6, _omitFieldNames ? '' : 'lastSeen',
        subBuilder: $3.Timestamp.create)
    ..aOM<$3.Timestamp>(7, _omitFieldNames ? '' : 'pairedAt',
        subBuilder: $3.Timestamp.create)
    ..pPS(8, _omitFieldNames ? '' : 'tags')
    ..aOM<NodeMetrics>(9, _omitFieldNames ? '' : 'metrics',
        subBuilder: NodeMetrics.create)
    ..aOS(10, _omitFieldNames ? '' : 'version')
    ..aOS(11, _omitFieldNames ? '' : 'os')
    ..aOB(12, _omitFieldNames ? '' : 'pinned')
    ..aOB(13, _omitFieldNames ? '' : 'alertsEnabled')
    ..aI(14, _omitFieldNames ? '' : 'proxyCount')
    ..aE<NodeConnectionType>(15, _omitFieldNames ? '' : 'connType',
        enumValues: NodeConnectionType.values)
    ..aOS(16, _omitFieldNames ? '' : 'directAddress')
    ..aOS(17, _omitFieldNames ? '' : 'directToken')
    ..aOS(18, _omitFieldNames ? '' : 'directCaPem')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeInfo copyWith(void Function(NodeInfo) updates) =>
      super.copyWith((message) => updates(message as NodeInfo)) as NodeInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NodeInfo create() => NodeInfo._();
  @$core.override
  NodeInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NodeInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NodeInfo>(create);
  static NodeInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fingerprint => $_getSZ(2);
  @$pb.TagNumber(3)
  set fingerprint($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFingerprint() => $_has(2);
  @$pb.TagNumber(3)
  void clearFingerprint() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get emojiHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set emojiHash($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEmojiHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmojiHash() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get online => $_getBF(4);
  @$pb.TagNumber(5)
  set online($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOnline() => $_has(4);
  @$pb.TagNumber(5)
  void clearOnline() => $_clearField(5);

  @$pb.TagNumber(6)
  $3.Timestamp get lastSeen => $_getN(5);
  @$pb.TagNumber(6)
  set lastSeen($3.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasLastSeen() => $_has(5);
  @$pb.TagNumber(6)
  void clearLastSeen() => $_clearField(6);
  @$pb.TagNumber(6)
  $3.Timestamp ensureLastSeen() => $_ensure(5);

  @$pb.TagNumber(7)
  $3.Timestamp get pairedAt => $_getN(6);
  @$pb.TagNumber(7)
  set pairedAt($3.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasPairedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearPairedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $3.Timestamp ensurePairedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get tags => $_getList(7);

  @$pb.TagNumber(9)
  NodeMetrics get metrics => $_getN(8);
  @$pb.TagNumber(9)
  set metrics(NodeMetrics value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasMetrics() => $_has(8);
  @$pb.TagNumber(9)
  void clearMetrics() => $_clearField(9);
  @$pb.TagNumber(9)
  NodeMetrics ensureMetrics() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.String get version => $_getSZ(9);
  @$pb.TagNumber(10)
  set version($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasVersion() => $_has(9);
  @$pb.TagNumber(10)
  void clearVersion() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get os => $_getSZ(10);
  @$pb.TagNumber(11)
  set os($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasOs() => $_has(10);
  @$pb.TagNumber(11)
  void clearOs() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get pinned => $_getBF(11);
  @$pb.TagNumber(12)
  set pinned($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPinned() => $_has(11);
  @$pb.TagNumber(12)
  void clearPinned() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get alertsEnabled => $_getBF(12);
  @$pb.TagNumber(13)
  set alertsEnabled($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasAlertsEnabled() => $_has(12);
  @$pb.TagNumber(13)
  void clearAlertsEnabled() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get proxyCount => $_getIZ(13);
  @$pb.TagNumber(14)
  set proxyCount($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasProxyCount() => $_has(13);
  @$pb.TagNumber(14)
  void clearProxyCount() => $_clearField(14);

  /// Direct connection fields (only for NODE_CONNECTION_TYPE_DIRECT)
  @$pb.TagNumber(15)
  NodeConnectionType get connType => $_getN(14);
  @$pb.TagNumber(15)
  set connType(NodeConnectionType value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasConnType() => $_has(14);
  @$pb.TagNumber(15)
  void clearConnType() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get directAddress => $_getSZ(15);
  @$pb.TagNumber(16)
  set directAddress($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasDirectAddress() => $_has(15);
  @$pb.TagNumber(16)
  void clearDirectAddress() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get directToken => $_getSZ(16);
  @$pb.TagNumber(17)
  set directToken($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasDirectToken() => $_has(16);
  @$pb.TagNumber(17)
  void clearDirectToken() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get directCaPem => $_getSZ(17);
  @$pb.TagNumber(18)
  set directCaPem($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasDirectCaPem() => $_has(17);
  @$pb.TagNumber(18)
  void clearDirectCaPem() => $_clearField(18);
}

class NodeMetrics extends $pb.GeneratedMessage {
  factory NodeMetrics({
    $fixnum.Int64? activeConnections,
    $fixnum.Int64? totalConnections,
    $fixnum.Int64? bytesIn,
    $fixnum.Int64? bytesOut,
    $fixnum.Int64? blockedTotal,
    $core.int? proxyCount,
    $fixnum.Int64? uptimeSeconds,
  }) {
    final result = create();
    if (activeConnections != null) result.activeConnections = activeConnections;
    if (totalConnections != null) result.totalConnections = totalConnections;
    if (bytesIn != null) result.bytesIn = bytesIn;
    if (bytesOut != null) result.bytesOut = bytesOut;
    if (blockedTotal != null) result.blockedTotal = blockedTotal;
    if (proxyCount != null) result.proxyCount = proxyCount;
    if (uptimeSeconds != null) result.uptimeSeconds = uptimeSeconds;
    return result;
  }

  NodeMetrics._();

  factory NodeMetrics.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NodeMetrics.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeMetrics',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'activeConnections')
    ..aInt64(2, _omitFieldNames ? '' : 'totalConnections')
    ..aInt64(3, _omitFieldNames ? '' : 'bytesIn')
    ..aInt64(4, _omitFieldNames ? '' : 'bytesOut')
    ..aInt64(5, _omitFieldNames ? '' : 'blockedTotal')
    ..aI(6, _omitFieldNames ? '' : 'proxyCount')
    ..aInt64(7, _omitFieldNames ? '' : 'uptimeSeconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeMetrics clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeMetrics copyWith(void Function(NodeMetrics) updates) =>
      super.copyWith((message) => updates(message as NodeMetrics))
          as NodeMetrics;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NodeMetrics create() => NodeMetrics._();
  @$core.override
  NodeMetrics createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NodeMetrics getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NodeMetrics>(create);
  static NodeMetrics? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get activeConnections => $_getI64(0);
  @$pb.TagNumber(1)
  set activeConnections($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasActiveConnections() => $_has(0);
  @$pb.TagNumber(1)
  void clearActiveConnections() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalConnections => $_getI64(1);
  @$pb.TagNumber(2)
  set totalConnections($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalConnections() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalConnections() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get bytesIn => $_getI64(2);
  @$pb.TagNumber(3)
  set bytesIn($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBytesIn() => $_has(2);
  @$pb.TagNumber(3)
  void clearBytesIn() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get bytesOut => $_getI64(3);
  @$pb.TagNumber(4)
  set bytesOut($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBytesOut() => $_has(3);
  @$pb.TagNumber(4)
  void clearBytesOut() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get blockedTotal => $_getI64(4);
  @$pb.TagNumber(5)
  set blockedTotal($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBlockedTotal() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlockedTotal() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get proxyCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set proxyCount($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProxyCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearProxyCount() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get uptimeSeconds => $_getI64(6);
  @$pb.TagNumber(7)
  set uptimeSeconds($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUptimeSeconds() => $_has(6);
  @$pb.TagNumber(7)
  void clearUptimeSeconds() => $_clearField(7);
}

class ListNodesRequest extends $pb.GeneratedMessage {
  factory ListNodesRequest({
    $core.String? filter,
  }) {
    final result = create();
    if (filter != null) result.filter = filter;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filter')
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
}

class ListNodesResponse extends $pb.GeneratedMessage {
  factory ListNodesResponse({
    $core.Iterable<NodeInfo>? nodes,
    $core.int? totalCount,
    $core.int? onlineCount,
  }) {
    final result = create();
    if (nodes != null) result.nodes.addAll(nodes);
    if (totalCount != null) result.totalCount = totalCount;
    if (onlineCount != null) result.onlineCount = onlineCount;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<NodeInfo>(1, _omitFieldNames ? '' : 'nodes',
        subBuilder: NodeInfo.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..aI(3, _omitFieldNames ? '' : 'onlineCount')
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
  $pb.PbList<NodeInfo> get nodes => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get onlineCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set onlineCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOnlineCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearOnlineCount() => $_clearField(3);
}

class GetNodeRequest extends $pb.GeneratedMessage {
  factory GetNodeRequest({
    $core.String? nodeId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
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
}

class GetNodeDetailSnapshotRequest extends $pb.GeneratedMessage {
  factory GetNodeDetailSnapshotRequest({
    $core.String? nodeId,
    $core.bool? includeRuntimeStatus,
    $core.bool? includeProxies,
    $core.bool? includeRules,
    $core.bool? includeConnectionStats,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (includeRuntimeStatus != null)
      result.includeRuntimeStatus = includeRuntimeStatus;
    if (includeProxies != null) result.includeProxies = includeProxies;
    if (includeRules != null) result.includeRules = includeRules;
    if (includeConnectionStats != null)
      result.includeConnectionStats = includeConnectionStats;
    return result;
  }

  GetNodeDetailSnapshotRequest._();

  factory GetNodeDetailSnapshotRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNodeDetailSnapshotRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNodeDetailSnapshotRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOB(2, _omitFieldNames ? '' : 'includeRuntimeStatus')
    ..aOB(3, _omitFieldNames ? '' : 'includeProxies')
    ..aOB(4, _omitFieldNames ? '' : 'includeRules')
    ..aOB(5, _omitFieldNames ? '' : 'includeConnectionStats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNodeDetailSnapshotRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNodeDetailSnapshotRequest copyWith(
          void Function(GetNodeDetailSnapshotRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetNodeDetailSnapshotRequest))
          as GetNodeDetailSnapshotRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNodeDetailSnapshotRequest create() =>
      GetNodeDetailSnapshotRequest._();
  @$core.override
  GetNodeDetailSnapshotRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNodeDetailSnapshotRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNodeDetailSnapshotRequest>(create);
  static GetNodeDetailSnapshotRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get includeRuntimeStatus => $_getBF(1);
  @$pb.TagNumber(2)
  set includeRuntimeStatus($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIncludeRuntimeStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearIncludeRuntimeStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get includeProxies => $_getBF(2);
  @$pb.TagNumber(3)
  set includeProxies($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIncludeProxies() => $_has(2);
  @$pb.TagNumber(3)
  void clearIncludeProxies() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get includeRules => $_getBF(3);
  @$pb.TagNumber(4)
  set includeRules($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIncludeRules() => $_has(3);
  @$pb.TagNumber(4)
  void clearIncludeRules() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get includeConnectionStats => $_getBF(4);
  @$pb.TagNumber(5)
  set includeConnectionStats($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIncludeConnectionStats() => $_has(4);
  @$pb.TagNumber(5)
  void clearIncludeConnectionStats() => $_clearField(5);
}

class NodeRuntimeStatus extends $pb.GeneratedMessage {
  factory NodeRuntimeStatus({
    $core.String? status,
    $3.Timestamp? lastSeen,
    $core.String? publicIp,
    $core.String? version,
    $core.bool? geoipEnabled,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (lastSeen != null) result.lastSeen = lastSeen;
    if (publicIp != null) result.publicIp = publicIp;
    if (version != null) result.version = version;
    if (geoipEnabled != null) result.geoipEnabled = geoipEnabled;
    return result;
  }

  NodeRuntimeStatus._();

  factory NodeRuntimeStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NodeRuntimeStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeRuntimeStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'status')
    ..aOM<$3.Timestamp>(2, _omitFieldNames ? '' : 'lastSeen',
        subBuilder: $3.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'publicIp')
    ..aOS(4, _omitFieldNames ? '' : 'version')
    ..aOB(5, _omitFieldNames ? '' : 'geoipEnabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeRuntimeStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeRuntimeStatus copyWith(void Function(NodeRuntimeStatus) updates) =>
      super.copyWith((message) => updates(message as NodeRuntimeStatus))
          as NodeRuntimeStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NodeRuntimeStatus create() => NodeRuntimeStatus._();
  @$core.override
  NodeRuntimeStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NodeRuntimeStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NodeRuntimeStatus>(create);
  static NodeRuntimeStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get status => $_getSZ(0);
  @$pb.TagNumber(1)
  set status($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $3.Timestamp get lastSeen => $_getN(1);
  @$pb.TagNumber(2)
  set lastSeen($3.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasLastSeen() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastSeen() => $_clearField(2);
  @$pb.TagNumber(2)
  $3.Timestamp ensureLastSeen() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get publicIp => $_getSZ(2);
  @$pb.TagNumber(3)
  set publicIp($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPublicIp() => $_has(2);
  @$pb.TagNumber(3)
  void clearPublicIp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get version => $_getSZ(3);
  @$pb.TagNumber(4)
  set version($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get geoipEnabled => $_getBF(4);
  @$pb.TagNumber(5)
  set geoipEnabled($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasGeoipEnabled() => $_has(4);
  @$pb.TagNumber(5)
  void clearGeoipEnabled() => $_clearField(5);
}

class NodeDetailSnapshot extends $pb.GeneratedMessage {
  factory NodeDetailSnapshot({
    NodeInfo? node,
    NodeRuntimeStatus? runtimeStatus,
    $core.Iterable<ProxyInfo>? proxies,
    $core.Iterable<$2.Rule>? rules,
    ConnectionStats? connectionStats,
  }) {
    final result = create();
    if (node != null) result.node = node;
    if (runtimeStatus != null) result.runtimeStatus = runtimeStatus;
    if (proxies != null) result.proxies.addAll(proxies);
    if (rules != null) result.rules.addAll(rules);
    if (connectionStats != null) result.connectionStats = connectionStats;
    return result;
  }

  NodeDetailSnapshot._();

  factory NodeDetailSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NodeDetailSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeDetailSnapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOM<NodeInfo>(1, _omitFieldNames ? '' : 'node',
        subBuilder: NodeInfo.create)
    ..aOM<NodeRuntimeStatus>(2, _omitFieldNames ? '' : 'runtimeStatus',
        subBuilder: NodeRuntimeStatus.create)
    ..pPM<ProxyInfo>(3, _omitFieldNames ? '' : 'proxies',
        subBuilder: ProxyInfo.create)
    ..pPM<$2.Rule>(4, _omitFieldNames ? '' : 'rules',
        subBuilder: $2.Rule.create)
    ..aOM<ConnectionStats>(5, _omitFieldNames ? '' : 'connectionStats',
        subBuilder: ConnectionStats.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeDetailSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeDetailSnapshot copyWith(void Function(NodeDetailSnapshot) updates) =>
      super.copyWith((message) => updates(message as NodeDetailSnapshot))
          as NodeDetailSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NodeDetailSnapshot create() => NodeDetailSnapshot._();
  @$core.override
  NodeDetailSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NodeDetailSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NodeDetailSnapshot>(create);
  static NodeDetailSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  NodeInfo get node => $_getN(0);
  @$pb.TagNumber(1)
  set node(NodeInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasNode() => $_has(0);
  @$pb.TagNumber(1)
  void clearNode() => $_clearField(1);
  @$pb.TagNumber(1)
  NodeInfo ensureNode() => $_ensure(0);

  @$pb.TagNumber(2)
  NodeRuntimeStatus get runtimeStatus => $_getN(1);
  @$pb.TagNumber(2)
  set runtimeStatus(NodeRuntimeStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRuntimeStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearRuntimeStatus() => $_clearField(2);
  @$pb.TagNumber(2)
  NodeRuntimeStatus ensureRuntimeStatus() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<ProxyInfo> get proxies => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<$2.Rule> get rules => $_getList(3);

  @$pb.TagNumber(5)
  ConnectionStats get connectionStats => $_getN(4);
  @$pb.TagNumber(5)
  set connectionStats(ConnectionStats value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasConnectionStats() => $_has(4);
  @$pb.TagNumber(5)
  void clearConnectionStats() => $_clearField(5);
  @$pb.TagNumber(5)
  ConnectionStats ensureConnectionStats() => $_ensure(4);
}

class UpdateNodeRequest extends $pb.GeneratedMessage {
  factory UpdateNodeRequest({
    $core.String? nodeId,
    $core.String? name,
    $core.Iterable<$core.String>? tags,
    $core.bool? pinned,
    $core.bool? alertsEnabled,
    $4.FieldMask? updateMask,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (name != null) result.name = name;
    if (tags != null) result.tags.addAll(tags);
    if (pinned != null) result.pinned = pinned;
    if (alertsEnabled != null) result.alertsEnabled = alertsEnabled;
    if (updateMask != null) result.updateMask = updateMask;
    return result;
  }

  UpdateNodeRequest._();

  factory UpdateNodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateNodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateNodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..pPS(3, _omitFieldNames ? '' : 'tags')
    ..aOB(4, _omitFieldNames ? '' : 'pinned')
    ..aOB(5, _omitFieldNames ? '' : 'alertsEnabled')
    ..aOM<$4.FieldMask>(6, _omitFieldNames ? '' : 'updateMask',
        subBuilder: $4.FieldMask.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNodeRequest copyWith(void Function(UpdateNodeRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateNodeRequest))
          as UpdateNodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateNodeRequest create() => UpdateNodeRequest._();
  @$core.override
  UpdateNodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateNodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateNodeRequest>(create);
  static UpdateNodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get tags => $_getList(2);

  @$pb.TagNumber(4)
  $core.bool get pinned => $_getBF(3);
  @$pb.TagNumber(4)
  set pinned($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPinned() => $_has(3);
  @$pb.TagNumber(4)
  void clearPinned() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get alertsEnabled => $_getBF(4);
  @$pb.TagNumber(5)
  set alertsEnabled($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAlertsEnabled() => $_has(4);
  @$pb.TagNumber(5)
  void clearAlertsEnabled() => $_clearField(5);

  @$pb.TagNumber(6)
  $4.FieldMask get updateMask => $_getN(5);
  @$pb.TagNumber(6)
  set updateMask($4.FieldMask value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasUpdateMask() => $_has(5);
  @$pb.TagNumber(6)
  void clearUpdateMask() => $_clearField(6);
  @$pb.TagNumber(6)
  $4.FieldMask ensureUpdateMask() => $_ensure(5);
}

class RemoveNodeRequest extends $pb.GeneratedMessage {
  factory RemoveNodeRequest({
    $core.String? nodeId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    return result;
  }

  RemoveNodeRequest._();

  factory RemoveNodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveNodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveNodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveNodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveNodeRequest copyWith(void Function(RemoveNodeRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveNodeRequest))
          as RemoveNodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveNodeRequest create() => RemoveNodeRequest._();
  @$core.override
  RemoveNodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveNodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveNodeRequest>(create);
  static RemoveNodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);
}

/// AddNodeDirect adds a standalone nitellad with direct connection.
/// This bypasses Hub and connects directly to the node's admin API.
class AddNodeDirectRequest extends $pb.GeneratedMessage {
  factory AddNodeDirectRequest({
    $core.String? name,
    $core.String? address,
    $core.String? token,
    $core.String? caPem,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (address != null) result.address = address;
    if (token != null) result.token = token;
    if (caPem != null) result.caPem = caPem;
    return result;
  }

  AddNodeDirectRequest._();

  factory AddNodeDirectRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddNodeDirectRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddNodeDirectRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aOS(3, _omitFieldNames ? '' : 'token')
    ..aOS(4, _omitFieldNames ? '' : 'caPem')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddNodeDirectRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddNodeDirectRequest copyWith(void Function(AddNodeDirectRequest) updates) =>
      super.copyWith((message) => updates(message as AddNodeDirectRequest))
          as AddNodeDirectRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddNodeDirectRequest create() => AddNodeDirectRequest._();
  @$core.override
  AddNodeDirectRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddNodeDirectRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddNodeDirectRequest>(create);
  static AddNodeDirectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get token => $_getSZ(2);
  @$pb.TagNumber(3)
  set token($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearToken() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get caPem => $_getSZ(3);
  @$pb.TagNumber(4)
  set caPem($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCaPem() => $_has(3);
  @$pb.TagNumber(4)
  void clearCaPem() => $_clearField(4);
}

class AddNodeDirectResponse extends $pb.GeneratedMessage {
  factory AddNodeDirectResponse({
    $core.bool? success,
    $core.String? error,
    NodeInfo? node,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (node != null) result.node = node;
    return result;
  }

  AddNodeDirectResponse._();

  factory AddNodeDirectResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddNodeDirectResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddNodeDirectResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOM<NodeInfo>(3, _omitFieldNames ? '' : 'node',
        subBuilder: NodeInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddNodeDirectResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddNodeDirectResponse copyWith(
          void Function(AddNodeDirectResponse) updates) =>
      super.copyWith((message) => updates(message as AddNodeDirectResponse))
          as AddNodeDirectResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddNodeDirectResponse create() => AddNodeDirectResponse._();
  @$core.override
  AddNodeDirectResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddNodeDirectResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddNodeDirectResponse>(create);
  static AddNodeDirectResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  NodeInfo get node => $_getN(2);
  @$pb.TagNumber(3)
  set node(NodeInfo value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasNode() => $_has(2);
  @$pb.TagNumber(3)
  void clearNode() => $_clearField(3);
  @$pb.TagNumber(3)
  NodeInfo ensureNode() => $_ensure(2);
}

/// TestDirectConnection tests connectivity to a nitellad admin API.
class TestDirectConnectionRequest extends $pb.GeneratedMessage {
  factory TestDirectConnectionRequest({
    $core.String? address,
    $core.String? token,
    $core.String? caPem,
  }) {
    final result = create();
    if (address != null) result.address = address;
    if (token != null) result.token = token;
    if (caPem != null) result.caPem = caPem;
    return result;
  }

  TestDirectConnectionRequest._();

  factory TestDirectConnectionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TestDirectConnectionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TestDirectConnectionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'token')
    ..aOS(3, _omitFieldNames ? '' : 'caPem')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestDirectConnectionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestDirectConnectionRequest copyWith(
          void Function(TestDirectConnectionRequest) updates) =>
      super.copyWith(
              (message) => updates(message as TestDirectConnectionRequest))
          as TestDirectConnectionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestDirectConnectionRequest create() =>
      TestDirectConnectionRequest._();
  @$core.override
  TestDirectConnectionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TestDirectConnectionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TestDirectConnectionRequest>(create);
  static TestDirectConnectionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get token => $_getSZ(1);
  @$pb.TagNumber(2)
  set token($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get caPem => $_getSZ(2);
  @$pb.TagNumber(3)
  set caPem($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCaPem() => $_has(2);
  @$pb.TagNumber(3)
  void clearCaPem() => $_clearField(3);
}

class TestDirectConnectionResponse extends $pb.GeneratedMessage {
  factory TestDirectConnectionResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? nodeVersion,
    $core.String? nodeHostname,
    $core.int? proxyCount,
    $core.String? emojiHash,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (nodeVersion != null) result.nodeVersion = nodeVersion;
    if (nodeHostname != null) result.nodeHostname = nodeHostname;
    if (proxyCount != null) result.proxyCount = proxyCount;
    if (emojiHash != null) result.emojiHash = emojiHash;
    return result;
  }

  TestDirectConnectionResponse._();

  factory TestDirectConnectionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TestDirectConnectionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TestDirectConnectionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'nodeVersion')
    ..aOS(4, _omitFieldNames ? '' : 'nodeHostname')
    ..aI(5, _omitFieldNames ? '' : 'proxyCount')
    ..aOS(6, _omitFieldNames ? '' : 'emojiHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestDirectConnectionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestDirectConnectionResponse copyWith(
          void Function(TestDirectConnectionResponse) updates) =>
      super.copyWith(
              (message) => updates(message as TestDirectConnectionResponse))
          as TestDirectConnectionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestDirectConnectionResponse create() =>
      TestDirectConnectionResponse._();
  @$core.override
  TestDirectConnectionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TestDirectConnectionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TestDirectConnectionResponse>(create);
  static TestDirectConnectionResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get nodeVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set nodeVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get nodeHostname => $_getSZ(3);
  @$pb.TagNumber(4)
  set nodeHostname($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNodeHostname() => $_has(3);
  @$pb.TagNumber(4)
  void clearNodeHostname() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get proxyCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set proxyCount($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProxyCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearProxyCount() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get emojiHash => $_getSZ(5);
  @$pb.TagNumber(6)
  set emojiHash($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEmojiHash() => $_has(5);
  @$pb.TagNumber(6)
  void clearEmojiHash() => $_clearField(6);
}

class ProxyInfo extends $pb.GeneratedMessage {
  factory ProxyInfo({
    $core.String? proxyId,
    $core.String? nodeId,
    $core.String? name,
    $core.String? listenAddr,
    $core.String? defaultBackend,
    $core.bool? running,
    $5.ActionType? defaultAction,
    $5.FallbackAction? fallbackAction,
    $core.int? ruleCount,
    $fixnum.Int64? activeConnections,
    $fixnum.Int64? totalConnections,
    $core.Iterable<$core.String>? tags,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (nodeId != null) result.nodeId = nodeId;
    if (name != null) result.name = name;
    if (listenAddr != null) result.listenAddr = listenAddr;
    if (defaultBackend != null) result.defaultBackend = defaultBackend;
    if (running != null) result.running = running;
    if (defaultAction != null) result.defaultAction = defaultAction;
    if (fallbackAction != null) result.fallbackAction = fallbackAction;
    if (ruleCount != null) result.ruleCount = ruleCount;
    if (activeConnections != null) result.activeConnections = activeConnections;
    if (totalConnections != null) result.totalConnections = totalConnections;
    if (tags != null) result.tags.addAll(tags);
    return result;
  }

  ProxyInfo._();

  factory ProxyInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProxyInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProxyInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'nodeId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'listenAddr')
    ..aOS(5, _omitFieldNames ? '' : 'defaultBackend')
    ..aOB(6, _omitFieldNames ? '' : 'running')
    ..aE<$5.ActionType>(7, _omitFieldNames ? '' : 'defaultAction',
        enumValues: $5.ActionType.values)
    ..aE<$5.FallbackAction>(8, _omitFieldNames ? '' : 'fallbackAction',
        enumValues: $5.FallbackAction.values)
    ..aI(9, _omitFieldNames ? '' : 'ruleCount')
    ..aInt64(10, _omitFieldNames ? '' : 'activeConnections')
    ..aInt64(11, _omitFieldNames ? '' : 'totalConnections')
    ..pPS(12, _omitFieldNames ? '' : 'tags')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProxyInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProxyInfo copyWith(void Function(ProxyInfo) updates) =>
      super.copyWith((message) => updates(message as ProxyInfo)) as ProxyInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProxyInfo create() => ProxyInfo._();
  @$core.override
  ProxyInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProxyInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProxyInfo>(create);
  static ProxyInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get listenAddr => $_getSZ(3);
  @$pb.TagNumber(4)
  set listenAddr($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasListenAddr() => $_has(3);
  @$pb.TagNumber(4)
  void clearListenAddr() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get defaultBackend => $_getSZ(4);
  @$pb.TagNumber(5)
  set defaultBackend($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDefaultBackend() => $_has(4);
  @$pb.TagNumber(5)
  void clearDefaultBackend() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get running => $_getBF(5);
  @$pb.TagNumber(6)
  set running($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRunning() => $_has(5);
  @$pb.TagNumber(6)
  void clearRunning() => $_clearField(6);

  @$pb.TagNumber(7)
  $5.ActionType get defaultAction => $_getN(6);
  @$pb.TagNumber(7)
  set defaultAction($5.ActionType value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasDefaultAction() => $_has(6);
  @$pb.TagNumber(7)
  void clearDefaultAction() => $_clearField(7);

  @$pb.TagNumber(8)
  $5.FallbackAction get fallbackAction => $_getN(7);
  @$pb.TagNumber(8)
  set fallbackAction($5.FallbackAction value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasFallbackAction() => $_has(7);
  @$pb.TagNumber(8)
  void clearFallbackAction() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get ruleCount => $_getIZ(8);
  @$pb.TagNumber(9)
  set ruleCount($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRuleCount() => $_has(8);
  @$pb.TagNumber(9)
  void clearRuleCount() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get activeConnections => $_getI64(9);
  @$pb.TagNumber(10)
  set activeConnections($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasActiveConnections() => $_has(9);
  @$pb.TagNumber(10)
  void clearActiveConnections() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get totalConnections => $_getI64(10);
  @$pb.TagNumber(11)
  set totalConnections($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasTotalConnections() => $_has(10);
  @$pb.TagNumber(11)
  void clearTotalConnections() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<$core.String> get tags => $_getList(11);
}

class ListProxiesRequest extends $pb.GeneratedMessage {
  factory ListProxiesRequest({
    $core.String? nodeId,
    $core.int? limit,
    $core.int? offset,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (limit != null) result.limit = limit;
    if (offset != null) result.offset = offset;
    return result;
  }

  ListProxiesRequest._();

  factory ListProxiesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListProxiesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProxiesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aI(2, _omitFieldNames ? '' : 'limit')
    ..aI(3, _omitFieldNames ? '' : 'offset')
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

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

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

class ListProxiesResponse extends $pb.GeneratedMessage {
  factory ListProxiesResponse({
    $core.Iterable<ProxyInfo>? proxies,
    $core.int? totalCount,
  }) {
    final result = create();
    if (proxies != null) result.proxies.addAll(proxies);
    if (totalCount != null) result.totalCount = totalCount;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<ProxyInfo>(1, _omitFieldNames ? '' : 'proxies',
        subBuilder: ProxyInfo.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
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
  $pb.PbList<ProxyInfo> get proxies => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class GetProxiesSnapshotRequest extends $pb.GeneratedMessage {
  factory GetProxiesSnapshotRequest({
    $core.String? nodeId,
    $core.String? nodeFilter,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (nodeFilter != null) result.nodeFilter = nodeFilter;
    return result;
  }

  GetProxiesSnapshotRequest._();

  factory GetProxiesSnapshotRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetProxiesSnapshotRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProxiesSnapshotRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'nodeFilter')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProxiesSnapshotRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProxiesSnapshotRequest copyWith(
          void Function(GetProxiesSnapshotRequest) updates) =>
      super.copyWith((message) => updates(message as GetProxiesSnapshotRequest))
          as GetProxiesSnapshotRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProxiesSnapshotRequest create() => GetProxiesSnapshotRequest._();
  @$core.override
  GetProxiesSnapshotRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetProxiesSnapshotRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProxiesSnapshotRequest>(create);
  static GetProxiesSnapshotRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodeFilter => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeFilter($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeFilter() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeFilter() => $_clearField(2);
}

class NodeProxiesSnapshot extends $pb.GeneratedMessage {
  factory NodeProxiesSnapshot({
    NodeInfo? node,
    $core.Iterable<ProxyInfo>? proxies,
  }) {
    final result = create();
    if (node != null) result.node = node;
    if (proxies != null) result.proxies.addAll(proxies);
    return result;
  }

  NodeProxiesSnapshot._();

  factory NodeProxiesSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NodeProxiesSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeProxiesSnapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOM<NodeInfo>(1, _omitFieldNames ? '' : 'node',
        subBuilder: NodeInfo.create)
    ..pPM<ProxyInfo>(2, _omitFieldNames ? '' : 'proxies',
        subBuilder: ProxyInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeProxiesSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeProxiesSnapshot copyWith(void Function(NodeProxiesSnapshot) updates) =>
      super.copyWith((message) => updates(message as NodeProxiesSnapshot))
          as NodeProxiesSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NodeProxiesSnapshot create() => NodeProxiesSnapshot._();
  @$core.override
  NodeProxiesSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NodeProxiesSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NodeProxiesSnapshot>(create);
  static NodeProxiesSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  NodeInfo get node => $_getN(0);
  @$pb.TagNumber(1)
  set node(NodeInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasNode() => $_has(0);
  @$pb.TagNumber(1)
  void clearNode() => $_clearField(1);
  @$pb.TagNumber(1)
  NodeInfo ensureNode() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<ProxyInfo> get proxies => $_getList(1);
}

class GetProxiesSnapshotResponse extends $pb.GeneratedMessage {
  factory GetProxiesSnapshotResponse({
    $core.Iterable<NodeProxiesSnapshot>? nodeSnapshots,
    $core.int? totalNodes,
    $core.int? totalProxies,
  }) {
    final result = create();
    if (nodeSnapshots != null) result.nodeSnapshots.addAll(nodeSnapshots);
    if (totalNodes != null) result.totalNodes = totalNodes;
    if (totalProxies != null) result.totalProxies = totalProxies;
    return result;
  }

  GetProxiesSnapshotResponse._();

  factory GetProxiesSnapshotResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetProxiesSnapshotResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProxiesSnapshotResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<NodeProxiesSnapshot>(1, _omitFieldNames ? '' : 'nodeSnapshots',
        subBuilder: NodeProxiesSnapshot.create)
    ..aI(2, _omitFieldNames ? '' : 'totalNodes')
    ..aI(3, _omitFieldNames ? '' : 'totalProxies')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProxiesSnapshotResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProxiesSnapshotResponse copyWith(
          void Function(GetProxiesSnapshotResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetProxiesSnapshotResponse))
          as GetProxiesSnapshotResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProxiesSnapshotResponse create() => GetProxiesSnapshotResponse._();
  @$core.override
  GetProxiesSnapshotResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetProxiesSnapshotResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProxiesSnapshotResponse>(create);
  static GetProxiesSnapshotResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<NodeProxiesSnapshot> get nodeSnapshots => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalNodes => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalNodes($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalNodes() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalNodes() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalProxies => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalProxies($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalProxies() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalProxies() => $_clearField(3);
}

class GetProxyRequest extends $pb.GeneratedMessage {
  factory GetProxyRequest({
    $core.String? nodeId,
    $core.String? proxyId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    return result;
  }

  GetProxyRequest._();

  factory GetProxyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetProxyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProxyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProxyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProxyRequest copyWith(void Function(GetProxyRequest) updates) =>
      super.copyWith((message) => updates(message as GetProxyRequest))
          as GetProxyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProxyRequest create() => GetProxyRequest._();
  @$core.override
  GetProxyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetProxyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProxyRequest>(create);
  static GetProxyRequest? _defaultInstance;

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

class AddProxyRequest extends $pb.GeneratedMessage {
  factory AddProxyRequest({
    $core.String? nodeId,
    $core.String? name,
    $core.String? listenAddr,
    $core.String? defaultBackend,
    $5.ActionType? defaultAction,
    $5.FallbackAction? fallbackAction,
    $5.MockPreset? defaultMock,
    $5.MockPreset? fallbackMock,
    $core.Iterable<$core.String>? tags,
    $core.String? certPem,
    $core.String? keyPem,
    $core.String? caPem,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (name != null) result.name = name;
    if (listenAddr != null) result.listenAddr = listenAddr;
    if (defaultBackend != null) result.defaultBackend = defaultBackend;
    if (defaultAction != null) result.defaultAction = defaultAction;
    if (fallbackAction != null) result.fallbackAction = fallbackAction;
    if (defaultMock != null) result.defaultMock = defaultMock;
    if (fallbackMock != null) result.fallbackMock = fallbackMock;
    if (tags != null) result.tags.addAll(tags);
    if (certPem != null) result.certPem = certPem;
    if (keyPem != null) result.keyPem = keyPem;
    if (caPem != null) result.caPem = caPem;
    return result;
  }

  AddProxyRequest._();

  factory AddProxyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddProxyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddProxyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'listenAddr')
    ..aOS(4, _omitFieldNames ? '' : 'defaultBackend')
    ..aE<$5.ActionType>(5, _omitFieldNames ? '' : 'defaultAction',
        enumValues: $5.ActionType.values)
    ..aE<$5.FallbackAction>(6, _omitFieldNames ? '' : 'fallbackAction',
        enumValues: $5.FallbackAction.values)
    ..aE<$5.MockPreset>(7, _omitFieldNames ? '' : 'defaultMock',
        enumValues: $5.MockPreset.values)
    ..aE<$5.MockPreset>(8, _omitFieldNames ? '' : 'fallbackMock',
        enumValues: $5.MockPreset.values)
    ..pPS(9, _omitFieldNames ? '' : 'tags')
    ..aOS(10, _omitFieldNames ? '' : 'certPem')
    ..aOS(11, _omitFieldNames ? '' : 'keyPem')
    ..aOS(12, _omitFieldNames ? '' : 'caPem')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddProxyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddProxyRequest copyWith(void Function(AddProxyRequest) updates) =>
      super.copyWith((message) => updates(message as AddProxyRequest))
          as AddProxyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddProxyRequest create() => AddProxyRequest._();
  @$core.override
  AddProxyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddProxyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddProxyRequest>(create);
  static AddProxyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get listenAddr => $_getSZ(2);
  @$pb.TagNumber(3)
  set listenAddr($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasListenAddr() => $_has(2);
  @$pb.TagNumber(3)
  void clearListenAddr() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get defaultBackend => $_getSZ(3);
  @$pb.TagNumber(4)
  set defaultBackend($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDefaultBackend() => $_has(3);
  @$pb.TagNumber(4)
  void clearDefaultBackend() => $_clearField(4);

  @$pb.TagNumber(5)
  $5.ActionType get defaultAction => $_getN(4);
  @$pb.TagNumber(5)
  set defaultAction($5.ActionType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDefaultAction() => $_has(4);
  @$pb.TagNumber(5)
  void clearDefaultAction() => $_clearField(5);

  @$pb.TagNumber(6)
  $5.FallbackAction get fallbackAction => $_getN(5);
  @$pb.TagNumber(6)
  set fallbackAction($5.FallbackAction value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasFallbackAction() => $_has(5);
  @$pb.TagNumber(6)
  void clearFallbackAction() => $_clearField(6);

  @$pb.TagNumber(7)
  $5.MockPreset get defaultMock => $_getN(6);
  @$pb.TagNumber(7)
  set defaultMock($5.MockPreset value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasDefaultMock() => $_has(6);
  @$pb.TagNumber(7)
  void clearDefaultMock() => $_clearField(7);

  @$pb.TagNumber(8)
  $5.MockPreset get fallbackMock => $_getN(7);
  @$pb.TagNumber(8)
  set fallbackMock($5.MockPreset value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasFallbackMock() => $_has(7);
  @$pb.TagNumber(8)
  void clearFallbackMock() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get tags => $_getList(8);

  /// TLS configuration
  @$pb.TagNumber(10)
  $core.String get certPem => $_getSZ(9);
  @$pb.TagNumber(10)
  set certPem($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCertPem() => $_has(9);
  @$pb.TagNumber(10)
  void clearCertPem() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get keyPem => $_getSZ(10);
  @$pb.TagNumber(11)
  set keyPem($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasKeyPem() => $_has(10);
  @$pb.TagNumber(11)
  void clearKeyPem() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get caPem => $_getSZ(11);
  @$pb.TagNumber(12)
  set caPem($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasCaPem() => $_has(11);
  @$pb.TagNumber(12)
  void clearCaPem() => $_clearField(12);
}

class UpdateProxyRequest extends $pb.GeneratedMessage {
  factory UpdateProxyRequest({
    $core.String? nodeId,
    $core.String? proxyId,
    $core.String? name,
    $core.String? listenAddr,
    $core.String? defaultBackend,
    $5.ActionType? defaultAction,
    $5.FallbackAction? fallbackAction,
    $5.MockPreset? defaultMock,
    $5.MockPreset? fallbackMock,
    $core.Iterable<$core.String>? tags,
    $core.bool? running,
    $4.FieldMask? updateMask,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    if (name != null) result.name = name;
    if (listenAddr != null) result.listenAddr = listenAddr;
    if (defaultBackend != null) result.defaultBackend = defaultBackend;
    if (defaultAction != null) result.defaultAction = defaultAction;
    if (fallbackAction != null) result.fallbackAction = fallbackAction;
    if (defaultMock != null) result.defaultMock = defaultMock;
    if (fallbackMock != null) result.fallbackMock = fallbackMock;
    if (tags != null) result.tags.addAll(tags);
    if (running != null) result.running = running;
    if (updateMask != null) result.updateMask = updateMask;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'listenAddr')
    ..aOS(5, _omitFieldNames ? '' : 'defaultBackend')
    ..aE<$5.ActionType>(6, _omitFieldNames ? '' : 'defaultAction',
        enumValues: $5.ActionType.values)
    ..aE<$5.FallbackAction>(7, _omitFieldNames ? '' : 'fallbackAction',
        enumValues: $5.FallbackAction.values)
    ..aE<$5.MockPreset>(8, _omitFieldNames ? '' : 'defaultMock',
        enumValues: $5.MockPreset.values)
    ..aE<$5.MockPreset>(9, _omitFieldNames ? '' : 'fallbackMock',
        enumValues: $5.MockPreset.values)
    ..pPS(10, _omitFieldNames ? '' : 'tags')
    ..aOB(11, _omitFieldNames ? '' : 'running')
    ..aOM<$4.FieldMask>(12, _omitFieldNames ? '' : 'updateMask',
        subBuilder: $4.FieldMask.create)
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

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get listenAddr => $_getSZ(3);
  @$pb.TagNumber(4)
  set listenAddr($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasListenAddr() => $_has(3);
  @$pb.TagNumber(4)
  void clearListenAddr() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get defaultBackend => $_getSZ(4);
  @$pb.TagNumber(5)
  set defaultBackend($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDefaultBackend() => $_has(4);
  @$pb.TagNumber(5)
  void clearDefaultBackend() => $_clearField(5);

  @$pb.TagNumber(6)
  $5.ActionType get defaultAction => $_getN(5);
  @$pb.TagNumber(6)
  set defaultAction($5.ActionType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasDefaultAction() => $_has(5);
  @$pb.TagNumber(6)
  void clearDefaultAction() => $_clearField(6);

  @$pb.TagNumber(7)
  $5.FallbackAction get fallbackAction => $_getN(6);
  @$pb.TagNumber(7)
  set fallbackAction($5.FallbackAction value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasFallbackAction() => $_has(6);
  @$pb.TagNumber(7)
  void clearFallbackAction() => $_clearField(7);

  @$pb.TagNumber(8)
  $5.MockPreset get defaultMock => $_getN(7);
  @$pb.TagNumber(8)
  set defaultMock($5.MockPreset value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasDefaultMock() => $_has(7);
  @$pb.TagNumber(8)
  void clearDefaultMock() => $_clearField(8);

  @$pb.TagNumber(9)
  $5.MockPreset get fallbackMock => $_getN(8);
  @$pb.TagNumber(9)
  set fallbackMock($5.MockPreset value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasFallbackMock() => $_has(8);
  @$pb.TagNumber(9)
  void clearFallbackMock() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get tags => $_getList(9);

  @$pb.TagNumber(11)
  $core.bool get running => $_getBF(10);
  @$pb.TagNumber(11)
  set running($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasRunning() => $_has(10);
  @$pb.TagNumber(11)
  void clearRunning() => $_clearField(11);

  @$pb.TagNumber(12)
  $4.FieldMask get updateMask => $_getN(11);
  @$pb.TagNumber(12)
  set updateMask($4.FieldMask value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasUpdateMask() => $_has(11);
  @$pb.TagNumber(12)
  void clearUpdateMask() => $_clearField(12);
  @$pb.TagNumber(12)
  $4.FieldMask ensureUpdateMask() => $_ensure(11);
}

class RemoveProxyRequest extends $pb.GeneratedMessage {
  factory RemoveProxyRequest({
    $core.String? nodeId,
    $core.String? proxyId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    return result;
  }

  RemoveProxyRequest._();

  factory RemoveProxyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveProxyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveProxyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveProxyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveProxyRequest copyWith(void Function(RemoveProxyRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveProxyRequest))
          as RemoveProxyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveProxyRequest create() => RemoveProxyRequest._();
  @$core.override
  RemoveProxyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveProxyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveProxyRequest>(create);
  static RemoveProxyRequest? _defaultInstance;

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

class SetNodeProxiesRunningRequest extends $pb.GeneratedMessage {
  factory SetNodeProxiesRunningRequest({
    $core.String? nodeId,
    $core.bool? running,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (running != null) result.running = running;
    return result;
  }

  SetNodeProxiesRunningRequest._();

  factory SetNodeProxiesRunningRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetNodeProxiesRunningRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetNodeProxiesRunningRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOB(2, _omitFieldNames ? '' : 'running')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetNodeProxiesRunningRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetNodeProxiesRunningRequest copyWith(
          void Function(SetNodeProxiesRunningRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SetNodeProxiesRunningRequest))
          as SetNodeProxiesRunningRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetNodeProxiesRunningRequest create() =>
      SetNodeProxiesRunningRequest._();
  @$core.override
  SetNodeProxiesRunningRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetNodeProxiesRunningRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetNodeProxiesRunningRequest>(create);
  static SetNodeProxiesRunningRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get running => $_getBF(1);
  @$pb.TagNumber(2)
  set running($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRunning() => $_has(1);
  @$pb.TagNumber(2)
  void clearRunning() => $_clearField(2);
}

class SetNodeProxiesRunningResponse extends $pb.GeneratedMessage {
  factory SetNodeProxiesRunningResponse({
    $core.bool? success,
    $core.String? error,
    $core.int? updatedCount,
    $core.int? skippedCount,
    $core.Iterable<$core.String>? failedProxyIds,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (updatedCount != null) result.updatedCount = updatedCount;
    if (skippedCount != null) result.skippedCount = skippedCount;
    if (failedProxyIds != null) result.failedProxyIds.addAll(failedProxyIds);
    return result;
  }

  SetNodeProxiesRunningResponse._();

  factory SetNodeProxiesRunningResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetNodeProxiesRunningResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetNodeProxiesRunningResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aI(3, _omitFieldNames ? '' : 'updatedCount')
    ..aI(4, _omitFieldNames ? '' : 'skippedCount')
    ..pPS(5, _omitFieldNames ? '' : 'failedProxyIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetNodeProxiesRunningResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetNodeProxiesRunningResponse copyWith(
          void Function(SetNodeProxiesRunningResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SetNodeProxiesRunningResponse))
          as SetNodeProxiesRunningResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetNodeProxiesRunningResponse create() =>
      SetNodeProxiesRunningResponse._();
  @$core.override
  SetNodeProxiesRunningResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetNodeProxiesRunningResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetNodeProxiesRunningResponse>(create);
  static SetNodeProxiesRunningResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.int get updatedCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set updatedCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUpdatedCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearUpdatedCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get skippedCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set skippedCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSkippedCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearSkippedCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get failedProxyIds => $_getList(4);
}

class ListRulesRequest extends $pb.GeneratedMessage {
  factory ListRulesRequest({
    $core.String? nodeId,
    $core.String? proxyId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
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

class ListRulesResponse extends $pb.GeneratedMessage {
  factory ListRulesResponse({
    $core.Iterable<$2.Rule>? rules,
    $core.int? totalCount,
    RuleComposerPolicy? composerPolicy,
  }) {
    final result = create();
    if (rules != null) result.rules.addAll(rules);
    if (totalCount != null) result.totalCount = totalCount;
    if (composerPolicy != null) result.composerPolicy = composerPolicy;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<$2.Rule>(1, _omitFieldNames ? '' : 'rules',
        subBuilder: $2.Rule.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..aOM<RuleComposerPolicy>(3, _omitFieldNames ? '' : 'composerPolicy',
        subBuilder: RuleComposerPolicy.create)
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
  $pb.PbList<$2.Rule> get rules => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);

  @$pb.TagNumber(3)
  RuleComposerPolicy get composerPolicy => $_getN(2);
  @$pb.TagNumber(3)
  set composerPolicy(RuleComposerPolicy value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasComposerPolicy() => $_has(2);
  @$pb.TagNumber(3)
  void clearComposerPolicy() => $_clearField(3);
  @$pb.TagNumber(3)
  RuleComposerPolicy ensureComposerPolicy() => $_ensure(2);
}

class RuleComposerConditionPolicy extends $pb.GeneratedMessage {
  factory RuleComposerConditionPolicy({
    $5.ConditionType? conditionType,
    $core.Iterable<$5.Operator>? operators,
    $5.Operator? defaultOperator,
    $core.String? valueHint,
  }) {
    final result = create();
    if (conditionType != null) result.conditionType = conditionType;
    if (operators != null) result.operators.addAll(operators);
    if (defaultOperator != null) result.defaultOperator = defaultOperator;
    if (valueHint != null) result.valueHint = valueHint;
    return result;
  }

  RuleComposerConditionPolicy._();

  factory RuleComposerConditionPolicy.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RuleComposerConditionPolicy.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RuleComposerConditionPolicy',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aE<$5.ConditionType>(1, _omitFieldNames ? '' : 'conditionType',
        enumValues: $5.ConditionType.values)
    ..pc<$5.Operator>(2, _omitFieldNames ? '' : 'operators', $pb.PbFieldType.KE,
        valueOf: $5.Operator.valueOf,
        enumValues: $5.Operator.values,
        defaultEnumValue: $5.Operator.OPERATOR_UNSPECIFIED)
    ..aE<$5.Operator>(3, _omitFieldNames ? '' : 'defaultOperator',
        enumValues: $5.Operator.values)
    ..aOS(4, _omitFieldNames ? '' : 'valueHint')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuleComposerConditionPolicy clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuleComposerConditionPolicy copyWith(
          void Function(RuleComposerConditionPolicy) updates) =>
      super.copyWith(
              (message) => updates(message as RuleComposerConditionPolicy))
          as RuleComposerConditionPolicy;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RuleComposerConditionPolicy create() =>
      RuleComposerConditionPolicy._();
  @$core.override
  RuleComposerConditionPolicy createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RuleComposerConditionPolicy getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RuleComposerConditionPolicy>(create);
  static RuleComposerConditionPolicy? _defaultInstance;

  @$pb.TagNumber(1)
  $5.ConditionType get conditionType => $_getN(0);
  @$pb.TagNumber(1)
  set conditionType($5.ConditionType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasConditionType() => $_has(0);
  @$pb.TagNumber(1)
  void clearConditionType() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$5.Operator> get operators => $_getList(1);

  @$pb.TagNumber(3)
  $5.Operator get defaultOperator => $_getN(2);
  @$pb.TagNumber(3)
  set defaultOperator($5.Operator value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDefaultOperator() => $_has(2);
  @$pb.TagNumber(3)
  void clearDefaultOperator() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get valueHint => $_getSZ(3);
  @$pb.TagNumber(4)
  set valueHint($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasValueHint() => $_has(3);
  @$pb.TagNumber(4)
  void clearValueHint() => $_clearField(4);
}

class RuleComposerPolicy extends $pb.GeneratedMessage {
  factory RuleComposerPolicy({
    $core.Iterable<RuleComposerConditionPolicy>? conditionPolicies,
    $core.Iterable<$5.ActionType>? allowedActions,
    $core.int? defaultPriority,
  }) {
    final result = create();
    if (conditionPolicies != null)
      result.conditionPolicies.addAll(conditionPolicies);
    if (allowedActions != null) result.allowedActions.addAll(allowedActions);
    if (defaultPriority != null) result.defaultPriority = defaultPriority;
    return result;
  }

  RuleComposerPolicy._();

  factory RuleComposerPolicy.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RuleComposerPolicy.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RuleComposerPolicy',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<RuleComposerConditionPolicy>(
        1, _omitFieldNames ? '' : 'conditionPolicies',
        subBuilder: RuleComposerConditionPolicy.create)
    ..pc<$5.ActionType>(
        2, _omitFieldNames ? '' : 'allowedActions', $pb.PbFieldType.KE,
        valueOf: $5.ActionType.valueOf,
        enumValues: $5.ActionType.values,
        defaultEnumValue: $5.ActionType.ACTION_TYPE_UNSPECIFIED)
    ..aI(3, _omitFieldNames ? '' : 'defaultPriority')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuleComposerPolicy clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RuleComposerPolicy copyWith(void Function(RuleComposerPolicy) updates) =>
      super.copyWith((message) => updates(message as RuleComposerPolicy))
          as RuleComposerPolicy;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RuleComposerPolicy create() => RuleComposerPolicy._();
  @$core.override
  RuleComposerPolicy createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RuleComposerPolicy getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RuleComposerPolicy>(create);
  static RuleComposerPolicy? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RuleComposerConditionPolicy> get conditionPolicies => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<$5.ActionType> get allowedActions => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get defaultPriority => $_getIZ(2);
  @$pb.TagNumber(3)
  set defaultPriority($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDefaultPriority() => $_has(2);
  @$pb.TagNumber(3)
  void clearDefaultPriority() => $_clearField(3);
}

class GetRuleRequest extends $pb.GeneratedMessage {
  factory GetRuleRequest({
    $core.String? nodeId,
    $core.String? proxyId,
    $core.String? ruleId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    if (ruleId != null) result.ruleId = ruleId;
    return result;
  }

  GetRuleRequest._();

  factory GetRuleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRuleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRuleRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..aOS(3, _omitFieldNames ? '' : 'ruleId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRuleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRuleRequest copyWith(void Function(GetRuleRequest) updates) =>
      super.copyWith((message) => updates(message as GetRuleRequest))
          as GetRuleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRuleRequest create() => GetRuleRequest._();
  @$core.override
  GetRuleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRuleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRuleRequest>(create);
  static GetRuleRequest? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get ruleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ruleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRuleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRuleId() => $_clearField(3);
}

class AddRuleRequest extends $pb.GeneratedMessage {
  factory AddRuleRequest({
    $core.String? nodeId,
    $core.String? proxyId,
    $2.Rule? rule,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..aOM<$2.Rule>(3, _omitFieldNames ? '' : 'rule', subBuilder: $2.Rule.create)
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

  @$pb.TagNumber(3)
  $2.Rule get rule => $_getN(2);
  @$pb.TagNumber(3)
  set rule($2.Rule value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRule() => $_has(2);
  @$pb.TagNumber(3)
  void clearRule() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.Rule ensureRule() => $_ensure(2);
}

class AddQuickRuleRequest extends $pb.GeneratedMessage {
  factory AddQuickRuleRequest({
    $core.String? nodeId,
    $core.String? proxyId,
    $core.String? name,
    $5.ActionType? action,
    $5.ConditionType? conditionType,
    $core.String? value,
    $core.int? durationSeconds,
    $core.bool? sourceIpToCidr24,
    $core.bool? applyToAllNodes,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    if (name != null) result.name = name;
    if (action != null) result.action = action;
    if (conditionType != null) result.conditionType = conditionType;
    if (value != null) result.value = value;
    if (durationSeconds != null) result.durationSeconds = durationSeconds;
    if (sourceIpToCidr24 != null) result.sourceIpToCidr24 = sourceIpToCidr24;
    if (applyToAllNodes != null) result.applyToAllNodes = applyToAllNodes;
    return result;
  }

  AddQuickRuleRequest._();

  factory AddQuickRuleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddQuickRuleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddQuickRuleRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aE<$5.ActionType>(4, _omitFieldNames ? '' : 'action',
        enumValues: $5.ActionType.values)
    ..aE<$5.ConditionType>(5, _omitFieldNames ? '' : 'conditionType',
        enumValues: $5.ConditionType.values)
    ..aOS(6, _omitFieldNames ? '' : 'value')
    ..aI(7, _omitFieldNames ? '' : 'durationSeconds')
    ..aOB(8, _omitFieldNames ? '' : 'sourceIpToCidr24')
    ..aOB(9, _omitFieldNames ? '' : 'applyToAllNodes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddQuickRuleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddQuickRuleRequest copyWith(void Function(AddQuickRuleRequest) updates) =>
      super.copyWith((message) => updates(message as AddQuickRuleRequest))
          as AddQuickRuleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddQuickRuleRequest create() => AddQuickRuleRequest._();
  @$core.override
  AddQuickRuleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddQuickRuleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddQuickRuleRequest>(create);
  static AddQuickRuleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  /// Empty proxy_id is allowed for:
  /// - SOURCE_IP BLOCK/ALLOW: maps to node-level global rules
  /// - GEO_COUNTRY/GEO_ISP BLOCK: applies on all proxies of the target node
  @$pb.TagNumber(2)
  $core.String get proxyId => $_getSZ(1);
  @$pb.TagNumber(2)
  set proxyId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProxyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProxyId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $5.ActionType get action => $_getN(3);
  @$pb.TagNumber(4)
  set action($5.ActionType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAction() => $_has(3);
  @$pb.TagNumber(4)
  void clearAction() => $_clearField(4);

  @$pb.TagNumber(5)
  $5.ConditionType get conditionType => $_getN(4);
  @$pb.TagNumber(5)
  set conditionType($5.ConditionType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasConditionType() => $_has(4);
  @$pb.TagNumber(5)
  void clearConditionType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get value => $_getSZ(5);
  @$pb.TagNumber(6)
  set value($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearValue() => $_clearField(6);

  /// Optional duration for global SOURCE_IP BLOCK/ALLOW quick rules.
  @$pb.TagNumber(7)
  $core.int get durationSeconds => $_getIZ(6);
  @$pb.TagNumber(7)
  set durationSeconds($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDurationSeconds() => $_has(6);
  @$pb.TagNumber(7)
  void clearDurationSeconds() => $_clearField(7);

  /// If true and condition_type is SOURCE_IP, normalize IPv4 to x.y.z.0/24.
  @$pb.TagNumber(8)
  $core.bool get sourceIpToCidr24 => $_getBF(7);
  @$pb.TagNumber(8)
  set sourceIpToCidr24($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSourceIpToCidr24() => $_has(7);
  @$pb.TagNumber(8)
  void clearSourceIpToCidr24() => $_clearField(8);

  /// If true for SOURCE_IP BLOCK/ALLOW quick rules, apply across reachable nodes.
  @$pb.TagNumber(9)
  $core.bool get applyToAllNodes => $_getBF(8);
  @$pb.TagNumber(9)
  set applyToAllNodes($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasApplyToAllNodes() => $_has(8);
  @$pb.TagNumber(9)
  void clearApplyToAllNodes() => $_clearField(9);
}

class AddQuickRuleResponse extends $pb.GeneratedMessage {
  factory AddQuickRuleResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? ruleId,
    $core.int? rulesCreated,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (ruleId != null) result.ruleId = ruleId;
    if (rulesCreated != null) result.rulesCreated = rulesCreated;
    return result;
  }

  AddQuickRuleResponse._();

  factory AddQuickRuleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddQuickRuleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddQuickRuleResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'ruleId')
    ..aI(4, _omitFieldNames ? '' : 'rulesCreated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddQuickRuleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddQuickRuleResponse copyWith(void Function(AddQuickRuleResponse) updates) =>
      super.copyWith((message) => updates(message as AddQuickRuleResponse))
          as AddQuickRuleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddQuickRuleResponse create() => AddQuickRuleResponse._();
  @$core.override
  AddQuickRuleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddQuickRuleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddQuickRuleResponse>(create);
  static AddQuickRuleResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get ruleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ruleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRuleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRuleId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get rulesCreated => $_getIZ(3);
  @$pb.TagNumber(4)
  set rulesCreated($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRulesCreated() => $_has(3);
  @$pb.TagNumber(4)
  void clearRulesCreated() => $_clearField(4);
}

class UpdateRuleRequest extends $pb.GeneratedMessage {
  factory UpdateRuleRequest({
    $core.String? nodeId,
    $core.String? proxyId,
    $2.Rule? rule,
    $4.FieldMask? updateMask,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    if (rule != null) result.rule = rule;
    if (updateMask != null) result.updateMask = updateMask;
    return result;
  }

  UpdateRuleRequest._();

  factory UpdateRuleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateRuleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateRuleRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..aOM<$2.Rule>(3, _omitFieldNames ? '' : 'rule', subBuilder: $2.Rule.create)
    ..aOM<$4.FieldMask>(4, _omitFieldNames ? '' : 'updateMask',
        subBuilder: $4.FieldMask.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateRuleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateRuleRequest copyWith(void Function(UpdateRuleRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateRuleRequest))
          as UpdateRuleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateRuleRequest create() => UpdateRuleRequest._();
  @$core.override
  UpdateRuleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateRuleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateRuleRequest>(create);
  static UpdateRuleRequest? _defaultInstance;

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

  @$pb.TagNumber(3)
  $2.Rule get rule => $_getN(2);
  @$pb.TagNumber(3)
  set rule($2.Rule value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRule() => $_has(2);
  @$pb.TagNumber(3)
  void clearRule() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.Rule ensureRule() => $_ensure(2);

  @$pb.TagNumber(4)
  $4.FieldMask get updateMask => $_getN(3);
  @$pb.TagNumber(4)
  set updateMask($4.FieldMask value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasUpdateMask() => $_has(3);
  @$pb.TagNumber(4)
  void clearUpdateMask() => $_clearField(4);
  @$pb.TagNumber(4)
  $4.FieldMask ensureUpdateMask() => $_ensure(3);
}

class RemoveRuleRequest extends $pb.GeneratedMessage {
  factory RemoveRuleRequest({
    $core.String? nodeId,
    $core.String? proxyId,
    $core.String? ruleId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..aOS(3, _omitFieldNames ? '' : 'ruleId')
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

  @$pb.TagNumber(3)
  $core.String get ruleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ruleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRuleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRuleId() => $_clearField(3);
}

class BlockIPRequest extends $pb.GeneratedMessage {
  factory BlockIPRequest({
    $core.String? nodeId,
    $core.String? proxyId,
    $core.String? ip,
    $core.bool? applyToAllNodes,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    if (ip != null) result.ip = ip;
    if (applyToAllNodes != null) result.applyToAllNodes = applyToAllNodes;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..aOS(3, _omitFieldNames ? '' : 'ip')
    ..aOB(4, _omitFieldNames ? '' : 'applyToAllNodes')
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

  @$pb.TagNumber(3)
  $core.String get ip => $_getSZ(2);
  @$pb.TagNumber(3)
  set ip($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIp() => $_has(2);
  @$pb.TagNumber(3)
  void clearIp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get applyToAllNodes => $_getBF(3);
  @$pb.TagNumber(4)
  set applyToAllNodes($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasApplyToAllNodes() => $_has(3);
  @$pb.TagNumber(4)
  void clearApplyToAllNodes() => $_clearField(4);
}

class BlockIPResponse extends $pb.GeneratedMessage {
  factory BlockIPResponse({
    $core.bool? success,
    $core.String? error,
    $core.int? rulesCreated,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (rulesCreated != null) result.rulesCreated = rulesCreated;
    return result;
  }

  BlockIPResponse._();

  factory BlockIPResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockIPResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockIPResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aI(3, _omitFieldNames ? '' : 'rulesCreated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockIPResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockIPResponse copyWith(void Function(BlockIPResponse) updates) =>
      super.copyWith((message) => updates(message as BlockIPResponse))
          as BlockIPResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockIPResponse create() => BlockIPResponse._();
  @$core.override
  BlockIPResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockIPResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockIPResponse>(create);
  static BlockIPResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.int get rulesCreated => $_getIZ(2);
  @$pb.TagNumber(3)
  set rulesCreated($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRulesCreated() => $_has(2);
  @$pb.TagNumber(3)
  void clearRulesCreated() => $_clearField(3);
}

class BlockISPRequest extends $pb.GeneratedMessage {
  factory BlockISPRequest({
    $core.String? nodeId,
    $core.String? proxyId,
    $core.String? isp,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    if (isp != null) result.isp = isp;
    return result;
  }

  BlockISPRequest._();

  factory BlockISPRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockISPRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockISPRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..aOS(3, _omitFieldNames ? '' : 'isp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockISPRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockISPRequest copyWith(void Function(BlockISPRequest) updates) =>
      super.copyWith((message) => updates(message as BlockISPRequest))
          as BlockISPRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockISPRequest create() => BlockISPRequest._();
  @$core.override
  BlockISPRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockISPRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockISPRequest>(create);
  static BlockISPRequest? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get isp => $_getSZ(2);
  @$pb.TagNumber(3)
  set isp($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsp() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsp() => $_clearField(3);
}

class BlockISPResponse extends $pb.GeneratedMessage {
  factory BlockISPResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? ruleId,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (ruleId != null) result.ruleId = ruleId;
    return result;
  }

  BlockISPResponse._();

  factory BlockISPResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockISPResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockISPResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'ruleId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockISPResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockISPResponse copyWith(void Function(BlockISPResponse) updates) =>
      super.copyWith((message) => updates(message as BlockISPResponse))
          as BlockISPResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockISPResponse create() => BlockISPResponse._();
  @$core.override
  BlockISPResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockISPResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockISPResponse>(create);
  static BlockISPResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get ruleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ruleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRuleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRuleId() => $_clearField(3);
}

class BlockCountryRequest extends $pb.GeneratedMessage {
  factory BlockCountryRequest({
    $core.String? nodeId,
    $core.String? proxyId,
    $core.String? country,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    if (country != null) result.country = country;
    return result;
  }

  BlockCountryRequest._();

  factory BlockCountryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockCountryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockCountryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..aOS(3, _omitFieldNames ? '' : 'country')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockCountryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockCountryRequest copyWith(void Function(BlockCountryRequest) updates) =>
      super.copyWith((message) => updates(message as BlockCountryRequest))
          as BlockCountryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockCountryRequest create() => BlockCountryRequest._();
  @$core.override
  BlockCountryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockCountryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockCountryRequest>(create);
  static BlockCountryRequest? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get country => $_getSZ(2);
  @$pb.TagNumber(3)
  set country($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCountry() => $_has(2);
  @$pb.TagNumber(3)
  void clearCountry() => $_clearField(3);
}

class BlockCountryResponse extends $pb.GeneratedMessage {
  factory BlockCountryResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? ruleId,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (ruleId != null) result.ruleId = ruleId;
    return result;
  }

  BlockCountryResponse._();

  factory BlockCountryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockCountryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockCountryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'ruleId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockCountryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockCountryResponse copyWith(void Function(BlockCountryResponse) updates) =>
      super.copyWith((message) => updates(message as BlockCountryResponse))
          as BlockCountryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockCountryResponse create() => BlockCountryResponse._();
  @$core.override
  BlockCountryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockCountryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockCountryResponse>(create);
  static BlockCountryResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get ruleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ruleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRuleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRuleId() => $_clearField(3);
}

class AddGlobalRuleRequest extends $pb.GeneratedMessage {
  factory AddGlobalRuleRequest({
    $core.String? nodeId,
    $core.String? ip,
    $5.ActionType? action,
    $fixnum.Int64? durationSeconds,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (ip != null) result.ip = ip;
    if (action != null) result.action = action;
    if (durationSeconds != null) result.durationSeconds = durationSeconds;
    return result;
  }

  AddGlobalRuleRequest._();

  factory AddGlobalRuleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddGlobalRuleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddGlobalRuleRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'ip')
    ..aE<$5.ActionType>(3, _omitFieldNames ? '' : 'action',
        enumValues: $5.ActionType.values)
    ..aInt64(4, _omitFieldNames ? '' : 'durationSeconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGlobalRuleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGlobalRuleRequest copyWith(void Function(AddGlobalRuleRequest) updates) =>
      super.copyWith((message) => updates(message as AddGlobalRuleRequest))
          as AddGlobalRuleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddGlobalRuleRequest create() => AddGlobalRuleRequest._();
  @$core.override
  AddGlobalRuleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddGlobalRuleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddGlobalRuleRequest>(create);
  static AddGlobalRuleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get ip => $_getSZ(1);
  @$pb.TagNumber(2)
  set ip($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIp() => $_has(1);
  @$pb.TagNumber(2)
  void clearIp() => $_clearField(2);

  @$pb.TagNumber(3)
  $5.ActionType get action => $_getN(2);
  @$pb.TagNumber(3)
  set action($5.ActionType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasAction() => $_has(2);
  @$pb.TagNumber(3)
  void clearAction() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get durationSeconds => $_getI64(3);
  @$pb.TagNumber(4)
  set durationSeconds($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDurationSeconds() => $_has(3);
  @$pb.TagNumber(4)
  void clearDurationSeconds() => $_clearField(4);
}

class AddGlobalRuleResponse extends $pb.GeneratedMessage {
  factory AddGlobalRuleResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? ruleId,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (ruleId != null) result.ruleId = ruleId;
    return result;
  }

  AddGlobalRuleResponse._();

  factory AddGlobalRuleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddGlobalRuleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddGlobalRuleResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'ruleId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGlobalRuleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGlobalRuleResponse copyWith(
          void Function(AddGlobalRuleResponse) updates) =>
      super.copyWith((message) => updates(message as AddGlobalRuleResponse))
          as AddGlobalRuleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddGlobalRuleResponse create() => AddGlobalRuleResponse._();
  @$core.override
  AddGlobalRuleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddGlobalRuleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddGlobalRuleResponse>(create);
  static AddGlobalRuleResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get ruleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ruleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRuleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRuleId() => $_clearField(3);
}

class ListGlobalRulesRequest extends $pb.GeneratedMessage {
  factory ListGlobalRulesRequest({
    $core.String? nodeId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    return result;
  }

  ListGlobalRulesRequest._();

  factory ListGlobalRulesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListGlobalRulesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListGlobalRulesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
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

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);
}

class ListGlobalRulesResponse extends $pb.GeneratedMessage {
  factory ListGlobalRulesResponse({
    $core.Iterable<$2.GlobalRule>? rules,
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<$2.GlobalRule>(1, _omitFieldNames ? '' : 'rules',
        subBuilder: $2.GlobalRule.create)
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
  $pb.PbList<$2.GlobalRule> get rules => $_getList(0);
}

class RemoveGlobalRuleRequest extends $pb.GeneratedMessage {
  factory RemoveGlobalRuleRequest({
    $core.String? nodeId,
    $core.String? ruleId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'ruleId')
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
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get ruleId => $_getSZ(1);
  @$pb.TagNumber(2)
  set ruleId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRuleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRuleId() => $_clearField(2);
}

class RemoveGlobalRuleResponse extends $pb.GeneratedMessage {
  factory RemoveGlobalRuleResponse({
    $core.bool? success,
    $core.String? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
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
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
}

class ApprovalRequest extends $pb.GeneratedMessage {
  factory ApprovalRequest({
    $core.String? requestId,
    $core.String? nodeId,
    $core.String? nodeName,
    $core.String? proxyId,
    $core.String? proxyName,
    $core.String? sourceIp,
    $core.int? sourcePort,
    $core.String? destAddr,
    $core.String? ruleId,
    $core.String? ruleName,
    $5.GeoInfo? geo,
    $3.Timestamp? timestamp,
    $core.String? tlsCn,
    $core.String? tlsFingerprint,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (nodeId != null) result.nodeId = nodeId;
    if (nodeName != null) result.nodeName = nodeName;
    if (proxyId != null) result.proxyId = proxyId;
    if (proxyName != null) result.proxyName = proxyName;
    if (sourceIp != null) result.sourceIp = sourceIp;
    if (sourcePort != null) result.sourcePort = sourcePort;
    if (destAddr != null) result.destAddr = destAddr;
    if (ruleId != null) result.ruleId = ruleId;
    if (ruleName != null) result.ruleName = ruleName;
    if (geo != null) result.geo = geo;
    if (timestamp != null) result.timestamp = timestamp;
    if (tlsCn != null) result.tlsCn = tlsCn;
    if (tlsFingerprint != null) result.tlsFingerprint = tlsFingerprint;
    return result;
  }

  ApprovalRequest._();

  factory ApprovalRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApprovalRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApprovalRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'nodeId')
    ..aOS(3, _omitFieldNames ? '' : 'nodeName')
    ..aOS(4, _omitFieldNames ? '' : 'proxyId')
    ..aOS(5, _omitFieldNames ? '' : 'proxyName')
    ..aOS(6, _omitFieldNames ? '' : 'sourceIp')
    ..aI(7, _omitFieldNames ? '' : 'sourcePort')
    ..aOS(8, _omitFieldNames ? '' : 'destAddr')
    ..aOS(9, _omitFieldNames ? '' : 'ruleId')
    ..aOS(10, _omitFieldNames ? '' : 'ruleName')
    ..aOM<$5.GeoInfo>(11, _omitFieldNames ? '' : 'geo',
        subBuilder: $5.GeoInfo.create)
    ..aOM<$3.Timestamp>(12, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $3.Timestamp.create)
    ..aOS(13, _omitFieldNames ? '' : 'tlsCn')
    ..aOS(14, _omitFieldNames ? '' : 'tlsFingerprint')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalRequest copyWith(void Function(ApprovalRequest) updates) =>
      super.copyWith((message) => updates(message as ApprovalRequest))
          as ApprovalRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApprovalRequest create() => ApprovalRequest._();
  @$core.override
  ApprovalRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApprovalRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApprovalRequest>(create);
  static ApprovalRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get nodeName => $_getSZ(2);
  @$pb.TagNumber(3)
  set nodeName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeName() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get proxyId => $_getSZ(3);
  @$pb.TagNumber(4)
  set proxyId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProxyId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProxyId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get proxyName => $_getSZ(4);
  @$pb.TagNumber(5)
  set proxyName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProxyName() => $_has(4);
  @$pb.TagNumber(5)
  void clearProxyName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get sourceIp => $_getSZ(5);
  @$pb.TagNumber(6)
  set sourceIp($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSourceIp() => $_has(5);
  @$pb.TagNumber(6)
  void clearSourceIp() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get sourcePort => $_getIZ(6);
  @$pb.TagNumber(7)
  set sourcePort($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSourcePort() => $_has(6);
  @$pb.TagNumber(7)
  void clearSourcePort() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get destAddr => $_getSZ(7);
  @$pb.TagNumber(8)
  set destAddr($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDestAddr() => $_has(7);
  @$pb.TagNumber(8)
  void clearDestAddr() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get ruleId => $_getSZ(8);
  @$pb.TagNumber(9)
  set ruleId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRuleId() => $_has(8);
  @$pb.TagNumber(9)
  void clearRuleId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get ruleName => $_getSZ(9);
  @$pb.TagNumber(10)
  set ruleName($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRuleName() => $_has(9);
  @$pb.TagNumber(10)
  void clearRuleName() => $_clearField(10);

  @$pb.TagNumber(11)
  $5.GeoInfo get geo => $_getN(10);
  @$pb.TagNumber(11)
  set geo($5.GeoInfo value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasGeo() => $_has(10);
  @$pb.TagNumber(11)
  void clearGeo() => $_clearField(11);
  @$pb.TagNumber(11)
  $5.GeoInfo ensureGeo() => $_ensure(10);

  @$pb.TagNumber(12)
  $3.Timestamp get timestamp => $_getN(11);
  @$pb.TagNumber(12)
  set timestamp($3.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasTimestamp() => $_has(11);
  @$pb.TagNumber(12)
  void clearTimestamp() => $_clearField(12);
  @$pb.TagNumber(12)
  $3.Timestamp ensureTimestamp() => $_ensure(11);

  @$pb.TagNumber(13)
  $core.String get tlsCn => $_getSZ(12);
  @$pb.TagNumber(13)
  set tlsCn($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasTlsCn() => $_has(12);
  @$pb.TagNumber(13)
  void clearTlsCn() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get tlsFingerprint => $_getSZ(13);
  @$pb.TagNumber(14)
  set tlsFingerprint($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasTlsFingerprint() => $_has(13);
  @$pb.TagNumber(14)
  void clearTlsFingerprint() => $_clearField(14);
}

class ListPendingApprovalsRequest extends $pb.GeneratedMessage {
  factory ListPendingApprovalsRequest({
    $core.String? nodeId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    return result;
  }

  ListPendingApprovalsRequest._();

  factory ListPendingApprovalsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPendingApprovalsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPendingApprovalsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPendingApprovalsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPendingApprovalsRequest copyWith(
          void Function(ListPendingApprovalsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ListPendingApprovalsRequest))
          as ListPendingApprovalsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPendingApprovalsRequest create() =>
      ListPendingApprovalsRequest._();
  @$core.override
  ListPendingApprovalsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPendingApprovalsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPendingApprovalsRequest>(create);
  static ListPendingApprovalsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);
}

class ListPendingApprovalsResponse extends $pb.GeneratedMessage {
  factory ListPendingApprovalsResponse({
    $core.Iterable<ApprovalRequest>? requests,
    $core.int? totalCount,
  }) {
    final result = create();
    if (requests != null) result.requests.addAll(requests);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListPendingApprovalsResponse._();

  factory ListPendingApprovalsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPendingApprovalsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPendingApprovalsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<ApprovalRequest>(1, _omitFieldNames ? '' : 'requests',
        subBuilder: ApprovalRequest.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPendingApprovalsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPendingApprovalsResponse copyWith(
          void Function(ListPendingApprovalsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListPendingApprovalsResponse))
          as ListPendingApprovalsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPendingApprovalsResponse create() =>
      ListPendingApprovalsResponse._();
  @$core.override
  ListPendingApprovalsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPendingApprovalsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPendingApprovalsResponse>(create);
  static ListPendingApprovalsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ApprovalRequest> get requests => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class GetApprovalsSnapshotRequest extends $pb.GeneratedMessage {
  factory GetApprovalsSnapshotRequest({
    $core.String? nodeId,
    $core.int? historyLimit,
    $core.int? historyOffset,
    $core.bool? includeHistory,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (historyLimit != null) result.historyLimit = historyLimit;
    if (historyOffset != null) result.historyOffset = historyOffset;
    if (includeHistory != null) result.includeHistory = includeHistory;
    return result;
  }

  GetApprovalsSnapshotRequest._();

  factory GetApprovalsSnapshotRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetApprovalsSnapshotRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetApprovalsSnapshotRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aI(2, _omitFieldNames ? '' : 'historyLimit')
    ..aI(3, _omitFieldNames ? '' : 'historyOffset')
    ..aOB(4, _omitFieldNames ? '' : 'includeHistory')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetApprovalsSnapshotRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetApprovalsSnapshotRequest copyWith(
          void Function(GetApprovalsSnapshotRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetApprovalsSnapshotRequest))
          as GetApprovalsSnapshotRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetApprovalsSnapshotRequest create() =>
      GetApprovalsSnapshotRequest._();
  @$core.override
  GetApprovalsSnapshotRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetApprovalsSnapshotRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetApprovalsSnapshotRequest>(create);
  static GetApprovalsSnapshotRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get historyLimit => $_getIZ(1);
  @$pb.TagNumber(2)
  set historyLimit($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHistoryLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearHistoryLimit() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get historyOffset => $_getIZ(2);
  @$pb.TagNumber(3)
  set historyOffset($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHistoryOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearHistoryOffset() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get includeHistory => $_getBF(3);
  @$pb.TagNumber(4)
  set includeHistory($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIncludeHistory() => $_has(3);
  @$pb.TagNumber(4)
  void clearIncludeHistory() => $_clearField(4);
}

class GetApprovalsSnapshotResponse extends $pb.GeneratedMessage {
  factory GetApprovalsSnapshotResponse({
    $core.Iterable<ApprovalRequest>? pendingRequests,
    $core.int? pendingTotalCount,
    $core.Iterable<ApprovalHistoryEntry>? historyEntries,
    $core.int? historyTotalCount,
    $core.Iterable<$fixnum.Int64>? approveDurationOptions,
    $fixnum.Int64? defaultApproveDurationSeconds,
    $core.Iterable<DenyBlockType>? denyBlockOptions,
    $core.int? recommendedPollIntervalSeconds,
  }) {
    final result = create();
    if (pendingRequests != null) result.pendingRequests.addAll(pendingRequests);
    if (pendingTotalCount != null) result.pendingTotalCount = pendingTotalCount;
    if (historyEntries != null) result.historyEntries.addAll(historyEntries);
    if (historyTotalCount != null) result.historyTotalCount = historyTotalCount;
    if (approveDurationOptions != null)
      result.approveDurationOptions.addAll(approveDurationOptions);
    if (defaultApproveDurationSeconds != null)
      result.defaultApproveDurationSeconds = defaultApproveDurationSeconds;
    if (denyBlockOptions != null)
      result.denyBlockOptions.addAll(denyBlockOptions);
    if (recommendedPollIntervalSeconds != null)
      result.recommendedPollIntervalSeconds = recommendedPollIntervalSeconds;
    return result;
  }

  GetApprovalsSnapshotResponse._();

  factory GetApprovalsSnapshotResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetApprovalsSnapshotResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetApprovalsSnapshotResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<ApprovalRequest>(1, _omitFieldNames ? '' : 'pendingRequests',
        subBuilder: ApprovalRequest.create)
    ..aI(2, _omitFieldNames ? '' : 'pendingTotalCount')
    ..pPM<ApprovalHistoryEntry>(3, _omitFieldNames ? '' : 'historyEntries',
        subBuilder: ApprovalHistoryEntry.create)
    ..aI(4, _omitFieldNames ? '' : 'historyTotalCount')
    ..p<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'approveDurationOptions', $pb.PbFieldType.K6)
    ..aInt64(6, _omitFieldNames ? '' : 'defaultApproveDurationSeconds')
    ..pc<DenyBlockType>(
        7, _omitFieldNames ? '' : 'denyBlockOptions', $pb.PbFieldType.KE,
        valueOf: DenyBlockType.valueOf,
        enumValues: DenyBlockType.values,
        defaultEnumValue: DenyBlockType.DENY_BLOCK_TYPE_NONE)
    ..aI(8, _omitFieldNames ? '' : 'recommendedPollIntervalSeconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetApprovalsSnapshotResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetApprovalsSnapshotResponse copyWith(
          void Function(GetApprovalsSnapshotResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetApprovalsSnapshotResponse))
          as GetApprovalsSnapshotResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetApprovalsSnapshotResponse create() =>
      GetApprovalsSnapshotResponse._();
  @$core.override
  GetApprovalsSnapshotResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetApprovalsSnapshotResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetApprovalsSnapshotResponse>(create);
  static GetApprovalsSnapshotResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ApprovalRequest> get pendingRequests => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get pendingTotalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set pendingTotalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPendingTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearPendingTotalCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<ApprovalHistoryEntry> get historyEntries => $_getList(2);

  @$pb.TagNumber(4)
  $core.int get historyTotalCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set historyTotalCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHistoryTotalCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearHistoryTotalCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$fixnum.Int64> get approveDurationOptions => $_getList(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get defaultApproveDurationSeconds => $_getI64(5);
  @$pb.TagNumber(6)
  set defaultApproveDurationSeconds($fixnum.Int64 value) =>
      $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDefaultApproveDurationSeconds() => $_has(5);
  @$pb.TagNumber(6)
  void clearDefaultApproveDurationSeconds() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<DenyBlockType> get denyBlockOptions => $_getList(6);

  @$pb.TagNumber(8)
  $core.int get recommendedPollIntervalSeconds => $_getIZ(7);
  @$pb.TagNumber(8)
  set recommendedPollIntervalSeconds($core.int value) =>
      $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRecommendedPollIntervalSeconds() => $_has(7);
  @$pb.TagNumber(8)
  void clearRecommendedPollIntervalSeconds() => $_clearField(8);
}

class ApproveRequestRequest extends $pb.GeneratedMessage {
  factory ApproveRequestRequest({
    $core.String? requestId,
    $5.ApprovalRetentionMode? retentionMode,
    $fixnum.Int64? durationSeconds,
    $core.bool? createRule,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (retentionMode != null) result.retentionMode = retentionMode;
    if (durationSeconds != null) result.durationSeconds = durationSeconds;
    if (createRule != null) result.createRule = createRule;
    return result;
  }

  ApproveRequestRequest._();

  factory ApproveRequestRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApproveRequestRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApproveRequestRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aE<$5.ApprovalRetentionMode>(2, _omitFieldNames ? '' : 'retentionMode',
        enumValues: $5.ApprovalRetentionMode.values)
    ..aInt64(3, _omitFieldNames ? '' : 'durationSeconds')
    ..aOB(4, _omitFieldNames ? '' : 'createRule')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApproveRequestRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApproveRequestRequest copyWith(
          void Function(ApproveRequestRequest) updates) =>
      super.copyWith((message) => updates(message as ApproveRequestRequest))
          as ApproveRequestRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApproveRequestRequest create() => ApproveRequestRequest._();
  @$core.override
  ApproveRequestRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApproveRequestRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApproveRequestRequest>(create);
  static ApproveRequestRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $5.ApprovalRetentionMode get retentionMode => $_getN(1);
  @$pb.TagNumber(2)
  set retentionMode($5.ApprovalRetentionMode value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRetentionMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearRetentionMode() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get durationSeconds => $_getI64(2);
  @$pb.TagNumber(3)
  set durationSeconds($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDurationSeconds() => $_has(2);
  @$pb.TagNumber(3)
  void clearDurationSeconds() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get createRule => $_getBF(3);
  @$pb.TagNumber(4)
  set createRule($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreateRule() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreateRule() => $_clearField(4);
}

class ApproveRequestResponse extends $pb.GeneratedMessage {
  factory ApproveRequestResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? ruleId,
    $core.bool? decisionApplied,
    $core.bool? historyPersisted,
    $core.String? historyError,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (ruleId != null) result.ruleId = ruleId;
    if (decisionApplied != null) result.decisionApplied = decisionApplied;
    if (historyPersisted != null) result.historyPersisted = historyPersisted;
    if (historyError != null) result.historyError = historyError;
    return result;
  }

  ApproveRequestResponse._();

  factory ApproveRequestResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApproveRequestResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApproveRequestResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'ruleId')
    ..aOB(4, _omitFieldNames ? '' : 'decisionApplied')
    ..aOB(5, _omitFieldNames ? '' : 'historyPersisted')
    ..aOS(6, _omitFieldNames ? '' : 'historyError')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApproveRequestResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApproveRequestResponse copyWith(
          void Function(ApproveRequestResponse) updates) =>
      super.copyWith((message) => updates(message as ApproveRequestResponse))
          as ApproveRequestResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApproveRequestResponse create() => ApproveRequestResponse._();
  @$core.override
  ApproveRequestResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApproveRequestResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApproveRequestResponse>(create);
  static ApproveRequestResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get ruleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ruleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRuleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRuleId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get decisionApplied => $_getBF(3);
  @$pb.TagNumber(4)
  set decisionApplied($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDecisionApplied() => $_has(3);
  @$pb.TagNumber(4)
  void clearDecisionApplied() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get historyPersisted => $_getBF(4);
  @$pb.TagNumber(5)
  set historyPersisted($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHistoryPersisted() => $_has(4);
  @$pb.TagNumber(5)
  void clearHistoryPersisted() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get historyError => $_getSZ(5);
  @$pb.TagNumber(6)
  set historyError($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHistoryError() => $_has(5);
  @$pb.TagNumber(6)
  void clearHistoryError() => $_clearField(6);
}

class DenyRequestRequest extends $pb.GeneratedMessage {
  factory DenyRequestRequest({
    $core.String? requestId,
    $5.ApprovalRetentionMode? retentionMode,
    $fixnum.Int64? durationSeconds,
    DenyBlockType? blockType,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (retentionMode != null) result.retentionMode = retentionMode;
    if (durationSeconds != null) result.durationSeconds = durationSeconds;
    if (blockType != null) result.blockType = blockType;
    return result;
  }

  DenyRequestRequest._();

  factory DenyRequestRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DenyRequestRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DenyRequestRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aE<$5.ApprovalRetentionMode>(2, _omitFieldNames ? '' : 'retentionMode',
        enumValues: $5.ApprovalRetentionMode.values)
    ..aInt64(3, _omitFieldNames ? '' : 'durationSeconds')
    ..aE<DenyBlockType>(4, _omitFieldNames ? '' : 'blockType',
        enumValues: DenyBlockType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DenyRequestRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DenyRequestRequest copyWith(void Function(DenyRequestRequest) updates) =>
      super.copyWith((message) => updates(message as DenyRequestRequest))
          as DenyRequestRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DenyRequestRequest create() => DenyRequestRequest._();
  @$core.override
  DenyRequestRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DenyRequestRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DenyRequestRequest>(create);
  static DenyRequestRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $5.ApprovalRetentionMode get retentionMode => $_getN(1);
  @$pb.TagNumber(2)
  set retentionMode($5.ApprovalRetentionMode value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRetentionMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearRetentionMode() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get durationSeconds => $_getI64(2);
  @$pb.TagNumber(3)
  set durationSeconds($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDurationSeconds() => $_has(2);
  @$pb.TagNumber(3)
  void clearDurationSeconds() => $_clearField(3);

  @$pb.TagNumber(4)
  DenyBlockType get blockType => $_getN(3);
  @$pb.TagNumber(4)
  set blockType(DenyBlockType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasBlockType() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockType() => $_clearField(4);
}

class DenyRequestResponse extends $pb.GeneratedMessage {
  factory DenyRequestResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? ruleId,
    $core.bool? decisionApplied,
    $core.bool? historyPersisted,
    $core.String? historyError,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (ruleId != null) result.ruleId = ruleId;
    if (decisionApplied != null) result.decisionApplied = decisionApplied;
    if (historyPersisted != null) result.historyPersisted = historyPersisted;
    if (historyError != null) result.historyError = historyError;
    return result;
  }

  DenyRequestResponse._();

  factory DenyRequestResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DenyRequestResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DenyRequestResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'ruleId')
    ..aOB(4, _omitFieldNames ? '' : 'decisionApplied')
    ..aOB(5, _omitFieldNames ? '' : 'historyPersisted')
    ..aOS(6, _omitFieldNames ? '' : 'historyError')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DenyRequestResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DenyRequestResponse copyWith(void Function(DenyRequestResponse) updates) =>
      super.copyWith((message) => updates(message as DenyRequestResponse))
          as DenyRequestResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DenyRequestResponse create() => DenyRequestResponse._();
  @$core.override
  DenyRequestResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DenyRequestResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DenyRequestResponse>(create);
  static DenyRequestResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get ruleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ruleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRuleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRuleId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get decisionApplied => $_getBF(3);
  @$pb.TagNumber(4)
  set decisionApplied($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDecisionApplied() => $_has(3);
  @$pb.TagNumber(4)
  void clearDecisionApplied() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get historyPersisted => $_getBF(4);
  @$pb.TagNumber(5)
  set historyPersisted($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHistoryPersisted() => $_has(4);
  @$pb.TagNumber(5)
  void clearHistoryPersisted() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get historyError => $_getSZ(5);
  @$pb.TagNumber(6)
  set historyError($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHistoryError() => $_has(5);
  @$pb.TagNumber(6)
  void clearHistoryError() => $_clearField(6);
}

class ResolveApprovalDecisionRequest extends $pb.GeneratedMessage {
  factory ResolveApprovalDecisionRequest({
    $core.String? requestId,
    ApprovalDecision? decision,
    $5.ApprovalRetentionMode? retentionMode,
    $fixnum.Int64? durationSeconds,
    DenyBlockType? denyBlockType,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (decision != null) result.decision = decision;
    if (retentionMode != null) result.retentionMode = retentionMode;
    if (durationSeconds != null) result.durationSeconds = durationSeconds;
    if (denyBlockType != null) result.denyBlockType = denyBlockType;
    return result;
  }

  ResolveApprovalDecisionRequest._();

  factory ResolveApprovalDecisionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResolveApprovalDecisionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolveApprovalDecisionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aE<ApprovalDecision>(2, _omitFieldNames ? '' : 'decision',
        enumValues: ApprovalDecision.values)
    ..aE<$5.ApprovalRetentionMode>(3, _omitFieldNames ? '' : 'retentionMode',
        enumValues: $5.ApprovalRetentionMode.values)
    ..aInt64(4, _omitFieldNames ? '' : 'durationSeconds')
    ..aE<DenyBlockType>(5, _omitFieldNames ? '' : 'denyBlockType',
        enumValues: DenyBlockType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveApprovalDecisionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveApprovalDecisionRequest copyWith(
          void Function(ResolveApprovalDecisionRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ResolveApprovalDecisionRequest))
          as ResolveApprovalDecisionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResolveApprovalDecisionRequest create() =>
      ResolveApprovalDecisionRequest._();
  @$core.override
  ResolveApprovalDecisionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResolveApprovalDecisionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolveApprovalDecisionRequest>(create);
  static ResolveApprovalDecisionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  ApprovalDecision get decision => $_getN(1);
  @$pb.TagNumber(2)
  set decision(ApprovalDecision value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDecision() => $_has(1);
  @$pb.TagNumber(2)
  void clearDecision() => $_clearField(2);

  @$pb.TagNumber(3)
  $5.ApprovalRetentionMode get retentionMode => $_getN(2);
  @$pb.TagNumber(3)
  set retentionMode($5.ApprovalRetentionMode value) => $_setField(3, value);
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
  DenyBlockType get denyBlockType => $_getN(4);
  @$pb.TagNumber(5)
  set denyBlockType(DenyBlockType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDenyBlockType() => $_has(4);
  @$pb.TagNumber(5)
  void clearDenyBlockType() => $_clearField(5);
}

class ResolveApprovalDecisionResponse extends $pb.GeneratedMessage {
  factory ResolveApprovalDecisionResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? ruleId,
    $core.bool? decisionApplied,
    $core.bool? historyPersisted,
    $core.String? historyError,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (ruleId != null) result.ruleId = ruleId;
    if (decisionApplied != null) result.decisionApplied = decisionApplied;
    if (historyPersisted != null) result.historyPersisted = historyPersisted;
    if (historyError != null) result.historyError = historyError;
    return result;
  }

  ResolveApprovalDecisionResponse._();

  factory ResolveApprovalDecisionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResolveApprovalDecisionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolveApprovalDecisionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'ruleId')
    ..aOB(4, _omitFieldNames ? '' : 'decisionApplied')
    ..aOB(5, _omitFieldNames ? '' : 'historyPersisted')
    ..aOS(6, _omitFieldNames ? '' : 'historyError')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveApprovalDecisionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveApprovalDecisionResponse copyWith(
          void Function(ResolveApprovalDecisionResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ResolveApprovalDecisionResponse))
          as ResolveApprovalDecisionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResolveApprovalDecisionResponse create() =>
      ResolveApprovalDecisionResponse._();
  @$core.override
  ResolveApprovalDecisionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResolveApprovalDecisionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolveApprovalDecisionResponse>(
          create);
  static ResolveApprovalDecisionResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get ruleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ruleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRuleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRuleId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get decisionApplied => $_getBF(3);
  @$pb.TagNumber(4)
  set decisionApplied($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDecisionApplied() => $_has(3);
  @$pb.TagNumber(4)
  void clearDecisionApplied() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get historyPersisted => $_getBF(4);
  @$pb.TagNumber(5)
  set historyPersisted($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHistoryPersisted() => $_has(4);
  @$pb.TagNumber(5)
  void clearHistoryPersisted() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get historyError => $_getSZ(5);
  @$pb.TagNumber(6)
  set historyError($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHistoryError() => $_has(5);
  @$pb.TagNumber(6)
  void clearHistoryError() => $_clearField(6);
}

class StreamApprovalsRequest extends $pb.GeneratedMessage {
  factory StreamApprovalsRequest({
    $core.String? nodeId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    return result;
  }

  StreamApprovalsRequest._();

  factory StreamApprovalsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamApprovalsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamApprovalsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamApprovalsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamApprovalsRequest copyWith(
          void Function(StreamApprovalsRequest) updates) =>
      super.copyWith((message) => updates(message as StreamApprovalsRequest))
          as StreamApprovalsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamApprovalsRequest create() => StreamApprovalsRequest._();
  @$core.override
  StreamApprovalsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamApprovalsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamApprovalsRequest>(create);
  static StreamApprovalsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);
}

class ApprovalHistoryEntry extends $pb.GeneratedMessage {
  factory ApprovalHistoryEntry({
    $core.String? requestId,
    $core.String? nodeId,
    $core.String? nodeName,
    $core.String? proxyId,
    $core.String? proxyName,
    $core.String? sourceIp,
    $core.String? destAddr,
    $5.GeoInfo? geo,
    ApprovalHistoryAction? action,
    $fixnum.Int64? durationSeconds,
    DenyBlockType? blockType,
    $core.String? ruleId,
    $3.Timestamp? decidedAt,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (nodeId != null) result.nodeId = nodeId;
    if (nodeName != null) result.nodeName = nodeName;
    if (proxyId != null) result.proxyId = proxyId;
    if (proxyName != null) result.proxyName = proxyName;
    if (sourceIp != null) result.sourceIp = sourceIp;
    if (destAddr != null) result.destAddr = destAddr;
    if (geo != null) result.geo = geo;
    if (action != null) result.action = action;
    if (durationSeconds != null) result.durationSeconds = durationSeconds;
    if (blockType != null) result.blockType = blockType;
    if (ruleId != null) result.ruleId = ruleId;
    if (decidedAt != null) result.decidedAt = decidedAt;
    return result;
  }

  ApprovalHistoryEntry._();

  factory ApprovalHistoryEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApprovalHistoryEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApprovalHistoryEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'nodeId')
    ..aOS(3, _omitFieldNames ? '' : 'nodeName')
    ..aOS(4, _omitFieldNames ? '' : 'proxyId')
    ..aOS(5, _omitFieldNames ? '' : 'proxyName')
    ..aOS(6, _omitFieldNames ? '' : 'sourceIp')
    ..aOS(7, _omitFieldNames ? '' : 'destAddr')
    ..aOM<$5.GeoInfo>(8, _omitFieldNames ? '' : 'geo',
        subBuilder: $5.GeoInfo.create)
    ..aE<ApprovalHistoryAction>(9, _omitFieldNames ? '' : 'action',
        enumValues: ApprovalHistoryAction.values)
    ..aInt64(10, _omitFieldNames ? '' : 'durationSeconds')
    ..aE<DenyBlockType>(11, _omitFieldNames ? '' : 'blockType',
        enumValues: DenyBlockType.values)
    ..aOS(12, _omitFieldNames ? '' : 'ruleId')
    ..aOM<$3.Timestamp>(13, _omitFieldNames ? '' : 'decidedAt',
        subBuilder: $3.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalHistoryEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApprovalHistoryEntry copyWith(void Function(ApprovalHistoryEntry) updates) =>
      super.copyWith((message) => updates(message as ApprovalHistoryEntry))
          as ApprovalHistoryEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApprovalHistoryEntry create() => ApprovalHistoryEntry._();
  @$core.override
  ApprovalHistoryEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApprovalHistoryEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApprovalHistoryEntry>(create);
  static ApprovalHistoryEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get nodeName => $_getSZ(2);
  @$pb.TagNumber(3)
  set nodeName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeName() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get proxyId => $_getSZ(3);
  @$pb.TagNumber(4)
  set proxyId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProxyId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProxyId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get proxyName => $_getSZ(4);
  @$pb.TagNumber(5)
  set proxyName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProxyName() => $_has(4);
  @$pb.TagNumber(5)
  void clearProxyName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get sourceIp => $_getSZ(5);
  @$pb.TagNumber(6)
  set sourceIp($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSourceIp() => $_has(5);
  @$pb.TagNumber(6)
  void clearSourceIp() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get destAddr => $_getSZ(6);
  @$pb.TagNumber(7)
  set destAddr($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDestAddr() => $_has(6);
  @$pb.TagNumber(7)
  void clearDestAddr() => $_clearField(7);

  @$pb.TagNumber(8)
  $5.GeoInfo get geo => $_getN(7);
  @$pb.TagNumber(8)
  set geo($5.GeoInfo value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasGeo() => $_has(7);
  @$pb.TagNumber(8)
  void clearGeo() => $_clearField(8);
  @$pb.TagNumber(8)
  $5.GeoInfo ensureGeo() => $_ensure(7);

  @$pb.TagNumber(9)
  ApprovalHistoryAction get action => $_getN(8);
  @$pb.TagNumber(9)
  set action(ApprovalHistoryAction value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasAction() => $_has(8);
  @$pb.TagNumber(9)
  void clearAction() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get durationSeconds => $_getI64(9);
  @$pb.TagNumber(10)
  set durationSeconds($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDurationSeconds() => $_has(9);
  @$pb.TagNumber(10)
  void clearDurationSeconds() => $_clearField(10);

  @$pb.TagNumber(11)
  DenyBlockType get blockType => $_getN(10);
  @$pb.TagNumber(11)
  set blockType(DenyBlockType value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasBlockType() => $_has(10);
  @$pb.TagNumber(11)
  void clearBlockType() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get ruleId => $_getSZ(11);
  @$pb.TagNumber(12)
  set ruleId($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasRuleId() => $_has(11);
  @$pb.TagNumber(12)
  void clearRuleId() => $_clearField(12);

  @$pb.TagNumber(13)
  $3.Timestamp get decidedAt => $_getN(12);
  @$pb.TagNumber(13)
  set decidedAt($3.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasDecidedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearDecidedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $3.Timestamp ensureDecidedAt() => $_ensure(12);
}

class ListApprovalHistoryRequest extends $pb.GeneratedMessage {
  factory ListApprovalHistoryRequest({
    $core.String? nodeId,
    $core.int? limit,
    $core.int? offset,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (limit != null) result.limit = limit;
    if (offset != null) result.offset = offset;
    return result;
  }

  ListApprovalHistoryRequest._();

  factory ListApprovalHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListApprovalHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListApprovalHistoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aI(2, _omitFieldNames ? '' : 'limit')
    ..aI(3, _omitFieldNames ? '' : 'offset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListApprovalHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListApprovalHistoryRequest copyWith(
          void Function(ListApprovalHistoryRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ListApprovalHistoryRequest))
          as ListApprovalHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListApprovalHistoryRequest create() => ListApprovalHistoryRequest._();
  @$core.override
  ListApprovalHistoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListApprovalHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListApprovalHistoryRequest>(create);
  static ListApprovalHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

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

class ListApprovalHistoryResponse extends $pb.GeneratedMessage {
  factory ListApprovalHistoryResponse({
    $core.Iterable<ApprovalHistoryEntry>? entries,
    $core.int? totalCount,
  }) {
    final result = create();
    if (entries != null) result.entries.addAll(entries);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListApprovalHistoryResponse._();

  factory ListApprovalHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListApprovalHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListApprovalHistoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<ApprovalHistoryEntry>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: ApprovalHistoryEntry.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListApprovalHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListApprovalHistoryResponse copyWith(
          void Function(ListApprovalHistoryResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListApprovalHistoryResponse))
          as ListApprovalHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListApprovalHistoryResponse create() =>
      ListApprovalHistoryResponse._();
  @$core.override
  ListApprovalHistoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListApprovalHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListApprovalHistoryResponse>(create);
  static ListApprovalHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ApprovalHistoryEntry> get entries => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class ClearApprovalHistoryRequest extends $pb.GeneratedMessage {
  factory ClearApprovalHistoryRequest() => create();

  ClearApprovalHistoryRequest._();

  factory ClearApprovalHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClearApprovalHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClearApprovalHistoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearApprovalHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearApprovalHistoryRequest copyWith(
          void Function(ClearApprovalHistoryRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ClearApprovalHistoryRequest))
          as ClearApprovalHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClearApprovalHistoryRequest create() =>
      ClearApprovalHistoryRequest._();
  @$core.override
  ClearApprovalHistoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClearApprovalHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClearApprovalHistoryRequest>(create);
  static ClearApprovalHistoryRequest? _defaultInstance;
}

class ClearApprovalHistoryResponse extends $pb.GeneratedMessage {
  factory ClearApprovalHistoryResponse({
    $core.bool? success,
    $core.String? error,
    $core.int? deletedCount,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (deletedCount != null) result.deletedCount = deletedCount;
    return result;
  }

  ClearApprovalHistoryResponse._();

  factory ClearApprovalHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClearApprovalHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClearApprovalHistoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aI(3, _omitFieldNames ? '' : 'deletedCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearApprovalHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearApprovalHistoryResponse copyWith(
          void Function(ClearApprovalHistoryResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ClearApprovalHistoryResponse))
          as ClearApprovalHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClearApprovalHistoryResponse create() =>
      ClearApprovalHistoryResponse._();
  @$core.override
  ClearApprovalHistoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClearApprovalHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClearApprovalHistoryResponse>(create);
  static ClearApprovalHistoryResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.int get deletedCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set deletedCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeletedCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeletedCount() => $_clearField(3);
}

class ConnectionStats extends $pb.GeneratedMessage {
  factory ConnectionStats({
    $fixnum.Int64? activeConnections,
    $fixnum.Int64? totalConnections,
    $fixnum.Int64? bytesIn,
    $fixnum.Int64? bytesOut,
    $fixnum.Int64? blockedTotal,
    $fixnum.Int64? allowedTotal,
    $fixnum.Int64? uniqueIps,
    $fixnum.Int64? uniqueCountries,
    $fixnum.Int64? pendingApprovals,
    $core.int? recommendedPollIntervalSeconds,
  }) {
    final result = create();
    if (activeConnections != null) result.activeConnections = activeConnections;
    if (totalConnections != null) result.totalConnections = totalConnections;
    if (bytesIn != null) result.bytesIn = bytesIn;
    if (bytesOut != null) result.bytesOut = bytesOut;
    if (blockedTotal != null) result.blockedTotal = blockedTotal;
    if (allowedTotal != null) result.allowedTotal = allowedTotal;
    if (uniqueIps != null) result.uniqueIps = uniqueIps;
    if (uniqueCountries != null) result.uniqueCountries = uniqueCountries;
    if (pendingApprovals != null) result.pendingApprovals = pendingApprovals;
    if (recommendedPollIntervalSeconds != null)
      result.recommendedPollIntervalSeconds = recommendedPollIntervalSeconds;
    return result;
  }

  ConnectionStats._();

  factory ConnectionStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConnectionStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnectionStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'activeConnections')
    ..aInt64(2, _omitFieldNames ? '' : 'totalConnections')
    ..aInt64(3, _omitFieldNames ? '' : 'bytesIn')
    ..aInt64(4, _omitFieldNames ? '' : 'bytesOut')
    ..aInt64(5, _omitFieldNames ? '' : 'blockedTotal')
    ..aInt64(6, _omitFieldNames ? '' : 'allowedTotal')
    ..aInt64(7, _omitFieldNames ? '' : 'uniqueIps')
    ..aInt64(8, _omitFieldNames ? '' : 'uniqueCountries')
    ..aInt64(9, _omitFieldNames ? '' : 'pendingApprovals')
    ..aI(10, _omitFieldNames ? '' : 'recommendedPollIntervalSeconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectionStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectionStats copyWith(void Function(ConnectionStats) updates) =>
      super.copyWith((message) => updates(message as ConnectionStats))
          as ConnectionStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnectionStats create() => ConnectionStats._();
  @$core.override
  ConnectionStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConnectionStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConnectionStats>(create);
  static ConnectionStats? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get activeConnections => $_getI64(0);
  @$pb.TagNumber(1)
  set activeConnections($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasActiveConnections() => $_has(0);
  @$pb.TagNumber(1)
  void clearActiveConnections() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalConnections => $_getI64(1);
  @$pb.TagNumber(2)
  set totalConnections($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalConnections() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalConnections() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get bytesIn => $_getI64(2);
  @$pb.TagNumber(3)
  set bytesIn($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBytesIn() => $_has(2);
  @$pb.TagNumber(3)
  void clearBytesIn() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get bytesOut => $_getI64(3);
  @$pb.TagNumber(4)
  set bytesOut($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBytesOut() => $_has(3);
  @$pb.TagNumber(4)
  void clearBytesOut() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get blockedTotal => $_getI64(4);
  @$pb.TagNumber(5)
  set blockedTotal($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBlockedTotal() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlockedTotal() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get allowedTotal => $_getI64(5);
  @$pb.TagNumber(6)
  set allowedTotal($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAllowedTotal() => $_has(5);
  @$pb.TagNumber(6)
  void clearAllowedTotal() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get uniqueIps => $_getI64(6);
  @$pb.TagNumber(7)
  set uniqueIps($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUniqueIps() => $_has(6);
  @$pb.TagNumber(7)
  void clearUniqueIps() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get uniqueCountries => $_getI64(7);
  @$pb.TagNumber(8)
  set uniqueCountries($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUniqueCountries() => $_has(7);
  @$pb.TagNumber(8)
  void clearUniqueCountries() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get pendingApprovals => $_getI64(8);
  @$pb.TagNumber(9)
  set pendingApprovals($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPendingApprovals() => $_has(8);
  @$pb.TagNumber(9)
  void clearPendingApprovals() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get recommendedPollIntervalSeconds => $_getIZ(9);
  @$pb.TagNumber(10)
  set recommendedPollIntervalSeconds($core.int value) =>
      $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRecommendedPollIntervalSeconds() => $_has(9);
  @$pb.TagNumber(10)
  void clearRecommendedPollIntervalSeconds() => $_clearField(10);
}

class GetConnectionStatsRequest extends $pb.GeneratedMessage {
  factory GetConnectionStatsRequest({
    $core.String? nodeId,
    $core.String? proxyId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    return result;
  }

  GetConnectionStatsRequest._();

  factory GetConnectionStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetConnectionStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetConnectionStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConnectionStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConnectionStatsRequest copyWith(
          void Function(GetConnectionStatsRequest) updates) =>
      super.copyWith((message) => updates(message as GetConnectionStatsRequest))
          as GetConnectionStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetConnectionStatsRequest create() => GetConnectionStatsRequest._();
  @$core.override
  GetConnectionStatsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetConnectionStatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetConnectionStatsRequest>(create);
  static GetConnectionStatsRequest? _defaultInstance;

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

class ConnectionInfo extends $pb.GeneratedMessage {
  factory ConnectionInfo({
    $core.String? connId,
    $core.String? nodeId,
    $core.String? proxyId,
    $core.String? sourceIp,
    $core.int? sourcePort,
    $core.String? destAddr,
    $3.Timestamp? startTime,
    $fixnum.Int64? bytesIn,
    $fixnum.Int64? bytesOut,
    $5.GeoInfo? geo,
    $core.String? ruleMatched,
    $5.ActionType? action,
  }) {
    final result = create();
    if (connId != null) result.connId = connId;
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    if (sourceIp != null) result.sourceIp = sourceIp;
    if (sourcePort != null) result.sourcePort = sourcePort;
    if (destAddr != null) result.destAddr = destAddr;
    if (startTime != null) result.startTime = startTime;
    if (bytesIn != null) result.bytesIn = bytesIn;
    if (bytesOut != null) result.bytesOut = bytesOut;
    if (geo != null) result.geo = geo;
    if (ruleMatched != null) result.ruleMatched = ruleMatched;
    if (action != null) result.action = action;
    return result;
  }

  ConnectionInfo._();

  factory ConnectionInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConnectionInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnectionInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'connId')
    ..aOS(2, _omitFieldNames ? '' : 'nodeId')
    ..aOS(3, _omitFieldNames ? '' : 'proxyId')
    ..aOS(4, _omitFieldNames ? '' : 'sourceIp')
    ..aI(5, _omitFieldNames ? '' : 'sourcePort')
    ..aOS(6, _omitFieldNames ? '' : 'destAddr')
    ..aOM<$3.Timestamp>(7, _omitFieldNames ? '' : 'startTime',
        subBuilder: $3.Timestamp.create)
    ..aInt64(8, _omitFieldNames ? '' : 'bytesIn')
    ..aInt64(9, _omitFieldNames ? '' : 'bytesOut')
    ..aOM<$5.GeoInfo>(10, _omitFieldNames ? '' : 'geo',
        subBuilder: $5.GeoInfo.create)
    ..aOS(11, _omitFieldNames ? '' : 'ruleMatched')
    ..aE<$5.ActionType>(12, _omitFieldNames ? '' : 'action',
        enumValues: $5.ActionType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectionInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectionInfo copyWith(void Function(ConnectionInfo) updates) =>
      super.copyWith((message) => updates(message as ConnectionInfo))
          as ConnectionInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnectionInfo create() => ConnectionInfo._();
  @$core.override
  ConnectionInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConnectionInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConnectionInfo>(create);
  static ConnectionInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get connId => $_getSZ(0);
  @$pb.TagNumber(1)
  set connId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConnId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConnId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get proxyId => $_getSZ(2);
  @$pb.TagNumber(3)
  set proxyId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProxyId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProxyId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sourceIp => $_getSZ(3);
  @$pb.TagNumber(4)
  set sourceIp($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSourceIp() => $_has(3);
  @$pb.TagNumber(4)
  void clearSourceIp() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get sourcePort => $_getIZ(4);
  @$pb.TagNumber(5)
  set sourcePort($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSourcePort() => $_has(4);
  @$pb.TagNumber(5)
  void clearSourcePort() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get destAddr => $_getSZ(5);
  @$pb.TagNumber(6)
  set destAddr($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDestAddr() => $_has(5);
  @$pb.TagNumber(6)
  void clearDestAddr() => $_clearField(6);

  @$pb.TagNumber(7)
  $3.Timestamp get startTime => $_getN(6);
  @$pb.TagNumber(7)
  set startTime($3.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStartTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearStartTime() => $_clearField(7);
  @$pb.TagNumber(7)
  $3.Timestamp ensureStartTime() => $_ensure(6);

  @$pb.TagNumber(8)
  $fixnum.Int64 get bytesIn => $_getI64(7);
  @$pb.TagNumber(8)
  set bytesIn($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBytesIn() => $_has(7);
  @$pb.TagNumber(8)
  void clearBytesIn() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get bytesOut => $_getI64(8);
  @$pb.TagNumber(9)
  set bytesOut($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasBytesOut() => $_has(8);
  @$pb.TagNumber(9)
  void clearBytesOut() => $_clearField(9);

  @$pb.TagNumber(10)
  $5.GeoInfo get geo => $_getN(9);
  @$pb.TagNumber(10)
  set geo($5.GeoInfo value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasGeo() => $_has(9);
  @$pb.TagNumber(10)
  void clearGeo() => $_clearField(10);
  @$pb.TagNumber(10)
  $5.GeoInfo ensureGeo() => $_ensure(9);

  @$pb.TagNumber(11)
  $core.String get ruleMatched => $_getSZ(10);
  @$pb.TagNumber(11)
  set ruleMatched($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasRuleMatched() => $_has(10);
  @$pb.TagNumber(11)
  void clearRuleMatched() => $_clearField(11);

  @$pb.TagNumber(12)
  $5.ActionType get action => $_getN(11);
  @$pb.TagNumber(12)
  set action($5.ActionType value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasAction() => $_has(11);
  @$pb.TagNumber(12)
  void clearAction() => $_clearField(12);
}

class ListConnectionsRequest extends $pb.GeneratedMessage {
  factory ListConnectionsRequest({
    $core.String? nodeId,
    $core.String? proxyId,
    $core.bool? activeOnly,
    $core.int? limit,
    $core.int? offset,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    if (activeOnly != null) result.activeOnly = activeOnly;
    if (limit != null) result.limit = limit;
    if (offset != null) result.offset = offset;
    return result;
  }

  ListConnectionsRequest._();

  factory ListConnectionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListConnectionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListConnectionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..aOB(3, _omitFieldNames ? '' : 'activeOnly')
    ..aI(4, _omitFieldNames ? '' : 'limit')
    ..aI(5, _omitFieldNames ? '' : 'offset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConnectionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConnectionsRequest copyWith(
          void Function(ListConnectionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListConnectionsRequest))
          as ListConnectionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListConnectionsRequest create() => ListConnectionsRequest._();
  @$core.override
  ListConnectionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListConnectionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListConnectionsRequest>(create);
  static ListConnectionsRequest? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.bool get activeOnly => $_getBF(2);
  @$pb.TagNumber(3)
  set activeOnly($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasActiveOnly() => $_has(2);
  @$pb.TagNumber(3)
  void clearActiveOnly() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get limit => $_getIZ(3);
  @$pb.TagNumber(4)
  set limit($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLimit() => $_has(3);
  @$pb.TagNumber(4)
  void clearLimit() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get offset => $_getIZ(4);
  @$pb.TagNumber(5)
  set offset($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOffset() => $_has(4);
  @$pb.TagNumber(5)
  void clearOffset() => $_clearField(5);
}

class ListConnectionsResponse extends $pb.GeneratedMessage {
  factory ListConnectionsResponse({
    $core.Iterable<ConnectionInfo>? connections,
    $core.int? totalCount,
  }) {
    final result = create();
    if (connections != null) result.connections.addAll(connections);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListConnectionsResponse._();

  factory ListConnectionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListConnectionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListConnectionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<ConnectionInfo>(1, _omitFieldNames ? '' : 'connections',
        subBuilder: ConnectionInfo.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConnectionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConnectionsResponse copyWith(
          void Function(ListConnectionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListConnectionsResponse))
          as ListConnectionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListConnectionsResponse create() => ListConnectionsResponse._();
  @$core.override
  ListConnectionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListConnectionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListConnectionsResponse>(create);
  static ListConnectionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ConnectionInfo> get connections => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class GetIPStatsRequest extends $pb.GeneratedMessage {
  factory GetIPStatsRequest({
    $core.String? nodeId,
    $core.int? limit,
    $core.int? offset,
    $core.String? sourceIpFilter,
    $core.String? countryFilter,
    $5.SortOrder? sortBy,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aI(2, _omitFieldNames ? '' : 'limit')
    ..aI(3, _omitFieldNames ? '' : 'offset')
    ..aOS(4, _omitFieldNames ? '' : 'sourceIpFilter')
    ..aOS(5, _omitFieldNames ? '' : 'countryFilter')
    ..aE<$5.SortOrder>(6, _omitFieldNames ? '' : 'sortBy',
        enumValues: $5.SortOrder.values)
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
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

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

  @$pb.TagNumber(4)
  $core.String get sourceIpFilter => $_getSZ(3);
  @$pb.TagNumber(4)
  set sourceIpFilter($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSourceIpFilter() => $_has(3);
  @$pb.TagNumber(4)
  void clearSourceIpFilter() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get countryFilter => $_getSZ(4);
  @$pb.TagNumber(5)
  set countryFilter($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCountryFilter() => $_has(4);
  @$pb.TagNumber(5)
  void clearCountryFilter() => $_clearField(5);

  @$pb.TagNumber(6)
  $5.SortOrder get sortBy => $_getN(5);
  @$pb.TagNumber(6)
  set sortBy($5.SortOrder value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasSortBy() => $_has(5);
  @$pb.TagNumber(6)
  void clearSortBy() => $_clearField(6);
}

class IPStats extends $pb.GeneratedMessage {
  factory IPStats({
    $core.String? sourceIp,
    $3.Timestamp? firstSeen,
    $3.Timestamp? lastSeen,
    $fixnum.Int64? connectionCount,
    $fixnum.Int64? totalBytesIn,
    $fixnum.Int64? totalBytesOut,
    $fixnum.Int64? blockedCount,
    $fixnum.Int64? allowedCount,
    $core.String? geoCountry,
    $core.String? geoCity,
    $core.String? geoIsp,
  }) {
    final result = create();
    if (sourceIp != null) result.sourceIp = sourceIp;
    if (firstSeen != null) result.firstSeen = firstSeen;
    if (lastSeen != null) result.lastSeen = lastSeen;
    if (connectionCount != null) result.connectionCount = connectionCount;
    if (totalBytesIn != null) result.totalBytesIn = totalBytesIn;
    if (totalBytesOut != null) result.totalBytesOut = totalBytesOut;
    if (blockedCount != null) result.blockedCount = blockedCount;
    if (allowedCount != null) result.allowedCount = allowedCount;
    if (geoCountry != null) result.geoCountry = geoCountry;
    if (geoCity != null) result.geoCity = geoCity;
    if (geoIsp != null) result.geoIsp = geoIsp;
    return result;
  }

  IPStats._();

  factory IPStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IPStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IPStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sourceIp')
    ..aOM<$3.Timestamp>(2, _omitFieldNames ? '' : 'firstSeen',
        subBuilder: $3.Timestamp.create)
    ..aOM<$3.Timestamp>(3, _omitFieldNames ? '' : 'lastSeen',
        subBuilder: $3.Timestamp.create)
    ..aInt64(4, _omitFieldNames ? '' : 'connectionCount')
    ..aInt64(5, _omitFieldNames ? '' : 'totalBytesIn')
    ..aInt64(6, _omitFieldNames ? '' : 'totalBytesOut')
    ..aInt64(7, _omitFieldNames ? '' : 'blockedCount')
    ..aInt64(8, _omitFieldNames ? '' : 'allowedCount')
    ..aOS(9, _omitFieldNames ? '' : 'geoCountry')
    ..aOS(10, _omitFieldNames ? '' : 'geoCity')
    ..aOS(11, _omitFieldNames ? '' : 'geoIsp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IPStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IPStats copyWith(void Function(IPStats) updates) =>
      super.copyWith((message) => updates(message as IPStats)) as IPStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IPStats create() => IPStats._();
  @$core.override
  IPStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IPStats getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IPStats>(create);
  static IPStats? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sourceIp => $_getSZ(0);
  @$pb.TagNumber(1)
  set sourceIp($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSourceIp() => $_has(0);
  @$pb.TagNumber(1)
  void clearSourceIp() => $_clearField(1);

  @$pb.TagNumber(2)
  $3.Timestamp get firstSeen => $_getN(1);
  @$pb.TagNumber(2)
  set firstSeen($3.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFirstSeen() => $_has(1);
  @$pb.TagNumber(2)
  void clearFirstSeen() => $_clearField(2);
  @$pb.TagNumber(2)
  $3.Timestamp ensureFirstSeen() => $_ensure(1);

  @$pb.TagNumber(3)
  $3.Timestamp get lastSeen => $_getN(2);
  @$pb.TagNumber(3)
  set lastSeen($3.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasLastSeen() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastSeen() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.Timestamp ensureLastSeen() => $_ensure(2);

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
  $fixnum.Int64 get blockedCount => $_getI64(6);
  @$pb.TagNumber(7)
  set blockedCount($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBlockedCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlockedCount() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get allowedCount => $_getI64(7);
  @$pb.TagNumber(8)
  set allowedCount($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAllowedCount() => $_has(7);
  @$pb.TagNumber(8)
  void clearAllowedCount() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get geoCountry => $_getSZ(8);
  @$pb.TagNumber(9)
  set geoCountry($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasGeoCountry() => $_has(8);
  @$pb.TagNumber(9)
  void clearGeoCountry() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get geoCity => $_getSZ(9);
  @$pb.TagNumber(10)
  set geoCity($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasGeoCity() => $_has(9);
  @$pb.TagNumber(10)
  void clearGeoCity() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get geoIsp => $_getSZ(10);
  @$pb.TagNumber(11)
  set geoIsp($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasGeoIsp() => $_has(10);
  @$pb.TagNumber(11)
  void clearGeoIsp() => $_clearField(11);
}

class GetIPStatsResponse extends $pb.GeneratedMessage {
  factory GetIPStatsResponse({
    $core.Iterable<IPStats>? stats,
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<IPStats>(1, _omitFieldNames ? '' : 'stats',
        subBuilder: IPStats.create)
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
  $pb.PbList<IPStats> get stats => $_getList(0);

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
    $core.String? nodeId,
    GeoStatsType? type,
    $core.int? limit,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (type != null) result.type = type;
    if (limit != null) result.limit = limit;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aE<GeoStatsType>(2, _omitFieldNames ? '' : 'type',
        enumValues: GeoStatsType.values)
    ..aI(3, _omitFieldNames ? '' : 'limit')
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
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  GeoStatsType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(GeoStatsType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);
}

class GeoStats extends $pb.GeneratedMessage {
  factory GeoStats({
    GeoStatsType? type,
    $core.String? value,
    $fixnum.Int64? connectionCount,
    $fixnum.Int64? uniqueIps,
    $fixnum.Int64? totalBytes,
    $fixnum.Int64? blockedCount,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (value != null) result.value = value;
    if (connectionCount != null) result.connectionCount = connectionCount;
    if (uniqueIps != null) result.uniqueIps = uniqueIps;
    if (totalBytes != null) result.totalBytes = totalBytes;
    if (blockedCount != null) result.blockedCount = blockedCount;
    return result;
  }

  GeoStats._();

  factory GeoStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GeoStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GeoStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aE<GeoStatsType>(1, _omitFieldNames ? '' : 'type',
        enumValues: GeoStatsType.values)
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..aInt64(3, _omitFieldNames ? '' : 'connectionCount')
    ..aInt64(4, _omitFieldNames ? '' : 'uniqueIps')
    ..aInt64(5, _omitFieldNames ? '' : 'totalBytes')
    ..aInt64(6, _omitFieldNames ? '' : 'blockedCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeoStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeoStats copyWith(void Function(GeoStats) updates) =>
      super.copyWith((message) => updates(message as GeoStats)) as GeoStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GeoStats create() => GeoStats._();
  @$core.override
  GeoStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GeoStats getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GeoStats>(create);
  static GeoStats? _defaultInstance;

  @$pb.TagNumber(1)
  GeoStatsType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(GeoStatsType value) => $_setField(1, value);
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
  $fixnum.Int64 get totalBytes => $_getI64(4);
  @$pb.TagNumber(5)
  set totalBytes($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalBytes() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get blockedCount => $_getI64(5);
  @$pb.TagNumber(6)
  set blockedCount($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBlockedCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlockedCount() => $_clearField(6);
}

class GetGeoStatsResponse extends $pb.GeneratedMessage {
  factory GetGeoStatsResponse({
    $core.Iterable<GeoStats>? stats,
    $core.int? totalCount,
  }) {
    final result = create();
    if (stats != null) result.stats.addAll(stats);
    if (totalCount != null) result.totalCount = totalCount;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<GeoStats>(1, _omitFieldNames ? '' : 'stats',
        subBuilder: GeoStats.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
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
  $pb.PbList<GeoStats> get stats => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class StreamConnectionsRequest extends $pb.GeneratedMessage {
  factory StreamConnectionsRequest({
    $core.String? nodeId,
    $core.String? proxyId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
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

class ConnectionEvent extends $pb.GeneratedMessage {
  factory ConnectionEvent({
    $core.String? connId,
    $core.String? nodeId,
    $core.String? proxyId,
    $core.String? sourceIp,
    $core.int? sourcePort,
    $core.String? destAddr,
    ConnectionEvent_EventType? eventType,
    $3.Timestamp? timestamp,
    $core.String? ruleMatched,
    $5.ActionType? actionTaken,
    $fixnum.Int64? bytesIn,
    $fixnum.Int64? bytesOut,
    $5.GeoInfo? geo,
  }) {
    final result = create();
    if (connId != null) result.connId = connId;
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    if (sourceIp != null) result.sourceIp = sourceIp;
    if (sourcePort != null) result.sourcePort = sourcePort;
    if (destAddr != null) result.destAddr = destAddr;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'connId')
    ..aOS(2, _omitFieldNames ? '' : 'nodeId')
    ..aOS(3, _omitFieldNames ? '' : 'proxyId')
    ..aOS(4, _omitFieldNames ? '' : 'sourceIp')
    ..aI(5, _omitFieldNames ? '' : 'sourcePort')
    ..aOS(6, _omitFieldNames ? '' : 'destAddr')
    ..aE<ConnectionEvent_EventType>(7, _omitFieldNames ? '' : 'eventType',
        enumValues: ConnectionEvent_EventType.values)
    ..aOM<$3.Timestamp>(8, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $3.Timestamp.create)
    ..aOS(9, _omitFieldNames ? '' : 'ruleMatched')
    ..aE<$5.ActionType>(10, _omitFieldNames ? '' : 'actionTaken',
        enumValues: $5.ActionType.values)
    ..aInt64(11, _omitFieldNames ? '' : 'bytesIn')
    ..aInt64(12, _omitFieldNames ? '' : 'bytesOut')
    ..aOM<$5.GeoInfo>(13, _omitFieldNames ? '' : 'geo',
        subBuilder: $5.GeoInfo.create)
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
  $core.String get nodeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get proxyId => $_getSZ(2);
  @$pb.TagNumber(3)
  set proxyId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProxyId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProxyId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sourceIp => $_getSZ(3);
  @$pb.TagNumber(4)
  set sourceIp($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSourceIp() => $_has(3);
  @$pb.TagNumber(4)
  void clearSourceIp() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get sourcePort => $_getIZ(4);
  @$pb.TagNumber(5)
  set sourcePort($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSourcePort() => $_has(4);
  @$pb.TagNumber(5)
  void clearSourcePort() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get destAddr => $_getSZ(5);
  @$pb.TagNumber(6)
  set destAddr($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDestAddr() => $_has(5);
  @$pb.TagNumber(6)
  void clearDestAddr() => $_clearField(6);

  @$pb.TagNumber(7)
  ConnectionEvent_EventType get eventType => $_getN(6);
  @$pb.TagNumber(7)
  set eventType(ConnectionEvent_EventType value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasEventType() => $_has(6);
  @$pb.TagNumber(7)
  void clearEventType() => $_clearField(7);

  @$pb.TagNumber(8)
  $3.Timestamp get timestamp => $_getN(7);
  @$pb.TagNumber(8)
  set timestamp($3.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasTimestamp() => $_has(7);
  @$pb.TagNumber(8)
  void clearTimestamp() => $_clearField(8);
  @$pb.TagNumber(8)
  $3.Timestamp ensureTimestamp() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.String get ruleMatched => $_getSZ(8);
  @$pb.TagNumber(9)
  set ruleMatched($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRuleMatched() => $_has(8);
  @$pb.TagNumber(9)
  void clearRuleMatched() => $_clearField(9);

  @$pb.TagNumber(10)
  $5.ActionType get actionTaken => $_getN(9);
  @$pb.TagNumber(10)
  set actionTaken($5.ActionType value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasActionTaken() => $_has(9);
  @$pb.TagNumber(10)
  void clearActionTaken() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get bytesIn => $_getI64(10);
  @$pb.TagNumber(11)
  set bytesIn($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasBytesIn() => $_has(10);
  @$pb.TagNumber(11)
  void clearBytesIn() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get bytesOut => $_getI64(11);
  @$pb.TagNumber(12)
  set bytesOut($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasBytesOut() => $_has(11);
  @$pb.TagNumber(12)
  void clearBytesOut() => $_clearField(12);

  @$pb.TagNumber(13)
  $5.GeoInfo get geo => $_getN(12);
  @$pb.TagNumber(13)
  set geo($5.GeoInfo value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasGeo() => $_has(12);
  @$pb.TagNumber(13)
  void clearGeo() => $_clearField(13);
  @$pb.TagNumber(13)
  $5.GeoInfo ensureGeo() => $_ensure(12);
}

enum CloseConnectionRequest_Identifier { connId, sourceIp, notSet }

class CloseConnectionRequest extends $pb.GeneratedMessage {
  factory CloseConnectionRequest({
    $core.String? nodeId,
    $core.String? proxyId,
    $core.String? connId,
    $core.String? sourceIp,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    if (connId != null) result.connId = connId;
    if (sourceIp != null) result.sourceIp = sourceIp;
    return result;
  }

  CloseConnectionRequest._();

  factory CloseConnectionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CloseConnectionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, CloseConnectionRequest_Identifier>
      _CloseConnectionRequest_IdentifierByTag = {
    3: CloseConnectionRequest_Identifier.connId,
    4: CloseConnectionRequest_Identifier.sourceIp,
    0: CloseConnectionRequest_Identifier.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CloseConnectionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..oo(0, [3, 4])
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..aOS(3, _omitFieldNames ? '' : 'connId')
    ..aOS(4, _omitFieldNames ? '' : 'sourceIp')
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

  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  CloseConnectionRequest_Identifier whichIdentifier() =>
      _CloseConnectionRequest_IdentifierByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  void clearIdentifier() => $_clearField($_whichOneof(0));

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

  @$pb.TagNumber(3)
  $core.String get connId => $_getSZ(2);
  @$pb.TagNumber(3)
  set connId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConnId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConnId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sourceIp => $_getSZ(3);
  @$pb.TagNumber(4)
  set sourceIp($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSourceIp() => $_has(3);
  @$pb.TagNumber(4)
  void clearSourceIp() => $_clearField(4);
}

class CloseConnectionResponse extends $pb.GeneratedMessage {
  factory CloseConnectionResponse({
    $core.bool? success,
    $core.String? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
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
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
}

class CloseAllConnectionsRequest extends $pb.GeneratedMessage {
  factory CloseAllConnectionsRequest({
    $core.String? nodeId,
    $core.String? proxyId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
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

class CloseAllConnectionsResponse extends $pb.GeneratedMessage {
  factory CloseAllConnectionsResponse({
    $core.bool? success,
    $core.String? error,
    $core.int? closedCount,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (closedCount != null) result.closedCount = closedCount;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aI(3, _omitFieldNames ? '' : 'closedCount')
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
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get closedCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set closedCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasClosedCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearClosedCount() => $_clearField(3);
}

class CloseAllNodeConnectionsRequest extends $pb.GeneratedMessage {
  factory CloseAllNodeConnectionsRequest({
    $core.String? nodeId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    return result;
  }

  CloseAllNodeConnectionsRequest._();

  factory CloseAllNodeConnectionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CloseAllNodeConnectionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CloseAllNodeConnectionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseAllNodeConnectionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseAllNodeConnectionsRequest copyWith(
          void Function(CloseAllNodeConnectionsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CloseAllNodeConnectionsRequest))
          as CloseAllNodeConnectionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CloseAllNodeConnectionsRequest create() =>
      CloseAllNodeConnectionsRequest._();
  @$core.override
  CloseAllNodeConnectionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CloseAllNodeConnectionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CloseAllNodeConnectionsRequest>(create);
  static CloseAllNodeConnectionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);
}

class CloseAllNodeConnectionsResponse extends $pb.GeneratedMessage {
  factory CloseAllNodeConnectionsResponse({
    $core.bool? success,
    $core.String? error,
    $core.int? processedProxyCount,
    $core.int? closedCount,
    $core.Iterable<$core.String>? failedProxyIds,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (processedProxyCount != null)
      result.processedProxyCount = processedProxyCount;
    if (closedCount != null) result.closedCount = closedCount;
    if (failedProxyIds != null) result.failedProxyIds.addAll(failedProxyIds);
    return result;
  }

  CloseAllNodeConnectionsResponse._();

  factory CloseAllNodeConnectionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CloseAllNodeConnectionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CloseAllNodeConnectionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aI(3, _omitFieldNames ? '' : 'processedProxyCount')
    ..aI(4, _omitFieldNames ? '' : 'closedCount')
    ..pPS(5, _omitFieldNames ? '' : 'failedProxyIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseAllNodeConnectionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseAllNodeConnectionsResponse copyWith(
          void Function(CloseAllNodeConnectionsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CloseAllNodeConnectionsResponse))
          as CloseAllNodeConnectionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CloseAllNodeConnectionsResponse create() =>
      CloseAllNodeConnectionsResponse._();
  @$core.override
  CloseAllNodeConnectionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CloseAllNodeConnectionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CloseAllNodeConnectionsResponse>(
          create);
  static CloseAllNodeConnectionsResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.int get processedProxyCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set processedProxyCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProcessedProxyCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearProcessedProxyCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get closedCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set closedCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClosedCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearClosedCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get failedProxyIds => $_getList(4);
}

class StartPairingRequest extends $pb.GeneratedMessage {
  factory StartPairingRequest({
    $core.String? nodeName,
  }) {
    final result = create();
    if (nodeName != null) result.nodeName = nodeName;
    return result;
  }

  StartPairingRequest._();

  factory StartPairingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StartPairingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StartPairingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartPairingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartPairingRequest copyWith(void Function(StartPairingRequest) updates) =>
      super.copyWith((message) => updates(message as StartPairingRequest))
          as StartPairingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartPairingRequest create() => StartPairingRequest._();
  @$core.override
  StartPairingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StartPairingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StartPairingRequest>(create);
  static StartPairingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeName => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeName() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeName() => $_clearField(1);
}

class StartPairingResponse extends $pb.GeneratedMessage {
  factory StartPairingResponse({
    $core.String? sessionId,
    $core.String? pairingCode,
    $core.int? expiresInSeconds,
  }) {
    final result = create();
    if (sessionId != null) result.sessionId = sessionId;
    if (pairingCode != null) result.pairingCode = pairingCode;
    if (expiresInSeconds != null) result.expiresInSeconds = expiresInSeconds;
    return result;
  }

  StartPairingResponse._();

  factory StartPairingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StartPairingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StartPairingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'pairingCode')
    ..aI(3, _omitFieldNames ? '' : 'expiresInSeconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartPairingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartPairingResponse copyWith(void Function(StartPairingResponse) updates) =>
      super.copyWith((message) => updates(message as StartPairingResponse))
          as StartPairingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartPairingResponse create() => StartPairingResponse._();
  @$core.override
  StartPairingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StartPairingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StartPairingResponse>(create);
  static StartPairingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pairingCode => $_getSZ(1);
  @$pb.TagNumber(2)
  set pairingCode($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPairingCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearPairingCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get expiresInSeconds => $_getIZ(2);
  @$pb.TagNumber(3)
  set expiresInSeconds($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpiresInSeconds() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpiresInSeconds() => $_clearField(3);
}

class JoinPairingRequest extends $pb.GeneratedMessage {
  factory JoinPairingRequest({
    $core.String? pairingCode,
  }) {
    final result = create();
    if (pairingCode != null) result.pairingCode = pairingCode;
    return result;
  }

  JoinPairingRequest._();

  factory JoinPairingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinPairingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinPairingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pairingCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinPairingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinPairingRequest copyWith(void Function(JoinPairingRequest) updates) =>
      super.copyWith((message) => updates(message as JoinPairingRequest))
          as JoinPairingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinPairingRequest create() => JoinPairingRequest._();
  @$core.override
  JoinPairingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinPairingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinPairingRequest>(create);
  static JoinPairingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pairingCode => $_getSZ(0);
  @$pb.TagNumber(1)
  set pairingCode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPairingCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearPairingCode() => $_clearField(1);
}

class JoinPairingResponse extends $pb.GeneratedMessage {
  factory JoinPairingResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? sessionId,
    $core.String? emojiFingerprint,
    $core.String? nodeName,
    $core.String? fingerprint,
    $core.String? emojiHash,
    $core.String? csrFingerprint,
    $core.String? csrHash,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (sessionId != null) result.sessionId = sessionId;
    if (emojiFingerprint != null) result.emojiFingerprint = emojiFingerprint;
    if (nodeName != null) result.nodeName = nodeName;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (emojiHash != null) result.emojiHash = emojiHash;
    if (csrFingerprint != null) result.csrFingerprint = csrFingerprint;
    if (csrHash != null) result.csrHash = csrHash;
    return result;
  }

  JoinPairingResponse._();

  factory JoinPairingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinPairingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinPairingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'sessionId')
    ..aOS(4, _omitFieldNames ? '' : 'emojiFingerprint')
    ..aOS(5, _omitFieldNames ? '' : 'nodeName')
    ..aOS(6, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(7, _omitFieldNames ? '' : 'emojiHash')
    ..aOS(8, _omitFieldNames ? '' : 'csrFingerprint')
    ..aOS(9, _omitFieldNames ? '' : 'csrHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinPairingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinPairingResponse copyWith(void Function(JoinPairingResponse) updates) =>
      super.copyWith((message) => updates(message as JoinPairingResponse))
          as JoinPairingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinPairingResponse create() => JoinPairingResponse._();
  @$core.override
  JoinPairingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinPairingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinPairingResponse>(create);
  static JoinPairingResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get sessionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sessionId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSessionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSessionId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get emojiFingerprint => $_getSZ(3);
  @$pb.TagNumber(4)
  set emojiFingerprint($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEmojiFingerprint() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmojiFingerprint() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get nodeName => $_getSZ(4);
  @$pb.TagNumber(5)
  set nodeName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNodeName() => $_has(4);
  @$pb.TagNumber(5)
  void clearNodeName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get fingerprint => $_getSZ(5);
  @$pb.TagNumber(6)
  set fingerprint($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFingerprint() => $_has(5);
  @$pb.TagNumber(6)
  void clearFingerprint() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get emojiHash => $_getSZ(6);
  @$pb.TagNumber(7)
  set emojiHash($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEmojiHash() => $_has(6);
  @$pb.TagNumber(7)
  void clearEmojiHash() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get csrFingerprint => $_getSZ(7);
  @$pb.TagNumber(8)
  set csrFingerprint($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCsrFingerprint() => $_has(7);
  @$pb.TagNumber(8)
  void clearCsrFingerprint() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get csrHash => $_getSZ(8);
  @$pb.TagNumber(9)
  set csrHash($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCsrHash() => $_has(8);
  @$pb.TagNumber(9)
  void clearCsrHash() => $_clearField(9);
}

class CompletePairingRequest extends $pb.GeneratedMessage {
  factory CompletePairingRequest({
    $core.String? sessionId,
  }) {
    final result = create();
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  CompletePairingRequest._();

  factory CompletePairingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CompletePairingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CompletePairingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompletePairingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompletePairingRequest copyWith(
          void Function(CompletePairingRequest) updates) =>
      super.copyWith((message) => updates(message as CompletePairingRequest))
          as CompletePairingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CompletePairingRequest create() => CompletePairingRequest._();
  @$core.override
  CompletePairingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CompletePairingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CompletePairingRequest>(create);
  static CompletePairingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);
}

class CompletePairingResponse extends $pb.GeneratedMessage {
  factory CompletePairingResponse({
    $core.bool? success,
    $core.String? error,
    NodeInfo? node,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (node != null) result.node = node;
    return result;
  }

  CompletePairingResponse._();

  factory CompletePairingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CompletePairingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CompletePairingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOM<NodeInfo>(3, _omitFieldNames ? '' : 'node',
        subBuilder: NodeInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompletePairingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompletePairingResponse copyWith(
          void Function(CompletePairingResponse) updates) =>
      super.copyWith((message) => updates(message as CompletePairingResponse))
          as CompletePairingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CompletePairingResponse create() => CompletePairingResponse._();
  @$core.override
  CompletePairingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CompletePairingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CompletePairingResponse>(create);
  static CompletePairingResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  NodeInfo get node => $_getN(2);
  @$pb.TagNumber(3)
  set node(NodeInfo value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasNode() => $_has(2);
  @$pb.TagNumber(3)
  void clearNode() => $_clearField(3);
  @$pb.TagNumber(3)
  NodeInfo ensureNode() => $_ensure(2);
}

class FinalizePairingRequest extends $pb.GeneratedMessage {
  factory FinalizePairingRequest({
    $core.String? sessionId,
    $core.bool? accepted,
    $core.String? nodeName,
  }) {
    final result = create();
    if (sessionId != null) result.sessionId = sessionId;
    if (accepted != null) result.accepted = accepted;
    if (nodeName != null) result.nodeName = nodeName;
    return result;
  }

  FinalizePairingRequest._();

  factory FinalizePairingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FinalizePairingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FinalizePairingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOB(2, _omitFieldNames ? '' : 'accepted')
    ..aOS(3, _omitFieldNames ? '' : 'nodeName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FinalizePairingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FinalizePairingRequest copyWith(
          void Function(FinalizePairingRequest) updates) =>
      super.copyWith((message) => updates(message as FinalizePairingRequest))
          as FinalizePairingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FinalizePairingRequest create() => FinalizePairingRequest._();
  @$core.override
  FinalizePairingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FinalizePairingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FinalizePairingRequest>(create);
  static FinalizePairingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get accepted => $_getBF(1);
  @$pb.TagNumber(2)
  set accepted($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAccepted() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccepted() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get nodeName => $_getSZ(2);
  @$pb.TagNumber(3)
  set nodeName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeName() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeName() => $_clearField(3);
}

class FinalizePairingResponse extends $pb.GeneratedMessage {
  factory FinalizePairingResponse({
    $core.bool? success,
    $core.String? error,
    $core.bool? completed,
    $core.bool? cancelled,
    NodeInfo? node,
    $core.List<$core.int>? qrData,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (completed != null) result.completed = completed;
    if (cancelled != null) result.cancelled = cancelled;
    if (node != null) result.node = node;
    if (qrData != null) result.qrData = qrData;
    return result;
  }

  FinalizePairingResponse._();

  factory FinalizePairingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FinalizePairingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FinalizePairingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOB(3, _omitFieldNames ? '' : 'completed')
    ..aOB(4, _omitFieldNames ? '' : 'cancelled')
    ..aOM<NodeInfo>(5, _omitFieldNames ? '' : 'node',
        subBuilder: NodeInfo.create)
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'qrData', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FinalizePairingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FinalizePairingResponse copyWith(
          void Function(FinalizePairingResponse) updates) =>
      super.copyWith((message) => updates(message as FinalizePairingResponse))
          as FinalizePairingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FinalizePairingResponse create() => FinalizePairingResponse._();
  @$core.override
  FinalizePairingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FinalizePairingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FinalizePairingResponse>(create);
  static FinalizePairingResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.bool get completed => $_getBF(2);
  @$pb.TagNumber(3)
  set completed($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCompleted() => $_has(2);
  @$pb.TagNumber(3)
  void clearCompleted() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get cancelled => $_getBF(3);
  @$pb.TagNumber(4)
  set cancelled($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCancelled() => $_has(3);
  @$pb.TagNumber(4)
  void clearCancelled() => $_clearField(4);

  @$pb.TagNumber(5)
  NodeInfo get node => $_getN(4);
  @$pb.TagNumber(5)
  set node(NodeInfo value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasNode() => $_has(4);
  @$pb.TagNumber(5)
  void clearNode() => $_clearField(5);
  @$pb.TagNumber(5)
  NodeInfo ensureNode() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.List<$core.int> get qrData => $_getN(5);
  @$pb.TagNumber(6)
  set qrData($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasQrData() => $_has(5);
  @$pb.TagNumber(6)
  void clearQrData() => $_clearField(6);
}

class CancelPairingRequest extends $pb.GeneratedMessage {
  factory CancelPairingRequest({
    $core.String? sessionId,
  }) {
    final result = create();
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  CancelPairingRequest._();

  factory CancelPairingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CancelPairingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelPairingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelPairingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelPairingRequest copyWith(void Function(CancelPairingRequest) updates) =>
      super.copyWith((message) => updates(message as CancelPairingRequest))
          as CancelPairingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelPairingRequest create() => CancelPairingRequest._();
  @$core.override
  CancelPairingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CancelPairingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelPairingRequest>(create);
  static CancelPairingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);
}

class GenerateQRCodeRequest extends $pb.GeneratedMessage {
  factory GenerateQRCodeRequest() => create();

  GenerateQRCodeRequest._();

  factory GenerateQRCodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateQRCodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateQRCodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateQRCodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateQRCodeRequest copyWith(
          void Function(GenerateQRCodeRequest) updates) =>
      super.copyWith((message) => updates(message as GenerateQRCodeRequest))
          as GenerateQRCodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateQRCodeRequest create() => GenerateQRCodeRequest._();
  @$core.override
  GenerateQRCodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateQRCodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateQRCodeRequest>(create);
  static GenerateQRCodeRequest? _defaultInstance;
}

class GenerateQRCodeResponse extends $pb.GeneratedMessage {
  factory GenerateQRCodeResponse({
    $core.List<$core.int>? qrData,
    $core.String? fingerprint,
  }) {
    final result = create();
    if (qrData != null) result.qrData = qrData;
    if (fingerprint != null) result.fingerprint = fingerprint;
    return result;
  }

  GenerateQRCodeResponse._();

  factory GenerateQRCodeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateQRCodeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateQRCodeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'qrData', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'fingerprint')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateQRCodeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateQRCodeResponse copyWith(
          void Function(GenerateQRCodeResponse) updates) =>
      super.copyWith((message) => updates(message as GenerateQRCodeResponse))
          as GenerateQRCodeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateQRCodeResponse create() => GenerateQRCodeResponse._();
  @$core.override
  GenerateQRCodeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateQRCodeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateQRCodeResponse>(create);
  static GenerateQRCodeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get qrData => $_getN(0);
  @$pb.TagNumber(1)
  set qrData($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQrData() => $_has(0);
  @$pb.TagNumber(1)
  void clearQrData() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fingerprint => $_getSZ(1);
  @$pb.TagNumber(2)
  set fingerprint($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFingerprint() => $_has(1);
  @$pb.TagNumber(2)
  void clearFingerprint() => $_clearField(2);
}

class ScanQRCodeRequest extends $pb.GeneratedMessage {
  factory ScanQRCodeRequest({
    $core.List<$core.int>? qrData,
  }) {
    final result = create();
    if (qrData != null) result.qrData = qrData;
    return result;
  }

  ScanQRCodeRequest._();

  factory ScanQRCodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScanQRCodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScanQRCodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'qrData', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScanQRCodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScanQRCodeRequest copyWith(void Function(ScanQRCodeRequest) updates) =>
      super.copyWith((message) => updates(message as ScanQRCodeRequest))
          as ScanQRCodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScanQRCodeRequest create() => ScanQRCodeRequest._();
  @$core.override
  ScanQRCodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScanQRCodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScanQRCodeRequest>(create);
  static ScanQRCodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get qrData => $_getN(0);
  @$pb.TagNumber(1)
  set qrData($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQrData() => $_has(0);
  @$pb.TagNumber(1)
  void clearQrData() => $_clearField(1);
}

class ScanQRCodeResponse extends $pb.GeneratedMessage {
  factory ScanQRCodeResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? nodeId,
    $core.String? csrPem,
    $core.String? fingerprint,
    $core.String? emojiHash,
    $core.String? sessionId,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (nodeId != null) result.nodeId = nodeId;
    if (csrPem != null) result.csrPem = csrPem;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (emojiHash != null) result.emojiHash = emojiHash;
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  ScanQRCodeResponse._();

  factory ScanQRCodeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScanQRCodeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScanQRCodeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'nodeId')
    ..aOS(4, _omitFieldNames ? '' : 'csrPem')
    ..aOS(5, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(6, _omitFieldNames ? '' : 'emojiHash')
    ..aOS(7, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScanQRCodeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScanQRCodeResponse copyWith(void Function(ScanQRCodeResponse) updates) =>
      super.copyWith((message) => updates(message as ScanQRCodeResponse))
          as ScanQRCodeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScanQRCodeResponse create() => ScanQRCodeResponse._();
  @$core.override
  ScanQRCodeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScanQRCodeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScanQRCodeResponse>(create);
  static ScanQRCodeResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get nodeId => $_getSZ(2);
  @$pb.TagNumber(3)
  set nodeId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeId() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get csrPem => $_getSZ(3);
  @$pb.TagNumber(4)
  set csrPem($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCsrPem() => $_has(3);
  @$pb.TagNumber(4)
  void clearCsrPem() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get fingerprint => $_getSZ(4);
  @$pb.TagNumber(5)
  set fingerprint($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFingerprint() => $_has(4);
  @$pb.TagNumber(5)
  void clearFingerprint() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get emojiHash => $_getSZ(5);
  @$pb.TagNumber(6)
  set emojiHash($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEmojiHash() => $_has(5);
  @$pb.TagNumber(6)
  void clearEmojiHash() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get sessionId => $_getSZ(6);
  @$pb.TagNumber(7)
  set sessionId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSessionId() => $_has(6);
  @$pb.TagNumber(7)
  void clearSessionId() => $_clearField(7);
}

class GenerateQRReplyRequest extends $pb.GeneratedMessage {
  factory GenerateQRReplyRequest({
    $core.String? nodeId,
    $core.String? csrPem,
    $core.String? nodeName,
    $core.String? scanSessionId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (csrPem != null) result.csrPem = csrPem;
    if (nodeName != null) result.nodeName = nodeName;
    if (scanSessionId != null) result.scanSessionId = scanSessionId;
    return result;
  }

  GenerateQRReplyRequest._();

  factory GenerateQRReplyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateQRReplyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateQRReplyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'csrPem')
    ..aOS(3, _omitFieldNames ? '' : 'nodeName')
    ..aOS(4, _omitFieldNames ? '' : 'scanSessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateQRReplyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateQRReplyRequest copyWith(
          void Function(GenerateQRReplyRequest) updates) =>
      super.copyWith((message) => updates(message as GenerateQRReplyRequest))
          as GenerateQRReplyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateQRReplyRequest create() => GenerateQRReplyRequest._();
  @$core.override
  GenerateQRReplyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateQRReplyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateQRReplyRequest>(create);
  static GenerateQRReplyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get csrPem => $_getSZ(1);
  @$pb.TagNumber(2)
  set csrPem($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCsrPem() => $_has(1);
  @$pb.TagNumber(2)
  void clearCsrPem() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get nodeName => $_getSZ(2);
  @$pb.TagNumber(3)
  set nodeName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeName() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get scanSessionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set scanSessionId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasScanSessionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearScanSessionId() => $_clearField(4);
}

class GenerateQRReplyResponse extends $pb.GeneratedMessage {
  factory GenerateQRReplyResponse({
    $core.List<$core.int>? qrData,
    NodeInfo? node,
  }) {
    final result = create();
    if (qrData != null) result.qrData = qrData;
    if (node != null) result.node = node;
    return result;
  }

  GenerateQRReplyResponse._();

  factory GenerateQRReplyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateQRReplyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateQRReplyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'qrData', $pb.PbFieldType.OY)
    ..aOM<NodeInfo>(2, _omitFieldNames ? '' : 'node',
        subBuilder: NodeInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateQRReplyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateQRReplyResponse copyWith(
          void Function(GenerateQRReplyResponse) updates) =>
      super.copyWith((message) => updates(message as GenerateQRReplyResponse))
          as GenerateQRReplyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateQRReplyResponse create() => GenerateQRReplyResponse._();
  @$core.override
  GenerateQRReplyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateQRReplyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateQRReplyResponse>(create);
  static GenerateQRReplyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get qrData => $_getN(0);
  @$pb.TagNumber(1)
  set qrData($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQrData() => $_has(0);
  @$pb.TagNumber(1)
  void clearQrData() => $_clearField(1);

  @$pb.TagNumber(2)
  NodeInfo get node => $_getN(1);
  @$pb.TagNumber(2)
  set node(NodeInfo value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasNode() => $_has(1);
  @$pb.TagNumber(2)
  void clearNode() => $_clearField(2);
  @$pb.TagNumber(2)
  NodeInfo ensureNode() => $_ensure(1);
}

class Template extends $pb.GeneratedMessage {
  factory Template({
    $core.String? templateId,
    $core.String? name,
    $core.String? description,
    $3.Timestamp? createdAt,
    $3.Timestamp? updatedAt,
    $core.String? author,
    $core.bool? isPublic,
    $core.int? downloads,
    $core.Iterable<$core.String>? tags,
    $core.Iterable<ProxyTemplate>? proxies,
  }) {
    final result = create();
    if (templateId != null) result.templateId = templateId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (author != null) result.author = author;
    if (isPublic != null) result.isPublic = isPublic;
    if (downloads != null) result.downloads = downloads;
    if (tags != null) result.tags.addAll(tags);
    if (proxies != null) result.proxies.addAll(proxies);
    return result;
  }

  Template._();

  factory Template.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Template.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Template',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'templateId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOM<$3.Timestamp>(4, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $3.Timestamp.create)
    ..aOM<$3.Timestamp>(5, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $3.Timestamp.create)
    ..aOS(6, _omitFieldNames ? '' : 'author')
    ..aOB(7, _omitFieldNames ? '' : 'isPublic')
    ..aI(8, _omitFieldNames ? '' : 'downloads')
    ..pPS(9, _omitFieldNames ? '' : 'tags')
    ..pPM<ProxyTemplate>(10, _omitFieldNames ? '' : 'proxies',
        subBuilder: ProxyTemplate.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Template clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Template copyWith(void Function(Template) updates) =>
      super.copyWith((message) => updates(message as Template)) as Template;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Template create() => Template._();
  @$core.override
  Template createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Template getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Template>(create);
  static Template? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get templateId => $_getSZ(0);
  @$pb.TagNumber(1)
  set templateId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTemplateId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemplateId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $3.Timestamp get createdAt => $_getN(3);
  @$pb.TagNumber(4)
  set createdAt($3.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $3.Timestamp ensureCreatedAt() => $_ensure(3);

  @$pb.TagNumber(5)
  $3.Timestamp get updatedAt => $_getN(4);
  @$pb.TagNumber(5)
  set updatedAt($3.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasUpdatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdatedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $3.Timestamp ensureUpdatedAt() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get author => $_getSZ(5);
  @$pb.TagNumber(6)
  set author($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAuthor() => $_has(5);
  @$pb.TagNumber(6)
  void clearAuthor() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isPublic => $_getBF(6);
  @$pb.TagNumber(7)
  set isPublic($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsPublic() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsPublic() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get downloads => $_getIZ(7);
  @$pb.TagNumber(8)
  set downloads($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDownloads() => $_has(7);
  @$pb.TagNumber(8)
  void clearDownloads() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get tags => $_getList(8);

  /// Template content
  @$pb.TagNumber(10)
  $pb.PbList<ProxyTemplate> get proxies => $_getList(9);
}

class ProxyTemplate extends $pb.GeneratedMessage {
  factory ProxyTemplate({
    $core.String? name,
    $core.String? listenAddr,
    $5.ActionType? defaultAction,
    $5.FallbackAction? fallbackAction,
    $core.Iterable<$2.Rule>? rules,
    $core.Iterable<$core.String>? tags,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (listenAddr != null) result.listenAddr = listenAddr;
    if (defaultAction != null) result.defaultAction = defaultAction;
    if (fallbackAction != null) result.fallbackAction = fallbackAction;
    if (rules != null) result.rules.addAll(rules);
    if (tags != null) result.tags.addAll(tags);
    return result;
  }

  ProxyTemplate._();

  factory ProxyTemplate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProxyTemplate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProxyTemplate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'listenAddr')
    ..aE<$5.ActionType>(3, _omitFieldNames ? '' : 'defaultAction',
        enumValues: $5.ActionType.values)
    ..aE<$5.FallbackAction>(4, _omitFieldNames ? '' : 'fallbackAction',
        enumValues: $5.FallbackAction.values)
    ..pPM<$2.Rule>(5, _omitFieldNames ? '' : 'rules',
        subBuilder: $2.Rule.create)
    ..pPS(6, _omitFieldNames ? '' : 'tags')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProxyTemplate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProxyTemplate copyWith(void Function(ProxyTemplate) updates) =>
      super.copyWith((message) => updates(message as ProxyTemplate))
          as ProxyTemplate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProxyTemplate create() => ProxyTemplate._();
  @$core.override
  ProxyTemplate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProxyTemplate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProxyTemplate>(create);
  static ProxyTemplate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get listenAddr => $_getSZ(1);
  @$pb.TagNumber(2)
  set listenAddr($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasListenAddr() => $_has(1);
  @$pb.TagNumber(2)
  void clearListenAddr() => $_clearField(2);

  @$pb.TagNumber(3)
  $5.ActionType get defaultAction => $_getN(2);
  @$pb.TagNumber(3)
  set defaultAction($5.ActionType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDefaultAction() => $_has(2);
  @$pb.TagNumber(3)
  void clearDefaultAction() => $_clearField(3);

  @$pb.TagNumber(4)
  $5.FallbackAction get fallbackAction => $_getN(3);
  @$pb.TagNumber(4)
  set fallbackAction($5.FallbackAction value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFallbackAction() => $_has(3);
  @$pb.TagNumber(4)
  void clearFallbackAction() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$2.Rule> get rules => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get tags => $_getList(5);
}

class ListTemplatesRequest extends $pb.GeneratedMessage {
  factory ListTemplatesRequest({
    $core.bool? includePublic,
    $core.Iterable<$core.String>? tags,
  }) {
    final result = create();
    if (includePublic != null) result.includePublic = includePublic;
    if (tags != null) result.tags.addAll(tags);
    return result;
  }

  ListTemplatesRequest._();

  factory ListTemplatesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTemplatesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTemplatesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'includePublic')
    ..pPS(2, _omitFieldNames ? '' : 'tags')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTemplatesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTemplatesRequest copyWith(void Function(ListTemplatesRequest) updates) =>
      super.copyWith((message) => updates(message as ListTemplatesRequest))
          as ListTemplatesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTemplatesRequest create() => ListTemplatesRequest._();
  @$core.override
  ListTemplatesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTemplatesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTemplatesRequest>(create);
  static ListTemplatesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get includePublic => $_getBF(0);
  @$pb.TagNumber(1)
  set includePublic($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIncludePublic() => $_has(0);
  @$pb.TagNumber(1)
  void clearIncludePublic() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get tags => $_getList(1);
}

class ListTemplatesResponse extends $pb.GeneratedMessage {
  factory ListTemplatesResponse({
    $core.Iterable<Template>? templates,
    $core.int? totalCount,
  }) {
    final result = create();
    if (templates != null) result.templates.addAll(templates);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListTemplatesResponse._();

  factory ListTemplatesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTemplatesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTemplatesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<Template>(1, _omitFieldNames ? '' : 'templates',
        subBuilder: Template.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTemplatesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTemplatesResponse copyWith(
          void Function(ListTemplatesResponse) updates) =>
      super.copyWith((message) => updates(message as ListTemplatesResponse))
          as ListTemplatesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTemplatesResponse create() => ListTemplatesResponse._();
  @$core.override
  ListTemplatesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTemplatesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTemplatesResponse>(create);
  static ListTemplatesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Template> get templates => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class GetTemplateRequest extends $pb.GeneratedMessage {
  factory GetTemplateRequest({
    $core.String? templateId,
  }) {
    final result = create();
    if (templateId != null) result.templateId = templateId;
    return result;
  }

  GetTemplateRequest._();

  factory GetTemplateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTemplateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTemplateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'templateId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTemplateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTemplateRequest copyWith(void Function(GetTemplateRequest) updates) =>
      super.copyWith((message) => updates(message as GetTemplateRequest))
          as GetTemplateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTemplateRequest create() => GetTemplateRequest._();
  @$core.override
  GetTemplateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTemplateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTemplateRequest>(create);
  static GetTemplateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get templateId => $_getSZ(0);
  @$pb.TagNumber(1)
  set templateId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTemplateId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemplateId() => $_clearField(1);
}

class CreateTemplateRequest extends $pb.GeneratedMessage {
  factory CreateTemplateRequest({
    $core.String? name,
    $core.String? description,
    $core.String? nodeId,
    $core.Iterable<$core.String>? proxyIds,
    $core.Iterable<$core.String>? tags,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyIds != null) result.proxyIds.addAll(proxyIds);
    if (tags != null) result.tags.addAll(tags);
    return result;
  }

  CreateTemplateRequest._();

  factory CreateTemplateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateTemplateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateTemplateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOS(3, _omitFieldNames ? '' : 'nodeId')
    ..pPS(4, _omitFieldNames ? '' : 'proxyIds')
    ..pPS(5, _omitFieldNames ? '' : 'tags')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTemplateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTemplateRequest copyWith(
          void Function(CreateTemplateRequest) updates) =>
      super.copyWith((message) => updates(message as CreateTemplateRequest))
          as CreateTemplateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateTemplateRequest create() => CreateTemplateRequest._();
  @$core.override
  CreateTemplateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateTemplateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateTemplateRequest>(create);
  static CreateTemplateRequest? _defaultInstance;

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
  $core.String get nodeId => $_getSZ(2);
  @$pb.TagNumber(3)
  set nodeId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeId() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeId() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get proxyIds => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get tags => $_getList(4);
}

class ApplyTemplateRequest extends $pb.GeneratedMessage {
  factory ApplyTemplateRequest({
    $core.String? templateId,
    $core.String? nodeId,
    $core.bool? overwrite,
  }) {
    final result = create();
    if (templateId != null) result.templateId = templateId;
    if (nodeId != null) result.nodeId = nodeId;
    if (overwrite != null) result.overwrite = overwrite;
    return result;
  }

  ApplyTemplateRequest._();

  factory ApplyTemplateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApplyTemplateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApplyTemplateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'templateId')
    ..aOS(2, _omitFieldNames ? '' : 'nodeId')
    ..aOB(3, _omitFieldNames ? '' : 'overwrite')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyTemplateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyTemplateRequest copyWith(void Function(ApplyTemplateRequest) updates) =>
      super.copyWith((message) => updates(message as ApplyTemplateRequest))
          as ApplyTemplateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApplyTemplateRequest create() => ApplyTemplateRequest._();
  @$core.override
  ApplyTemplateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApplyTemplateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApplyTemplateRequest>(create);
  static ApplyTemplateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get templateId => $_getSZ(0);
  @$pb.TagNumber(1)
  set templateId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTemplateId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemplateId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get overwrite => $_getBF(2);
  @$pb.TagNumber(3)
  set overwrite($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOverwrite() => $_has(2);
  @$pb.TagNumber(3)
  void clearOverwrite() => $_clearField(3);
}

class ApplyTemplateResponse extends $pb.GeneratedMessage {
  factory ApplyTemplateResponse({
    $core.bool? success,
    $core.String? error,
    $core.int? proxiesCreated,
    $core.int? rulesCreated,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (proxiesCreated != null) result.proxiesCreated = proxiesCreated;
    if (rulesCreated != null) result.rulesCreated = rulesCreated;
    return result;
  }

  ApplyTemplateResponse._();

  factory ApplyTemplateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApplyTemplateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApplyTemplateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aI(3, _omitFieldNames ? '' : 'proxiesCreated')
    ..aI(4, _omitFieldNames ? '' : 'rulesCreated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyTemplateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyTemplateResponse copyWith(
          void Function(ApplyTemplateResponse) updates) =>
      super.copyWith((message) => updates(message as ApplyTemplateResponse))
          as ApplyTemplateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApplyTemplateResponse create() => ApplyTemplateResponse._();
  @$core.override
  ApplyTemplateResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApplyTemplateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApplyTemplateResponse>(create);
  static ApplyTemplateResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.int get proxiesCreated => $_getIZ(2);
  @$pb.TagNumber(3)
  set proxiesCreated($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProxiesCreated() => $_has(2);
  @$pb.TagNumber(3)
  void clearProxiesCreated() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get rulesCreated => $_getIZ(3);
  @$pb.TagNumber(4)
  set rulesCreated($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRulesCreated() => $_has(3);
  @$pb.TagNumber(4)
  void clearRulesCreated() => $_clearField(4);
}

class DeleteTemplateRequest extends $pb.GeneratedMessage {
  factory DeleteTemplateRequest({
    $core.String? templateId,
  }) {
    final result = create();
    if (templateId != null) result.templateId = templateId;
    return result;
  }

  DeleteTemplateRequest._();

  factory DeleteTemplateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTemplateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTemplateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'templateId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTemplateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTemplateRequest copyWith(
          void Function(DeleteTemplateRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteTemplateRequest))
          as DeleteTemplateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTemplateRequest create() => DeleteTemplateRequest._();
  @$core.override
  DeleteTemplateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTemplateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTemplateRequest>(create);
  static DeleteTemplateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get templateId => $_getSZ(0);
  @$pb.TagNumber(1)
  set templateId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTemplateId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemplateId() => $_clearField(1);
}

class SyncTemplatesResponse extends $pb.GeneratedMessage {
  factory SyncTemplatesResponse({
    $core.int? uploaded,
    $core.int? downloaded,
    $core.int? conflicts,
  }) {
    final result = create();
    if (uploaded != null) result.uploaded = uploaded;
    if (downloaded != null) result.downloaded = downloaded;
    if (conflicts != null) result.conflicts = conflicts;
    return result;
  }

  SyncTemplatesResponse._();

  factory SyncTemplatesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SyncTemplatesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncTemplatesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'uploaded')
    ..aI(2, _omitFieldNames ? '' : 'downloaded')
    ..aI(3, _omitFieldNames ? '' : 'conflicts')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncTemplatesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncTemplatesResponse copyWith(
          void Function(SyncTemplatesResponse) updates) =>
      super.copyWith((message) => updates(message as SyncTemplatesResponse))
          as SyncTemplatesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncTemplatesResponse create() => SyncTemplatesResponse._();
  @$core.override
  SyncTemplatesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SyncTemplatesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncTemplatesResponse>(create);
  static SyncTemplatesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get uploaded => $_getIZ(0);
  @$pb.TagNumber(1)
  set uploaded($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUploaded() => $_has(0);
  @$pb.TagNumber(1)
  void clearUploaded() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get downloaded => $_getIZ(1);
  @$pb.TagNumber(2)
  set downloaded($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDownloaded() => $_has(1);
  @$pb.TagNumber(2)
  void clearDownloaded() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get conflicts => $_getIZ(2);
  @$pb.TagNumber(3)
  set conflicts($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConflicts() => $_has(2);
  @$pb.TagNumber(3)
  void clearConflicts() => $_clearField(3);
}

class ExportTemplateYamlRequest extends $pb.GeneratedMessage {
  factory ExportTemplateYamlRequest({
    $core.String? templateId,
  }) {
    final result = create();
    if (templateId != null) result.templateId = templateId;
    return result;
  }

  ExportTemplateYamlRequest._();

  factory ExportTemplateYamlRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExportTemplateYamlRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportTemplateYamlRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'templateId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportTemplateYamlRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportTemplateYamlRequest copyWith(
          void Function(ExportTemplateYamlRequest) updates) =>
      super.copyWith((message) => updates(message as ExportTemplateYamlRequest))
          as ExportTemplateYamlRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportTemplateYamlRequest create() => ExportTemplateYamlRequest._();
  @$core.override
  ExportTemplateYamlRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExportTemplateYamlRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportTemplateYamlRequest>(create);
  static ExportTemplateYamlRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get templateId => $_getSZ(0);
  @$pb.TagNumber(1)
  set templateId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTemplateId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemplateId() => $_clearField(1);
}

class ExportTemplateYamlResponse extends $pb.GeneratedMessage {
  factory ExportTemplateYamlResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? yaml,
    Template? template,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (yaml != null) result.yaml = yaml;
    if (template != null) result.template = template;
    return result;
  }

  ExportTemplateYamlResponse._();

  factory ExportTemplateYamlResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExportTemplateYamlResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportTemplateYamlResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'yaml')
    ..aOM<Template>(4, _omitFieldNames ? '' : 'template',
        subBuilder: Template.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportTemplateYamlResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportTemplateYamlResponse copyWith(
          void Function(ExportTemplateYamlResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ExportTemplateYamlResponse))
          as ExportTemplateYamlResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportTemplateYamlResponse create() => ExportTemplateYamlResponse._();
  @$core.override
  ExportTemplateYamlResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExportTemplateYamlResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportTemplateYamlResponse>(create);
  static ExportTemplateYamlResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get yaml => $_getSZ(2);
  @$pb.TagNumber(3)
  set yaml($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasYaml() => $_has(2);
  @$pb.TagNumber(3)
  void clearYaml() => $_clearField(3);

  @$pb.TagNumber(4)
  Template get template => $_getN(3);
  @$pb.TagNumber(4)
  set template(Template value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTemplate() => $_has(3);
  @$pb.TagNumber(4)
  void clearTemplate() => $_clearField(4);
  @$pb.TagNumber(4)
  Template ensureTemplate() => $_ensure(3);
}

class ImportTemplateYamlRequest extends $pb.GeneratedMessage {
  factory ImportTemplateYamlRequest({
    $core.String? yaml,
  }) {
    final result = create();
    if (yaml != null) result.yaml = yaml;
    return result;
  }

  ImportTemplateYamlRequest._();

  factory ImportTemplateYamlRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportTemplateYamlRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportTemplateYamlRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'yaml')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportTemplateYamlRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportTemplateYamlRequest copyWith(
          void Function(ImportTemplateYamlRequest) updates) =>
      super.copyWith((message) => updates(message as ImportTemplateYamlRequest))
          as ImportTemplateYamlRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportTemplateYamlRequest create() => ImportTemplateYamlRequest._();
  @$core.override
  ImportTemplateYamlRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportTemplateYamlRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportTemplateYamlRequest>(create);
  static ImportTemplateYamlRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get yaml => $_getSZ(0);
  @$pb.TagNumber(1)
  set yaml($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasYaml() => $_has(0);
  @$pb.TagNumber(1)
  void clearYaml() => $_clearField(1);
}

class ImportTemplateYamlResponse extends $pb.GeneratedMessage {
  factory ImportTemplateYamlResponse({
    $core.bool? success,
    $core.String? error,
    Template? template,
    $core.String? name,
    $core.String? description,
    $core.int? proxyCount,
    $core.Iterable<$core.String>? tags,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (template != null) result.template = template;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (proxyCount != null) result.proxyCount = proxyCount;
    if (tags != null) result.tags.addAll(tags);
    return result;
  }

  ImportTemplateYamlResponse._();

  factory ImportTemplateYamlResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportTemplateYamlResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportTemplateYamlResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOM<Template>(3, _omitFieldNames ? '' : 'template',
        subBuilder: Template.create)
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aI(6, _omitFieldNames ? '' : 'proxyCount')
    ..pPS(7, _omitFieldNames ? '' : 'tags')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportTemplateYamlResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportTemplateYamlResponse copyWith(
          void Function(ImportTemplateYamlResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ImportTemplateYamlResponse))
          as ImportTemplateYamlResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportTemplateYamlResponse create() => ImportTemplateYamlResponse._();
  @$core.override
  ImportTemplateYamlResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportTemplateYamlResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportTemplateYamlResponse>(create);
  static ImportTemplateYamlResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  Template get template => $_getN(2);
  @$pb.TagNumber(3)
  set template(Template value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTemplate() => $_has(2);
  @$pb.TagNumber(3)
  void clearTemplate() => $_clearField(3);
  @$pb.TagNumber(3)
  Template ensureTemplate() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get proxyCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set proxyCount($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProxyCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearProxyCount() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get tags => $_getList(6);
}

class Settings extends $pb.GeneratedMessage {
  factory Settings({
    $core.String? hubAddress,
    $core.bool? autoConnectHub,
    $core.bool? notificationsEnabled,
    $core.bool? approvalNotifications,
    $core.bool? connectionNotifications,
    $core.bool? alertNotifications,
    $5.P2PMode? p2pMode,
    $core.bool? requireBiometric,
    $core.int? autoLockMinutes,
    Theme? theme,
    $core.String? language,
    $core.List<$core.int>? hubCaPem,
    $core.String? hubCertPin,
    $core.Iterable<$core.String>? stunServers,
    $core.String? turnServer,
    $core.String? turnUsername,
    $core.String? turnPassword,
    $core.String? hubInviteCode,
  }) {
    final result = create();
    if (hubAddress != null) result.hubAddress = hubAddress;
    if (autoConnectHub != null) result.autoConnectHub = autoConnectHub;
    if (notificationsEnabled != null)
      result.notificationsEnabled = notificationsEnabled;
    if (approvalNotifications != null)
      result.approvalNotifications = approvalNotifications;
    if (connectionNotifications != null)
      result.connectionNotifications = connectionNotifications;
    if (alertNotifications != null)
      result.alertNotifications = alertNotifications;
    if (p2pMode != null) result.p2pMode = p2pMode;
    if (requireBiometric != null) result.requireBiometric = requireBiometric;
    if (autoLockMinutes != null) result.autoLockMinutes = autoLockMinutes;
    if (theme != null) result.theme = theme;
    if (language != null) result.language = language;
    if (hubCaPem != null) result.hubCaPem = hubCaPem;
    if (hubCertPin != null) result.hubCertPin = hubCertPin;
    if (stunServers != null) result.stunServers.addAll(stunServers);
    if (turnServer != null) result.turnServer = turnServer;
    if (turnUsername != null) result.turnUsername = turnUsername;
    if (turnPassword != null) result.turnPassword = turnPassword;
    if (hubInviteCode != null) result.hubInviteCode = hubInviteCode;
    return result;
  }

  Settings._();

  factory Settings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Settings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Settings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hubAddress')
    ..aOB(2, _omitFieldNames ? '' : 'autoConnectHub')
    ..aOB(3, _omitFieldNames ? '' : 'notificationsEnabled')
    ..aOB(4, _omitFieldNames ? '' : 'approvalNotifications')
    ..aOB(5, _omitFieldNames ? '' : 'connectionNotifications')
    ..aOB(6, _omitFieldNames ? '' : 'alertNotifications')
    ..aE<$5.P2PMode>(7, _omitFieldNames ? '' : 'p2pMode',
        enumValues: $5.P2PMode.values)
    ..aOB(8, _omitFieldNames ? '' : 'requireBiometric')
    ..aI(9, _omitFieldNames ? '' : 'autoLockMinutes')
    ..aE<Theme>(10, _omitFieldNames ? '' : 'theme', enumValues: Theme.values)
    ..aOS(11, _omitFieldNames ? '' : 'language')
    ..a<$core.List<$core.int>>(
        12, _omitFieldNames ? '' : 'hubCaPem', $pb.PbFieldType.OY)
    ..aOS(13, _omitFieldNames ? '' : 'hubCertPin')
    ..pPS(14, _omitFieldNames ? '' : 'stunServers')
    ..aOS(15, _omitFieldNames ? '' : 'turnServer')
    ..aOS(16, _omitFieldNames ? '' : 'turnUsername')
    ..aOS(17, _omitFieldNames ? '' : 'turnPassword')
    ..aOS(18, _omitFieldNames ? '' : 'hubInviteCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Settings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Settings copyWith(void Function(Settings) updates) =>
      super.copyWith((message) => updates(message as Settings)) as Settings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Settings create() => Settings._();
  @$core.override
  Settings createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Settings getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Settings>(create);
  static Settings? _defaultInstance;

  /// Hub settings
  @$pb.TagNumber(1)
  $core.String get hubAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set hubAddress($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHubAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearHubAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get autoConnectHub => $_getBF(1);
  @$pb.TagNumber(2)
  set autoConnectHub($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAutoConnectHub() => $_has(1);
  @$pb.TagNumber(2)
  void clearAutoConnectHub() => $_clearField(2);

  /// Notification settings
  @$pb.TagNumber(3)
  $core.bool get notificationsEnabled => $_getBF(2);
  @$pb.TagNumber(3)
  set notificationsEnabled($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNotificationsEnabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearNotificationsEnabled() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get approvalNotifications => $_getBF(3);
  @$pb.TagNumber(4)
  set approvalNotifications($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasApprovalNotifications() => $_has(3);
  @$pb.TagNumber(4)
  void clearApprovalNotifications() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get connectionNotifications => $_getBF(4);
  @$pb.TagNumber(5)
  set connectionNotifications($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConnectionNotifications() => $_has(4);
  @$pb.TagNumber(5)
  void clearConnectionNotifications() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get alertNotifications => $_getBF(5);
  @$pb.TagNumber(6)
  set alertNotifications($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAlertNotifications() => $_has(5);
  @$pb.TagNumber(6)
  void clearAlertNotifications() => $_clearField(6);

  /// P2P settings
  @$pb.TagNumber(7)
  $5.P2PMode get p2pMode => $_getN(6);
  @$pb.TagNumber(7)
  set p2pMode($5.P2PMode value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasP2pMode() => $_has(6);
  @$pb.TagNumber(7)
  void clearP2pMode() => $_clearField(7);

  /// Security settings
  @$pb.TagNumber(8)
  $core.bool get requireBiometric => $_getBF(7);
  @$pb.TagNumber(8)
  set requireBiometric($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRequireBiometric() => $_has(7);
  @$pb.TagNumber(8)
  void clearRequireBiometric() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get autoLockMinutes => $_getIZ(8);
  @$pb.TagNumber(9)
  set autoLockMinutes($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasAutoLockMinutes() => $_has(8);
  @$pb.TagNumber(9)
  void clearAutoLockMinutes() => $_clearField(9);

  /// Display settings
  @$pb.TagNumber(10)
  Theme get theme => $_getN(9);
  @$pb.TagNumber(10)
  set theme(Theme value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasTheme() => $_has(9);
  @$pb.TagNumber(10)
  void clearTheme() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get language => $_getSZ(10);
  @$pb.TagNumber(11)
  set language($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasLanguage() => $_has(10);
  @$pb.TagNumber(11)
  void clearLanguage() => $_clearField(11);

  /// Hub TLS settings (zero-trust)
  @$pb.TagNumber(12)
  $core.List<$core.int> get hubCaPem => $_getN(11);
  @$pb.TagNumber(12)
  set hubCaPem($core.List<$core.int> value) => $_setBytes(11, value);
  @$pb.TagNumber(12)
  $core.bool hasHubCaPem() => $_has(11);
  @$pb.TagNumber(12)
  void clearHubCaPem() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get hubCertPin => $_getSZ(12);
  @$pb.TagNumber(13)
  set hubCertPin($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasHubCertPin() => $_has(12);
  @$pb.TagNumber(13)
  void clearHubCertPin() => $_clearField(13);

  /// ICE settings (backend-owned; UI/CLI are thin inputs only)
  @$pb.TagNumber(14)
  $pb.PbList<$core.String> get stunServers => $_getList(13);

  @$pb.TagNumber(15)
  $core.String get turnServer => $_getSZ(14);
  @$pb.TagNumber(15)
  set turnServer($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasTurnServer() => $_has(14);
  @$pb.TagNumber(15)
  void clearTurnServer() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get turnUsername => $_getSZ(15);
  @$pb.TagNumber(16)
  set turnUsername($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasTurnUsername() => $_has(15);
  @$pb.TagNumber(16)
  void clearTurnUsername() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get turnPassword => $_getSZ(16);
  @$pb.TagNumber(17)
  set turnPassword($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasTurnPassword() => $_has(16);
  @$pb.TagNumber(17)
  void clearTurnPassword() => $_clearField(17);

  /// Hub onboarding defaults
  @$pb.TagNumber(18)
  $core.String get hubInviteCode => $_getSZ(17);
  @$pb.TagNumber(18)
  set hubInviteCode($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasHubInviteCode() => $_has(17);
  @$pb.TagNumber(18)
  void clearHubInviteCode() => $_clearField(18);
}

class UpdateSettingsRequest extends $pb.GeneratedMessage {
  factory UpdateSettingsRequest({
    Settings? settings,
    $4.FieldMask? updateMask,
  }) {
    final result = create();
    if (settings != null) result.settings = settings;
    if (updateMask != null) result.updateMask = updateMask;
    return result;
  }

  UpdateSettingsRequest._();

  factory UpdateSettingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOM<Settings>(1, _omitFieldNames ? '' : 'settings',
        subBuilder: Settings.create)
    ..aOM<$4.FieldMask>(2, _omitFieldNames ? '' : 'updateMask',
        subBuilder: $4.FieldMask.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSettingsRequest copyWith(
          void Function(UpdateSettingsRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateSettingsRequest))
          as UpdateSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateSettingsRequest create() => UpdateSettingsRequest._();
  @$core.override
  UpdateSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateSettingsRequest>(create);
  static UpdateSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Settings get settings => $_getN(0);
  @$pb.TagNumber(1)
  set settings(Settings value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSettings() => $_has(0);
  @$pb.TagNumber(1)
  void clearSettings() => $_clearField(1);
  @$pb.TagNumber(1)
  Settings ensureSettings() => $_ensure(0);

  @$pb.TagNumber(2)
  $4.FieldMask get updateMask => $_getN(1);
  @$pb.TagNumber(2)
  set updateMask($4.FieldMask value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUpdateMask() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpdateMask() => $_clearField(2);
  @$pb.TagNumber(2)
  $4.FieldMask ensureUpdateMask() => $_ensure(1);
}

class SettingsOverviewSnapshot extends $pb.GeneratedMessage {
  factory SettingsOverviewSnapshot({
    IdentityInfo? identity,
    HubSettingsSnapshot? hub,
    P2PSettingsSnapshot? p2p,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    if (hub != null) result.hub = hub;
    if (p2p != null) result.p2p = p2p;
    return result;
  }

  SettingsOverviewSnapshot._();

  factory SettingsOverviewSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SettingsOverviewSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SettingsOverviewSnapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOM<IdentityInfo>(1, _omitFieldNames ? '' : 'identity',
        subBuilder: IdentityInfo.create)
    ..aOM<HubSettingsSnapshot>(2, _omitFieldNames ? '' : 'hub',
        subBuilder: HubSettingsSnapshot.create)
    ..aOM<P2PSettingsSnapshot>(3, _omitFieldNames ? '' : 'p2p',
        subBuilder: P2PSettingsSnapshot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SettingsOverviewSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SettingsOverviewSnapshot copyWith(
          void Function(SettingsOverviewSnapshot) updates) =>
      super.copyWith((message) => updates(message as SettingsOverviewSnapshot))
          as SettingsOverviewSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SettingsOverviewSnapshot create() => SettingsOverviewSnapshot._();
  @$core.override
  SettingsOverviewSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SettingsOverviewSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SettingsOverviewSnapshot>(create);
  static SettingsOverviewSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  IdentityInfo get identity => $_getN(0);
  @$pb.TagNumber(1)
  set identity(IdentityInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);
  @$pb.TagNumber(1)
  IdentityInfo ensureIdentity() => $_ensure(0);

  @$pb.TagNumber(2)
  HubSettingsSnapshot get hub => $_getN(1);
  @$pb.TagNumber(2)
  set hub(HubSettingsSnapshot value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasHub() => $_has(1);
  @$pb.TagNumber(2)
  void clearHub() => $_clearField(2);
  @$pb.TagNumber(2)
  HubSettingsSnapshot ensureHub() => $_ensure(1);

  @$pb.TagNumber(3)
  P2PSettingsSnapshot get p2p => $_getN(2);
  @$pb.TagNumber(3)
  set p2p(P2PSettingsSnapshot value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasP2p() => $_has(2);
  @$pb.TagNumber(3)
  void clearP2p() => $_clearField(3);
  @$pb.TagNumber(3)
  P2PSettingsSnapshot ensureP2p() => $_ensure(2);
}

class RegisterFCMTokenRequest extends $pb.GeneratedMessage {
  factory RegisterFCMTokenRequest({
    $core.String? fcmToken,
    DeviceType? deviceType,
    $core.String? deviceName,
  }) {
    final result = create();
    if (fcmToken != null) result.fcmToken = fcmToken;
    if (deviceType != null) result.deviceType = deviceType;
    if (deviceName != null) result.deviceName = deviceName;
    return result;
  }

  RegisterFCMTokenRequest._();

  factory RegisterFCMTokenRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterFCMTokenRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterFCMTokenRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fcmToken')
    ..aE<DeviceType>(2, _omitFieldNames ? '' : 'deviceType',
        enumValues: DeviceType.values)
    ..aOS(3, _omitFieldNames ? '' : 'deviceName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterFCMTokenRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterFCMTokenRequest copyWith(
          void Function(RegisterFCMTokenRequest) updates) =>
      super.copyWith((message) => updates(message as RegisterFCMTokenRequest))
          as RegisterFCMTokenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterFCMTokenRequest create() => RegisterFCMTokenRequest._();
  @$core.override
  RegisterFCMTokenRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterFCMTokenRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterFCMTokenRequest>(create);
  static RegisterFCMTokenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fcmToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set fcmToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFcmToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearFcmToken() => $_clearField(1);

  @$pb.TagNumber(2)
  DeviceType get deviceType => $_getN(1);
  @$pb.TagNumber(2)
  set deviceType(DeviceType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceType() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get deviceName => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceName() => $_clearField(3);
}

class ConnectToHubRequest extends $pb.GeneratedMessage {
  factory ConnectToHubRequest({
    $core.String? hubAddress,
    $core.bool? useP2p,
    $core.List<$core.int>? hubCaPem,
    $core.String? hubCertPin,
    $core.String? token,
  }) {
    final result = create();
    if (hubAddress != null) result.hubAddress = hubAddress;
    if (useP2p != null) result.useP2p = useP2p;
    if (hubCaPem != null) result.hubCaPem = hubCaPem;
    if (hubCertPin != null) result.hubCertPin = hubCertPin;
    if (token != null) result.token = token;
    return result;
  }

  ConnectToHubRequest._();

  factory ConnectToHubRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConnectToHubRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnectToHubRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hubAddress')
    ..aOB(2, _omitFieldNames ? '' : 'useP2p')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'hubCaPem', $pb.PbFieldType.OY)
    ..aOS(4, _omitFieldNames ? '' : 'hubCertPin')
    ..aOS(5, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectToHubRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectToHubRequest copyWith(void Function(ConnectToHubRequest) updates) =>
      super.copyWith((message) => updates(message as ConnectToHubRequest))
          as ConnectToHubRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnectToHubRequest create() => ConnectToHubRequest._();
  @$core.override
  ConnectToHubRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConnectToHubRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConnectToHubRequest>(create);
  static ConnectToHubRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hubAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set hubAddress($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHubAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearHubAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get useP2p => $_getBF(1);
  @$pb.TagNumber(2)
  set useP2p($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUseP2p() => $_has(1);
  @$pb.TagNumber(2)
  void clearUseP2p() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get hubCaPem => $_getN(2);
  @$pb.TagNumber(3)
  set hubCaPem($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHubCaPem() => $_has(2);
  @$pb.TagNumber(3)
  void clearHubCaPem() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get hubCertPin => $_getSZ(3);
  @$pb.TagNumber(4)
  set hubCertPin($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHubCertPin() => $_has(3);
  @$pb.TagNumber(4)
  void clearHubCertPin() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get token => $_getSZ(4);
  @$pb.TagNumber(5)
  set token($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasToken() => $_has(4);
  @$pb.TagNumber(5)
  void clearToken() => $_clearField(5);
}

class FetchHubCARequest extends $pb.GeneratedMessage {
  factory FetchHubCARequest({
    $core.String? hubAddress,
  }) {
    final result = create();
    if (hubAddress != null) result.hubAddress = hubAddress;
    return result;
  }

  FetchHubCARequest._();

  factory FetchHubCARequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FetchHubCARequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FetchHubCARequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hubAddress')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FetchHubCARequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FetchHubCARequest copyWith(void Function(FetchHubCARequest) updates) =>
      super.copyWith((message) => updates(message as FetchHubCARequest))
          as FetchHubCARequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FetchHubCARequest create() => FetchHubCARequest._();
  @$core.override
  FetchHubCARequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FetchHubCARequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FetchHubCARequest>(create);
  static FetchHubCARequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hubAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set hubAddress($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHubAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearHubAddress() => $_clearField(1);
}

class FetchHubCAResponse extends $pb.GeneratedMessage {
  factory FetchHubCAResponse({
    $core.bool? success,
    $core.String? error,
    $core.List<$core.int>? caPem,
    $core.String? fingerprint,
    $core.String? emojiHash,
    $core.String? subject,
    $core.String? expires,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (caPem != null) result.caPem = caPem;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (emojiHash != null) result.emojiHash = emojiHash;
    if (subject != null) result.subject = subject;
    if (expires != null) result.expires = expires;
    return result;
  }

  FetchHubCAResponse._();

  factory FetchHubCAResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FetchHubCAResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FetchHubCAResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'caPem', $pb.PbFieldType.OY)
    ..aOS(4, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(5, _omitFieldNames ? '' : 'emojiHash')
    ..aOS(6, _omitFieldNames ? '' : 'subject')
    ..aOS(7, _omitFieldNames ? '' : 'expires')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FetchHubCAResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FetchHubCAResponse copyWith(void Function(FetchHubCAResponse) updates) =>
      super.copyWith((message) => updates(message as FetchHubCAResponse))
          as FetchHubCAResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FetchHubCAResponse create() => FetchHubCAResponse._();
  @$core.override
  FetchHubCAResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FetchHubCAResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FetchHubCAResponse>(create);
  static FetchHubCAResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.List<$core.int> get caPem => $_getN(2);
  @$pb.TagNumber(3)
  set caPem($core.List<$core.int> value) => $_setBytes(2, value);
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
  $core.String get emojiHash => $_getSZ(4);
  @$pb.TagNumber(5)
  set emojiHash($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEmojiHash() => $_has(4);
  @$pb.TagNumber(5)
  void clearEmojiHash() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get subject => $_getSZ(5);
  @$pb.TagNumber(6)
  set subject($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSubject() => $_has(5);
  @$pb.TagNumber(6)
  void clearSubject() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get expires => $_getSZ(6);
  @$pb.TagNumber(7)
  set expires($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasExpires() => $_has(6);
  @$pb.TagNumber(7)
  void clearExpires() => $_clearField(7);
}

class ConnectToHubResponse extends $pb.GeneratedMessage {
  factory ConnectToHubResponse({
    $core.bool? success,
    $core.String? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  ConnectToHubResponse._();

  factory ConnectToHubResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConnectToHubResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnectToHubResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectToHubResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectToHubResponse copyWith(void Function(ConnectToHubResponse) updates) =>
      super.copyWith((message) => updates(message as ConnectToHubResponse))
          as ConnectToHubResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnectToHubResponse create() => ConnectToHubResponse._();
  @$core.override
  ConnectToHubResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConnectToHubResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConnectToHubResponse>(create);
  static ConnectToHubResponse? _defaultInstance;

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

class HubStatus extends $pb.GeneratedMessage {
  factory HubStatus({
    $core.bool? connected,
    $core.String? hubAddress,
    $3.Timestamp? connectedSince,
    $fixnum.Int64? messagesSent,
    $fixnum.Int64? messagesReceived,
    $core.String? userId,
    $core.String? tier,
    $core.int? maxNodes,
  }) {
    final result = create();
    if (connected != null) result.connected = connected;
    if (hubAddress != null) result.hubAddress = hubAddress;
    if (connectedSince != null) result.connectedSince = connectedSince;
    if (messagesSent != null) result.messagesSent = messagesSent;
    if (messagesReceived != null) result.messagesReceived = messagesReceived;
    if (userId != null) result.userId = userId;
    if (tier != null) result.tier = tier;
    if (maxNodes != null) result.maxNodes = maxNodes;
    return result;
  }

  HubStatus._();

  factory HubStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HubStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HubStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'connected')
    ..aOS(2, _omitFieldNames ? '' : 'hubAddress')
    ..aOM<$3.Timestamp>(3, _omitFieldNames ? '' : 'connectedSince',
        subBuilder: $3.Timestamp.create)
    ..aInt64(4, _omitFieldNames ? '' : 'messagesSent')
    ..aInt64(5, _omitFieldNames ? '' : 'messagesReceived')
    ..aOS(6, _omitFieldNames ? '' : 'userId')
    ..aOS(7, _omitFieldNames ? '' : 'tier')
    ..aI(8, _omitFieldNames ? '' : 'maxNodes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HubStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HubStatus copyWith(void Function(HubStatus) updates) =>
      super.copyWith((message) => updates(message as HubStatus)) as HubStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HubStatus create() => HubStatus._();
  @$core.override
  HubStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HubStatus getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HubStatus>(create);
  static HubStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get connected => $_getBF(0);
  @$pb.TagNumber(1)
  set connected($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConnected() => $_has(0);
  @$pb.TagNumber(1)
  void clearConnected() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get hubAddress => $_getSZ(1);
  @$pb.TagNumber(2)
  set hubAddress($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHubAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearHubAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $3.Timestamp get connectedSince => $_getN(2);
  @$pb.TagNumber(3)
  set connectedSince($3.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasConnectedSince() => $_has(2);
  @$pb.TagNumber(3)
  void clearConnectedSince() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.Timestamp ensureConnectedSince() => $_ensure(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get messagesSent => $_getI64(3);
  @$pb.TagNumber(4)
  set messagesSent($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessagesSent() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessagesSent() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get messagesReceived => $_getI64(4);
  @$pb.TagNumber(5)
  set messagesReceived($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMessagesReceived() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessagesReceived() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get userId => $_getSZ(5);
  @$pb.TagNumber(6)
  set userId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUserId() => $_has(5);
  @$pb.TagNumber(6)
  void clearUserId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get tier => $_getSZ(6);
  @$pb.TagNumber(7)
  set tier($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTier() => $_has(6);
  @$pb.TagNumber(7)
  void clearTier() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get maxNodes => $_getIZ(7);
  @$pb.TagNumber(8)
  set maxNodes($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMaxNodes() => $_has(7);
  @$pb.TagNumber(8)
  void clearMaxNodes() => $_clearField(8);
}

class HubSettingsSnapshot extends $pb.GeneratedMessage {
  factory HubSettingsSnapshot({
    HubStatus? status,
    Settings? settings,
    $core.String? resolvedHubAddress,
    $core.String? resolvedInviteCode,
    HubTrustChallenge? pendingTrustChallenge,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (settings != null) result.settings = settings;
    if (resolvedHubAddress != null)
      result.resolvedHubAddress = resolvedHubAddress;
    if (resolvedInviteCode != null)
      result.resolvedInviteCode = resolvedInviteCode;
    if (pendingTrustChallenge != null)
      result.pendingTrustChallenge = pendingTrustChallenge;
    return result;
  }

  HubSettingsSnapshot._();

  factory HubSettingsSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HubSettingsSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HubSettingsSnapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOM<HubStatus>(1, _omitFieldNames ? '' : 'status',
        subBuilder: HubStatus.create)
    ..aOM<Settings>(2, _omitFieldNames ? '' : 'settings',
        subBuilder: Settings.create)
    ..aOS(3, _omitFieldNames ? '' : 'resolvedHubAddress')
    ..aOS(4, _omitFieldNames ? '' : 'resolvedInviteCode')
    ..aOM<HubTrustChallenge>(5, _omitFieldNames ? '' : 'pendingTrustChallenge',
        subBuilder: HubTrustChallenge.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HubSettingsSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HubSettingsSnapshot copyWith(void Function(HubSettingsSnapshot) updates) =>
      super.copyWith((message) => updates(message as HubSettingsSnapshot))
          as HubSettingsSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HubSettingsSnapshot create() => HubSettingsSnapshot._();
  @$core.override
  HubSettingsSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HubSettingsSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HubSettingsSnapshot>(create);
  static HubSettingsSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  HubStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(HubStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);
  @$pb.TagNumber(1)
  HubStatus ensureStatus() => $_ensure(0);

  @$pb.TagNumber(2)
  Settings get settings => $_getN(1);
  @$pb.TagNumber(2)
  set settings(Settings value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSettings() => $_has(1);
  @$pb.TagNumber(2)
  void clearSettings() => $_clearField(2);
  @$pb.TagNumber(2)
  Settings ensureSettings() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get resolvedHubAddress => $_getSZ(2);
  @$pb.TagNumber(3)
  set resolvedHubAddress($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasResolvedHubAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearResolvedHubAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get resolvedInviteCode => $_getSZ(3);
  @$pb.TagNumber(4)
  set resolvedInviteCode($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasResolvedInviteCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearResolvedInviteCode() => $_clearField(4);

  @$pb.TagNumber(5)
  HubTrustChallenge get pendingTrustChallenge => $_getN(4);
  @$pb.TagNumber(5)
  set pendingTrustChallenge(HubTrustChallenge value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPendingTrustChallenge() => $_has(4);
  @$pb.TagNumber(5)
  void clearPendingTrustChallenge() => $_clearField(5);
  @$pb.TagNumber(5)
  HubTrustChallenge ensurePendingTrustChallenge() => $_ensure(4);
}

class HubOverview extends $pb.GeneratedMessage {
  factory HubOverview({
    $core.bool? hubConnected,
    $core.String? hubAddress,
    $core.String? userId,
    $core.String? tier,
    $core.int? maxNodes,
    $core.int? totalNodes,
    $core.int? onlineNodes,
    $core.int? pinnedNodes,
    $core.int? totalProxies,
    $fixnum.Int64? totalActiveConnections,
  }) {
    final result = create();
    if (hubConnected != null) result.hubConnected = hubConnected;
    if (hubAddress != null) result.hubAddress = hubAddress;
    if (userId != null) result.userId = userId;
    if (tier != null) result.tier = tier;
    if (maxNodes != null) result.maxNodes = maxNodes;
    if (totalNodes != null) result.totalNodes = totalNodes;
    if (onlineNodes != null) result.onlineNodes = onlineNodes;
    if (pinnedNodes != null) result.pinnedNodes = pinnedNodes;
    if (totalProxies != null) result.totalProxies = totalProxies;
    if (totalActiveConnections != null)
      result.totalActiveConnections = totalActiveConnections;
    return result;
  }

  HubOverview._();

  factory HubOverview.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HubOverview.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HubOverview',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'hubConnected')
    ..aOS(2, _omitFieldNames ? '' : 'hubAddress')
    ..aOS(3, _omitFieldNames ? '' : 'userId')
    ..aOS(4, _omitFieldNames ? '' : 'tier')
    ..aI(5, _omitFieldNames ? '' : 'maxNodes')
    ..aI(6, _omitFieldNames ? '' : 'totalNodes')
    ..aI(7, _omitFieldNames ? '' : 'onlineNodes')
    ..aI(8, _omitFieldNames ? '' : 'pinnedNodes')
    ..aI(9, _omitFieldNames ? '' : 'totalProxies')
    ..aInt64(10, _omitFieldNames ? '' : 'totalActiveConnections')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HubOverview clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HubOverview copyWith(void Function(HubOverview) updates) =>
      super.copyWith((message) => updates(message as HubOverview))
          as HubOverview;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HubOverview create() => HubOverview._();
  @$core.override
  HubOverview createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HubOverview getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HubOverview>(create);
  static HubOverview? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get hubConnected => $_getBF(0);
  @$pb.TagNumber(1)
  set hubConnected($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHubConnected() => $_has(0);
  @$pb.TagNumber(1)
  void clearHubConnected() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get hubAddress => $_getSZ(1);
  @$pb.TagNumber(2)
  set hubAddress($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHubAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearHubAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get tier => $_getSZ(3);
  @$pb.TagNumber(4)
  set tier($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTier() => $_has(3);
  @$pb.TagNumber(4)
  void clearTier() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get maxNodes => $_getIZ(4);
  @$pb.TagNumber(5)
  set maxNodes($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMaxNodes() => $_has(4);
  @$pb.TagNumber(5)
  void clearMaxNodes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get totalNodes => $_getIZ(5);
  @$pb.TagNumber(6)
  set totalNodes($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalNodes() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalNodes() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get onlineNodes => $_getIZ(6);
  @$pb.TagNumber(7)
  set onlineNodes($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOnlineNodes() => $_has(6);
  @$pb.TagNumber(7)
  void clearOnlineNodes() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get pinnedNodes => $_getIZ(7);
  @$pb.TagNumber(8)
  set pinnedNodes($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPinnedNodes() => $_has(7);
  @$pb.TagNumber(8)
  void clearPinnedNodes() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get totalProxies => $_getIZ(8);
  @$pb.TagNumber(9)
  set totalProxies($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTotalProxies() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotalProxies() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get totalActiveConnections => $_getI64(9);
  @$pb.TagNumber(10)
  set totalActiveConnections($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasTotalActiveConnections() => $_has(9);
  @$pb.TagNumber(10)
  void clearTotalActiveConnections() => $_clearField(10);
}

class GetHubDashboardSnapshotRequest extends $pb.GeneratedMessage {
  factory GetHubDashboardSnapshotRequest({
    $core.String? nodeFilter,
  }) {
    final result = create();
    if (nodeFilter != null) result.nodeFilter = nodeFilter;
    return result;
  }

  GetHubDashboardSnapshotRequest._();

  factory GetHubDashboardSnapshotRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHubDashboardSnapshotRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHubDashboardSnapshotRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeFilter')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHubDashboardSnapshotRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHubDashboardSnapshotRequest copyWith(
          void Function(GetHubDashboardSnapshotRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetHubDashboardSnapshotRequest))
          as GetHubDashboardSnapshotRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHubDashboardSnapshotRequest create() =>
      GetHubDashboardSnapshotRequest._();
  @$core.override
  GetHubDashboardSnapshotRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHubDashboardSnapshotRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHubDashboardSnapshotRequest>(create);
  static GetHubDashboardSnapshotRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeFilter => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeFilter($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeFilter() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeFilter() => $_clearField(1);
}

class HubDashboardSnapshot extends $pb.GeneratedMessage {
  factory HubDashboardSnapshot({
    HubOverview? overview,
    $core.Iterable<NodeInfo>? nodes,
    $core.Iterable<NodeInfo>? pinnedNodes,
  }) {
    final result = create();
    if (overview != null) result.overview = overview;
    if (nodes != null) result.nodes.addAll(nodes);
    if (pinnedNodes != null) result.pinnedNodes.addAll(pinnedNodes);
    return result;
  }

  HubDashboardSnapshot._();

  factory HubDashboardSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HubDashboardSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HubDashboardSnapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOM<HubOverview>(1, _omitFieldNames ? '' : 'overview',
        subBuilder: HubOverview.create)
    ..pPM<NodeInfo>(2, _omitFieldNames ? '' : 'nodes',
        subBuilder: NodeInfo.create)
    ..pPM<NodeInfo>(3, _omitFieldNames ? '' : 'pinnedNodes',
        subBuilder: NodeInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HubDashboardSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HubDashboardSnapshot copyWith(void Function(HubDashboardSnapshot) updates) =>
      super.copyWith((message) => updates(message as HubDashboardSnapshot))
          as HubDashboardSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HubDashboardSnapshot create() => HubDashboardSnapshot._();
  @$core.override
  HubDashboardSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HubDashboardSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HubDashboardSnapshot>(create);
  static HubDashboardSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  HubOverview get overview => $_getN(0);
  @$pb.TagNumber(1)
  set overview(HubOverview value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOverview() => $_has(0);
  @$pb.TagNumber(1)
  void clearOverview() => $_clearField(1);
  @$pb.TagNumber(1)
  HubOverview ensureOverview() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<NodeInfo> get nodes => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<NodeInfo> get pinnedNodes => $_getList(2);
}

class RegisterUserRequest extends $pb.GeneratedMessage {
  factory RegisterUserRequest({
    $core.String? email,
    $core.String? inviteCode,
    $core.List<$core.int>? biometricPublicKey,
  }) {
    final result = create();
    if (email != null) result.email = email;
    if (inviteCode != null) result.inviteCode = inviteCode;
    if (biometricPublicKey != null)
      result.biometricPublicKey = biometricPublicKey;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'email')
    ..aOS(2, _omitFieldNames ? '' : 'inviteCode')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'biometricPublicKey', $pb.PbFieldType.OY)
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
  $core.String get email => $_getSZ(0);
  @$pb.TagNumber(1)
  set email($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEmail() => $_has(0);
  @$pb.TagNumber(1)
  void clearEmail() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get inviteCode => $_getSZ(1);
  @$pb.TagNumber(2)
  set inviteCode($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInviteCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearInviteCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get biometricPublicKey => $_getN(2);
  @$pb.TagNumber(3)
  set biometricPublicKey($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBiometricPublicKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearBiometricPublicKey() => $_clearField(3);
}

class RegisterUserResponse extends $pb.GeneratedMessage {
  factory RegisterUserResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? userId,
    $core.String? tier,
    $core.int? maxNodes,
    $core.String? jwtToken,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (userId != null) result.userId = userId;
    if (tier != null) result.tier = tier;
    if (maxNodes != null) result.maxNodes = maxNodes;
    if (jwtToken != null) result.jwtToken = jwtToken;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'userId')
    ..aOS(4, _omitFieldNames ? '' : 'tier')
    ..aI(5, _omitFieldNames ? '' : 'maxNodes')
    ..aOS(6, _omitFieldNames ? '' : 'jwtToken')
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

  @$pb.TagNumber(3)
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get tier => $_getSZ(3);
  @$pb.TagNumber(4)
  set tier($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTier() => $_has(3);
  @$pb.TagNumber(4)
  void clearTier() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get maxNodes => $_getIZ(4);
  @$pb.TagNumber(5)
  set maxNodes($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMaxNodes() => $_has(4);
  @$pb.TagNumber(5)
  void clearMaxNodes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get jwtToken => $_getSZ(5);
  @$pb.TagNumber(6)
  set jwtToken($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasJwtToken() => $_has(5);
  @$pb.TagNumber(6)
  void clearJwtToken() => $_clearField(6);
}

class OnboardHubRequest extends $pb.GeneratedMessage {
  factory OnboardHubRequest({
    $core.String? hubAddress,
    $core.String? inviteCode,
    $core.String? token,
    $core.List<$core.int>? biometricPublicKey,
    $core.bool? trustPromptAccepted,
    $core.String? trustChallengeId,
    $core.bool? skipRegistration,
    $core.bool? persistSettings,
  }) {
    final result = create();
    if (hubAddress != null) result.hubAddress = hubAddress;
    if (inviteCode != null) result.inviteCode = inviteCode;
    if (token != null) result.token = token;
    if (biometricPublicKey != null)
      result.biometricPublicKey = biometricPublicKey;
    if (trustPromptAccepted != null)
      result.trustPromptAccepted = trustPromptAccepted;
    if (trustChallengeId != null) result.trustChallengeId = trustChallengeId;
    if (skipRegistration != null) result.skipRegistration = skipRegistration;
    if (persistSettings != null) result.persistSettings = persistSettings;
    return result;
  }

  OnboardHubRequest._();

  factory OnboardHubRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OnboardHubRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OnboardHubRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hubAddress')
    ..aOS(2, _omitFieldNames ? '' : 'inviteCode')
    ..aOS(3, _omitFieldNames ? '' : 'token')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'biometricPublicKey', $pb.PbFieldType.OY)
    ..aOB(10, _omitFieldNames ? '' : 'trustPromptAccepted')
    ..aOS(11, _omitFieldNames ? '' : 'trustChallengeId')
    ..aOB(14, _omitFieldNames ? '' : 'skipRegistration')
    ..aOB(15, _omitFieldNames ? '' : 'persistSettings')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardHubRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardHubRequest copyWith(void Function(OnboardHubRequest) updates) =>
      super.copyWith((message) => updates(message as OnboardHubRequest))
          as OnboardHubRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OnboardHubRequest create() => OnboardHubRequest._();
  @$core.override
  OnboardHubRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static OnboardHubRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OnboardHubRequest>(create);
  static OnboardHubRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hubAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set hubAddress($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHubAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearHubAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get inviteCode => $_getSZ(1);
  @$pb.TagNumber(2)
  set inviteCode($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInviteCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearInviteCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get token => $_getSZ(2);
  @$pb.TagNumber(3)
  set token($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearToken() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get biometricPublicKey => $_getN(3);
  @$pb.TagNumber(4)
  set biometricPublicKey($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBiometricPublicKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearBiometricPublicKey() => $_clearField(4);

  /// TOFU confirmation fields (used when stage = NEEDS_TRUST)
  @$pb.TagNumber(10)
  $core.bool get trustPromptAccepted => $_getBF(4);
  @$pb.TagNumber(10)
  set trustPromptAccepted($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(10)
  $core.bool hasTrustPromptAccepted() => $_has(4);
  @$pb.TagNumber(10)
  void clearTrustPromptAccepted() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get trustChallengeId => $_getSZ(5);
  @$pb.TagNumber(11)
  set trustChallengeId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(11)
  $core.bool hasTrustChallengeId() => $_has(5);
  @$pb.TagNumber(11)
  void clearTrustChallengeId() => $_clearField(11);

  /// If true, only establish verified connection (skip registration).
  @$pb.TagNumber(14)
  $core.bool get skipRegistration => $_getBF(6);
  @$pb.TagNumber(14)
  set skipRegistration($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(14)
  $core.bool hasSkipRegistration() => $_has(6);
  @$pb.TagNumber(14)
  void clearSkipRegistration() => $_clearField(14);

  /// If true, persist hub_address/invite_code into backend settings before onboarding.
  @$pb.TagNumber(15)
  $core.bool get persistSettings => $_getBF(7);
  @$pb.TagNumber(15)
  set persistSettings($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(15)
  $core.bool hasPersistSettings() => $_has(7);
  @$pb.TagNumber(15)
  void clearPersistSettings() => $_clearField(15);
}

class EnsureHubRegisteredRequest extends $pb.GeneratedMessage {
  factory EnsureHubRegisteredRequest({
    $core.String? hubAddress,
    $core.String? inviteCode,
    $core.String? token,
    $core.List<$core.int>? biometricPublicKey,
    $core.bool? persistSettings,
  }) {
    final result = create();
    if (hubAddress != null) result.hubAddress = hubAddress;
    if (inviteCode != null) result.inviteCode = inviteCode;
    if (token != null) result.token = token;
    if (biometricPublicKey != null)
      result.biometricPublicKey = biometricPublicKey;
    if (persistSettings != null) result.persistSettings = persistSettings;
    return result;
  }

  EnsureHubRegisteredRequest._();

  factory EnsureHubRegisteredRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EnsureHubRegisteredRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EnsureHubRegisteredRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hubAddress')
    ..aOS(2, _omitFieldNames ? '' : 'inviteCode')
    ..aOS(3, _omitFieldNames ? '' : 'token')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'biometricPublicKey', $pb.PbFieldType.OY)
    ..aOB(5, _omitFieldNames ? '' : 'persistSettings')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnsureHubRegisteredRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnsureHubRegisteredRequest copyWith(
          void Function(EnsureHubRegisteredRequest) updates) =>
      super.copyWith(
              (message) => updates(message as EnsureHubRegisteredRequest))
          as EnsureHubRegisteredRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EnsureHubRegisteredRequest create() => EnsureHubRegisteredRequest._();
  @$core.override
  EnsureHubRegisteredRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EnsureHubRegisteredRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EnsureHubRegisteredRequest>(create);
  static EnsureHubRegisteredRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hubAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set hubAddress($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHubAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearHubAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get inviteCode => $_getSZ(1);
  @$pb.TagNumber(2)
  set inviteCode($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInviteCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearInviteCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get token => $_getSZ(2);
  @$pb.TagNumber(3)
  set token($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearToken() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get biometricPublicKey => $_getN(3);
  @$pb.TagNumber(4)
  set biometricPublicKey($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBiometricPublicKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearBiometricPublicKey() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get persistSettings => $_getBF(4);
  @$pb.TagNumber(5)
  set persistSettings($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPersistSettings() => $_has(4);
  @$pb.TagNumber(5)
  void clearPersistSettings() => $_clearField(5);
}

class EnsureHubConnectedRequest extends $pb.GeneratedMessage {
  factory EnsureHubConnectedRequest({
    $core.String? hubAddress,
    $core.String? token,
    $core.bool? persistSettings,
  }) {
    final result = create();
    if (hubAddress != null) result.hubAddress = hubAddress;
    if (token != null) result.token = token;
    if (persistSettings != null) result.persistSettings = persistSettings;
    return result;
  }

  EnsureHubConnectedRequest._();

  factory EnsureHubConnectedRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EnsureHubConnectedRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EnsureHubConnectedRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hubAddress')
    ..aOS(2, _omitFieldNames ? '' : 'token')
    ..aOB(3, _omitFieldNames ? '' : 'persistSettings')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnsureHubConnectedRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnsureHubConnectedRequest copyWith(
          void Function(EnsureHubConnectedRequest) updates) =>
      super.copyWith((message) => updates(message as EnsureHubConnectedRequest))
          as EnsureHubConnectedRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EnsureHubConnectedRequest create() => EnsureHubConnectedRequest._();
  @$core.override
  EnsureHubConnectedRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EnsureHubConnectedRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EnsureHubConnectedRequest>(create);
  static EnsureHubConnectedRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hubAddress => $_getSZ(0);
  @$pb.TagNumber(1)
  set hubAddress($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHubAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearHubAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get token => $_getSZ(1);
  @$pb.TagNumber(2)
  set token($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get persistSettings => $_getBF(2);
  @$pb.TagNumber(3)
  set persistSettings($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPersistSettings() => $_has(2);
  @$pb.TagNumber(3)
  void clearPersistSettings() => $_clearField(3);
}

class HubTrustChallenge extends $pb.GeneratedMessage {
  factory HubTrustChallenge({
    $core.List<$core.int>? caPem,
    $core.String? fingerprint,
    $core.String? emojiHash,
    $core.String? subject,
    $core.String? expires,
    $core.String? challengeId,
  }) {
    final result = create();
    if (caPem != null) result.caPem = caPem;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (emojiHash != null) result.emojiHash = emojiHash;
    if (subject != null) result.subject = subject;
    if (expires != null) result.expires = expires;
    if (challengeId != null) result.challengeId = challengeId;
    return result;
  }

  HubTrustChallenge._();

  factory HubTrustChallenge.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HubTrustChallenge.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HubTrustChallenge',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'caPem', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(3, _omitFieldNames ? '' : 'emojiHash')
    ..aOS(4, _omitFieldNames ? '' : 'subject')
    ..aOS(5, _omitFieldNames ? '' : 'expires')
    ..aOS(6, _omitFieldNames ? '' : 'challengeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HubTrustChallenge clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HubTrustChallenge copyWith(void Function(HubTrustChallenge) updates) =>
      super.copyWith((message) => updates(message as HubTrustChallenge))
          as HubTrustChallenge;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HubTrustChallenge create() => HubTrustChallenge._();
  @$core.override
  HubTrustChallenge createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HubTrustChallenge getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HubTrustChallenge>(create);
  static HubTrustChallenge? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get caPem => $_getN(0);
  @$pb.TagNumber(1)
  set caPem($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCaPem() => $_has(0);
  @$pb.TagNumber(1)
  void clearCaPem() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fingerprint => $_getSZ(1);
  @$pb.TagNumber(2)
  set fingerprint($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFingerprint() => $_has(1);
  @$pb.TagNumber(2)
  void clearFingerprint() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get emojiHash => $_getSZ(2);
  @$pb.TagNumber(3)
  set emojiHash($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEmojiHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmojiHash() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get subject => $_getSZ(3);
  @$pb.TagNumber(4)
  set subject($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSubject() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubject() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get expires => $_getSZ(4);
  @$pb.TagNumber(5)
  set expires($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpires() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpires() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get challengeId => $_getSZ(5);
  @$pb.TagNumber(6)
  set challengeId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasChallengeId() => $_has(5);
  @$pb.TagNumber(6)
  void clearChallengeId() => $_clearField(6);
}

class ResolveHubTrustChallengeRequest extends $pb.GeneratedMessage {
  factory ResolveHubTrustChallengeRequest({
    $core.String? challengeId,
    $core.bool? accepted,
  }) {
    final result = create();
    if (challengeId != null) result.challengeId = challengeId;
    if (accepted != null) result.accepted = accepted;
    return result;
  }

  ResolveHubTrustChallengeRequest._();

  factory ResolveHubTrustChallengeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResolveHubTrustChallengeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolveHubTrustChallengeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'challengeId')
    ..aOB(2, _omitFieldNames ? '' : 'accepted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveHubTrustChallengeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveHubTrustChallengeRequest copyWith(
          void Function(ResolveHubTrustChallengeRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ResolveHubTrustChallengeRequest))
          as ResolveHubTrustChallengeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResolveHubTrustChallengeRequest create() =>
      ResolveHubTrustChallengeRequest._();
  @$core.override
  ResolveHubTrustChallengeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResolveHubTrustChallengeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolveHubTrustChallengeRequest>(
          create);
  static ResolveHubTrustChallengeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get challengeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set challengeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChallengeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChallengeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get accepted => $_getBF(1);
  @$pb.TagNumber(2)
  set accepted($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAccepted() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccepted() => $_clearField(2);
}

class OnboardHubResponse extends $pb.GeneratedMessage {
  factory OnboardHubResponse({
    OnboardHubResponse_Stage? stage,
    $core.bool? success,
    $core.String? error,
    $core.String? hubAddress,
    $core.bool? connected,
    $core.bool? registered,
    $core.String? userId,
    $core.String? tier,
    $core.int? maxNodes,
    HubTrustChallenge? trustChallenge,
  }) {
    final result = create();
    if (stage != null) result.stage = stage;
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (hubAddress != null) result.hubAddress = hubAddress;
    if (connected != null) result.connected = connected;
    if (registered != null) result.registered = registered;
    if (userId != null) result.userId = userId;
    if (tier != null) result.tier = tier;
    if (maxNodes != null) result.maxNodes = maxNodes;
    if (trustChallenge != null) result.trustChallenge = trustChallenge;
    return result;
  }

  OnboardHubResponse._();

  factory OnboardHubResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OnboardHubResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OnboardHubResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aE<OnboardHubResponse_Stage>(1, _omitFieldNames ? '' : 'stage',
        enumValues: OnboardHubResponse_Stage.values)
    ..aOB(2, _omitFieldNames ? '' : 'success')
    ..aOS(3, _omitFieldNames ? '' : 'error')
    ..aOS(4, _omitFieldNames ? '' : 'hubAddress')
    ..aOB(5, _omitFieldNames ? '' : 'connected')
    ..aOB(6, _omitFieldNames ? '' : 'registered')
    ..aOS(7, _omitFieldNames ? '' : 'userId')
    ..aOS(8, _omitFieldNames ? '' : 'tier')
    ..aI(9, _omitFieldNames ? '' : 'maxNodes')
    ..aOM<HubTrustChallenge>(10, _omitFieldNames ? '' : 'trustChallenge',
        subBuilder: HubTrustChallenge.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardHubResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OnboardHubResponse copyWith(void Function(OnboardHubResponse) updates) =>
      super.copyWith((message) => updates(message as OnboardHubResponse))
          as OnboardHubResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OnboardHubResponse create() => OnboardHubResponse._();
  @$core.override
  OnboardHubResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static OnboardHubResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OnboardHubResponse>(create);
  static OnboardHubResponse? _defaultInstance;

  @$pb.TagNumber(1)
  OnboardHubResponse_Stage get stage => $_getN(0);
  @$pb.TagNumber(1)
  set stage(OnboardHubResponse_Stage value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStage() => $_has(0);
  @$pb.TagNumber(1)
  void clearStage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get success => $_getBF(1);
  @$pb.TagNumber(2)
  set success($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSuccess() => $_has(1);
  @$pb.TagNumber(2)
  void clearSuccess() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get error => $_getSZ(2);
  @$pb.TagNumber(3)
  set error($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get hubAddress => $_getSZ(3);
  @$pb.TagNumber(4)
  set hubAddress($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHubAddress() => $_has(3);
  @$pb.TagNumber(4)
  void clearHubAddress() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get connected => $_getBF(4);
  @$pb.TagNumber(5)
  set connected($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConnected() => $_has(4);
  @$pb.TagNumber(5)
  void clearConnected() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get registered => $_getBF(5);
  @$pb.TagNumber(6)
  set registered($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRegistered() => $_has(5);
  @$pb.TagNumber(6)
  void clearRegistered() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get userId => $_getSZ(6);
  @$pb.TagNumber(7)
  set userId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUserId() => $_has(6);
  @$pb.TagNumber(7)
  void clearUserId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get tier => $_getSZ(7);
  @$pb.TagNumber(8)
  set tier($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTier() => $_has(7);
  @$pb.TagNumber(8)
  void clearTier() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get maxNodes => $_getIZ(8);
  @$pb.TagNumber(9)
  set maxNodes($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMaxNodes() => $_has(8);
  @$pb.TagNumber(9)
  void clearMaxNodes() => $_clearField(9);

  @$pb.TagNumber(10)
  HubTrustChallenge get trustChallenge => $_getN(9);
  @$pb.TagNumber(10)
  set trustChallenge(HubTrustChallenge value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasTrustChallenge() => $_has(9);
  @$pb.TagNumber(10)
  void clearTrustChallenge() => $_clearField(10);
  @$pb.TagNumber(10)
  HubTrustChallenge ensureTrustChallenge() => $_ensure(9);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
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
    $5.GeoInfo? geo,
    $core.bool? cached,
  }) {
    final result = create();
    if (geo != null) result.geo = geo;
    if (cached != null) result.cached = cached;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOM<$5.GeoInfo>(1, _omitFieldNames ? '' : 'geo',
        subBuilder: $5.GeoInfo.create)
    ..aOB(2, _omitFieldNames ? '' : 'cached')
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
  $5.GeoInfo get geo => $_getN(0);
  @$pb.TagNumber(1)
  set geo($5.GeoInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGeo() => $_has(0);
  @$pb.TagNumber(1)
  void clearGeo() => $_clearField(1);
  @$pb.TagNumber(1)
  $5.GeoInfo ensureGeo() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.bool get cached => $_getBF(1);
  @$pb.TagNumber(2)
  set cached($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCached() => $_has(1);
  @$pb.TagNumber(2)
  void clearCached() => $_clearField(2);
}

class ConfigureGeoIPNodeRequest extends $pb.GeneratedMessage {
  factory ConfigureGeoIPNodeRequest({
    $core.String? nodeId,
    $2.ConfigureGeoIPRequest? config,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (config != null) result.config = config;
    return result;
  }

  ConfigureGeoIPNodeRequest._();

  factory ConfigureGeoIPNodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConfigureGeoIPNodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConfigureGeoIPNodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOM<$2.ConfigureGeoIPRequest>(2, _omitFieldNames ? '' : 'config',
        subBuilder: $2.ConfigureGeoIPRequest.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigureGeoIPNodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigureGeoIPNodeRequest copyWith(
          void Function(ConfigureGeoIPNodeRequest) updates) =>
      super.copyWith((message) => updates(message as ConfigureGeoIPNodeRequest))
          as ConfigureGeoIPNodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConfigureGeoIPNodeRequest create() => ConfigureGeoIPNodeRequest._();
  @$core.override
  ConfigureGeoIPNodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConfigureGeoIPNodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConfigureGeoIPNodeRequest>(create);
  static ConfigureGeoIPNodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $2.ConfigureGeoIPRequest get config => $_getN(1);
  @$pb.TagNumber(2)
  set config($2.ConfigureGeoIPRequest value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasConfig() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfig() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.ConfigureGeoIPRequest ensureConfig() => $_ensure(1);
}

class GetGeoIPStatusNodeRequest extends $pb.GeneratedMessage {
  factory GetGeoIPStatusNodeRequest({
    $core.String? nodeId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    return result;
  }

  GetGeoIPStatusNodeRequest._();

  factory GetGeoIPStatusNodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGeoIPStatusNodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGeoIPStatusNodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGeoIPStatusNodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGeoIPStatusNodeRequest copyWith(
          void Function(GetGeoIPStatusNodeRequest) updates) =>
      super.copyWith((message) => updates(message as GetGeoIPStatusNodeRequest))
          as GetGeoIPStatusNodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGeoIPStatusNodeRequest create() => GetGeoIPStatusNodeRequest._();
  @$core.override
  GetGeoIPStatusNodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGeoIPStatusNodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGeoIPStatusNodeRequest>(create);
  static GetGeoIPStatusNodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);
}

class RestartListenersNodeRequest extends $pb.GeneratedMessage {
  factory RestartListenersNodeRequest({
    $core.String? nodeId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    return result;
  }

  RestartListenersNodeRequest._();

  factory RestartListenersNodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RestartListenersNodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RestartListenersNodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestartListenersNodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestartListenersNodeRequest copyWith(
          void Function(RestartListenersNodeRequest) updates) =>
      super.copyWith(
              (message) => updates(message as RestartListenersNodeRequest))
          as RestartListenersNodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RestartListenersNodeRequest create() =>
      RestartListenersNodeRequest._();
  @$core.override
  RestartListenersNodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RestartListenersNodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RestartListenersNodeRequest>(create);
  static RestartListenersNodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);
}

class NodeStatusChange extends $pb.GeneratedMessage {
  factory NodeStatusChange({
    $core.String? nodeId,
    $core.String? name,
    $core.bool? online,
    $3.Timestamp? timestamp,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (name != null) result.name = name;
    if (online != null) result.online = online;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  NodeStatusChange._();

  factory NodeStatusChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NodeStatusChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeStatusChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOB(3, _omitFieldNames ? '' : 'online')
    ..aOM<$3.Timestamp>(4, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $3.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeStatusChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeStatusChange copyWith(void Function(NodeStatusChange) updates) =>
      super.copyWith((message) => updates(message as NodeStatusChange))
          as NodeStatusChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NodeStatusChange create() => NodeStatusChange._();
  @$core.override
  NodeStatusChange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NodeStatusChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NodeStatusChange>(create);
  static NodeStatusChange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get online => $_getBF(2);
  @$pb.TagNumber(3)
  set online($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOnline() => $_has(2);
  @$pb.TagNumber(3)
  void clearOnline() => $_clearField(3);

  @$pb.TagNumber(4)
  $3.Timestamp get timestamp => $_getN(3);
  @$pb.TagNumber(4)
  set timestamp($3.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
  @$pb.TagNumber(4)
  $3.Timestamp ensureTimestamp() => $_ensure(3);
}

class Alert extends $pb.GeneratedMessage {
  factory Alert({
    $core.String? id,
    $core.String? nodeId,
    $core.String? title,
    $core.String? message,
    AlertSeverity? severity,
    $3.Timestamp? timestamp,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (nodeId != null) result.nodeId = nodeId;
    if (title != null) result.title = title;
    if (message != null) result.message = message;
    if (severity != null) result.severity = severity;
    if (timestamp != null) result.timestamp = timestamp;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  Alert._();

  factory Alert.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Alert.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Alert',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'nodeId')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'message')
    ..aE<AlertSeverity>(5, _omitFieldNames ? '' : 'severity',
        enumValues: AlertSeverity.values)
    ..aOM<$3.Timestamp>(6, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $3.Timestamp.create)
    ..m<$core.String, $core.String>(7, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'Alert.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('nitella.local'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Alert clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Alert copyWith(void Function(Alert) updates) =>
      super.copyWith((message) => updates(message as Alert)) as Alert;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Alert create() => Alert._();
  @$core.override
  Alert createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Alert getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Alert>(create);
  static Alert? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => $_clearField(4);

  @$pb.TagNumber(5)
  AlertSeverity get severity => $_getN(4);
  @$pb.TagNumber(5)
  set severity(AlertSeverity value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSeverity() => $_has(4);
  @$pb.TagNumber(5)
  void clearSeverity() => $_clearField(5);

  @$pb.TagNumber(6)
  $3.Timestamp get timestamp => $_getN(5);
  @$pb.TagNumber(6)
  set timestamp($3.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimestamp() => $_clearField(6);
  @$pb.TagNumber(6)
  $3.Timestamp ensureTimestamp() => $_ensure(5);

  @$pb.TagNumber(7)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(6);
}

class ToastMessage extends $pb.GeneratedMessage {
  factory ToastMessage({
    $core.String? message,
    ToastType? type,
    $core.int? durationMs,
  }) {
    final result = create();
    if (message != null) result.message = message;
    if (type != null) result.type = type;
    if (durationMs != null) result.durationMs = durationMs;
    return result;
  }

  ToastMessage._();

  factory ToastMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ToastMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ToastMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..aE<ToastType>(2, _omitFieldNames ? '' : 'type',
        enumValues: ToastType.values)
    ..aI(3, _omitFieldNames ? '' : 'durationMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ToastMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ToastMessage copyWith(void Function(ToastMessage) updates) =>
      super.copyWith((message) => updates(message as ToastMessage))
          as ToastMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ToastMessage create() => ToastMessage._();
  @$core.override
  ToastMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ToastMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ToastMessage>(create);
  static ToastMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);

  @$pb.TagNumber(2)
  ToastType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(ToastType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get durationMs => $_getIZ(2);
  @$pb.TagNumber(3)
  set durationMs($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDurationMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearDurationMs() => $_clearField(3);
}

class P2PStatus extends $pb.GeneratedMessage {
  factory P2PStatus({
    $core.bool? enabled,
    $5.P2PMode? mode,
    $core.int? activeConnections,
    $core.Iterable<$core.String>? connectedNodes,
  }) {
    final result = create();
    if (enabled != null) result.enabled = enabled;
    if (mode != null) result.mode = mode;
    if (activeConnections != null) result.activeConnections = activeConnections;
    if (connectedNodes != null) result.connectedNodes.addAll(connectedNodes);
    return result;
  }

  P2PStatus._();

  factory P2PStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory P2PStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'P2PStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..aE<$5.P2PMode>(2, _omitFieldNames ? '' : 'mode',
        enumValues: $5.P2PMode.values)
    ..aI(3, _omitFieldNames ? '' : 'activeConnections')
    ..pPS(4, _omitFieldNames ? '' : 'connectedNodes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  P2PStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  P2PStatus copyWith(void Function(P2PStatus) updates) =>
      super.copyWith((message) => updates(message as P2PStatus)) as P2PStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static P2PStatus create() => P2PStatus._();
  @$core.override
  P2PStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static P2PStatus getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<P2PStatus>(create);
  static P2PStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => $_clearField(1);

  @$pb.TagNumber(2)
  $5.P2PMode get mode => $_getN(1);
  @$pb.TagNumber(2)
  set mode($5.P2PMode value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearMode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get activeConnections => $_getIZ(2);
  @$pb.TagNumber(3)
  set activeConnections($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasActiveConnections() => $_has(2);
  @$pb.TagNumber(3)
  void clearActiveConnections() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get connectedNodes => $_getList(3);
}

class P2PSettingsSnapshot extends $pb.GeneratedMessage {
  factory P2PSettingsSnapshot({
    P2PStatus? status,
    Settings? settings,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (settings != null) result.settings = settings;
    return result;
  }

  P2PSettingsSnapshot._();

  factory P2PSettingsSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory P2PSettingsSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'P2PSettingsSnapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOM<P2PStatus>(1, _omitFieldNames ? '' : 'status',
        subBuilder: P2PStatus.create)
    ..aOM<Settings>(2, _omitFieldNames ? '' : 'settings',
        subBuilder: Settings.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  P2PSettingsSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  P2PSettingsSnapshot copyWith(void Function(P2PSettingsSnapshot) updates) =>
      super.copyWith((message) => updates(message as P2PSettingsSnapshot))
          as P2PSettingsSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static P2PSettingsSnapshot create() => P2PSettingsSnapshot._();
  @$core.override
  P2PSettingsSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static P2PSettingsSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<P2PSettingsSnapshot>(create);
  static P2PSettingsSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  P2PStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(P2PStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);
  @$pb.TagNumber(1)
  P2PStatus ensureStatus() => $_ensure(0);

  @$pb.TagNumber(2)
  Settings get settings => $_getN(1);
  @$pb.TagNumber(2)
  set settings(Settings value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSettings() => $_has(1);
  @$pb.TagNumber(2)
  void clearSettings() => $_clearField(2);
  @$pb.TagNumber(2)
  Settings ensureSettings() => $_ensure(1);
}

class SetP2PModeRequest extends $pb.GeneratedMessage {
  factory SetP2PModeRequest({
    $5.P2PMode? mode,
  }) {
    final result = create();
    if (mode != null) result.mode = mode;
    return result;
  }

  SetP2PModeRequest._();

  factory SetP2PModeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetP2PModeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetP2PModeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aE<$5.P2PMode>(1, _omitFieldNames ? '' : 'mode',
        enumValues: $5.P2PMode.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetP2PModeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetP2PModeRequest copyWith(void Function(SetP2PModeRequest) updates) =>
      super.copyWith((message) => updates(message as SetP2PModeRequest))
          as SetP2PModeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetP2PModeRequest create() => SetP2PModeRequest._();
  @$core.override
  SetP2PModeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetP2PModeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetP2PModeRequest>(create);
  static SetP2PModeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $5.P2PMode get mode => $_getN(0);
  @$pb.TagNumber(1)
  set mode($5.P2PMode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);
}

class LocalProxyConfig extends $pb.GeneratedMessage {
  factory LocalProxyConfig({
    $core.String? proxyId,
    $core.String? name,
    $core.String? description,
    $3.Timestamp? createdAt,
    $3.Timestamp? updatedAt,
    $3.Timestamp? syncedAt,
    $fixnum.Int64? revisionNum,
    $core.String? configHash,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (syncedAt != null) result.syncedAt = syncedAt;
    if (revisionNum != null) result.revisionNum = revisionNum;
    if (configHash != null) result.configHash = configHash;
    return result;
  }

  LocalProxyConfig._();

  factory LocalProxyConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LocalProxyConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LocalProxyConfig',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOM<$3.Timestamp>(4, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $3.Timestamp.create)
    ..aOM<$3.Timestamp>(5, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $3.Timestamp.create)
    ..aOM<$3.Timestamp>(6, _omitFieldNames ? '' : 'syncedAt',
        subBuilder: $3.Timestamp.create)
    ..aInt64(7, _omitFieldNames ? '' : 'revisionNum')
    ..aOS(8, _omitFieldNames ? '' : 'configHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocalProxyConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocalProxyConfig copyWith(void Function(LocalProxyConfig) updates) =>
      super.copyWith((message) => updates(message as LocalProxyConfig))
          as LocalProxyConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LocalProxyConfig create() => LocalProxyConfig._();
  @$core.override
  LocalProxyConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LocalProxyConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LocalProxyConfig>(create);
  static LocalProxyConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $3.Timestamp get createdAt => $_getN(3);
  @$pb.TagNumber(4)
  set createdAt($3.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $3.Timestamp ensureCreatedAt() => $_ensure(3);

  @$pb.TagNumber(5)
  $3.Timestamp get updatedAt => $_getN(4);
  @$pb.TagNumber(5)
  set updatedAt($3.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasUpdatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdatedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $3.Timestamp ensureUpdatedAt() => $_ensure(4);

  @$pb.TagNumber(6)
  $3.Timestamp get syncedAt => $_getN(5);
  @$pb.TagNumber(6)
  set syncedAt($3.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasSyncedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearSyncedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $3.Timestamp ensureSyncedAt() => $_ensure(5);

  @$pb.TagNumber(7)
  $fixnum.Int64 get revisionNum => $_getI64(6);
  @$pb.TagNumber(7)
  set revisionNum($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRevisionNum() => $_has(6);
  @$pb.TagNumber(7)
  void clearRevisionNum() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get configHash => $_getSZ(7);
  @$pb.TagNumber(8)
  set configHash($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasConfigHash() => $_has(7);
  @$pb.TagNumber(8)
  void clearConfigHash() => $_clearField(8);
}

class ListLocalProxyConfigsRequest extends $pb.GeneratedMessage {
  factory ListLocalProxyConfigsRequest() => create();

  ListLocalProxyConfigsRequest._();

  factory ListLocalProxyConfigsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListLocalProxyConfigsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListLocalProxyConfigsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLocalProxyConfigsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLocalProxyConfigsRequest copyWith(
          void Function(ListLocalProxyConfigsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ListLocalProxyConfigsRequest))
          as ListLocalProxyConfigsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListLocalProxyConfigsRequest create() =>
      ListLocalProxyConfigsRequest._();
  @$core.override
  ListLocalProxyConfigsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListLocalProxyConfigsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListLocalProxyConfigsRequest>(create);
  static ListLocalProxyConfigsRequest? _defaultInstance;
}

class ListLocalProxyConfigsResponse extends $pb.GeneratedMessage {
  factory ListLocalProxyConfigsResponse({
    $core.Iterable<LocalProxyConfig>? proxies,
  }) {
    final result = create();
    if (proxies != null) result.proxies.addAll(proxies);
    return result;
  }

  ListLocalProxyConfigsResponse._();

  factory ListLocalProxyConfigsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListLocalProxyConfigsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListLocalProxyConfigsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<LocalProxyConfig>(1, _omitFieldNames ? '' : 'proxies',
        subBuilder: LocalProxyConfig.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLocalProxyConfigsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLocalProxyConfigsResponse copyWith(
          void Function(ListLocalProxyConfigsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListLocalProxyConfigsResponse))
          as ListLocalProxyConfigsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListLocalProxyConfigsResponse create() =>
      ListLocalProxyConfigsResponse._();
  @$core.override
  ListLocalProxyConfigsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListLocalProxyConfigsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListLocalProxyConfigsResponse>(create);
  static ListLocalProxyConfigsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LocalProxyConfig> get proxies => $_getList(0);
}

class GetLocalProxyConfigRequest extends $pb.GeneratedMessage {
  factory GetLocalProxyConfigRequest({
    $core.String? proxyId,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    return result;
  }

  GetLocalProxyConfigRequest._();

  factory GetLocalProxyConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLocalProxyConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLocalProxyConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLocalProxyConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLocalProxyConfigRequest copyWith(
          void Function(GetLocalProxyConfigRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetLocalProxyConfigRequest))
          as GetLocalProxyConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLocalProxyConfigRequest create() => GetLocalProxyConfigRequest._();
  @$core.override
  GetLocalProxyConfigRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLocalProxyConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLocalProxyConfigRequest>(create);
  static GetLocalProxyConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);
}

class GetLocalProxyConfigResponse extends $pb.GeneratedMessage {
  factory GetLocalProxyConfigResponse({
    $core.bool? success,
    $core.String? error,
    LocalProxyConfig? proxy,
    $core.String? configYaml,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (proxy != null) result.proxy = proxy;
    if (configYaml != null) result.configYaml = configYaml;
    return result;
  }

  GetLocalProxyConfigResponse._();

  factory GetLocalProxyConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLocalProxyConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLocalProxyConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOM<LocalProxyConfig>(3, _omitFieldNames ? '' : 'proxy',
        subBuilder: LocalProxyConfig.create)
    ..aOS(4, _omitFieldNames ? '' : 'configYaml')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLocalProxyConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLocalProxyConfigResponse copyWith(
          void Function(GetLocalProxyConfigResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetLocalProxyConfigResponse))
          as GetLocalProxyConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLocalProxyConfigResponse create() =>
      GetLocalProxyConfigResponse._();
  @$core.override
  GetLocalProxyConfigResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLocalProxyConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLocalProxyConfigResponse>(create);
  static GetLocalProxyConfigResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  LocalProxyConfig get proxy => $_getN(2);
  @$pb.TagNumber(3)
  set proxy(LocalProxyConfig value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasProxy() => $_has(2);
  @$pb.TagNumber(3)
  void clearProxy() => $_clearField(3);
  @$pb.TagNumber(3)
  LocalProxyConfig ensureProxy() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get configYaml => $_getSZ(3);
  @$pb.TagNumber(4)
  set configYaml($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfigYaml() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfigYaml() => $_clearField(4);
}

class ImportLocalProxyConfigRequest extends $pb.GeneratedMessage {
  factory ImportLocalProxyConfigRequest({
    $core.List<$core.int>? configData,
    $core.String? sourceName,
    $core.String? name,
  }) {
    final result = create();
    if (configData != null) result.configData = configData;
    if (sourceName != null) result.sourceName = sourceName;
    if (name != null) result.name = name;
    return result;
  }

  ImportLocalProxyConfigRequest._();

  factory ImportLocalProxyConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportLocalProxyConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportLocalProxyConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'configData', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'sourceName')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportLocalProxyConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportLocalProxyConfigRequest copyWith(
          void Function(ImportLocalProxyConfigRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ImportLocalProxyConfigRequest))
          as ImportLocalProxyConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportLocalProxyConfigRequest create() =>
      ImportLocalProxyConfigRequest._();
  @$core.override
  ImportLocalProxyConfigRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportLocalProxyConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportLocalProxyConfigRequest>(create);
  static ImportLocalProxyConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get configData => $_getN(0);
  @$pb.TagNumber(1)
  set configData($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfigData() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfigData() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sourceName => $_getSZ(1);
  @$pb.TagNumber(2)
  set sourceName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSourceName() => $_has(1);
  @$pb.TagNumber(2)
  void clearSourceName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);
}

class ImportLocalProxyConfigResponse extends $pb.GeneratedMessage {
  factory ImportLocalProxyConfigResponse({
    $core.bool? success,
    $core.String? error,
    LocalProxyConfig? proxy,
    $core.String? configYaml,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (proxy != null) result.proxy = proxy;
    if (configYaml != null) result.configYaml = configYaml;
    return result;
  }

  ImportLocalProxyConfigResponse._();

  factory ImportLocalProxyConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportLocalProxyConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportLocalProxyConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOM<LocalProxyConfig>(3, _omitFieldNames ? '' : 'proxy',
        subBuilder: LocalProxyConfig.create)
    ..aOS(4, _omitFieldNames ? '' : 'configYaml')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportLocalProxyConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportLocalProxyConfigResponse copyWith(
          void Function(ImportLocalProxyConfigResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ImportLocalProxyConfigResponse))
          as ImportLocalProxyConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportLocalProxyConfigResponse create() =>
      ImportLocalProxyConfigResponse._();
  @$core.override
  ImportLocalProxyConfigResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportLocalProxyConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportLocalProxyConfigResponse>(create);
  static ImportLocalProxyConfigResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  LocalProxyConfig get proxy => $_getN(2);
  @$pb.TagNumber(3)
  set proxy(LocalProxyConfig value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasProxy() => $_has(2);
  @$pb.TagNumber(3)
  void clearProxy() => $_clearField(3);
  @$pb.TagNumber(3)
  LocalProxyConfig ensureProxy() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get configYaml => $_getSZ(3);
  @$pb.TagNumber(4)
  set configYaml($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfigYaml() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfigYaml() => $_clearField(4);
}

class SaveLocalProxyConfigRequest extends $pb.GeneratedMessage {
  factory SaveLocalProxyConfigRequest({
    $core.String? proxyId,
    $core.String? name,
    $core.String? description,
    $core.String? configYaml,
    $fixnum.Int64? revisionNum,
    $core.String? configHash,
    $core.bool? markSynced,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (configYaml != null) result.configYaml = configYaml;
    if (revisionNum != null) result.revisionNum = revisionNum;
    if (configHash != null) result.configHash = configHash;
    if (markSynced != null) result.markSynced = markSynced;
    return result;
  }

  SaveLocalProxyConfigRequest._();

  factory SaveLocalProxyConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SaveLocalProxyConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SaveLocalProxyConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'configYaml')
    ..aInt64(5, _omitFieldNames ? '' : 'revisionNum')
    ..aOS(6, _omitFieldNames ? '' : 'configHash')
    ..aOB(7, _omitFieldNames ? '' : 'markSynced')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveLocalProxyConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveLocalProxyConfigRequest copyWith(
          void Function(SaveLocalProxyConfigRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SaveLocalProxyConfigRequest))
          as SaveLocalProxyConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SaveLocalProxyConfigRequest create() =>
      SaveLocalProxyConfigRequest._();
  @$core.override
  SaveLocalProxyConfigRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SaveLocalProxyConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SaveLocalProxyConfigRequest>(create);
  static SaveLocalProxyConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get configYaml => $_getSZ(3);
  @$pb.TagNumber(4)
  set configYaml($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfigYaml() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfigYaml() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get revisionNum => $_getI64(4);
  @$pb.TagNumber(5)
  set revisionNum($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRevisionNum() => $_has(4);
  @$pb.TagNumber(5)
  void clearRevisionNum() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get configHash => $_getSZ(5);
  @$pb.TagNumber(6)
  set configHash($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasConfigHash() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfigHash() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get markSynced => $_getBF(6);
  @$pb.TagNumber(7)
  set markSynced($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMarkSynced() => $_has(6);
  @$pb.TagNumber(7)
  void clearMarkSynced() => $_clearField(7);
}

class SaveLocalProxyConfigResponse extends $pb.GeneratedMessage {
  factory SaveLocalProxyConfigResponse({
    $core.bool? success,
    $core.String? error,
    LocalProxyConfig? proxy,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (proxy != null) result.proxy = proxy;
    return result;
  }

  SaveLocalProxyConfigResponse._();

  factory SaveLocalProxyConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SaveLocalProxyConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SaveLocalProxyConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOM<LocalProxyConfig>(3, _omitFieldNames ? '' : 'proxy',
        subBuilder: LocalProxyConfig.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveLocalProxyConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveLocalProxyConfigResponse copyWith(
          void Function(SaveLocalProxyConfigResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SaveLocalProxyConfigResponse))
          as SaveLocalProxyConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SaveLocalProxyConfigResponse create() =>
      SaveLocalProxyConfigResponse._();
  @$core.override
  SaveLocalProxyConfigResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SaveLocalProxyConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SaveLocalProxyConfigResponse>(create);
  static SaveLocalProxyConfigResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  LocalProxyConfig get proxy => $_getN(2);
  @$pb.TagNumber(3)
  set proxy(LocalProxyConfig value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasProxy() => $_has(2);
  @$pb.TagNumber(3)
  void clearProxy() => $_clearField(3);
  @$pb.TagNumber(3)
  LocalProxyConfig ensureProxy() => $_ensure(2);
}

class DeleteLocalProxyConfigRequest extends $pb.GeneratedMessage {
  factory DeleteLocalProxyConfigRequest({
    $core.String? proxyId,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    return result;
  }

  DeleteLocalProxyConfigRequest._();

  factory DeleteLocalProxyConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteLocalProxyConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteLocalProxyConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteLocalProxyConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteLocalProxyConfigRequest copyWith(
          void Function(DeleteLocalProxyConfigRequest) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteLocalProxyConfigRequest))
          as DeleteLocalProxyConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteLocalProxyConfigRequest create() =>
      DeleteLocalProxyConfigRequest._();
  @$core.override
  DeleteLocalProxyConfigRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteLocalProxyConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteLocalProxyConfigRequest>(create);
  static DeleteLocalProxyConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);
}

class DeleteLocalProxyConfigResponse extends $pb.GeneratedMessage {
  factory DeleteLocalProxyConfigResponse({
    $core.bool? success,
    $core.String? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  DeleteLocalProxyConfigResponse._();

  factory DeleteLocalProxyConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteLocalProxyConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteLocalProxyConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteLocalProxyConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteLocalProxyConfigResponse copyWith(
          void Function(DeleteLocalProxyConfigResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteLocalProxyConfigResponse))
          as DeleteLocalProxyConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteLocalProxyConfigResponse create() =>
      DeleteLocalProxyConfigResponse._();
  @$core.override
  DeleteLocalProxyConfigResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteLocalProxyConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteLocalProxyConfigResponse>(create);
  static DeleteLocalProxyConfigResponse? _defaultInstance;

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

class ValidateLocalProxyConfigRequest extends $pb.GeneratedMessage {
  factory ValidateLocalProxyConfigRequest({
    $core.String? proxyId,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    return result;
  }

  ValidateLocalProxyConfigRequest._();

  factory ValidateLocalProxyConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ValidateLocalProxyConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ValidateLocalProxyConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateLocalProxyConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateLocalProxyConfigRequest copyWith(
          void Function(ValidateLocalProxyConfigRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ValidateLocalProxyConfigRequest))
          as ValidateLocalProxyConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateLocalProxyConfigRequest create() =>
      ValidateLocalProxyConfigRequest._();
  @$core.override
  ValidateLocalProxyConfigRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ValidateLocalProxyConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateLocalProxyConfigRequest>(
          create);
  static ValidateLocalProxyConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);
}

class ValidateLocalProxyConfigResponse extends $pb.GeneratedMessage {
  factory ValidateLocalProxyConfigResponse({
    $core.bool? success,
    $core.String? error,
    $core.bool? checksumOk,
    $core.String? checksumError,
    $core.bool? headerOk,
    $core.String? headerError,
    $core.String? headerType,
    $core.int? headerVersion,
    $core.bool? yamlOk,
    $core.String? yamlError,
    $core.bool? hasEntryPoints,
    $core.bool? hasTcp,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (checksumOk != null) result.checksumOk = checksumOk;
    if (checksumError != null) result.checksumError = checksumError;
    if (headerOk != null) result.headerOk = headerOk;
    if (headerError != null) result.headerError = headerError;
    if (headerType != null) result.headerType = headerType;
    if (headerVersion != null) result.headerVersion = headerVersion;
    if (yamlOk != null) result.yamlOk = yamlOk;
    if (yamlError != null) result.yamlError = yamlError;
    if (hasEntryPoints != null) result.hasEntryPoints = hasEntryPoints;
    if (hasTcp != null) result.hasTcp = hasTcp;
    return result;
  }

  ValidateLocalProxyConfigResponse._();

  factory ValidateLocalProxyConfigResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ValidateLocalProxyConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ValidateLocalProxyConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOB(3, _omitFieldNames ? '' : 'checksumOk')
    ..aOS(4, _omitFieldNames ? '' : 'checksumError')
    ..aOB(5, _omitFieldNames ? '' : 'headerOk')
    ..aOS(6, _omitFieldNames ? '' : 'headerError')
    ..aOS(7, _omitFieldNames ? '' : 'headerType')
    ..aI(8, _omitFieldNames ? '' : 'headerVersion')
    ..aOB(9, _omitFieldNames ? '' : 'yamlOk')
    ..aOS(10, _omitFieldNames ? '' : 'yamlError')
    ..aOB(11, _omitFieldNames ? '' : 'hasEntryPoints')
    ..aOB(12, _omitFieldNames ? '' : 'hasTcp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateLocalProxyConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateLocalProxyConfigResponse copyWith(
          void Function(ValidateLocalProxyConfigResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ValidateLocalProxyConfigResponse))
          as ValidateLocalProxyConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateLocalProxyConfigResponse create() =>
      ValidateLocalProxyConfigResponse._();
  @$core.override
  ValidateLocalProxyConfigResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ValidateLocalProxyConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateLocalProxyConfigResponse>(
          create);
  static ValidateLocalProxyConfigResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.bool get checksumOk => $_getBF(2);
  @$pb.TagNumber(3)
  set checksumOk($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChecksumOk() => $_has(2);
  @$pb.TagNumber(3)
  void clearChecksumOk() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get checksumError => $_getSZ(3);
  @$pb.TagNumber(4)
  set checksumError($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChecksumError() => $_has(3);
  @$pb.TagNumber(4)
  void clearChecksumError() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get headerOk => $_getBF(4);
  @$pb.TagNumber(5)
  set headerOk($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHeaderOk() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeaderOk() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get headerError => $_getSZ(5);
  @$pb.TagNumber(6)
  set headerError($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHeaderError() => $_has(5);
  @$pb.TagNumber(6)
  void clearHeaderError() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get headerType => $_getSZ(6);
  @$pb.TagNumber(7)
  set headerType($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasHeaderType() => $_has(6);
  @$pb.TagNumber(7)
  void clearHeaderType() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get headerVersion => $_getIZ(7);
  @$pb.TagNumber(8)
  set headerVersion($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasHeaderVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearHeaderVersion() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get yamlOk => $_getBF(8);
  @$pb.TagNumber(9)
  set yamlOk($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasYamlOk() => $_has(8);
  @$pb.TagNumber(9)
  void clearYamlOk() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get yamlError => $_getSZ(9);
  @$pb.TagNumber(10)
  set yamlError($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasYamlError() => $_has(9);
  @$pb.TagNumber(10)
  void clearYamlError() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get hasEntryPoints => $_getBF(10);
  @$pb.TagNumber(11)
  set hasEntryPoints($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasHasEntryPoints() => $_has(10);
  @$pb.TagNumber(11)
  void clearHasEntryPoints() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get hasTcp => $_getBF(11);
  @$pb.TagNumber(12)
  set hasTcp($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasHasTcp() => $_has(11);
  @$pb.TagNumber(12)
  void clearHasTcp() => $_clearField(12);
}

class PushProxyRevisionRequest extends $pb.GeneratedMessage {
  factory PushProxyRevisionRequest({
    $core.String? proxyId,
    $core.String? name,
    $core.String? description,
    $core.String? commitMessage,
    $core.String? configYaml,
    $core.String? configHash,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (commitMessage != null) result.commitMessage = commitMessage;
    if (configYaml != null) result.configYaml = configYaml;
    if (configHash != null) result.configHash = configHash;
    return result;
  }

  PushProxyRevisionRequest._();

  factory PushProxyRevisionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushProxyRevisionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushProxyRevisionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'commitMessage')
    ..aOS(5, _omitFieldNames ? '' : 'configYaml')
    ..aOS(6, _omitFieldNames ? '' : 'configHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushProxyRevisionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushProxyRevisionRequest copyWith(
          void Function(PushProxyRevisionRequest) updates) =>
      super.copyWith((message) => updates(message as PushProxyRevisionRequest))
          as PushProxyRevisionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushProxyRevisionRequest create() => PushProxyRevisionRequest._();
  @$core.override
  PushProxyRevisionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushProxyRevisionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushProxyRevisionRequest>(create);
  static PushProxyRevisionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get commitMessage => $_getSZ(3);
  @$pb.TagNumber(4)
  set commitMessage($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCommitMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearCommitMessage() => $_clearField(4);

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

class PushProxyRevisionResponse extends $pb.GeneratedMessage {
  factory PushProxyRevisionResponse({
    $core.bool? success,
    $core.String? error,
    $fixnum.Int64? revisionNum,
    $core.int? revisionsKept,
    $core.int? revisionsLimit,
    $core.int? storageUsedKb,
    $core.int? storageLimitKb,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (revisionNum != null) result.revisionNum = revisionNum;
    if (revisionsKept != null) result.revisionsKept = revisionsKept;
    if (revisionsLimit != null) result.revisionsLimit = revisionsLimit;
    if (storageUsedKb != null) result.storageUsedKb = storageUsedKb;
    if (storageLimitKb != null) result.storageLimitKb = storageLimitKb;
    return result;
  }

  PushProxyRevisionResponse._();

  factory PushProxyRevisionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushProxyRevisionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushProxyRevisionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aInt64(3, _omitFieldNames ? '' : 'revisionNum')
    ..aI(4, _omitFieldNames ? '' : 'revisionsKept')
    ..aI(5, _omitFieldNames ? '' : 'revisionsLimit')
    ..aI(6, _omitFieldNames ? '' : 'storageUsedKb')
    ..aI(7, _omitFieldNames ? '' : 'storageLimitKb')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushProxyRevisionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushProxyRevisionResponse copyWith(
          void Function(PushProxyRevisionResponse) updates) =>
      super.copyWith((message) => updates(message as PushProxyRevisionResponse))
          as PushProxyRevisionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushProxyRevisionResponse create() => PushProxyRevisionResponse._();
  @$core.override
  PushProxyRevisionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushProxyRevisionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushProxyRevisionResponse>(create);
  static PushProxyRevisionResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $fixnum.Int64 get revisionNum => $_getI64(2);
  @$pb.TagNumber(3)
  set revisionNum($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRevisionNum() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevisionNum() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get revisionsKept => $_getIZ(3);
  @$pb.TagNumber(4)
  set revisionsKept($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRevisionsKept() => $_has(3);
  @$pb.TagNumber(4)
  void clearRevisionsKept() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get revisionsLimit => $_getIZ(4);
  @$pb.TagNumber(5)
  set revisionsLimit($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRevisionsLimit() => $_has(4);
  @$pb.TagNumber(5)
  void clearRevisionsLimit() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get storageUsedKb => $_getIZ(5);
  @$pb.TagNumber(6)
  set storageUsedKb($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStorageUsedKb() => $_has(5);
  @$pb.TagNumber(6)
  void clearStorageUsedKb() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get storageLimitKb => $_getIZ(6);
  @$pb.TagNumber(7)
  set storageLimitKb($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStorageLimitKb() => $_has(6);
  @$pb.TagNumber(7)
  void clearStorageLimitKb() => $_clearField(7);
}

class PushLocalProxyRevisionRequest extends $pb.GeneratedMessage {
  factory PushLocalProxyRevisionRequest({
    $core.String? proxyId,
    $core.String? commitMessage,
    $core.bool? ensureRemote,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (commitMessage != null) result.commitMessage = commitMessage;
    if (ensureRemote != null) result.ensureRemote = ensureRemote;
    return result;
  }

  PushLocalProxyRevisionRequest._();

  factory PushLocalProxyRevisionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushLocalProxyRevisionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushLocalProxyRevisionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'commitMessage')
    ..aOB(3, _omitFieldNames ? '' : 'ensureRemote')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushLocalProxyRevisionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushLocalProxyRevisionRequest copyWith(
          void Function(PushLocalProxyRevisionRequest) updates) =>
      super.copyWith(
              (message) => updates(message as PushLocalProxyRevisionRequest))
          as PushLocalProxyRevisionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushLocalProxyRevisionRequest create() =>
      PushLocalProxyRevisionRequest._();
  @$core.override
  PushLocalProxyRevisionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushLocalProxyRevisionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushLocalProxyRevisionRequest>(create);
  static PushLocalProxyRevisionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commitMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set commitMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommitMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommitMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get ensureRemote => $_getBF(2);
  @$pb.TagNumber(3)
  set ensureRemote($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEnsureRemote() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnsureRemote() => $_clearField(3);
}

class PushLocalProxyRevisionResponse extends $pb.GeneratedMessage {
  factory PushLocalProxyRevisionResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? proxyId,
    $fixnum.Int64? revisionNum,
    $core.int? revisionsKept,
    $core.int? revisionsLimit,
    $core.int? storageUsedKb,
    $core.int? storageLimitKb,
    LocalProxyConfig? localProxy,
    $core.bool? remotePushed,
    $core.bool? localMetadataUpdated,
    $core.String? localMetadataError,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (proxyId != null) result.proxyId = proxyId;
    if (revisionNum != null) result.revisionNum = revisionNum;
    if (revisionsKept != null) result.revisionsKept = revisionsKept;
    if (revisionsLimit != null) result.revisionsLimit = revisionsLimit;
    if (storageUsedKb != null) result.storageUsedKb = storageUsedKb;
    if (storageLimitKb != null) result.storageLimitKb = storageLimitKb;
    if (localProxy != null) result.localProxy = localProxy;
    if (remotePushed != null) result.remotePushed = remotePushed;
    if (localMetadataUpdated != null)
      result.localMetadataUpdated = localMetadataUpdated;
    if (localMetadataError != null)
      result.localMetadataError = localMetadataError;
    return result;
  }

  PushLocalProxyRevisionResponse._();

  factory PushLocalProxyRevisionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushLocalProxyRevisionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushLocalProxyRevisionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'proxyId')
    ..aInt64(4, _omitFieldNames ? '' : 'revisionNum')
    ..aI(5, _omitFieldNames ? '' : 'revisionsKept')
    ..aI(6, _omitFieldNames ? '' : 'revisionsLimit')
    ..aI(7, _omitFieldNames ? '' : 'storageUsedKb')
    ..aI(8, _omitFieldNames ? '' : 'storageLimitKb')
    ..aOM<LocalProxyConfig>(9, _omitFieldNames ? '' : 'localProxy',
        subBuilder: LocalProxyConfig.create)
    ..aOB(10, _omitFieldNames ? '' : 'remotePushed')
    ..aOB(11, _omitFieldNames ? '' : 'localMetadataUpdated')
    ..aOS(12, _omitFieldNames ? '' : 'localMetadataError')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushLocalProxyRevisionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushLocalProxyRevisionResponse copyWith(
          void Function(PushLocalProxyRevisionResponse) updates) =>
      super.copyWith(
              (message) => updates(message as PushLocalProxyRevisionResponse))
          as PushLocalProxyRevisionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushLocalProxyRevisionResponse create() =>
      PushLocalProxyRevisionResponse._();
  @$core.override
  PushLocalProxyRevisionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushLocalProxyRevisionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushLocalProxyRevisionResponse>(create);
  static PushLocalProxyRevisionResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get proxyId => $_getSZ(2);
  @$pb.TagNumber(3)
  set proxyId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProxyId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProxyId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get revisionNum => $_getI64(3);
  @$pb.TagNumber(4)
  set revisionNum($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRevisionNum() => $_has(3);
  @$pb.TagNumber(4)
  void clearRevisionNum() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get revisionsKept => $_getIZ(4);
  @$pb.TagNumber(5)
  set revisionsKept($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRevisionsKept() => $_has(4);
  @$pb.TagNumber(5)
  void clearRevisionsKept() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get revisionsLimit => $_getIZ(5);
  @$pb.TagNumber(6)
  set revisionsLimit($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRevisionsLimit() => $_has(5);
  @$pb.TagNumber(6)
  void clearRevisionsLimit() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get storageUsedKb => $_getIZ(6);
  @$pb.TagNumber(7)
  set storageUsedKb($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStorageUsedKb() => $_has(6);
  @$pb.TagNumber(7)
  void clearStorageUsedKb() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get storageLimitKb => $_getIZ(7);
  @$pb.TagNumber(8)
  set storageLimitKb($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasStorageLimitKb() => $_has(7);
  @$pb.TagNumber(8)
  void clearStorageLimitKb() => $_clearField(8);

  @$pb.TagNumber(9)
  LocalProxyConfig get localProxy => $_getN(8);
  @$pb.TagNumber(9)
  set localProxy(LocalProxyConfig value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasLocalProxy() => $_has(8);
  @$pb.TagNumber(9)
  void clearLocalProxy() => $_clearField(9);
  @$pb.TagNumber(9)
  LocalProxyConfig ensureLocalProxy() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.bool get remotePushed => $_getBF(9);
  @$pb.TagNumber(10)
  set remotePushed($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRemotePushed() => $_has(9);
  @$pb.TagNumber(10)
  void clearRemotePushed() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get localMetadataUpdated => $_getBF(10);
  @$pb.TagNumber(11)
  set localMetadataUpdated($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasLocalMetadataUpdated() => $_has(10);
  @$pb.TagNumber(11)
  void clearLocalMetadataUpdated() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get localMetadataError => $_getSZ(11);
  @$pb.TagNumber(12)
  set localMetadataError($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasLocalMetadataError() => $_has(11);
  @$pb.TagNumber(12)
  void clearLocalMetadataError() => $_clearField(12);
}

class PullProxyRevisionRequest extends $pb.GeneratedMessage {
  factory PullProxyRevisionRequest({
    $core.String? proxyId,
    $fixnum.Int64? revisionNum,
    $core.bool? storeLocal,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (revisionNum != null) result.revisionNum = revisionNum;
    if (storeLocal != null) result.storeLocal = storeLocal;
    return result;
  }

  PullProxyRevisionRequest._();

  factory PullProxyRevisionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PullProxyRevisionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullProxyRevisionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aInt64(2, _omitFieldNames ? '' : 'revisionNum')
    ..aOB(3, _omitFieldNames ? '' : 'storeLocal')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullProxyRevisionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullProxyRevisionRequest copyWith(
          void Function(PullProxyRevisionRequest) updates) =>
      super.copyWith((message) => updates(message as PullProxyRevisionRequest))
          as PullProxyRevisionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PullProxyRevisionRequest create() => PullProxyRevisionRequest._();
  @$core.override
  PullProxyRevisionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PullProxyRevisionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PullProxyRevisionRequest>(create);
  static PullProxyRevisionRequest? _defaultInstance;

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
  $core.bool get storeLocal => $_getBF(2);
  @$pb.TagNumber(3)
  set storeLocal($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStoreLocal() => $_has(2);
  @$pb.TagNumber(3)
  void clearStoreLocal() => $_clearField(3);
}

class PullProxyRevisionResponse extends $pb.GeneratedMessage {
  factory PullProxyRevisionResponse({
    $core.bool? success,
    $core.String? error,
    $fixnum.Int64? revisionNum,
    $core.String? name,
    $core.String? description,
    $core.String? commitMessage,
    $core.String? configYaml,
    $core.String? configHash,
    $core.int? sizeBytes,
    LocalProxyConfig? localProxy,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (revisionNum != null) result.revisionNum = revisionNum;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (commitMessage != null) result.commitMessage = commitMessage;
    if (configYaml != null) result.configYaml = configYaml;
    if (configHash != null) result.configHash = configHash;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (localProxy != null) result.localProxy = localProxy;
    return result;
  }

  PullProxyRevisionResponse._();

  factory PullProxyRevisionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PullProxyRevisionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PullProxyRevisionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aInt64(3, _omitFieldNames ? '' : 'revisionNum')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aOS(6, _omitFieldNames ? '' : 'commitMessage')
    ..aOS(7, _omitFieldNames ? '' : 'configYaml')
    ..aOS(8, _omitFieldNames ? '' : 'configHash')
    ..aI(9, _omitFieldNames ? '' : 'sizeBytes')
    ..aOM<LocalProxyConfig>(10, _omitFieldNames ? '' : 'localProxy',
        subBuilder: LocalProxyConfig.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullProxyRevisionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PullProxyRevisionResponse copyWith(
          void Function(PullProxyRevisionResponse) updates) =>
      super.copyWith((message) => updates(message as PullProxyRevisionResponse))
          as PullProxyRevisionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PullProxyRevisionResponse create() => PullProxyRevisionResponse._();
  @$core.override
  PullProxyRevisionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PullProxyRevisionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PullProxyRevisionResponse>(create);
  static PullProxyRevisionResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $fixnum.Int64 get revisionNum => $_getI64(2);
  @$pb.TagNumber(3)
  set revisionNum($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRevisionNum() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevisionNum() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get commitMessage => $_getSZ(5);
  @$pb.TagNumber(6)
  set commitMessage($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCommitMessage() => $_has(5);
  @$pb.TagNumber(6)
  void clearCommitMessage() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get configYaml => $_getSZ(6);
  @$pb.TagNumber(7)
  set configYaml($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasConfigYaml() => $_has(6);
  @$pb.TagNumber(7)
  void clearConfigYaml() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get configHash => $_getSZ(7);
  @$pb.TagNumber(8)
  set configHash($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasConfigHash() => $_has(7);
  @$pb.TagNumber(8)
  void clearConfigHash() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get sizeBytes => $_getIZ(8);
  @$pb.TagNumber(9)
  set sizeBytes($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSizeBytes() => $_has(8);
  @$pb.TagNumber(9)
  void clearSizeBytes() => $_clearField(9);

  @$pb.TagNumber(10)
  LocalProxyConfig get localProxy => $_getN(9);
  @$pb.TagNumber(10)
  set localProxy(LocalProxyConfig value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasLocalProxy() => $_has(9);
  @$pb.TagNumber(10)
  void clearLocalProxy() => $_clearField(10);
  @$pb.TagNumber(10)
  LocalProxyConfig ensureLocalProxy() => $_ensure(9);
}

class DiffProxyRevisionsRequest extends $pb.GeneratedMessage {
  factory DiffProxyRevisionsRequest({
    $core.String? proxyId,
    $fixnum.Int64? revisionNumA,
    $fixnum.Int64? revisionNumB,
    $core.bool? localVsLatest,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (revisionNumA != null) result.revisionNumA = revisionNumA;
    if (revisionNumB != null) result.revisionNumB = revisionNumB;
    if (localVsLatest != null) result.localVsLatest = localVsLatest;
    return result;
  }

  DiffProxyRevisionsRequest._();

  factory DiffProxyRevisionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DiffProxyRevisionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiffProxyRevisionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aInt64(2, _omitFieldNames ? '' : 'revisionNumA')
    ..aInt64(3, _omitFieldNames ? '' : 'revisionNumB')
    ..aOB(4, _omitFieldNames ? '' : 'localVsLatest')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiffProxyRevisionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiffProxyRevisionsRequest copyWith(
          void Function(DiffProxyRevisionsRequest) updates) =>
      super.copyWith((message) => updates(message as DiffProxyRevisionsRequest))
          as DiffProxyRevisionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiffProxyRevisionsRequest create() => DiffProxyRevisionsRequest._();
  @$core.override
  DiffProxyRevisionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DiffProxyRevisionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiffProxyRevisionsRequest>(create);
  static DiffProxyRevisionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get revisionNumA => $_getI64(1);
  @$pb.TagNumber(2)
  set revisionNumA($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevisionNumA() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevisionNumA() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get revisionNumB => $_getI64(2);
  @$pb.TagNumber(3)
  set revisionNumB($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRevisionNumB() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevisionNumB() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get localVsLatest => $_getBF(3);
  @$pb.TagNumber(4)
  set localVsLatest($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLocalVsLatest() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocalVsLatest() => $_clearField(4);
}

class DiffProxyRevisionsResponse extends $pb.GeneratedMessage {
  factory DiffProxyRevisionsResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? leftLabel,
    $core.String? rightLabel,
    $core.String? unifiedDiff,
    $core.bool? hasDifferences,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (leftLabel != null) result.leftLabel = leftLabel;
    if (rightLabel != null) result.rightLabel = rightLabel;
    if (unifiedDiff != null) result.unifiedDiff = unifiedDiff;
    if (hasDifferences != null) result.hasDifferences = hasDifferences;
    return result;
  }

  DiffProxyRevisionsResponse._();

  factory DiffProxyRevisionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DiffProxyRevisionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiffProxyRevisionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'leftLabel')
    ..aOS(4, _omitFieldNames ? '' : 'rightLabel')
    ..aOS(5, _omitFieldNames ? '' : 'unifiedDiff')
    ..aOB(6, _omitFieldNames ? '' : 'hasDifferences')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiffProxyRevisionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiffProxyRevisionsResponse copyWith(
          void Function(DiffProxyRevisionsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DiffProxyRevisionsResponse))
          as DiffProxyRevisionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiffProxyRevisionsResponse create() => DiffProxyRevisionsResponse._();
  @$core.override
  DiffProxyRevisionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DiffProxyRevisionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiffProxyRevisionsResponse>(create);
  static DiffProxyRevisionsResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get leftLabel => $_getSZ(2);
  @$pb.TagNumber(3)
  set leftLabel($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLeftLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLeftLabel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get rightLabel => $_getSZ(3);
  @$pb.TagNumber(4)
  set rightLabel($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRightLabel() => $_has(3);
  @$pb.TagNumber(4)
  void clearRightLabel() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get unifiedDiff => $_getSZ(4);
  @$pb.TagNumber(5)
  set unifiedDiff($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUnifiedDiff() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnifiedDiff() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get hasDifferences => $_getBF(5);
  @$pb.TagNumber(6)
  set hasDifferences($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHasDifferences() => $_has(5);
  @$pb.TagNumber(6)
  void clearHasDifferences() => $_clearField(6);
}

class ListProxyRevisionsRequest extends $pb.GeneratedMessage {
  factory ListProxyRevisionsRequest({
    $core.String? proxyId,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    return result;
  }

  ListProxyRevisionsRequest._();

  factory ListProxyRevisionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListProxyRevisionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProxyRevisionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProxyRevisionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProxyRevisionsRequest copyWith(
          void Function(ListProxyRevisionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListProxyRevisionsRequest))
          as ListProxyRevisionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProxyRevisionsRequest create() => ListProxyRevisionsRequest._();
  @$core.override
  ListProxyRevisionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListProxyRevisionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListProxyRevisionsRequest>(create);
  static ListProxyRevisionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);
}

class ListProxyRevisionsResponse extends $pb.GeneratedMessage {
  factory ListProxyRevisionsResponse({
    $core.Iterable<ProxyRevisionMeta>? revisions,
  }) {
    final result = create();
    if (revisions != null) result.revisions.addAll(revisions);
    return result;
  }

  ListProxyRevisionsResponse._();

  factory ListProxyRevisionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListProxyRevisionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProxyRevisionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<ProxyRevisionMeta>(1, _omitFieldNames ? '' : 'revisions',
        subBuilder: ProxyRevisionMeta.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProxyRevisionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProxyRevisionsResponse copyWith(
          void Function(ListProxyRevisionsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListProxyRevisionsResponse))
          as ListProxyRevisionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProxyRevisionsResponse create() => ListProxyRevisionsResponse._();
  @$core.override
  ListProxyRevisionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListProxyRevisionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListProxyRevisionsResponse>(create);
  static ListProxyRevisionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ProxyRevisionMeta> get revisions => $_getList(0);
}

class ProxyRevisionMeta extends $pb.GeneratedMessage {
  factory ProxyRevisionMeta({
    $fixnum.Int64? revisionNum,
    $core.int? sizeBytes,
    $3.Timestamp? createdAt,
  }) {
    final result = create();
    if (revisionNum != null) result.revisionNum = revisionNum;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  ProxyRevisionMeta._();

  factory ProxyRevisionMeta.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProxyRevisionMeta.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProxyRevisionMeta',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'revisionNum')
    ..aI(2, _omitFieldNames ? '' : 'sizeBytes')
    ..aOM<$3.Timestamp>(3, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $3.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProxyRevisionMeta clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProxyRevisionMeta copyWith(void Function(ProxyRevisionMeta) updates) =>
      super.copyWith((message) => updates(message as ProxyRevisionMeta))
          as ProxyRevisionMeta;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProxyRevisionMeta create() => ProxyRevisionMeta._();
  @$core.override
  ProxyRevisionMeta createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProxyRevisionMeta getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProxyRevisionMeta>(create);
  static ProxyRevisionMeta? _defaultInstance;

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
  $3.Timestamp get createdAt => $_getN(2);
  @$pb.TagNumber(3)
  set createdAt($3.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCreatedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreatedAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.Timestamp ensureCreatedAt() => $_ensure(2);
}

class FlushProxyRevisionsRequest extends $pb.GeneratedMessage {
  factory FlushProxyRevisionsRequest({
    $core.String? proxyId,
    $core.int? keepCount,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (keepCount != null) result.keepCount = keepCount;
    return result;
  }

  FlushProxyRevisionsRequest._();

  factory FlushProxyRevisionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FlushProxyRevisionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FlushProxyRevisionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aI(2, _omitFieldNames ? '' : 'keepCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlushProxyRevisionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlushProxyRevisionsRequest copyWith(
          void Function(FlushProxyRevisionsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as FlushProxyRevisionsRequest))
          as FlushProxyRevisionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FlushProxyRevisionsRequest create() => FlushProxyRevisionsRequest._();
  @$core.override
  FlushProxyRevisionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FlushProxyRevisionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FlushProxyRevisionsRequest>(create);
  static FlushProxyRevisionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get keepCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set keepCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKeepCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearKeepCount() => $_clearField(2);
}

class FlushProxyRevisionsResponse extends $pb.GeneratedMessage {
  factory FlushProxyRevisionsResponse({
    $core.bool? success,
    $core.String? error,
    $core.int? deletedCount,
    $core.int? remainingCount,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (deletedCount != null) result.deletedCount = deletedCount;
    if (remainingCount != null) result.remainingCount = remainingCount;
    return result;
  }

  FlushProxyRevisionsResponse._();

  factory FlushProxyRevisionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FlushProxyRevisionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FlushProxyRevisionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aI(3, _omitFieldNames ? '' : 'deletedCount')
    ..aI(4, _omitFieldNames ? '' : 'remainingCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlushProxyRevisionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlushProxyRevisionsResponse copyWith(
          void Function(FlushProxyRevisionsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as FlushProxyRevisionsResponse))
          as FlushProxyRevisionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FlushProxyRevisionsResponse create() =>
      FlushProxyRevisionsResponse._();
  @$core.override
  FlushProxyRevisionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FlushProxyRevisionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FlushProxyRevisionsResponse>(create);
  static FlushProxyRevisionsResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.int get deletedCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set deletedCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeletedCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeletedCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get remainingCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set remainingCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRemainingCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearRemainingCount() => $_clearField(4);
}

class ListProxyConfigsRequest extends $pb.GeneratedMessage {
  factory ListProxyConfigsRequest() => create();

  ListProxyConfigsRequest._();

  factory ListProxyConfigsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListProxyConfigsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProxyConfigsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
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
    $fixnum.Int64? latestRevision,
    $core.int? totalSizeBytes,
    $3.Timestamp? updatedAt,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (latestRevision != null) result.latestRevision = latestRevision;
    if (totalSizeBytes != null) result.totalSizeBytes = totalSizeBytes;
    if (updatedAt != null) result.updatedAt = updatedAt;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aInt64(2, _omitFieldNames ? '' : 'latestRevision')
    ..aI(3, _omitFieldNames ? '' : 'totalSizeBytes')
    ..aOM<$3.Timestamp>(4, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $3.Timestamp.create)
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
  $fixnum.Int64 get latestRevision => $_getI64(1);
  @$pb.TagNumber(2)
  set latestRevision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLatestRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearLatestRevision() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalSizeBytes => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalSizeBytes($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalSizeBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalSizeBytes() => $_clearField(3);

  @$pb.TagNumber(4)
  $3.Timestamp get updatedAt => $_getN(3);
  @$pb.TagNumber(4)
  set updatedAt($3.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasUpdatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearUpdatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $3.Timestamp ensureUpdatedAt() => $_ensure(3);
}

class CreateProxyConfigRequest extends $pb.GeneratedMessage {
  factory CreateProxyConfigRequest({
    $core.String? proxyId,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
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

class DeleteProxyConfigRequest extends $pb.GeneratedMessage {
  factory DeleteProxyConfigRequest({
    $core.String? proxyId,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
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
}

class DeleteProxyConfigResponse extends $pb.GeneratedMessage {
  factory DeleteProxyConfigResponse({
    $core.bool? success,
    $core.String? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  DeleteProxyConfigResponse._();

  factory DeleteProxyConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteProxyConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteProxyConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteProxyConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteProxyConfigResponse copyWith(
          void Function(DeleteProxyConfigResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteProxyConfigResponse))
          as DeleteProxyConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteProxyConfigResponse create() => DeleteProxyConfigResponse._();
  @$core.override
  DeleteProxyConfigResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteProxyConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteProxyConfigResponse>(create);
  static DeleteProxyConfigResponse? _defaultInstance;

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

class ApplyProxyToNodeRequest extends $pb.GeneratedMessage {
  factory ApplyProxyToNodeRequest({
    $core.String? proxyId,
    $core.String? nodeId,
    $fixnum.Int64? revisionNum,
    $core.String? configYaml,
    $core.String? configHash,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (nodeId != null) result.nodeId = nodeId;
    if (revisionNum != null) result.revisionNum = revisionNum;
    if (configYaml != null) result.configYaml = configYaml;
    if (configHash != null) result.configHash = configHash;
    return result;
  }

  ApplyProxyToNodeRequest._();

  factory ApplyProxyToNodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApplyProxyToNodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApplyProxyToNodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'nodeId')
    ..aInt64(3, _omitFieldNames ? '' : 'revisionNum')
    ..aOS(4, _omitFieldNames ? '' : 'configYaml')
    ..aOS(5, _omitFieldNames ? '' : 'configHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyProxyToNodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyProxyToNodeRequest copyWith(
          void Function(ApplyProxyToNodeRequest) updates) =>
      super.copyWith((message) => updates(message as ApplyProxyToNodeRequest))
          as ApplyProxyToNodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApplyProxyToNodeRequest create() => ApplyProxyToNodeRequest._();
  @$core.override
  ApplyProxyToNodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApplyProxyToNodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApplyProxyToNodeRequest>(create);
  static ApplyProxyToNodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get revisionNum => $_getI64(2);
  @$pb.TagNumber(3)
  set revisionNum($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRevisionNum() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevisionNum() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get configYaml => $_getSZ(3);
  @$pb.TagNumber(4)
  set configYaml($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfigYaml() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfigYaml() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get configHash => $_getSZ(4);
  @$pb.TagNumber(5)
  set configHash($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConfigHash() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfigHash() => $_clearField(5);
}

class ApplyProxyToNodeResponse extends $pb.GeneratedMessage {
  factory ApplyProxyToNodeResponse({
    $core.bool? success,
    $core.String? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  ApplyProxyToNodeResponse._();

  factory ApplyProxyToNodeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApplyProxyToNodeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApplyProxyToNodeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyProxyToNodeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyProxyToNodeResponse copyWith(
          void Function(ApplyProxyToNodeResponse) updates) =>
      super.copyWith((message) => updates(message as ApplyProxyToNodeResponse))
          as ApplyProxyToNodeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApplyProxyToNodeResponse create() => ApplyProxyToNodeResponse._();
  @$core.override
  ApplyProxyToNodeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApplyProxyToNodeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApplyProxyToNodeResponse>(create);
  static ApplyProxyToNodeResponse? _defaultInstance;

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

class UnapplyProxyFromNodeRequest extends $pb.GeneratedMessage {
  factory UnapplyProxyFromNodeRequest({
    $core.String? proxyId,
    $core.String? nodeId,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (nodeId != null) result.nodeId = nodeId;
    return result;
  }

  UnapplyProxyFromNodeRequest._();

  factory UnapplyProxyFromNodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnapplyProxyFromNodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnapplyProxyFromNodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aOS(2, _omitFieldNames ? '' : 'nodeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnapplyProxyFromNodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnapplyProxyFromNodeRequest copyWith(
          void Function(UnapplyProxyFromNodeRequest) updates) =>
      super.copyWith(
              (message) => updates(message as UnapplyProxyFromNodeRequest))
          as UnapplyProxyFromNodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnapplyProxyFromNodeRequest create() =>
      UnapplyProxyFromNodeRequest._();
  @$core.override
  UnapplyProxyFromNodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnapplyProxyFromNodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnapplyProxyFromNodeRequest>(create);
  static UnapplyProxyFromNodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get proxyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set proxyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProxyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProxyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeId() => $_clearField(2);
}

class UnapplyProxyFromNodeResponse extends $pb.GeneratedMessage {
  factory UnapplyProxyFromNodeResponse({
    $core.bool? success,
    $core.String? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  UnapplyProxyFromNodeResponse._();

  factory UnapplyProxyFromNodeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnapplyProxyFromNodeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnapplyProxyFromNodeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnapplyProxyFromNodeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnapplyProxyFromNodeResponse copyWith(
          void Function(UnapplyProxyFromNodeResponse) updates) =>
      super.copyWith(
              (message) => updates(message as UnapplyProxyFromNodeResponse))
          as UnapplyProxyFromNodeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnapplyProxyFromNodeResponse create() =>
      UnapplyProxyFromNodeResponse._();
  @$core.override
  UnapplyProxyFromNodeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnapplyProxyFromNodeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnapplyProxyFromNodeResponse>(create);
  static UnapplyProxyFromNodeResponse? _defaultInstance;

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

class GetAppliedProxiesRequest extends $pb.GeneratedMessage {
  factory GetAppliedProxiesRequest({
    $core.String? nodeId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    return result;
  }

  GetAppliedProxiesRequest._();

  factory GetAppliedProxiesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAppliedProxiesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAppliedProxiesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAppliedProxiesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAppliedProxiesRequest copyWith(
          void Function(GetAppliedProxiesRequest) updates) =>
      super.copyWith((message) => updates(message as GetAppliedProxiesRequest))
          as GetAppliedProxiesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAppliedProxiesRequest create() => GetAppliedProxiesRequest._();
  @$core.override
  GetAppliedProxiesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAppliedProxiesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAppliedProxiesRequest>(create);
  static GetAppliedProxiesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);
}

class GetAppliedProxiesResponse extends $pb.GeneratedMessage {
  factory GetAppliedProxiesResponse({
    $core.Iterable<AppliedProxy>? proxies,
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<AppliedProxy>(1, _omitFieldNames ? '' : 'proxies',
        subBuilder: AppliedProxy.create)
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
  $pb.PbList<AppliedProxy> get proxies => $_getList(0);
}

class AppliedProxy extends $pb.GeneratedMessage {
  factory AppliedProxy({
    $core.String? proxyId,
    $fixnum.Int64? revisionNum,
    $core.String? appliedAt,
    $core.String? status,
  }) {
    final result = create();
    if (proxyId != null) result.proxyId = proxyId;
    if (revisionNum != null) result.revisionNum = revisionNum;
    if (appliedAt != null) result.appliedAt = appliedAt;
    if (status != null) result.status = status;
    return result;
  }

  AppliedProxy._();

  factory AppliedProxy.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AppliedProxy.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AppliedProxy',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'proxyId')
    ..aInt64(2, _omitFieldNames ? '' : 'revisionNum')
    ..aOS(3, _omitFieldNames ? '' : 'appliedAt')
    ..aOS(4, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AppliedProxy clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AppliedProxy copyWith(void Function(AppliedProxy) updates) =>
      super.copyWith((message) => updates(message as AppliedProxy))
          as AppliedProxy;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AppliedProxy create() => AppliedProxy._();
  @$core.override
  AppliedProxy createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AppliedProxy getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AppliedProxy>(create);
  static AppliedProxy? _defaultInstance;

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
}

class AllowIPRequest extends $pb.GeneratedMessage {
  factory AllowIPRequest({
    $core.String? nodeId,
    $core.String? proxyId,
    $core.String? ip,
    $core.bool? applyToAllNodes,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (proxyId != null) result.proxyId = proxyId;
    if (ip != null) result.ip = ip;
    if (applyToAllNodes != null) result.applyToAllNodes = applyToAllNodes;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'proxyId')
    ..aOS(3, _omitFieldNames ? '' : 'ip')
    ..aOB(4, _omitFieldNames ? '' : 'applyToAllNodes')
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

  @$pb.TagNumber(3)
  $core.String get ip => $_getSZ(2);
  @$pb.TagNumber(3)
  set ip($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIp() => $_has(2);
  @$pb.TagNumber(3)
  void clearIp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get applyToAllNodes => $_getBF(3);
  @$pb.TagNumber(4)
  set applyToAllNodes($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasApplyToAllNodes() => $_has(3);
  @$pb.TagNumber(4)
  void clearApplyToAllNodes() => $_clearField(4);
}

class AllowIPResponse extends $pb.GeneratedMessage {
  factory AllowIPResponse({
    $core.bool? success,
    $core.String? error,
    $core.int? rulesCreated,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (rulesCreated != null) result.rulesCreated = rulesCreated;
    return result;
  }

  AllowIPResponse._();

  factory AllowIPResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AllowIPResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AllowIPResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aI(3, _omitFieldNames ? '' : 'rulesCreated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllowIPResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllowIPResponse copyWith(void Function(AllowIPResponse) updates) =>
      super.copyWith((message) => updates(message as AllowIPResponse))
          as AllowIPResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AllowIPResponse create() => AllowIPResponse._();
  @$core.override
  AllowIPResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AllowIPResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AllowIPResponse>(create);
  static AllowIPResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.int get rulesCreated => $_getIZ(2);
  @$pb.TagNumber(3)
  set rulesCreated($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRulesCreated() => $_has(2);
  @$pb.TagNumber(3)
  void clearRulesCreated() => $_clearField(3);
}

class StreamMetricsRequest extends $pb.GeneratedMessage {
  factory StreamMetricsRequest({
    $core.String? nodeId,
    $core.int? intervalSeconds,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (intervalSeconds != null) result.intervalSeconds = intervalSeconds;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aI(2, _omitFieldNames ? '' : 'intervalSeconds')
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
  $core.int get intervalSeconds => $_getIZ(1);
  @$pb.TagNumber(2)
  set intervalSeconds($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIntervalSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearIntervalSeconds() => $_clearField(2);
}

class GetDebugRuntimeStatsRequest extends $pb.GeneratedMessage {
  factory GetDebugRuntimeStatsRequest() => create();

  GetDebugRuntimeStatsRequest._();

  factory GetDebugRuntimeStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDebugRuntimeStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDebugRuntimeStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDebugRuntimeStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDebugRuntimeStatsRequest copyWith(
          void Function(GetDebugRuntimeStatsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetDebugRuntimeStatsRequest))
          as GetDebugRuntimeStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDebugRuntimeStatsRequest create() =>
      GetDebugRuntimeStatsRequest._();
  @$core.override
  GetDebugRuntimeStatsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDebugRuntimeStatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDebugRuntimeStatsRequest>(create);
  static GetDebugRuntimeStatsRequest? _defaultInstance;
}

class DebugRuntimeStats extends $pb.GeneratedMessage {
  factory DebugRuntimeStats({
    $fixnum.Int64? rssBytes,
    $fixnum.Int64? goHeapAllocBytes,
    $fixnum.Int64? goHeapSysBytes,
    $fixnum.Int64? goSysBytes,
    $fixnum.Int64? goTotalAllocBytes,
    $fixnum.Int64? goGcCount,
    $fixnum.Int64? goGoroutines,
    $fixnum.Int64? goCgoCalls,
    $fixnum.Int64? goHeapObjects,
    $fixnum.Int64? goHeapInuseBytes,
    $fixnum.Int64? goStackInuseBytes,
    $fixnum.Int64? uptimeSeconds,
    $core.bool? hubConnected,
    $core.String? hubGrpcState,
    $core.int? totalNodes,
    $core.int? onlineNodes,
    $core.int? directGrpcConnections,
    $core.Iterable<DebugGrpcConnection>? grpcConnections,
    $core.int? approvalStreamSubscribers,
    $core.int? connectionStreamSubscribers,
    $core.int? p2pStreamSubscribers,
    $core.bool? goroutineDiffHasBaseline,
    $fixnum.Int64? goroutineDiffPrevTotal,
    $fixnum.Int64? goroutineDiffCurrTotal,
    $fixnum.Int64? goroutineDiffDelta,
    $core.Iterable<DebugGoroutineDiffEntry>? goroutineDiffEntries,
    $3.Timestamp? goroutineDiffPrevAt,
    $3.Timestamp? goroutineDiffCurrAt,
    $core.int? goroutineDiffTruncated,
  }) {
    final result = create();
    if (rssBytes != null) result.rssBytes = rssBytes;
    if (goHeapAllocBytes != null) result.goHeapAllocBytes = goHeapAllocBytes;
    if (goHeapSysBytes != null) result.goHeapSysBytes = goHeapSysBytes;
    if (goSysBytes != null) result.goSysBytes = goSysBytes;
    if (goTotalAllocBytes != null) result.goTotalAllocBytes = goTotalAllocBytes;
    if (goGcCount != null) result.goGcCount = goGcCount;
    if (goGoroutines != null) result.goGoroutines = goGoroutines;
    if (goCgoCalls != null) result.goCgoCalls = goCgoCalls;
    if (goHeapObjects != null) result.goHeapObjects = goHeapObjects;
    if (goHeapInuseBytes != null) result.goHeapInuseBytes = goHeapInuseBytes;
    if (goStackInuseBytes != null) result.goStackInuseBytes = goStackInuseBytes;
    if (uptimeSeconds != null) result.uptimeSeconds = uptimeSeconds;
    if (hubConnected != null) result.hubConnected = hubConnected;
    if (hubGrpcState != null) result.hubGrpcState = hubGrpcState;
    if (totalNodes != null) result.totalNodes = totalNodes;
    if (onlineNodes != null) result.onlineNodes = onlineNodes;
    if (directGrpcConnections != null)
      result.directGrpcConnections = directGrpcConnections;
    if (grpcConnections != null) result.grpcConnections.addAll(grpcConnections);
    if (approvalStreamSubscribers != null)
      result.approvalStreamSubscribers = approvalStreamSubscribers;
    if (connectionStreamSubscribers != null)
      result.connectionStreamSubscribers = connectionStreamSubscribers;
    if (p2pStreamSubscribers != null)
      result.p2pStreamSubscribers = p2pStreamSubscribers;
    if (goroutineDiffHasBaseline != null)
      result.goroutineDiffHasBaseline = goroutineDiffHasBaseline;
    if (goroutineDiffPrevTotal != null)
      result.goroutineDiffPrevTotal = goroutineDiffPrevTotal;
    if (goroutineDiffCurrTotal != null)
      result.goroutineDiffCurrTotal = goroutineDiffCurrTotal;
    if (goroutineDiffDelta != null)
      result.goroutineDiffDelta = goroutineDiffDelta;
    if (goroutineDiffEntries != null)
      result.goroutineDiffEntries.addAll(goroutineDiffEntries);
    if (goroutineDiffPrevAt != null)
      result.goroutineDiffPrevAt = goroutineDiffPrevAt;
    if (goroutineDiffCurrAt != null)
      result.goroutineDiffCurrAt = goroutineDiffCurrAt;
    if (goroutineDiffTruncated != null)
      result.goroutineDiffTruncated = goroutineDiffTruncated;
    return result;
  }

  DebugRuntimeStats._();

  factory DebugRuntimeStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DebugRuntimeStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DebugRuntimeStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'rssBytes')
    ..aInt64(2, _omitFieldNames ? '' : 'goHeapAllocBytes')
    ..aInt64(3, _omitFieldNames ? '' : 'goHeapSysBytes')
    ..aInt64(4, _omitFieldNames ? '' : 'goSysBytes')
    ..aInt64(5, _omitFieldNames ? '' : 'goTotalAllocBytes')
    ..aInt64(6, _omitFieldNames ? '' : 'goGcCount')
    ..aInt64(7, _omitFieldNames ? '' : 'goGoroutines')
    ..aInt64(8, _omitFieldNames ? '' : 'goCgoCalls')
    ..aInt64(9, _omitFieldNames ? '' : 'goHeapObjects')
    ..aInt64(10, _omitFieldNames ? '' : 'goHeapInuseBytes')
    ..aInt64(11, _omitFieldNames ? '' : 'goStackInuseBytes')
    ..aInt64(12, _omitFieldNames ? '' : 'uptimeSeconds')
    ..aOB(13, _omitFieldNames ? '' : 'hubConnected')
    ..aOS(14, _omitFieldNames ? '' : 'hubGrpcState')
    ..aI(15, _omitFieldNames ? '' : 'totalNodes')
    ..aI(16, _omitFieldNames ? '' : 'onlineNodes')
    ..aI(17, _omitFieldNames ? '' : 'directGrpcConnections')
    ..pPM<DebugGrpcConnection>(18, _omitFieldNames ? '' : 'grpcConnections',
        subBuilder: DebugGrpcConnection.create)
    ..aI(19, _omitFieldNames ? '' : 'approvalStreamSubscribers')
    ..aI(20, _omitFieldNames ? '' : 'connectionStreamSubscribers')
    ..aI(21, _omitFieldNames ? '' : 'p2pStreamSubscribers')
    ..aOB(22, _omitFieldNames ? '' : 'goroutineDiffHasBaseline')
    ..aInt64(23, _omitFieldNames ? '' : 'goroutineDiffPrevTotal')
    ..aInt64(24, _omitFieldNames ? '' : 'goroutineDiffCurrTotal')
    ..aInt64(25, _omitFieldNames ? '' : 'goroutineDiffDelta')
    ..pPM<DebugGoroutineDiffEntry>(
        26, _omitFieldNames ? '' : 'goroutineDiffEntries',
        subBuilder: DebugGoroutineDiffEntry.create)
    ..aOM<$3.Timestamp>(27, _omitFieldNames ? '' : 'goroutineDiffPrevAt',
        subBuilder: $3.Timestamp.create)
    ..aOM<$3.Timestamp>(28, _omitFieldNames ? '' : 'goroutineDiffCurrAt',
        subBuilder: $3.Timestamp.create)
    ..aI(29, _omitFieldNames ? '' : 'goroutineDiffTruncated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DebugRuntimeStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DebugRuntimeStats copyWith(void Function(DebugRuntimeStats) updates) =>
      super.copyWith((message) => updates(message as DebugRuntimeStats))
          as DebugRuntimeStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DebugRuntimeStats create() => DebugRuntimeStats._();
  @$core.override
  DebugRuntimeStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DebugRuntimeStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DebugRuntimeStats>(create);
  static DebugRuntimeStats? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get rssBytes => $_getI64(0);
  @$pb.TagNumber(1)
  set rssBytes($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRssBytes() => $_has(0);
  @$pb.TagNumber(1)
  void clearRssBytes() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get goHeapAllocBytes => $_getI64(1);
  @$pb.TagNumber(2)
  set goHeapAllocBytes($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGoHeapAllocBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearGoHeapAllocBytes() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get goHeapSysBytes => $_getI64(2);
  @$pb.TagNumber(3)
  set goHeapSysBytes($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGoHeapSysBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearGoHeapSysBytes() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get goSysBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set goSysBytes($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGoSysBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearGoSysBytes() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get goTotalAllocBytes => $_getI64(4);
  @$pb.TagNumber(5)
  set goTotalAllocBytes($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasGoTotalAllocBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearGoTotalAllocBytes() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get goGcCount => $_getI64(5);
  @$pb.TagNumber(6)
  set goGcCount($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasGoGcCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearGoGcCount() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get goGoroutines => $_getI64(6);
  @$pb.TagNumber(7)
  set goGoroutines($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasGoGoroutines() => $_has(6);
  @$pb.TagNumber(7)
  void clearGoGoroutines() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get goCgoCalls => $_getI64(7);
  @$pb.TagNumber(8)
  set goCgoCalls($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasGoCgoCalls() => $_has(7);
  @$pb.TagNumber(8)
  void clearGoCgoCalls() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get goHeapObjects => $_getI64(8);
  @$pb.TagNumber(9)
  set goHeapObjects($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasGoHeapObjects() => $_has(8);
  @$pb.TagNumber(9)
  void clearGoHeapObjects() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get goHeapInuseBytes => $_getI64(9);
  @$pb.TagNumber(10)
  set goHeapInuseBytes($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasGoHeapInuseBytes() => $_has(9);
  @$pb.TagNumber(10)
  void clearGoHeapInuseBytes() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get goStackInuseBytes => $_getI64(10);
  @$pb.TagNumber(11)
  set goStackInuseBytes($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasGoStackInuseBytes() => $_has(10);
  @$pb.TagNumber(11)
  void clearGoStackInuseBytes() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get uptimeSeconds => $_getI64(11);
  @$pb.TagNumber(12)
  set uptimeSeconds($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasUptimeSeconds() => $_has(11);
  @$pb.TagNumber(12)
  void clearUptimeSeconds() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get hubConnected => $_getBF(12);
  @$pb.TagNumber(13)
  set hubConnected($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasHubConnected() => $_has(12);
  @$pb.TagNumber(13)
  void clearHubConnected() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get hubGrpcState => $_getSZ(13);
  @$pb.TagNumber(14)
  set hubGrpcState($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasHubGrpcState() => $_has(13);
  @$pb.TagNumber(14)
  void clearHubGrpcState() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get totalNodes => $_getIZ(14);
  @$pb.TagNumber(15)
  set totalNodes($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasTotalNodes() => $_has(14);
  @$pb.TagNumber(15)
  void clearTotalNodes() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.int get onlineNodes => $_getIZ(15);
  @$pb.TagNumber(16)
  set onlineNodes($core.int value) => $_setSignedInt32(15, value);
  @$pb.TagNumber(16)
  $core.bool hasOnlineNodes() => $_has(15);
  @$pb.TagNumber(16)
  void clearOnlineNodes() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.int get directGrpcConnections => $_getIZ(16);
  @$pb.TagNumber(17)
  set directGrpcConnections($core.int value) => $_setSignedInt32(16, value);
  @$pb.TagNumber(17)
  $core.bool hasDirectGrpcConnections() => $_has(16);
  @$pb.TagNumber(17)
  void clearDirectGrpcConnections() => $_clearField(17);

  @$pb.TagNumber(18)
  $pb.PbList<DebugGrpcConnection> get grpcConnections => $_getList(17);

  @$pb.TagNumber(19)
  $core.int get approvalStreamSubscribers => $_getIZ(18);
  @$pb.TagNumber(19)
  set approvalStreamSubscribers($core.int value) => $_setSignedInt32(18, value);
  @$pb.TagNumber(19)
  $core.bool hasApprovalStreamSubscribers() => $_has(18);
  @$pb.TagNumber(19)
  void clearApprovalStreamSubscribers() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.int get connectionStreamSubscribers => $_getIZ(19);
  @$pb.TagNumber(20)
  set connectionStreamSubscribers($core.int value) =>
      $_setSignedInt32(19, value);
  @$pb.TagNumber(20)
  $core.bool hasConnectionStreamSubscribers() => $_has(19);
  @$pb.TagNumber(20)
  void clearConnectionStreamSubscribers() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.int get p2pStreamSubscribers => $_getIZ(20);
  @$pb.TagNumber(21)
  set p2pStreamSubscribers($core.int value) => $_setSignedInt32(20, value);
  @$pb.TagNumber(21)
  $core.bool hasP2pStreamSubscribers() => $_has(20);
  @$pb.TagNumber(21)
  void clearP2pStreamSubscribers() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.bool get goroutineDiffHasBaseline => $_getBF(21);
  @$pb.TagNumber(22)
  set goroutineDiffHasBaseline($core.bool value) => $_setBool(21, value);
  @$pb.TagNumber(22)
  $core.bool hasGoroutineDiffHasBaseline() => $_has(21);
  @$pb.TagNumber(22)
  void clearGoroutineDiffHasBaseline() => $_clearField(22);

  @$pb.TagNumber(23)
  $fixnum.Int64 get goroutineDiffPrevTotal => $_getI64(22);
  @$pb.TagNumber(23)
  set goroutineDiffPrevTotal($fixnum.Int64 value) => $_setInt64(22, value);
  @$pb.TagNumber(23)
  $core.bool hasGoroutineDiffPrevTotal() => $_has(22);
  @$pb.TagNumber(23)
  void clearGoroutineDiffPrevTotal() => $_clearField(23);

  @$pb.TagNumber(24)
  $fixnum.Int64 get goroutineDiffCurrTotal => $_getI64(23);
  @$pb.TagNumber(24)
  set goroutineDiffCurrTotal($fixnum.Int64 value) => $_setInt64(23, value);
  @$pb.TagNumber(24)
  $core.bool hasGoroutineDiffCurrTotal() => $_has(23);
  @$pb.TagNumber(24)
  void clearGoroutineDiffCurrTotal() => $_clearField(24);

  @$pb.TagNumber(25)
  $fixnum.Int64 get goroutineDiffDelta => $_getI64(24);
  @$pb.TagNumber(25)
  set goroutineDiffDelta($fixnum.Int64 value) => $_setInt64(24, value);
  @$pb.TagNumber(25)
  $core.bool hasGoroutineDiffDelta() => $_has(24);
  @$pb.TagNumber(25)
  void clearGoroutineDiffDelta() => $_clearField(25);

  @$pb.TagNumber(26)
  $pb.PbList<DebugGoroutineDiffEntry> get goroutineDiffEntries => $_getList(25);

  @$pb.TagNumber(27)
  $3.Timestamp get goroutineDiffPrevAt => $_getN(26);
  @$pb.TagNumber(27)
  set goroutineDiffPrevAt($3.Timestamp value) => $_setField(27, value);
  @$pb.TagNumber(27)
  $core.bool hasGoroutineDiffPrevAt() => $_has(26);
  @$pb.TagNumber(27)
  void clearGoroutineDiffPrevAt() => $_clearField(27);
  @$pb.TagNumber(27)
  $3.Timestamp ensureGoroutineDiffPrevAt() => $_ensure(26);

  @$pb.TagNumber(28)
  $3.Timestamp get goroutineDiffCurrAt => $_getN(27);
  @$pb.TagNumber(28)
  set goroutineDiffCurrAt($3.Timestamp value) => $_setField(28, value);
  @$pb.TagNumber(28)
  $core.bool hasGoroutineDiffCurrAt() => $_has(27);
  @$pb.TagNumber(28)
  void clearGoroutineDiffCurrAt() => $_clearField(28);
  @$pb.TagNumber(28)
  $3.Timestamp ensureGoroutineDiffCurrAt() => $_ensure(27);

  @$pb.TagNumber(29)
  $core.int get goroutineDiffTruncated => $_getIZ(28);
  @$pb.TagNumber(29)
  set goroutineDiffTruncated($core.int value) => $_setSignedInt32(28, value);
  @$pb.TagNumber(29)
  $core.bool hasGoroutineDiffTruncated() => $_has(28);
  @$pb.TagNumber(29)
  void clearGoroutineDiffTruncated() => $_clearField(29);
}

class DebugGrpcConnection extends $pb.GeneratedMessage {
  factory DebugGrpcConnection({
    $core.String? scope,
    $core.String? nodeId,
    $core.String? address,
    $core.String? state,
    $core.bool? connected,
  }) {
    final result = create();
    if (scope != null) result.scope = scope;
    if (nodeId != null) result.nodeId = nodeId;
    if (address != null) result.address = address;
    if (state != null) result.state = state;
    if (connected != null) result.connected = connected;
    return result;
  }

  DebugGrpcConnection._();

  factory DebugGrpcConnection.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DebugGrpcConnection.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DebugGrpcConnection',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'scope')
    ..aOS(2, _omitFieldNames ? '' : 'nodeId')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aOS(4, _omitFieldNames ? '' : 'state')
    ..aOB(5, _omitFieldNames ? '' : 'connected')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DebugGrpcConnection clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DebugGrpcConnection copyWith(void Function(DebugGrpcConnection) updates) =>
      super.copyWith((message) => updates(message as DebugGrpcConnection))
          as DebugGrpcConnection;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DebugGrpcConnection create() => DebugGrpcConnection._();
  @$core.override
  DebugGrpcConnection createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DebugGrpcConnection getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DebugGrpcConnection>(create);
  static DebugGrpcConnection? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get scope => $_getSZ(0);
  @$pb.TagNumber(1)
  set scope($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasScope() => $_has(0);
  @$pb.TagNumber(1)
  void clearScope() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get state => $_getSZ(3);
  @$pb.TagNumber(4)
  set state($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasState() => $_has(3);
  @$pb.TagNumber(4)
  void clearState() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get connected => $_getBF(4);
  @$pb.TagNumber(5)
  set connected($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConnected() => $_has(4);
  @$pb.TagNumber(5)
  void clearConnected() => $_clearField(5);
}

class DebugGoroutineDiffEntry extends $pb.GeneratedMessage {
  factory DebugGoroutineDiffEntry({
    $core.String? signature,
    $core.int? prevCount,
    $core.int? currCount,
    $core.int? delta,
  }) {
    final result = create();
    if (signature != null) result.signature = signature;
    if (prevCount != null) result.prevCount = prevCount;
    if (currCount != null) result.currCount = currCount;
    if (delta != null) result.delta = delta;
    return result;
  }

  DebugGoroutineDiffEntry._();

  factory DebugGoroutineDiffEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DebugGoroutineDiffEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DebugGoroutineDiffEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'signature')
    ..aI(2, _omitFieldNames ? '' : 'prevCount')
    ..aI(3, _omitFieldNames ? '' : 'currCount')
    ..aI(4, _omitFieldNames ? '' : 'delta')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DebugGoroutineDiffEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DebugGoroutineDiffEntry copyWith(
          void Function(DebugGoroutineDiffEntry) updates) =>
      super.copyWith((message) => updates(message as DebugGoroutineDiffEntry))
          as DebugGoroutineDiffEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DebugGoroutineDiffEntry create() => DebugGoroutineDiffEntry._();
  @$core.override
  DebugGoroutineDiffEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DebugGoroutineDiffEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DebugGoroutineDiffEntry>(create);
  static DebugGoroutineDiffEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get signature => $_getSZ(0);
  @$pb.TagNumber(1)
  set signature($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSignature() => $_has(0);
  @$pb.TagNumber(1)
  void clearSignature() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get prevCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set prevCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPrevCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrevCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get currCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set currCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCurrCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get delta => $_getIZ(3);
  @$pb.TagNumber(4)
  set delta($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDelta() => $_has(3);
  @$pb.TagNumber(4)
  void clearDelta() => $_clearField(4);
}

class GetLogsStatsRequest extends $pb.GeneratedMessage {
  factory GetLogsStatsRequest() => create();

  GetLogsStatsRequest._();

  factory GetLogsStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLogsStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLogsStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLogsStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLogsStatsRequest copyWith(void Function(GetLogsStatsRequest) updates) =>
      super.copyWith((message) => updates(message as GetLogsStatsRequest))
          as GetLogsStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLogsStatsRequest create() => GetLogsStatsRequest._();
  @$core.override
  GetLogsStatsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLogsStatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLogsStatsRequest>(create);
  static GetLogsStatsRequest? _defaultInstance;
}

class GetLogsStatsResponse extends $pb.GeneratedMessage {
  factory GetLogsStatsResponse({
    $fixnum.Int64? totalLogs,
    $fixnum.Int64? totalStorageBytes,
    $3.Timestamp? oldestLog,
    $3.Timestamp? newestLog,
    $core.Iterable<$core.MapEntry<$core.String, $fixnum.Int64>>?
        logsByRoutingToken,
    $core.Iterable<$core.MapEntry<$core.String, $fixnum.Int64>>?
        storageByRoutingToken,
  }) {
    final result = create();
    if (totalLogs != null) result.totalLogs = totalLogs;
    if (totalStorageBytes != null) result.totalStorageBytes = totalStorageBytes;
    if (oldestLog != null) result.oldestLog = oldestLog;
    if (newestLog != null) result.newestLog = newestLog;
    if (logsByRoutingToken != null)
      result.logsByRoutingToken.addEntries(logsByRoutingToken);
    if (storageByRoutingToken != null)
      result.storageByRoutingToken.addEntries(storageByRoutingToken);
    return result;
  }

  GetLogsStatsResponse._();

  factory GetLogsStatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLogsStatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLogsStatsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'totalLogs')
    ..aInt64(2, _omitFieldNames ? '' : 'totalStorageBytes')
    ..aOM<$3.Timestamp>(3, _omitFieldNames ? '' : 'oldestLog',
        subBuilder: $3.Timestamp.create)
    ..aOM<$3.Timestamp>(4, _omitFieldNames ? '' : 'newestLog',
        subBuilder: $3.Timestamp.create)
    ..m<$core.String, $fixnum.Int64>(
        5, _omitFieldNames ? '' : 'logsByRoutingToken',
        entryClassName: 'GetLogsStatsResponse.LogsByRoutingTokenEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O6,
        packageName: const $pb.PackageName('nitella.local'))
    ..m<$core.String, $fixnum.Int64>(
        6, _omitFieldNames ? '' : 'storageByRoutingToken',
        entryClassName: 'GetLogsStatsResponse.StorageByRoutingTokenEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O6,
        packageName: const $pb.PackageName('nitella.local'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLogsStatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLogsStatsResponse copyWith(void Function(GetLogsStatsResponse) updates) =>
      super.copyWith((message) => updates(message as GetLogsStatsResponse))
          as GetLogsStatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLogsStatsResponse create() => GetLogsStatsResponse._();
  @$core.override
  GetLogsStatsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLogsStatsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLogsStatsResponse>(create);
  static GetLogsStatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get totalLogs => $_getI64(0);
  @$pb.TagNumber(1)
  set totalLogs($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalLogs() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalLogs() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalStorageBytes => $_getI64(1);
  @$pb.TagNumber(2)
  set totalStorageBytes($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalStorageBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalStorageBytes() => $_clearField(2);

  @$pb.TagNumber(3)
  $3.Timestamp get oldestLog => $_getN(2);
  @$pb.TagNumber(3)
  set oldestLog($3.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOldestLog() => $_has(2);
  @$pb.TagNumber(3)
  void clearOldestLog() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.Timestamp ensureOldestLog() => $_ensure(2);

  @$pb.TagNumber(4)
  $3.Timestamp get newestLog => $_getN(3);
  @$pb.TagNumber(4)
  set newestLog($3.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasNewestLog() => $_has(3);
  @$pb.TagNumber(4)
  void clearNewestLog() => $_clearField(4);
  @$pb.TagNumber(4)
  $3.Timestamp ensureNewestLog() => $_ensure(3);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $fixnum.Int64> get logsByRoutingToken => $_getMap(4);

  @$pb.TagNumber(6)
  $pb.PbMap<$core.String, $fixnum.Int64> get storageByRoutingToken =>
      $_getMap(5);
}

class ListLogsRequest extends $pb.GeneratedMessage {
  factory ListLogsRequest({
    $core.String? routingToken,
    $core.String? nodeId,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (routingToken != null) result.routingToken = routingToken;
    if (nodeId != null) result.nodeId = nodeId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListLogsRequest._();

  factory ListLogsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListLogsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListLogsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'routingToken')
    ..aOS(2, _omitFieldNames ? '' : 'nodeId')
    ..aI(3, _omitFieldNames ? '' : 'pageSize')
    ..aOS(4, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLogsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLogsRequest copyWith(void Function(ListLogsRequest) updates) =>
      super.copyWith((message) => updates(message as ListLogsRequest))
          as ListLogsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListLogsRequest create() => ListLogsRequest._();
  @$core.override
  ListLogsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListLogsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListLogsRequest>(create);
  static ListLogsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get routingToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set routingToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoutingToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoutingToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageSize($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageSize() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get pageToken => $_getSZ(3);
  @$pb.TagNumber(4)
  set pageToken($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageToken() => $_clearField(4);
}

class ListLogsResponse extends $pb.GeneratedMessage {
  factory ListLogsResponse({
    $core.Iterable<LogEntry>? logs,
    $fixnum.Int64? totalCount,
    $core.String? nextPageToken,
  }) {
    final result = create();
    if (logs != null) result.logs.addAll(logs);
    if (totalCount != null) result.totalCount = totalCount;
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    return result;
  }

  ListLogsResponse._();

  factory ListLogsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListLogsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListLogsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..pPM<LogEntry>(1, _omitFieldNames ? '' : 'logs',
        subBuilder: LogEntry.create)
    ..aInt64(2, _omitFieldNames ? '' : 'totalCount')
    ..aOS(3, _omitFieldNames ? '' : 'nextPageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLogsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLogsResponse copyWith(void Function(ListLogsResponse) updates) =>
      super.copyWith((message) => updates(message as ListLogsResponse))
          as ListLogsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListLogsResponse create() => ListLogsResponse._();
  @$core.override
  ListLogsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListLogsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListLogsResponse>(create);
  static ListLogsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LogEntry> get logs => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalCount => $_getI64(1);
  @$pb.TagNumber(2)
  set totalCount($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get nextPageToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set nextPageToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNextPageToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearNextPageToken() => $_clearField(3);
}

class LogEntry extends $pb.GeneratedMessage {
  factory LogEntry({
    $fixnum.Int64? id,
    $core.String? nodeId,
    $core.String? routingToken,
    $3.Timestamp? timestamp,
    $core.int? encryptedSizeBytes,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (nodeId != null) result.nodeId = nodeId;
    if (routingToken != null) result.routingToken = routingToken;
    if (timestamp != null) result.timestamp = timestamp;
    if (encryptedSizeBytes != null)
      result.encryptedSizeBytes = encryptedSizeBytes;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'nodeId')
    ..aOS(3, _omitFieldNames ? '' : 'routingToken')
    ..aOM<$3.Timestamp>(4, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $3.Timestamp.create)
    ..aI(5, _omitFieldNames ? '' : 'encryptedSizeBytes')
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
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get routingToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set routingToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRoutingToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoutingToken() => $_clearField(3);

  @$pb.TagNumber(4)
  $3.Timestamp get timestamp => $_getN(3);
  @$pb.TagNumber(4)
  set timestamp($3.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
  @$pb.TagNumber(4)
  $3.Timestamp ensureTimestamp() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.int get encryptedSizeBytes => $_getIZ(4);
  @$pb.TagNumber(5)
  set encryptedSizeBytes($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEncryptedSizeBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearEncryptedSizeBytes() => $_clearField(5);
}

class DeleteLogsRequest extends $pb.GeneratedMessage {
  factory DeleteLogsRequest({
    $core.String? routingToken,
    $core.String? nodeId,
    $core.bool? deleteAll,
    $3.Timestamp? before,
  }) {
    final result = create();
    if (routingToken != null) result.routingToken = routingToken;
    if (nodeId != null) result.nodeId = nodeId;
    if (deleteAll != null) result.deleteAll = deleteAll;
    if (before != null) result.before = before;
    return result;
  }

  DeleteLogsRequest._();

  factory DeleteLogsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteLogsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteLogsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'routingToken')
    ..aOS(2, _omitFieldNames ? '' : 'nodeId')
    ..aOB(3, _omitFieldNames ? '' : 'deleteAll')
    ..aOM<$3.Timestamp>(4, _omitFieldNames ? '' : 'before',
        subBuilder: $3.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteLogsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteLogsRequest copyWith(void Function(DeleteLogsRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteLogsRequest))
          as DeleteLogsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteLogsRequest create() => DeleteLogsRequest._();
  @$core.override
  DeleteLogsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteLogsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteLogsRequest>(create);
  static DeleteLogsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get routingToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set routingToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoutingToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoutingToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get deleteAll => $_getBF(2);
  @$pb.TagNumber(3)
  set deleteAll($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeleteAll() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeleteAll() => $_clearField(3);

  @$pb.TagNumber(4)
  $3.Timestamp get before => $_getN(3);
  @$pb.TagNumber(4)
  set before($3.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasBefore() => $_has(3);
  @$pb.TagNumber(4)
  void clearBefore() => $_clearField(4);
  @$pb.TagNumber(4)
  $3.Timestamp ensureBefore() => $_ensure(3);
}

class DeleteLogsResponse extends $pb.GeneratedMessage {
  factory DeleteLogsResponse({
    $fixnum.Int64? deletedCount,
    $fixnum.Int64? freedBytes,
  }) {
    final result = create();
    if (deletedCount != null) result.deletedCount = deletedCount;
    if (freedBytes != null) result.freedBytes = freedBytes;
    return result;
  }

  DeleteLogsResponse._();

  factory DeleteLogsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteLogsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteLogsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'deletedCount')
    ..aInt64(2, _omitFieldNames ? '' : 'freedBytes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteLogsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteLogsResponse copyWith(void Function(DeleteLogsResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteLogsResponse))
          as DeleteLogsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteLogsResponse create() => DeleteLogsResponse._();
  @$core.override
  DeleteLogsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteLogsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteLogsResponse>(create);
  static DeleteLogsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get deletedCount => $_getI64(0);
  @$pb.TagNumber(1)
  set deletedCount($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeletedCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeletedCount() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get freedBytes => $_getI64(1);
  @$pb.TagNumber(2)
  set freedBytes($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFreedBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearFreedBytes() => $_clearField(2);
}

class CleanupOldLogsRequest extends $pb.GeneratedMessage {
  factory CleanupOldLogsRequest({
    $core.int? olderThanDays,
    $core.bool? dryRun,
  }) {
    final result = create();
    if (olderThanDays != null) result.olderThanDays = olderThanDays;
    if (dryRun != null) result.dryRun = dryRun;
    return result;
  }

  CleanupOldLogsRequest._();

  factory CleanupOldLogsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CleanupOldLogsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CleanupOldLogsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'olderThanDays')
    ..aOB(2, _omitFieldNames ? '' : 'dryRun')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CleanupOldLogsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CleanupOldLogsRequest copyWith(
          void Function(CleanupOldLogsRequest) updates) =>
      super.copyWith((message) => updates(message as CleanupOldLogsRequest))
          as CleanupOldLogsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CleanupOldLogsRequest create() => CleanupOldLogsRequest._();
  @$core.override
  CleanupOldLogsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CleanupOldLogsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CleanupOldLogsRequest>(create);
  static CleanupOldLogsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get olderThanDays => $_getIZ(0);
  @$pb.TagNumber(1)
  set olderThanDays($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOlderThanDays() => $_has(0);
  @$pb.TagNumber(1)
  void clearOlderThanDays() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get dryRun => $_getBF(1);
  @$pb.TagNumber(2)
  set dryRun($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDryRun() => $_has(1);
  @$pb.TagNumber(2)
  void clearDryRun() => $_clearField(2);
}

class CleanupOldLogsResponse extends $pb.GeneratedMessage {
  factory CleanupOldLogsResponse({
    $fixnum.Int64? deletedCount,
    $fixnum.Int64? freedBytes,
    $core.Iterable<$core.MapEntry<$core.String, $fixnum.Int64>>?
        deletedByRoutingToken,
  }) {
    final result = create();
    if (deletedCount != null) result.deletedCount = deletedCount;
    if (freedBytes != null) result.freedBytes = freedBytes;
    if (deletedByRoutingToken != null)
      result.deletedByRoutingToken.addEntries(deletedByRoutingToken);
    return result;
  }

  CleanupOldLogsResponse._();

  factory CleanupOldLogsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CleanupOldLogsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CleanupOldLogsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'deletedCount')
    ..aInt64(2, _omitFieldNames ? '' : 'freedBytes')
    ..m<$core.String, $fixnum.Int64>(
        3, _omitFieldNames ? '' : 'deletedByRoutingToken',
        entryClassName: 'CleanupOldLogsResponse.DeletedByRoutingTokenEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O6,
        packageName: const $pb.PackageName('nitella.local'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CleanupOldLogsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CleanupOldLogsResponse copyWith(
          void Function(CleanupOldLogsResponse) updates) =>
      super.copyWith((message) => updates(message as CleanupOldLogsResponse))
          as CleanupOldLogsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CleanupOldLogsResponse create() => CleanupOldLogsResponse._();
  @$core.override
  CleanupOldLogsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CleanupOldLogsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CleanupOldLogsResponse>(create);
  static CleanupOldLogsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get deletedCount => $_getI64(0);
  @$pb.TagNumber(1)
  set deletedCount($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeletedCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeletedCount() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get freedBytes => $_getI64(1);
  @$pb.TagNumber(2)
  set freedBytes($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFreedBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearFreedBytes() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $fixnum.Int64> get deletedByRoutingToken =>
      $_getMap(2);
}

class GetNodeFromHubRequest extends $pb.GeneratedMessage {
  factory GetNodeFromHubRequest({
    $core.String? nodeId,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    return result;
  }

  GetNodeFromHubRequest._();

  factory GetNodeFromHubRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNodeFromHubRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNodeFromHubRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNodeFromHubRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNodeFromHubRequest copyWith(
          void Function(GetNodeFromHubRequest) updates) =>
      super.copyWith((message) => updates(message as GetNodeFromHubRequest))
          as GetNodeFromHubRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNodeFromHubRequest create() => GetNodeFromHubRequest._();
  @$core.override
  GetNodeFromHubRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNodeFromHubRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNodeFromHubRequest>(create);
  static GetNodeFromHubRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);
}

class GetNodeFromHubResponse extends $pb.GeneratedMessage {
  factory GetNodeFromHubResponse({
    $core.String? nodeId,
    $core.String? status,
    $3.Timestamp? lastSeen,
    $core.String? publicIp,
    $core.String? version,
    $core.bool? geoipEnabled,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (status != null) result.status = status;
    if (lastSeen != null) result.lastSeen = lastSeen;
    if (publicIp != null) result.publicIp = publicIp;
    if (version != null) result.version = version;
    if (geoipEnabled != null) result.geoipEnabled = geoipEnabled;
    return result;
  }

  GetNodeFromHubResponse._();

  factory GetNodeFromHubResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNodeFromHubResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNodeFromHubResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aOM<$3.Timestamp>(3, _omitFieldNames ? '' : 'lastSeen',
        subBuilder: $3.Timestamp.create)
    ..aOS(4, _omitFieldNames ? '' : 'publicIp')
    ..aOS(5, _omitFieldNames ? '' : 'version')
    ..aOB(6, _omitFieldNames ? '' : 'geoipEnabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNodeFromHubResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNodeFromHubResponse copyWith(
          void Function(GetNodeFromHubResponse) updates) =>
      super.copyWith((message) => updates(message as GetNodeFromHubResponse))
          as GetNodeFromHubResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNodeFromHubResponse create() => GetNodeFromHubResponse._();
  @$core.override
  GetNodeFromHubResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNodeFromHubResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNodeFromHubResponse>(create);
  static GetNodeFromHubResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $3.Timestamp get lastSeen => $_getN(2);
  @$pb.TagNumber(3)
  set lastSeen($3.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasLastSeen() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastSeen() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.Timestamp ensureLastSeen() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get publicIp => $_getSZ(3);
  @$pb.TagNumber(4)
  set publicIp($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPublicIp() => $_has(3);
  @$pb.TagNumber(4)
  void clearPublicIp() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get version => $_getSZ(4);
  @$pb.TagNumber(5)
  set version($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get geoipEnabled => $_getBF(5);
  @$pb.TagNumber(6)
  set geoipEnabled($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasGeoipEnabled() => $_has(5);
  @$pb.TagNumber(6)
  void clearGeoipEnabled() => $_clearField(6);
}

class RegisterNodeWithHubRequest extends $pb.GeneratedMessage {
  factory RegisterNodeWithHubRequest({
    $core.String? nodeId,
    $core.String? certPem,
    $core.String? routingToken,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (certPem != null) result.certPem = certPem;
    if (routingToken != null) result.routingToken = routingToken;
    return result;
  }

  RegisterNodeWithHubRequest._();

  factory RegisterNodeWithHubRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterNodeWithHubRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterNodeWithHubRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'certPem')
    ..aOS(3, _omitFieldNames ? '' : 'routingToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterNodeWithHubRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterNodeWithHubRequest copyWith(
          void Function(RegisterNodeWithHubRequest) updates) =>
      super.copyWith(
              (message) => updates(message as RegisterNodeWithHubRequest))
          as RegisterNodeWithHubRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterNodeWithHubRequest create() => RegisterNodeWithHubRequest._();
  @$core.override
  RegisterNodeWithHubRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterNodeWithHubRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterNodeWithHubRequest>(create);
  static RegisterNodeWithHubRequest? _defaultInstance;

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
}

class RegisterNodeWithHubResponse extends $pb.GeneratedMessage {
  factory RegisterNodeWithHubResponse({
    $core.bool? success,
    $core.String? error,
    $core.String? routingToken,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    if (routingToken != null) result.routingToken = routingToken;
    return result;
  }

  RegisterNodeWithHubResponse._();

  factory RegisterNodeWithHubResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterNodeWithHubResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterNodeWithHubResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella.local'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aOS(3, _omitFieldNames ? '' : 'routingToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterNodeWithHubResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterNodeWithHubResponse copyWith(
          void Function(RegisterNodeWithHubResponse) updates) =>
      super.copyWith(
              (message) => updates(message as RegisterNodeWithHubResponse))
          as RegisterNodeWithHubResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterNodeWithHubResponse create() =>
      RegisterNodeWithHubResponse._();
  @$core.override
  RegisterNodeWithHubResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterNodeWithHubResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterNodeWithHubResponse>(create);
  static RegisterNodeWithHubResponse? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get routingToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set routingToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRoutingToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearRoutingToken() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
