// This is a generated file - do not edit.
//
// Generated from common/common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use actionTypeDescriptor instead')
const ActionType$json = {
  '1': 'ActionType',
  '2': [
    {'1': 'ACTION_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'ACTION_TYPE_ALLOW', '2': 1},
    {'1': 'ACTION_TYPE_BLOCK', '2': 2},
    {'1': 'ACTION_TYPE_MOCK', '2': 3},
    {'1': 'ACTION_TYPE_REQUIRE_APPROVAL', '2': 4},
  ],
};

/// Descriptor for `ActionType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List actionTypeDescriptor = $convert.base64Decode(
    'CgpBY3Rpb25UeXBlEhsKF0FDVElPTl9UWVBFX1VOU1BFQ0lGSUVEEAASFQoRQUNUSU9OX1RZUE'
    'VfQUxMT1cQARIVChFBQ1RJT05fVFlQRV9CTE9DSxACEhQKEEFDVElPTl9UWVBFX01PQ0sQAxIg'
    'ChxBQ1RJT05fVFlQRV9SRVFVSVJFX0FQUFJPVkFMEAQ=');

@$core.Deprecated('Use fallbackActionDescriptor instead')
const FallbackAction$json = {
  '1': 'FallbackAction',
  '2': [
    {'1': 'FALLBACK_ACTION_UNSPECIFIED', '2': 0},
    {'1': 'FALLBACK_ACTION_CLOSE', '2': 1},
    {'1': 'FALLBACK_ACTION_MOCK', '2': 2},
  ],
};

/// Descriptor for `FallbackAction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List fallbackActionDescriptor = $convert.base64Decode(
    'Cg5GYWxsYmFja0FjdGlvbhIfChtGQUxMQkFDS19BQ1RJT05fVU5TUEVDSUZJRUQQABIZChVGQU'
    'xMQkFDS19BQ1RJT05fQ0xPU0UQARIYChRGQUxMQkFDS19BQ1RJT05fTU9DSxAC');

@$core.Deprecated('Use mockPresetDescriptor instead')
const MockPreset$json = {
  '1': 'MockPreset',
  '2': [
    {'1': 'MOCK_PRESET_UNSPECIFIED', '2': 0},
    {'1': 'MOCK_PRESET_SSH_SECURE', '2': 1},
    {'1': 'MOCK_PRESET_SSH_TARPIT', '2': 2},
    {'1': 'MOCK_PRESET_HTTP_403', '2': 3},
    {'1': 'MOCK_PRESET_HTTP_404', '2': 4},
    {'1': 'MOCK_PRESET_HTTP_401', '2': 5},
    {'1': 'MOCK_PRESET_REDIS_SECURE', '2': 6},
    {'1': 'MOCK_PRESET_MYSQL_SECURE', '2': 7},
    {'1': 'MOCK_PRESET_MYSQL_TARPIT', '2': 8},
    {'1': 'MOCK_PRESET_RDP_SECURE', '2': 9},
    {'1': 'MOCK_PRESET_TELNET_SECURE', '2': 10},
    {'1': 'MOCK_PRESET_RAW_TARPIT', '2': 11},
  ],
};

/// Descriptor for `MockPreset`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List mockPresetDescriptor = $convert.base64Decode(
    'CgpNb2NrUHJlc2V0EhsKF01PQ0tfUFJFU0VUX1VOU1BFQ0lGSUVEEAASGgoWTU9DS19QUkVTRV'
    'RfU1NIX1NFQ1VSRRABEhoKFk1PQ0tfUFJFU0VUX1NTSF9UQVJQSVQQAhIYChRNT0NLX1BSRVNF'
    'VF9IVFRQXzQwMxADEhgKFE1PQ0tfUFJFU0VUX0hUVFBfNDA0EAQSGAoUTU9DS19QUkVTRVRfSF'
    'RUUF80MDEQBRIcChhNT0NLX1BSRVNFVF9SRURJU19TRUNVUkUQBhIcChhNT0NLX1BSRVNFVF9N'
    'WVNRTF9TRUNVUkUQBxIcChhNT0NLX1BSRVNFVF9NWVNRTF9UQVJQSVQQCBIaChZNT0NLX1BSRV'
    'NFVF9SRFBfU0VDVVJFEAkSHQoZTU9DS19QUkVTRVRfVEVMTkVUX1NFQ1VSRRAKEhoKFk1PQ0tf'
    'UFJFU0VUX1JBV19UQVJQSVQQCw==');

@$core.Deprecated('Use conditionTypeDescriptor instead')
const ConditionType$json = {
  '1': 'ConditionType',
  '2': [
    {'1': 'CONDITION_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'CONDITION_TYPE_SOURCE_IP', '2': 1},
    {'1': 'CONDITION_TYPE_GEO_COUNTRY', '2': 2},
    {'1': 'CONDITION_TYPE_GEO_CITY', '2': 3},
    {'1': 'CONDITION_TYPE_GEO_ISP', '2': 4},
    {'1': 'CONDITION_TYPE_TIME_RANGE', '2': 5},
    {'1': 'CONDITION_TYPE_TLS_FINGERPRINT', '2': 6},
    {'1': 'CONDITION_TYPE_TLS_CN', '2': 7},
    {'1': 'CONDITION_TYPE_TLS_SERIAL', '2': 8},
    {'1': 'CONDITION_TYPE_TLS_PRESENT', '2': 9},
    {'1': 'CONDITION_TYPE_TLS_CA', '2': 10},
    {'1': 'CONDITION_TYPE_TLS_SAN', '2': 11},
    {'1': 'CONDITION_TYPE_TLS_OU', '2': 12},
  ],
};

/// Descriptor for `ConditionType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List conditionTypeDescriptor = $convert.base64Decode(
    'Cg1Db25kaXRpb25UeXBlEh4KGkNPTkRJVElPTl9UWVBFX1VOU1BFQ0lGSUVEEAASHAoYQ09ORE'
    'lUSU9OX1RZUEVfU09VUkNFX0lQEAESHgoaQ09ORElUSU9OX1RZUEVfR0VPX0NPVU5UUlkQAhIb'
    'ChdDT05ESVRJT05fVFlQRV9HRU9fQ0lUWRADEhoKFkNPTkRJVElPTl9UWVBFX0dFT19JU1AQBB'
    'IdChlDT05ESVRJT05fVFlQRV9USU1FX1JBTkdFEAUSIgoeQ09ORElUSU9OX1RZUEVfVExTX0ZJ'
    'TkdFUlBSSU5UEAYSGQoVQ09ORElUSU9OX1RZUEVfVExTX0NOEAcSHQoZQ09ORElUSU9OX1RZUE'
    'VfVExTX1NFUklBTBAIEh4KGkNPTkRJVElPTl9UWVBFX1RMU19QUkVTRU5UEAkSGQoVQ09ORElU'
    'SU9OX1RZUEVfVExTX0NBEAoSGgoWQ09ORElUSU9OX1RZUEVfVExTX1NBThALEhkKFUNPTkRJVE'
    'lPTl9UWVBFX1RMU19PVRAM');

@$core.Deprecated('Use operatorDescriptor instead')
const Operator$json = {
  '1': 'Operator',
  '2': [
    {'1': 'OPERATOR_UNSPECIFIED', '2': 0},
    {'1': 'OPERATOR_EQ', '2': 1},
    {'1': 'OPERATOR_CONTAINS', '2': 2},
    {'1': 'OPERATOR_REGEX', '2': 3},
    {'1': 'OPERATOR_CIDR', '2': 4},
  ],
};

/// Descriptor for `Operator`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List operatorDescriptor = $convert.base64Decode(
    'CghPcGVyYXRvchIYChRPUEVSQVRPUl9VTlNQRUNJRklFRBAAEg8KC09QRVJBVE9SX0VREAESFQ'
    'oRT1BFUkFUT1JfQ09OVEFJTlMQAhISCg5PUEVSQVRPUl9SRUdFWBADEhEKDU9QRVJBVE9SX0NJ'
    'RFIQBA==');

@$core.Deprecated('Use sortOrderDescriptor instead')
const SortOrder$json = {
  '1': 'SortOrder',
  '2': [
    {'1': 'SORT_LAST_SEEN_DESC', '2': 0},
    {'1': 'SORT_LAST_SEEN_ASC', '2': 1},
    {'1': 'SORT_CONNECTION_COUNT_DESC', '2': 2},
    {'1': 'SORT_BYTES_TOTAL_DESC', '2': 3},
    {'1': 'SORT_RECENCY_WEIGHT_DESC', '2': 4},
  ],
};

/// Descriptor for `SortOrder`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sortOrderDescriptor = $convert.base64Decode(
    'CglTb3J0T3JkZXISFwoTU09SVF9MQVNUX1NFRU5fREVTQxAAEhYKElNPUlRfTEFTVF9TRUVOX0'
    'FTQxABEh4KGlNPUlRfQ09OTkVDVElPTl9DT1VOVF9ERVNDEAISGQoVU09SVF9CWVRFU19UT1RB'
    'TF9ERVNDEAMSHAoYU09SVF9SRUNFTkNZX1dFSUdIVF9ERVNDEAQ=');

@$core.Deprecated('Use pemLabelDescriptor instead')
const PemLabel$json = {
  '1': 'PemLabel',
  '2': [
    {'1': 'PEM_LABEL_UNSPECIFIED', '2': 0},
    {'1': 'PEM_LABEL_CERTIFICATE', '2': 1},
    {'1': 'PEM_LABEL_PUBLIC_KEY', '2': 2},
    {'1': 'PEM_LABEL_PRIVATE_KEY', '2': 3},
    {'1': 'PEM_LABEL_ENCRYPTED_PRIVATE_KEY', '2': 4},
  ],
};

/// Descriptor for `PemLabel`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List pemLabelDescriptor = $convert.base64Decode(
    'CghQZW1MYWJlbBIZChVQRU1fTEFCRUxfVU5TUEVDSUZJRUQQABIZChVQRU1fTEFCRUxfQ0VSVE'
    'lGSUNBVEUQARIYChRQRU1fTEFCRUxfUFVCTElDX0tFWRACEhkKFVBFTV9MQUJFTF9QUklWQVRF'
    'X0tFWRADEiMKH1BFTV9MQUJFTF9FTkNSWVBURURfUFJJVkFURV9LRVkQBA==');

@$core.Deprecated('Use approvalActionTypeDescriptor instead')
const ApprovalActionType$json = {
  '1': 'ApprovalActionType',
  '2': [
    {'1': 'APPROVAL_ACTION_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'APPROVAL_ACTION_TYPE_ALLOW', '2': 1},
    {'1': 'APPROVAL_ACTION_TYPE_BLOCK', '2': 2},
    {'1': 'APPROVAL_ACTION_TYPE_BLOCK_ADD_RULE', '2': 3},
  ],
};

/// Descriptor for `ApprovalActionType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List approvalActionTypeDescriptor = $convert.base64Decode(
    'ChJBcHByb3ZhbEFjdGlvblR5cGUSJAogQVBQUk9WQUxfQUNUSU9OX1RZUEVfVU5TUEVDSUZJRU'
    'QQABIeChpBUFBST1ZBTF9BQ1RJT05fVFlQRV9BTExPVxABEh4KGkFQUFJPVkFMX0FDVElPTl9U'
    'WVBFX0JMT0NLEAISJwojQVBQUk9WQUxfQUNUSU9OX1RZUEVfQkxPQ0tfQUREX1JVTEUQAw==');

@$core.Deprecated('Use approvalRetentionModeDescriptor instead')
const ApprovalRetentionMode$json = {
  '1': 'ApprovalRetentionMode',
  '2': [
    {'1': 'APPROVAL_RETENTION_MODE_UNSPECIFIED', '2': 0},
    {'1': 'APPROVAL_RETENTION_MODE_CACHE', '2': 1},
    {'1': 'APPROVAL_RETENTION_MODE_CONNECTION_ONLY', '2': 2},
  ],
};

/// Descriptor for `ApprovalRetentionMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List approvalRetentionModeDescriptor = $convert.base64Decode(
    'ChVBcHByb3ZhbFJldGVudGlvbk1vZGUSJwojQVBQUk9WQUxfUkVURU5USU9OX01PREVfVU5TUE'
    'VDSUZJRUQQABIhCh1BUFBST1ZBTF9SRVRFTlRJT05fTU9ERV9DQUNIRRABEisKJ0FQUFJPVkFM'
    'X1JFVEVOVElPTl9NT0RFX0NPTk5FQ1RJT05fT05MWRAC');

@$core.Deprecated('Use p2PModeDescriptor instead')
const P2PMode$json = {
  '1': 'P2PMode',
  '2': [
    {'1': 'P2P_MODE_UNSPECIFIED', '2': 0},
    {'1': 'P2P_MODE_AUTO', '2': 1},
    {'1': 'P2P_MODE_DIRECT', '2': 2},
    {'1': 'P2P_MODE_HUB', '2': 3},
  ],
};

/// Descriptor for `P2PMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List p2PModeDescriptor = $convert.base64Decode(
    'CgdQMlBNb2RlEhgKFFAyUF9NT0RFX1VOU1BFQ0lGSUVEEAASEQoNUDJQX01PREVfQVVUTxABEh'
    'MKD1AyUF9NT0RFX0RJUkVDVBACEhAKDFAyUF9NT0RFX0hVQhAD');

@$core.Deprecated('Use cryptoAlgorithmDescriptor instead')
const CryptoAlgorithm$json = {
  '1': 'CryptoAlgorithm',
  '2': [
    {'1': 'ALGO_UNKNOWN', '2': 0},
    {'1': 'ALGO_ED25519', '2': 1},
  ],
};

/// Descriptor for `CryptoAlgorithm`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List cryptoAlgorithmDescriptor = $convert.base64Decode(
    'Cg9DcnlwdG9BbGdvcml0aG0SEAoMQUxHT19VTktOT1dOEAASEAoMQUxHT19FRDI1NTE5EAE=');

@$core.Deprecated('Use encryptedPayloadDescriptor instead')
const EncryptedPayload$json = {
  '1': 'EncryptedPayload',
  '2': [
    {'1': 'ephemeral_pubkey', '3': 1, '4': 1, '5': 12, '10': 'ephemeralPubkey'},
    {'1': 'nonce', '3': 2, '4': 1, '5': 12, '10': 'nonce'},
    {'1': 'ciphertext', '3': 3, '4': 1, '5': 12, '10': 'ciphertext'},
    {
      '1': 'sender_fingerprint',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'senderFingerprint'
    },
    {'1': 'signature', '3': 5, '4': 1, '5': 12, '10': 'signature'},
    {
      '1': 'algorithm',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.nitella.CryptoAlgorithm',
      '10': 'algorithm'
    },
  ],
};

/// Descriptor for `EncryptedPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encryptedPayloadDescriptor = $convert.base64Decode(
    'ChBFbmNyeXB0ZWRQYXlsb2FkEikKEGVwaGVtZXJhbF9wdWJrZXkYASABKAxSD2VwaGVtZXJhbF'
    'B1YmtleRIUCgVub25jZRgCIAEoDFIFbm9uY2USHgoKY2lwaGVydGV4dBgDIAEoDFIKY2lwaGVy'
    'dGV4dBItChJzZW5kZXJfZmluZ2VycHJpbnQYBCABKAlSEXNlbmRlckZpbmdlcnByaW50EhwKCX'
    'NpZ25hdHVyZRgFIAEoDFIJc2lnbmF0dXJlEjYKCWFsZ29yaXRobRgGIAEoDjIYLm5pdGVsbGEu'
    'Q3J5cHRvQWxnb3JpdGhtUglhbGdvcml0aG0=');

@$core.Deprecated('Use secureCommandPayloadDescriptor instead')
const SecureCommandPayload$json = {
  '1': 'SecureCommandPayload',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'data', '3': 3, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `SecureCommandPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secureCommandPayloadDescriptor = $convert.base64Decode(
    'ChRTZWN1cmVDb21tYW5kUGF5bG9hZBIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZXF1ZXN0SWQSHA'
    'oJdGltZXN0YW1wGAIgASgDUgl0aW1lc3RhbXASEgoEZGF0YRgDIAEoDFIEZGF0YQ==');

@$core.Deprecated('Use alertDescriptor instead')
const Alert$json = {
  '1': 'Alert',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'severity', '3': 3, '4': 1, '5': 9, '10': 'severity'},
    {'1': 'timestamp_unix', '3': 4, '4': 1, '5': 3, '10': 'timestampUnix'},
    {'1': 'acknowledged', '3': 5, '4': 1, '5': 8, '10': 'acknowledged'},
    {
      '1': 'encrypted',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.nitella.EncryptedPayload',
      '10': 'encrypted'
    },
    {
      '1': 'metadata',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.nitella.Alert.MetadataEntry',
      '10': 'metadata'
    },
  ],
  '3': [Alert_MetadataEntry$json],
};

@$core.Deprecated('Use alertDescriptor instead')
const Alert_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Alert`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List alertDescriptor = $convert.base64Decode(
    'CgVBbGVydBIOCgJpZBgBIAEoCVICaWQSFwoHbm9kZV9pZBgCIAEoCVIGbm9kZUlkEhoKCHNldm'
    'VyaXR5GAMgASgJUghzZXZlcml0eRIlCg50aW1lc3RhbXBfdW5peBgEIAEoA1INdGltZXN0YW1w'
    'VW5peBIiCgxhY2tub3dsZWRnZWQYBSABKAhSDGFja25vd2xlZGdlZBI3CgllbmNyeXB0ZWQYBi'
    'ABKAsyGS5uaXRlbGxhLkVuY3J5cHRlZFBheWxvYWRSCWVuY3J5cHRlZBI4CghtZXRhZGF0YRgH'
    'IAMoCzIcLm5pdGVsbGEuQWxlcnQuTWV0YWRhdGFFbnRyeVIIbWV0YWRhdGEaOwoNTWV0YWRhdG'
    'FFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use alertDetailsDescriptor instead')
const AlertDetails$json = {
  '1': 'AlertDetails',
  '2': [
    {'1': 'source_ip', '3': 1, '4': 1, '5': 9, '10': 'sourceIp'},
    {'1': 'destination', '3': 2, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'proxy_id', '3': 3, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'proxy_name', '3': 4, '4': 1, '5': 9, '10': 'proxyName'},
    {'1': 'rule_id', '3': 5, '4': 1, '5': 9, '10': 'ruleId'},
    {'1': 'geo_country', '3': 6, '4': 1, '5': 9, '10': 'geoCountry'},
    {'1': 'geo_city', '3': 7, '4': 1, '5': 9, '10': 'geoCity'},
    {'1': 'geo_isp', '3': 8, '4': 1, '5': 9, '10': 'geoIsp'},
  ],
};

/// Descriptor for `AlertDetails`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List alertDetailsDescriptor = $convert.base64Decode(
    'CgxBbGVydERldGFpbHMSGwoJc291cmNlX2lwGAEgASgJUghzb3VyY2VJcBIgCgtkZXN0aW5hdG'
    'lvbhgCIAEoCVILZGVzdGluYXRpb24SGQoIcHJveHlfaWQYAyABKAlSB3Byb3h5SWQSHQoKcHJv'
    'eHlfbmFtZRgEIAEoCVIJcHJveHlOYW1lEhcKB3J1bGVfaWQYBSABKAlSBnJ1bGVJZBIfCgtnZW'
    '9fY291bnRyeRgGIAEoCVIKZ2VvQ291bnRyeRIZCghnZW9fY2l0eRgHIAEoCVIHZ2VvQ2l0eRIX'
    'CgdnZW9faXNwGAggASgJUgZnZW9Jc3A=');

@$core.Deprecated('Use geoInfoDescriptor instead')
const GeoInfo$json = {
  '1': 'GeoInfo',
  '2': [
    {'1': 'country', '3': 1, '4': 1, '5': 9, '10': 'country'},
    {'1': 'city', '3': 2, '4': 1, '5': 9, '10': 'city'},
    {'1': 'isp', '3': 3, '4': 1, '5': 9, '10': 'isp'},
    {'1': 'country_code', '3': 4, '4': 1, '5': 9, '10': 'countryCode'},
    {'1': 'region', '3': 5, '4': 1, '5': 9, '10': 'region'},
    {'1': 'region_name', '3': 6, '4': 1, '5': 9, '10': 'regionName'},
    {'1': 'zip', '3': 7, '4': 1, '5': 9, '10': 'zip'},
    {'1': 'latitude', '3': 8, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 9, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'timezone', '3': 10, '4': 1, '5': 9, '10': 'timezone'},
    {'1': 'org', '3': 11, '4': 1, '5': 9, '10': 'org'},
    {'1': 'as', '3': 12, '4': 1, '5': 9, '10': 'as'},
    {'1': 'source', '3': 13, '4': 1, '5': 9, '10': 'source'},
    {'1': 'latency_ms', '3': 14, '4': 1, '5': 3, '10': 'latencyMs'},
  ],
};

/// Descriptor for `GeoInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List geoInfoDescriptor = $convert.base64Decode(
    'CgdHZW9JbmZvEhgKB2NvdW50cnkYASABKAlSB2NvdW50cnkSEgoEY2l0eRgCIAEoCVIEY2l0eR'
    'IQCgNpc3AYAyABKAlSA2lzcBIhCgxjb3VudHJ5X2NvZGUYBCABKAlSC2NvdW50cnlDb2RlEhYK'
    'BnJlZ2lvbhgFIAEoCVIGcmVnaW9uEh8KC3JlZ2lvbl9uYW1lGAYgASgJUgpyZWdpb25OYW1lEh'
    'AKA3ppcBgHIAEoCVIDemlwEhoKCGxhdGl0dWRlGAggASgBUghsYXRpdHVkZRIcCglsb25naXR1'
    'ZGUYCSABKAFSCWxvbmdpdHVkZRIaCgh0aW1lem9uZRgKIAEoCVIIdGltZXpvbmUSEAoDb3JnGA'
    'sgASgJUgNvcmcSDgoCYXMYDCABKAlSAmFzEhYKBnNvdXJjZRgNIAEoCVIGc291cmNlEh0KCmxh'
    'dGVuY3lfbXMYDiABKANSCWxhdGVuY3lNcw==');
