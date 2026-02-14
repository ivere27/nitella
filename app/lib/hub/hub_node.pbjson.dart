// This is a generated file - do not edit.
//
// Generated from hub/hub_node.proto.

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

@$core.Deprecated('Use nodeCommandDescriptor instead')
const NodeCommand$json = {
  '1': 'NodeCommand',
  '2': [
    {
      '1': 'add_rule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.AddRuleRequest',
      '9': 0,
      '10': 'addRule'
    },
    {
      '1': 'remove_rule',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.RemoveRuleRequest',
      '9': 0,
      '10': 'removeRule'
    },
    {
      '1': 'fetch_rules',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.ListRulesRequest',
      '9': 0,
      '10': 'fetchRules'
    },
    {
      '1': 'get_connections',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.GetActiveConnectionsRequest',
      '9': 0,
      '10': 'getConnections'
    },
    {
      '1': 'close_connection',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.CloseConnectionRequest',
      '9': 0,
      '10': 'closeConnection'
    },
    {
      '1': 'close_all',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.CloseAllConnectionsRequest',
      '9': 0,
      '10': 'closeAll'
    },
    {
      '1': 'get_ip_stats',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.GetIPStatsRequest',
      '9': 0,
      '10': 'getIpStats'
    },
    {
      '1': 'get_geo_stats',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.GetGeoStatsRequest',
      '9': 0,
      '10': 'getGeoStats'
    },
    {
      '1': 'get_stats_summary',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.GetStatsSummaryRequest',
      '9': 0,
      '10': 'getStatsSummary'
    },
    {
      '1': 'resolve_approval',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.ResolveApprovalRequest',
      '9': 0,
      '10': 'resolveApproval'
    },
    {
      '1': 'list_proxies',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.ListProxiesRequest',
      '9': 0,
      '10': 'listProxies'
    },
    {
      '1': 'create_proxy',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.CreateProxyRequest',
      '9': 0,
      '10': 'createProxy'
    },
    {
      '1': 'update_proxy',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.UpdateProxyRequest',
      '9': 0,
      '10': 'updateProxy'
    },
    {
      '1': 'delete_proxy',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.DeleteProxyRequest',
      '9': 0,
      '10': 'deleteProxy'
    },
    {
      '1': 'enable_proxy',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.EnableProxyRequest',
      '9': 0,
      '10': 'enableProxy'
    },
    {
      '1': 'disable_proxy',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.DisableProxyRequest',
      '9': 0,
      '10': 'disableProxy'
    },
  ],
  '8': [
    {'1': 'command'},
  ],
};

/// Descriptor for `NodeCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeCommandDescriptor = $convert.base64Decode(
    'CgtOb2RlQ29tbWFuZBI6CghhZGRfcnVsZRgBIAEoCzIdLm5pdGVsbGEucHJveHkuQWRkUnVsZV'
    'JlcXVlc3RIAFIHYWRkUnVsZRJDCgtyZW1vdmVfcnVsZRgCIAEoCzIgLm5pdGVsbGEucHJveHku'
    'UmVtb3ZlUnVsZVJlcXVlc3RIAFIKcmVtb3ZlUnVsZRJCCgtmZXRjaF9ydWxlcxgDIAEoCzIfLm'
    '5pdGVsbGEucHJveHkuTGlzdFJ1bGVzUmVxdWVzdEgAUgpmZXRjaFJ1bGVzElUKD2dldF9jb25u'
    'ZWN0aW9ucxgEIAEoCzIqLm5pdGVsbGEucHJveHkuR2V0QWN0aXZlQ29ubmVjdGlvbnNSZXF1ZX'
    'N0SABSDmdldENvbm5lY3Rpb25zElIKEGNsb3NlX2Nvbm5lY3Rpb24YBSABKAsyJS5uaXRlbGxh'
    'LnByb3h5LkNsb3NlQ29ubmVjdGlvblJlcXVlc3RIAFIPY2xvc2VDb25uZWN0aW9uEkgKCWNsb3'
    'NlX2FsbBgGIAEoCzIpLm5pdGVsbGEucHJveHkuQ2xvc2VBbGxDb25uZWN0aW9uc1JlcXVlc3RI'
    'AFIIY2xvc2VBbGwSRAoMZ2V0X2lwX3N0YXRzGAcgASgLMiAubml0ZWxsYS5wcm94eS5HZXRJUF'
    'N0YXRzUmVxdWVzdEgAUgpnZXRJcFN0YXRzEkcKDWdldF9nZW9fc3RhdHMYCCABKAsyIS5uaXRl'
    'bGxhLnByb3h5LkdldEdlb1N0YXRzUmVxdWVzdEgAUgtnZXRHZW9TdGF0cxJTChFnZXRfc3RhdH'
    'Nfc3VtbWFyeRgJIAEoCzIlLm5pdGVsbGEucHJveHkuR2V0U3RhdHNTdW1tYXJ5UmVxdWVzdEgA'
    'Ug9nZXRTdGF0c1N1bW1hcnkSUgoQcmVzb2x2ZV9hcHByb3ZhbBgKIAEoCzIlLm5pdGVsbGEucH'
    'JveHkuUmVzb2x2ZUFwcHJvdmFsUmVxdWVzdEgAUg9yZXNvbHZlQXBwcm92YWwSRgoMbGlzdF9w'
    'cm94aWVzGAsgASgLMiEubml0ZWxsYS5wcm94eS5MaXN0UHJveGllc1JlcXVlc3RIAFILbGlzdF'
    'Byb3hpZXMSRgoMY3JlYXRlX3Byb3h5GAwgASgLMiEubml0ZWxsYS5wcm94eS5DcmVhdGVQcm94'
    'eVJlcXVlc3RIAFILY3JlYXRlUHJveHkSRgoMdXBkYXRlX3Byb3h5GA0gASgLMiEubml0ZWxsYS'
    '5wcm94eS5VcGRhdGVQcm94eVJlcXVlc3RIAFILdXBkYXRlUHJveHkSRgoMZGVsZXRlX3Byb3h5'
    'GA4gASgLMiEubml0ZWxsYS5wcm94eS5EZWxldGVQcm94eVJlcXVlc3RIAFILZGVsZXRlUHJveH'
    'kSRgoMZW5hYmxlX3Byb3h5GA8gASgLMiEubml0ZWxsYS5wcm94eS5FbmFibGVQcm94eVJlcXVl'
    'c3RIAFILZW5hYmxlUHJveHkSSQoNZGlzYWJsZV9wcm94eRgQIAEoCzIiLm5pdGVsbGEucHJveH'
    'kuRGlzYWJsZVByb3h5UmVxdWVzdEgAUgxkaXNhYmxlUHJveHlCCQoHY29tbWFuZA==');

@$core.Deprecated('Use nodeRegisterRequestDescriptor instead')
const NodeRegisterRequest$json = {
  '1': 'NodeRegisterRequest',
  '2': [
    {
      '1': 'registration_code',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'registrationCode'
    },
    {'1': 'csr_pem', '3': 2, '4': 1, '5': 9, '10': 'csrPem'},
    {
      '1': 'encrypted_metadata',
      '3': 3,
      '4': 1,
      '5': 12,
      '10': 'encryptedMetadata'
    },
    {'1': 'listen_ports', '3': 4, '4': 3, '5': 5, '10': 'listenPorts'},
    {'1': 'version', '3': 5, '4': 1, '5': 9, '10': 'version'},
    {'1': 'invite_code', '3': 6, '4': 1, '5': 9, '10': 'inviteCode'},
    {'1': 'pairing_code', '3': 7, '4': 1, '5': 9, '10': 'pairingCode'},
  ],
};

/// Descriptor for `NodeRegisterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeRegisterRequestDescriptor = $convert.base64Decode(
    'ChNOb2RlUmVnaXN0ZXJSZXF1ZXN0EisKEXJlZ2lzdHJhdGlvbl9jb2RlGAEgASgJUhByZWdpc3'
    'RyYXRpb25Db2RlEhcKB2Nzcl9wZW0YAiABKAlSBmNzclBlbRItChJlbmNyeXB0ZWRfbWV0YWRh'
    'dGEYAyABKAxSEWVuY3J5cHRlZE1ldGFkYXRhEiEKDGxpc3Rlbl9wb3J0cxgEIAMoBVILbGlzdG'
    'VuUG9ydHMSGAoHdmVyc2lvbhgFIAEoCVIHdmVyc2lvbhIfCgtpbnZpdGVfY29kZRgGIAEoCVIK'
    'aW52aXRlQ29kZRIhCgxwYWlyaW5nX2NvZGUYByABKAlSC3BhaXJpbmdDb2Rl');

@$core.Deprecated('Use nodeRegisterResponseDescriptor instead')
const NodeRegisterResponse$json = {
  '1': 'NodeRegisterResponse',
  '2': [
    {
      '1': 'registration_code',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'registrationCode'
    },
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.nitella.hub.RegistrationStatus',
      '10': 'status'
    },
    {'1': 'cert_pem', '3': 3, '4': 1, '5': 9, '10': 'certPem'},
    {'1': 'ca_pem', '3': 4, '4': 1, '5': 9, '10': 'caPem'},
    {'1': 'watch_secret', '3': 5, '4': 1, '5': 9, '10': 'watchSecret'},
  ],
};

/// Descriptor for `NodeRegisterResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeRegisterResponseDescriptor = $convert.base64Decode(
    'ChROb2RlUmVnaXN0ZXJSZXNwb25zZRIrChFyZWdpc3RyYXRpb25fY29kZRgBIAEoCVIQcmVnaX'
    'N0cmF0aW9uQ29kZRI3CgZzdGF0dXMYAiABKA4yHy5uaXRlbGxhLmh1Yi5SZWdpc3RyYXRpb25T'
    'dGF0dXNSBnN0YXR1cxIZCghjZXJ0X3BlbRgDIAEoCVIHY2VydFBlbRIVCgZjYV9wZW0YBCABKA'
    'lSBWNhUGVtEiEKDHdhdGNoX3NlY3JldBgFIAEoCVILd2F0Y2hTZWNyZXQ=');

@$core.Deprecated('Use watchRegistrationRequestDescriptor instead')
const WatchRegistrationRequest$json = {
  '1': 'WatchRegistrationRequest',
  '2': [
    {
      '1': 'registration_code',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'registrationCode'
    },
    {'1': 'watch_secret', '3': 2, '4': 1, '5': 9, '10': 'watchSecret'},
  ],
};

/// Descriptor for `WatchRegistrationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchRegistrationRequestDescriptor =
    $convert.base64Decode(
        'ChhXYXRjaFJlZ2lzdHJhdGlvblJlcXVlc3QSKwoRcmVnaXN0cmF0aW9uX2NvZGUYASABKAlSEH'
        'JlZ2lzdHJhdGlvbkNvZGUSIQoMd2F0Y2hfc2VjcmV0GAIgASgJUgt3YXRjaFNlY3JldA==');

@$core.Deprecated('Use watchRegistrationResponseDescriptor instead')
const WatchRegistrationResponse$json = {
  '1': 'WatchRegistrationResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.nitella.hub.RegistrationStatus',
      '10': 'status'
    },
    {'1': 'cert_pem', '3': 2, '4': 1, '5': 9, '10': 'certPem'},
    {'1': 'ca_pem', '3': 3, '4': 1, '5': 9, '10': 'caPem'},
  ],
};

/// Descriptor for `WatchRegistrationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchRegistrationResponseDescriptor = $convert.base64Decode(
    'ChlXYXRjaFJlZ2lzdHJhdGlvblJlc3BvbnNlEjcKBnN0YXR1cxgBIAEoDjIfLm5pdGVsbGEuaH'
    'ViLlJlZ2lzdHJhdGlvblN0YXR1c1IGc3RhdHVzEhkKCGNlcnRfcGVtGAIgASgJUgdjZXJ0UGVt'
    'EhUKBmNhX3BlbRgDIAEoCVIFY2FQZW0=');

@$core.Deprecated('Use checkCertificateRequestDescriptor instead')
const CheckCertificateRequest$json = {
  '1': 'CheckCertificateRequest',
  '2': [
    {'1': 'fingerprint', '3': 1, '4': 1, '5': 9, '10': 'fingerprint'},
  ],
};

/// Descriptor for `CheckCertificateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkCertificateRequestDescriptor =
    $convert.base64Decode(
        'ChdDaGVja0NlcnRpZmljYXRlUmVxdWVzdBIgCgtmaW5nZXJwcmludBgBIAEoCVILZmluZ2VycH'
        'JpbnQ=');

@$core.Deprecated('Use checkCertificateResponseDescriptor instead')
const CheckCertificateResponse$json = {
  '1': 'CheckCertificateResponse',
  '2': [
    {'1': 'found', '3': 1, '4': 1, '5': 8, '10': 'found'},
    {'1': 'cert_pem', '3': 2, '4': 1, '5': 9, '10': 'certPem'},
    {'1': 'ca_pem', '3': 3, '4': 1, '5': 9, '10': 'caPem'},
  ],
};

/// Descriptor for `CheckCertificateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkCertificateResponseDescriptor =
    $convert.base64Decode(
        'ChhDaGVja0NlcnRpZmljYXRlUmVzcG9uc2USFAoFZm91bmQYASABKAhSBWZvdW5kEhkKCGNlcn'
        'RfcGVtGAIgASgJUgdjZXJ0UGVtEhUKBmNhX3BlbRgDIAEoCVIFY2FQZW0=');

@$core.Deprecated('Use heartbeatRequestDescriptor instead')
const HeartbeatRequest$json = {
  '1': 'HeartbeatRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.nitella.hub.NodeStatus',
      '10': 'status'
    },
    {'1': 'uptime_seconds', '3': 3, '4': 1, '5': 3, '10': 'uptimeSeconds'},
  ],
};

/// Descriptor for `HeartbeatRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List heartbeatRequestDescriptor = $convert.base64Decode(
    'ChBIZWFydGJlYXRSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBIvCgZzdGF0dXMYAi'
    'ABKA4yFy5uaXRlbGxhLmh1Yi5Ob2RlU3RhdHVzUgZzdGF0dXMSJQoOdXB0aW1lX3NlY29uZHMY'
    'AyABKANSDXVwdGltZVNlY29uZHM=');

@$core.Deprecated('Use heartbeatResponseDescriptor instead')
const HeartbeatResponse$json = {
  '1': 'HeartbeatResponse',
  '2': [
    {'1': 'rules_changed', '3': 1, '4': 1, '5': 8, '10': 'rulesChanged'},
    {'1': 'config_changed', '3': 2, '4': 1, '5': 8, '10': 'configChanged'},
  ],
};

/// Descriptor for `HeartbeatResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List heartbeatResponseDescriptor = $convert.base64Decode(
    'ChFIZWFydGJlYXRSZXNwb25zZRIjCg1ydWxlc19jaGFuZ2VkGAEgASgIUgxydWxlc0NoYW5nZW'
    'QSJQoOY29uZmlnX2NoYW5nZWQYAiABKAhSDWNvbmZpZ0NoYW5nZWQ=');

@$core.Deprecated('Use receiveCommandsRequestDescriptor instead')
const ReceiveCommandsRequest$json = {
  '1': 'ReceiveCommandsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `ReceiveCommandsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List receiveCommandsRequestDescriptor =
    $convert.base64Decode(
        'ChZSZWNlaXZlQ29tbWFuZHNSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZA==');

@$core.Deprecated('Use streamRevocationsRequestDescriptor instead')
const StreamRevocationsRequest$json = {
  '1': 'StreamRevocationsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `StreamRevocationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamRevocationsRequestDescriptor =
    $convert.base64Decode(
        'ChhTdHJlYW1SZXZvY2F0aW9uc1JlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlk');
