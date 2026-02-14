// This is a generated file - do not edit.
//
// Generated from local/nitella_local.proto.

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

@$core.Deprecated('Use geoStatsTypeDescriptor instead')
const GeoStatsType$json = {
  '1': 'GeoStatsType',
  '2': [
    {'1': 'GEO_STATS_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'GEO_STATS_TYPE_COUNTRY', '2': 1},
    {'1': 'GEO_STATS_TYPE_CITY', '2': 2},
    {'1': 'GEO_STATS_TYPE_ISP', '2': 3},
  ],
};

/// Descriptor for `GeoStatsType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List geoStatsTypeDescriptor = $convert.base64Decode(
    'CgxHZW9TdGF0c1R5cGUSHgoaR0VPX1NUQVRTX1RZUEVfVU5TUEVDSUZJRUQQABIaChZHRU9fU1'
    'RBVFNfVFlQRV9DT1VOVFJZEAESFwoTR0VPX1NUQVRTX1RZUEVfQ0lUWRACEhYKEkdFT19TVEFU'
    'U19UWVBFX0lTUBAD');

@$core.Deprecated('Use themeDescriptor instead')
const Theme$json = {
  '1': 'Theme',
  '2': [
    {'1': 'THEME_UNSPECIFIED', '2': 0},
    {'1': 'THEME_LIGHT', '2': 1},
    {'1': 'THEME_DARK', '2': 2},
    {'1': 'THEME_SYSTEM', '2': 3},
  ],
};

/// Descriptor for `Theme`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List themeDescriptor = $convert.base64Decode(
    'CgVUaGVtZRIVChFUSEVNRV9VTlNQRUNJRklFRBAAEg8KC1RIRU1FX0xJR0hUEAESDgoKVEhFTU'
    'VfREFSSxACEhAKDFRIRU1FX1NZU1RFTRAD');

@$core.Deprecated('Use alertSeverityDescriptor instead')
const AlertSeverity$json = {
  '1': 'AlertSeverity',
  '2': [
    {'1': 'ALERT_SEVERITY_UNSPECIFIED', '2': 0},
    {'1': 'ALERT_SEVERITY_INFO', '2': 1},
    {'1': 'ALERT_SEVERITY_WARNING', '2': 2},
    {'1': 'ALERT_SEVERITY_CRITICAL', '2': 3},
  ],
};

/// Descriptor for `AlertSeverity`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List alertSeverityDescriptor = $convert.base64Decode(
    'Cg1BbGVydFNldmVyaXR5Eh4KGkFMRVJUX1NFVkVSSVRZX1VOU1BFQ0lGSUVEEAASFwoTQUxFUl'
    'RfU0VWRVJJVFlfSU5GTxABEhoKFkFMRVJUX1NFVkVSSVRZX1dBUk5JTkcQAhIbChdBTEVSVF9T'
    'RVZFUklUWV9DUklUSUNBTBAD');

@$core.Deprecated('Use toastTypeDescriptor instead')
const ToastType$json = {
  '1': 'ToastType',
  '2': [
    {'1': 'TOAST_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'TOAST_TYPE_INFO', '2': 1},
    {'1': 'TOAST_TYPE_SUCCESS', '2': 2},
    {'1': 'TOAST_TYPE_WARNING', '2': 3},
    {'1': 'TOAST_TYPE_ERROR', '2': 4},
  ],
};

/// Descriptor for `ToastType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List toastTypeDescriptor = $convert.base64Decode(
    'CglUb2FzdFR5cGUSGgoWVE9BU1RfVFlQRV9VTlNQRUNJRklFRBAAEhMKD1RPQVNUX1RZUEVfSU'
    '5GTxABEhYKElRPQVNUX1RZUEVfU1VDQ0VTUxACEhYKElRPQVNUX1RZUEVfV0FSTklORxADEhQK'
    'EFRPQVNUX1RZUEVfRVJST1IQBA==');

@$core.Deprecated('Use deviceTypeDescriptor instead')
const DeviceType$json = {
  '1': 'DeviceType',
  '2': [
    {'1': 'DEVICE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'DEVICE_TYPE_ANDROID', '2': 1},
    {'1': 'DEVICE_TYPE_IOS', '2': 2},
  ],
};

/// Descriptor for `DeviceType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List deviceTypeDescriptor = $convert.base64Decode(
    'CgpEZXZpY2VUeXBlEhsKF0RFVklDRV9UWVBFX1VOU1BFQ0lGSUVEEAASFwoTREVWSUNFX1RZUE'
    'VfQU5EUk9JRBABEhMKD0RFVklDRV9UWVBFX0lPUxAC');

@$core.Deprecated('Use bootstrapStageDescriptor instead')
const BootstrapStage$json = {
  '1': 'BootstrapStage',
  '2': [
    {'1': 'BOOTSTRAP_STAGE_UNSPECIFIED', '2': 0},
    {'1': 'BOOTSTRAP_STAGE_SETUP_NEEDED', '2': 1},
    {'1': 'BOOTSTRAP_STAGE_AUTH_NEEDED', '2': 2},
    {'1': 'BOOTSTRAP_STAGE_READY', '2': 3},
  ],
};

/// Descriptor for `BootstrapStage`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List bootstrapStageDescriptor = $convert.base64Decode(
    'Cg5Cb290c3RyYXBTdGFnZRIfChtCT09UU1RSQVBfU1RBR0VfVU5TUEVDSUZJRUQQABIgChxCT0'
    '9UU1RSQVBfU1RBR0VfU0VUVVBfTkVFREVEEAESHwobQk9PVFNUUkFQX1NUQUdFX0FVVEhfTkVF'
    'REVEEAISGQoVQk9PVFNUUkFQX1NUQUdFX1JFQURZEAM=');

@$core.Deprecated('Use passphraseStrengthDescriptor instead')
const PassphraseStrength$json = {
  '1': 'PassphraseStrength',
  '2': [
    {'1': 'PASSPHRASE_STRENGTH_UNSPECIFIED', '2': 0},
    {'1': 'PASSPHRASE_STRENGTH_WEAK', '2': 1},
    {'1': 'PASSPHRASE_STRENGTH_FAIR', '2': 2},
    {'1': 'PASSPHRASE_STRENGTH_STRONG', '2': 3},
  ],
};

/// Descriptor for `PassphraseStrength`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List passphraseStrengthDescriptor = $convert.base64Decode(
    'ChJQYXNzcGhyYXNlU3RyZW5ndGgSIwofUEFTU1BIUkFTRV9TVFJFTkdUSF9VTlNQRUNJRklFRB'
    'AAEhwKGFBBU1NQSFJBU0VfU1RSRU5HVEhfV0VBSxABEhwKGFBBU1NQSFJBU0VfU1RSRU5HVEhf'
    'RkFJUhACEh4KGlBBU1NQSFJBU0VfU1RSRU5HVEhfU1RST05HEAM=');

@$core.Deprecated('Use nodeConnectionTypeDescriptor instead')
const NodeConnectionType$json = {
  '1': 'NodeConnectionType',
  '2': [
    {'1': 'NODE_CONNECTION_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'NODE_CONNECTION_TYPE_HUB', '2': 1},
    {'1': 'NODE_CONNECTION_TYPE_DIRECT', '2': 2},
  ],
};

/// Descriptor for `NodeConnectionType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List nodeConnectionTypeDescriptor = $convert.base64Decode(
    'ChJOb2RlQ29ubmVjdGlvblR5cGUSJAogTk9ERV9DT05ORUNUSU9OX1RZUEVfVU5TUEVDSUZJRU'
    'QQABIcChhOT0RFX0NPTk5FQ1RJT05fVFlQRV9IVUIQARIfChtOT0RFX0NPTk5FQ1RJT05fVFlQ'
    'RV9ESVJFQ1QQAg==');

@$core.Deprecated('Use denyBlockTypeDescriptor instead')
const DenyBlockType$json = {
  '1': 'DenyBlockType',
  '2': [
    {'1': 'DENY_BLOCK_TYPE_NONE', '2': 0},
    {'1': 'DENY_BLOCK_TYPE_IP', '2': 1},
    {'1': 'DENY_BLOCK_TYPE_ISP', '2': 2},
  ],
};

/// Descriptor for `DenyBlockType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List denyBlockTypeDescriptor = $convert.base64Decode(
    'Cg1EZW55QmxvY2tUeXBlEhgKFERFTllfQkxPQ0tfVFlQRV9OT05FEAASFgoSREVOWV9CTE9DS1'
    '9UWVBFX0lQEAESFwoTREVOWV9CTE9DS19UWVBFX0lTUBAC');

@$core.Deprecated('Use approvalDecisionDescriptor instead')
const ApprovalDecision$json = {
  '1': 'ApprovalDecision',
  '2': [
    {'1': 'APPROVAL_DECISION_UNSPECIFIED', '2': 0},
    {'1': 'APPROVAL_DECISION_APPROVE', '2': 1},
    {'1': 'APPROVAL_DECISION_DENY', '2': 2},
  ],
};

/// Descriptor for `ApprovalDecision`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List approvalDecisionDescriptor = $convert.base64Decode(
    'ChBBcHByb3ZhbERlY2lzaW9uEiEKHUFQUFJPVkFMX0RFQ0lTSU9OX1VOU1BFQ0lGSUVEEAASHQ'
    'oZQVBQUk9WQUxfREVDSVNJT05fQVBQUk9WRRABEhoKFkFQUFJPVkFMX0RFQ0lTSU9OX0RFTlkQ'
    'Ag==');

@$core.Deprecated('Use approvalHistoryActionDescriptor instead')
const ApprovalHistoryAction$json = {
  '1': 'ApprovalHistoryAction',
  '2': [
    {'1': 'APPROVAL_HISTORY_ACTION_UNSPECIFIED', '2': 0},
    {'1': 'APPROVAL_HISTORY_ACTION_APPROVED', '2': 1},
    {'1': 'APPROVAL_HISTORY_ACTION_DENIED', '2': 2},
    {'1': 'APPROVAL_HISTORY_ACTION_EXPIRED', '2': 3},
  ],
};

/// Descriptor for `ApprovalHistoryAction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List approvalHistoryActionDescriptor = $convert.base64Decode(
    'ChVBcHByb3ZhbEhpc3RvcnlBY3Rpb24SJwojQVBQUk9WQUxfSElTVE9SWV9BQ1RJT05fVU5TUE'
    'VDSUZJRUQQABIkCiBBUFBST1ZBTF9ISVNUT1JZX0FDVElPTl9BUFBST1ZFRBABEiIKHkFQUFJP'
    'VkFMX0hJU1RPUllfQUNUSU9OX0RFTklFRBACEiMKH0FQUFJPVkFMX0hJU1RPUllfQUNUSU9OX0'
    'VYUElSRUQQAw==');

@$core.Deprecated('Use initializeRequestDescriptor instead')
const InitializeRequest$json = {
  '1': 'InitializeRequest',
  '2': [
    {'1': 'data_dir', '3': 1, '4': 1, '5': 9, '10': 'dataDir'},
    {'1': 'cache_dir', '3': 2, '4': 1, '5': 9, '10': 'cacheDir'},
    {'1': 'hub_address', '3': 3, '4': 1, '5': 9, '10': 'hubAddress'},
    {'1': 'debug_mode', '3': 4, '4': 1, '5': 8, '10': 'debugMode'},
  ],
};

/// Descriptor for `InitializeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List initializeRequestDescriptor = $convert.base64Decode(
    'ChFJbml0aWFsaXplUmVxdWVzdBIZCghkYXRhX2RpchgBIAEoCVIHZGF0YURpchIbCgljYWNoZV'
    '9kaXIYAiABKAlSCGNhY2hlRGlyEh8KC2h1Yl9hZGRyZXNzGAMgASgJUgpodWJBZGRyZXNzEh0K'
    'CmRlYnVnX21vZGUYBCABKAhSCWRlYnVnTW9kZQ==');

@$core.Deprecated('Use initializeResponseDescriptor instead')
const InitializeResponse$json = {
  '1': 'InitializeResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'identity_exists', '3': 3, '4': 1, '5': 8, '10': 'identityExists'},
    {'1': 'identity_locked', '3': 4, '4': 1, '5': 8, '10': 'identityLocked'},
  ],
};

/// Descriptor for `InitializeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List initializeResponseDescriptor = $convert.base64Decode(
    'ChJJbml0aWFsaXplUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIUCgVlcnJvch'
    'gCIAEoCVIFZXJyb3ISJwoPaWRlbnRpdHlfZXhpc3RzGAMgASgIUg5pZGVudGl0eUV4aXN0cxIn'
    'Cg9pZGVudGl0eV9sb2NrZWQYBCABKAhSDmlkZW50aXR5TG9ja2Vk');

@$core.Deprecated('Use bootstrapStateResponseDescriptor instead')
const BootstrapStateResponse$json = {
  '1': 'BootstrapStateResponse',
  '2': [
    {
      '1': 'stage',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.BootstrapStage',
      '10': 'stage'
    },
    {'1': 'identity_exists', '3': 2, '4': 1, '5': 8, '10': 'identityExists'},
    {'1': 'identity_locked', '3': 3, '4': 1, '5': 8, '10': 'identityLocked'},
    {
      '1': 'require_biometric',
      '3': 4,
      '4': 1,
      '5': 8,
      '10': 'requireBiometric'
    },
  ],
};

/// Descriptor for `BootstrapStateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bootstrapStateResponseDescriptor = $convert.base64Decode(
    'ChZCb290c3RyYXBTdGF0ZVJlc3BvbnNlEjMKBXN0YWdlGAEgASgOMh0ubml0ZWxsYS5sb2NhbC'
    '5Cb290c3RyYXBTdGFnZVIFc3RhZ2USJwoPaWRlbnRpdHlfZXhpc3RzGAIgASgIUg5pZGVudGl0'
    'eUV4aXN0cxInCg9pZGVudGl0eV9sb2NrZWQYAyABKAhSDmlkZW50aXR5TG9ja2VkEisKEXJlcX'
    'VpcmVfYmlvbWV0cmljGAQgASgIUhByZXF1aXJlQmlvbWV0cmlj');

@$core.Deprecated('Use identityInfoDescriptor instead')
const IdentityInfo$json = {
  '1': 'IdentityInfo',
  '2': [
    {'1': 'exists', '3': 1, '4': 1, '5': 8, '10': 'exists'},
    {'1': 'locked', '3': 2, '4': 1, '5': 8, '10': 'locked'},
    {'1': 'fingerprint', '3': 3, '4': 1, '5': 9, '10': 'fingerprint'},
    {'1': 'emoji_hash', '3': 4, '4': 1, '5': 9, '10': 'emojiHash'},
    {'1': 'root_cert_pem', '3': 5, '4': 1, '5': 9, '10': 'rootCertPem'},
    {
      '1': 'created_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {'1': 'paired_nodes', '3': 7, '4': 1, '5': 5, '10': 'pairedNodes'},
  ],
};

/// Descriptor for `IdentityInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List identityInfoDescriptor = $convert.base64Decode(
    'CgxJZGVudGl0eUluZm8SFgoGZXhpc3RzGAEgASgIUgZleGlzdHMSFgoGbG9ja2VkGAIgASgIUg'
    'Zsb2NrZWQSIAoLZmluZ2VycHJpbnQYAyABKAlSC2ZpbmdlcnByaW50Eh0KCmVtb2ppX2hhc2gY'
    'BCABKAlSCWVtb2ppSGFzaBIiCg1yb290X2NlcnRfcGVtGAUgASgJUgtyb290Q2VydFBlbRI5Cg'
    'pjcmVhdGVkX2F0GAYgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0'
    'EiEKDHBhaXJlZF9ub2RlcxgHIAEoBVILcGFpcmVkTm9kZXM=');

@$core.Deprecated('Use createIdentityRequestDescriptor instead')
const CreateIdentityRequest$json = {
  '1': 'CreateIdentityRequest',
  '2': [
    {'1': 'passphrase', '3': 1, '4': 1, '5': 9, '10': 'passphrase'},
    {'1': 'common_name', '3': 2, '4': 1, '5': 9, '10': 'commonName'},
    {'1': 'organization', '3': 3, '4': 1, '5': 9, '10': 'organization'},
    {
      '1': 'allow_weak_passphrase',
      '3': 4,
      '4': 1,
      '5': 8,
      '10': 'allowWeakPassphrase'
    },
  ],
};

/// Descriptor for `CreateIdentityRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createIdentityRequestDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVJZGVudGl0eVJlcXVlc3QSHgoKcGFzc3BocmFzZRgBIAEoCVIKcGFzc3BocmFzZR'
    'IfCgtjb21tb25fbmFtZRgCIAEoCVIKY29tbW9uTmFtZRIiCgxvcmdhbml6YXRpb24YAyABKAlS'
    'DG9yZ2FuaXphdGlvbhIyChVhbGxvd193ZWFrX3Bhc3NwaHJhc2UYBCABKAhSE2FsbG93V2Vha1'
    'Bhc3NwaHJhc2U=');

@$core.Deprecated('Use createIdentityResponseDescriptor instead')
const CreateIdentityResponse$json = {
  '1': 'CreateIdentityResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'mnemonic', '3': 3, '4': 1, '5': 9, '10': 'mnemonic'},
    {
      '1': 'identity',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.IdentityInfo',
      '10': 'identity'
    },
  ],
};

/// Descriptor for `CreateIdentityResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createIdentityResponseDescriptor = $convert.base64Decode(
    'ChZDcmVhdGVJZGVudGl0eVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSFAoFZX'
    'Jyb3IYAiABKAlSBWVycm9yEhoKCG1uZW1vbmljGAMgASgJUghtbmVtb25pYxI3CghpZGVudGl0'
    'eRgEIAEoCzIbLm5pdGVsbGEubG9jYWwuSWRlbnRpdHlJbmZvUghpZGVudGl0eQ==');

@$core.Deprecated('Use restoreIdentityRequestDescriptor instead')
const RestoreIdentityRequest$json = {
  '1': 'RestoreIdentityRequest',
  '2': [
    {'1': 'mnemonic', '3': 1, '4': 1, '5': 9, '10': 'mnemonic'},
    {'1': 'passphrase', '3': 2, '4': 1, '5': 9, '10': 'passphrase'},
    {'1': 'common_name', '3': 3, '4': 1, '5': 9, '10': 'commonName'},
    {'1': 'organization', '3': 4, '4': 1, '5': 9, '10': 'organization'},
    {
      '1': 'allow_weak_passphrase',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'allowWeakPassphrase'
    },
  ],
};

/// Descriptor for `RestoreIdentityRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List restoreIdentityRequestDescriptor = $convert.base64Decode(
    'ChZSZXN0b3JlSWRlbnRpdHlSZXF1ZXN0EhoKCG1uZW1vbmljGAEgASgJUghtbmVtb25pYxIeCg'
    'pwYXNzcGhyYXNlGAIgASgJUgpwYXNzcGhyYXNlEh8KC2NvbW1vbl9uYW1lGAMgASgJUgpjb21t'
    'b25OYW1lEiIKDG9yZ2FuaXphdGlvbhgEIAEoCVIMb3JnYW5pemF0aW9uEjIKFWFsbG93X3dlYW'
    'tfcGFzc3BocmFzZRgFIAEoCFITYWxsb3dXZWFrUGFzc3BocmFzZQ==');

@$core.Deprecated('Use restoreIdentityResponseDescriptor instead')
const RestoreIdentityResponse$json = {
  '1': 'RestoreIdentityResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {
      '1': 'identity',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.IdentityInfo',
      '10': 'identity'
    },
  ],
};

/// Descriptor for `RestoreIdentityResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List restoreIdentityResponseDescriptor = $convert.base64Decode(
    'ChdSZXN0b3JlSWRlbnRpdHlSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhQKBW'
    'Vycm9yGAIgASgJUgVlcnJvchI3CghpZGVudGl0eRgDIAEoCzIbLm5pdGVsbGEubG9jYWwuSWRl'
    'bnRpdHlJbmZvUghpZGVudGl0eQ==');

@$core.Deprecated('Use importIdentityRequestDescriptor instead')
const ImportIdentityRequest$json = {
  '1': 'ImportIdentityRequest',
  '2': [
    {'1': 'cert_pem', '3': 1, '4': 1, '5': 9, '10': 'certPem'},
    {'1': 'key_pem', '3': 2, '4': 1, '5': 9, '10': 'keyPem'},
    {'1': 'key_passphrase', '3': 3, '4': 1, '5': 9, '10': 'keyPassphrase'},
  ],
};

/// Descriptor for `ImportIdentityRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importIdentityRequestDescriptor = $convert.base64Decode(
    'ChVJbXBvcnRJZGVudGl0eVJlcXVlc3QSGQoIY2VydF9wZW0YASABKAlSB2NlcnRQZW0SFwoHa2'
    'V5X3BlbRgCIAEoCVIGa2V5UGVtEiUKDmtleV9wYXNzcGhyYXNlGAMgASgJUg1rZXlQYXNzcGhy'
    'YXNl');

@$core.Deprecated('Use importIdentityResponseDescriptor instead')
const ImportIdentityResponse$json = {
  '1': 'ImportIdentityResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {
      '1': 'identity',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.IdentityInfo',
      '10': 'identity'
    },
  ],
};

/// Descriptor for `ImportIdentityResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importIdentityResponseDescriptor = $convert.base64Decode(
    'ChZJbXBvcnRJZGVudGl0eVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSFAoFZX'
    'Jyb3IYAiABKAlSBWVycm9yEjcKCGlkZW50aXR5GAMgASgLMhsubml0ZWxsYS5sb2NhbC5JZGVu'
    'dGl0eUluZm9SCGlkZW50aXR5');

@$core.Deprecated('Use unlockIdentityRequestDescriptor instead')
const UnlockIdentityRequest$json = {
  '1': 'UnlockIdentityRequest',
  '2': [
    {'1': 'passphrase', '3': 1, '4': 1, '5': 9, '10': 'passphrase'},
  ],
};

/// Descriptor for `UnlockIdentityRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unlockIdentityRequestDescriptor = $convert.base64Decode(
    'ChVVbmxvY2tJZGVudGl0eVJlcXVlc3QSHgoKcGFzc3BocmFzZRgBIAEoCVIKcGFzc3BocmFzZQ'
    '==');

@$core.Deprecated('Use unlockIdentityResponseDescriptor instead')
const UnlockIdentityResponse$json = {
  '1': 'UnlockIdentityResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {
      '1': 'identity',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.IdentityInfo',
      '10': 'identity'
    },
  ],
};

/// Descriptor for `UnlockIdentityResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unlockIdentityResponseDescriptor = $convert.base64Decode(
    'ChZVbmxvY2tJZGVudGl0eVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSFAoFZX'
    'Jyb3IYAiABKAlSBWVycm9yEjcKCGlkZW50aXR5GAMgASgLMhsubml0ZWxsYS5sb2NhbC5JZGVu'
    'dGl0eUluZm9SCGlkZW50aXR5');

@$core.Deprecated('Use changePassphraseRequestDescriptor instead')
const ChangePassphraseRequest$json = {
  '1': 'ChangePassphraseRequest',
  '2': [
    {'1': 'old_passphrase', '3': 1, '4': 1, '5': 9, '10': 'oldPassphrase'},
    {'1': 'new_passphrase', '3': 2, '4': 1, '5': 9, '10': 'newPassphrase'},
    {
      '1': 'allow_weak_passphrase',
      '3': 3,
      '4': 1,
      '5': 8,
      '10': 'allowWeakPassphrase'
    },
  ],
};

/// Descriptor for `ChangePassphraseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changePassphraseRequestDescriptor = $convert.base64Decode(
    'ChdDaGFuZ2VQYXNzcGhyYXNlUmVxdWVzdBIlCg5vbGRfcGFzc3BocmFzZRgBIAEoCVINb2xkUG'
    'Fzc3BocmFzZRIlCg5uZXdfcGFzc3BocmFzZRgCIAEoCVINbmV3UGFzc3BocmFzZRIyChVhbGxv'
    'd193ZWFrX3Bhc3NwaHJhc2UYAyABKAhSE2FsbG93V2Vha1Bhc3NwaHJhc2U=');

@$core.Deprecated('Use evaluatePassphraseRequestDescriptor instead')
const EvaluatePassphraseRequest$json = {
  '1': 'EvaluatePassphraseRequest',
  '2': [
    {'1': 'passphrase', '3': 1, '4': 1, '5': 9, '10': 'passphrase'},
  ],
};

/// Descriptor for `EvaluatePassphraseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List evaluatePassphraseRequestDescriptor =
    $convert.base64Decode(
        'ChlFdmFsdWF0ZVBhc3NwaHJhc2VSZXF1ZXN0Eh4KCnBhc3NwaHJhc2UYASABKAlSCnBhc3NwaH'
        'Jhc2U=');

@$core.Deprecated('Use evaluatePassphraseResponseDescriptor instead')
const EvaluatePassphraseResponse$json = {
  '1': 'EvaluatePassphraseResponse',
  '2': [
    {
      '1': 'strength',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.PassphraseStrength',
      '10': 'strength'
    },
    {'1': 'entropy', '3': 2, '4': 1, '5': 1, '10': 'entropy'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    {'1': 'crack_time', '3': 4, '4': 1, '5': 9, '10': 'crackTime'},
    {'1': 'gpu_scenario', '3': 5, '4': 1, '5': 9, '10': 'gpuScenario'},
    {'1': 'should_warn', '3': 6, '4': 1, '5': 8, '10': 'shouldWarn'},
    {'1': 'report', '3': 7, '4': 1, '5': 9, '10': 'report'},
  ],
};

/// Descriptor for `EvaluatePassphraseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List evaluatePassphraseResponseDescriptor = $convert.base64Decode(
    'ChpFdmFsdWF0ZVBhc3NwaHJhc2VSZXNwb25zZRI9CghzdHJlbmd0aBgBIAEoDjIhLm5pdGVsbG'
    'EubG9jYWwuUGFzc3BocmFzZVN0cmVuZ3RoUghzdHJlbmd0aBIYCgdlbnRyb3B5GAIgASgBUgdl'
    'bnRyb3B5EhgKB21lc3NhZ2UYAyABKAlSB21lc3NhZ2USHQoKY3JhY2tfdGltZRgEIAEoCVIJY3'
    'JhY2tUaW1lEiEKDGdwdV9zY2VuYXJpbxgFIAEoCVILZ3B1U2NlbmFyaW8SHwoLc2hvdWxkX3dh'
    'cm4YBiABKAhSCnNob3VsZFdhcm4SFgoGcmVwb3J0GAcgASgJUgZyZXBvcnQ=');

@$core.Deprecated('Use nodeInfoDescriptor instead')
const NodeInfo$json = {
  '1': 'NodeInfo',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'fingerprint', '3': 3, '4': 1, '5': 9, '10': 'fingerprint'},
    {'1': 'emoji_hash', '3': 4, '4': 1, '5': 9, '10': 'emojiHash'},
    {'1': 'online', '3': 5, '4': 1, '5': 8, '10': 'online'},
    {
      '1': 'last_seen',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastSeen'
    },
    {
      '1': 'paired_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'pairedAt'
    },
    {'1': 'tags', '3': 8, '4': 3, '5': 9, '10': 'tags'},
    {
      '1': 'metrics',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.NodeMetrics',
      '10': 'metrics'
    },
    {'1': 'version', '3': 10, '4': 1, '5': 9, '10': 'version'},
    {'1': 'os', '3': 11, '4': 1, '5': 9, '10': 'os'},
    {'1': 'pinned', '3': 12, '4': 1, '5': 8, '10': 'pinned'},
    {'1': 'alerts_enabled', '3': 13, '4': 1, '5': 8, '10': 'alertsEnabled'},
    {'1': 'proxy_count', '3': 14, '4': 1, '5': 5, '10': 'proxyCount'},
    {
      '1': 'conn_type',
      '3': 15,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.NodeConnectionType',
      '10': 'connType'
    },
    {'1': 'direct_address', '3': 16, '4': 1, '5': 9, '10': 'directAddress'},
    {'1': 'direct_token', '3': 17, '4': 1, '5': 9, '10': 'directToken'},
    {'1': 'direct_ca_pem', '3': 18, '4': 1, '5': 9, '10': 'directCaPem'},
  ],
};

/// Descriptor for `NodeInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeInfoDescriptor = $convert.base64Decode(
    'CghOb2RlSW5mbxIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSEgoEbmFtZRgCIAEoCVIEbmFtZR'
    'IgCgtmaW5nZXJwcmludBgDIAEoCVILZmluZ2VycHJpbnQSHQoKZW1vamlfaGFzaBgEIAEoCVIJ'
    'ZW1vamlIYXNoEhYKBm9ubGluZRgFIAEoCFIGb25saW5lEjcKCWxhc3Rfc2VlbhgGIAEoCzIaLm'
    'dvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCGxhc3RTZWVuEjcKCXBhaXJlZF9hdBgHIAEoCzIa'
    'Lmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCHBhaXJlZEF0EhIKBHRhZ3MYCCADKAlSBHRhZ3'
    'MSNAoHbWV0cmljcxgJIAEoCzIaLm5pdGVsbGEubG9jYWwuTm9kZU1ldHJpY3NSB21ldHJpY3MS'
    'GAoHdmVyc2lvbhgKIAEoCVIHdmVyc2lvbhIOCgJvcxgLIAEoCVICb3MSFgoGcGlubmVkGAwgAS'
    'gIUgZwaW5uZWQSJQoOYWxlcnRzX2VuYWJsZWQYDSABKAhSDWFsZXJ0c0VuYWJsZWQSHwoLcHJv'
    'eHlfY291bnQYDiABKAVSCnByb3h5Q291bnQSPgoJY29ubl90eXBlGA8gASgOMiEubml0ZWxsYS'
    '5sb2NhbC5Ob2RlQ29ubmVjdGlvblR5cGVSCGNvbm5UeXBlEiUKDmRpcmVjdF9hZGRyZXNzGBAg'
    'ASgJUg1kaXJlY3RBZGRyZXNzEiEKDGRpcmVjdF90b2tlbhgRIAEoCVILZGlyZWN0VG9rZW4SIg'
    'oNZGlyZWN0X2NhX3BlbRgSIAEoCVILZGlyZWN0Q2FQZW0=');

@$core.Deprecated('Use nodeMetricsDescriptor instead')
const NodeMetrics$json = {
  '1': 'NodeMetrics',
  '2': [
    {
      '1': 'active_connections',
      '3': 1,
      '4': 1,
      '5': 3,
      '10': 'activeConnections'
    },
    {
      '1': 'total_connections',
      '3': 2,
      '4': 1,
      '5': 3,
      '10': 'totalConnections'
    },
    {'1': 'bytes_in', '3': 3, '4': 1, '5': 3, '10': 'bytesIn'},
    {'1': 'bytes_out', '3': 4, '4': 1, '5': 3, '10': 'bytesOut'},
    {'1': 'blocked_total', '3': 5, '4': 1, '5': 3, '10': 'blockedTotal'},
    {'1': 'proxy_count', '3': 6, '4': 1, '5': 5, '10': 'proxyCount'},
    {'1': 'uptime_seconds', '3': 7, '4': 1, '5': 3, '10': 'uptimeSeconds'},
  ],
};

/// Descriptor for `NodeMetrics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeMetricsDescriptor = $convert.base64Decode(
    'CgtOb2RlTWV0cmljcxItChJhY3RpdmVfY29ubmVjdGlvbnMYASABKANSEWFjdGl2ZUNvbm5lY3'
    'Rpb25zEisKEXRvdGFsX2Nvbm5lY3Rpb25zGAIgASgDUhB0b3RhbENvbm5lY3Rpb25zEhkKCGJ5'
    'dGVzX2luGAMgASgDUgdieXRlc0luEhsKCWJ5dGVzX291dBgEIAEoA1IIYnl0ZXNPdXQSIwoNYm'
    'xvY2tlZF90b3RhbBgFIAEoA1IMYmxvY2tlZFRvdGFsEh8KC3Byb3h5X2NvdW50GAYgASgFUgpw'
    'cm94eUNvdW50EiUKDnVwdGltZV9zZWNvbmRzGAcgASgDUg11cHRpbWVTZWNvbmRz');

@$core.Deprecated('Use listNodesRequestDescriptor instead')
const ListNodesRequest$json = {
  '1': 'ListNodesRequest',
  '2': [
    {'1': 'filter', '3': 1, '4': 1, '5': 9, '10': 'filter'},
  ],
};

/// Descriptor for `ListNodesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listNodesRequestDescriptor = $convert
    .base64Decode('ChBMaXN0Tm9kZXNSZXF1ZXN0EhYKBmZpbHRlchgBIAEoCVIGZmlsdGVy');

@$core.Deprecated('Use listNodesResponseDescriptor instead')
const ListNodesResponse$json = {
  '1': 'ListNodesResponse',
  '2': [
    {
      '1': 'nodes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.NodeInfo',
      '10': 'nodes'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
    {'1': 'online_count', '3': 3, '4': 1, '5': 5, '10': 'onlineCount'},
  ],
};

/// Descriptor for `ListNodesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listNodesResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0Tm9kZXNSZXNwb25zZRItCgVub2RlcxgBIAMoCzIXLm5pdGVsbGEubG9jYWwuTm9kZU'
    'luZm9SBW5vZGVzEh8KC3RvdGFsX2NvdW50GAIgASgFUgp0b3RhbENvdW50EiEKDG9ubGluZV9j'
    'b3VudBgDIAEoBVILb25saW5lQ291bnQ=');

@$core.Deprecated('Use getNodeRequestDescriptor instead')
const GetNodeRequest$json = {
  '1': 'GetNodeRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `GetNodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNodeRequestDescriptor = $convert
    .base64Decode('Cg5HZXROb2RlUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQ=');

@$core.Deprecated('Use getNodeDetailSnapshotRequestDescriptor instead')
const GetNodeDetailSnapshotRequest$json = {
  '1': 'GetNodeDetailSnapshotRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {
      '1': 'include_runtime_status',
      '3': 2,
      '4': 1,
      '5': 8,
      '10': 'includeRuntimeStatus'
    },
    {'1': 'include_proxies', '3': 3, '4': 1, '5': 8, '10': 'includeProxies'},
    {'1': 'include_rules', '3': 4, '4': 1, '5': 8, '10': 'includeRules'},
    {
      '1': 'include_connection_stats',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'includeConnectionStats'
    },
  ],
};

/// Descriptor for `GetNodeDetailSnapshotRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNodeDetailSnapshotRequestDescriptor = $convert.base64Decode(
    'ChxHZXROb2RlRGV0YWlsU25hcHNob3RSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZB'
    'I0ChZpbmNsdWRlX3J1bnRpbWVfc3RhdHVzGAIgASgIUhRpbmNsdWRlUnVudGltZVN0YXR1cxIn'
    'Cg9pbmNsdWRlX3Byb3hpZXMYAyABKAhSDmluY2x1ZGVQcm94aWVzEiMKDWluY2x1ZGVfcnVsZX'
    'MYBCABKAhSDGluY2x1ZGVSdWxlcxI4ChhpbmNsdWRlX2Nvbm5lY3Rpb25fc3RhdHMYBSABKAhS'
    'FmluY2x1ZGVDb25uZWN0aW9uU3RhdHM=');

@$core.Deprecated('Use nodeRuntimeStatusDescriptor instead')
const NodeRuntimeStatus$json = {
  '1': 'NodeRuntimeStatus',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
    {
      '1': 'last_seen',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastSeen'
    },
    {'1': 'public_ip', '3': 3, '4': 1, '5': 9, '10': 'publicIp'},
    {'1': 'version', '3': 4, '4': 1, '5': 9, '10': 'version'},
    {'1': 'geoip_enabled', '3': 5, '4': 1, '5': 8, '10': 'geoipEnabled'},
  ],
};

/// Descriptor for `NodeRuntimeStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeRuntimeStatusDescriptor = $convert.base64Decode(
    'ChFOb2RlUnVudGltZVN0YXR1cxIWCgZzdGF0dXMYASABKAlSBnN0YXR1cxI3CglsYXN0X3NlZW'
    '4YAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUghsYXN0U2VlbhIbCglwdWJsaWNf'
    'aXAYAyABKAlSCHB1YmxpY0lwEhgKB3ZlcnNpb24YBCABKAlSB3ZlcnNpb24SIwoNZ2VvaXBfZW'
    '5hYmxlZBgFIAEoCFIMZ2VvaXBFbmFibGVk');

@$core.Deprecated('Use nodeDetailSnapshotDescriptor instead')
const NodeDetailSnapshot$json = {
  '1': 'NodeDetailSnapshot',
  '2': [
    {
      '1': 'node',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.NodeInfo',
      '10': 'node'
    },
    {
      '1': 'runtime_status',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.NodeRuntimeStatus',
      '10': 'runtimeStatus'
    },
    {
      '1': 'proxies',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.ProxyInfo',
      '10': 'proxies'
    },
    {
      '1': 'rules',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.nitella.proxy.Rule',
      '10': 'rules'
    },
    {
      '1': 'connection_stats',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.ConnectionStats',
      '10': 'connectionStats'
    },
  ],
};

/// Descriptor for `NodeDetailSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeDetailSnapshotDescriptor = $convert.base64Decode(
    'ChJOb2RlRGV0YWlsU25hcHNob3QSKwoEbm9kZRgBIAEoCzIXLm5pdGVsbGEubG9jYWwuTm9kZU'
    'luZm9SBG5vZGUSRwoOcnVudGltZV9zdGF0dXMYAiABKAsyIC5uaXRlbGxhLmxvY2FsLk5vZGVS'
    'dW50aW1lU3RhdHVzUg1ydW50aW1lU3RhdHVzEjIKB3Byb3hpZXMYAyADKAsyGC5uaXRlbGxhLm'
    'xvY2FsLlByb3h5SW5mb1IHcHJveGllcxIpCgVydWxlcxgEIAMoCzITLm5pdGVsbGEucHJveHku'
    'UnVsZVIFcnVsZXMSSQoQY29ubmVjdGlvbl9zdGF0cxgFIAEoCzIeLm5pdGVsbGEubG9jYWwuQ2'
    '9ubmVjdGlvblN0YXRzUg9jb25uZWN0aW9uU3RhdHM=');

@$core.Deprecated('Use updateNodeRequestDescriptor instead')
const UpdateNodeRequest$json = {
  '1': 'UpdateNodeRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'tags', '3': 3, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'pinned', '3': 4, '4': 1, '5': 8, '10': 'pinned'},
    {'1': 'alerts_enabled', '3': 5, '4': 1, '5': 8, '10': 'alertsEnabled'},
    {
      '1': 'update_mask',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'updateMask'
    },
  ],
};

/// Descriptor for `UpdateNodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateNodeRequestDescriptor = $convert.base64Decode(
    'ChFVcGRhdGVOb2RlUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSEgoEbmFtZRgCIA'
    'EoCVIEbmFtZRISCgR0YWdzGAMgAygJUgR0YWdzEhYKBnBpbm5lZBgEIAEoCFIGcGlubmVkEiUK'
    'DmFsZXJ0c19lbmFibGVkGAUgASgIUg1hbGVydHNFbmFibGVkEjsKC3VwZGF0ZV9tYXNrGAYgAS'
    'gLMhouZ29vZ2xlLnByb3RvYnVmLkZpZWxkTWFza1IKdXBkYXRlTWFzaw==');

@$core.Deprecated('Use removeNodeRequestDescriptor instead')
const RemoveNodeRequest$json = {
  '1': 'RemoveNodeRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `RemoveNodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeNodeRequestDescriptor = $convert.base64Decode(
    'ChFSZW1vdmVOb2RlUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQ=');

@$core.Deprecated('Use addNodeDirectRequestDescriptor instead')
const AddNodeDirectRequest$json = {
  '1': 'AddNodeDirectRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'token', '3': 3, '4': 1, '5': 9, '10': 'token'},
    {'1': 'ca_pem', '3': 4, '4': 1, '5': 9, '10': 'caPem'},
  ],
};

/// Descriptor for `AddNodeDirectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addNodeDirectRequestDescriptor = $convert.base64Decode(
    'ChRBZGROb2RlRGlyZWN0UmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEhgKB2FkZHJlc3MYAi'
    'ABKAlSB2FkZHJlc3MSFAoFdG9rZW4YAyABKAlSBXRva2VuEhUKBmNhX3BlbRgEIAEoCVIFY2FQ'
    'ZW0=');

@$core.Deprecated('Use addNodeDirectResponseDescriptor instead')
const AddNodeDirectResponse$json = {
  '1': 'AddNodeDirectResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {
      '1': 'node',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.NodeInfo',
      '10': 'node'
    },
  ],
};

/// Descriptor for `AddNodeDirectResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addNodeDirectResponseDescriptor = $convert.base64Decode(
    'ChVBZGROb2RlRGlyZWN0UmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIUCgVlcn'
    'JvchgCIAEoCVIFZXJyb3ISKwoEbm9kZRgDIAEoCzIXLm5pdGVsbGEubG9jYWwuTm9kZUluZm9S'
    'BG5vZGU=');

@$core.Deprecated('Use testDirectConnectionRequestDescriptor instead')
const TestDirectConnectionRequest$json = {
  '1': 'TestDirectConnectionRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'token', '3': 2, '4': 1, '5': 9, '10': 'token'},
    {'1': 'ca_pem', '3': 3, '4': 1, '5': 9, '10': 'caPem'},
  ],
};

/// Descriptor for `TestDirectConnectionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testDirectConnectionRequestDescriptor =
    $convert.base64Decode(
        'ChtUZXN0RGlyZWN0Q29ubmVjdGlvblJlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcx'
        'IUCgV0b2tlbhgCIAEoCVIFdG9rZW4SFQoGY2FfcGVtGAMgASgJUgVjYVBlbQ==');

@$core.Deprecated('Use testDirectConnectionResponseDescriptor instead')
const TestDirectConnectionResponse$json = {
  '1': 'TestDirectConnectionResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'node_version', '3': 3, '4': 1, '5': 9, '10': 'nodeVersion'},
    {'1': 'node_hostname', '3': 4, '4': 1, '5': 9, '10': 'nodeHostname'},
    {'1': 'proxy_count', '3': 5, '4': 1, '5': 5, '10': 'proxyCount'},
    {'1': 'emoji_hash', '3': 6, '4': 1, '5': 9, '10': 'emojiHash'},
  ],
};

/// Descriptor for `TestDirectConnectionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testDirectConnectionResponseDescriptor = $convert.base64Decode(
    'ChxUZXN0RGlyZWN0Q29ubmVjdGlvblJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3'
    'MSFAoFZXJyb3IYAiABKAlSBWVycm9yEiEKDG5vZGVfdmVyc2lvbhgDIAEoCVILbm9kZVZlcnNp'
    'b24SIwoNbm9kZV9ob3N0bmFtZRgEIAEoCVIMbm9kZUhvc3RuYW1lEh8KC3Byb3h5X2NvdW50GA'
    'UgASgFUgpwcm94eUNvdW50Eh0KCmVtb2ppX2hhc2gYBiABKAlSCWVtb2ppSGFzaA==');

@$core.Deprecated('Use proxyInfoDescriptor instead')
const ProxyInfo$json = {
  '1': 'ProxyInfo',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'listen_addr', '3': 4, '4': 1, '5': 9, '10': 'listenAddr'},
    {'1': 'default_backend', '3': 5, '4': 1, '5': 9, '10': 'defaultBackend'},
    {'1': 'running', '3': 6, '4': 1, '5': 8, '10': 'running'},
    {
      '1': 'default_action',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.nitella.ActionType',
      '10': 'defaultAction'
    },
    {
      '1': 'fallback_action',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.nitella.FallbackAction',
      '10': 'fallbackAction'
    },
    {'1': 'rule_count', '3': 9, '4': 1, '5': 5, '10': 'ruleCount'},
    {
      '1': 'active_connections',
      '3': 10,
      '4': 1,
      '5': 3,
      '10': 'activeConnections'
    },
    {
      '1': 'total_connections',
      '3': 11,
      '4': 1,
      '5': 3,
      '10': 'totalConnections'
    },
    {'1': 'tags', '3': 12, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `ProxyInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List proxyInfoDescriptor = $convert.base64Decode(
    'CglQcm94eUluZm8SGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQSFwoHbm9kZV9pZBgCIAEoCV'
    'IGbm9kZUlkEhIKBG5hbWUYAyABKAlSBG5hbWUSHwoLbGlzdGVuX2FkZHIYBCABKAlSCmxpc3Rl'
    'bkFkZHISJwoPZGVmYXVsdF9iYWNrZW5kGAUgASgJUg5kZWZhdWx0QmFja2VuZBIYCgdydW5uaW'
    '5nGAYgASgIUgdydW5uaW5nEjoKDmRlZmF1bHRfYWN0aW9uGAcgASgOMhMubml0ZWxsYS5BY3Rp'
    'b25UeXBlUg1kZWZhdWx0QWN0aW9uEkAKD2ZhbGxiYWNrX2FjdGlvbhgIIAEoDjIXLm5pdGVsbG'
    'EuRmFsbGJhY2tBY3Rpb25SDmZhbGxiYWNrQWN0aW9uEh0KCnJ1bGVfY291bnQYCSABKAVSCXJ1'
    'bGVDb3VudBItChJhY3RpdmVfY29ubmVjdGlvbnMYCiABKANSEWFjdGl2ZUNvbm5lY3Rpb25zEi'
    'sKEXRvdGFsX2Nvbm5lY3Rpb25zGAsgASgDUhB0b3RhbENvbm5lY3Rpb25zEhIKBHRhZ3MYDCAD'
    'KAlSBHRhZ3M=');

@$core.Deprecated('Use listProxiesRequestDescriptor instead')
const ListProxiesRequest$json = {
  '1': 'ListProxiesRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'offset', '3': 3, '4': 1, '5': 5, '10': 'offset'},
  ],
};

/// Descriptor for `ListProxiesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProxiesRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0UHJveGllc1JlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlkEhQKBWxpbWl0GA'
    'IgASgFUgVsaW1pdBIWCgZvZmZzZXQYAyABKAVSBm9mZnNldA==');

@$core.Deprecated('Use listProxiesResponseDescriptor instead')
const ListProxiesResponse$json = {
  '1': 'ListProxiesResponse',
  '2': [
    {
      '1': 'proxies',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.ProxyInfo',
      '10': 'proxies'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListProxiesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProxiesResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0UHJveGllc1Jlc3BvbnNlEjIKB3Byb3hpZXMYASADKAsyGC5uaXRlbGxhLmxvY2FsLl'
    'Byb3h5SW5mb1IHcHJveGllcxIfCgt0b3RhbF9jb3VudBgCIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use getProxiesSnapshotRequestDescriptor instead')
const GetProxiesSnapshotRequest$json = {
  '1': 'GetProxiesSnapshotRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'node_filter', '3': 2, '4': 1, '5': 9, '10': 'nodeFilter'},
  ],
};

/// Descriptor for `GetProxiesSnapshotRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProxiesSnapshotRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRQcm94aWVzU25hcHNob3RSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBIfCg'
        'tub2RlX2ZpbHRlchgCIAEoCVIKbm9kZUZpbHRlcg==');

@$core.Deprecated('Use nodeProxiesSnapshotDescriptor instead')
const NodeProxiesSnapshot$json = {
  '1': 'NodeProxiesSnapshot',
  '2': [
    {
      '1': 'node',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.NodeInfo',
      '10': 'node'
    },
    {
      '1': 'proxies',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.ProxyInfo',
      '10': 'proxies'
    },
  ],
};

/// Descriptor for `NodeProxiesSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeProxiesSnapshotDescriptor = $convert.base64Decode(
    'ChNOb2RlUHJveGllc1NuYXBzaG90EisKBG5vZGUYASABKAsyFy5uaXRlbGxhLmxvY2FsLk5vZG'
    'VJbmZvUgRub2RlEjIKB3Byb3hpZXMYAiADKAsyGC5uaXRlbGxhLmxvY2FsLlByb3h5SW5mb1IH'
    'cHJveGllcw==');

@$core.Deprecated('Use getProxiesSnapshotResponseDescriptor instead')
const GetProxiesSnapshotResponse$json = {
  '1': 'GetProxiesSnapshotResponse',
  '2': [
    {
      '1': 'node_snapshots',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.NodeProxiesSnapshot',
      '10': 'nodeSnapshots'
    },
    {'1': 'total_nodes', '3': 2, '4': 1, '5': 5, '10': 'totalNodes'},
    {'1': 'total_proxies', '3': 3, '4': 1, '5': 5, '10': 'totalProxies'},
  ],
};

/// Descriptor for `GetProxiesSnapshotResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProxiesSnapshotResponseDescriptor = $convert.base64Decode(
    'ChpHZXRQcm94aWVzU25hcHNob3RSZXNwb25zZRJJCg5ub2RlX3NuYXBzaG90cxgBIAMoCzIiLm'
    '5pdGVsbGEubG9jYWwuTm9kZVByb3hpZXNTbmFwc2hvdFINbm9kZVNuYXBzaG90cxIfCgt0b3Rh'
    'bF9ub2RlcxgCIAEoBVIKdG90YWxOb2RlcxIjCg10b3RhbF9wcm94aWVzGAMgASgFUgx0b3RhbF'
    'Byb3hpZXM=');

@$core.Deprecated('Use getProxyRequestDescriptor instead')
const GetProxyRequest$json = {
  '1': 'GetProxyRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `GetProxyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProxyRequestDescriptor = $convert.base64Decode(
    'Cg9HZXRQcm94eVJlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlkEhkKCHByb3h5X2lkGA'
    'IgASgJUgdwcm94eUlk');

@$core.Deprecated('Use addProxyRequestDescriptor instead')
const AddProxyRequest$json = {
  '1': 'AddProxyRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'listen_addr', '3': 3, '4': 1, '5': 9, '10': 'listenAddr'},
    {'1': 'default_backend', '3': 4, '4': 1, '5': 9, '10': 'defaultBackend'},
    {
      '1': 'default_action',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.nitella.ActionType',
      '10': 'defaultAction'
    },
    {
      '1': 'fallback_action',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.nitella.FallbackAction',
      '10': 'fallbackAction'
    },
    {
      '1': 'default_mock',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.nitella.MockPreset',
      '10': 'defaultMock'
    },
    {
      '1': 'fallback_mock',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.nitella.MockPreset',
      '10': 'fallbackMock'
    },
    {'1': 'tags', '3': 9, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'cert_pem', '3': 10, '4': 1, '5': 9, '10': 'certPem'},
    {'1': 'key_pem', '3': 11, '4': 1, '5': 9, '10': 'keyPem'},
    {'1': 'ca_pem', '3': 12, '4': 1, '5': 9, '10': 'caPem'},
  ],
};

/// Descriptor for `AddProxyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addProxyRequestDescriptor = $convert.base64Decode(
    'Cg9BZGRQcm94eVJlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlkEhIKBG5hbWUYAiABKA'
    'lSBG5hbWUSHwoLbGlzdGVuX2FkZHIYAyABKAlSCmxpc3RlbkFkZHISJwoPZGVmYXVsdF9iYWNr'
    'ZW5kGAQgASgJUg5kZWZhdWx0QmFja2VuZBI6Cg5kZWZhdWx0X2FjdGlvbhgFIAEoDjITLm5pdG'
    'VsbGEuQWN0aW9uVHlwZVINZGVmYXVsdEFjdGlvbhJACg9mYWxsYmFja19hY3Rpb24YBiABKA4y'
    'Fy5uaXRlbGxhLkZhbGxiYWNrQWN0aW9uUg5mYWxsYmFja0FjdGlvbhI2CgxkZWZhdWx0X21vY2'
    'sYByABKA4yEy5uaXRlbGxhLk1vY2tQcmVzZXRSC2RlZmF1bHRNb2NrEjgKDWZhbGxiYWNrX21v'
    'Y2sYCCABKA4yEy5uaXRlbGxhLk1vY2tQcmVzZXRSDGZhbGxiYWNrTW9jaxISCgR0YWdzGAkgAy'
    'gJUgR0YWdzEhkKCGNlcnRfcGVtGAogASgJUgdjZXJ0UGVtEhcKB2tleV9wZW0YCyABKAlSBmtl'
    'eVBlbRIVCgZjYV9wZW0YDCABKAlSBWNhUGVt');

@$core.Deprecated('Use updateProxyRequestDescriptor instead')
const UpdateProxyRequest$json = {
  '1': 'UpdateProxyRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'listen_addr', '3': 4, '4': 1, '5': 9, '10': 'listenAddr'},
    {'1': 'default_backend', '3': 5, '4': 1, '5': 9, '10': 'defaultBackend'},
    {
      '1': 'default_action',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.nitella.ActionType',
      '10': 'defaultAction'
    },
    {
      '1': 'fallback_action',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.nitella.FallbackAction',
      '10': 'fallbackAction'
    },
    {
      '1': 'default_mock',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.nitella.MockPreset',
      '10': 'defaultMock'
    },
    {
      '1': 'fallback_mock',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.nitella.MockPreset',
      '10': 'fallbackMock'
    },
    {'1': 'tags', '3': 10, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'running', '3': 11, '4': 1, '5': 8, '10': 'running'},
    {
      '1': 'update_mask',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'updateMask'
    },
  ],
};

/// Descriptor for `UpdateProxyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProxyRequestDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVQcm94eVJlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlkEhkKCHByb3h5X2'
    'lkGAIgASgJUgdwcm94eUlkEhIKBG5hbWUYAyABKAlSBG5hbWUSHwoLbGlzdGVuX2FkZHIYBCAB'
    'KAlSCmxpc3RlbkFkZHISJwoPZGVmYXVsdF9iYWNrZW5kGAUgASgJUg5kZWZhdWx0QmFja2VuZB'
    'I6Cg5kZWZhdWx0X2FjdGlvbhgGIAEoDjITLm5pdGVsbGEuQWN0aW9uVHlwZVINZGVmYXVsdEFj'
    'dGlvbhJACg9mYWxsYmFja19hY3Rpb24YByABKA4yFy5uaXRlbGxhLkZhbGxiYWNrQWN0aW9uUg'
    '5mYWxsYmFja0FjdGlvbhI2CgxkZWZhdWx0X21vY2sYCCABKA4yEy5uaXRlbGxhLk1vY2tQcmVz'
    'ZXRSC2RlZmF1bHRNb2NrEjgKDWZhbGxiYWNrX21vY2sYCSABKA4yEy5uaXRlbGxhLk1vY2tQcm'
    'VzZXRSDGZhbGxiYWNrTW9jaxISCgR0YWdzGAogAygJUgR0YWdzEhgKB3J1bm5pbmcYCyABKAhS'
    'B3J1bm5pbmcSOwoLdXBkYXRlX21hc2sYDCABKAsyGi5nb29nbGUucHJvdG9idWYuRmllbGRNYX'
    'NrUgp1cGRhdGVNYXNr');

@$core.Deprecated('Use removeProxyRequestDescriptor instead')
const RemoveProxyRequest$json = {
  '1': 'RemoveProxyRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `RemoveProxyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeProxyRequestDescriptor = $convert.base64Decode(
    'ChJSZW1vdmVQcm94eVJlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlkEhkKCHByb3h5X2'
    'lkGAIgASgJUgdwcm94eUlk');

@$core.Deprecated('Use setNodeProxiesRunningRequestDescriptor instead')
const SetNodeProxiesRunningRequest$json = {
  '1': 'SetNodeProxiesRunningRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'running', '3': 2, '4': 1, '5': 8, '10': 'running'},
  ],
};

/// Descriptor for `SetNodeProxiesRunningRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setNodeProxiesRunningRequestDescriptor =
    $convert.base64Decode(
        'ChxTZXROb2RlUHJveGllc1J1bm5pbmdSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZB'
        'IYCgdydW5uaW5nGAIgASgIUgdydW5uaW5n');

@$core.Deprecated('Use setNodeProxiesRunningResponseDescriptor instead')
const SetNodeProxiesRunningResponse$json = {
  '1': 'SetNodeProxiesRunningResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'updated_count', '3': 3, '4': 1, '5': 5, '10': 'updatedCount'},
    {'1': 'skipped_count', '3': 4, '4': 1, '5': 5, '10': 'skippedCount'},
    {'1': 'failed_proxy_ids', '3': 5, '4': 3, '5': 9, '10': 'failedProxyIds'},
  ],
};

/// Descriptor for `SetNodeProxiesRunningResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setNodeProxiesRunningResponseDescriptor = $convert.base64Decode(
    'Ch1TZXROb2RlUHJveGllc1J1bm5pbmdSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZX'
    'NzEhQKBWVycm9yGAIgASgJUgVlcnJvchIjCg11cGRhdGVkX2NvdW50GAMgASgFUgx1cGRhdGVk'
    'Q291bnQSIwoNc2tpcHBlZF9jb3VudBgEIAEoBVIMc2tpcHBlZENvdW50EigKEGZhaWxlZF9wcm'
    '94eV9pZHMYBSADKAlSDmZhaWxlZFByb3h5SWRz');

@$core.Deprecated('Use listRulesRequestDescriptor instead')
const ListRulesRequest$json = {
  '1': 'ListRulesRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `ListRulesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRulesRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0UnVsZXNSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBIZCghwcm94eV9pZB'
    'gCIAEoCVIHcHJveHlJZA==');

@$core.Deprecated('Use listRulesResponseDescriptor instead')
const ListRulesResponse$json = {
  '1': 'ListRulesResponse',
  '2': [
    {
      '1': 'rules',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.proxy.Rule',
      '10': 'rules'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
    {
      '1': 'composer_policy',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.RuleComposerPolicy',
      '10': 'composerPolicy'
    },
  ],
};

/// Descriptor for `ListRulesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRulesResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0UnVsZXNSZXNwb25zZRIpCgVydWxlcxgBIAMoCzITLm5pdGVsbGEucHJveHkuUnVsZV'
    'IFcnVsZXMSHwoLdG90YWxfY291bnQYAiABKAVSCnRvdGFsQ291bnQSSgoPY29tcG9zZXJfcG9s'
    'aWN5GAMgASgLMiEubml0ZWxsYS5sb2NhbC5SdWxlQ29tcG9zZXJQb2xpY3lSDmNvbXBvc2VyUG'
    '9saWN5');

@$core.Deprecated('Use ruleComposerConditionPolicyDescriptor instead')
const RuleComposerConditionPolicy$json = {
  '1': 'RuleComposerConditionPolicy',
  '2': [
    {
      '1': 'condition_type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.nitella.ConditionType',
      '10': 'conditionType'
    },
    {
      '1': 'operators',
      '3': 2,
      '4': 3,
      '5': 14,
      '6': '.nitella.Operator',
      '10': 'operators'
    },
    {
      '1': 'default_operator',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.nitella.Operator',
      '10': 'defaultOperator'
    },
    {'1': 'value_hint', '3': 4, '4': 1, '5': 9, '10': 'valueHint'},
  ],
};

/// Descriptor for `RuleComposerConditionPolicy`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ruleComposerConditionPolicyDescriptor = $convert.base64Decode(
    'ChtSdWxlQ29tcG9zZXJDb25kaXRpb25Qb2xpY3kSPQoOY29uZGl0aW9uX3R5cGUYASABKA4yFi'
    '5uaXRlbGxhLkNvbmRpdGlvblR5cGVSDWNvbmRpdGlvblR5cGUSLwoJb3BlcmF0b3JzGAIgAygO'
    'MhEubml0ZWxsYS5PcGVyYXRvclIJb3BlcmF0b3JzEjwKEGRlZmF1bHRfb3BlcmF0b3IYAyABKA'
    '4yES5uaXRlbGxhLk9wZXJhdG9yUg9kZWZhdWx0T3BlcmF0b3ISHQoKdmFsdWVfaGludBgEIAEo'
    'CVIJdmFsdWVIaW50');

@$core.Deprecated('Use ruleComposerPolicyDescriptor instead')
const RuleComposerPolicy$json = {
  '1': 'RuleComposerPolicy',
  '2': [
    {
      '1': 'condition_policies',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.RuleComposerConditionPolicy',
      '10': 'conditionPolicies'
    },
    {
      '1': 'allowed_actions',
      '3': 2,
      '4': 3,
      '5': 14,
      '6': '.nitella.ActionType',
      '10': 'allowedActions'
    },
    {'1': 'default_priority', '3': 3, '4': 1, '5': 5, '10': 'defaultPriority'},
  ],
};

/// Descriptor for `RuleComposerPolicy`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ruleComposerPolicyDescriptor = $convert.base64Decode(
    'ChJSdWxlQ29tcG9zZXJQb2xpY3kSWQoSY29uZGl0aW9uX3BvbGljaWVzGAEgAygLMioubml0ZW'
    'xsYS5sb2NhbC5SdWxlQ29tcG9zZXJDb25kaXRpb25Qb2xpY3lSEWNvbmRpdGlvblBvbGljaWVz'
    'EjwKD2FsbG93ZWRfYWN0aW9ucxgCIAMoDjITLm5pdGVsbGEuQWN0aW9uVHlwZVIOYWxsb3dlZE'
    'FjdGlvbnMSKQoQZGVmYXVsdF9wcmlvcml0eRgDIAEoBVIPZGVmYXVsdFByaW9yaXR5');

@$core.Deprecated('Use getRuleRequestDescriptor instead')
const GetRuleRequest$json = {
  '1': 'GetRuleRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'rule_id', '3': 3, '4': 1, '5': 9, '10': 'ruleId'},
  ],
};

/// Descriptor for `GetRuleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRuleRequestDescriptor = $convert.base64Decode(
    'Cg5HZXRSdWxlUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSGQoIcHJveHlfaWQYAi'
    'ABKAlSB3Byb3h5SWQSFwoHcnVsZV9pZBgDIAEoCVIGcnVsZUlk');

@$core.Deprecated('Use addRuleRequestDescriptor instead')
const AddRuleRequest$json = {
  '1': 'AddRuleRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
    {
      '1': 'rule',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.Rule',
      '10': 'rule'
    },
  ],
};

/// Descriptor for `AddRuleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addRuleRequestDescriptor = $convert.base64Decode(
    'Cg5BZGRSdWxlUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSGQoIcHJveHlfaWQYAi'
    'ABKAlSB3Byb3h5SWQSJwoEcnVsZRgDIAEoCzITLm5pdGVsbGEucHJveHkuUnVsZVIEcnVsZQ==');

@$core.Deprecated('Use addQuickRuleRequestDescriptor instead')
const AddQuickRuleRequest$json = {
  '1': 'AddQuickRuleRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'action',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.nitella.ActionType',
      '10': 'action'
    },
    {
      '1': 'condition_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.nitella.ConditionType',
      '10': 'conditionType'
    },
    {'1': 'value', '3': 6, '4': 1, '5': 9, '10': 'value'},
    {'1': 'duration_seconds', '3': 7, '4': 1, '5': 5, '10': 'durationSeconds'},
    {
      '1': 'source_ip_to_cidr24',
      '3': 8,
      '4': 1,
      '5': 8,
      '10': 'sourceIpToCidr24'
    },
    {
      '1': 'apply_to_all_nodes',
      '3': 9,
      '4': 1,
      '5': 8,
      '10': 'applyToAllNodes'
    },
  ],
};

/// Descriptor for `AddQuickRuleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addQuickRuleRequestDescriptor = $convert.base64Decode(
    'ChNBZGRRdWlja1J1bGVSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBIZCghwcm94eV'
    '9pZBgCIAEoCVIHcHJveHlJZBISCgRuYW1lGAMgASgJUgRuYW1lEisKBmFjdGlvbhgEIAEoDjIT'
    'Lm5pdGVsbGEuQWN0aW9uVHlwZVIGYWN0aW9uEj0KDmNvbmRpdGlvbl90eXBlGAUgASgOMhYubm'
    'l0ZWxsYS5Db25kaXRpb25UeXBlUg1jb25kaXRpb25UeXBlEhQKBXZhbHVlGAYgASgJUgV2YWx1'
    'ZRIpChBkdXJhdGlvbl9zZWNvbmRzGAcgASgFUg9kdXJhdGlvblNlY29uZHMSLQoTc291cmNlX2'
    'lwX3RvX2NpZHIyNBgIIAEoCFIQc291cmNlSXBUb0NpZHIyNBIrChJhcHBseV90b19hbGxfbm9k'
    'ZXMYCSABKAhSD2FwcGx5VG9BbGxOb2Rlcw==');

@$core.Deprecated('Use addQuickRuleResponseDescriptor instead')
const AddQuickRuleResponse$json = {
  '1': 'AddQuickRuleResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'rule_id', '3': 3, '4': 1, '5': 9, '10': 'ruleId'},
    {'1': 'rules_created', '3': 4, '4': 1, '5': 5, '10': 'rulesCreated'},
  ],
};

/// Descriptor for `AddQuickRuleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addQuickRuleResponseDescriptor = $convert.base64Decode(
    'ChRBZGRRdWlja1J1bGVSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhQKBWVycm'
    '9yGAIgASgJUgVlcnJvchIXCgdydWxlX2lkGAMgASgJUgZydWxlSWQSIwoNcnVsZXNfY3JlYXRl'
    'ZBgEIAEoBVIMcnVsZXNDcmVhdGVk');

@$core.Deprecated('Use updateRuleRequestDescriptor instead')
const UpdateRuleRequest$json = {
  '1': 'UpdateRuleRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
    {
      '1': 'rule',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.Rule',
      '10': 'rule'
    },
    {
      '1': 'update_mask',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'updateMask'
    },
  ],
};

/// Descriptor for `UpdateRuleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateRuleRequestDescriptor = $convert.base64Decode(
    'ChFVcGRhdGVSdWxlUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSGQoIcHJveHlfaW'
    'QYAiABKAlSB3Byb3h5SWQSJwoEcnVsZRgDIAEoCzITLm5pdGVsbGEucHJveHkuUnVsZVIEcnVs'
    'ZRI7Cgt1cGRhdGVfbWFzaxgEIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5GaWVsZE1hc2tSCnVwZG'
    'F0ZU1hc2s=');

@$core.Deprecated('Use removeRuleRequestDescriptor instead')
const RemoveRuleRequest$json = {
  '1': 'RemoveRuleRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'rule_id', '3': 3, '4': 1, '5': 9, '10': 'ruleId'},
  ],
};

/// Descriptor for `RemoveRuleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeRuleRequestDescriptor = $convert.base64Decode(
    'ChFSZW1vdmVSdWxlUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSGQoIcHJveHlfaW'
    'QYAiABKAlSB3Byb3h5SWQSFwoHcnVsZV9pZBgDIAEoCVIGcnVsZUlk');

@$core.Deprecated('Use blockIPRequestDescriptor instead')
const BlockIPRequest$json = {
  '1': 'BlockIPRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'ip', '3': 3, '4': 1, '5': 9, '10': 'ip'},
    {
      '1': 'apply_to_all_nodes',
      '3': 4,
      '4': 1,
      '5': 8,
      '10': 'applyToAllNodes'
    },
  ],
};

/// Descriptor for `BlockIPRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockIPRequestDescriptor = $convert.base64Decode(
    'Cg5CbG9ja0lQUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSGQoIcHJveHlfaWQYAi'
    'ABKAlSB3Byb3h5SWQSDgoCaXAYAyABKAlSAmlwEisKEmFwcGx5X3RvX2FsbF9ub2RlcxgEIAEo'
    'CFIPYXBwbHlUb0FsbE5vZGVz');

@$core.Deprecated('Use blockIPResponseDescriptor instead')
const BlockIPResponse$json = {
  '1': 'BlockIPResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'rules_created', '3': 3, '4': 1, '5': 5, '10': 'rulesCreated'},
  ],
};

/// Descriptor for `BlockIPResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockIPResponseDescriptor = $convert.base64Decode(
    'Cg9CbG9ja0lQUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIUCgVlcnJvchgCIA'
    'EoCVIFZXJyb3ISIwoNcnVsZXNfY3JlYXRlZBgDIAEoBVIMcnVsZXNDcmVhdGVk');

@$core.Deprecated('Use blockISPRequestDescriptor instead')
const BlockISPRequest$json = {
  '1': 'BlockISPRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'isp', '3': 3, '4': 1, '5': 9, '10': 'isp'},
  ],
};

/// Descriptor for `BlockISPRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockISPRequestDescriptor = $convert.base64Decode(
    'Cg9CbG9ja0lTUFJlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlkEhkKCHByb3h5X2lkGA'
    'IgASgJUgdwcm94eUlkEhAKA2lzcBgDIAEoCVIDaXNw');

@$core.Deprecated('Use blockISPResponseDescriptor instead')
const BlockISPResponse$json = {
  '1': 'BlockISPResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'rule_id', '3': 3, '4': 1, '5': 9, '10': 'ruleId'},
  ],
};

/// Descriptor for `BlockISPResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockISPResponseDescriptor = $convert.base64Decode(
    'ChBCbG9ja0lTUFJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSFAoFZXJyb3IYAi'
    'ABKAlSBWVycm9yEhcKB3J1bGVfaWQYAyABKAlSBnJ1bGVJZA==');

@$core.Deprecated('Use blockCountryRequestDescriptor instead')
const BlockCountryRequest$json = {
  '1': 'BlockCountryRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'country', '3': 3, '4': 1, '5': 9, '10': 'country'},
  ],
};

/// Descriptor for `BlockCountryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockCountryRequestDescriptor = $convert.base64Decode(
    'ChNCbG9ja0NvdW50cnlSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBIZCghwcm94eV'
    '9pZBgCIAEoCVIHcHJveHlJZBIYCgdjb3VudHJ5GAMgASgJUgdjb3VudHJ5');

@$core.Deprecated('Use blockCountryResponseDescriptor instead')
const BlockCountryResponse$json = {
  '1': 'BlockCountryResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'rule_id', '3': 3, '4': 1, '5': 9, '10': 'ruleId'},
  ],
};

/// Descriptor for `BlockCountryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockCountryResponseDescriptor = $convert.base64Decode(
    'ChRCbG9ja0NvdW50cnlSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhQKBWVycm'
    '9yGAIgASgJUgVlcnJvchIXCgdydWxlX2lkGAMgASgJUgZydWxlSWQ=');

@$core.Deprecated('Use addGlobalRuleRequestDescriptor instead')
const AddGlobalRuleRequest$json = {
  '1': 'AddGlobalRuleRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'ip', '3': 2, '4': 1, '5': 9, '10': 'ip'},
    {
      '1': 'action',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.nitella.ActionType',
      '10': 'action'
    },
    {'1': 'duration_seconds', '3': 4, '4': 1, '5': 3, '10': 'durationSeconds'},
  ],
};

/// Descriptor for `AddGlobalRuleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addGlobalRuleRequestDescriptor = $convert.base64Decode(
    'ChRBZGRHbG9iYWxSdWxlUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSDgoCaXAYAi'
    'ABKAlSAmlwEisKBmFjdGlvbhgDIAEoDjITLm5pdGVsbGEuQWN0aW9uVHlwZVIGYWN0aW9uEikK'
    'EGR1cmF0aW9uX3NlY29uZHMYBCABKANSD2R1cmF0aW9uU2Vjb25kcw==');

@$core.Deprecated('Use addGlobalRuleResponseDescriptor instead')
const AddGlobalRuleResponse$json = {
  '1': 'AddGlobalRuleResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'rule_id', '3': 3, '4': 1, '5': 9, '10': 'ruleId'},
  ],
};

/// Descriptor for `AddGlobalRuleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addGlobalRuleResponseDescriptor = $convert.base64Decode(
    'ChVBZGRHbG9iYWxSdWxlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIUCgVlcn'
    'JvchgCIAEoCVIFZXJyb3ISFwoHcnVsZV9pZBgDIAEoCVIGcnVsZUlk');

@$core.Deprecated('Use listGlobalRulesRequestDescriptor instead')
const ListGlobalRulesRequest$json = {
  '1': 'ListGlobalRulesRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `ListGlobalRulesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listGlobalRulesRequestDescriptor =
    $convert.base64Decode(
        'ChZMaXN0R2xvYmFsUnVsZXNSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZA==');

@$core.Deprecated('Use listGlobalRulesResponseDescriptor instead')
const ListGlobalRulesResponse$json = {
  '1': 'ListGlobalRulesResponse',
  '2': [
    {
      '1': 'rules',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.proxy.GlobalRule',
      '10': 'rules'
    },
  ],
};

/// Descriptor for `ListGlobalRulesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listGlobalRulesResponseDescriptor =
    $convert.base64Decode(
        'ChdMaXN0R2xvYmFsUnVsZXNSZXNwb25zZRIvCgVydWxlcxgBIAMoCzIZLm5pdGVsbGEucHJveH'
        'kuR2xvYmFsUnVsZVIFcnVsZXM=');

@$core.Deprecated('Use removeGlobalRuleRequestDescriptor instead')
const RemoveGlobalRuleRequest$json = {
  '1': 'RemoveGlobalRuleRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'rule_id', '3': 2, '4': 1, '5': 9, '10': 'ruleId'},
  ],
};

/// Descriptor for `RemoveGlobalRuleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeGlobalRuleRequestDescriptor =
    $convert.base64Decode(
        'ChdSZW1vdmVHbG9iYWxSdWxlUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSFwoHcn'
        'VsZV9pZBgCIAEoCVIGcnVsZUlk');

@$core.Deprecated('Use removeGlobalRuleResponseDescriptor instead')
const RemoveGlobalRuleResponse$json = {
  '1': 'RemoveGlobalRuleResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `RemoveGlobalRuleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeGlobalRuleResponseDescriptor =
    $convert.base64Decode(
        'ChhSZW1vdmVHbG9iYWxSdWxlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIUCg'
        'VlcnJvchgCIAEoCVIFZXJyb3I=');

@$core.Deprecated('Use approvalRequestDescriptor instead')
const ApprovalRequest$json = {
  '1': 'ApprovalRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'node_name', '3': 3, '4': 1, '5': 9, '10': 'nodeName'},
    {'1': 'proxy_id', '3': 4, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'proxy_name', '3': 5, '4': 1, '5': 9, '10': 'proxyName'},
    {'1': 'source_ip', '3': 6, '4': 1, '5': 9, '10': 'sourceIp'},
    {'1': 'source_port', '3': 7, '4': 1, '5': 5, '10': 'sourcePort'},
    {'1': 'dest_addr', '3': 8, '4': 1, '5': 9, '10': 'destAddr'},
    {'1': 'rule_id', '3': 9, '4': 1, '5': 9, '10': 'ruleId'},
    {'1': 'rule_name', '3': 10, '4': 1, '5': 9, '10': 'ruleName'},
    {
      '1': 'geo',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.nitella.GeoInfo',
      '10': 'geo'
    },
    {
      '1': 'timestamp',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'tls_cn', '3': 13, '4': 1, '5': 9, '10': 'tlsCn'},
    {'1': 'tls_fingerprint', '3': 14, '4': 1, '5': 9, '10': 'tlsFingerprint'},
  ],
};

/// Descriptor for `ApprovalRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approvalRequestDescriptor = $convert.base64Decode(
    'Cg9BcHByb3ZhbFJlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoCVIJcmVxdWVzdElkEhcKB25vZG'
    'VfaWQYAiABKAlSBm5vZGVJZBIbCglub2RlX25hbWUYAyABKAlSCG5vZGVOYW1lEhkKCHByb3h5'
    'X2lkGAQgASgJUgdwcm94eUlkEh0KCnByb3h5X25hbWUYBSABKAlSCXByb3h5TmFtZRIbCglzb3'
    'VyY2VfaXAYBiABKAlSCHNvdXJjZUlwEh8KC3NvdXJjZV9wb3J0GAcgASgFUgpzb3VyY2VQb3J0'
    'EhsKCWRlc3RfYWRkchgIIAEoCVIIZGVzdEFkZHISFwoHcnVsZV9pZBgJIAEoCVIGcnVsZUlkEh'
    'sKCXJ1bGVfbmFtZRgKIAEoCVIIcnVsZU5hbWUSIgoDZ2VvGAsgASgLMhAubml0ZWxsYS5HZW9J'
    'bmZvUgNnZW8SOAoJdGltZXN0YW1wGAwgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcF'
    'IJdGltZXN0YW1wEhUKBnRsc19jbhgNIAEoCVIFdGxzQ24SJwoPdGxzX2ZpbmdlcnByaW50GA4g'
    'ASgJUg50bHNGaW5nZXJwcmludA==');

@$core.Deprecated('Use listPendingApprovalsRequestDescriptor instead')
const ListPendingApprovalsRequest$json = {
  '1': 'ListPendingApprovalsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `ListPendingApprovalsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPendingApprovalsRequestDescriptor =
    $convert.base64Decode(
        'ChtMaXN0UGVuZGluZ0FwcHJvdmFsc1JlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlk');

@$core.Deprecated('Use listPendingApprovalsResponseDescriptor instead')
const ListPendingApprovalsResponse$json = {
  '1': 'ListPendingApprovalsResponse',
  '2': [
    {
      '1': 'requests',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.ApprovalRequest',
      '10': 'requests'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListPendingApprovalsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPendingApprovalsResponseDescriptor =
    $convert.base64Decode(
        'ChxMaXN0UGVuZGluZ0FwcHJvdmFsc1Jlc3BvbnNlEjoKCHJlcXVlc3RzGAEgAygLMh4ubml0ZW'
        'xsYS5sb2NhbC5BcHByb3ZhbFJlcXVlc3RSCHJlcXVlc3RzEh8KC3RvdGFsX2NvdW50GAIgASgF'
        'Ugp0b3RhbENvdW50');

@$core.Deprecated('Use getApprovalsSnapshotRequestDescriptor instead')
const GetApprovalsSnapshotRequest$json = {
  '1': 'GetApprovalsSnapshotRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'history_limit', '3': 2, '4': 1, '5': 5, '10': 'historyLimit'},
    {'1': 'history_offset', '3': 3, '4': 1, '5': 5, '10': 'historyOffset'},
    {'1': 'include_history', '3': 4, '4': 1, '5': 8, '10': 'includeHistory'},
  ],
};

/// Descriptor for `GetApprovalsSnapshotRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getApprovalsSnapshotRequestDescriptor = $convert.base64Decode(
    'ChtHZXRBcHByb3ZhbHNTbmFwc2hvdFJlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlkEi'
    'MKDWhpc3RvcnlfbGltaXQYAiABKAVSDGhpc3RvcnlMaW1pdBIlCg5oaXN0b3J5X29mZnNldBgD'
    'IAEoBVINaGlzdG9yeU9mZnNldBInCg9pbmNsdWRlX2hpc3RvcnkYBCABKAhSDmluY2x1ZGVIaX'
    'N0b3J5');

@$core.Deprecated('Use getApprovalsSnapshotResponseDescriptor instead')
const GetApprovalsSnapshotResponse$json = {
  '1': 'GetApprovalsSnapshotResponse',
  '2': [
    {
      '1': 'pending_requests',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.ApprovalRequest',
      '10': 'pendingRequests'
    },
    {
      '1': 'pending_total_count',
      '3': 2,
      '4': 1,
      '5': 5,
      '10': 'pendingTotalCount'
    },
    {
      '1': 'history_entries',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.ApprovalHistoryEntry',
      '10': 'historyEntries'
    },
    {
      '1': 'history_total_count',
      '3': 4,
      '4': 1,
      '5': 5,
      '10': 'historyTotalCount'
    },
    {
      '1': 'approve_duration_options',
      '3': 5,
      '4': 3,
      '5': 3,
      '10': 'approveDurationOptions'
    },
    {
      '1': 'default_approve_duration_seconds',
      '3': 6,
      '4': 1,
      '5': 3,
      '10': 'defaultApproveDurationSeconds'
    },
    {
      '1': 'deny_block_options',
      '3': 7,
      '4': 3,
      '5': 14,
      '6': '.nitella.local.DenyBlockType',
      '10': 'denyBlockOptions'
    },
    {
      '1': 'recommended_poll_interval_seconds',
      '3': 8,
      '4': 1,
      '5': 5,
      '10': 'recommendedPollIntervalSeconds'
    },
  ],
};

/// Descriptor for `GetApprovalsSnapshotResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getApprovalsSnapshotResponseDescriptor = $convert.base64Decode(
    'ChxHZXRBcHByb3ZhbHNTbmFwc2hvdFJlc3BvbnNlEkkKEHBlbmRpbmdfcmVxdWVzdHMYASADKA'
    'syHi5uaXRlbGxhLmxvY2FsLkFwcHJvdmFsUmVxdWVzdFIPcGVuZGluZ1JlcXVlc3RzEi4KE3Bl'
    'bmRpbmdfdG90YWxfY291bnQYAiABKAVSEXBlbmRpbmdUb3RhbENvdW50EkwKD2hpc3RvcnlfZW'
    '50cmllcxgDIAMoCzIjLm5pdGVsbGEubG9jYWwuQXBwcm92YWxIaXN0b3J5RW50cnlSDmhpc3Rv'
    'cnlFbnRyaWVzEi4KE2hpc3RvcnlfdG90YWxfY291bnQYBCABKAVSEWhpc3RvcnlUb3RhbENvdW'
    '50EjgKGGFwcHJvdmVfZHVyYXRpb25fb3B0aW9ucxgFIAMoA1IWYXBwcm92ZUR1cmF0aW9uT3B0'
    'aW9ucxJHCiBkZWZhdWx0X2FwcHJvdmVfZHVyYXRpb25fc2Vjb25kcxgGIAEoA1IdZGVmYXVsdE'
    'FwcHJvdmVEdXJhdGlvblNlY29uZHMSSgoSZGVueV9ibG9ja19vcHRpb25zGAcgAygOMhwubml0'
    'ZWxsYS5sb2NhbC5EZW55QmxvY2tUeXBlUhBkZW55QmxvY2tPcHRpb25zEkkKIXJlY29tbWVuZG'
    'VkX3BvbGxfaW50ZXJ2YWxfc2Vjb25kcxgIIAEoBVIecmVjb21tZW5kZWRQb2xsSW50ZXJ2YWxT'
    'ZWNvbmRz');

@$core.Deprecated('Use approveRequestRequestDescriptor instead')
const ApproveRequestRequest$json = {
  '1': 'ApproveRequestRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'retention_mode',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.nitella.ApprovalRetentionMode',
      '10': 'retentionMode'
    },
    {'1': 'duration_seconds', '3': 3, '4': 1, '5': 3, '10': 'durationSeconds'},
    {'1': 'create_rule', '3': 4, '4': 1, '5': 8, '10': 'createRule'},
  ],
};

/// Descriptor for `ApproveRequestRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approveRequestRequestDescriptor = $convert.base64Decode(
    'ChVBcHByb3ZlUmVxdWVzdFJlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoCVIJcmVxdWVzdElkEk'
    'UKDnJldGVudGlvbl9tb2RlGAIgASgOMh4ubml0ZWxsYS5BcHByb3ZhbFJldGVudGlvbk1vZGVS'
    'DXJldGVudGlvbk1vZGUSKQoQZHVyYXRpb25fc2Vjb25kcxgDIAEoA1IPZHVyYXRpb25TZWNvbm'
    'RzEh8KC2NyZWF0ZV9ydWxlGAQgASgIUgpjcmVhdGVSdWxl');

@$core.Deprecated('Use approveRequestResponseDescriptor instead')
const ApproveRequestResponse$json = {
  '1': 'ApproveRequestResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'rule_id', '3': 3, '4': 1, '5': 9, '10': 'ruleId'},
    {'1': 'decision_applied', '3': 4, '4': 1, '5': 8, '10': 'decisionApplied'},
    {
      '1': 'history_persisted',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'historyPersisted'
    },
    {'1': 'history_error', '3': 6, '4': 1, '5': 9, '10': 'historyError'},
  ],
};

/// Descriptor for `ApproveRequestResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approveRequestResponseDescriptor = $convert.base64Decode(
    'ChZBcHByb3ZlUmVxdWVzdFJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSFAoFZX'
    'Jyb3IYAiABKAlSBWVycm9yEhcKB3J1bGVfaWQYAyABKAlSBnJ1bGVJZBIpChBkZWNpc2lvbl9h'
    'cHBsaWVkGAQgASgIUg9kZWNpc2lvbkFwcGxpZWQSKwoRaGlzdG9yeV9wZXJzaXN0ZWQYBSABKA'
    'hSEGhpc3RvcnlQZXJzaXN0ZWQSIwoNaGlzdG9yeV9lcnJvchgGIAEoCVIMaGlzdG9yeUVycm9y');

@$core.Deprecated('Use denyRequestRequestDescriptor instead')
const DenyRequestRequest$json = {
  '1': 'DenyRequestRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'retention_mode',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.nitella.ApprovalRetentionMode',
      '10': 'retentionMode'
    },
    {'1': 'duration_seconds', '3': 3, '4': 1, '5': 3, '10': 'durationSeconds'},
    {
      '1': 'block_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.DenyBlockType',
      '10': 'blockType'
    },
  ],
};

/// Descriptor for `DenyRequestRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List denyRequestRequestDescriptor = $convert.base64Decode(
    'ChJEZW55UmVxdWVzdFJlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoCVIJcmVxdWVzdElkEkUKDn'
    'JldGVudGlvbl9tb2RlGAIgASgOMh4ubml0ZWxsYS5BcHByb3ZhbFJldGVudGlvbk1vZGVSDXJl'
    'dGVudGlvbk1vZGUSKQoQZHVyYXRpb25fc2Vjb25kcxgDIAEoA1IPZHVyYXRpb25TZWNvbmRzEj'
    'sKCmJsb2NrX3R5cGUYBCABKA4yHC5uaXRlbGxhLmxvY2FsLkRlbnlCbG9ja1R5cGVSCWJsb2Nr'
    'VHlwZQ==');

@$core.Deprecated('Use denyRequestResponseDescriptor instead')
const DenyRequestResponse$json = {
  '1': 'DenyRequestResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'rule_id', '3': 3, '4': 1, '5': 9, '10': 'ruleId'},
    {'1': 'decision_applied', '3': 4, '4': 1, '5': 8, '10': 'decisionApplied'},
    {
      '1': 'history_persisted',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'historyPersisted'
    },
    {'1': 'history_error', '3': 6, '4': 1, '5': 9, '10': 'historyError'},
  ],
};

/// Descriptor for `DenyRequestResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List denyRequestResponseDescriptor = $convert.base64Decode(
    'ChNEZW55UmVxdWVzdFJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSFAoFZXJyb3'
    'IYAiABKAlSBWVycm9yEhcKB3J1bGVfaWQYAyABKAlSBnJ1bGVJZBIpChBkZWNpc2lvbl9hcHBs'
    'aWVkGAQgASgIUg9kZWNpc2lvbkFwcGxpZWQSKwoRaGlzdG9yeV9wZXJzaXN0ZWQYBSABKAhSEG'
    'hpc3RvcnlQZXJzaXN0ZWQSIwoNaGlzdG9yeV9lcnJvchgGIAEoCVIMaGlzdG9yeUVycm9y');

@$core.Deprecated('Use resolveApprovalDecisionRequestDescriptor instead')
const ResolveApprovalDecisionRequest$json = {
  '1': 'ResolveApprovalDecisionRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'decision',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.ApprovalDecision',
      '10': 'decision'
    },
    {
      '1': 'retention_mode',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.nitella.ApprovalRetentionMode',
      '10': 'retentionMode'
    },
    {'1': 'duration_seconds', '3': 4, '4': 1, '5': 3, '10': 'durationSeconds'},
    {
      '1': 'deny_block_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.DenyBlockType',
      '10': 'denyBlockType'
    },
  ],
};

/// Descriptor for `ResolveApprovalDecisionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolveApprovalDecisionRequestDescriptor = $convert.base64Decode(
    'Ch5SZXNvbHZlQXBwcm92YWxEZWNpc2lvblJlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoCVIJcm'
    'VxdWVzdElkEjsKCGRlY2lzaW9uGAIgASgOMh8ubml0ZWxsYS5sb2NhbC5BcHByb3ZhbERlY2lz'
    'aW9uUghkZWNpc2lvbhJFCg5yZXRlbnRpb25fbW9kZRgDIAEoDjIeLm5pdGVsbGEuQXBwcm92YW'
    'xSZXRlbnRpb25Nb2RlUg1yZXRlbnRpb25Nb2RlEikKEGR1cmF0aW9uX3NlY29uZHMYBCABKANS'
    'D2R1cmF0aW9uU2Vjb25kcxJECg9kZW55X2Jsb2NrX3R5cGUYBSABKA4yHC5uaXRlbGxhLmxvY2'
    'FsLkRlbnlCbG9ja1R5cGVSDWRlbnlCbG9ja1R5cGU=');

@$core.Deprecated('Use resolveApprovalDecisionResponseDescriptor instead')
const ResolveApprovalDecisionResponse$json = {
  '1': 'ResolveApprovalDecisionResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'rule_id', '3': 3, '4': 1, '5': 9, '10': 'ruleId'},
    {'1': 'decision_applied', '3': 4, '4': 1, '5': 8, '10': 'decisionApplied'},
    {
      '1': 'history_persisted',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'historyPersisted'
    },
    {'1': 'history_error', '3': 6, '4': 1, '5': 9, '10': 'historyError'},
  ],
};

/// Descriptor for `ResolveApprovalDecisionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolveApprovalDecisionResponseDescriptor = $convert.base64Decode(
    'Ch9SZXNvbHZlQXBwcm92YWxEZWNpc2lvblJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2'
    'Nlc3MSFAoFZXJyb3IYAiABKAlSBWVycm9yEhcKB3J1bGVfaWQYAyABKAlSBnJ1bGVJZBIpChBk'
    'ZWNpc2lvbl9hcHBsaWVkGAQgASgIUg9kZWNpc2lvbkFwcGxpZWQSKwoRaGlzdG9yeV9wZXJzaX'
    'N0ZWQYBSABKAhSEGhpc3RvcnlQZXJzaXN0ZWQSIwoNaGlzdG9yeV9lcnJvchgGIAEoCVIMaGlz'
    'dG9yeUVycm9y');

@$core.Deprecated('Use streamApprovalsRequestDescriptor instead')
const StreamApprovalsRequest$json = {
  '1': 'StreamApprovalsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `StreamApprovalsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamApprovalsRequestDescriptor =
    $convert.base64Decode(
        'ChZTdHJlYW1BcHByb3ZhbHNSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZA==');

@$core.Deprecated('Use approvalHistoryEntryDescriptor instead')
const ApprovalHistoryEntry$json = {
  '1': 'ApprovalHistoryEntry',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'node_name', '3': 3, '4': 1, '5': 9, '10': 'nodeName'},
    {'1': 'proxy_id', '3': 4, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'proxy_name', '3': 5, '4': 1, '5': 9, '10': 'proxyName'},
    {'1': 'source_ip', '3': 6, '4': 1, '5': 9, '10': 'sourceIp'},
    {'1': 'dest_addr', '3': 7, '4': 1, '5': 9, '10': 'destAddr'},
    {'1': 'geo', '3': 8, '4': 1, '5': 11, '6': '.nitella.GeoInfo', '10': 'geo'},
    {
      '1': 'action',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.ApprovalHistoryAction',
      '10': 'action'
    },
    {'1': 'duration_seconds', '3': 10, '4': 1, '5': 3, '10': 'durationSeconds'},
    {
      '1': 'block_type',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.DenyBlockType',
      '10': 'blockType'
    },
    {'1': 'rule_id', '3': 12, '4': 1, '5': 9, '10': 'ruleId'},
    {
      '1': 'decided_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'decidedAt'
    },
  ],
};

/// Descriptor for `ApprovalHistoryEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approvalHistoryEntryDescriptor = $convert.base64Decode(
    'ChRBcHByb3ZhbEhpc3RvcnlFbnRyeRIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZXF1ZXN0SWQSFw'
    'oHbm9kZV9pZBgCIAEoCVIGbm9kZUlkEhsKCW5vZGVfbmFtZRgDIAEoCVIIbm9kZU5hbWUSGQoI'
    'cHJveHlfaWQYBCABKAlSB3Byb3h5SWQSHQoKcHJveHlfbmFtZRgFIAEoCVIJcHJveHlOYW1lEh'
    'sKCXNvdXJjZV9pcBgGIAEoCVIIc291cmNlSXASGwoJZGVzdF9hZGRyGAcgASgJUghkZXN0QWRk'
    'chIiCgNnZW8YCCABKAsyEC5uaXRlbGxhLkdlb0luZm9SA2dlbxI8CgZhY3Rpb24YCSABKA4yJC'
    '5uaXRlbGxhLmxvY2FsLkFwcHJvdmFsSGlzdG9yeUFjdGlvblIGYWN0aW9uEikKEGR1cmF0aW9u'
    'X3NlY29uZHMYCiABKANSD2R1cmF0aW9uU2Vjb25kcxI7CgpibG9ja190eXBlGAsgASgOMhwubm'
    'l0ZWxsYS5sb2NhbC5EZW55QmxvY2tUeXBlUglibG9ja1R5cGUSFwoHcnVsZV9pZBgMIAEoCVIG'
    'cnVsZUlkEjkKCmRlY2lkZWRfYXQYDSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUg'
    'lkZWNpZGVkQXQ=');

@$core.Deprecated('Use listApprovalHistoryRequestDescriptor instead')
const ListApprovalHistoryRequest$json = {
  '1': 'ListApprovalHistoryRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'offset', '3': 3, '4': 1, '5': 5, '10': 'offset'},
  ],
};

/// Descriptor for `ListApprovalHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listApprovalHistoryRequestDescriptor =
    $convert.base64Decode(
        'ChpMaXN0QXBwcm92YWxIaXN0b3J5UmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSFA'
        'oFbGltaXQYAiABKAVSBWxpbWl0EhYKBm9mZnNldBgDIAEoBVIGb2Zmc2V0');

@$core.Deprecated('Use listApprovalHistoryResponseDescriptor instead')
const ListApprovalHistoryResponse$json = {
  '1': 'ListApprovalHistoryResponse',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.ApprovalHistoryEntry',
      '10': 'entries'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListApprovalHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listApprovalHistoryResponseDescriptor =
    $convert.base64Decode(
        'ChtMaXN0QXBwcm92YWxIaXN0b3J5UmVzcG9uc2USPQoHZW50cmllcxgBIAMoCzIjLm5pdGVsbG'
        'EubG9jYWwuQXBwcm92YWxIaXN0b3J5RW50cnlSB2VudHJpZXMSHwoLdG90YWxfY291bnQYAiAB'
        'KAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use clearApprovalHistoryRequestDescriptor instead')
const ClearApprovalHistoryRequest$json = {
  '1': 'ClearApprovalHistoryRequest',
};

/// Descriptor for `ClearApprovalHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clearApprovalHistoryRequestDescriptor =
    $convert.base64Decode('ChtDbGVhckFwcHJvdmFsSGlzdG9yeVJlcXVlc3Q=');

@$core.Deprecated('Use clearApprovalHistoryResponseDescriptor instead')
const ClearApprovalHistoryResponse$json = {
  '1': 'ClearApprovalHistoryResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'deleted_count', '3': 3, '4': 1, '5': 5, '10': 'deletedCount'},
  ],
};

/// Descriptor for `ClearApprovalHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clearApprovalHistoryResponseDescriptor =
    $convert.base64Decode(
        'ChxDbGVhckFwcHJvdmFsSGlzdG9yeVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3'
        'MSFAoFZXJyb3IYAiABKAlSBWVycm9yEiMKDWRlbGV0ZWRfY291bnQYAyABKAVSDGRlbGV0ZWRD'
        'b3VudA==');

@$core.Deprecated('Use connectionStatsDescriptor instead')
const ConnectionStats$json = {
  '1': 'ConnectionStats',
  '2': [
    {
      '1': 'active_connections',
      '3': 1,
      '4': 1,
      '5': 3,
      '10': 'activeConnections'
    },
    {
      '1': 'total_connections',
      '3': 2,
      '4': 1,
      '5': 3,
      '10': 'totalConnections'
    },
    {'1': 'bytes_in', '3': 3, '4': 1, '5': 3, '10': 'bytesIn'},
    {'1': 'bytes_out', '3': 4, '4': 1, '5': 3, '10': 'bytesOut'},
    {'1': 'blocked_total', '3': 5, '4': 1, '5': 3, '10': 'blockedTotal'},
    {'1': 'allowed_total', '3': 6, '4': 1, '5': 3, '10': 'allowedTotal'},
    {'1': 'unique_ips', '3': 7, '4': 1, '5': 3, '10': 'uniqueIps'},
    {'1': 'unique_countries', '3': 8, '4': 1, '5': 3, '10': 'uniqueCountries'},
    {
      '1': 'pending_approvals',
      '3': 9,
      '4': 1,
      '5': 3,
      '10': 'pendingApprovals'
    },
    {
      '1': 'recommended_poll_interval_seconds',
      '3': 10,
      '4': 1,
      '5': 5,
      '10': 'recommendedPollIntervalSeconds'
    },
  ],
};

/// Descriptor for `ConnectionStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectionStatsDescriptor = $convert.base64Decode(
    'Cg9Db25uZWN0aW9uU3RhdHMSLQoSYWN0aXZlX2Nvbm5lY3Rpb25zGAEgASgDUhFhY3RpdmVDb2'
    '5uZWN0aW9ucxIrChF0b3RhbF9jb25uZWN0aW9ucxgCIAEoA1IQdG90YWxDb25uZWN0aW9ucxIZ'
    'CghieXRlc19pbhgDIAEoA1IHYnl0ZXNJbhIbCglieXRlc19vdXQYBCABKANSCGJ5dGVzT3V0Ei'
    'MKDWJsb2NrZWRfdG90YWwYBSABKANSDGJsb2NrZWRUb3RhbBIjCg1hbGxvd2VkX3RvdGFsGAYg'
    'ASgDUgxhbGxvd2VkVG90YWwSHQoKdW5pcXVlX2lwcxgHIAEoA1IJdW5pcXVlSXBzEikKEHVuaX'
    'F1ZV9jb3VudHJpZXMYCCABKANSD3VuaXF1ZUNvdW50cmllcxIrChFwZW5kaW5nX2FwcHJvdmFs'
    'cxgJIAEoA1IQcGVuZGluZ0FwcHJvdmFscxJJCiFyZWNvbW1lbmRlZF9wb2xsX2ludGVydmFsX3'
    'NlY29uZHMYCiABKAVSHnJlY29tbWVuZGVkUG9sbEludGVydmFsU2Vjb25kcw==');

@$core.Deprecated('Use getConnectionStatsRequestDescriptor instead')
const GetConnectionStatsRequest$json = {
  '1': 'GetConnectionStatsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `GetConnectionStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getConnectionStatsRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRDb25uZWN0aW9uU3RhdHNSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBIZCg'
        'hwcm94eV9pZBgCIAEoCVIHcHJveHlJZA==');

@$core.Deprecated('Use connectionInfoDescriptor instead')
const ConnectionInfo$json = {
  '1': 'ConnectionInfo',
  '2': [
    {'1': 'conn_id', '3': 1, '4': 1, '5': 9, '10': 'connId'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 3, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'source_ip', '3': 4, '4': 1, '5': 9, '10': 'sourceIp'},
    {'1': 'source_port', '3': 5, '4': 1, '5': 5, '10': 'sourcePort'},
    {'1': 'dest_addr', '3': 6, '4': 1, '5': 9, '10': 'destAddr'},
    {
      '1': 'start_time',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startTime'
    },
    {'1': 'bytes_in', '3': 8, '4': 1, '5': 3, '10': 'bytesIn'},
    {'1': 'bytes_out', '3': 9, '4': 1, '5': 3, '10': 'bytesOut'},
    {
      '1': 'geo',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.nitella.GeoInfo',
      '10': 'geo'
    },
    {'1': 'rule_matched', '3': 11, '4': 1, '5': 9, '10': 'ruleMatched'},
    {
      '1': 'action',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.nitella.ActionType',
      '10': 'action'
    },
  ],
};

/// Descriptor for `ConnectionInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectionInfoDescriptor = $convert.base64Decode(
    'Cg5Db25uZWN0aW9uSW5mbxIXCgdjb25uX2lkGAEgASgJUgZjb25uSWQSFwoHbm9kZV9pZBgCIA'
    'EoCVIGbm9kZUlkEhkKCHByb3h5X2lkGAMgASgJUgdwcm94eUlkEhsKCXNvdXJjZV9pcBgEIAEo'
    'CVIIc291cmNlSXASHwoLc291cmNlX3BvcnQYBSABKAVSCnNvdXJjZVBvcnQSGwoJZGVzdF9hZG'
    'RyGAYgASgJUghkZXN0QWRkchI5CgpzdGFydF90aW1lGAcgASgLMhouZ29vZ2xlLnByb3RvYnVm'
    'LlRpbWVzdGFtcFIJc3RhcnRUaW1lEhkKCGJ5dGVzX2luGAggASgDUgdieXRlc0luEhsKCWJ5dG'
    'VzX291dBgJIAEoA1IIYnl0ZXNPdXQSIgoDZ2VvGAogASgLMhAubml0ZWxsYS5HZW9JbmZvUgNn'
    'ZW8SIQoMcnVsZV9tYXRjaGVkGAsgASgJUgtydWxlTWF0Y2hlZBIrCgZhY3Rpb24YDCABKA4yEy'
    '5uaXRlbGxhLkFjdGlvblR5cGVSBmFjdGlvbg==');

@$core.Deprecated('Use listConnectionsRequestDescriptor instead')
const ListConnectionsRequest$json = {
  '1': 'ListConnectionsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'active_only', '3': 3, '4': 1, '5': 8, '10': 'activeOnly'},
    {'1': 'limit', '3': 4, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'offset', '3': 5, '4': 1, '5': 5, '10': 'offset'},
  ],
};

/// Descriptor for `ListConnectionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listConnectionsRequestDescriptor = $convert.base64Decode(
    'ChZMaXN0Q29ubmVjdGlvbnNSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBIZCghwcm'
    '94eV9pZBgCIAEoCVIHcHJveHlJZBIfCgthY3RpdmVfb25seRgDIAEoCFIKYWN0aXZlT25seRIU'
    'CgVsaW1pdBgEIAEoBVIFbGltaXQSFgoGb2Zmc2V0GAUgASgFUgZvZmZzZXQ=');

@$core.Deprecated('Use listConnectionsResponseDescriptor instead')
const ListConnectionsResponse$json = {
  '1': 'ListConnectionsResponse',
  '2': [
    {
      '1': 'connections',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.ConnectionInfo',
      '10': 'connections'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListConnectionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listConnectionsResponseDescriptor = $convert.base64Decode(
    'ChdMaXN0Q29ubmVjdGlvbnNSZXNwb25zZRI/Cgtjb25uZWN0aW9ucxgBIAMoCzIdLm5pdGVsbG'
    'EubG9jYWwuQ29ubmVjdGlvbkluZm9SC2Nvbm5lY3Rpb25zEh8KC3RvdGFsX2NvdW50GAIgASgF'
    'Ugp0b3RhbENvdW50');

@$core.Deprecated('Use getIPStatsRequestDescriptor instead')
const GetIPStatsRequest$json = {
  '1': 'GetIPStatsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'offset', '3': 3, '4': 1, '5': 5, '10': 'offset'},
    {'1': 'source_ip_filter', '3': 4, '4': 1, '5': 9, '10': 'sourceIpFilter'},
    {'1': 'country_filter', '3': 5, '4': 1, '5': 9, '10': 'countryFilter'},
    {
      '1': 'sort_by',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.nitella.SortOrder',
      '10': 'sortBy'
    },
  ],
};

/// Descriptor for `GetIPStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getIPStatsRequestDescriptor = $convert.base64Decode(
    'ChFHZXRJUFN0YXRzUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSFAoFbGltaXQYAi'
    'ABKAVSBWxpbWl0EhYKBm9mZnNldBgDIAEoBVIGb2Zmc2V0EigKEHNvdXJjZV9pcF9maWx0ZXIY'
    'BCABKAlSDnNvdXJjZUlwRmlsdGVyEiUKDmNvdW50cnlfZmlsdGVyGAUgASgJUg1jb3VudHJ5Rm'
    'lsdGVyEisKB3NvcnRfYnkYBiABKA4yEi5uaXRlbGxhLlNvcnRPcmRlclIGc29ydEJ5');

@$core.Deprecated('Use iPStatsDescriptor instead')
const IPStats$json = {
  '1': 'IPStats',
  '2': [
    {'1': 'source_ip', '3': 1, '4': 1, '5': 9, '10': 'sourceIp'},
    {
      '1': 'first_seen',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'firstSeen'
    },
    {
      '1': 'last_seen',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastSeen'
    },
    {'1': 'connection_count', '3': 4, '4': 1, '5': 3, '10': 'connectionCount'},
    {'1': 'total_bytes_in', '3': 5, '4': 1, '5': 3, '10': 'totalBytesIn'},
    {'1': 'total_bytes_out', '3': 6, '4': 1, '5': 3, '10': 'totalBytesOut'},
    {'1': 'blocked_count', '3': 7, '4': 1, '5': 3, '10': 'blockedCount'},
    {'1': 'allowed_count', '3': 8, '4': 1, '5': 3, '10': 'allowedCount'},
    {'1': 'geo_country', '3': 9, '4': 1, '5': 9, '10': 'geoCountry'},
    {'1': 'geo_city', '3': 10, '4': 1, '5': 9, '10': 'geoCity'},
    {'1': 'geo_isp', '3': 11, '4': 1, '5': 9, '10': 'geoIsp'},
  ],
};

/// Descriptor for `IPStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List iPStatsDescriptor = $convert.base64Decode(
    'CgdJUFN0YXRzEhsKCXNvdXJjZV9pcBgBIAEoCVIIc291cmNlSXASOQoKZmlyc3Rfc2VlbhgCIA'
    'EoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWZpcnN0U2VlbhI3CglsYXN0X3NlZW4Y'
    'AyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUghsYXN0U2VlbhIpChBjb25uZWN0aW'
    '9uX2NvdW50GAQgASgDUg9jb25uZWN0aW9uQ291bnQSJAoOdG90YWxfYnl0ZXNfaW4YBSABKANS'
    'DHRvdGFsQnl0ZXNJbhImCg90b3RhbF9ieXRlc19vdXQYBiABKANSDXRvdGFsQnl0ZXNPdXQSIw'
    'oNYmxvY2tlZF9jb3VudBgHIAEoA1IMYmxvY2tlZENvdW50EiMKDWFsbG93ZWRfY291bnQYCCAB'
    'KANSDGFsbG93ZWRDb3VudBIfCgtnZW9fY291bnRyeRgJIAEoCVIKZ2VvQ291bnRyeRIZCghnZW'
    '9fY2l0eRgKIAEoCVIHZ2VvQ2l0eRIXCgdnZW9faXNwGAsgASgJUgZnZW9Jc3A=');

@$core.Deprecated('Use getIPStatsResponseDescriptor instead')
const GetIPStatsResponse$json = {
  '1': 'GetIPStatsResponse',
  '2': [
    {
      '1': 'stats',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.IPStats',
      '10': 'stats'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 3, '10': 'totalCount'},
  ],
};

/// Descriptor for `GetIPStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getIPStatsResponseDescriptor = $convert.base64Decode(
    'ChJHZXRJUFN0YXRzUmVzcG9uc2USLAoFc3RhdHMYASADKAsyFi5uaXRlbGxhLmxvY2FsLklQU3'
    'RhdHNSBXN0YXRzEh8KC3RvdGFsX2NvdW50GAIgASgDUgp0b3RhbENvdW50');

@$core.Deprecated('Use getGeoStatsRequestDescriptor instead')
const GetGeoStatsRequest$json = {
  '1': 'GetGeoStatsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.GeoStatsType',
      '10': 'type'
    },
    {'1': 'limit', '3': 3, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `GetGeoStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGeoStatsRequestDescriptor = $convert.base64Decode(
    'ChJHZXRHZW9TdGF0c1JlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlkEi8KBHR5cGUYAi'
    'ABKA4yGy5uaXRlbGxhLmxvY2FsLkdlb1N0YXRzVHlwZVIEdHlwZRIUCgVsaW1pdBgDIAEoBVIF'
    'bGltaXQ=');

@$core.Deprecated('Use geoStatsDescriptor instead')
const GeoStats$json = {
  '1': 'GeoStats',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.GeoStatsType',
      '10': 'type'
    },
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
    {'1': 'connection_count', '3': 3, '4': 1, '5': 3, '10': 'connectionCount'},
    {'1': 'unique_ips', '3': 4, '4': 1, '5': 3, '10': 'uniqueIps'},
    {'1': 'total_bytes', '3': 5, '4': 1, '5': 3, '10': 'totalBytes'},
    {'1': 'blocked_count', '3': 6, '4': 1, '5': 3, '10': 'blockedCount'},
  ],
};

/// Descriptor for `GeoStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List geoStatsDescriptor = $convert.base64Decode(
    'CghHZW9TdGF0cxIvCgR0eXBlGAEgASgOMhsubml0ZWxsYS5sb2NhbC5HZW9TdGF0c1R5cGVSBH'
    'R5cGUSFAoFdmFsdWUYAiABKAlSBXZhbHVlEikKEGNvbm5lY3Rpb25fY291bnQYAyABKANSD2Nv'
    'bm5lY3Rpb25Db3VudBIdCgp1bmlxdWVfaXBzGAQgASgDUgl1bmlxdWVJcHMSHwoLdG90YWxfYn'
    'l0ZXMYBSABKANSCnRvdGFsQnl0ZXMSIwoNYmxvY2tlZF9jb3VudBgGIAEoA1IMYmxvY2tlZENv'
    'dW50');

@$core.Deprecated('Use getGeoStatsResponseDescriptor instead')
const GetGeoStatsResponse$json = {
  '1': 'GetGeoStatsResponse',
  '2': [
    {
      '1': 'stats',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.GeoStats',
      '10': 'stats'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `GetGeoStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGeoStatsResponseDescriptor = $convert.base64Decode(
    'ChNHZXRHZW9TdGF0c1Jlc3BvbnNlEi0KBXN0YXRzGAEgAygLMhcubml0ZWxsYS5sb2NhbC5HZW'
    '9TdGF0c1IFc3RhdHMSHwoLdG90YWxfY291bnQYAiABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use streamConnectionsRequestDescriptor instead')
const StreamConnectionsRequest$json = {
  '1': 'StreamConnectionsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `StreamConnectionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamConnectionsRequestDescriptor =
    $convert.base64Decode(
        'ChhTdHJlYW1Db25uZWN0aW9uc1JlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlkEhkKCH'
        'Byb3h5X2lkGAIgASgJUgdwcm94eUlk');

@$core.Deprecated('Use connectionEventDescriptor instead')
const ConnectionEvent$json = {
  '1': 'ConnectionEvent',
  '2': [
    {'1': 'conn_id', '3': 1, '4': 1, '5': 9, '10': 'connId'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 3, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'source_ip', '3': 4, '4': 1, '5': 9, '10': 'sourceIp'},
    {'1': 'source_port', '3': 5, '4': 1, '5': 5, '10': 'sourcePort'},
    {'1': 'dest_addr', '3': 6, '4': 1, '5': 9, '10': 'destAddr'},
    {
      '1': 'event_type',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.ConnectionEvent.EventType',
      '10': 'eventType'
    },
    {
      '1': 'timestamp',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'rule_matched', '3': 9, '4': 1, '5': 9, '10': 'ruleMatched'},
    {
      '1': 'action_taken',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.nitella.ActionType',
      '10': 'actionTaken'
    },
    {'1': 'bytes_in', '3': 11, '4': 1, '5': 3, '10': 'bytesIn'},
    {'1': 'bytes_out', '3': 12, '4': 1, '5': 3, '10': 'bytesOut'},
    {
      '1': 'geo',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.nitella.GeoInfo',
      '10': 'geo'
    },
  ],
  '4': [ConnectionEvent_EventType$json],
};

@$core.Deprecated('Use connectionEventDescriptor instead')
const ConnectionEvent_EventType$json = {
  '1': 'EventType',
  '2': [
    {'1': 'EVENT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'EVENT_TYPE_CONNECTED', '2': 1},
    {'1': 'EVENT_TYPE_CLOSED', '2': 2},
    {'1': 'EVENT_TYPE_BLOCKED', '2': 3},
    {'1': 'EVENT_TYPE_PENDING_APPROVAL', '2': 4},
    {'1': 'EVENT_TYPE_APPROVED', '2': 5},
  ],
};

/// Descriptor for `ConnectionEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectionEventDescriptor = $convert.base64Decode(
    'Cg9Db25uZWN0aW9uRXZlbnQSFwoHY29ubl9pZBgBIAEoCVIGY29ubklkEhcKB25vZGVfaWQYAi'
    'ABKAlSBm5vZGVJZBIZCghwcm94eV9pZBgDIAEoCVIHcHJveHlJZBIbCglzb3VyY2VfaXAYBCAB'
    'KAlSCHNvdXJjZUlwEh8KC3NvdXJjZV9wb3J0GAUgASgFUgpzb3VyY2VQb3J0EhsKCWRlc3RfYW'
    'RkchgGIAEoCVIIZGVzdEFkZHISRwoKZXZlbnRfdHlwZRgHIAEoDjIoLm5pdGVsbGEubG9jYWwu'
    'Q29ubmVjdGlvbkV2ZW50LkV2ZW50VHlwZVIJZXZlbnRUeXBlEjgKCXRpbWVzdGFtcBgIIAEoCz'
    'IaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcBIhCgxydWxlX21hdGNoZWQY'
    'CSABKAlSC3J1bGVNYXRjaGVkEjYKDGFjdGlvbl90YWtlbhgKIAEoDjITLm5pdGVsbGEuQWN0aW'
    '9uVHlwZVILYWN0aW9uVGFrZW4SGQoIYnl0ZXNfaW4YCyABKANSB2J5dGVzSW4SGwoJYnl0ZXNf'
    'b3V0GAwgASgDUghieXRlc091dBIiCgNnZW8YDSABKAsyEC5uaXRlbGxhLkdlb0luZm9SA2dlby'
    'KqAQoJRXZlbnRUeXBlEhoKFkVWRU5UX1RZUEVfVU5TUEVDSUZJRUQQABIYChRFVkVOVF9UWVBF'
    'X0NPTk5FQ1RFRBABEhUKEUVWRU5UX1RZUEVfQ0xPU0VEEAISFgoSRVZFTlRfVFlQRV9CTE9DS0'
    'VEEAMSHwobRVZFTlRfVFlQRV9QRU5ESU5HX0FQUFJPVkFMEAQSFwoTRVZFTlRfVFlQRV9BUFBS'
    'T1ZFRBAF');

@$core.Deprecated('Use closeConnectionRequestDescriptor instead')
const CloseConnectionRequest$json = {
  '1': 'CloseConnectionRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'conn_id', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'connId'},
    {'1': 'source_ip', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'sourceIp'},
  ],
  '8': [
    {'1': 'identifier'},
  ],
};

/// Descriptor for `CloseConnectionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List closeConnectionRequestDescriptor = $convert.base64Decode(
    'ChZDbG9zZUNvbm5lY3Rpb25SZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBIZCghwcm'
    '94eV9pZBgCIAEoCVIHcHJveHlJZBIZCgdjb25uX2lkGAMgASgJSABSBmNvbm5JZBIdCglzb3Vy'
    'Y2VfaXAYBCABKAlIAFIIc291cmNlSXBCDAoKaWRlbnRpZmllcg==');

@$core.Deprecated('Use closeConnectionResponseDescriptor instead')
const CloseConnectionResponse$json = {
  '1': 'CloseConnectionResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `CloseConnectionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List closeConnectionResponseDescriptor =
    $convert.base64Decode(
        'ChdDbG9zZUNvbm5lY3Rpb25SZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhQKBW'
        'Vycm9yGAIgASgJUgVlcnJvcg==');

@$core.Deprecated('Use closeAllConnectionsRequestDescriptor instead')
const CloseAllConnectionsRequest$json = {
  '1': 'CloseAllConnectionsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `CloseAllConnectionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List closeAllConnectionsRequestDescriptor =
    $convert.base64Decode(
        'ChpDbG9zZUFsbENvbm5lY3Rpb25zUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSGQ'
        'oIcHJveHlfaWQYAiABKAlSB3Byb3h5SWQ=');

@$core.Deprecated('Use closeAllConnectionsResponseDescriptor instead')
const CloseAllConnectionsResponse$json = {
  '1': 'CloseAllConnectionsResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'closed_count', '3': 3, '4': 1, '5': 5, '10': 'closedCount'},
  ],
};

/// Descriptor for `CloseAllConnectionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List closeAllConnectionsResponseDescriptor =
    $convert.base64Decode(
        'ChtDbG9zZUFsbENvbm5lY3Rpb25zUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcx'
        'IUCgVlcnJvchgCIAEoCVIFZXJyb3ISIQoMY2xvc2VkX2NvdW50GAMgASgFUgtjbG9zZWRDb3Vu'
        'dA==');

@$core.Deprecated('Use closeAllNodeConnectionsRequestDescriptor instead')
const CloseAllNodeConnectionsRequest$json = {
  '1': 'CloseAllNodeConnectionsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `CloseAllNodeConnectionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List closeAllNodeConnectionsRequestDescriptor =
    $convert.base64Decode(
        'Ch5DbG9zZUFsbE5vZGVDb25uZWN0aW9uc1JlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZU'
        'lk');

@$core.Deprecated('Use closeAllNodeConnectionsResponseDescriptor instead')
const CloseAllNodeConnectionsResponse$json = {
  '1': 'CloseAllNodeConnectionsResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {
      '1': 'processed_proxy_count',
      '3': 3,
      '4': 1,
      '5': 5,
      '10': 'processedProxyCount'
    },
    {'1': 'closed_count', '3': 4, '4': 1, '5': 5, '10': 'closedCount'},
    {'1': 'failed_proxy_ids', '3': 5, '4': 3, '5': 9, '10': 'failedProxyIds'},
  ],
};

/// Descriptor for `CloseAllNodeConnectionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List closeAllNodeConnectionsResponseDescriptor =
    $convert.base64Decode(
        'Ch9DbG9zZUFsbE5vZGVDb25uZWN0aW9uc1Jlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2'
        'Nlc3MSFAoFZXJyb3IYAiABKAlSBWVycm9yEjIKFXByb2Nlc3NlZF9wcm94eV9jb3VudBgDIAEo'
        'BVITcHJvY2Vzc2VkUHJveHlDb3VudBIhCgxjbG9zZWRfY291bnQYBCABKAVSC2Nsb3NlZENvdW'
        '50EigKEGZhaWxlZF9wcm94eV9pZHMYBSADKAlSDmZhaWxlZFByb3h5SWRz');

@$core.Deprecated('Use startPairingRequestDescriptor instead')
const StartPairingRequest$json = {
  '1': 'StartPairingRequest',
  '2': [
    {'1': 'node_name', '3': 1, '4': 1, '5': 9, '10': 'nodeName'},
  ],
};

/// Descriptor for `StartPairingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startPairingRequestDescriptor =
    $convert.base64Decode(
        'ChNTdGFydFBhaXJpbmdSZXF1ZXN0EhsKCW5vZGVfbmFtZRgBIAEoCVIIbm9kZU5hbWU=');

@$core.Deprecated('Use startPairingResponseDescriptor instead')
const StartPairingResponse$json = {
  '1': 'StartPairingResponse',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'pairing_code', '3': 2, '4': 1, '5': 9, '10': 'pairingCode'},
    {
      '1': 'expires_in_seconds',
      '3': 3,
      '4': 1,
      '5': 5,
      '10': 'expiresInSeconds'
    },
  ],
};

/// Descriptor for `StartPairingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startPairingResponseDescriptor = $convert.base64Decode(
    'ChRTdGFydFBhaXJpbmdSZXNwb25zZRIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSWQSIQ'
    'oMcGFpcmluZ19jb2RlGAIgASgJUgtwYWlyaW5nQ29kZRIsChJleHBpcmVzX2luX3NlY29uZHMY'
    'AyABKAVSEGV4cGlyZXNJblNlY29uZHM=');

@$core.Deprecated('Use joinPairingRequestDescriptor instead')
const JoinPairingRequest$json = {
  '1': 'JoinPairingRequest',
  '2': [
    {'1': 'pairing_code', '3': 1, '4': 1, '5': 9, '10': 'pairingCode'},
  ],
};

/// Descriptor for `JoinPairingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinPairingRequestDescriptor = $convert.base64Decode(
    'ChJKb2luUGFpcmluZ1JlcXVlc3QSIQoMcGFpcmluZ19jb2RlGAEgASgJUgtwYWlyaW5nQ29kZQ'
    '==');

@$core.Deprecated('Use joinPairingResponseDescriptor instead')
const JoinPairingResponse$json = {
  '1': 'JoinPairingResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'session_id', '3': 3, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'emoji_fingerprint',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'emojiFingerprint'
    },
    {'1': 'node_name', '3': 5, '4': 1, '5': 9, '10': 'nodeName'},
    {'1': 'fingerprint', '3': 6, '4': 1, '5': 9, '10': 'fingerprint'},
    {'1': 'emoji_hash', '3': 7, '4': 1, '5': 9, '10': 'emojiHash'},
    {'1': 'csr_fingerprint', '3': 8, '4': 1, '5': 9, '10': 'csrFingerprint'},
    {'1': 'csr_hash', '3': 9, '4': 1, '5': 9, '10': 'csrHash'},
  ],
};

/// Descriptor for `JoinPairingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinPairingResponseDescriptor = $convert.base64Decode(
    'ChNKb2luUGFpcmluZ1Jlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSFAoFZXJyb3'
    'IYAiABKAlSBWVycm9yEh0KCnNlc3Npb25faWQYAyABKAlSCXNlc3Npb25JZBIrChFlbW9qaV9m'
    'aW5nZXJwcmludBgEIAEoCVIQZW1vamlGaW5nZXJwcmludBIbCglub2RlX25hbWUYBSABKAlSCG'
    '5vZGVOYW1lEiAKC2ZpbmdlcnByaW50GAYgASgJUgtmaW5nZXJwcmludBIdCgplbW9qaV9oYXNo'
    'GAcgASgJUgllbW9qaUhhc2gSJwoPY3NyX2ZpbmdlcnByaW50GAggASgJUg5jc3JGaW5nZXJwcm'
    'ludBIZCghjc3JfaGFzaBgJIAEoCVIHY3NySGFzaA==');

@$core.Deprecated('Use completePairingRequestDescriptor instead')
const CompletePairingRequest$json = {
  '1': 'CompletePairingRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
  ],
};

/// Descriptor for `CompletePairingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List completePairingRequestDescriptor =
    $convert.base64Decode(
        'ChZDb21wbGV0ZVBhaXJpbmdSZXF1ZXN0Eh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZA'
        '==');

@$core.Deprecated('Use completePairingResponseDescriptor instead')
const CompletePairingResponse$json = {
  '1': 'CompletePairingResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {
      '1': 'node',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.NodeInfo',
      '10': 'node'
    },
  ],
};

/// Descriptor for `CompletePairingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List completePairingResponseDescriptor = $convert.base64Decode(
    'ChdDb21wbGV0ZVBhaXJpbmdSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhQKBW'
    'Vycm9yGAIgASgJUgVlcnJvchIrCgRub2RlGAMgASgLMhcubml0ZWxsYS5sb2NhbC5Ob2RlSW5m'
    'b1IEbm9kZQ==');

@$core.Deprecated('Use finalizePairingRequestDescriptor instead')
const FinalizePairingRequest$json = {
  '1': 'FinalizePairingRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'accepted', '3': 2, '4': 1, '5': 8, '10': 'accepted'},
    {'1': 'node_name', '3': 3, '4': 1, '5': 9, '10': 'nodeName'},
  ],
};

/// Descriptor for `FinalizePairingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List finalizePairingRequestDescriptor = $convert.base64Decode(
    'ChZGaW5hbGl6ZVBhaXJpbmdSZXF1ZXN0Eh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZB'
    'IaCghhY2NlcHRlZBgCIAEoCFIIYWNjZXB0ZWQSGwoJbm9kZV9uYW1lGAMgASgJUghub2RlTmFt'
    'ZQ==');

@$core.Deprecated('Use finalizePairingResponseDescriptor instead')
const FinalizePairingResponse$json = {
  '1': 'FinalizePairingResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'completed', '3': 3, '4': 1, '5': 8, '10': 'completed'},
    {'1': 'cancelled', '3': 4, '4': 1, '5': 8, '10': 'cancelled'},
    {
      '1': 'node',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.NodeInfo',
      '10': 'node'
    },
    {'1': 'qr_data', '3': 6, '4': 1, '5': 12, '10': 'qrData'},
  ],
};

/// Descriptor for `FinalizePairingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List finalizePairingResponseDescriptor = $convert.base64Decode(
    'ChdGaW5hbGl6ZVBhaXJpbmdSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhQKBW'
    'Vycm9yGAIgASgJUgVlcnJvchIcCgljb21wbGV0ZWQYAyABKAhSCWNvbXBsZXRlZBIcCgljYW5j'
    'ZWxsZWQYBCABKAhSCWNhbmNlbGxlZBIrCgRub2RlGAUgASgLMhcubml0ZWxsYS5sb2NhbC5Ob2'
    'RlSW5mb1IEbm9kZRIXCgdxcl9kYXRhGAYgASgMUgZxckRhdGE=');

@$core.Deprecated('Use cancelPairingRequestDescriptor instead')
const CancelPairingRequest$json = {
  '1': 'CancelPairingRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
  ],
};

/// Descriptor for `CancelPairingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelPairingRequestDescriptor = $convert.base64Decode(
    'ChRDYW5jZWxQYWlyaW5nUmVxdWVzdBIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSWQ=');

@$core.Deprecated('Use generateQRCodeRequestDescriptor instead')
const GenerateQRCodeRequest$json = {
  '1': 'GenerateQRCodeRequest',
};

/// Descriptor for `GenerateQRCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateQRCodeRequestDescriptor =
    $convert.base64Decode('ChVHZW5lcmF0ZVFSQ29kZVJlcXVlc3Q=');

@$core.Deprecated('Use generateQRCodeResponseDescriptor instead')
const GenerateQRCodeResponse$json = {
  '1': 'GenerateQRCodeResponse',
  '2': [
    {'1': 'qr_data', '3': 1, '4': 1, '5': 12, '10': 'qrData'},
    {'1': 'fingerprint', '3': 2, '4': 1, '5': 9, '10': 'fingerprint'},
  ],
};

/// Descriptor for `GenerateQRCodeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateQRCodeResponseDescriptor =
    $convert.base64Decode(
        'ChZHZW5lcmF0ZVFSQ29kZVJlc3BvbnNlEhcKB3FyX2RhdGEYASABKAxSBnFyRGF0YRIgCgtmaW'
        '5nZXJwcmludBgCIAEoCVILZmluZ2VycHJpbnQ=');

@$core.Deprecated('Use scanQRCodeRequestDescriptor instead')
const ScanQRCodeRequest$json = {
  '1': 'ScanQRCodeRequest',
  '2': [
    {'1': 'qr_data', '3': 1, '4': 1, '5': 12, '10': 'qrData'},
  ],
};

/// Descriptor for `ScanQRCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scanQRCodeRequestDescriptor = $convert.base64Decode(
    'ChFTY2FuUVJDb2RlUmVxdWVzdBIXCgdxcl9kYXRhGAEgASgMUgZxckRhdGE=');

@$core.Deprecated('Use scanQRCodeResponseDescriptor instead')
const ScanQRCodeResponse$json = {
  '1': 'ScanQRCodeResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'session_id', '3': 7, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'node_id', '3': 3, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'csr_pem', '3': 4, '4': 1, '5': 9, '10': 'csrPem'},
    {'1': 'fingerprint', '3': 5, '4': 1, '5': 9, '10': 'fingerprint'},
    {'1': 'emoji_hash', '3': 6, '4': 1, '5': 9, '10': 'emojiHash'},
  ],
};

/// Descriptor for `ScanQRCodeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scanQRCodeResponseDescriptor = $convert.base64Decode(
    'ChJTY2FuUVJDb2RlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIUCgVlcnJvch'
    'gCIAEoCVIFZXJyb3ISHQoKc2Vzc2lvbl9pZBgHIAEoCVIJc2Vzc2lvbklkEhcKB25vZGVfaWQY'
    'AyABKAlSBm5vZGVJZBIXCgdjc3JfcGVtGAQgASgJUgZjc3JQZW0SIAoLZmluZ2VycHJpbnQYBS'
    'ABKAlSC2ZpbmdlcnByaW50Eh0KCmVtb2ppX2hhc2gYBiABKAlSCWVtb2ppSGFzaA==');

@$core.Deprecated('Use generateQRReplyRequestDescriptor instead')
const GenerateQRReplyRequest$json = {
  '1': 'GenerateQRReplyRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'csr_pem', '3': 2, '4': 1, '5': 9, '10': 'csrPem'},
    {'1': 'node_name', '3': 3, '4': 1, '5': 9, '10': 'nodeName'},
    {'1': 'scan_session_id', '3': 4, '4': 1, '5': 9, '10': 'scanSessionId'},
  ],
};

/// Descriptor for `GenerateQRReplyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateQRReplyRequestDescriptor = $convert.base64Decode(
    'ChZHZW5lcmF0ZVFSUmVwbHlSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBIXCgdjc3'
    'JfcGVtGAIgASgJUgZjc3JQZW0SGwoJbm9kZV9uYW1lGAMgASgJUghub2RlTmFtZRImCg9zY2Fu'
    'X3Nlc3Npb25faWQYBCABKAlSDXNjYW5TZXNzaW9uSWQ=');

@$core.Deprecated('Use generateQRReplyResponseDescriptor instead')
const GenerateQRReplyResponse$json = {
  '1': 'GenerateQRReplyResponse',
  '2': [
    {'1': 'qr_data', '3': 1, '4': 1, '5': 12, '10': 'qrData'},
    {
      '1': 'node',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.NodeInfo',
      '10': 'node'
    },
  ],
};

/// Descriptor for `GenerateQRReplyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateQRReplyResponseDescriptor =
    $convert.base64Decode(
        'ChdHZW5lcmF0ZVFSUmVwbHlSZXNwb25zZRIXCgdxcl9kYXRhGAEgASgMUgZxckRhdGESKwoEbm'
        '9kZRgCIAEoCzIXLm5pdGVsbGEubG9jYWwuTm9kZUluZm9SBG5vZGU=');

@$core.Deprecated('Use templateDescriptor instead')
const Template$json = {
  '1': 'Template',
  '2': [
    {'1': 'template_id', '3': 1, '4': 1, '5': 9, '10': 'templateId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'created_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {'1': 'author', '3': 6, '4': 1, '5': 9, '10': 'author'},
    {'1': 'is_public', '3': 7, '4': 1, '5': 8, '10': 'isPublic'},
    {'1': 'downloads', '3': 8, '4': 1, '5': 5, '10': 'downloads'},
    {'1': 'tags', '3': 9, '4': 3, '5': 9, '10': 'tags'},
    {
      '1': 'proxies',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.ProxyTemplate',
      '10': 'proxies'
    },
  ],
};

/// Descriptor for `Template`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateDescriptor = $convert.base64Decode(
    'CghUZW1wbGF0ZRIfCgt0ZW1wbGF0ZV9pZBgBIAEoCVIKdGVtcGxhdGVJZBISCgRuYW1lGAIgAS'
    'gJUgRuYW1lEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhI5CgpjcmVhdGVkX2F0'
    'GAQgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZW'
    'RfYXQYBSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQSFgoGYXV0'
    'aG9yGAYgASgJUgZhdXRob3ISGwoJaXNfcHVibGljGAcgASgIUghpc1B1YmxpYxIcCglkb3dubG'
    '9hZHMYCCABKAVSCWRvd25sb2FkcxISCgR0YWdzGAkgAygJUgR0YWdzEjYKB3Byb3hpZXMYCiAD'
    'KAsyHC5uaXRlbGxhLmxvY2FsLlByb3h5VGVtcGxhdGVSB3Byb3hpZXM=');

@$core.Deprecated('Use proxyTemplateDescriptor instead')
const ProxyTemplate$json = {
  '1': 'ProxyTemplate',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'listen_addr', '3': 2, '4': 1, '5': 9, '10': 'listenAddr'},
    {
      '1': 'default_action',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.nitella.ActionType',
      '10': 'defaultAction'
    },
    {
      '1': 'fallback_action',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.nitella.FallbackAction',
      '10': 'fallbackAction'
    },
    {
      '1': 'rules',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.nitella.proxy.Rule',
      '10': 'rules'
    },
    {'1': 'tags', '3': 6, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `ProxyTemplate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List proxyTemplateDescriptor = $convert.base64Decode(
    'Cg1Qcm94eVRlbXBsYXRlEhIKBG5hbWUYASABKAlSBG5hbWUSHwoLbGlzdGVuX2FkZHIYAiABKA'
    'lSCmxpc3RlbkFkZHISOgoOZGVmYXVsdF9hY3Rpb24YAyABKA4yEy5uaXRlbGxhLkFjdGlvblR5'
    'cGVSDWRlZmF1bHRBY3Rpb24SQAoPZmFsbGJhY2tfYWN0aW9uGAQgASgOMhcubml0ZWxsYS5GYW'
    'xsYmFja0FjdGlvblIOZmFsbGJhY2tBY3Rpb24SKQoFcnVsZXMYBSADKAsyEy5uaXRlbGxhLnBy'
    'b3h5LlJ1bGVSBXJ1bGVzEhIKBHRhZ3MYBiADKAlSBHRhZ3M=');

@$core.Deprecated('Use listTemplatesRequestDescriptor instead')
const ListTemplatesRequest$json = {
  '1': 'ListTemplatesRequest',
  '2': [
    {'1': 'include_public', '3': 1, '4': 1, '5': 8, '10': 'includePublic'},
    {'1': 'tags', '3': 2, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `ListTemplatesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTemplatesRequestDescriptor = $convert.base64Decode(
    'ChRMaXN0VGVtcGxhdGVzUmVxdWVzdBIlCg5pbmNsdWRlX3B1YmxpYxgBIAEoCFINaW5jbHVkZV'
    'B1YmxpYxISCgR0YWdzGAIgAygJUgR0YWdz');

@$core.Deprecated('Use listTemplatesResponseDescriptor instead')
const ListTemplatesResponse$json = {
  '1': 'ListTemplatesResponse',
  '2': [
    {
      '1': 'templates',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.Template',
      '10': 'templates'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListTemplatesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTemplatesResponseDescriptor = $convert.base64Decode(
    'ChVMaXN0VGVtcGxhdGVzUmVzcG9uc2USNQoJdGVtcGxhdGVzGAEgAygLMhcubml0ZWxsYS5sb2'
    'NhbC5UZW1wbGF0ZVIJdGVtcGxhdGVzEh8KC3RvdGFsX2NvdW50GAIgASgFUgp0b3RhbENvdW50');

@$core.Deprecated('Use getTemplateRequestDescriptor instead')
const GetTemplateRequest$json = {
  '1': 'GetTemplateRequest',
  '2': [
    {'1': 'template_id', '3': 1, '4': 1, '5': 9, '10': 'templateId'},
  ],
};

/// Descriptor for `GetTemplateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTemplateRequestDescriptor = $convert.base64Decode(
    'ChJHZXRUZW1wbGF0ZVJlcXVlc3QSHwoLdGVtcGxhdGVfaWQYASABKAlSCnRlbXBsYXRlSWQ=');

@$core.Deprecated('Use createTemplateRequestDescriptor instead')
const CreateTemplateRequest$json = {
  '1': 'CreateTemplateRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'node_id', '3': 3, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_ids', '3': 4, '4': 3, '5': 9, '10': 'proxyIds'},
    {'1': 'tags', '3': 5, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `CreateTemplateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTemplateRequestDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVUZW1wbGF0ZVJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIgCgtkZXNjcmlwdG'
    'lvbhgCIAEoCVILZGVzY3JpcHRpb24SFwoHbm9kZV9pZBgDIAEoCVIGbm9kZUlkEhsKCXByb3h5'
    'X2lkcxgEIAMoCVIIcHJveHlJZHMSEgoEdGFncxgFIAMoCVIEdGFncw==');

@$core.Deprecated('Use applyTemplateRequestDescriptor instead')
const ApplyTemplateRequest$json = {
  '1': 'ApplyTemplateRequest',
  '2': [
    {'1': 'template_id', '3': 1, '4': 1, '5': 9, '10': 'templateId'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'overwrite', '3': 3, '4': 1, '5': 8, '10': 'overwrite'},
  ],
};

/// Descriptor for `ApplyTemplateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applyTemplateRequestDescriptor = $convert.base64Decode(
    'ChRBcHBseVRlbXBsYXRlUmVxdWVzdBIfCgt0ZW1wbGF0ZV9pZBgBIAEoCVIKdGVtcGxhdGVJZB'
    'IXCgdub2RlX2lkGAIgASgJUgZub2RlSWQSHAoJb3ZlcndyaXRlGAMgASgIUglvdmVyd3JpdGU=');

@$core.Deprecated('Use applyTemplateResponseDescriptor instead')
const ApplyTemplateResponse$json = {
  '1': 'ApplyTemplateResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'proxies_created', '3': 3, '4': 1, '5': 5, '10': 'proxiesCreated'},
    {'1': 'rules_created', '3': 4, '4': 1, '5': 5, '10': 'rulesCreated'},
  ],
};

/// Descriptor for `ApplyTemplateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applyTemplateResponseDescriptor = $convert.base64Decode(
    'ChVBcHBseVRlbXBsYXRlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIUCgVlcn'
    'JvchgCIAEoCVIFZXJyb3ISJwoPcHJveGllc19jcmVhdGVkGAMgASgFUg5wcm94aWVzQ3JlYXRl'
    'ZBIjCg1ydWxlc19jcmVhdGVkGAQgASgFUgxydWxlc0NyZWF0ZWQ=');

@$core.Deprecated('Use deleteTemplateRequestDescriptor instead')
const DeleteTemplateRequest$json = {
  '1': 'DeleteTemplateRequest',
  '2': [
    {'1': 'template_id', '3': 1, '4': 1, '5': 9, '10': 'templateId'},
  ],
};

/// Descriptor for `DeleteTemplateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteTemplateRequestDescriptor = $convert.base64Decode(
    'ChVEZWxldGVUZW1wbGF0ZVJlcXVlc3QSHwoLdGVtcGxhdGVfaWQYASABKAlSCnRlbXBsYXRlSW'
    'Q=');

@$core.Deprecated('Use syncTemplatesResponseDescriptor instead')
const SyncTemplatesResponse$json = {
  '1': 'SyncTemplatesResponse',
  '2': [
    {'1': 'uploaded', '3': 1, '4': 1, '5': 5, '10': 'uploaded'},
    {'1': 'downloaded', '3': 2, '4': 1, '5': 5, '10': 'downloaded'},
    {'1': 'conflicts', '3': 3, '4': 1, '5': 5, '10': 'conflicts'},
  ],
};

/// Descriptor for `SyncTemplatesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncTemplatesResponseDescriptor = $convert.base64Decode(
    'ChVTeW5jVGVtcGxhdGVzUmVzcG9uc2USGgoIdXBsb2FkZWQYASABKAVSCHVwbG9hZGVkEh4KCm'
    'Rvd25sb2FkZWQYAiABKAVSCmRvd25sb2FkZWQSHAoJY29uZmxpY3RzGAMgASgFUgljb25mbGlj'
    'dHM=');

@$core.Deprecated('Use exportTemplateYamlRequestDescriptor instead')
const ExportTemplateYamlRequest$json = {
  '1': 'ExportTemplateYamlRequest',
  '2': [
    {'1': 'template_id', '3': 1, '4': 1, '5': 9, '10': 'templateId'},
  ],
};

/// Descriptor for `ExportTemplateYamlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportTemplateYamlRequestDescriptor =
    $convert.base64Decode(
        'ChlFeHBvcnRUZW1wbGF0ZVlhbWxSZXF1ZXN0Eh8KC3RlbXBsYXRlX2lkGAEgASgJUgp0ZW1wbG'
        'F0ZUlk');

@$core.Deprecated('Use exportTemplateYamlResponseDescriptor instead')
const ExportTemplateYamlResponse$json = {
  '1': 'ExportTemplateYamlResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'yaml', '3': 3, '4': 1, '5': 9, '10': 'yaml'},
    {
      '1': 'template',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.Template',
      '10': 'template'
    },
  ],
};

/// Descriptor for `ExportTemplateYamlResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportTemplateYamlResponseDescriptor =
    $convert.base64Decode(
        'ChpFeHBvcnRUZW1wbGF0ZVlhbWxSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEh'
        'QKBWVycm9yGAIgASgJUgVlcnJvchISCgR5YW1sGAMgASgJUgR5YW1sEjMKCHRlbXBsYXRlGAQg'
        'ASgLMhcubml0ZWxsYS5sb2NhbC5UZW1wbGF0ZVIIdGVtcGxhdGU=');

@$core.Deprecated('Use importTemplateYamlRequestDescriptor instead')
const ImportTemplateYamlRequest$json = {
  '1': 'ImportTemplateYamlRequest',
  '2': [
    {'1': 'yaml', '3': 1, '4': 1, '5': 9, '10': 'yaml'},
  ],
};

/// Descriptor for `ImportTemplateYamlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importTemplateYamlRequestDescriptor =
    $convert.base64Decode(
        'ChlJbXBvcnRUZW1wbGF0ZVlhbWxSZXF1ZXN0EhIKBHlhbWwYASABKAlSBHlhbWw=');

@$core.Deprecated('Use importTemplateYamlResponseDescriptor instead')
const ImportTemplateYamlResponse$json = {
  '1': 'ImportTemplateYamlResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {
      '1': 'template',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.Template',
      '10': 'template'
    },
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
    {'1': 'proxy_count', '3': 6, '4': 1, '5': 5, '10': 'proxyCount'},
    {'1': 'tags', '3': 7, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `ImportTemplateYamlResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importTemplateYamlResponseDescriptor = $convert.base64Decode(
    'ChpJbXBvcnRUZW1wbGF0ZVlhbWxSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEh'
    'QKBWVycm9yGAIgASgJUgVlcnJvchIzCgh0ZW1wbGF0ZRgDIAEoCzIXLm5pdGVsbGEubG9jYWwu'
    'VGVtcGxhdGVSCHRlbXBsYXRlEhIKBG5hbWUYBCABKAlSBG5hbWUSIAoLZGVzY3JpcHRpb24YBS'
    'ABKAlSC2Rlc2NyaXB0aW9uEh8KC3Byb3h5X2NvdW50GAYgASgFUgpwcm94eUNvdW50EhIKBHRh'
    'Z3MYByADKAlSBHRhZ3M=');

@$core.Deprecated('Use settingsDescriptor instead')
const Settings$json = {
  '1': 'Settings',
  '2': [
    {'1': 'hub_address', '3': 1, '4': 1, '5': 9, '10': 'hubAddress'},
    {'1': 'auto_connect_hub', '3': 2, '4': 1, '5': 8, '10': 'autoConnectHub'},
    {
      '1': 'notifications_enabled',
      '3': 3,
      '4': 1,
      '5': 8,
      '10': 'notificationsEnabled'
    },
    {
      '1': 'approval_notifications',
      '3': 4,
      '4': 1,
      '5': 8,
      '10': 'approvalNotifications'
    },
    {
      '1': 'connection_notifications',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'connectionNotifications'
    },
    {
      '1': 'alert_notifications',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'alertNotifications'
    },
    {
      '1': 'p2p_mode',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.nitella.P2PMode',
      '10': 'p2pMode'
    },
    {
      '1': 'require_biometric',
      '3': 8,
      '4': 1,
      '5': 8,
      '10': 'requireBiometric'
    },
    {'1': 'auto_lock_minutes', '3': 9, '4': 1, '5': 5, '10': 'autoLockMinutes'},
    {
      '1': 'theme',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.Theme',
      '10': 'theme'
    },
    {'1': 'language', '3': 11, '4': 1, '5': 9, '10': 'language'},
    {'1': 'hub_ca_pem', '3': 12, '4': 1, '5': 12, '10': 'hubCaPem'},
    {'1': 'hub_cert_pin', '3': 13, '4': 1, '5': 9, '10': 'hubCertPin'},
    {'1': 'stun_servers', '3': 14, '4': 3, '5': 9, '10': 'stunServers'},
    {'1': 'turn_server', '3': 15, '4': 1, '5': 9, '10': 'turnServer'},
    {'1': 'turn_username', '3': 16, '4': 1, '5': 9, '10': 'turnUsername'},
    {'1': 'turn_password', '3': 17, '4': 1, '5': 9, '10': 'turnPassword'},
    {'1': 'hub_invite_code', '3': 18, '4': 1, '5': 9, '10': 'hubInviteCode'},
  ],
};

/// Descriptor for `Settings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List settingsDescriptor = $convert.base64Decode(
    'CghTZXR0aW5ncxIfCgtodWJfYWRkcmVzcxgBIAEoCVIKaHViQWRkcmVzcxIoChBhdXRvX2Nvbm'
    '5lY3RfaHViGAIgASgIUg5hdXRvQ29ubmVjdEh1YhIzChVub3RpZmljYXRpb25zX2VuYWJsZWQY'
    'AyABKAhSFG5vdGlmaWNhdGlvbnNFbmFibGVkEjUKFmFwcHJvdmFsX25vdGlmaWNhdGlvbnMYBC'
    'ABKAhSFWFwcHJvdmFsTm90aWZpY2F0aW9ucxI5Chhjb25uZWN0aW9uX25vdGlmaWNhdGlvbnMY'
    'BSABKAhSF2Nvbm5lY3Rpb25Ob3RpZmljYXRpb25zEi8KE2FsZXJ0X25vdGlmaWNhdGlvbnMYBi'
    'ABKAhSEmFsZXJ0Tm90aWZpY2F0aW9ucxIrCghwMnBfbW9kZRgHIAEoDjIQLm5pdGVsbGEuUDJQ'
    'TW9kZVIHcDJwTW9kZRIrChFyZXF1aXJlX2Jpb21ldHJpYxgIIAEoCFIQcmVxdWlyZUJpb21ldH'
    'JpYxIqChFhdXRvX2xvY2tfbWludXRlcxgJIAEoBVIPYXV0b0xvY2tNaW51dGVzEioKBXRoZW1l'
    'GAogASgOMhQubml0ZWxsYS5sb2NhbC5UaGVtZVIFdGhlbWUSGgoIbGFuZ3VhZ2UYCyABKAlSCG'
    'xhbmd1YWdlEhwKCmh1Yl9jYV9wZW0YDCABKAxSCGh1YkNhUGVtEiAKDGh1Yl9jZXJ0X3BpbhgN'
    'IAEoCVIKaHViQ2VydFBpbhIhCgxzdHVuX3NlcnZlcnMYDiADKAlSC3N0dW5TZXJ2ZXJzEh8KC3'
    'R1cm5fc2VydmVyGA8gASgJUgp0dXJuU2VydmVyEiMKDXR1cm5fdXNlcm5hbWUYECABKAlSDHR1'
    'cm5Vc2VybmFtZRIjCg10dXJuX3Bhc3N3b3JkGBEgASgJUgx0dXJuUGFzc3dvcmQSJgoPaHViX2'
    'ludml0ZV9jb2RlGBIgASgJUg1odWJJbnZpdGVDb2Rl');

@$core.Deprecated('Use updateSettingsRequestDescriptor instead')
const UpdateSettingsRequest$json = {
  '1': 'UpdateSettingsRequest',
  '2': [
    {
      '1': 'settings',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.Settings',
      '10': 'settings'
    },
    {
      '1': 'update_mask',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'updateMask'
    },
  ],
};

/// Descriptor for `UpdateSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSettingsRequestDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVTZXR0aW5nc1JlcXVlc3QSMwoIc2V0dGluZ3MYASABKAsyFy5uaXRlbGxhLmxvY2'
    'FsLlNldHRpbmdzUghzZXR0aW5ncxI7Cgt1cGRhdGVfbWFzaxgCIAEoCzIaLmdvb2dsZS5wcm90'
    'b2J1Zi5GaWVsZE1hc2tSCnVwZGF0ZU1hc2s=');

@$core.Deprecated('Use settingsOverviewSnapshotDescriptor instead')
const SettingsOverviewSnapshot$json = {
  '1': 'SettingsOverviewSnapshot',
  '2': [
    {
      '1': 'identity',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.IdentityInfo',
      '10': 'identity'
    },
    {
      '1': 'hub',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.HubSettingsSnapshot',
      '10': 'hub'
    },
    {
      '1': 'p2p',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.P2PSettingsSnapshot',
      '10': 'p2p'
    },
  ],
};

/// Descriptor for `SettingsOverviewSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List settingsOverviewSnapshotDescriptor = $convert.base64Decode(
    'ChhTZXR0aW5nc092ZXJ2aWV3U25hcHNob3QSNwoIaWRlbnRpdHkYASABKAsyGy5uaXRlbGxhLm'
    'xvY2FsLklkZW50aXR5SW5mb1IIaWRlbnRpdHkSNAoDaHViGAIgASgLMiIubml0ZWxsYS5sb2Nh'
    'bC5IdWJTZXR0aW5nc1NuYXBzaG90UgNodWISNAoDcDJwGAMgASgLMiIubml0ZWxsYS5sb2NhbC'
    '5QMlBTZXR0aW5nc1NuYXBzaG90UgNwMnA=');

@$core.Deprecated('Use registerFCMTokenRequestDescriptor instead')
const RegisterFCMTokenRequest$json = {
  '1': 'RegisterFCMTokenRequest',
  '2': [
    {'1': 'fcm_token', '3': 1, '4': 1, '5': 9, '10': 'fcmToken'},
    {
      '1': 'device_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.DeviceType',
      '10': 'deviceType'
    },
    {'1': 'device_name', '3': 3, '4': 1, '5': 9, '10': 'deviceName'},
  ],
};

/// Descriptor for `RegisterFCMTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerFCMTokenRequestDescriptor = $convert.base64Decode(
    'ChdSZWdpc3RlckZDTVRva2VuUmVxdWVzdBIbCglmY21fdG9rZW4YASABKAlSCGZjbVRva2VuEj'
    'oKC2RldmljZV90eXBlGAIgASgOMhkubml0ZWxsYS5sb2NhbC5EZXZpY2VUeXBlUgpkZXZpY2VU'
    'eXBlEh8KC2RldmljZV9uYW1lGAMgASgJUgpkZXZpY2VOYW1l');

@$core.Deprecated('Use connectToHubRequestDescriptor instead')
const ConnectToHubRequest$json = {
  '1': 'ConnectToHubRequest',
  '2': [
    {'1': 'hub_address', '3': 1, '4': 1, '5': 9, '10': 'hubAddress'},
    {'1': 'use_p2p', '3': 2, '4': 1, '5': 8, '10': 'useP2p'},
    {'1': 'hub_ca_pem', '3': 3, '4': 1, '5': 12, '10': 'hubCaPem'},
    {'1': 'hub_cert_pin', '3': 4, '4': 1, '5': 9, '10': 'hubCertPin'},
    {'1': 'token', '3': 5, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `ConnectToHubRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectToHubRequestDescriptor = $convert.base64Decode(
    'ChNDb25uZWN0VG9IdWJSZXF1ZXN0Eh8KC2h1Yl9hZGRyZXNzGAEgASgJUgpodWJBZGRyZXNzEh'
    'cKB3VzZV9wMnAYAiABKAhSBnVzZVAycBIcCgpodWJfY2FfcGVtGAMgASgMUghodWJDYVBlbRIg'
    'CgxodWJfY2VydF9waW4YBCABKAlSCmh1YkNlcnRQaW4SFAoFdG9rZW4YBSABKAlSBXRva2Vu');

@$core.Deprecated('Use fetchHubCARequestDescriptor instead')
const FetchHubCARequest$json = {
  '1': 'FetchHubCARequest',
  '2': [
    {'1': 'hub_address', '3': 1, '4': 1, '5': 9, '10': 'hubAddress'},
  ],
};

/// Descriptor for `FetchHubCARequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fetchHubCARequestDescriptor = $convert.base64Decode(
    'ChFGZXRjaEh1YkNBUmVxdWVzdBIfCgtodWJfYWRkcmVzcxgBIAEoCVIKaHViQWRkcmVzcw==');

@$core.Deprecated('Use fetchHubCAResponseDescriptor instead')
const FetchHubCAResponse$json = {
  '1': 'FetchHubCAResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'ca_pem', '3': 3, '4': 1, '5': 12, '10': 'caPem'},
    {'1': 'fingerprint', '3': 4, '4': 1, '5': 9, '10': 'fingerprint'},
    {'1': 'emoji_hash', '3': 5, '4': 1, '5': 9, '10': 'emojiHash'},
    {'1': 'subject', '3': 6, '4': 1, '5': 9, '10': 'subject'},
    {'1': 'expires', '3': 7, '4': 1, '5': 9, '10': 'expires'},
  ],
};

/// Descriptor for `FetchHubCAResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fetchHubCAResponseDescriptor = $convert.base64Decode(
    'ChJGZXRjaEh1YkNBUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIUCgVlcnJvch'
    'gCIAEoCVIFZXJyb3ISFQoGY2FfcGVtGAMgASgMUgVjYVBlbRIgCgtmaW5nZXJwcmludBgEIAEo'
    'CVILZmluZ2VycHJpbnQSHQoKZW1vamlfaGFzaBgFIAEoCVIJZW1vamlIYXNoEhgKB3N1YmplY3'
    'QYBiABKAlSB3N1YmplY3QSGAoHZXhwaXJlcxgHIAEoCVIHZXhwaXJlcw==');

@$core.Deprecated('Use connectToHubResponseDescriptor instead')
const ConnectToHubResponse$json = {
  '1': 'ConnectToHubResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `ConnectToHubResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectToHubResponseDescriptor = $convert.base64Decode(
    'ChRDb25uZWN0VG9IdWJSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhQKBWVycm'
    '9yGAIgASgJUgVlcnJvcg==');

@$core.Deprecated('Use hubStatusDescriptor instead')
const HubStatus$json = {
  '1': 'HubStatus',
  '2': [
    {'1': 'connected', '3': 1, '4': 1, '5': 8, '10': 'connected'},
    {'1': 'hub_address', '3': 2, '4': 1, '5': 9, '10': 'hubAddress'},
    {
      '1': 'connected_since',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'connectedSince'
    },
    {'1': 'messages_sent', '3': 4, '4': 1, '5': 3, '10': 'messagesSent'},
    {
      '1': 'messages_received',
      '3': 5,
      '4': 1,
      '5': 3,
      '10': 'messagesReceived'
    },
    {'1': 'user_id', '3': 6, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'tier', '3': 7, '4': 1, '5': 9, '10': 'tier'},
    {'1': 'max_nodes', '3': 8, '4': 1, '5': 5, '10': 'maxNodes'},
  ],
};

/// Descriptor for `HubStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hubStatusDescriptor = $convert.base64Decode(
    'CglIdWJTdGF0dXMSHAoJY29ubmVjdGVkGAEgASgIUgljb25uZWN0ZWQSHwoLaHViX2FkZHJlc3'
    'MYAiABKAlSCmh1YkFkZHJlc3MSQwoPY29ubmVjdGVkX3NpbmNlGAMgASgLMhouZ29vZ2xlLnBy'
    'b3RvYnVmLlRpbWVzdGFtcFIOY29ubmVjdGVkU2luY2USIwoNbWVzc2FnZXNfc2VudBgEIAEoA1'
    'IMbWVzc2FnZXNTZW50EisKEW1lc3NhZ2VzX3JlY2VpdmVkGAUgASgDUhBtZXNzYWdlc1JlY2Vp'
    'dmVkEhcKB3VzZXJfaWQYBiABKAlSBnVzZXJJZBISCgR0aWVyGAcgASgJUgR0aWVyEhsKCW1heF'
    '9ub2RlcxgIIAEoBVIIbWF4Tm9kZXM=');

@$core.Deprecated('Use hubSettingsSnapshotDescriptor instead')
const HubSettingsSnapshot$json = {
  '1': 'HubSettingsSnapshot',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.HubStatus',
      '10': 'status'
    },
    {
      '1': 'settings',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.Settings',
      '10': 'settings'
    },
    {
      '1': 'resolved_hub_address',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'resolvedHubAddress'
    },
    {
      '1': 'resolved_invite_code',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'resolvedInviteCode'
    },
    {
      '1': 'pending_trust_challenge',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.HubTrustChallenge',
      '10': 'pendingTrustChallenge'
    },
  ],
};

/// Descriptor for `HubSettingsSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hubSettingsSnapshotDescriptor = $convert.base64Decode(
    'ChNIdWJTZXR0aW5nc1NuYXBzaG90EjAKBnN0YXR1cxgBIAEoCzIYLm5pdGVsbGEubG9jYWwuSH'
    'ViU3RhdHVzUgZzdGF0dXMSMwoIc2V0dGluZ3MYAiABKAsyFy5uaXRlbGxhLmxvY2FsLlNldHRp'
    'bmdzUghzZXR0aW5ncxIwChRyZXNvbHZlZF9odWJfYWRkcmVzcxgDIAEoCVIScmVzb2x2ZWRIdW'
    'JBZGRyZXNzEjAKFHJlc29sdmVkX2ludml0ZV9jb2RlGAQgASgJUhJyZXNvbHZlZEludml0ZUNv'
    'ZGUSWAoXcGVuZGluZ190cnVzdF9jaGFsbGVuZ2UYBSABKAsyIC5uaXRlbGxhLmxvY2FsLkh1Yl'
    'RydXN0Q2hhbGxlbmdlUhVwZW5kaW5nVHJ1c3RDaGFsbGVuZ2U=');

@$core.Deprecated('Use hubOverviewDescriptor instead')
const HubOverview$json = {
  '1': 'HubOverview',
  '2': [
    {'1': 'hub_connected', '3': 1, '4': 1, '5': 8, '10': 'hubConnected'},
    {'1': 'hub_address', '3': 2, '4': 1, '5': 9, '10': 'hubAddress'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'tier', '3': 4, '4': 1, '5': 9, '10': 'tier'},
    {'1': 'max_nodes', '3': 5, '4': 1, '5': 5, '10': 'maxNodes'},
    {'1': 'total_nodes', '3': 6, '4': 1, '5': 5, '10': 'totalNodes'},
    {'1': 'online_nodes', '3': 7, '4': 1, '5': 5, '10': 'onlineNodes'},
    {'1': 'pinned_nodes', '3': 8, '4': 1, '5': 5, '10': 'pinnedNodes'},
    {'1': 'total_proxies', '3': 9, '4': 1, '5': 5, '10': 'totalProxies'},
    {
      '1': 'total_active_connections',
      '3': 10,
      '4': 1,
      '5': 3,
      '10': 'totalActiveConnections'
    },
  ],
};

/// Descriptor for `HubOverview`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hubOverviewDescriptor = $convert.base64Decode(
    'CgtIdWJPdmVydmlldxIjCg1odWJfY29ubmVjdGVkGAEgASgIUgxodWJDb25uZWN0ZWQSHwoLaH'
    'ViX2FkZHJlc3MYAiABKAlSCmh1YkFkZHJlc3MSFwoHdXNlcl9pZBgDIAEoCVIGdXNlcklkEhIK'
    'BHRpZXIYBCABKAlSBHRpZXISGwoJbWF4X25vZGVzGAUgASgFUghtYXhOb2RlcxIfCgt0b3RhbF'
    '9ub2RlcxgGIAEoBVIKdG90YWxOb2RlcxIhCgxvbmxpbmVfbm9kZXMYByABKAVSC29ubGluZU5v'
    'ZGVzEiEKDHBpbm5lZF9ub2RlcxgIIAEoBVILcGlubmVkTm9kZXMSIwoNdG90YWxfcHJveGllcx'
    'gJIAEoBVIMdG90YWxQcm94aWVzEjgKGHRvdGFsX2FjdGl2ZV9jb25uZWN0aW9ucxgKIAEoA1IW'
    'dG90YWxBY3RpdmVDb25uZWN0aW9ucw==');

@$core.Deprecated('Use getHubDashboardSnapshotRequestDescriptor instead')
const GetHubDashboardSnapshotRequest$json = {
  '1': 'GetHubDashboardSnapshotRequest',
  '2': [
    {'1': 'node_filter', '3': 1, '4': 1, '5': 9, '10': 'nodeFilter'},
  ],
};

/// Descriptor for `GetHubDashboardSnapshotRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHubDashboardSnapshotRequestDescriptor =
    $convert.base64Decode(
        'Ch5HZXRIdWJEYXNoYm9hcmRTbmFwc2hvdFJlcXVlc3QSHwoLbm9kZV9maWx0ZXIYASABKAlSCm'
        '5vZGVGaWx0ZXI=');

@$core.Deprecated('Use hubDashboardSnapshotDescriptor instead')
const HubDashboardSnapshot$json = {
  '1': 'HubDashboardSnapshot',
  '2': [
    {
      '1': 'overview',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.HubOverview',
      '10': 'overview'
    },
    {
      '1': 'nodes',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.NodeInfo',
      '10': 'nodes'
    },
    {
      '1': 'pinned_nodes',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.NodeInfo',
      '10': 'pinnedNodes'
    },
  ],
};

/// Descriptor for `HubDashboardSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hubDashboardSnapshotDescriptor = $convert.base64Decode(
    'ChRIdWJEYXNoYm9hcmRTbmFwc2hvdBI2CghvdmVydmlldxgBIAEoCzIaLm5pdGVsbGEubG9jYW'
    'wuSHViT3ZlcnZpZXdSCG92ZXJ2aWV3Ei0KBW5vZGVzGAIgAygLMhcubml0ZWxsYS5sb2NhbC5O'
    'b2RlSW5mb1IFbm9kZXMSOgoMcGlubmVkX25vZGVzGAMgAygLMhcubml0ZWxsYS5sb2NhbC5Ob2'
    'RlSW5mb1ILcGlubmVkTm9kZXM=');

@$core.Deprecated('Use registerUserRequestDescriptor instead')
const RegisterUserRequest$json = {
  '1': 'RegisterUserRequest',
  '2': [
    {'1': 'email', '3': 1, '4': 1, '5': 9, '10': 'email'},
    {'1': 'invite_code', '3': 2, '4': 1, '5': 9, '10': 'inviteCode'},
    {
      '1': 'biometric_public_key',
      '3': 3,
      '4': 1,
      '5': 12,
      '10': 'biometricPublicKey'
    },
  ],
};

/// Descriptor for `RegisterUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerUserRequestDescriptor = $convert.base64Decode(
    'ChNSZWdpc3RlclVzZXJSZXF1ZXN0EhQKBWVtYWlsGAEgASgJUgVlbWFpbBIfCgtpbnZpdGVfY2'
    '9kZRgCIAEoCVIKaW52aXRlQ29kZRIwChRiaW9tZXRyaWNfcHVibGljX2tleRgDIAEoDFISYmlv'
    'bWV0cmljUHVibGljS2V5');

@$core.Deprecated('Use registerUserResponseDescriptor instead')
const RegisterUserResponse$json = {
  '1': 'RegisterUserResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'tier', '3': 4, '4': 1, '5': 9, '10': 'tier'},
    {'1': 'max_nodes', '3': 5, '4': 1, '5': 5, '10': 'maxNodes'},
    {'1': 'jwt_token', '3': 6, '4': 1, '5': 9, '10': 'jwtToken'},
  ],
};

/// Descriptor for `RegisterUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerUserResponseDescriptor = $convert.base64Decode(
    'ChRSZWdpc3RlclVzZXJSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhQKBWVycm'
    '9yGAIgASgJUgVlcnJvchIXCgd1c2VyX2lkGAMgASgJUgZ1c2VySWQSEgoEdGllchgEIAEoCVIE'
    'dGllchIbCgltYXhfbm9kZXMYBSABKAVSCG1heE5vZGVzEhsKCWp3dF90b2tlbhgGIAEoCVIIan'
    'd0VG9rZW4=');

@$core.Deprecated('Use onboardHubRequestDescriptor instead')
const OnboardHubRequest$json = {
  '1': 'OnboardHubRequest',
  '2': [
    {'1': 'hub_address', '3': 1, '4': 1, '5': 9, '10': 'hubAddress'},
    {'1': 'invite_code', '3': 2, '4': 1, '5': 9, '10': 'inviteCode'},
    {'1': 'token', '3': 3, '4': 1, '5': 9, '10': 'token'},
    {
      '1': 'biometric_public_key',
      '3': 4,
      '4': 1,
      '5': 12,
      '10': 'biometricPublicKey'
    },
    {
      '1': 'trust_prompt_accepted',
      '3': 10,
      '4': 1,
      '5': 8,
      '10': 'trustPromptAccepted'
    },
    {
      '1': 'trust_challenge_id',
      '3': 11,
      '4': 1,
      '5': 9,
      '10': 'trustChallengeId'
    },
    {
      '1': 'skip_registration',
      '3': 14,
      '4': 1,
      '5': 8,
      '10': 'skipRegistration'
    },
    {'1': 'persist_settings', '3': 15, '4': 1, '5': 8, '10': 'persistSettings'},
  ],
  '9': [
    {'1': 12, '2': 13},
    {'1': 13, '2': 14},
  ],
};

/// Descriptor for `OnboardHubRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List onboardHubRequestDescriptor = $convert.base64Decode(
    'ChFPbmJvYXJkSHViUmVxdWVzdBIfCgtodWJfYWRkcmVzcxgBIAEoCVIKaHViQWRkcmVzcxIfCg'
    'tpbnZpdGVfY29kZRgCIAEoCVIKaW52aXRlQ29kZRIUCgV0b2tlbhgDIAEoCVIFdG9rZW4SMAoU'
    'YmlvbWV0cmljX3B1YmxpY19rZXkYBCABKAxSEmJpb21ldHJpY1B1YmxpY0tleRIyChV0cnVzdF'
    '9wcm9tcHRfYWNjZXB0ZWQYCiABKAhSE3RydXN0UHJvbXB0QWNjZXB0ZWQSLAoSdHJ1c3RfY2hh'
    'bGxlbmdlX2lkGAsgASgJUhB0cnVzdENoYWxsZW5nZUlkEisKEXNraXBfcmVnaXN0cmF0aW9uGA'
    '4gASgIUhBza2lwUmVnaXN0cmF0aW9uEikKEHBlcnNpc3Rfc2V0dGluZ3MYDyABKAhSD3BlcnNp'
    'c3RTZXR0aW5nc0oECAwQDUoECA0QDg==');

@$core.Deprecated('Use ensureHubRegisteredRequestDescriptor instead')
const EnsureHubRegisteredRequest$json = {
  '1': 'EnsureHubRegisteredRequest',
  '2': [
    {'1': 'hub_address', '3': 1, '4': 1, '5': 9, '10': 'hubAddress'},
    {'1': 'invite_code', '3': 2, '4': 1, '5': 9, '10': 'inviteCode'},
    {'1': 'token', '3': 3, '4': 1, '5': 9, '10': 'token'},
    {
      '1': 'biometric_public_key',
      '3': 4,
      '4': 1,
      '5': 12,
      '10': 'biometricPublicKey'
    },
    {'1': 'persist_settings', '3': 5, '4': 1, '5': 8, '10': 'persistSettings'},
  ],
};

/// Descriptor for `EnsureHubRegisteredRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ensureHubRegisteredRequestDescriptor = $convert.base64Decode(
    'ChpFbnN1cmVIdWJSZWdpc3RlcmVkUmVxdWVzdBIfCgtodWJfYWRkcmVzcxgBIAEoCVIKaHViQW'
    'RkcmVzcxIfCgtpbnZpdGVfY29kZRgCIAEoCVIKaW52aXRlQ29kZRIUCgV0b2tlbhgDIAEoCVIF'
    'dG9rZW4SMAoUYmlvbWV0cmljX3B1YmxpY19rZXkYBCABKAxSEmJpb21ldHJpY1B1YmxpY0tleR'
    'IpChBwZXJzaXN0X3NldHRpbmdzGAUgASgIUg9wZXJzaXN0U2V0dGluZ3M=');

@$core.Deprecated('Use ensureHubConnectedRequestDescriptor instead')
const EnsureHubConnectedRequest$json = {
  '1': 'EnsureHubConnectedRequest',
  '2': [
    {'1': 'hub_address', '3': 1, '4': 1, '5': 9, '10': 'hubAddress'},
    {'1': 'token', '3': 2, '4': 1, '5': 9, '10': 'token'},
    {'1': 'persist_settings', '3': 3, '4': 1, '5': 8, '10': 'persistSettings'},
  ],
};

/// Descriptor for `EnsureHubConnectedRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ensureHubConnectedRequestDescriptor = $convert.base64Decode(
    'ChlFbnN1cmVIdWJDb25uZWN0ZWRSZXF1ZXN0Eh8KC2h1Yl9hZGRyZXNzGAEgASgJUgpodWJBZG'
    'RyZXNzEhQKBXRva2VuGAIgASgJUgV0b2tlbhIpChBwZXJzaXN0X3NldHRpbmdzGAMgASgIUg9w'
    'ZXJzaXN0U2V0dGluZ3M=');

@$core.Deprecated('Use hubTrustChallengeDescriptor instead')
const HubTrustChallenge$json = {
  '1': 'HubTrustChallenge',
  '2': [
    {'1': 'ca_pem', '3': 1, '4': 1, '5': 12, '10': 'caPem'},
    {'1': 'fingerprint', '3': 2, '4': 1, '5': 9, '10': 'fingerprint'},
    {'1': 'emoji_hash', '3': 3, '4': 1, '5': 9, '10': 'emojiHash'},
    {'1': 'subject', '3': 4, '4': 1, '5': 9, '10': 'subject'},
    {'1': 'expires', '3': 5, '4': 1, '5': 9, '10': 'expires'},
    {'1': 'challenge_id', '3': 6, '4': 1, '5': 9, '10': 'challengeId'},
  ],
};

/// Descriptor for `HubTrustChallenge`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hubTrustChallengeDescriptor = $convert.base64Decode(
    'ChFIdWJUcnVzdENoYWxsZW5nZRIVCgZjYV9wZW0YASABKAxSBWNhUGVtEiAKC2ZpbmdlcnByaW'
    '50GAIgASgJUgtmaW5nZXJwcmludBIdCgplbW9qaV9oYXNoGAMgASgJUgllbW9qaUhhc2gSGAoH'
    'c3ViamVjdBgEIAEoCVIHc3ViamVjdBIYCgdleHBpcmVzGAUgASgJUgdleHBpcmVzEiEKDGNoYW'
    'xsZW5nZV9pZBgGIAEoCVILY2hhbGxlbmdlSWQ=');

@$core.Deprecated('Use resolveHubTrustChallengeRequestDescriptor instead')
const ResolveHubTrustChallengeRequest$json = {
  '1': 'ResolveHubTrustChallengeRequest',
  '2': [
    {'1': 'challenge_id', '3': 1, '4': 1, '5': 9, '10': 'challengeId'},
    {'1': 'accepted', '3': 2, '4': 1, '5': 8, '10': 'accepted'},
  ],
};

/// Descriptor for `ResolveHubTrustChallengeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolveHubTrustChallengeRequestDescriptor =
    $convert.base64Decode(
        'Ch9SZXNvbHZlSHViVHJ1c3RDaGFsbGVuZ2VSZXF1ZXN0EiEKDGNoYWxsZW5nZV9pZBgBIAEoCV'
        'ILY2hhbGxlbmdlSWQSGgoIYWNjZXB0ZWQYAiABKAhSCGFjY2VwdGVk');

@$core.Deprecated('Use onboardHubResponseDescriptor instead')
const OnboardHubResponse$json = {
  '1': 'OnboardHubResponse',
  '2': [
    {
      '1': 'stage',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.OnboardHubResponse.Stage',
      '10': 'stage'
    },
    {'1': 'success', '3': 2, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 3, '4': 1, '5': 9, '10': 'error'},
    {'1': 'hub_address', '3': 4, '4': 1, '5': 9, '10': 'hubAddress'},
    {'1': 'connected', '3': 5, '4': 1, '5': 8, '10': 'connected'},
    {'1': 'registered', '3': 6, '4': 1, '5': 8, '10': 'registered'},
    {'1': 'user_id', '3': 7, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'tier', '3': 8, '4': 1, '5': 9, '10': 'tier'},
    {'1': 'max_nodes', '3': 9, '4': 1, '5': 5, '10': 'maxNodes'},
    {
      '1': 'trust_challenge',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.HubTrustChallenge',
      '10': 'trustChallenge'
    },
  ],
  '4': [OnboardHubResponse_Stage$json],
};

@$core.Deprecated('Use onboardHubResponseDescriptor instead')
const OnboardHubResponse_Stage$json = {
  '1': 'Stage',
  '2': [
    {'1': 'STAGE_UNSPECIFIED', '2': 0},
    {'1': 'STAGE_COMPLETED', '2': 1},
    {'1': 'STAGE_NEEDS_TRUST', '2': 2},
    {'1': 'STAGE_FAILED', '2': 3},
  ],
};

/// Descriptor for `OnboardHubResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List onboardHubResponseDescriptor = $convert.base64Decode(
    'ChJPbmJvYXJkSHViUmVzcG9uc2USPQoFc3RhZ2UYASABKA4yJy5uaXRlbGxhLmxvY2FsLk9uYm'
    '9hcmRIdWJSZXNwb25zZS5TdGFnZVIFc3RhZ2USGAoHc3VjY2VzcxgCIAEoCFIHc3VjY2VzcxIU'
    'CgVlcnJvchgDIAEoCVIFZXJyb3ISHwoLaHViX2FkZHJlc3MYBCABKAlSCmh1YkFkZHJlc3MSHA'
    'oJY29ubmVjdGVkGAUgASgIUgljb25uZWN0ZWQSHgoKcmVnaXN0ZXJlZBgGIAEoCFIKcmVnaXN0'
    'ZXJlZBIXCgd1c2VyX2lkGAcgASgJUgZ1c2VySWQSEgoEdGllchgIIAEoCVIEdGllchIbCgltYX'
    'hfbm9kZXMYCSABKAVSCG1heE5vZGVzEkkKD3RydXN0X2NoYWxsZW5nZRgKIAEoCzIgLm5pdGVs'
    'bGEubG9jYWwuSHViVHJ1c3RDaGFsbGVuZ2VSDnRydXN0Q2hhbGxlbmdlIlwKBVN0YWdlEhUKEV'
    'NUQUdFX1VOU1BFQ0lGSUVEEAASEwoPU1RBR0VfQ09NUExFVEVEEAESFQoRU1RBR0VfTkVFRFNf'
    'VFJVU1QQAhIQCgxTVEFHRV9GQUlMRUQQAw==');

@$core.Deprecated('Use lookupIPRequestDescriptor instead')
const LookupIPRequest$json = {
  '1': 'LookupIPRequest',
  '2': [
    {'1': 'ip', '3': 1, '4': 1, '5': 9, '10': 'ip'},
  ],
};

/// Descriptor for `LookupIPRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lookupIPRequestDescriptor =
    $convert.base64Decode('Cg9Mb29rdXBJUFJlcXVlc3QSDgoCaXAYASABKAlSAmlw');

@$core.Deprecated('Use lookupIPResponseDescriptor instead')
const LookupIPResponse$json = {
  '1': 'LookupIPResponse',
  '2': [
    {'1': 'geo', '3': 1, '4': 1, '5': 11, '6': '.nitella.GeoInfo', '10': 'geo'},
    {'1': 'cached', '3': 2, '4': 1, '5': 8, '10': 'cached'},
  ],
};

/// Descriptor for `LookupIPResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lookupIPResponseDescriptor = $convert.base64Decode(
    'ChBMb29rdXBJUFJlc3BvbnNlEiIKA2dlbxgBIAEoCzIQLm5pdGVsbGEuR2VvSW5mb1IDZ2VvEh'
    'YKBmNhY2hlZBgCIAEoCFIGY2FjaGVk');

@$core.Deprecated('Use configureGeoIPNodeRequestDescriptor instead')
const ConfigureGeoIPNodeRequest$json = {
  '1': 'ConfigureGeoIPNodeRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {
      '1': 'config',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.ConfigureGeoIPRequest',
      '10': 'config'
    },
  ],
};

/// Descriptor for `ConfigureGeoIPNodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configureGeoIPNodeRequestDescriptor = $convert.base64Decode(
    'ChlDb25maWd1cmVHZW9JUE5vZGVSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBI8Cg'
    'Zjb25maWcYAiABKAsyJC5uaXRlbGxhLnByb3h5LkNvbmZpZ3VyZUdlb0lQUmVxdWVzdFIGY29u'
    'Zmln');

@$core.Deprecated('Use getGeoIPStatusNodeRequestDescriptor instead')
const GetGeoIPStatusNodeRequest$json = {
  '1': 'GetGeoIPStatusNodeRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `GetGeoIPStatusNodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGeoIPStatusNodeRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRHZW9JUFN0YXR1c05vZGVSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZA==');

@$core.Deprecated('Use restartListenersNodeRequestDescriptor instead')
const RestartListenersNodeRequest$json = {
  '1': 'RestartListenersNodeRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `RestartListenersNodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List restartListenersNodeRequestDescriptor =
    $convert.base64Decode(
        'ChtSZXN0YXJ0TGlzdGVuZXJzTm9kZVJlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlk');

@$core.Deprecated('Use nodeStatusChangeDescriptor instead')
const NodeStatusChange$json = {
  '1': 'NodeStatusChange',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'online', '3': 3, '4': 1, '5': 8, '10': 'online'},
    {
      '1': 'timestamp',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `NodeStatusChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeStatusChangeDescriptor = $convert.base64Decode(
    'ChBOb2RlU3RhdHVzQ2hhbmdlEhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBISCgRuYW1lGAIgAS'
    'gJUgRuYW1lEhYKBm9ubGluZRgDIAEoCFIGb25saW5lEjgKCXRpbWVzdGFtcBgEIAEoCzIaLmdv'
    'b2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use alertDescriptor instead')
const Alert$json = {
  '1': 'Alert',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'message', '3': 4, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'severity',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.AlertSeverity',
      '10': 'severity'
    },
    {
      '1': 'timestamp',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'metadata',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.Alert.MetadataEntry',
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
    'CgVBbGVydBIOCgJpZBgBIAEoCVICaWQSFwoHbm9kZV9pZBgCIAEoCVIGbm9kZUlkEhQKBXRpdG'
    'xlGAMgASgJUgV0aXRsZRIYCgdtZXNzYWdlGAQgASgJUgdtZXNzYWdlEjgKCHNldmVyaXR5GAUg'
    'ASgOMhwubml0ZWxsYS5sb2NhbC5BbGVydFNldmVyaXR5UghzZXZlcml0eRI4Cgl0aW1lc3RhbX'
    'AYBiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXASPgoIbWV0YWRh'
    'dGEYByADKAsyIi5uaXRlbGxhLmxvY2FsLkFsZXJ0Lk1ldGFkYXRhRW50cnlSCG1ldGFkYXRhGj'
    'sKDU1ldGFkYXRhRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVl'
    'OgI4AQ==');

@$core.Deprecated('Use toastMessageDescriptor instead')
const ToastMessage$json = {
  '1': 'ToastMessage',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.nitella.local.ToastType',
      '10': 'type'
    },
    {'1': 'duration_ms', '3': 3, '4': 1, '5': 5, '10': 'durationMs'},
  ],
};

/// Descriptor for `ToastMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List toastMessageDescriptor = $convert.base64Decode(
    'CgxUb2FzdE1lc3NhZ2USGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZRIsCgR0eXBlGAIgASgOMh'
    'gubml0ZWxsYS5sb2NhbC5Ub2FzdFR5cGVSBHR5cGUSHwoLZHVyYXRpb25fbXMYAyABKAVSCmR1'
    'cmF0aW9uTXM=');

@$core.Deprecated('Use p2PStatusDescriptor instead')
const P2PStatus$json = {
  '1': 'P2PStatus',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
    {
      '1': 'mode',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.nitella.P2PMode',
      '10': 'mode'
    },
    {
      '1': 'active_connections',
      '3': 3,
      '4': 1,
      '5': 5,
      '10': 'activeConnections'
    },
    {'1': 'connected_nodes', '3': 4, '4': 3, '5': 9, '10': 'connectedNodes'},
  ],
};

/// Descriptor for `P2PStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List p2PStatusDescriptor = $convert.base64Decode(
    'CglQMlBTdGF0dXMSGAoHZW5hYmxlZBgBIAEoCFIHZW5hYmxlZBIkCgRtb2RlGAIgASgOMhAubm'
    'l0ZWxsYS5QMlBNb2RlUgRtb2RlEi0KEmFjdGl2ZV9jb25uZWN0aW9ucxgDIAEoBVIRYWN0aXZl'
    'Q29ubmVjdGlvbnMSJwoPY29ubmVjdGVkX25vZGVzGAQgAygJUg5jb25uZWN0ZWROb2Rlcw==');

@$core.Deprecated('Use p2PSettingsSnapshotDescriptor instead')
const P2PSettingsSnapshot$json = {
  '1': 'P2PSettingsSnapshot',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.P2PStatus',
      '10': 'status'
    },
    {
      '1': 'settings',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.Settings',
      '10': 'settings'
    },
  ],
};

/// Descriptor for `P2PSettingsSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List p2PSettingsSnapshotDescriptor = $convert.base64Decode(
    'ChNQMlBTZXR0aW5nc1NuYXBzaG90EjAKBnN0YXR1cxgBIAEoCzIYLm5pdGVsbGEubG9jYWwuUD'
    'JQU3RhdHVzUgZzdGF0dXMSMwoIc2V0dGluZ3MYAiABKAsyFy5uaXRlbGxhLmxvY2FsLlNldHRp'
    'bmdzUghzZXR0aW5ncw==');

@$core.Deprecated('Use setP2PModeRequestDescriptor instead')
const SetP2PModeRequest$json = {
  '1': 'SetP2PModeRequest',
  '2': [
    {
      '1': 'mode',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.nitella.P2PMode',
      '10': 'mode'
    },
  ],
};

/// Descriptor for `SetP2PModeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setP2PModeRequestDescriptor = $convert.base64Decode(
    'ChFTZXRQMlBNb2RlUmVxdWVzdBIkCgRtb2RlGAEgASgOMhAubml0ZWxsYS5QMlBNb2RlUgRtb2'
    'Rl');

@$core.Deprecated('Use localProxyConfigDescriptor instead')
const LocalProxyConfig$json = {
  '1': 'LocalProxyConfig',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'created_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {
      '1': 'synced_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'syncedAt'
    },
    {'1': 'revision_num', '3': 7, '4': 1, '5': 3, '10': 'revisionNum'},
    {'1': 'config_hash', '3': 8, '4': 1, '5': 9, '10': 'configHash'},
  ],
};

/// Descriptor for `LocalProxyConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List localProxyConfigDescriptor = $convert.base64Decode(
    'ChBMb2NhbFByb3h5Q29uZmlnEhkKCHByb3h5X2lkGAEgASgJUgdwcm94eUlkEhIKBG5hbWUYAi'
    'ABKAlSBG5hbWUSIAoLZGVzY3JpcHRpb24YAyABKAlSC2Rlc2NyaXB0aW9uEjkKCmNyZWF0ZWRf'
    'YXQYBCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYX'
    'RlZF9hdBgFIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdBI3Cglz'
    'eW5jZWRfYXQYBiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUghzeW5jZWRBdBIhCg'
    'xyZXZpc2lvbl9udW0YByABKANSC3JldmlzaW9uTnVtEh8KC2NvbmZpZ19oYXNoGAggASgJUgpj'
    'b25maWdIYXNo');

@$core.Deprecated('Use listLocalProxyConfigsRequestDescriptor instead')
const ListLocalProxyConfigsRequest$json = {
  '1': 'ListLocalProxyConfigsRequest',
};

/// Descriptor for `ListLocalProxyConfigsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listLocalProxyConfigsRequestDescriptor =
    $convert.base64Decode('ChxMaXN0TG9jYWxQcm94eUNvbmZpZ3NSZXF1ZXN0');

@$core.Deprecated('Use listLocalProxyConfigsResponseDescriptor instead')
const ListLocalProxyConfigsResponse$json = {
  '1': 'ListLocalProxyConfigsResponse',
  '2': [
    {
      '1': 'proxies',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.LocalProxyConfig',
      '10': 'proxies'
    },
  ],
};

/// Descriptor for `ListLocalProxyConfigsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listLocalProxyConfigsResponseDescriptor =
    $convert.base64Decode(
        'Ch1MaXN0TG9jYWxQcm94eUNvbmZpZ3NSZXNwb25zZRI5Cgdwcm94aWVzGAEgAygLMh8ubml0ZW'
        'xsYS5sb2NhbC5Mb2NhbFByb3h5Q29uZmlnUgdwcm94aWVz');

@$core.Deprecated('Use getLocalProxyConfigRequestDescriptor instead')
const GetLocalProxyConfigRequest$json = {
  '1': 'GetLocalProxyConfigRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `GetLocalProxyConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLocalProxyConfigRequestDescriptor =
    $convert.base64Decode(
        'ChpHZXRMb2NhbFByb3h5Q29uZmlnUmVxdWVzdBIZCghwcm94eV9pZBgBIAEoCVIHcHJveHlJZA'
        '==');

@$core.Deprecated('Use getLocalProxyConfigResponseDescriptor instead')
const GetLocalProxyConfigResponse$json = {
  '1': 'GetLocalProxyConfigResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {
      '1': 'proxy',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.LocalProxyConfig',
      '10': 'proxy'
    },
    {'1': 'config_yaml', '3': 4, '4': 1, '5': 9, '10': 'configYaml'},
  ],
};

/// Descriptor for `GetLocalProxyConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLocalProxyConfigResponseDescriptor = $convert.base64Decode(
    'ChtHZXRMb2NhbFByb3h5Q29uZmlnUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcx'
    'IUCgVlcnJvchgCIAEoCVIFZXJyb3ISNQoFcHJveHkYAyABKAsyHy5uaXRlbGxhLmxvY2FsLkxv'
    'Y2FsUHJveHlDb25maWdSBXByb3h5Eh8KC2NvbmZpZ195YW1sGAQgASgJUgpjb25maWdZYW1s');

@$core.Deprecated('Use importLocalProxyConfigRequestDescriptor instead')
const ImportLocalProxyConfigRequest$json = {
  '1': 'ImportLocalProxyConfigRequest',
  '2': [
    {'1': 'config_data', '3': 1, '4': 1, '5': 12, '10': 'configData'},
    {'1': 'source_name', '3': 2, '4': 1, '5': 9, '10': 'sourceName'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `ImportLocalProxyConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importLocalProxyConfigRequestDescriptor =
    $convert.base64Decode(
        'Ch1JbXBvcnRMb2NhbFByb3h5Q29uZmlnUmVxdWVzdBIfCgtjb25maWdfZGF0YRgBIAEoDFIKY2'
        '9uZmlnRGF0YRIfCgtzb3VyY2VfbmFtZRgCIAEoCVIKc291cmNlTmFtZRISCgRuYW1lGAMgASgJ'
        'UgRuYW1l');

@$core.Deprecated('Use importLocalProxyConfigResponseDescriptor instead')
const ImportLocalProxyConfigResponse$json = {
  '1': 'ImportLocalProxyConfigResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {
      '1': 'proxy',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.LocalProxyConfig',
      '10': 'proxy'
    },
    {'1': 'config_yaml', '3': 4, '4': 1, '5': 9, '10': 'configYaml'},
  ],
};

/// Descriptor for `ImportLocalProxyConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importLocalProxyConfigResponseDescriptor =
    $convert.base64Decode(
        'Ch5JbXBvcnRMb2NhbFByb3h5Q29uZmlnUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2'
        'VzcxIUCgVlcnJvchgCIAEoCVIFZXJyb3ISNQoFcHJveHkYAyABKAsyHy5uaXRlbGxhLmxvY2Fs'
        'LkxvY2FsUHJveHlDb25maWdSBXByb3h5Eh8KC2NvbmZpZ195YW1sGAQgASgJUgpjb25maWdZYW'
        '1s');

@$core.Deprecated('Use saveLocalProxyConfigRequestDescriptor instead')
const SaveLocalProxyConfigRequest$json = {
  '1': 'SaveLocalProxyConfigRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'config_yaml', '3': 4, '4': 1, '5': 9, '10': 'configYaml'},
    {'1': 'revision_num', '3': 5, '4': 1, '5': 3, '10': 'revisionNum'},
    {'1': 'config_hash', '3': 6, '4': 1, '5': 9, '10': 'configHash'},
    {'1': 'mark_synced', '3': 7, '4': 1, '5': 8, '10': 'markSynced'},
  ],
};

/// Descriptor for `SaveLocalProxyConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List saveLocalProxyConfigRequestDescriptor = $convert.base64Decode(
    'ChtTYXZlTG9jYWxQcm94eUNvbmZpZ1JlcXVlc3QSGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SW'
    'QSEgoEbmFtZRgCIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgDIAEoCVILZGVzY3JpcHRpb24S'
    'HwoLY29uZmlnX3lhbWwYBCABKAlSCmNvbmZpZ1lhbWwSIQoMcmV2aXNpb25fbnVtGAUgASgDUg'
    'tyZXZpc2lvbk51bRIfCgtjb25maWdfaGFzaBgGIAEoCVIKY29uZmlnSGFzaBIfCgttYXJrX3N5'
    'bmNlZBgHIAEoCFIKbWFya1N5bmNlZA==');

@$core.Deprecated('Use saveLocalProxyConfigResponseDescriptor instead')
const SaveLocalProxyConfigResponse$json = {
  '1': 'SaveLocalProxyConfigResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {
      '1': 'proxy',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.LocalProxyConfig',
      '10': 'proxy'
    },
  ],
};

/// Descriptor for `SaveLocalProxyConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List saveLocalProxyConfigResponseDescriptor =
    $convert.base64Decode(
        'ChxTYXZlTG9jYWxQcm94eUNvbmZpZ1Jlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3'
        'MSFAoFZXJyb3IYAiABKAlSBWVycm9yEjUKBXByb3h5GAMgASgLMh8ubml0ZWxsYS5sb2NhbC5M'
        'b2NhbFByb3h5Q29uZmlnUgVwcm94eQ==');

@$core.Deprecated('Use deleteLocalProxyConfigRequestDescriptor instead')
const DeleteLocalProxyConfigRequest$json = {
  '1': 'DeleteLocalProxyConfigRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `DeleteLocalProxyConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteLocalProxyConfigRequestDescriptor =
    $convert.base64Decode(
        'Ch1EZWxldGVMb2NhbFByb3h5Q29uZmlnUmVxdWVzdBIZCghwcm94eV9pZBgBIAEoCVIHcHJveH'
        'lJZA==');

@$core.Deprecated('Use deleteLocalProxyConfigResponseDescriptor instead')
const DeleteLocalProxyConfigResponse$json = {
  '1': 'DeleteLocalProxyConfigResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `DeleteLocalProxyConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteLocalProxyConfigResponseDescriptor =
    $convert.base64Decode(
        'Ch5EZWxldGVMb2NhbFByb3h5Q29uZmlnUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2'
        'VzcxIUCgVlcnJvchgCIAEoCVIFZXJyb3I=');

@$core.Deprecated('Use validateLocalProxyConfigRequestDescriptor instead')
const ValidateLocalProxyConfigRequest$json = {
  '1': 'ValidateLocalProxyConfigRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `ValidateLocalProxyConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateLocalProxyConfigRequestDescriptor =
    $convert.base64Decode(
        'Ch9WYWxpZGF0ZUxvY2FsUHJveHlDb25maWdSZXF1ZXN0EhkKCHByb3h5X2lkGAEgASgJUgdwcm'
        '94eUlk');

@$core.Deprecated('Use validateLocalProxyConfigResponseDescriptor instead')
const ValidateLocalProxyConfigResponse$json = {
  '1': 'ValidateLocalProxyConfigResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'checksum_ok', '3': 3, '4': 1, '5': 8, '10': 'checksumOk'},
    {'1': 'checksum_error', '3': 4, '4': 1, '5': 9, '10': 'checksumError'},
    {'1': 'header_ok', '3': 5, '4': 1, '5': 8, '10': 'headerOk'},
    {'1': 'header_error', '3': 6, '4': 1, '5': 9, '10': 'headerError'},
    {'1': 'header_type', '3': 7, '4': 1, '5': 9, '10': 'headerType'},
    {'1': 'header_version', '3': 8, '4': 1, '5': 5, '10': 'headerVersion'},
    {'1': 'yaml_ok', '3': 9, '4': 1, '5': 8, '10': 'yamlOk'},
    {'1': 'yaml_error', '3': 10, '4': 1, '5': 9, '10': 'yamlError'},
    {'1': 'has_entry_points', '3': 11, '4': 1, '5': 8, '10': 'hasEntryPoints'},
    {'1': 'has_tcp', '3': 12, '4': 1, '5': 8, '10': 'hasTcp'},
  ],
};

/// Descriptor for `ValidateLocalProxyConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateLocalProxyConfigResponseDescriptor = $convert.base64Decode(
    'CiBWYWxpZGF0ZUxvY2FsUHJveHlDb25maWdSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdW'
    'NjZXNzEhQKBWVycm9yGAIgASgJUgVlcnJvchIfCgtjaGVja3N1bV9vaxgDIAEoCFIKY2hlY2tz'
    'dW1PaxIlCg5jaGVja3N1bV9lcnJvchgEIAEoCVINY2hlY2tzdW1FcnJvchIbCgloZWFkZXJfb2'
    'sYBSABKAhSCGhlYWRlck9rEiEKDGhlYWRlcl9lcnJvchgGIAEoCVILaGVhZGVyRXJyb3ISHwoL'
    'aGVhZGVyX3R5cGUYByABKAlSCmhlYWRlclR5cGUSJQoOaGVhZGVyX3ZlcnNpb24YCCABKAVSDW'
    'hlYWRlclZlcnNpb24SFwoHeWFtbF9vaxgJIAEoCFIGeWFtbE9rEh0KCnlhbWxfZXJyb3IYCiAB'
    'KAlSCXlhbWxFcnJvchIoChBoYXNfZW50cnlfcG9pbnRzGAsgASgIUg5oYXNFbnRyeVBvaW50cx'
    'IXCgdoYXNfdGNwGAwgASgIUgZoYXNUY3A=');

@$core.Deprecated('Use pushProxyRevisionRequestDescriptor instead')
const PushProxyRevisionRequest$json = {
  '1': 'PushProxyRevisionRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'commit_message', '3': 4, '4': 1, '5': 9, '10': 'commitMessage'},
    {'1': 'config_yaml', '3': 5, '4': 1, '5': 9, '10': 'configYaml'},
    {'1': 'config_hash', '3': 6, '4': 1, '5': 9, '10': 'configHash'},
  ],
};

/// Descriptor for `PushProxyRevisionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushProxyRevisionRequestDescriptor = $convert.base64Decode(
    'ChhQdXNoUHJveHlSZXZpc2lvblJlcXVlc3QSGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQSEg'
    'oEbmFtZRgCIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgDIAEoCVILZGVzY3JpcHRpb24SJQoO'
    'Y29tbWl0X21lc3NhZ2UYBCABKAlSDWNvbW1pdE1lc3NhZ2USHwoLY29uZmlnX3lhbWwYBSABKA'
    'lSCmNvbmZpZ1lhbWwSHwoLY29uZmlnX2hhc2gYBiABKAlSCmNvbmZpZ0hhc2g=');

@$core.Deprecated('Use pushProxyRevisionResponseDescriptor instead')
const PushProxyRevisionResponse$json = {
  '1': 'PushProxyRevisionResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'revision_num', '3': 3, '4': 1, '5': 3, '10': 'revisionNum'},
    {'1': 'revisions_kept', '3': 4, '4': 1, '5': 5, '10': 'revisionsKept'},
    {'1': 'revisions_limit', '3': 5, '4': 1, '5': 5, '10': 'revisionsLimit'},
    {'1': 'storage_used_kb', '3': 6, '4': 1, '5': 5, '10': 'storageUsedKb'},
    {'1': 'storage_limit_kb', '3': 7, '4': 1, '5': 5, '10': 'storageLimitKb'},
  ],
};

/// Descriptor for `PushProxyRevisionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushProxyRevisionResponseDescriptor = $convert.base64Decode(
    'ChlQdXNoUHJveHlSZXZpc2lvblJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSFA'
    'oFZXJyb3IYAiABKAlSBWVycm9yEiEKDHJldmlzaW9uX251bRgDIAEoA1ILcmV2aXNpb25OdW0S'
    'JQoOcmV2aXNpb25zX2tlcHQYBCABKAVSDXJldmlzaW9uc0tlcHQSJwoPcmV2aXNpb25zX2xpbW'
    'l0GAUgASgFUg5yZXZpc2lvbnNMaW1pdBImCg9zdG9yYWdlX3VzZWRfa2IYBiABKAVSDXN0b3Jh'
    'Z2VVc2VkS2ISKAoQc3RvcmFnZV9saW1pdF9rYhgHIAEoBVIOc3RvcmFnZUxpbWl0S2I=');

@$core.Deprecated('Use pushLocalProxyRevisionRequestDescriptor instead')
const PushLocalProxyRevisionRequest$json = {
  '1': 'PushLocalProxyRevisionRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'commit_message', '3': 2, '4': 1, '5': 9, '10': 'commitMessage'},
    {'1': 'ensure_remote', '3': 3, '4': 1, '5': 8, '10': 'ensureRemote'},
  ],
};

/// Descriptor for `PushLocalProxyRevisionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushLocalProxyRevisionRequestDescriptor =
    $convert.base64Decode(
        'Ch1QdXNoTG9jYWxQcm94eVJldmlzaW9uUmVxdWVzdBIZCghwcm94eV9pZBgBIAEoCVIHcHJveH'
        'lJZBIlCg5jb21taXRfbWVzc2FnZRgCIAEoCVINY29tbWl0TWVzc2FnZRIjCg1lbnN1cmVfcmVt'
        'b3RlGAMgASgIUgxlbnN1cmVSZW1vdGU=');

@$core.Deprecated('Use pushLocalProxyRevisionResponseDescriptor instead')
const PushLocalProxyRevisionResponse$json = {
  '1': 'PushLocalProxyRevisionResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'proxy_id', '3': 3, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'revision_num', '3': 4, '4': 1, '5': 3, '10': 'revisionNum'},
    {'1': 'revisions_kept', '3': 5, '4': 1, '5': 5, '10': 'revisionsKept'},
    {'1': 'revisions_limit', '3': 6, '4': 1, '5': 5, '10': 'revisionsLimit'},
    {'1': 'storage_used_kb', '3': 7, '4': 1, '5': 5, '10': 'storageUsedKb'},
    {'1': 'storage_limit_kb', '3': 8, '4': 1, '5': 5, '10': 'storageLimitKb'},
    {
      '1': 'local_proxy',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.LocalProxyConfig',
      '10': 'localProxy'
    },
    {'1': 'remote_pushed', '3': 10, '4': 1, '5': 8, '10': 'remotePushed'},
    {
      '1': 'local_metadata_updated',
      '3': 11,
      '4': 1,
      '5': 8,
      '10': 'localMetadataUpdated'
    },
    {
      '1': 'local_metadata_error',
      '3': 12,
      '4': 1,
      '5': 9,
      '10': 'localMetadataError'
    },
  ],
};

/// Descriptor for `PushLocalProxyRevisionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushLocalProxyRevisionResponseDescriptor = $convert.base64Decode(
    'Ch5QdXNoTG9jYWxQcm94eVJldmlzaW9uUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2'
    'VzcxIUCgVlcnJvchgCIAEoCVIFZXJyb3ISGQoIcHJveHlfaWQYAyABKAlSB3Byb3h5SWQSIQoM'
    'cmV2aXNpb25fbnVtGAQgASgDUgtyZXZpc2lvbk51bRIlCg5yZXZpc2lvbnNfa2VwdBgFIAEoBV'
    'INcmV2aXNpb25zS2VwdBInCg9yZXZpc2lvbnNfbGltaXQYBiABKAVSDnJldmlzaW9uc0xpbWl0'
    'EiYKD3N0b3JhZ2VfdXNlZF9rYhgHIAEoBVINc3RvcmFnZVVzZWRLYhIoChBzdG9yYWdlX2xpbW'
    'l0X2tiGAggASgFUg5zdG9yYWdlTGltaXRLYhJACgtsb2NhbF9wcm94eRgJIAEoCzIfLm5pdGVs'
    'bGEubG9jYWwuTG9jYWxQcm94eUNvbmZpZ1IKbG9jYWxQcm94eRIjCg1yZW1vdGVfcHVzaGVkGA'
    'ogASgIUgxyZW1vdGVQdXNoZWQSNAoWbG9jYWxfbWV0YWRhdGFfdXBkYXRlZBgLIAEoCFIUbG9j'
    'YWxNZXRhZGF0YVVwZGF0ZWQSMAoUbG9jYWxfbWV0YWRhdGFfZXJyb3IYDCABKAlSEmxvY2FsTW'
    'V0YWRhdGFFcnJvcg==');

@$core.Deprecated('Use pullProxyRevisionRequestDescriptor instead')
const PullProxyRevisionRequest$json = {
  '1': 'PullProxyRevisionRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'revision_num', '3': 2, '4': 1, '5': 3, '10': 'revisionNum'},
    {'1': 'store_local', '3': 3, '4': 1, '5': 8, '10': 'storeLocal'},
  ],
};

/// Descriptor for `PullProxyRevisionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullProxyRevisionRequestDescriptor = $convert.base64Decode(
    'ChhQdWxsUHJveHlSZXZpc2lvblJlcXVlc3QSGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQSIQ'
    'oMcmV2aXNpb25fbnVtGAIgASgDUgtyZXZpc2lvbk51bRIfCgtzdG9yZV9sb2NhbBgDIAEoCFIK'
    'c3RvcmVMb2NhbA==');

@$core.Deprecated('Use pullProxyRevisionResponseDescriptor instead')
const PullProxyRevisionResponse$json = {
  '1': 'PullProxyRevisionResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'revision_num', '3': 3, '4': 1, '5': 3, '10': 'revisionNum'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
    {'1': 'commit_message', '3': 6, '4': 1, '5': 9, '10': 'commitMessage'},
    {'1': 'config_yaml', '3': 7, '4': 1, '5': 9, '10': 'configYaml'},
    {'1': 'config_hash', '3': 8, '4': 1, '5': 9, '10': 'configHash'},
    {'1': 'size_bytes', '3': 9, '4': 1, '5': 5, '10': 'sizeBytes'},
    {
      '1': 'local_proxy',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.nitella.local.LocalProxyConfig',
      '10': 'localProxy'
    },
  ],
};

/// Descriptor for `PullProxyRevisionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pullProxyRevisionResponseDescriptor = $convert.base64Decode(
    'ChlQdWxsUHJveHlSZXZpc2lvblJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSFA'
    'oFZXJyb3IYAiABKAlSBWVycm9yEiEKDHJldmlzaW9uX251bRgDIAEoA1ILcmV2aXNpb25OdW0S'
    'EgoEbmFtZRgEIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgFIAEoCVILZGVzY3JpcHRpb24SJQ'
    'oOY29tbWl0X21lc3NhZ2UYBiABKAlSDWNvbW1pdE1lc3NhZ2USHwoLY29uZmlnX3lhbWwYByAB'
    'KAlSCmNvbmZpZ1lhbWwSHwoLY29uZmlnX2hhc2gYCCABKAlSCmNvbmZpZ0hhc2gSHQoKc2l6ZV'
    '9ieXRlcxgJIAEoBVIJc2l6ZUJ5dGVzEkAKC2xvY2FsX3Byb3h5GAogASgLMh8ubml0ZWxsYS5s'
    'b2NhbC5Mb2NhbFByb3h5Q29uZmlnUgpsb2NhbFByb3h5');

@$core.Deprecated('Use diffProxyRevisionsRequestDescriptor instead')
const DiffProxyRevisionsRequest$json = {
  '1': 'DiffProxyRevisionsRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'revision_num_a', '3': 2, '4': 1, '5': 3, '10': 'revisionNumA'},
    {'1': 'revision_num_b', '3': 3, '4': 1, '5': 3, '10': 'revisionNumB'},
    {'1': 'local_vs_latest', '3': 4, '4': 1, '5': 8, '10': 'localVsLatest'},
  ],
};

/// Descriptor for `DiffProxyRevisionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diffProxyRevisionsRequestDescriptor = $convert.base64Decode(
    'ChlEaWZmUHJveHlSZXZpc2lvbnNSZXF1ZXN0EhkKCHByb3h5X2lkGAEgASgJUgdwcm94eUlkEi'
    'QKDnJldmlzaW9uX251bV9hGAIgASgDUgxyZXZpc2lvbk51bUESJAoOcmV2aXNpb25fbnVtX2IY'
    'AyABKANSDHJldmlzaW9uTnVtQhImCg9sb2NhbF92c19sYXRlc3QYBCABKAhSDWxvY2FsVnNMYX'
    'Rlc3Q=');

@$core.Deprecated('Use diffProxyRevisionsResponseDescriptor instead')
const DiffProxyRevisionsResponse$json = {
  '1': 'DiffProxyRevisionsResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'left_label', '3': 3, '4': 1, '5': 9, '10': 'leftLabel'},
    {'1': 'right_label', '3': 4, '4': 1, '5': 9, '10': 'rightLabel'},
    {'1': 'unified_diff', '3': 5, '4': 1, '5': 9, '10': 'unifiedDiff'},
    {'1': 'has_differences', '3': 6, '4': 1, '5': 8, '10': 'hasDifferences'},
  ],
};

/// Descriptor for `DiffProxyRevisionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diffProxyRevisionsResponseDescriptor = $convert.base64Decode(
    'ChpEaWZmUHJveHlSZXZpc2lvbnNSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEh'
    'QKBWVycm9yGAIgASgJUgVlcnJvchIdCgpsZWZ0X2xhYmVsGAMgASgJUglsZWZ0TGFiZWwSHwoL'
    'cmlnaHRfbGFiZWwYBCABKAlSCnJpZ2h0TGFiZWwSIQoMdW5pZmllZF9kaWZmGAUgASgJUgt1bm'
    'lmaWVkRGlmZhInCg9oYXNfZGlmZmVyZW5jZXMYBiABKAhSDmhhc0RpZmZlcmVuY2Vz');

@$core.Deprecated('Use listProxyRevisionsRequestDescriptor instead')
const ListProxyRevisionsRequest$json = {
  '1': 'ListProxyRevisionsRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `ListProxyRevisionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProxyRevisionsRequestDescriptor =
    $convert.base64Decode(
        'ChlMaXN0UHJveHlSZXZpc2lvbnNSZXF1ZXN0EhkKCHByb3h5X2lkGAEgASgJUgdwcm94eUlk');

@$core.Deprecated('Use listProxyRevisionsResponseDescriptor instead')
const ListProxyRevisionsResponse$json = {
  '1': 'ListProxyRevisionsResponse',
  '2': [
    {
      '1': 'revisions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.ProxyRevisionMeta',
      '10': 'revisions'
    },
  ],
};

/// Descriptor for `ListProxyRevisionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProxyRevisionsResponseDescriptor =
    $convert.base64Decode(
        'ChpMaXN0UHJveHlSZXZpc2lvbnNSZXNwb25zZRI+CglyZXZpc2lvbnMYASADKAsyIC5uaXRlbG'
        'xhLmxvY2FsLlByb3h5UmV2aXNpb25NZXRhUglyZXZpc2lvbnM=');

@$core.Deprecated('Use proxyRevisionMetaDescriptor instead')
const ProxyRevisionMeta$json = {
  '1': 'ProxyRevisionMeta',
  '2': [
    {'1': 'revision_num', '3': 1, '4': 1, '5': 3, '10': 'revisionNum'},
    {'1': 'size_bytes', '3': 2, '4': 1, '5': 5, '10': 'sizeBytes'},
    {
      '1': 'created_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `ProxyRevisionMeta`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List proxyRevisionMetaDescriptor = $convert.base64Decode(
    'ChFQcm94eVJldmlzaW9uTWV0YRIhCgxyZXZpc2lvbl9udW0YASABKANSC3JldmlzaW9uTnVtEh'
    '0KCnNpemVfYnl0ZXMYAiABKAVSCXNpemVCeXRlcxI5CgpjcmVhdGVkX2F0GAMgASgLMhouZ29v'
    'Z2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use flushProxyRevisionsRequestDescriptor instead')
const FlushProxyRevisionsRequest$json = {
  '1': 'FlushProxyRevisionsRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'keep_count', '3': 2, '4': 1, '5': 5, '10': 'keepCount'},
  ],
};

/// Descriptor for `FlushProxyRevisionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List flushProxyRevisionsRequestDescriptor =
    $convert.base64Decode(
        'ChpGbHVzaFByb3h5UmV2aXNpb25zUmVxdWVzdBIZCghwcm94eV9pZBgBIAEoCVIHcHJveHlJZB'
        'IdCgprZWVwX2NvdW50GAIgASgFUglrZWVwQ291bnQ=');

@$core.Deprecated('Use flushProxyRevisionsResponseDescriptor instead')
const FlushProxyRevisionsResponse$json = {
  '1': 'FlushProxyRevisionsResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'deleted_count', '3': 3, '4': 1, '5': 5, '10': 'deletedCount'},
    {'1': 'remaining_count', '3': 4, '4': 1, '5': 5, '10': 'remainingCount'},
  ],
};

/// Descriptor for `FlushProxyRevisionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List flushProxyRevisionsResponseDescriptor =
    $convert.base64Decode(
        'ChtGbHVzaFByb3h5UmV2aXNpb25zUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcx'
        'IUCgVlcnJvchgCIAEoCVIFZXJyb3ISIwoNZGVsZXRlZF9jb3VudBgDIAEoBVIMZGVsZXRlZENv'
        'dW50EicKD3JlbWFpbmluZ19jb3VudBgEIAEoBVIOcmVtYWluaW5nQ291bnQ=');

@$core.Deprecated('Use listProxyConfigsRequestDescriptor instead')
const ListProxyConfigsRequest$json = {
  '1': 'ListProxyConfigsRequest',
};

/// Descriptor for `ListProxyConfigsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProxyConfigsRequestDescriptor =
    $convert.base64Decode('ChdMaXN0UHJveHlDb25maWdzUmVxdWVzdA==');

@$core.Deprecated('Use listProxyConfigsResponseDescriptor instead')
const ListProxyConfigsResponse$json = {
  '1': 'ListProxyConfigsResponse',
  '2': [
    {
      '1': 'proxies',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.ProxyConfigInfo',
      '10': 'proxies'
    },
  ],
};

/// Descriptor for `ListProxyConfigsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProxyConfigsResponseDescriptor =
    $convert.base64Decode(
        'ChhMaXN0UHJveHlDb25maWdzUmVzcG9uc2USOAoHcHJveGllcxgBIAMoCzIeLm5pdGVsbGEubG'
        '9jYWwuUHJveHlDb25maWdJbmZvUgdwcm94aWVz');

@$core.Deprecated('Use proxyConfigInfoDescriptor instead')
const ProxyConfigInfo$json = {
  '1': 'ProxyConfigInfo',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'latest_revision', '3': 2, '4': 1, '5': 3, '10': 'latestRevision'},
    {'1': 'total_size_bytes', '3': 3, '4': 1, '5': 5, '10': 'totalSizeBytes'},
    {
      '1': 'updated_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `ProxyConfigInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List proxyConfigInfoDescriptor = $convert.base64Decode(
    'Cg9Qcm94eUNvbmZpZ0luZm8SGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQSJwoPbGF0ZXN0X3'
    'JldmlzaW9uGAIgASgDUg5sYXRlc3RSZXZpc2lvbhIoChB0b3RhbF9zaXplX2J5dGVzGAMgASgF'
    'Ug50b3RhbFNpemVCeXRlcxI5Cgp1cGRhdGVkX2F0GAQgASgLMhouZ29vZ2xlLnByb3RvYnVmLl'
    'RpbWVzdGFtcFIJdXBkYXRlZEF0');

@$core.Deprecated('Use createProxyConfigRequestDescriptor instead')
const CreateProxyConfigRequest$json = {
  '1': 'CreateProxyConfigRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `CreateProxyConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProxyConfigRequestDescriptor =
    $convert.base64Decode(
        'ChhDcmVhdGVQcm94eUNvbmZpZ1JlcXVlc3QSGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQ=');

@$core.Deprecated('Use createProxyConfigResponseDescriptor instead')
const CreateProxyConfigResponse$json = {
  '1': 'CreateProxyConfigResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `CreateProxyConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProxyConfigResponseDescriptor =
    $convert.base64Decode(
        'ChlDcmVhdGVQcm94eUNvbmZpZ1Jlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSFA'
        'oFZXJyb3IYAiABKAlSBWVycm9y');

@$core.Deprecated('Use deleteProxyConfigRequestDescriptor instead')
const DeleteProxyConfigRequest$json = {
  '1': 'DeleteProxyConfigRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `DeleteProxyConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteProxyConfigRequestDescriptor =
    $convert.base64Decode(
        'ChhEZWxldGVQcm94eUNvbmZpZ1JlcXVlc3QSGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQ=');

@$core.Deprecated('Use deleteProxyConfigResponseDescriptor instead')
const DeleteProxyConfigResponse$json = {
  '1': 'DeleteProxyConfigResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `DeleteProxyConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteProxyConfigResponseDescriptor =
    $convert.base64Decode(
        'ChlEZWxldGVQcm94eUNvbmZpZ1Jlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSFA'
        'oFZXJyb3IYAiABKAlSBWVycm9y');

@$core.Deprecated('Use applyProxyToNodeRequestDescriptor instead')
const ApplyProxyToNodeRequest$json = {
  '1': 'ApplyProxyToNodeRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'revision_num', '3': 3, '4': 1, '5': 3, '10': 'revisionNum'},
    {'1': 'config_yaml', '3': 4, '4': 1, '5': 9, '10': 'configYaml'},
    {'1': 'config_hash', '3': 5, '4': 1, '5': 9, '10': 'configHash'},
  ],
};

/// Descriptor for `ApplyProxyToNodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applyProxyToNodeRequestDescriptor = $convert.base64Decode(
    'ChdBcHBseVByb3h5VG9Ob2RlUmVxdWVzdBIZCghwcm94eV9pZBgBIAEoCVIHcHJveHlJZBIXCg'
    'dub2RlX2lkGAIgASgJUgZub2RlSWQSIQoMcmV2aXNpb25fbnVtGAMgASgDUgtyZXZpc2lvbk51'
    'bRIfCgtjb25maWdfeWFtbBgEIAEoCVIKY29uZmlnWWFtbBIfCgtjb25maWdfaGFzaBgFIAEoCV'
    'IKY29uZmlnSGFzaA==');

@$core.Deprecated('Use applyProxyToNodeResponseDescriptor instead')
const ApplyProxyToNodeResponse$json = {
  '1': 'ApplyProxyToNodeResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `ApplyProxyToNodeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applyProxyToNodeResponseDescriptor =
    $convert.base64Decode(
        'ChhBcHBseVByb3h5VG9Ob2RlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIUCg'
        'VlcnJvchgCIAEoCVIFZXJyb3I=');

@$core.Deprecated('Use unapplyProxyFromNodeRequestDescriptor instead')
const UnapplyProxyFromNodeRequest$json = {
  '1': 'UnapplyProxyFromNodeRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `UnapplyProxyFromNodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unapplyProxyFromNodeRequestDescriptor =
    $convert.base64Decode(
        'ChtVbmFwcGx5UHJveHlGcm9tTm9kZVJlcXVlc3QSGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SW'
        'QSFwoHbm9kZV9pZBgCIAEoCVIGbm9kZUlk');

@$core.Deprecated('Use unapplyProxyFromNodeResponseDescriptor instead')
const UnapplyProxyFromNodeResponse$json = {
  '1': 'UnapplyProxyFromNodeResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `UnapplyProxyFromNodeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unapplyProxyFromNodeResponseDescriptor =
    $convert.base64Decode(
        'ChxVbmFwcGx5UHJveHlGcm9tTm9kZVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3'
        'MSFAoFZXJyb3IYAiABKAlSBWVycm9y');

@$core.Deprecated('Use getAppliedProxiesRequestDescriptor instead')
const GetAppliedProxiesRequest$json = {
  '1': 'GetAppliedProxiesRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `GetAppliedProxiesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAppliedProxiesRequestDescriptor =
    $convert.base64Decode(
        'ChhHZXRBcHBsaWVkUHJveGllc1JlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlk');

@$core.Deprecated('Use getAppliedProxiesResponseDescriptor instead')
const GetAppliedProxiesResponse$json = {
  '1': 'GetAppliedProxiesResponse',
  '2': [
    {
      '1': 'proxies',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.AppliedProxy',
      '10': 'proxies'
    },
  ],
};

/// Descriptor for `GetAppliedProxiesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAppliedProxiesResponseDescriptor =
    $convert.base64Decode(
        'ChlHZXRBcHBsaWVkUHJveGllc1Jlc3BvbnNlEjUKB3Byb3hpZXMYASADKAsyGy5uaXRlbGxhLm'
        'xvY2FsLkFwcGxpZWRQcm94eVIHcHJveGllcw==');

@$core.Deprecated('Use appliedProxyDescriptor instead')
const AppliedProxy$json = {
  '1': 'AppliedProxy',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'revision_num', '3': 2, '4': 1, '5': 3, '10': 'revisionNum'},
    {'1': 'applied_at', '3': 3, '4': 1, '5': 9, '10': 'appliedAt'},
    {'1': 'status', '3': 4, '4': 1, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `AppliedProxy`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List appliedProxyDescriptor = $convert.base64Decode(
    'CgxBcHBsaWVkUHJveHkSGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQSIQoMcmV2aXNpb25fbn'
    'VtGAIgASgDUgtyZXZpc2lvbk51bRIdCgphcHBsaWVkX2F0GAMgASgJUglhcHBsaWVkQXQSFgoG'
    'c3RhdHVzGAQgASgJUgZzdGF0dXM=');

@$core.Deprecated('Use allowIPRequestDescriptor instead')
const AllowIPRequest$json = {
  '1': 'AllowIPRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'ip', '3': 3, '4': 1, '5': 9, '10': 'ip'},
    {
      '1': 'apply_to_all_nodes',
      '3': 4,
      '4': 1,
      '5': 8,
      '10': 'applyToAllNodes'
    },
  ],
};

/// Descriptor for `AllowIPRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List allowIPRequestDescriptor = $convert.base64Decode(
    'Cg5BbGxvd0lQUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSGQoIcHJveHlfaWQYAi'
    'ABKAlSB3Byb3h5SWQSDgoCaXAYAyABKAlSAmlwEisKEmFwcGx5X3RvX2FsbF9ub2RlcxgEIAEo'
    'CFIPYXBwbHlUb0FsbE5vZGVz');

@$core.Deprecated('Use allowIPResponseDescriptor instead')
const AllowIPResponse$json = {
  '1': 'AllowIPResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'rules_created', '3': 3, '4': 1, '5': 5, '10': 'rulesCreated'},
  ],
};

/// Descriptor for `AllowIPResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List allowIPResponseDescriptor = $convert.base64Decode(
    'Cg9BbGxvd0lQUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIUCgVlcnJvchgCIA'
    'EoCVIFZXJyb3ISIwoNcnVsZXNfY3JlYXRlZBgDIAEoBVIMcnVsZXNDcmVhdGVk');

@$core.Deprecated('Use streamMetricsRequestDescriptor instead')
const StreamMetricsRequest$json = {
  '1': 'StreamMetricsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'interval_seconds', '3': 2, '4': 1, '5': 5, '10': 'intervalSeconds'},
  ],
};

/// Descriptor for `StreamMetricsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamMetricsRequestDescriptor = $convert.base64Decode(
    'ChRTdHJlYW1NZXRyaWNzUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSKQoQaW50ZX'
    'J2YWxfc2Vjb25kcxgCIAEoBVIPaW50ZXJ2YWxTZWNvbmRz');

@$core.Deprecated('Use getDebugRuntimeStatsRequestDescriptor instead')
const GetDebugRuntimeStatsRequest$json = {
  '1': 'GetDebugRuntimeStatsRequest',
};

/// Descriptor for `GetDebugRuntimeStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDebugRuntimeStatsRequestDescriptor =
    $convert.base64Decode('ChtHZXREZWJ1Z1J1bnRpbWVTdGF0c1JlcXVlc3Q=');

@$core.Deprecated('Use debugRuntimeStatsDescriptor instead')
const DebugRuntimeStats$json = {
  '1': 'DebugRuntimeStats',
  '2': [
    {'1': 'rss_bytes', '3': 1, '4': 1, '5': 3, '10': 'rssBytes'},
    {
      '1': 'go_heap_alloc_bytes',
      '3': 2,
      '4': 1,
      '5': 3,
      '10': 'goHeapAllocBytes'
    },
    {'1': 'go_heap_sys_bytes', '3': 3, '4': 1, '5': 3, '10': 'goHeapSysBytes'},
    {'1': 'go_sys_bytes', '3': 4, '4': 1, '5': 3, '10': 'goSysBytes'},
    {
      '1': 'go_total_alloc_bytes',
      '3': 5,
      '4': 1,
      '5': 3,
      '10': 'goTotalAllocBytes'
    },
    {'1': 'go_gc_count', '3': 6, '4': 1, '5': 3, '10': 'goGcCount'},
    {'1': 'go_goroutines', '3': 7, '4': 1, '5': 3, '10': 'goGoroutines'},
    {'1': 'go_cgo_calls', '3': 8, '4': 1, '5': 3, '10': 'goCgoCalls'},
    {'1': 'go_heap_objects', '3': 9, '4': 1, '5': 3, '10': 'goHeapObjects'},
    {
      '1': 'go_heap_inuse_bytes',
      '3': 10,
      '4': 1,
      '5': 3,
      '10': 'goHeapInuseBytes'
    },
    {
      '1': 'go_stack_inuse_bytes',
      '3': 11,
      '4': 1,
      '5': 3,
      '10': 'goStackInuseBytes'
    },
    {'1': 'uptime_seconds', '3': 12, '4': 1, '5': 3, '10': 'uptimeSeconds'},
    {'1': 'hub_connected', '3': 13, '4': 1, '5': 8, '10': 'hubConnected'},
    {'1': 'hub_grpc_state', '3': 14, '4': 1, '5': 9, '10': 'hubGrpcState'},
    {'1': 'total_nodes', '3': 15, '4': 1, '5': 5, '10': 'totalNodes'},
    {'1': 'online_nodes', '3': 16, '4': 1, '5': 5, '10': 'onlineNodes'},
    {
      '1': 'direct_grpc_connections',
      '3': 17,
      '4': 1,
      '5': 5,
      '10': 'directGrpcConnections'
    },
    {
      '1': 'grpc_connections',
      '3': 18,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.DebugGrpcConnection',
      '10': 'grpcConnections'
    },
    {
      '1': 'approval_stream_subscribers',
      '3': 19,
      '4': 1,
      '5': 5,
      '10': 'approvalStreamSubscribers'
    },
    {
      '1': 'connection_stream_subscribers',
      '3': 20,
      '4': 1,
      '5': 5,
      '10': 'connectionStreamSubscribers'
    },
    {
      '1': 'p2p_stream_subscribers',
      '3': 21,
      '4': 1,
      '5': 5,
      '10': 'p2pStreamSubscribers'
    },
    {
      '1': 'goroutine_diff_has_baseline',
      '3': 22,
      '4': 1,
      '5': 8,
      '10': 'goroutineDiffHasBaseline'
    },
    {
      '1': 'goroutine_diff_prev_total',
      '3': 23,
      '4': 1,
      '5': 3,
      '10': 'goroutineDiffPrevTotal'
    },
    {
      '1': 'goroutine_diff_curr_total',
      '3': 24,
      '4': 1,
      '5': 3,
      '10': 'goroutineDiffCurrTotal'
    },
    {
      '1': 'goroutine_diff_delta',
      '3': 25,
      '4': 1,
      '5': 3,
      '10': 'goroutineDiffDelta'
    },
    {
      '1': 'goroutine_diff_entries',
      '3': 26,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.DebugGoroutineDiffEntry',
      '10': 'goroutineDiffEntries'
    },
    {
      '1': 'goroutine_diff_prev_at',
      '3': 27,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'goroutineDiffPrevAt'
    },
    {
      '1': 'goroutine_diff_curr_at',
      '3': 28,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'goroutineDiffCurrAt'
    },
    {
      '1': 'goroutine_diff_truncated',
      '3': 29,
      '4': 1,
      '5': 5,
      '10': 'goroutineDiffTruncated'
    },
  ],
};

/// Descriptor for `DebugRuntimeStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List debugRuntimeStatsDescriptor = $convert.base64Decode(
    'ChFEZWJ1Z1J1bnRpbWVTdGF0cxIbCglyc3NfYnl0ZXMYASABKANSCHJzc0J5dGVzEi0KE2dvX2'
    'hlYXBfYWxsb2NfYnl0ZXMYAiABKANSEGdvSGVhcEFsbG9jQnl0ZXMSKQoRZ29faGVhcF9zeXNf'
    'Ynl0ZXMYAyABKANSDmdvSGVhcFN5c0J5dGVzEiAKDGdvX3N5c19ieXRlcxgEIAEoA1IKZ29TeX'
    'NCeXRlcxIvChRnb190b3RhbF9hbGxvY19ieXRlcxgFIAEoA1IRZ29Ub3RhbEFsbG9jQnl0ZXMS'
    'HgoLZ29fZ2NfY291bnQYBiABKANSCWdvR2NDb3VudBIjCg1nb19nb3JvdXRpbmVzGAcgASgDUg'
    'xnb0dvcm91dGluZXMSIAoMZ29fY2dvX2NhbGxzGAggASgDUgpnb0Nnb0NhbGxzEiYKD2dvX2hl'
    'YXBfb2JqZWN0cxgJIAEoA1INZ29IZWFwT2JqZWN0cxItChNnb19oZWFwX2ludXNlX2J5dGVzGA'
    'ogASgDUhBnb0hlYXBJbnVzZUJ5dGVzEi8KFGdvX3N0YWNrX2ludXNlX2J5dGVzGAsgASgDUhFn'
    'b1N0YWNrSW51c2VCeXRlcxIlCg51cHRpbWVfc2Vjb25kcxgMIAEoA1INdXB0aW1lU2Vjb25kcx'
    'IjCg1odWJfY29ubmVjdGVkGA0gASgIUgxodWJDb25uZWN0ZWQSJAoOaHViX2dycGNfc3RhdGUY'
    'DiABKAlSDGh1YkdycGNTdGF0ZRIfCgt0b3RhbF9ub2RlcxgPIAEoBVIKdG90YWxOb2RlcxIhCg'
    'xvbmxpbmVfbm9kZXMYECABKAVSC29ubGluZU5vZGVzEjYKF2RpcmVjdF9ncnBjX2Nvbm5lY3Rp'
    'b25zGBEgASgFUhVkaXJlY3RHcnBjQ29ubmVjdGlvbnMSTQoQZ3JwY19jb25uZWN0aW9ucxgSIA'
    'MoCzIiLm5pdGVsbGEubG9jYWwuRGVidWdHcnBjQ29ubmVjdGlvblIPZ3JwY0Nvbm5lY3Rpb25z'
    'Ej4KG2FwcHJvdmFsX3N0cmVhbV9zdWJzY3JpYmVycxgTIAEoBVIZYXBwcm92YWxTdHJlYW1TdW'
    'JzY3JpYmVycxJCCh1jb25uZWN0aW9uX3N0cmVhbV9zdWJzY3JpYmVycxgUIAEoBVIbY29ubmVj'
    'dGlvblN0cmVhbVN1YnNjcmliZXJzEjQKFnAycF9zdHJlYW1fc3Vic2NyaWJlcnMYFSABKAVSFH'
    'AycFN0cmVhbVN1YnNjcmliZXJzEj0KG2dvcm91dGluZV9kaWZmX2hhc19iYXNlbGluZRgWIAEo'
    'CFIYZ29yb3V0aW5lRGlmZkhhc0Jhc2VsaW5lEjkKGWdvcm91dGluZV9kaWZmX3ByZXZfdG90YW'
    'wYFyABKANSFmdvcm91dGluZURpZmZQcmV2VG90YWwSOQoZZ29yb3V0aW5lX2RpZmZfY3Vycl90'
    'b3RhbBgYIAEoA1IWZ29yb3V0aW5lRGlmZkN1cnJUb3RhbBIwChRnb3JvdXRpbmVfZGlmZl9kZW'
    'x0YRgZIAEoA1ISZ29yb3V0aW5lRGlmZkRlbHRhElwKFmdvcm91dGluZV9kaWZmX2VudHJpZXMY'
    'GiADKAsyJi5uaXRlbGxhLmxvY2FsLkRlYnVnR29yb3V0aW5lRGlmZkVudHJ5UhRnb3JvdXRpbm'
    'VEaWZmRW50cmllcxJPChZnb3JvdXRpbmVfZGlmZl9wcmV2X2F0GBsgASgLMhouZ29vZ2xlLnBy'
    'b3RvYnVmLlRpbWVzdGFtcFITZ29yb3V0aW5lRGlmZlByZXZBdBJPChZnb3JvdXRpbmVfZGlmZl'
    '9jdXJyX2F0GBwgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFITZ29yb3V0aW5lRGlm'
    'ZkN1cnJBdBI4Chhnb3JvdXRpbmVfZGlmZl90cnVuY2F0ZWQYHSABKAVSFmdvcm91dGluZURpZm'
    'ZUcnVuY2F0ZWQ=');

@$core.Deprecated('Use debugGrpcConnectionDescriptor instead')
const DebugGrpcConnection$json = {
  '1': 'DebugGrpcConnection',
  '2': [
    {'1': 'scope', '3': 1, '4': 1, '5': 9, '10': 'scope'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'address', '3': 3, '4': 1, '5': 9, '10': 'address'},
    {'1': 'state', '3': 4, '4': 1, '5': 9, '10': 'state'},
    {'1': 'connected', '3': 5, '4': 1, '5': 8, '10': 'connected'},
  ],
};

/// Descriptor for `DebugGrpcConnection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List debugGrpcConnectionDescriptor = $convert.base64Decode(
    'ChNEZWJ1Z0dycGNDb25uZWN0aW9uEhQKBXNjb3BlGAEgASgJUgVzY29wZRIXCgdub2RlX2lkGA'
    'IgASgJUgZub2RlSWQSGAoHYWRkcmVzcxgDIAEoCVIHYWRkcmVzcxIUCgVzdGF0ZRgEIAEoCVIF'
    'c3RhdGUSHAoJY29ubmVjdGVkGAUgASgIUgljb25uZWN0ZWQ=');

@$core.Deprecated('Use debugGoroutineDiffEntryDescriptor instead')
const DebugGoroutineDiffEntry$json = {
  '1': 'DebugGoroutineDiffEntry',
  '2': [
    {'1': 'signature', '3': 1, '4': 1, '5': 9, '10': 'signature'},
    {'1': 'prev_count', '3': 2, '4': 1, '5': 5, '10': 'prevCount'},
    {'1': 'curr_count', '3': 3, '4': 1, '5': 5, '10': 'currCount'},
    {'1': 'delta', '3': 4, '4': 1, '5': 5, '10': 'delta'},
  ],
};

/// Descriptor for `DebugGoroutineDiffEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List debugGoroutineDiffEntryDescriptor = $convert.base64Decode(
    'ChdEZWJ1Z0dvcm91dGluZURpZmZFbnRyeRIcCglzaWduYXR1cmUYASABKAlSCXNpZ25hdHVyZR'
    'IdCgpwcmV2X2NvdW50GAIgASgFUglwcmV2Q291bnQSHQoKY3Vycl9jb3VudBgDIAEoBVIJY3Vy'
    'ckNvdW50EhQKBWRlbHRhGAQgASgFUgVkZWx0YQ==');

@$core.Deprecated('Use getLogsStatsRequestDescriptor instead')
const GetLogsStatsRequest$json = {
  '1': 'GetLogsStatsRequest',
};

/// Descriptor for `GetLogsStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLogsStatsRequestDescriptor =
    $convert.base64Decode('ChNHZXRMb2dzU3RhdHNSZXF1ZXN0');

@$core.Deprecated('Use getLogsStatsResponseDescriptor instead')
const GetLogsStatsResponse$json = {
  '1': 'GetLogsStatsResponse',
  '2': [
    {'1': 'total_logs', '3': 1, '4': 1, '5': 3, '10': 'totalLogs'},
    {
      '1': 'total_storage_bytes',
      '3': 2,
      '4': 1,
      '5': 3,
      '10': 'totalStorageBytes'
    },
    {
      '1': 'oldest_log',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'oldestLog'
    },
    {
      '1': 'newest_log',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'newestLog'
    },
    {
      '1': 'logs_by_routing_token',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.GetLogsStatsResponse.LogsByRoutingTokenEntry',
      '10': 'logsByRoutingToken'
    },
    {
      '1': 'storage_by_routing_token',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.GetLogsStatsResponse.StorageByRoutingTokenEntry',
      '10': 'storageByRoutingToken'
    },
  ],
  '3': [
    GetLogsStatsResponse_LogsByRoutingTokenEntry$json,
    GetLogsStatsResponse_StorageByRoutingTokenEntry$json
  ],
};

@$core.Deprecated('Use getLogsStatsResponseDescriptor instead')
const GetLogsStatsResponse_LogsByRoutingTokenEntry$json = {
  '1': 'LogsByRoutingTokenEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 3, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use getLogsStatsResponseDescriptor instead')
const GetLogsStatsResponse_StorageByRoutingTokenEntry$json = {
  '1': 'StorageByRoutingTokenEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 3, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `GetLogsStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLogsStatsResponseDescriptor = $convert.base64Decode(
    'ChRHZXRMb2dzU3RhdHNSZXNwb25zZRIdCgp0b3RhbF9sb2dzGAEgASgDUgl0b3RhbExvZ3MSLg'
    'oTdG90YWxfc3RvcmFnZV9ieXRlcxgCIAEoA1IRdG90YWxTdG9yYWdlQnl0ZXMSOQoKb2xkZXN0'
    'X2xvZxgDIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCW9sZGVzdExvZxI5CgpuZX'
    'dlc3RfbG9nGAQgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJbmV3ZXN0TG9nEm4K'
    'FWxvZ3NfYnlfcm91dGluZ190b2tlbhgFIAMoCzI7Lm5pdGVsbGEubG9jYWwuR2V0TG9nc1N0YX'
    'RzUmVzcG9uc2UuTG9nc0J5Um91dGluZ1Rva2VuRW50cnlSEmxvZ3NCeVJvdXRpbmdUb2tlbhJ3'
    'ChhzdG9yYWdlX2J5X3JvdXRpbmdfdG9rZW4YBiADKAsyPi5uaXRlbGxhLmxvY2FsLkdldExvZ3'
    'NTdGF0c1Jlc3BvbnNlLlN0b3JhZ2VCeVJvdXRpbmdUb2tlbkVudHJ5UhVzdG9yYWdlQnlSb3V0'
    'aW5nVG9rZW4aRQoXTG9nc0J5Um91dGluZ1Rva2VuRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFA'
    'oFdmFsdWUYAiABKANSBXZhbHVlOgI4ARpIChpTdG9yYWdlQnlSb3V0aW5nVG9rZW5FbnRyeRIQ'
    'CgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoA1IFdmFsdWU6AjgB');

@$core.Deprecated('Use listLogsRequestDescriptor instead')
const ListLogsRequest$json = {
  '1': 'ListLogsRequest',
  '2': [
    {'1': 'routing_token', '3': 1, '4': 1, '5': 9, '10': 'routingToken'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'page_size', '3': 3, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 4, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListLogsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listLogsRequestDescriptor = $convert.base64Decode(
    'Cg9MaXN0TG9nc1JlcXVlc3QSIwoNcm91dGluZ190b2tlbhgBIAEoCVIMcm91dGluZ1Rva2VuEh'
    'cKB25vZGVfaWQYAiABKAlSBm5vZGVJZBIbCglwYWdlX3NpemUYAyABKAVSCHBhZ2VTaXplEh0K'
    'CnBhZ2VfdG9rZW4YBCABKAlSCXBhZ2VUb2tlbg==');

@$core.Deprecated('Use listLogsResponseDescriptor instead')
const ListLogsResponse$json = {
  '1': 'ListLogsResponse',
  '2': [
    {
      '1': 'logs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.LogEntry',
      '10': 'logs'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 3, '10': 'totalCount'},
    {'1': 'next_page_token', '3': 3, '4': 1, '5': 9, '10': 'nextPageToken'},
  ],
};

/// Descriptor for `ListLogsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listLogsResponseDescriptor = $convert.base64Decode(
    'ChBMaXN0TG9nc1Jlc3BvbnNlEisKBGxvZ3MYASADKAsyFy5uaXRlbGxhLmxvY2FsLkxvZ0VudH'
    'J5UgRsb2dzEh8KC3RvdGFsX2NvdW50GAIgASgDUgp0b3RhbENvdW50EiYKD25leHRfcGFnZV90'
    'b2tlbhgDIAEoCVINbmV4dFBhZ2VUb2tlbg==');

@$core.Deprecated('Use logEntryDescriptor instead')
const LogEntry$json = {
  '1': 'LogEntry',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'routing_token', '3': 3, '4': 1, '5': 9, '10': 'routingToken'},
    {
      '1': 'timestamp',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'encrypted_size_bytes',
      '3': 5,
      '4': 1,
      '5': 5,
      '10': 'encryptedSizeBytes'
    },
  ],
};

/// Descriptor for `LogEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logEntryDescriptor = $convert.base64Decode(
    'CghMb2dFbnRyeRIOCgJpZBgBIAEoA1ICaWQSFwoHbm9kZV9pZBgCIAEoCVIGbm9kZUlkEiMKDX'
    'JvdXRpbmdfdG9rZW4YAyABKAlSDHJvdXRpbmdUb2tlbhI4Cgl0aW1lc3RhbXAYBCABKAsyGi5n'
    'b29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXASMAoUZW5jcnlwdGVkX3NpemVfYn'
    'l0ZXMYBSABKAVSEmVuY3J5cHRlZFNpemVCeXRlcw==');

@$core.Deprecated('Use deleteLogsRequestDescriptor instead')
const DeleteLogsRequest$json = {
  '1': 'DeleteLogsRequest',
  '2': [
    {'1': 'routing_token', '3': 1, '4': 1, '5': 9, '10': 'routingToken'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'delete_all', '3': 3, '4': 1, '5': 8, '10': 'deleteAll'},
    {
      '1': 'before',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'before'
    },
  ],
};

/// Descriptor for `DeleteLogsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteLogsRequestDescriptor = $convert.base64Decode(
    'ChFEZWxldGVMb2dzUmVxdWVzdBIjCg1yb3V0aW5nX3Rva2VuGAEgASgJUgxyb3V0aW5nVG9rZW'
    '4SFwoHbm9kZV9pZBgCIAEoCVIGbm9kZUlkEh0KCmRlbGV0ZV9hbGwYAyABKAhSCWRlbGV0ZUFs'
    'bBIyCgZiZWZvcmUYBCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgZiZWZvcmU=');

@$core.Deprecated('Use deleteLogsResponseDescriptor instead')
const DeleteLogsResponse$json = {
  '1': 'DeleteLogsResponse',
  '2': [
    {'1': 'deleted_count', '3': 1, '4': 1, '5': 3, '10': 'deletedCount'},
    {'1': 'freed_bytes', '3': 2, '4': 1, '5': 3, '10': 'freedBytes'},
  ],
};

/// Descriptor for `DeleteLogsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteLogsResponseDescriptor = $convert.base64Decode(
    'ChJEZWxldGVMb2dzUmVzcG9uc2USIwoNZGVsZXRlZF9jb3VudBgBIAEoA1IMZGVsZXRlZENvdW'
    '50Eh8KC2ZyZWVkX2J5dGVzGAIgASgDUgpmcmVlZEJ5dGVz');

@$core.Deprecated('Use cleanupOldLogsRequestDescriptor instead')
const CleanupOldLogsRequest$json = {
  '1': 'CleanupOldLogsRequest',
  '2': [
    {'1': 'older_than_days', '3': 1, '4': 1, '5': 5, '10': 'olderThanDays'},
    {'1': 'dry_run', '3': 2, '4': 1, '5': 8, '10': 'dryRun'},
  ],
};

/// Descriptor for `CleanupOldLogsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cleanupOldLogsRequestDescriptor = $convert.base64Decode(
    'ChVDbGVhbnVwT2xkTG9nc1JlcXVlc3QSJgoPb2xkZXJfdGhhbl9kYXlzGAEgASgFUg1vbGRlcl'
    'RoYW5EYXlzEhcKB2RyeV9ydW4YAiABKAhSBmRyeVJ1bg==');

@$core.Deprecated('Use cleanupOldLogsResponseDescriptor instead')
const CleanupOldLogsResponse$json = {
  '1': 'CleanupOldLogsResponse',
  '2': [
    {'1': 'deleted_count', '3': 1, '4': 1, '5': 3, '10': 'deletedCount'},
    {'1': 'freed_bytes', '3': 2, '4': 1, '5': 3, '10': 'freedBytes'},
    {
      '1': 'deleted_by_routing_token',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.nitella.local.CleanupOldLogsResponse.DeletedByRoutingTokenEntry',
      '10': 'deletedByRoutingToken'
    },
  ],
  '3': [CleanupOldLogsResponse_DeletedByRoutingTokenEntry$json],
};

@$core.Deprecated('Use cleanupOldLogsResponseDescriptor instead')
const CleanupOldLogsResponse_DeletedByRoutingTokenEntry$json = {
  '1': 'DeletedByRoutingTokenEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 3, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CleanupOldLogsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cleanupOldLogsResponseDescriptor = $convert.base64Decode(
    'ChZDbGVhbnVwT2xkTG9nc1Jlc3BvbnNlEiMKDWRlbGV0ZWRfY291bnQYASABKANSDGRlbGV0ZW'
    'RDb3VudBIfCgtmcmVlZF9ieXRlcxgCIAEoA1IKZnJlZWRCeXRlcxJ5ChhkZWxldGVkX2J5X3Jv'
    'dXRpbmdfdG9rZW4YAyADKAsyQC5uaXRlbGxhLmxvY2FsLkNsZWFudXBPbGRMb2dzUmVzcG9uc2'
    'UuRGVsZXRlZEJ5Um91dGluZ1Rva2VuRW50cnlSFWRlbGV0ZWRCeVJvdXRpbmdUb2tlbhpIChpE'
    'ZWxldGVkQnlSb3V0aW5nVG9rZW5FbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIA'
    'EoA1IFdmFsdWU6AjgB');

@$core.Deprecated('Use getNodeFromHubRequestDescriptor instead')
const GetNodeFromHubRequest$json = {
  '1': 'GetNodeFromHubRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `GetNodeFromHubRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNodeFromHubRequestDescriptor =
    $convert.base64Decode(
        'ChVHZXROb2RlRnJvbUh1YlJlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlk');

@$core.Deprecated('Use getNodeFromHubResponseDescriptor instead')
const GetNodeFromHubResponse$json = {
  '1': 'GetNodeFromHubResponse',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {
      '1': 'last_seen',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastSeen'
    },
    {'1': 'public_ip', '3': 4, '4': 1, '5': 9, '10': 'publicIp'},
    {'1': 'version', '3': 5, '4': 1, '5': 9, '10': 'version'},
    {'1': 'geoip_enabled', '3': 6, '4': 1, '5': 8, '10': 'geoipEnabled'},
  ],
};

/// Descriptor for `GetNodeFromHubResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNodeFromHubResponseDescriptor = $convert.base64Decode(
    'ChZHZXROb2RlRnJvbUh1YlJlc3BvbnNlEhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBIWCgZzdG'
    'F0dXMYAiABKAlSBnN0YXR1cxI3CglsYXN0X3NlZW4YAyABKAsyGi5nb29nbGUucHJvdG9idWYu'
    'VGltZXN0YW1wUghsYXN0U2VlbhIbCglwdWJsaWNfaXAYBCABKAlSCHB1YmxpY0lwEhgKB3Zlcn'
    'Npb24YBSABKAlSB3ZlcnNpb24SIwoNZ2VvaXBfZW5hYmxlZBgGIAEoCFIMZ2VvaXBFbmFibGVk');

@$core.Deprecated('Use registerNodeWithHubRequestDescriptor instead')
const RegisterNodeWithHubRequest$json = {
  '1': 'RegisterNodeWithHubRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'cert_pem', '3': 2, '4': 1, '5': 9, '10': 'certPem'},
    {'1': 'routing_token', '3': 3, '4': 1, '5': 9, '10': 'routingToken'},
  ],
};

/// Descriptor for `RegisterNodeWithHubRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerNodeWithHubRequestDescriptor =
    $convert.base64Decode(
        'ChpSZWdpc3Rlck5vZGVXaXRoSHViUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSGQ'
        'oIY2VydF9wZW0YAiABKAlSB2NlcnRQZW0SIwoNcm91dGluZ190b2tlbhgDIAEoCVIMcm91dGlu'
        'Z1Rva2Vu');

@$core.Deprecated('Use registerNodeWithHubResponseDescriptor instead')
const RegisterNodeWithHubResponse$json = {
  '1': 'RegisterNodeWithHubResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'routing_token', '3': 3, '4': 1, '5': 9, '10': 'routingToken'},
  ],
};

/// Descriptor for `RegisterNodeWithHubResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerNodeWithHubResponseDescriptor =
    $convert.base64Decode(
        'ChtSZWdpc3Rlck5vZGVXaXRoSHViUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcx'
        'IUCgVlcnJvchgCIAEoCVIFZXJyb3ISIwoNcm91dGluZ190b2tlbhgDIAEoCVIMcm91dGluZ1Rv'
        'a2Vu');
