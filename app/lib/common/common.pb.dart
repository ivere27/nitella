// This is a generated file - do not edit.
//
// Generated from common/common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'common.pbenum.dart';

/// EncryptedPayload wraps E2E encrypted data using X25519 ECDH + AES-256-GCM.
/// The sender generates an ephemeral X25519 keypair, derives a shared secret
/// with the recipient's public key using ECDH, then encrypts with AES-GCM.
class EncryptedPayload extends $pb.GeneratedMessage {
  factory EncryptedPayload({
    $core.List<$core.int>? ephemeralPubkey,
    $core.List<$core.int>? nonce,
    $core.List<$core.int>? ciphertext,
    $core.String? senderFingerprint,
    $core.List<$core.int>? signature,
    CryptoAlgorithm? algorithm,
  }) {
    final result = create();
    if (ephemeralPubkey != null) result.ephemeralPubkey = ephemeralPubkey;
    if (nonce != null) result.nonce = nonce;
    if (ciphertext != null) result.ciphertext = ciphertext;
    if (senderFingerprint != null) result.senderFingerprint = senderFingerprint;
    if (signature != null) result.signature = signature;
    if (algorithm != null) result.algorithm = algorithm;
    return result;
  }

  EncryptedPayload._();

  factory EncryptedPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EncryptedPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EncryptedPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'ephemeralPubkey', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'nonce', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'ciphertext', $pb.PbFieldType.OY)
    ..aOS(4, _omitFieldNames ? '' : 'senderFingerprint')
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..aE<CryptoAlgorithm>(6, _omitFieldNames ? '' : 'algorithm',
        enumValues: CryptoAlgorithm.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptedPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptedPayload copyWith(void Function(EncryptedPayload) updates) =>
      super.copyWith((message) => updates(message as EncryptedPayload))
          as EncryptedPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EncryptedPayload create() => EncryptedPayload._();
  @$core.override
  EncryptedPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EncryptedPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EncryptedPayload>(create);
  static EncryptedPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get ephemeralPubkey => $_getN(0);
  @$pb.TagNumber(1)
  set ephemeralPubkey($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEphemeralPubkey() => $_has(0);
  @$pb.TagNumber(1)
  void clearEphemeralPubkey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get nonce => $_getN(1);
  @$pb.TagNumber(2)
  set nonce($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNonce() => $_has(1);
  @$pb.TagNumber(2)
  void clearNonce() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get ciphertext => $_getN(2);
  @$pb.TagNumber(3)
  set ciphertext($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCiphertext() => $_has(2);
  @$pb.TagNumber(3)
  void clearCiphertext() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get senderFingerprint => $_getSZ(3);
  @$pb.TagNumber(4)
  set senderFingerprint($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSenderFingerprint() => $_has(3);
  @$pb.TagNumber(4)
  void clearSenderFingerprint() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get signature => $_getN(4);
  @$pb.TagNumber(5)
  set signature($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSignature() => $_has(4);
  @$pb.TagNumber(5)
  void clearSignature() => $_clearField(5);

  @$pb.TagNumber(6)
  CryptoAlgorithm get algorithm => $_getN(5);
  @$pb.TagNumber(6)
  set algorithm(CryptoAlgorithm value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasAlgorithm() => $_has(5);
  @$pb.TagNumber(6)
  void clearAlgorithm() => $_clearField(6);
}

/// SecureCommandPayload is the inner structure that gets encrypted.
/// It includes anti-replay fields that are only visible after decryption.
class SecureCommandPayload extends $pb.GeneratedMessage {
  factory SecureCommandPayload({
    $core.String? requestId,
    $fixnum.Int64? timestamp,
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (timestamp != null) result.timestamp = timestamp;
    if (data != null) result.data = data;
    return result;
  }

  SecureCommandPayload._();

  factory SecureCommandPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SecureCommandPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SecureCommandPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aInt64(2, _omitFieldNames ? '' : 'timestamp')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecureCommandPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SecureCommandPayload copyWith(void Function(SecureCommandPayload) updates) =>
      super.copyWith((message) => updates(message as SecureCommandPayload))
          as SecureCommandPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SecureCommandPayload create() => SecureCommandPayload._();
  @$core.override
  SecureCommandPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SecureCommandPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SecureCommandPayload>(create);
  static SecureCommandPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set timestamp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => $_clearField(3);
}

/// Alert (encrypted content for Zero-Trust)
class Alert extends $pb.GeneratedMessage {
  factory Alert({
    $core.String? id,
    $core.String? nodeId,
    $core.String? severity,
    $fixnum.Int64? timestampUnix,
    $core.bool? acknowledged,
    EncryptedPayload? encrypted,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (nodeId != null) result.nodeId = nodeId;
    if (severity != null) result.severity = severity;
    if (timestampUnix != null) result.timestampUnix = timestampUnix;
    if (acknowledged != null) result.acknowledged = acknowledged;
    if (encrypted != null) result.encrypted = encrypted;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'nodeId')
    ..aOS(3, _omitFieldNames ? '' : 'severity')
    ..aInt64(4, _omitFieldNames ? '' : 'timestampUnix')
    ..aOB(5, _omitFieldNames ? '' : 'acknowledged')
    ..aOM<EncryptedPayload>(6, _omitFieldNames ? '' : 'encrypted',
        subBuilder: EncryptedPayload.create)
    ..m<$core.String, $core.String>(7, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'Alert.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('nitella'))
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

  /// Plaintext fields for Hub routing only
  @$pb.TagNumber(3)
  $core.String get severity => $_getSZ(2);
  @$pb.TagNumber(3)
  set severity($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSeverity() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeverity() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestampUnix => $_getI64(3);
  @$pb.TagNumber(4)
  set timestampUnix($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestampUnix() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestampUnix() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get acknowledged => $_getBF(4);
  @$pb.TagNumber(5)
  set acknowledged($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAcknowledged() => $_has(4);
  @$pb.TagNumber(5)
  void clearAcknowledged() => $_clearField(5);

  /// Encrypted content (title, description) - only Mobile can decrypt
  @$pb.TagNumber(6)
  EncryptedPayload get encrypted => $_getN(5);
  @$pb.TagNumber(6)
  set encrypted(EncryptedPayload value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasEncrypted() => $_has(5);
  @$pb.TagNumber(6)
  void clearEncrypted() => $_clearField(6);
  @$pb.TagNumber(6)
  EncryptedPayload ensureEncrypted() => $_ensure(5);

  @$pb.TagNumber(7)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(6);
}

/// AlertDetails contains encrypted alert information for approval requests.
/// This replaces JSON-encoded alert info for type safety.
class AlertDetails extends $pb.GeneratedMessage {
  factory AlertDetails({
    $core.String? sourceIp,
    $core.String? destination,
    $core.String? proxyId,
    $core.String? proxyName,
    $core.String? ruleId,
    $core.String? geoCountry,
    $core.String? geoCity,
    $core.String? geoIsp,
  }) {
    final result = create();
    if (sourceIp != null) result.sourceIp = sourceIp;
    if (destination != null) result.destination = destination;
    if (proxyId != null) result.proxyId = proxyId;
    if (proxyName != null) result.proxyName = proxyName;
    if (ruleId != null) result.ruleId = ruleId;
    if (geoCountry != null) result.geoCountry = geoCountry;
    if (geoCity != null) result.geoCity = geoCity;
    if (geoIsp != null) result.geoIsp = geoIsp;
    return result;
  }

  AlertDetails._();

  factory AlertDetails.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AlertDetails.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AlertDetails',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sourceIp')
    ..aOS(2, _omitFieldNames ? '' : 'destination')
    ..aOS(3, _omitFieldNames ? '' : 'proxyId')
    ..aOS(4, _omitFieldNames ? '' : 'proxyName')
    ..aOS(5, _omitFieldNames ? '' : 'ruleId')
    ..aOS(6, _omitFieldNames ? '' : 'geoCountry')
    ..aOS(7, _omitFieldNames ? '' : 'geoCity')
    ..aOS(8, _omitFieldNames ? '' : 'geoIsp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlertDetails clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlertDetails copyWith(void Function(AlertDetails) updates) =>
      super.copyWith((message) => updates(message as AlertDetails))
          as AlertDetails;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlertDetails create() => AlertDetails._();
  @$core.override
  AlertDetails createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AlertDetails getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AlertDetails>(create);
  static AlertDetails? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sourceIp => $_getSZ(0);
  @$pb.TagNumber(1)
  set sourceIp($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSourceIp() => $_has(0);
  @$pb.TagNumber(1)
  void clearSourceIp() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get destination => $_getSZ(1);
  @$pb.TagNumber(2)
  set destination($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDestination() => $_has(1);
  @$pb.TagNumber(2)
  void clearDestination() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get proxyId => $_getSZ(2);
  @$pb.TagNumber(3)
  set proxyId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProxyId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProxyId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get proxyName => $_getSZ(3);
  @$pb.TagNumber(4)
  set proxyName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProxyName() => $_has(3);
  @$pb.TagNumber(4)
  void clearProxyName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get ruleId => $_getSZ(4);
  @$pb.TagNumber(5)
  set ruleId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRuleId() => $_has(4);
  @$pb.TagNumber(5)
  void clearRuleId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get geoCountry => $_getSZ(5);
  @$pb.TagNumber(6)
  set geoCountry($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasGeoCountry() => $_has(5);
  @$pb.TagNumber(6)
  void clearGeoCountry() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get geoCity => $_getSZ(6);
  @$pb.TagNumber(7)
  set geoCity($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasGeoCity() => $_has(6);
  @$pb.TagNumber(7)
  void clearGeoCity() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get geoIsp => $_getSZ(7);
  @$pb.TagNumber(8)
  set geoIsp($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasGeoIsp() => $_has(7);
  @$pb.TagNumber(8)
  void clearGeoIsp() => $_clearField(8);
}

/// GeoInfo contains geographical information for an IP address.
class GeoInfo extends $pb.GeneratedMessage {
  factory GeoInfo({
    $core.String? country,
    $core.String? city,
    $core.String? isp,
    $core.String? countryCode,
    $core.String? region,
    $core.String? regionName,
    $core.String? zip,
    $core.double? latitude,
    $core.double? longitude,
    $core.String? timezone,
    $core.String? org,
    $core.String? as,
    $core.String? source,
    $fixnum.Int64? latencyMs,
  }) {
    final result = create();
    if (country != null) result.country = country;
    if (city != null) result.city = city;
    if (isp != null) result.isp = isp;
    if (countryCode != null) result.countryCode = countryCode;
    if (region != null) result.region = region;
    if (regionName != null) result.regionName = regionName;
    if (zip != null) result.zip = zip;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (timezone != null) result.timezone = timezone;
    if (org != null) result.org = org;
    if (as != null) result.as = as;
    if (source != null) result.source = source;
    if (latencyMs != null) result.latencyMs = latencyMs;
    return result;
  }

  GeoInfo._();

  factory GeoInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GeoInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GeoInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nitella'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'country')
    ..aOS(2, _omitFieldNames ? '' : 'city')
    ..aOS(3, _omitFieldNames ? '' : 'isp')
    ..aOS(4, _omitFieldNames ? '' : 'countryCode')
    ..aOS(5, _omitFieldNames ? '' : 'region')
    ..aOS(6, _omitFieldNames ? '' : 'regionName')
    ..aOS(7, _omitFieldNames ? '' : 'zip')
    ..aD(8, _omitFieldNames ? '' : 'latitude')
    ..aD(9, _omitFieldNames ? '' : 'longitude')
    ..aOS(10, _omitFieldNames ? '' : 'timezone')
    ..aOS(11, _omitFieldNames ? '' : 'org')
    ..aOS(12, _omitFieldNames ? '' : 'as')
    ..aOS(13, _omitFieldNames ? '' : 'source')
    ..aInt64(14, _omitFieldNames ? '' : 'latencyMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeoInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeoInfo copyWith(void Function(GeoInfo) updates) =>
      super.copyWith((message) => updates(message as GeoInfo)) as GeoInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GeoInfo create() => GeoInfo._();
  @$core.override
  GeoInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GeoInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GeoInfo>(create);
  static GeoInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get country => $_getSZ(0);
  @$pb.TagNumber(1)
  set country($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCountry() => $_has(0);
  @$pb.TagNumber(1)
  void clearCountry() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get city => $_getSZ(1);
  @$pb.TagNumber(2)
  set city($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCity() => $_has(1);
  @$pb.TagNumber(2)
  void clearCity() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get isp => $_getSZ(2);
  @$pb.TagNumber(3)
  set isp($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsp() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsp() => $_clearField(3);

  /// Extended fields
  @$pb.TagNumber(4)
  $core.String get countryCode => $_getSZ(3);
  @$pb.TagNumber(4)
  set countryCode($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCountryCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearCountryCode() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get region => $_getSZ(4);
  @$pb.TagNumber(5)
  set region($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRegion() => $_has(4);
  @$pb.TagNumber(5)
  void clearRegion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get regionName => $_getSZ(5);
  @$pb.TagNumber(6)
  set regionName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRegionName() => $_has(5);
  @$pb.TagNumber(6)
  void clearRegionName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get zip => $_getSZ(6);
  @$pb.TagNumber(7)
  set zip($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasZip() => $_has(6);
  @$pb.TagNumber(7)
  void clearZip() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get latitude => $_getN(7);
  @$pb.TagNumber(8)
  set latitude($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLatitude() => $_has(7);
  @$pb.TagNumber(8)
  void clearLatitude() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get longitude => $_getN(8);
  @$pb.TagNumber(9)
  set longitude($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLongitude() => $_has(8);
  @$pb.TagNumber(9)
  void clearLongitude() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get timezone => $_getSZ(9);
  @$pb.TagNumber(10)
  set timezone($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasTimezone() => $_has(9);
  @$pb.TagNumber(10)
  void clearTimezone() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get org => $_getSZ(10);
  @$pb.TagNumber(11)
  set org($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasOrg() => $_has(10);
  @$pb.TagNumber(11)
  void clearOrg() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get as => $_getSZ(11);
  @$pb.TagNumber(12)
  set as($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasAs() => $_has(11);
  @$pb.TagNumber(12)
  void clearAs() => $_clearField(12);

  /// Metadata
  @$pb.TagNumber(13)
  $core.String get source => $_getSZ(12);
  @$pb.TagNumber(13)
  set source($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasSource() => $_has(12);
  @$pb.TagNumber(13)
  void clearSource() => $_clearField(13);

  @$pb.TagNumber(14)
  $fixnum.Int64 get latencyMs => $_getI64(13);
  @$pb.TagNumber(14)
  set latencyMs($fixnum.Int64 value) => $_setInt64(13, value);
  @$pb.TagNumber(14)
  $core.bool hasLatencyMs() => $_has(13);
  @$pb.TagNumber(14)
  void clearLatencyMs() => $_clearField(14);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
