// This is a generated file - do not edit.
//
// Generated from hub/hub_mobile.proto.

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

@$core.Deprecated('Use registerNodeViaCSRRequestDescriptor instead')
const RegisterNodeViaCSRRequest$json = {
  '1': 'RegisterNodeViaCSRRequest',
  '2': [
    {'1': 'cert_pem', '3': 1, '4': 1, '5': 9, '10': 'certPem'},
    {
      '1': 'encrypted_metadata',
      '3': 2,
      '4': 1,
      '5': 12,
      '10': 'encryptedMetadata'
    },
    {'1': 'node_id', '3': 3, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `RegisterNodeViaCSRRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerNodeViaCSRRequestDescriptor = $convert.base64Decode(
    'ChlSZWdpc3Rlck5vZGVWaWFDU1JSZXF1ZXN0EhkKCGNlcnRfcGVtGAEgASgJUgdjZXJ0UGVtEi'
    '0KEmVuY3J5cHRlZF9tZXRhZGF0YRgCIAEoDFIRZW5jcnlwdGVkTWV0YWRhdGESFwoHbm9kZV9p'
    'ZBgDIAEoCVIGbm9kZUlk');

@$core.Deprecated('Use registerNodeWithCertRequestDescriptor instead')
const RegisterNodeWithCertRequest$json = {
  '1': 'RegisterNodeWithCertRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'cert_pem', '3': 2, '4': 1, '5': 9, '10': 'certPem'},
    {'1': 'routing_token', '3': 3, '4': 1, '5': 9, '10': 'routingToken'},
    {
      '1': 'encrypted_metadata',
      '3': 4,
      '4': 1,
      '5': 12,
      '10': 'encryptedMetadata'
    },
  ],
};

/// Descriptor for `RegisterNodeWithCertRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerNodeWithCertRequestDescriptor = $convert.base64Decode(
    'ChtSZWdpc3Rlck5vZGVXaXRoQ2VydFJlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlkEh'
    'kKCGNlcnRfcGVtGAIgASgJUgdjZXJ0UGVtEiMKDXJvdXRpbmdfdG9rZW4YAyABKAlSDHJvdXRp'
    'bmdUb2tlbhItChJlbmNyeXB0ZWRfbWV0YWRhdGEYBCABKAxSEWVuY3J5cHRlZE1ldGFkYXRh');

@$core.Deprecated('Use listNodesRequestDescriptor instead')
const ListNodesRequest$json = {
  '1': 'ListNodesRequest',
  '2': [
    {'1': 'filter', '3': 1, '4': 1, '5': 9, '10': 'filter'},
    {'1': 'routing_tokens', '3': 2, '4': 3, '5': 9, '10': 'routingTokens'},
  ],
};

/// Descriptor for `ListNodesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listNodesRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0Tm9kZXNSZXF1ZXN0EhYKBmZpbHRlchgBIAEoCVIGZmlsdGVyEiUKDnJvdXRpbmdfdG'
    '9rZW5zGAIgAygJUg1yb3V0aW5nVG9rZW5z');

@$core.Deprecated('Use listNodesResponseDescriptor instead')
const ListNodesResponse$json = {
  '1': 'ListNodesResponse',
  '2': [
    {
      '1': 'nodes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.Node',
      '10': 'nodes'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListNodesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listNodesResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0Tm9kZXNSZXNwb25zZRInCgVub2RlcxgBIAMoCzIRLm5pdGVsbGEuaHViLk5vZGVSBW'
    '5vZGVzEh8KC3RvdGFsX2NvdW50GAIgASgFUgp0b3RhbENvdW50');

@$core.Deprecated('Use getNodeRequestDescriptor instead')
const GetNodeRequest$json = {
  '1': 'GetNodeRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'routing_token', '3': 2, '4': 1, '5': 9, '10': 'routingToken'},
  ],
};

/// Descriptor for `GetNodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNodeRequestDescriptor = $convert.base64Decode(
    'Cg5HZXROb2RlUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSIwoNcm91dGluZ190b2'
    'tlbhgCIAEoCVIMcm91dGluZ1Rva2Vu');

@$core.Deprecated('Use registerNodeRequestDescriptor instead')
const RegisterNodeRequest$json = {
  '1': 'RegisterNodeRequest',
  '2': [
    {
      '1': 'registration_code',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'registrationCode'
    },
  ],
};

/// Descriptor for `RegisterNodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerNodeRequestDescriptor = $convert.base64Decode(
    'ChNSZWdpc3Rlck5vZGVSZXF1ZXN0EisKEXJlZ2lzdHJhdGlvbl9jb2RlGAEgASgJUhByZWdpc3'
    'RyYXRpb25Db2Rl');

@$core.Deprecated('Use registerNodeResponseDescriptor instead')
const RegisterNodeResponse$json = {
  '1': 'RegisterNodeResponse',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {
      '1': 'encrypted_metadata',
      '3': 2,
      '4': 1,
      '5': 12,
      '10': 'encryptedMetadata'
    },
    {'1': 'csr_pem', '3': 3, '4': 1, '5': 9, '10': 'csrPem'},
  ],
};

/// Descriptor for `RegisterNodeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerNodeResponseDescriptor = $convert.base64Decode(
    'ChRSZWdpc3Rlck5vZGVSZXNwb25zZRIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSLQoSZW5jcn'
    'lwdGVkX21ldGFkYXRhGAIgASgMUhFlbmNyeXB0ZWRNZXRhZGF0YRIXCgdjc3JfcGVtGAMgASgJ'
    'UgZjc3JQZW0=');

@$core.Deprecated('Use approveNodeRequestDescriptor instead')
const ApproveNodeRequest$json = {
  '1': 'ApproveNodeRequest',
  '2': [
    {
      '1': 'registration_code',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'registrationCode'
    },
    {'1': 'cert_pem', '3': 2, '4': 1, '5': 9, '10': 'certPem'},
    {'1': 'ca_pem', '3': 3, '4': 1, '5': 9, '10': 'caPem'},
    {'1': 'routing_token', '3': 4, '4': 1, '5': 9, '10': 'routingToken'},
  ],
};

/// Descriptor for `ApproveNodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approveNodeRequestDescriptor = $convert.base64Decode(
    'ChJBcHByb3ZlTm9kZVJlcXVlc3QSKwoRcmVnaXN0cmF0aW9uX2NvZGUYASABKAlSEHJlZ2lzdH'
    'JhdGlvbkNvZGUSGQoIY2VydF9wZW0YAiABKAlSB2NlcnRQZW0SFQoGY2FfcGVtGAMgASgJUgVj'
    'YVBlbRIjCg1yb3V0aW5nX3Rva2VuGAQgASgJUgxyb3V0aW5nVG9rZW4=');

@$core.Deprecated('Use deleteNodeRequestDescriptor instead')
const DeleteNodeRequest$json = {
  '1': 'DeleteNodeRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'routing_token', '3': 2, '4': 1, '5': 9, '10': 'routingToken'},
  ],
};

/// Descriptor for `DeleteNodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteNodeRequestDescriptor = $convert.base64Decode(
    'ChFEZWxldGVOb2RlUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSIwoNcm91dGluZ1'
    '90b2tlbhgCIAEoCVIMcm91dGluZ1Rva2Vu');

@$core.Deprecated('Use commandRequestDescriptor instead')
const CommandRequest$json = {
  '1': 'CommandRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {
      '1': 'encrypted',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.nitella.EncryptedPayload',
      '10': 'encrypted'
    },
    {'1': 'routing_token', '3': 3, '4': 1, '5': 9, '10': 'routingToken'},
  ],
};

/// Descriptor for `CommandRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandRequestDescriptor = $convert.base64Decode(
    'Cg5Db21tYW5kUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSNwoJZW5jcnlwdGVkGA'
    'IgASgLMhkubml0ZWxsYS5FbmNyeXB0ZWRQYXlsb2FkUgllbmNyeXB0ZWQSIwoNcm91dGluZ190'
    'b2tlbhgDIAEoCVIMcm91dGluZ1Rva2Vu');

@$core.Deprecated('Use streamMetricsRequestDescriptor instead')
const StreamMetricsRequest$json = {
  '1': 'StreamMetricsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'routing_token', '3': 2, '4': 1, '5': 9, '10': 'routingToken'},
  ],
};

/// Descriptor for `StreamMetricsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamMetricsRequestDescriptor = $convert.base64Decode(
    'ChRTdHJlYW1NZXRyaWNzUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSIwoNcm91dG'
    'luZ190b2tlbhgCIAEoCVIMcm91dGluZ1Rva2Vu');

@$core.Deprecated('Use getMetricsHistoryRequestDescriptor instead')
const GetMetricsHistoryRequest$json = {
  '1': 'GetMetricsHistoryRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'routing_token', '3': 2, '4': 1, '5': 9, '10': 'routingToken'},
    {
      '1': 'start_time',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startTime'
    },
    {
      '1': 'end_time',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'endTime'
    },
    {'1': 'limit', '3': 5, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `GetMetricsHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMetricsHistoryRequestDescriptor = $convert.base64Decode(
    'ChhHZXRNZXRyaWNzSGlzdG9yeVJlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlkEiMKDX'
    'JvdXRpbmdfdG9rZW4YAiABKAlSDHJvdXRpbmdUb2tlbhI5CgpzdGFydF90aW1lGAMgASgLMhou'
    'Z29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJc3RhcnRUaW1lEjUKCGVuZF90aW1lGAQgASgLMh'
    'ouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIHZW5kVGltZRIUCgVsaW1pdBgFIAEoBVIFbGlt'
    'aXQ=');

@$core.Deprecated('Use getMetricsHistoryResponseDescriptor instead')
const GetMetricsHistoryResponse$json = {
  '1': 'GetMetricsHistoryResponse',
  '2': [
    {
      '1': 'samples',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.EncryptedMetrics',
      '10': 'samples'
    },
  ],
};

/// Descriptor for `GetMetricsHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMetricsHistoryResponseDescriptor =
    $convert.base64Decode(
        'ChlHZXRNZXRyaWNzSGlzdG9yeVJlc3BvbnNlEjcKB3NhbXBsZXMYASADKAsyHS5uaXRlbGxhLm'
        'h1Yi5FbmNyeXB0ZWRNZXRyaWNzUgdzYW1wbGVz');

@$core.Deprecated('Use streamAlertsRequestDescriptor instead')
const StreamAlertsRequest$json = {
  '1': 'StreamAlertsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'routing_tokens', '3': 2, '4': 3, '5': 9, '10': 'routingTokens'},
  ],
};

/// Descriptor for `StreamAlertsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamAlertsRequestDescriptor = $convert.base64Decode(
    'ChNTdHJlYW1BbGVydHNSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBIlCg5yb3V0aW'
    '5nX3Rva2VucxgCIAMoCVINcm91dGluZ1Rva2Vucw==');

@$core.Deprecated('Use submitSignedCertRequestDescriptor instead')
const SubmitSignedCertRequest$json = {
  '1': 'SubmitSignedCertRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'cert_pem', '3': 2, '4': 1, '5': 9, '10': 'certPem'},
    {'1': 'ca_pem', '3': 3, '4': 1, '5': 9, '10': 'caPem'},
    {'1': 'fingerprint', '3': 4, '4': 1, '5': 9, '10': 'fingerprint'},
    {'1': 'routing_token', '3': 5, '4': 1, '5': 9, '10': 'routingToken'},
  ],
};

/// Descriptor for `SubmitSignedCertRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submitSignedCertRequestDescriptor = $convert.base64Decode(
    'ChdTdWJtaXRTaWduZWRDZXJ0UmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSGQoIY2'
    'VydF9wZW0YAiABKAlSB2NlcnRQZW0SFQoGY2FfcGVtGAMgASgJUgVjYVBlbRIgCgtmaW5nZXJw'
    'cmludBgEIAEoCVILZmluZ2VycHJpbnQSIwoNcm91dGluZ190b2tlbhgFIAEoCVIMcm91dGluZ1'
    'Rva2Vu');

@$core.Deprecated('Use pakeMessageDescriptor instead')
const PakeMessage$json = {
  '1': 'PakeMessage',
  '2': [
    {'1': 'session_code', '3': 1, '4': 1, '5': 9, '10': 'sessionCode'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.nitella.hub.PakeMessage.MessageType',
      '10': 'type'
    },
    {'1': 'spake2_data', '3': 3, '4': 1, '5': 12, '10': 'spake2Data'},
    {
      '1': 'encrypted_payload',
      '3': 4,
      '4': 1,
      '5': 12,
      '10': 'encryptedPayload'
    },
    {'1': 'nonce', '3': 5, '4': 1, '5': 12, '10': 'nonce'},
    {'1': 'role', '3': 6, '4': 1, '5': 9, '10': 'role'},
    {'1': 'error_message', '3': 7, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
  '4': [PakeMessage_MessageType$json],
};

@$core.Deprecated('Use pakeMessageDescriptor instead')
const PakeMessage_MessageType$json = {
  '1': 'MessageType',
  '2': [
    {'1': 'MESSAGE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'MESSAGE_TYPE_SPAKE2_INIT', '2': 1},
    {'1': 'MESSAGE_TYPE_SPAKE2_REPLY', '2': 2},
    {'1': 'MESSAGE_TYPE_ENCRYPTED', '2': 3},
    {'1': 'MESSAGE_TYPE_ERROR', '2': 4},
  ],
};

/// Descriptor for `PakeMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pakeMessageDescriptor = $convert.base64Decode(
    'CgtQYWtlTWVzc2FnZRIhCgxzZXNzaW9uX2NvZGUYASABKAlSC3Nlc3Npb25Db2RlEjgKBHR5cG'
    'UYAiABKA4yJC5uaXRlbGxhLmh1Yi5QYWtlTWVzc2FnZS5NZXNzYWdlVHlwZVIEdHlwZRIfCgtz'
    'cGFrZTJfZGF0YRgDIAEoDFIKc3Bha2UyRGF0YRIrChFlbmNyeXB0ZWRfcGF5bG9hZBgEIAEoDF'
    'IQZW5jcnlwdGVkUGF5bG9hZBIUCgVub25jZRgFIAEoDFIFbm9uY2USEgoEcm9sZRgGIAEoCVIE'
    'cm9sZRIjCg1lcnJvcl9tZXNzYWdlGAcgASgJUgxlcnJvck1lc3NhZ2UinAEKC01lc3NhZ2VUeX'
    'BlEhwKGE1FU1NBR0VfVFlQRV9VTlNQRUNJRklFRBAAEhwKGE1FU1NBR0VfVFlQRV9TUEFLRTJf'
    'SU5JVBABEh0KGU1FU1NBR0VfVFlQRV9TUEFLRTJfUkVQTFkQAhIaChZNRVNTQUdFX1RZUEVfRU'
    '5DUllQVEVEEAMSFgoSTUVTU0FHRV9UWVBFX0VSUk9SEAQ=');

@$core.Deprecated('Use registerUserRequestDescriptor instead')
const RegisterUserRequest$json = {
  '1': 'RegisterUserRequest',
  '2': [
    {'1': 'root_cert_pem', '3': 1, '4': 1, '5': 9, '10': 'rootCertPem'},
    {'1': 'blind_index', '3': 2, '4': 1, '5': 9, '10': 'blindIndex'},
    {'1': 'invite_code', '3': 3, '4': 1, '5': 9, '10': 'inviteCode'},
    {
      '1': 'biometric_public_key',
      '3': 4,
      '4': 1,
      '5': 12,
      '10': 'biometricPublicKey'
    },
    {
      '1': 'encrypted_profile',
      '3': 5,
      '4': 1,
      '5': 12,
      '10': 'encryptedProfile'
    },
  ],
};

/// Descriptor for `RegisterUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerUserRequestDescriptor = $convert.base64Decode(
    'ChNSZWdpc3RlclVzZXJSZXF1ZXN0EiIKDXJvb3RfY2VydF9wZW0YASABKAlSC3Jvb3RDZXJ0UG'
    'VtEh8KC2JsaW5kX2luZGV4GAIgASgJUgpibGluZEluZGV4Eh8KC2ludml0ZV9jb2RlGAMgASgJ'
    'UgppbnZpdGVDb2RlEjAKFGJpb21ldHJpY19wdWJsaWNfa2V5GAQgASgMUhJiaW9tZXRyaWNQdW'
    'JsaWNLZXkSKwoRZW5jcnlwdGVkX3Byb2ZpbGUYBSABKAxSEGVuY3J5cHRlZFByb2ZpbGU=');

@$core.Deprecated('Use registerUserResponseDescriptor instead')
const RegisterUserResponse$json = {
  '1': 'RegisterUserResponse',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'tier', '3': 2, '4': 1, '5': 9, '10': 'tier'},
    {'1': 'max_nodes', '3': 3, '4': 1, '5': 5, '10': 'maxNodes'},
    {'1': 'jwt_token', '3': 4, '4': 1, '5': 9, '10': 'jwtToken'},
    {'1': 'refresh_token', '3': 5, '4': 1, '5': 9, '10': 'refreshToken'},
  ],
};

/// Descriptor for `RegisterUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerUserResponseDescriptor = $convert.base64Decode(
    'ChRSZWdpc3RlclVzZXJSZXNwb25zZRIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSEgoEdGllch'
    'gCIAEoCVIEdGllchIbCgltYXhfbm9kZXMYAyABKAVSCG1heE5vZGVzEhsKCWp3dF90b2tlbhgE'
    'IAEoCVIIand0VG9rZW4SIwoNcmVmcmVzaF90b2tlbhgFIAEoCVIMcmVmcmVzaFRva2Vu');

@$core.Deprecated('Use registerDeviceRequestDescriptor instead')
const RegisterDeviceRequest$json = {
  '1': 'RegisterDeviceRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'fcm_token', '3': 2, '4': 1, '5': 9, '10': 'fcmToken'},
    {'1': 'device_type', '3': 3, '4': 1, '5': 9, '10': 'deviceType'},
  ],
};

/// Descriptor for `RegisterDeviceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerDeviceRequestDescriptor = $convert.base64Decode(
    'ChVSZWdpc3RlckRldmljZVJlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhsKCWZjbV'
    '90b2tlbhgCIAEoCVIIZmNtVG9rZW4SHwoLZGV2aWNlX3R5cGUYAyABKAlSCmRldmljZVR5cGU=');

@$core.Deprecated('Use updateLicenseRequestDescriptor instead')
const UpdateLicenseRequest$json = {
  '1': 'UpdateLicenseRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'license_key', '3': 2, '4': 1, '5': 9, '10': 'licenseKey'},
    {'1': 'routing_token', '3': 3, '4': 1, '5': 9, '10': 'routingToken'},
  ],
};

/// Descriptor for `UpdateLicenseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateLicenseRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVMaWNlbnNlUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSHwoLbGljZW'
    '5zZV9rZXkYAiABKAlSCmxpY2Vuc2VLZXkSIwoNcm91dGluZ190b2tlbhgDIAEoCVIMcm91dGlu'
    'Z1Rva2Vu');

@$core.Deprecated('Use updateLicenseResponseDescriptor instead')
const UpdateLicenseResponse$json = {
  '1': 'UpdateLicenseResponse',
  '2': [
    {'1': 'tier', '3': 1, '4': 1, '5': 9, '10': 'tier'},
    {'1': 'max_nodes', '3': 2, '4': 1, '5': 5, '10': 'maxNodes'},
    {'1': 'valid', '3': 3, '4': 1, '5': 8, '10': 'valid'},
  ],
};

/// Descriptor for `UpdateLicenseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateLicenseResponseDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVMaWNlbnNlUmVzcG9uc2USEgoEdGllchgBIAEoCVIEdGllchIbCgltYXhfbm9kZX'
    'MYAiABKAVSCG1heE5vZGVzEhQKBXZhbGlkGAMgASgIUgV2YWxpZA==');

@$core.Deprecated('Use createProxyConfigRequestDescriptor instead')
const CreateProxyConfigRequest$json = {
  '1': 'CreateProxyConfigRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'routing_token', '3': 2, '4': 1, '5': 9, '10': 'routingToken'},
  ],
};

/// Descriptor for `CreateProxyConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProxyConfigRequestDescriptor =
    $convert.base64Decode(
        'ChhDcmVhdGVQcm94eUNvbmZpZ1JlcXVlc3QSGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQSIw'
        'oNcm91dGluZ190b2tlbhgCIAEoCVIMcm91dGluZ1Rva2Vu');

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

@$core.Deprecated('Use listProxyConfigsRequestDescriptor instead')
const ListProxyConfigsRequest$json = {
  '1': 'ListProxyConfigsRequest',
  '2': [
    {'1': 'routing_token', '3': 1, '4': 1, '5': 9, '10': 'routingToken'},
  ],
};

/// Descriptor for `ListProxyConfigsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProxyConfigsRequestDescriptor =
    $convert.base64Decode(
        'ChdMaXN0UHJveHlDb25maWdzUmVxdWVzdBIjCg1yb3V0aW5nX3Rva2VuGAEgASgJUgxyb3V0aW'
        '5nVG9rZW4=');

@$core.Deprecated('Use listProxyConfigsResponseDescriptor instead')
const ListProxyConfigsResponse$json = {
  '1': 'ListProxyConfigsResponse',
  '2': [
    {
      '1': 'proxies',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.ProxyConfigInfo',
      '10': 'proxies'
    },
  ],
};

/// Descriptor for `ListProxyConfigsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProxyConfigsResponseDescriptor =
    $convert.base64Decode(
        'ChhMaXN0UHJveHlDb25maWdzUmVzcG9uc2USNgoHcHJveGllcxgBIAMoCzIcLm5pdGVsbGEuaH'
        'ViLlByb3h5Q29uZmlnSW5mb1IHcHJveGllcw==');

@$core.Deprecated('Use proxyConfigInfoDescriptor instead')
const ProxyConfigInfo$json = {
  '1': 'ProxyConfigInfo',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'revision_count', '3': 2, '4': 1, '5': 3, '10': 'revisionCount'},
    {'1': 'latest_revision', '3': 3, '4': 1, '5': 3, '10': 'latestRevision'},
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
    {'1': 'total_size_bytes', '3': 6, '4': 1, '5': 5, '10': 'totalSizeBytes'},
  ],
};

/// Descriptor for `ProxyConfigInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List proxyConfigInfoDescriptor = $convert.base64Decode(
    'Cg9Qcm94eUNvbmZpZ0luZm8SGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQSJQoOcmV2aXNpb2'
    '5fY291bnQYAiABKANSDXJldmlzaW9uQ291bnQSJwoPbGF0ZXN0X3JldmlzaW9uGAMgASgDUg5s'
    'YXRlc3RSZXZpc2lvbhI5CgpjcmVhdGVkX2F0GAQgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbW'
    'VzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQYBSABKAsyGi5nb29nbGUucHJvdG9idWYu'
    'VGltZXN0YW1wUgl1cGRhdGVkQXQSKAoQdG90YWxfc2l6ZV9ieXRlcxgGIAEoBVIOdG90YWxTaX'
    'plQnl0ZXM=');

@$core.Deprecated('Use deleteProxyConfigRequestDescriptor instead')
const DeleteProxyConfigRequest$json = {
  '1': 'DeleteProxyConfigRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'routing_token', '3': 2, '4': 1, '5': 9, '10': 'routingToken'},
  ],
};

/// Descriptor for `DeleteProxyConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteProxyConfigRequestDescriptor =
    $convert.base64Decode(
        'ChhEZWxldGVQcm94eUNvbmZpZ1JlcXVlc3QSGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQSIw'
        'oNcm91dGluZ190b2tlbhgCIAEoCVIMcm91dGluZ1Rva2Vu');

@$core.Deprecated('Use pushRevisionRequestDescriptor instead')
const PushRevisionRequest$json = {
  '1': 'PushRevisionRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'routing_token', '3': 2, '4': 1, '5': 9, '10': 'routingToken'},
    {'1': 'encrypted_blob', '3': 3, '4': 1, '5': 12, '10': 'encryptedBlob'},
    {'1': 'size_bytes', '3': 4, '4': 1, '5': 5, '10': 'sizeBytes'},
  ],
};

/// Descriptor for `PushRevisionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushRevisionRequestDescriptor = $convert.base64Decode(
    'ChNQdXNoUmV2aXNpb25SZXF1ZXN0EhkKCHByb3h5X2lkGAEgASgJUgdwcm94eUlkEiMKDXJvdX'
    'RpbmdfdG9rZW4YAiABKAlSDHJvdXRpbmdUb2tlbhIlCg5lbmNyeXB0ZWRfYmxvYhgDIAEoDFIN'
    'ZW5jcnlwdGVkQmxvYhIdCgpzaXplX2J5dGVzGAQgASgFUglzaXplQnl0ZXM=');

@$core.Deprecated('Use pushRevisionResponseDescriptor instead')
const PushRevisionResponse$json = {
  '1': 'PushRevisionResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'revision_num', '3': 2, '4': 1, '5': 3, '10': 'revisionNum'},
    {'1': 'revisions_kept', '3': 3, '4': 1, '5': 5, '10': 'revisionsKept'},
    {'1': 'revisions_limit', '3': 4, '4': 1, '5': 5, '10': 'revisionsLimit'},
    {'1': 'storage_used_kb', '3': 5, '4': 1, '5': 5, '10': 'storageUsedKb'},
    {'1': 'storage_limit_kb', '3': 6, '4': 1, '5': 5, '10': 'storageLimitKb'},
    {'1': 'error', '3': 7, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `PushRevisionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushRevisionResponseDescriptor = $convert.base64Decode(
    'ChRQdXNoUmV2aXNpb25SZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEiEKDHJldm'
    'lzaW9uX251bRgCIAEoA1ILcmV2aXNpb25OdW0SJQoOcmV2aXNpb25zX2tlcHQYAyABKAVSDXJl'
    'dmlzaW9uc0tlcHQSJwoPcmV2aXNpb25zX2xpbWl0GAQgASgFUg5yZXZpc2lvbnNMaW1pdBImCg'
    '9zdG9yYWdlX3VzZWRfa2IYBSABKAVSDXN0b3JhZ2VVc2VkS2ISKAoQc3RvcmFnZV9saW1pdF9r'
    'YhgGIAEoBVIOc3RvcmFnZUxpbWl0S2ISFAoFZXJyb3IYByABKAlSBWVycm9y');

@$core.Deprecated('Use getRevisionRequestDescriptor instead')
const GetRevisionRequest$json = {
  '1': 'GetRevisionRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'routing_token', '3': 2, '4': 1, '5': 9, '10': 'routingToken'},
    {'1': 'revision_num', '3': 3, '4': 1, '5': 3, '10': 'revisionNum'},
  ],
};

/// Descriptor for `GetRevisionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRevisionRequestDescriptor = $convert.base64Decode(
    'ChJHZXRSZXZpc2lvblJlcXVlc3QSGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQSIwoNcm91dG'
    'luZ190b2tlbhgCIAEoCVIMcm91dGluZ1Rva2VuEiEKDHJldmlzaW9uX251bRgDIAEoA1ILcmV2'
    'aXNpb25OdW0=');

@$core.Deprecated('Use getRevisionResponseDescriptor instead')
const GetRevisionResponse$json = {
  '1': 'GetRevisionResponse',
  '2': [
    {'1': 'encrypted_blob', '3': 1, '4': 1, '5': 12, '10': 'encryptedBlob'},
    {'1': 'revision_num', '3': 2, '4': 1, '5': 3, '10': 'revisionNum'},
    {
      '1': 'created_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {'1': 'size_bytes', '3': 4, '4': 1, '5': 5, '10': 'sizeBytes'},
  ],
};

/// Descriptor for `GetRevisionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRevisionResponseDescriptor = $convert.base64Decode(
    'ChNHZXRSZXZpc2lvblJlc3BvbnNlEiUKDmVuY3J5cHRlZF9ibG9iGAEgASgMUg1lbmNyeXB0ZW'
    'RCbG9iEiEKDHJldmlzaW9uX251bRgCIAEoA1ILcmV2aXNpb25OdW0SOQoKY3JlYXRlZF9hdBgD'
    'IAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBIdCgpzaXplX2J5dG'
    'VzGAQgASgFUglzaXplQnl0ZXM=');

@$core.Deprecated('Use listRevisionsRequestDescriptor instead')
const ListRevisionsRequest$json = {
  '1': 'ListRevisionsRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'routing_token', '3': 2, '4': 1, '5': 9, '10': 'routingToken'},
  ],
};

/// Descriptor for `ListRevisionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRevisionsRequestDescriptor = $convert.base64Decode(
    'ChRMaXN0UmV2aXNpb25zUmVxdWVzdBIZCghwcm94eV9pZBgBIAEoCVIHcHJveHlJZBIjCg1yb3'
    'V0aW5nX3Rva2VuGAIgASgJUgxyb3V0aW5nVG9rZW4=');

@$core.Deprecated('Use listRevisionsResponseDescriptor instead')
const ListRevisionsResponse$json = {
  '1': 'ListRevisionsResponse',
  '2': [
    {
      '1': 'revisions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.RevisionMeta',
      '10': 'revisions'
    },
  ],
};

/// Descriptor for `ListRevisionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRevisionsResponseDescriptor = $convert.base64Decode(
    'ChVMaXN0UmV2aXNpb25zUmVzcG9uc2USNwoJcmV2aXNpb25zGAEgAygLMhkubml0ZWxsYS5odW'
    'IuUmV2aXNpb25NZXRhUglyZXZpc2lvbnM=');

@$core.Deprecated('Use revisionMetaDescriptor instead')
const RevisionMeta$json = {
  '1': 'RevisionMeta',
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

/// Descriptor for `RevisionMeta`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revisionMetaDescriptor = $convert.base64Decode(
    'CgxSZXZpc2lvbk1ldGESIQoMcmV2aXNpb25fbnVtGAEgASgDUgtyZXZpc2lvbk51bRIdCgpzaX'
    'plX2J5dGVzGAIgASgFUglzaXplQnl0ZXMSOQoKY3JlYXRlZF9hdBgDIAEoCzIaLmdvb2dsZS5w'
    'cm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdA==');

@$core.Deprecated('Use flushRevisionsRequestDescriptor instead')
const FlushRevisionsRequest$json = {
  '1': 'FlushRevisionsRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'routing_token', '3': 2, '4': 1, '5': 9, '10': 'routingToken'},
    {'1': 'keep_count', '3': 3, '4': 1, '5': 5, '10': 'keepCount'},
  ],
};

/// Descriptor for `FlushRevisionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List flushRevisionsRequestDescriptor = $convert.base64Decode(
    'ChVGbHVzaFJldmlzaW9uc1JlcXVlc3QSGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQSIwoNcm'
    '91dGluZ190b2tlbhgCIAEoCVIMcm91dGluZ1Rva2VuEh0KCmtlZXBfY291bnQYAyABKAVSCWtl'
    'ZXBDb3VudA==');

@$core.Deprecated('Use flushRevisionsResponseDescriptor instead')
const FlushRevisionsResponse$json = {
  '1': 'FlushRevisionsResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'deleted_count', '3': 2, '4': 1, '5': 5, '10': 'deletedCount'},
    {'1': 'remaining_count', '3': 3, '4': 1, '5': 5, '10': 'remainingCount'},
    {'1': 'error', '3': 4, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `FlushRevisionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List flushRevisionsResponseDescriptor = $convert.base64Decode(
    'ChZGbHVzaFJldmlzaW9uc1Jlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSIwoNZG'
    'VsZXRlZF9jb3VudBgCIAEoBVIMZGVsZXRlZENvdW50EicKD3JlbWFpbmluZ19jb3VudBgDIAEo'
    'BVIOcmVtYWluaW5nQ291bnQSFAoFZXJyb3IYBCABKAlSBWVycm9y');

@$core.Deprecated('Use proxyRevisionPayloadDescriptor instead')
const ProxyRevisionPayload$json = {
  '1': 'ProxyRevisionPayload',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'commit_message', '3': 3, '4': 1, '5': 9, '10': 'commitMessage'},
    {'1': 'protocol_version', '3': 4, '4': 1, '5': 9, '10': 'protocolVersion'},
    {'1': 'config_yaml', '3': 5, '4': 1, '5': 9, '10': 'configYaml'},
    {'1': 'config_hash', '3': 6, '4': 1, '5': 9, '10': 'configHash'},
  ],
};

/// Descriptor for `ProxyRevisionPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List proxyRevisionPayloadDescriptor = $convert.base64Decode(
    'ChRQcm94eVJldmlzaW9uUGF5bG9hZBISCgRuYW1lGAEgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW'
    '9uGAIgASgJUgtkZXNjcmlwdGlvbhIlCg5jb21taXRfbWVzc2FnZRgDIAEoCVINY29tbWl0TWVz'
    'c2FnZRIpChBwcm90b2NvbF92ZXJzaW9uGAQgASgJUg9wcm90b2NvbFZlcnNpb24SHwoLY29uZm'
    'lnX3lhbWwYBSABKAlSCmNvbmZpZ1lhbWwSHwoLY29uZmlnX2hhc2gYBiABKAlSCmNvbmZpZ0hh'
    'c2g=');
