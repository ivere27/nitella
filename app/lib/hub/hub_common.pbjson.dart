// This is a generated file - do not edit.
//
// Generated from hub/hub_common.proto.

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

@$core.Deprecated('Use registrationStatusDescriptor instead')
const RegistrationStatus$json = {
  '1': 'RegistrationStatus',
  '2': [
    {'1': 'REGISTRATION_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'REGISTRATION_STATUS_PENDING', '2': 1},
    {'1': 'REGISTRATION_STATUS_APPROVED', '2': 2},
    {'1': 'REGISTRATION_STATUS_REJECTED', '2': 3},
  ],
};

/// Descriptor for `RegistrationStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List registrationStatusDescriptor = $convert.base64Decode(
    'ChJSZWdpc3RyYXRpb25TdGF0dXMSIwofUkVHSVNUUkFUSU9OX1NUQVRVU19VTlNQRUNJRklFRB'
    'AAEh8KG1JFR0lTVFJBVElPTl9TVEFUVVNfUEVORElORxABEiAKHFJFR0lTVFJBVElPTl9TVEFU'
    'VVNfQVBQUk9WRUQQAhIgChxSRUdJU1RSQVRJT05fU1RBVFVTX1JFSkVDVEVEEAM=');

@$core.Deprecated('Use nodeStatusDescriptor instead')
const NodeStatus$json = {
  '1': 'NodeStatus',
  '2': [
    {'1': 'NODE_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'NODE_STATUS_OFFLINE', '2': 1},
    {'1': 'NODE_STATUS_ONLINE', '2': 2},
    {'1': 'NODE_STATUS_BLOCKED', '2': 3},
    {'1': 'NODE_STATUS_CONNECTING', '2': 4},
  ],
};

/// Descriptor for `NodeStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List nodeStatusDescriptor = $convert.base64Decode(
    'CgpOb2RlU3RhdHVzEhsKF05PREVfU1RBVFVTX1VOU1BFQ0lGSUVEEAASFwoTTk9ERV9TVEFUVV'
    'NfT0ZGTElORRABEhYKEk5PREVfU1RBVFVTX09OTElORRACEhcKE05PREVfU1RBVFVTX0JMT0NL'
    'RUQQAxIaChZOT0RFX1NUQVRVU19DT05ORUNUSU5HEAQ=');

@$core.Deprecated('Use commandTypeDescriptor instead')
const CommandType$json = {
  '1': 'CommandType',
  '2': [
    {'1': 'COMMAND_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'COMMAND_TYPE_ADD_RULE', '2': 2},
    {'1': 'COMMAND_TYPE_REMOVE_RULE', '2': 3},
    {'1': 'COMMAND_TYPE_GET_ACTIVE_CONNECTIONS', '2': 4},
    {'1': 'COMMAND_TYPE_CLOSE_CONNECTION', '2': 5},
    {'1': 'COMMAND_TYPE_CLOSE_ALL_CONNECTIONS', '2': 6},
    {'1': 'COMMAND_TYPE_STATS_CONTROL', '2': 7},
    {'1': 'COMMAND_TYPE_LIST_PROXIES', '2': 8},
    {'1': 'COMMAND_TYPE_LIST_RULES', '2': 9},
    {'1': 'COMMAND_TYPE_STATUS', '2': 10},
    {'1': 'COMMAND_TYPE_GET_METRICS', '2': 11},
    {'1': 'COMMAND_TYPE_APPLY_PROXY', '2': 20},
    {'1': 'COMMAND_TYPE_UNAPPLY_PROXY', '2': 21},
    {'1': 'COMMAND_TYPE_GET_APPLIED', '2': 22},
    {'1': 'COMMAND_TYPE_PROXY_UPDATE', '2': 23},
    {'1': 'COMMAND_TYPE_RESOLVE_APPROVAL', '2': 30},
    {'1': 'COMMAND_TYPE_CREATE_PROXY', '2': 40},
    {'1': 'COMMAND_TYPE_DELETE_PROXY', '2': 41},
    {'1': 'COMMAND_TYPE_ENABLE_PROXY', '2': 42},
    {'1': 'COMMAND_TYPE_DISABLE_PROXY', '2': 43},
    {'1': 'COMMAND_TYPE_UPDATE_PROXY', '2': 44},
    {'1': 'COMMAND_TYPE_RESTART_LISTENERS', '2': 45},
    {'1': 'COMMAND_TYPE_RELOAD_RULES', '2': 46},
    {'1': 'COMMAND_TYPE_BLOCK_IP', '2': 50},
    {'1': 'COMMAND_TYPE_ALLOW_IP', '2': 51},
    {'1': 'COMMAND_TYPE_LIST_GLOBAL_RULES', '2': 52},
    {'1': 'COMMAND_TYPE_REMOVE_GLOBAL_RULE', '2': 53},
    {'1': 'COMMAND_TYPE_CONFIGURE_GEOIP', '2': 60},
    {'1': 'COMMAND_TYPE_GET_GEOIP_STATUS', '2': 61},
    {'1': 'COMMAND_TYPE_LOOKUP_IP', '2': 62},
    {'1': 'COMMAND_TYPE_LIST_ACTIVE_APPROVALS', '2': 70},
    {'1': 'COMMAND_TYPE_CANCEL_APPROVAL', '2': 71},
  ],
  '4': [
    {'1': 1, '2': 1},
  ],
};

/// Descriptor for `CommandType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List commandTypeDescriptor = $convert.base64Decode(
    'CgtDb21tYW5kVHlwZRIcChhDT01NQU5EX1RZUEVfVU5TUEVDSUZJRUQQABIZChVDT01NQU5EX1'
    'RZUEVfQUREX1JVTEUQAhIcChhDT01NQU5EX1RZUEVfUkVNT1ZFX1JVTEUQAxInCiNDT01NQU5E'
    'X1RZUEVfR0VUX0FDVElWRV9DT05ORUNUSU9OUxAEEiEKHUNPTU1BTkRfVFlQRV9DTE9TRV9DT0'
    '5ORUNUSU9OEAUSJgoiQ09NTUFORF9UWVBFX0NMT1NFX0FMTF9DT05ORUNUSU9OUxAGEh4KGkNP'
    'TU1BTkRfVFlQRV9TVEFUU19DT05UUk9MEAcSHQoZQ09NTUFORF9UWVBFX0xJU1RfUFJPWElFUx'
    'AIEhsKF0NPTU1BTkRfVFlQRV9MSVNUX1JVTEVTEAkSFwoTQ09NTUFORF9UWVBFX1NUQVRVUxAK'
    'EhwKGENPTU1BTkRfVFlQRV9HRVRfTUVUUklDUxALEhwKGENPTU1BTkRfVFlQRV9BUFBMWV9QUk'
    '9YWRAUEh4KGkNPTU1BTkRfVFlQRV9VTkFQUExZX1BST1hZEBUSHAoYQ09NTUFORF9UWVBFX0dF'
    'VF9BUFBMSUVEEBYSHQoZQ09NTUFORF9UWVBFX1BST1hZX1VQREFURRAXEiEKHUNPTU1BTkRfVF'
    'lQRV9SRVNPTFZFX0FQUFJPVkFMEB4SHQoZQ09NTUFORF9UWVBFX0NSRUFURV9QUk9YWRAoEh0K'
    'GUNPTU1BTkRfVFlQRV9ERUxFVEVfUFJPWFkQKRIdChlDT01NQU5EX1RZUEVfRU5BQkxFX1BST1'
    'hZECoSHgoaQ09NTUFORF9UWVBFX0RJU0FCTEVfUFJPWFkQKxIdChlDT01NQU5EX1RZUEVfVVBE'
    'QVRFX1BST1hZECwSIgoeQ09NTUFORF9UWVBFX1JFU1RBUlRfTElTVEVORVJTEC0SHQoZQ09NTU'
    'FORF9UWVBFX1JFTE9BRF9SVUxFUxAuEhkKFUNPTU1BTkRfVFlQRV9CTE9DS19JUBAyEhkKFUNP'
    'TU1BTkRfVFlQRV9BTExPV19JUBAzEiIKHkNPTU1BTkRfVFlQRV9MSVNUX0dMT0JBTF9SVUxFUx'
    'A0EiMKH0NPTU1BTkRfVFlQRV9SRU1PVkVfR0xPQkFMX1JVTEUQNRIgChxDT01NQU5EX1RZUEVf'
    'Q09ORklHVVJFX0dFT0lQEDwSIQodQ09NTUFORF9UWVBFX0dFVF9HRU9JUF9TVEFUVVMQPRIaCh'
    'ZDT01NQU5EX1RZUEVfTE9PS1VQX0lQED4SJgoiQ09NTUFORF9UWVBFX0xJU1RfQUNUSVZFX0FQ'
    'UFJPVkFMUxBGEiAKHENPTU1BTkRfVFlQRV9DQU5DRUxfQVBQUk9WQUwQRyIECAEQAQ==');

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor =
    $convert.base64Decode('CgVFbXB0eQ==');

@$core.Deprecated('Use nodeDescriptor instead')
const Node$json = {
  '1': 'Node',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'encrypted_metadata',
      '3': 2,
      '4': 1,
      '5': 12,
      '10': 'encryptedMetadata'
    },
    {'1': 'owner_id', '3': 3, '4': 1, '5': 9, '10': 'ownerId'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.nitella.hub.NodeStatus',
      '10': 'status'
    },
    {
      '1': 'last_seen',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastSeen'
    },
    {'1': 'public_ip', '3': 6, '4': 1, '5': 9, '10': 'publicIp'},
    {'1': 'listen_ports', '3': 7, '4': 3, '5': 5, '10': 'listenPorts'},
    {'1': 'geoip_enabled', '3': 8, '4': 1, '5': 8, '10': 'geoipEnabled'},
    {'1': 'version', '3': 9, '4': 1, '5': 9, '10': 'version'},
    {
      '1': 'created_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `Node`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeDescriptor = $convert.base64Decode(
    'CgROb2RlEg4KAmlkGAEgASgJUgJpZBItChJlbmNyeXB0ZWRfbWV0YWRhdGEYAiABKAxSEWVuY3'
    'J5cHRlZE1ldGFkYXRhEhkKCG93bmVyX2lkGAMgASgJUgdvd25lcklkEi8KBnN0YXR1cxgEIAEo'
    'DjIXLm5pdGVsbGEuaHViLk5vZGVTdGF0dXNSBnN0YXR1cxI3CglsYXN0X3NlZW4YBSABKAsyGi'
    '5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUghsYXN0U2VlbhIbCglwdWJsaWNfaXAYBiABKAlS'
    'CHB1YmxpY0lwEiEKDGxpc3Rlbl9wb3J0cxgHIAMoBVILbGlzdGVuUG9ydHMSIwoNZ2VvaXBfZW'
    '5hYmxlZBgIIAEoCFIMZ2VvaXBFbmFibGVkEhgKB3ZlcnNpb24YCSABKAlSB3ZlcnNpb24SOQoK'
    'Y3JlYXRlZF9hdBgKIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdA'
    '==');

@$core.Deprecated('Use metricsDescriptor instead')
const Metrics$json = {
  '1': 'Metrics',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'connections_active',
      '3': 3,
      '4': 1,
      '5': 3,
      '10': 'connectionsActive'
    },
    {
      '1': 'connections_total',
      '3': 4,
      '4': 1,
      '5': 3,
      '10': 'connectionsTotal'
    },
    {'1': 'bytes_in', '3': 5, '4': 1, '5': 3, '10': 'bytesIn'},
    {'1': 'bytes_out', '3': 6, '4': 1, '5': 3, '10': 'bytesOut'},
    {'1': 'blocked_count', '3': 7, '4': 1, '5': 3, '10': 'blockedCount'},
    {
      '1': 'rules_hit_count',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.Metrics.RulesHitCountEntry',
      '10': 'rulesHitCount'
    },
  ],
  '3': [Metrics_RulesHitCountEntry$json],
};

@$core.Deprecated('Use metricsDescriptor instead')
const Metrics_RulesHitCountEntry$json = {
  '1': 'RulesHitCountEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 3, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Metrics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List metricsDescriptor = $convert.base64Decode(
    'CgdNZXRyaWNzEhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBI4Cgl0aW1lc3RhbXAYAiABKAsyGi'
    '5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXASLQoSY29ubmVjdGlvbnNfYWN0'
    'aXZlGAMgASgDUhFjb25uZWN0aW9uc0FjdGl2ZRIrChFjb25uZWN0aW9uc190b3RhbBgEIAEoA1'
    'IQY29ubmVjdGlvbnNUb3RhbBIZCghieXRlc19pbhgFIAEoA1IHYnl0ZXNJbhIbCglieXRlc19v'
    'dXQYBiABKANSCGJ5dGVzT3V0EiMKDWJsb2NrZWRfY291bnQYByABKANSDGJsb2NrZWRDb3VudB'
    'JPCg9ydWxlc19oaXRfY291bnQYCCADKAsyJy5uaXRlbGxhLmh1Yi5NZXRyaWNzLlJ1bGVzSGl0'
    'Q291bnRFbnRyeVINcnVsZXNIaXRDb3VudBpAChJSdWxlc0hpdENvdW50RW50cnkSEAoDa2V5GA'
    'EgASgJUgNrZXkSFAoFdmFsdWUYAiABKANSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use encryptedMetricsDescriptor instead')
const EncryptedMetrics$json = {
  '1': 'EncryptedMetrics',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'encrypted',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.EncryptedPayload',
      '10': 'encrypted'
    },
  ],
};

/// Descriptor for `EncryptedMetrics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encryptedMetricsDescriptor = $convert.base64Decode(
    'ChBFbmNyeXB0ZWRNZXRyaWNzEhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBI4Cgl0aW1lc3RhbX'
    'AYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXASNwoJZW5jcnlw'
    'dGVkGAMgASgLMhkubml0ZWxsYS5FbmNyeXB0ZWRQYXlsb2FkUgllbmNyeXB0ZWQ=');

@$core.Deprecated('Use logEntryDescriptor instead')
const LogEntry$json = {
  '1': 'LogEntry',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'level', '3': 3, '4': 1, '5': 9, '10': 'level'},
    {'1': 'message', '3': 4, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'fields',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.LogEntry.FieldsEntry',
      '10': 'fields'
    },
  ],
  '3': [LogEntry_FieldsEntry$json],
};

@$core.Deprecated('Use logEntryDescriptor instead')
const LogEntry_FieldsEntry$json = {
  '1': 'FieldsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `LogEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logEntryDescriptor = $convert.base64Decode(
    'CghMb2dFbnRyeRIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSOAoJdGltZXN0YW1wGAIgASgLMh'
    'ouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wEhQKBWxldmVsGAMgASgJUgVs'
    'ZXZlbBIYCgdtZXNzYWdlGAQgASgJUgdtZXNzYWdlEjkKBmZpZWxkcxgFIAMoCzIhLm5pdGVsbG'
    'EuaHViLkxvZ0VudHJ5LkZpZWxkc0VudHJ5UgZmaWVsZHMaOQoLRmllbGRzRW50cnkSEAoDa2V5'
    'GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use encryptedLogEntryDescriptor instead')
const EncryptedLogEntry$json = {
  '1': 'EncryptedLogEntry',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'encrypted',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.EncryptedPayload',
      '10': 'encrypted'
    },
  ],
};

/// Descriptor for `EncryptedLogEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encryptedLogEntryDescriptor = $convert.base64Decode(
    'ChFFbmNyeXB0ZWRMb2dFbnRyeRIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSOAoJdGltZXN0YW'
    '1wGAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wEjcKCWVuY3J5'
    'cHRlZBgDIAEoCzIZLm5pdGVsbGEuRW5jcnlwdGVkUGF5bG9hZFIJZW5jcnlwdGVk');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'blind_index', '3': 2, '4': 1, '5': 9, '10': 'blindIndex'},
    {
      '1': 'encrypted_profile',
      '3': 3,
      '4': 1,
      '5': 12,
      '10': 'encryptedProfile'
    },
    {'1': 'role', '3': 4, '4': 1, '5': 9, '10': 'role'},
    {'1': 'tier', '3': 5, '4': 1, '5': 9, '10': 'tier'},
    {'1': 'max_nodes', '3': 6, '4': 1, '5': 5, '10': 'maxNodes'},
    {
      '1': 'last_login',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastLogin'
    },
    {
      '1': 'created_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEg4KAmlkGAEgASgJUgJpZBIfCgtibGluZF9pbmRleBgCIAEoCVIKYmxpbmRJbmRleB'
    'IrChFlbmNyeXB0ZWRfcHJvZmlsZRgDIAEoDFIQZW5jcnlwdGVkUHJvZmlsZRISCgRyb2xlGAQg'
    'ASgJUgRyb2xlEhIKBHRpZXIYBSABKAlSBHRpZXISGwoJbWF4X25vZGVzGAYgASgFUghtYXhOb2'
    'RlcxI5CgpsYXN0X2xvZ2luGAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJbGFz'
    'dExvZ2luEjkKCmNyZWF0ZWRfYXQYCCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUg'
    'ljcmVhdGVkQXQ=');

@$core.Deprecated('Use commandResponseDescriptor instead')
const CommandResponse$json = {
  '1': 'CommandResponse',
  '2': [
    {'1': 'command_id', '3': 1, '4': 1, '5': 9, '10': 'commandId'},
    {
      '1': 'encrypted_data',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.nitella.EncryptedPayload',
      '10': 'encryptedData'
    },
  ],
};

/// Descriptor for `CommandResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandResponseDescriptor = $convert.base64Decode(
    'Cg9Db21tYW5kUmVzcG9uc2USHQoKY29tbWFuZF9pZBgBIAEoCVIJY29tbWFuZElkEkAKDmVuY3'
    'J5cHRlZF9kYXRhGAIgASgLMhkubml0ZWxsYS5FbmNyeXB0ZWRQYXlsb2FkUg1lbmNyeXB0ZWRE'
    'YXRh');

@$core.Deprecated('Use commandResultDescriptor instead')
const CommandResult$json = {
  '1': 'CommandResult',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
    {'1': 'response_payload', '3': 3, '4': 1, '5': 12, '10': 'responsePayload'},
  ],
};

/// Descriptor for `CommandResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandResultDescriptor = $convert.base64Decode(
    'Cg1Db21tYW5kUmVzdWx0EhYKBnN0YXR1cxgBIAEoCVIGc3RhdHVzEiMKDWVycm9yX21lc3NhZ2'
    'UYAiABKAlSDGVycm9yTWVzc2FnZRIpChByZXNwb25zZV9wYXlsb2FkGAMgASgMUg9yZXNwb25z'
    'ZVBheWxvYWQ=');

@$core.Deprecated('Use commandDescriptor instead')
const Command$json = {
  '1': 'Command',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'encrypted',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.nitella.EncryptedPayload',
      '10': 'encrypted'
    },
    {
      '1': 'expires_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiresAt'
    },
  ],
};

/// Descriptor for `Command`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandDescriptor = $convert.base64Decode(
    'CgdDb21tYW5kEg4KAmlkGAEgASgJUgJpZBI3CgllbmNyeXB0ZWQYAiABKAsyGS5uaXRlbGxhLk'
    'VuY3J5cHRlZFBheWxvYWRSCWVuY3J5cHRlZBI5CgpleHBpcmVzX2F0GAMgASgLMhouZ29vZ2xl'
    'LnByb3RvYnVmLlRpbWVzdGFtcFIJZXhwaXJlc0F0');

@$core.Deprecated('Use encryptedCommandPayloadDescriptor instead')
const EncryptedCommandPayload$json = {
  '1': 'EncryptedCommandPayload',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.nitella.hub.CommandType',
      '10': 'type'
    },
    {'1': 'payload', '3': 2, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `EncryptedCommandPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encryptedCommandPayloadDescriptor =
    $convert.base64Decode(
        'ChdFbmNyeXB0ZWRDb21tYW5kUGF5bG9hZBIsCgR0eXBlGAEgASgOMhgubml0ZWxsYS5odWIuQ2'
        '9tbWFuZFR5cGVSBHR5cGUSGAoHcGF5bG9hZBgCIAEoDFIHcGF5bG9hZA==');

@$core.Deprecated('Use revocationEventDescriptor instead')
const RevocationEvent$json = {
  '1': 'RevocationEvent',
  '2': [
    {'1': 'serial_number', '3': 1, '4': 1, '5': 9, '10': 'serialNumber'},
    {'1': 'fingerprint', '3': 2, '4': 1, '5': 9, '10': 'fingerprint'},
    {
      '1': 'revoked_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'revokedAt'
    },
    {'1': 'reason', '3': 4, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `RevocationEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revocationEventDescriptor = $convert.base64Decode(
    'Cg9SZXZvY2F0aW9uRXZlbnQSIwoNc2VyaWFsX251bWJlchgBIAEoCVIMc2VyaWFsTnVtYmVyEi'
    'AKC2ZpbmdlcnByaW50GAIgASgJUgtmaW5nZXJwcmludBI5CgpyZXZva2VkX2F0GAMgASgLMhou'
    'Z29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJcmV2b2tlZEF0EhYKBnJlYXNvbhgEIAEoCVIGcm'
    'Vhc29u');

@$core.Deprecated('Use signalMessageDescriptor instead')
const SignalMessage$json = {
  '1': 'SignalMessage',
  '2': [
    {'1': 'target_id', '3': 1, '4': 1, '5': 9, '10': 'targetId'},
    {'1': 'source_id', '3': 2, '4': 1, '5': 9, '10': 'sourceId'},
    {'1': 'type', '3': 3, '4': 1, '5': 9, '10': 'type'},
    {'1': 'payload', '3': 4, '4': 1, '5': 9, '10': 'payload'},
    {'1': 'source_user_id', '3': 5, '4': 1, '5': 9, '10': 'sourceUserId'},
  ],
};

/// Descriptor for `SignalMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signalMessageDescriptor = $convert.base64Decode(
    'Cg1TaWduYWxNZXNzYWdlEhsKCXRhcmdldF9pZBgBIAEoCVIIdGFyZ2V0SWQSGwoJc291cmNlX2'
    'lkGAIgASgJUghzb3VyY2VJZBISCgR0eXBlGAMgASgJUgR0eXBlEhgKB3BheWxvYWQYBCABKAlS'
    'B3BheWxvYWQSJAoOc291cmNlX3VzZXJfaWQYBSABKAlSDHNvdXJjZVVzZXJJZA==');

@$core.Deprecated('Use pairingRequestDescriptor instead')
const PairingRequest$json = {
  '1': 'PairingRequest',
  '2': [
    {'1': 'csr_pem', '3': 1, '4': 1, '5': 9, '10': 'csrPem'},
    {'1': 'node_public_key', '3': 2, '4': 1, '5': 12, '10': 'nodePublicKey'},
    {'1': 'node_version', '3': 3, '4': 1, '5': 9, '10': 'nodeVersion'},
  ],
};

/// Descriptor for `PairingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pairingRequestDescriptor = $convert.base64Decode(
    'Cg5QYWlyaW5nUmVxdWVzdBIXCgdjc3JfcGVtGAEgASgJUgZjc3JQZW0SJgoPbm9kZV9wdWJsaW'
    'Nfa2V5GAIgASgMUg1ub2RlUHVibGljS2V5EiEKDG5vZGVfdmVyc2lvbhgDIAEoCVILbm9kZVZl'
    'cnNpb24=');

@$core.Deprecated('Use pairingResponseDescriptor instead')
const PairingResponse$json = {
  '1': 'PairingResponse',
  '2': [
    {'1': 'cert_pem', '3': 1, '4': 1, '5': 9, '10': 'certPem'},
    {'1': 'ca_pem', '3': 2, '4': 1, '5': 9, '10': 'caPem'},
    {
      '1': 'viewer_public_key',
      '3': 3,
      '4': 1,
      '5': 12,
      '10': 'viewerPublicKey'
    },
    {'1': 'routing_token', '3': 4, '4': 1, '5': 9, '10': 'routingToken'},
  ],
};

/// Descriptor for `PairingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pairingResponseDescriptor = $convert.base64Decode(
    'Cg9QYWlyaW5nUmVzcG9uc2USGQoIY2VydF9wZW0YASABKAlSB2NlcnRQZW0SFQoGY2FfcGVtGA'
    'IgASgJUgVjYVBlbRIqChF2aWV3ZXJfcHVibGljX2tleRgDIAEoDFIPdmlld2VyUHVibGljS2V5'
    'EiMKDXJvdXRpbmdfdG9rZW4YBCABKAlSDHJvdXRpbmdUb2tlbg==');
