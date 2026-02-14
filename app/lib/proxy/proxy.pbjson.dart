// This is a generated file - do not edit.
//
// Generated from proxy/proxy.proto.

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

@$core.Deprecated('Use healthCheckTypeDescriptor instead')
const HealthCheckType$json = {
  '1': 'HealthCheckType',
  '2': [
    {'1': 'HEALTH_CHECK_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'HEALTH_CHECK_TYPE_TCP', '2': 1},
    {'1': 'HEALTH_CHECK_TYPE_HTTP', '2': 2},
    {'1': 'HEALTH_CHECK_TYPE_HTTPS', '2': 3},
  ],
};

/// Descriptor for `HealthCheckType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List healthCheckTypeDescriptor = $convert.base64Decode(
    'Cg9IZWFsdGhDaGVja1R5cGUSIQodSEVBTFRIX0NIRUNLX1RZUEVfVU5TUEVDSUZJRUQQABIZCh'
    'VIRUFMVEhfQ0hFQ0tfVFlQRV9UQ1AQARIaChZIRUFMVEhfQ0hFQ0tfVFlQRV9IVFRQEAISGwoX'
    'SEVBTFRIX0NIRUNLX1RZUEVfSFRUUFMQAw==');

@$core.Deprecated('Use clientAuthTypeDescriptor instead')
const ClientAuthType$json = {
  '1': 'ClientAuthType',
  '2': [
    {'1': 'CLIENT_AUTH_AUTO', '2': 0},
    {'1': 'CLIENT_AUTH_NONE', '2': 1},
    {'1': 'CLIENT_AUTH_REQUEST', '2': 2},
    {'1': 'CLIENT_AUTH_REQUIRE', '2': 3},
  ],
};

/// Descriptor for `ClientAuthType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List clientAuthTypeDescriptor = $convert.base64Decode(
    'Cg5DbGllbnRBdXRoVHlwZRIUChBDTElFTlRfQVVUSF9BVVRPEAASFAoQQ0xJRU5UX0FVVEhfTk'
    '9ORRABEhcKE0NMSUVOVF9BVVRIX1JFUVVFU1QQAhIXChNDTElFTlRfQVVUSF9SRVFVSVJFEAM=');

@$core.Deprecated('Use healthStatusDescriptor instead')
const HealthStatus$json = {
  '1': 'HealthStatus',
  '2': [
    {'1': 'HEALTH_STATUS_UNKNOWN', '2': 0},
    {'1': 'HEALTH_STATUS_HEALTHY', '2': 1},
    {'1': 'HEALTH_STATUS_UNHEALTHY', '2': 2},
    {'1': 'HEALTH_STATUS_STARTING', '2': 3},
  ],
};

/// Descriptor for `HealthStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List healthStatusDescriptor = $convert.base64Decode(
    'CgxIZWFsdGhTdGF0dXMSGQoVSEVBTFRIX1NUQVRVU19VTktOT1dOEAASGQoVSEVBTFRIX1NUQV'
    'RVU19IRUFMVEhZEAESGwoXSEVBTFRIX1NUQVRVU19VTkhFQUxUSFkQAhIaChZIRUFMVEhfU1RB'
    'VFVTX1NUQVJUSU5HEAM=');

@$core.Deprecated('Use eventTypeDescriptor instead')
const EventType$json = {
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

/// Descriptor for `EventType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List eventTypeDescriptor = $convert.base64Decode(
    'CglFdmVudFR5cGUSGgoWRVZFTlRfVFlQRV9VTlNQRUNJRklFRBAAEhgKFEVWRU5UX1RZUEVfQ0'
    '9OTkVDVEVEEAESFQoRRVZFTlRfVFlQRV9DTE9TRUQQAhIWChJFVkVOVF9UWVBFX0JMT0NLRUQQ'
    'AxIfChtFVkVOVF9UWVBFX1BFTkRJTkdfQVBQUk9WQUwQBBIXChNFVkVOVF9UWVBFX0FQUFJPVk'
    'VEEAU=');

@$core.Deprecated('Use configureGeoIPRequestDescriptor instead')
const ConfigureGeoIPRequest$json = {
  '1': 'ConfigureGeoIPRequest',
  '2': [
    {
      '1': 'mode',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.nitella.proxy.ConfigureGeoIPRequest.Mode',
      '10': 'mode'
    },
    {'1': 'city_db_path', '3': 2, '4': 1, '5': 9, '10': 'cityDbPath'},
    {'1': 'isp_db_path', '3': 3, '4': 1, '5': 9, '10': 'ispDbPath'},
    {'1': 'provider', '3': 4, '4': 1, '5': 9, '10': 'provider'},
    {'1': 'api_key', '3': 5, '4': 1, '5': 9, '10': 'apiKey'},
  ],
  '4': [ConfigureGeoIPRequest_Mode$json],
};

@$core.Deprecated('Use configureGeoIPRequestDescriptor instead')
const ConfigureGeoIPRequest_Mode$json = {
  '1': 'Mode',
  '2': [
    {'1': 'MODE_LOCAL_DB', '2': 0},
    {'1': 'MODE_REMOTE_API', '2': 1},
  ],
};

/// Descriptor for `ConfigureGeoIPRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configureGeoIPRequestDescriptor = $convert.base64Decode(
    'ChVDb25maWd1cmVHZW9JUFJlcXVlc3QSPQoEbW9kZRgBIAEoDjIpLm5pdGVsbGEucHJveHkuQ2'
    '9uZmlndXJlR2VvSVBSZXF1ZXN0Lk1vZGVSBG1vZGUSIAoMY2l0eV9kYl9wYXRoGAIgASgJUgpj'
    'aXR5RGJQYXRoEh4KC2lzcF9kYl9wYXRoGAMgASgJUglpc3BEYlBhdGgSGgoIcHJvdmlkZXIYBC'
    'ABKAlSCHByb3ZpZGVyEhcKB2FwaV9rZXkYBSABKAlSBmFwaUtleSIuCgRNb2RlEhEKDU1PREVf'
    'TE9DQUxfREIQABITCg9NT0RFX1JFTU9URV9BUEkQAQ==');

@$core.Deprecated('Use configureGeoIPResponseDescriptor instead')
const ConfigureGeoIPResponse$json = {
  '1': 'ConfigureGeoIPResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `ConfigureGeoIPResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configureGeoIPResponseDescriptor =
    $convert.base64Decode(
        'ChZDb25maWd1cmVHZW9JUFJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSFAoFZX'
        'Jyb3IYAiABKAlSBWVycm9y');

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
    {'1': 'lookup_time_ms', '3': 3, '4': 1, '5': 3, '10': 'lookupTimeMs'},
  ],
};

/// Descriptor for `LookupIPResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lookupIPResponseDescriptor = $convert.base64Decode(
    'ChBMb29rdXBJUFJlc3BvbnNlEiIKA2dlbxgBIAEoCzIQLm5pdGVsbGEuR2VvSW5mb1IDZ2VvEh'
    'YKBmNhY2hlZBgCIAEoCFIGY2FjaGVkEiQKDmxvb2t1cF90aW1lX21zGAMgASgDUgxsb29rdXBU'
    'aW1lTXM=');

@$core.Deprecated('Use getGeoIPStatusRequestDescriptor instead')
const GetGeoIPStatusRequest$json = {
  '1': 'GetGeoIPStatusRequest',
};

/// Descriptor for `GetGeoIPStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGeoIPStatusRequestDescriptor =
    $convert.base64Decode('ChVHZXRHZW9JUFN0YXR1c1JlcXVlc3Q=');

@$core.Deprecated('Use getGeoIPStatusResponseDescriptor instead')
const GetGeoIPStatusResponse$json = {
  '1': 'GetGeoIPStatusResponse',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'mode', '3': 2, '4': 1, '5': 9, '10': 'mode'},
    {'1': 'city_db_path', '3': 3, '4': 1, '5': 9, '10': 'cityDbPath'},
    {'1': 'isp_db_path', '3': 4, '4': 1, '5': 9, '10': 'ispDbPath'},
    {'1': 'provider', '3': 5, '4': 1, '5': 9, '10': 'provider'},
    {'1': 'strategy', '3': 6, '4': 3, '5': 9, '10': 'strategy'},
    {'1': 'cache_hits', '3': 7, '4': 1, '5': 3, '10': 'cacheHits'},
    {'1': 'cache_misses', '3': 8, '4': 1, '5': 3, '10': 'cacheMisses'},
  ],
};

/// Descriptor for `GetGeoIPStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGeoIPStatusResponseDescriptor = $convert.base64Decode(
    'ChZHZXRHZW9JUFN0YXR1c1Jlc3BvbnNlEhgKB2VuYWJsZWQYASABKAhSB2VuYWJsZWQSEgoEbW'
    '9kZRgCIAEoCVIEbW9kZRIgCgxjaXR5X2RiX3BhdGgYAyABKAlSCmNpdHlEYlBhdGgSHgoLaXNw'
    'X2RiX3BhdGgYBCABKAlSCWlzcERiUGF0aBIaCghwcm92aWRlchgFIAEoCVIIcHJvdmlkZXISGg'
    'oIc3RyYXRlZ3kYBiADKAlSCHN0cmF0ZWd5Eh0KCmNhY2hlX2hpdHMYByABKANSCWNhY2hlSGl0'
    'cxIhCgxjYWNoZV9taXNzZXMYCCABKANSC2NhY2hlTWlzc2Vz');

@$core.Deprecated('Use createProxyRequestDescriptor instead')
const CreateProxyRequest$json = {
  '1': 'CreateProxyRequest',
  '2': [
    {'1': 'listen_addr', '3': 1, '4': 1, '5': 9, '10': 'listenAddr'},
    {'1': 'default_backend', '3': 2, '4': 1, '5': 9, '10': 'defaultBackend'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'cert_pem', '3': 4, '4': 1, '5': 9, '10': 'certPem'},
    {'1': 'key_pem', '3': 5, '4': 1, '5': 9, '10': 'keyPem'},
    {'1': 'ca_pem', '3': 6, '4': 1, '5': 9, '10': 'caPem'},
    {
      '1': 'default_action',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.nitella.ActionType',
      '10': 'defaultAction'
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
      '1': 'fallback_action',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.nitella.FallbackAction',
      '10': 'fallbackAction'
    },
    {
      '1': 'fallback_mock',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.nitella.MockPreset',
      '10': 'fallbackMock'
    },
    {
      '1': 'client_auth_type',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.nitella.proxy.ClientAuthType',
      '10': 'clientAuthType'
    },
    {'1': 'tags', '3': 12, '4': 3, '5': 9, '10': 'tags'},
    {
      '1': 'health_check',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.HealthCheckConfig',
      '10': 'healthCheck'
    },
  ],
};

/// Descriptor for `CreateProxyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProxyRequestDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVQcm94eVJlcXVlc3QSHwoLbGlzdGVuX2FkZHIYASABKAlSCmxpc3RlbkFkZHISJw'
    'oPZGVmYXVsdF9iYWNrZW5kGAIgASgJUg5kZWZhdWx0QmFja2VuZBISCgRuYW1lGAMgASgJUgRu'
    'YW1lEhkKCGNlcnRfcGVtGAQgASgJUgdjZXJ0UGVtEhcKB2tleV9wZW0YBSABKAlSBmtleVBlbR'
    'IVCgZjYV9wZW0YBiABKAlSBWNhUGVtEjoKDmRlZmF1bHRfYWN0aW9uGAcgASgOMhMubml0ZWxs'
    'YS5BY3Rpb25UeXBlUg1kZWZhdWx0QWN0aW9uEjYKDGRlZmF1bHRfbW9jaxgIIAEoDjITLm5pdG'
    'VsbGEuTW9ja1ByZXNldFILZGVmYXVsdE1vY2sSQAoPZmFsbGJhY2tfYWN0aW9uGAkgASgOMhcu'
    'bml0ZWxsYS5GYWxsYmFja0FjdGlvblIOZmFsbGJhY2tBY3Rpb24SOAoNZmFsbGJhY2tfbW9jax'
    'gKIAEoDjITLm5pdGVsbGEuTW9ja1ByZXNldFIMZmFsbGJhY2tNb2NrEkcKEGNsaWVudF9hdXRo'
    'X3R5cGUYCyABKA4yHS5uaXRlbGxhLnByb3h5LkNsaWVudEF1dGhUeXBlUg5jbGllbnRBdXRoVH'
    'lwZRISCgR0YWdzGAwgAygJUgR0YWdzEkMKDGhlYWx0aF9jaGVjaxgNIAEoCzIgLm5pdGVsbGEu'
    'cHJveHkuSGVhbHRoQ2hlY2tDb25maWdSC2hlYWx0aENoZWNr');

@$core.Deprecated('Use healthCheckConfigDescriptor instead')
const HealthCheckConfig$json = {
  '1': 'HealthCheckConfig',
  '2': [
    {'1': 'interval', '3': 1, '4': 1, '5': 9, '10': 'interval'},
    {'1': 'timeout', '3': 2, '4': 1, '5': 9, '10': 'timeout'},
    {
      '1': 'type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.nitella.proxy.HealthCheckType',
      '10': 'type'
    },
    {'1': 'path', '3': 4, '4': 1, '5': 9, '10': 'path'},
    {'1': 'expected_status', '3': 5, '4': 1, '5': 5, '10': 'expectedStatus'},
  ],
};

/// Descriptor for `HealthCheckConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthCheckConfigDescriptor = $convert.base64Decode(
    'ChFIZWFsdGhDaGVja0NvbmZpZxIaCghpbnRlcnZhbBgBIAEoCVIIaW50ZXJ2YWwSGAoHdGltZW'
    '91dBgCIAEoCVIHdGltZW91dBIyCgR0eXBlGAMgASgOMh4ubml0ZWxsYS5wcm94eS5IZWFsdGhD'
    'aGVja1R5cGVSBHR5cGUSEgoEcGF0aBgEIAEoCVIEcGF0aBInCg9leHBlY3RlZF9zdGF0dXMYBS'
    'ABKAVSDmV4cGVjdGVkU3RhdHVz');

@$core.Deprecated('Use createProxyResponseDescriptor instead')
const CreateProxyResponse$json = {
  '1': 'CreateProxyResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
    {'1': 'proxy_id', '3': 3, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `CreateProxyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProxyResponseDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVQcm94eVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSIwoNZXJyb3'
    'JfbWVzc2FnZRgCIAEoCVIMZXJyb3JNZXNzYWdlEhkKCHByb3h5X2lkGAMgASgJUgdwcm94eUlk');

@$core.Deprecated('Use disableProxyRequestDescriptor instead')
const DisableProxyRequest$json = {
  '1': 'DisableProxyRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `DisableProxyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disableProxyRequestDescriptor =
    $convert.base64Decode(
        'ChNEaXNhYmxlUHJveHlSZXF1ZXN0EhkKCHByb3h5X2lkGAEgASgJUgdwcm94eUlk');

@$core.Deprecated('Use disableProxyResponseDescriptor instead')
const DisableProxyResponse$json = {
  '1': 'DisableProxyResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `DisableProxyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disableProxyResponseDescriptor = $convert.base64Decode(
    'ChREaXNhYmxlUHJveHlSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEiMKDWVycm'
    '9yX21lc3NhZ2UYAiABKAlSDGVycm9yTWVzc2FnZQ==');

@$core.Deprecated('Use enableProxyRequestDescriptor instead')
const EnableProxyRequest$json = {
  '1': 'EnableProxyRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `EnableProxyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List enableProxyRequestDescriptor =
    $convert.base64Decode(
        'ChJFbmFibGVQcm94eVJlcXVlc3QSGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQ=');

@$core.Deprecated('Use enableProxyResponseDescriptor instead')
const EnableProxyResponse$json = {
  '1': 'EnableProxyResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `EnableProxyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List enableProxyResponseDescriptor = $convert.base64Decode(
    'ChNFbmFibGVQcm94eVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSIwoNZXJyb3'
    'JfbWVzc2FnZRgCIAEoCVIMZXJyb3JNZXNzYWdl');

@$core.Deprecated('Use deleteProxyRequestDescriptor instead')
const DeleteProxyRequest$json = {
  '1': 'DeleteProxyRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `DeleteProxyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteProxyRequestDescriptor =
    $convert.base64Decode(
        'ChJEZWxldGVQcm94eVJlcXVlc3QSGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQ=');

@$core.Deprecated('Use deleteProxyResponseDescriptor instead')
const DeleteProxyResponse$json = {
  '1': 'DeleteProxyResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `DeleteProxyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteProxyResponseDescriptor = $convert.base64Decode(
    'ChNEZWxldGVQcm94eVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSIwoNZXJyb3'
    'JfbWVzc2FnZRgCIAEoCVIMZXJyb3JNZXNzYWdl');

@$core.Deprecated('Use updateProxyRequestDescriptor instead')
const UpdateProxyRequest$json = {
  '1': 'UpdateProxyRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'listen_addr', '3': 2, '4': 1, '5': 9, '10': 'listenAddr'},
    {'1': 'default_backend', '3': 3, '4': 1, '5': 9, '10': 'defaultBackend'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'cert_pem', '3': 5, '4': 1, '5': 9, '10': 'certPem'},
    {'1': 'key_pem', '3': 6, '4': 1, '5': 9, '10': 'keyPem'},
    {'1': 'ca_pem', '3': 7, '4': 1, '5': 9, '10': 'caPem'},
    {
      '1': 'default_action',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.nitella.ActionType',
      '10': 'defaultAction'
    },
    {
      '1': 'default_mock',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.nitella.MockPreset',
      '10': 'defaultMock'
    },
    {
      '1': 'fallback_action',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.nitella.FallbackAction',
      '10': 'fallbackAction'
    },
    {
      '1': 'fallback_mock',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.nitella.MockPreset',
      '10': 'fallbackMock'
    },
    {
      '1': 'client_auth_type',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.nitella.proxy.ClientAuthType',
      '10': 'clientAuthType'
    },
    {'1': 'tags', '3': 13, '4': 3, '5': 9, '10': 'tags'},
    {
      '1': 'health_check',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.HealthCheckConfig',
      '10': 'healthCheck'
    },
  ],
};

/// Descriptor for `UpdateProxyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProxyRequestDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVQcm94eVJlcXVlc3QSGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQSHwoLbGlzdG'
    'VuX2FkZHIYAiABKAlSCmxpc3RlbkFkZHISJwoPZGVmYXVsdF9iYWNrZW5kGAMgASgJUg5kZWZh'
    'dWx0QmFja2VuZBISCgRuYW1lGAQgASgJUgRuYW1lEhkKCGNlcnRfcGVtGAUgASgJUgdjZXJ0UG'
    'VtEhcKB2tleV9wZW0YBiABKAlSBmtleVBlbRIVCgZjYV9wZW0YByABKAlSBWNhUGVtEjoKDmRl'
    'ZmF1bHRfYWN0aW9uGAggASgOMhMubml0ZWxsYS5BY3Rpb25UeXBlUg1kZWZhdWx0QWN0aW9uEj'
    'YKDGRlZmF1bHRfbW9jaxgJIAEoDjITLm5pdGVsbGEuTW9ja1ByZXNldFILZGVmYXVsdE1vY2sS'
    'QAoPZmFsbGJhY2tfYWN0aW9uGAogASgOMhcubml0ZWxsYS5GYWxsYmFja0FjdGlvblIOZmFsbG'
    'JhY2tBY3Rpb24SOAoNZmFsbGJhY2tfbW9jaxgLIAEoDjITLm5pdGVsbGEuTW9ja1ByZXNldFIM'
    'ZmFsbGJhY2tNb2NrEkcKEGNsaWVudF9hdXRoX3R5cGUYDCABKA4yHS5uaXRlbGxhLnByb3h5Lk'
    'NsaWVudEF1dGhUeXBlUg5jbGllbnRBdXRoVHlwZRISCgR0YWdzGA0gAygJUgR0YWdzEkMKDGhl'
    'YWx0aF9jaGVjaxgOIAEoCzIgLm5pdGVsbGEucHJveHkuSGVhbHRoQ2hlY2tDb25maWdSC2hlYW'
    'x0aENoZWNr');

@$core.Deprecated('Use updateProxyResponseDescriptor instead')
const UpdateProxyResponse$json = {
  '1': 'UpdateProxyResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `UpdateProxyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProxyResponseDescriptor = $convert.base64Decode(
    'ChNVcGRhdGVQcm94eVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSIwoNZXJyb3'
    'JfbWVzc2FnZRgCIAEoCVIMZXJyb3JNZXNzYWdl');

@$core.Deprecated('Use restartListenersResponseDescriptor instead')
const RestartListenersResponse$json = {
  '1': 'RestartListenersResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'restarted_count', '3': 2, '4': 1, '5': 5, '10': 'restartedCount'},
    {'1': 'error_message', '3': 3, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `RestartListenersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List restartListenersResponseDescriptor = $convert.base64Decode(
    'ChhSZXN0YXJ0TGlzdGVuZXJzUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxInCg'
    '9yZXN0YXJ0ZWRfY291bnQYAiABKAVSDnJlc3RhcnRlZENvdW50EiMKDWVycm9yX21lc3NhZ2UY'
    'AyABKAlSDGVycm9yTWVzc2FnZQ==');

@$core.Deprecated('Use getStatusRequestDescriptor instead')
const GetStatusRequest$json = {
  '1': 'GetStatusRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `GetStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatusRequestDescriptor = $convert.base64Decode(
    'ChBHZXRTdGF0dXNSZXF1ZXN0EhkKCHByb3h5X2lkGAEgASgJUgdwcm94eUlk');

@$core.Deprecated('Use proxyStatusDescriptor instead')
const ProxyStatus$json = {
  '1': 'ProxyStatus',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'running', '3': 2, '4': 1, '5': 8, '10': 'running'},
    {'1': 'listen_addr', '3': 3, '4': 1, '5': 9, '10': 'listenAddr'},
    {
      '1': 'active_connections',
      '3': 4,
      '4': 1,
      '5': 3,
      '10': 'activeConnections'
    },
    {
      '1': 'total_connections',
      '3': 5,
      '4': 1,
      '5': 3,
      '10': 'totalConnections'
    },
    {'1': 'bytes_in', '3': 6, '4': 1, '5': 3, '10': 'bytesIn'},
    {'1': 'bytes_out', '3': 7, '4': 1, '5': 3, '10': 'bytesOut'},
    {'1': 'uptime_seconds', '3': 8, '4': 1, '5': 3, '10': 'uptimeSeconds'},
    {'1': 'memory_rss', '3': 9, '4': 1, '5': 3, '10': 'memoryRss'},
    {
      '1': 'default_action',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.nitella.ActionType',
      '10': 'defaultAction'
    },
    {
      '1': 'default_mock',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.nitella.MockPreset',
      '10': 'defaultMock'
    },
    {
      '1': 'fallback_action',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.nitella.FallbackAction',
      '10': 'fallbackAction'
    },
    {
      '1': 'fallback_mock',
      '3': 13,
      '4': 1,
      '5': 14,
      '6': '.nitella.MockPreset',
      '10': 'fallbackMock'
    },
    {'1': 'default_backend', '3': 14, '4': 1, '5': 9, '10': 'defaultBackend'},
    {
      '1': 'client_auth_type',
      '3': 15,
      '4': 1,
      '5': 14,
      '6': '.nitella.proxy.ClientAuthType',
      '10': 'clientAuthType'
    },
    {'1': 'tags', '3': 16, '4': 3, '5': 9, '10': 'tags'},
    {
      '1': 'health_check',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.HealthCheckConfig',
      '10': 'healthCheck'
    },
    {
      '1': 'health_status',
      '3': 18,
      '4': 1,
      '5': 14,
      '6': '.nitella.proxy.HealthStatus',
      '10': 'healthStatus'
    },
  ],
};

/// Descriptor for `ProxyStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List proxyStatusDescriptor = $convert.base64Decode(
    'CgtQcm94eVN0YXR1cxIZCghwcm94eV9pZBgBIAEoCVIHcHJveHlJZBIYCgdydW5uaW5nGAIgAS'
    'gIUgdydW5uaW5nEh8KC2xpc3Rlbl9hZGRyGAMgASgJUgpsaXN0ZW5BZGRyEi0KEmFjdGl2ZV9j'
    'b25uZWN0aW9ucxgEIAEoA1IRYWN0aXZlQ29ubmVjdGlvbnMSKwoRdG90YWxfY29ubmVjdGlvbn'
    'MYBSABKANSEHRvdGFsQ29ubmVjdGlvbnMSGQoIYnl0ZXNfaW4YBiABKANSB2J5dGVzSW4SGwoJ'
    'Ynl0ZXNfb3V0GAcgASgDUghieXRlc091dBIlCg51cHRpbWVfc2Vjb25kcxgIIAEoA1INdXB0aW'
    '1lU2Vjb25kcxIdCgptZW1vcnlfcnNzGAkgASgDUgltZW1vcnlSc3MSOgoOZGVmYXVsdF9hY3Rp'
    'b24YCiABKA4yEy5uaXRlbGxhLkFjdGlvblR5cGVSDWRlZmF1bHRBY3Rpb24SNgoMZGVmYXVsdF'
    '9tb2NrGAsgASgOMhMubml0ZWxsYS5Nb2NrUHJlc2V0UgtkZWZhdWx0TW9jaxJACg9mYWxsYmFj'
    'a19hY3Rpb24YDCABKA4yFy5uaXRlbGxhLkZhbGxiYWNrQWN0aW9uUg5mYWxsYmFja0FjdGlvbh'
    'I4Cg1mYWxsYmFja19tb2NrGA0gASgOMhMubml0ZWxsYS5Nb2NrUHJlc2V0UgxmYWxsYmFja01v'
    'Y2sSJwoPZGVmYXVsdF9iYWNrZW5kGA4gASgJUg5kZWZhdWx0QmFja2VuZBJHChBjbGllbnRfYX'
    'V0aF90eXBlGA8gASgOMh0ubml0ZWxsYS5wcm94eS5DbGllbnRBdXRoVHlwZVIOY2xpZW50QXV0'
    'aFR5cGUSEgoEdGFncxgQIAMoCVIEdGFncxJDCgxoZWFsdGhfY2hlY2sYESABKAsyIC5uaXRlbG'
    'xhLnByb3h5LkhlYWx0aENoZWNrQ29uZmlnUgtoZWFsdGhDaGVjaxJACg1oZWFsdGhfc3RhdHVz'
    'GBIgASgOMhsubml0ZWxsYS5wcm94eS5IZWFsdGhTdGF0dXNSDGhlYWx0aFN0YXR1cw==');

@$core.Deprecated('Use reloadRulesRequestDescriptor instead')
const ReloadRulesRequest$json = {
  '1': 'ReloadRulesRequest',
  '2': [
    {
      '1': 'rules',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.proxy.Rule',
      '10': 'rules'
    },
  ],
};

/// Descriptor for `ReloadRulesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reloadRulesRequestDescriptor = $convert.base64Decode(
    'ChJSZWxvYWRSdWxlc1JlcXVlc3QSKQoFcnVsZXMYASADKAsyEy5uaXRlbGxhLnByb3h5LlJ1bG'
    'VSBXJ1bGVz');

@$core.Deprecated('Use reloadRulesResponseDescriptor instead')
const ReloadRulesResponse$json = {
  '1': 'ReloadRulesResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'rules_loaded', '3': 2, '4': 1, '5': 5, '10': 'rulesLoaded'},
    {'1': 'error_message', '3': 3, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `ReloadRulesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reloadRulesResponseDescriptor = $convert.base64Decode(
    'ChNSZWxvYWRSdWxlc1Jlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSIQoMcnVsZX'
    'NfbG9hZGVkGAIgASgFUgtydWxlc0xvYWRlZBIjCg1lcnJvcl9tZXNzYWdlGAMgASgJUgxlcnJv'
    'ck1lc3NhZ2U=');

@$core.Deprecated('Use applyProxyRequestDescriptor instead')
const ApplyProxyRequest$json = {
  '1': 'ApplyProxyRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'revision_num', '3': 2, '4': 1, '5': 3, '10': 'revisionNum'},
    {'1': 'config_yaml', '3': 3, '4': 1, '5': 9, '10': 'configYaml'},
    {'1': 'config_hash', '3': 4, '4': 1, '5': 9, '10': 'configHash'},
  ],
};

/// Descriptor for `ApplyProxyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applyProxyRequestDescriptor = $convert.base64Decode(
    'ChFBcHBseVByb3h5UmVxdWVzdBIZCghwcm94eV9pZBgBIAEoCVIHcHJveHlJZBIhCgxyZXZpc2'
    'lvbl9udW0YAiABKANSC3JldmlzaW9uTnVtEh8KC2NvbmZpZ195YW1sGAMgASgJUgpjb25maWdZ'
    'YW1sEh8KC2NvbmZpZ19oYXNoGAQgASgJUgpjb25maWdIYXNo');

@$core.Deprecated('Use applyProxyResponseDescriptor instead')
const ApplyProxyResponse$json = {
  '1': 'ApplyProxyResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `ApplyProxyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applyProxyResponseDescriptor = $convert.base64Decode(
    'ChJBcHBseVByb3h5UmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIjCg1lcnJvcl'
    '9tZXNzYWdlGAIgASgJUgxlcnJvck1lc3NhZ2U=');

@$core.Deprecated('Use appliedProxyStatusDescriptor instead')
const AppliedProxyStatus$json = {
  '1': 'AppliedProxyStatus',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'revision_num', '3': 2, '4': 1, '5': 3, '10': 'revisionNum'},
    {'1': 'applied_at', '3': 3, '4': 1, '5': 9, '10': 'appliedAt'},
    {'1': 'status', '3': 4, '4': 1, '5': 9, '10': 'status'},
    {'1': 'error_message', '3': 5, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `AppliedProxyStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List appliedProxyStatusDescriptor = $convert.base64Decode(
    'ChJBcHBsaWVkUHJveHlTdGF0dXMSGQoIcHJveHlfaWQYASABKAlSB3Byb3h5SWQSIQoMcmV2aX'
    'Npb25fbnVtGAIgASgDUgtyZXZpc2lvbk51bRIdCgphcHBsaWVkX2F0GAMgASgJUglhcHBsaWVk'
    'QXQSFgoGc3RhdHVzGAQgASgJUgZzdGF0dXMSIwoNZXJyb3JfbWVzc2FnZRgFIAEoCVIMZXJyb3'
    'JNZXNzYWdl');

@$core.Deprecated('Use getAppliedProxiesResponseDescriptor instead')
const GetAppliedProxiesResponse$json = {
  '1': 'GetAppliedProxiesResponse',
  '2': [
    {
      '1': 'proxies',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.proxy.AppliedProxyStatus',
      '10': 'proxies'
    },
  ],
};

/// Descriptor for `GetAppliedProxiesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAppliedProxiesResponseDescriptor =
    $convert.base64Decode(
        'ChlHZXRBcHBsaWVkUHJveGllc1Jlc3BvbnNlEjsKB3Byb3hpZXMYASADKAsyIS5uaXRlbGxhLn'
        'Byb3h5LkFwcGxpZWRQcm94eVN0YXR1c1IHcHJveGllcw==');

@$core.Deprecated('Use ruleDescriptor instead')
const Rule$json = {
  '1': 'Rule',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'priority', '3': 3, '4': 1, '5': 5, '10': 'priority'},
    {'1': 'enabled', '3': 4, '4': 1, '5': 8, '10': 'enabled'},
    {
      '1': 'conditions',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.nitella.proxy.Condition',
      '10': 'conditions'
    },
    {
      '1': 'action',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.nitella.ActionType',
      '10': 'action'
    },
    {'1': 'target_backend', '3': 7, '4': 1, '5': 9, '10': 'targetBackend'},
    {
      '1': 'rate_limit',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.RateLimitConfig',
      '10': 'rateLimit'
    },
    {
      '1': 'mock_response',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.MockConfig',
      '10': 'mockResponse'
    },
    {'1': 'expression', '3': 10, '4': 1, '5': 9, '10': 'expression'},
  ],
};

/// Descriptor for `Rule`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ruleDescriptor = $convert.base64Decode(
    'CgRSdWxlEg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEhoKCHByaW9yaXR5GA'
    'MgASgFUghwcmlvcml0eRIYCgdlbmFibGVkGAQgASgIUgdlbmFibGVkEjgKCmNvbmRpdGlvbnMY'
    'BSADKAsyGC5uaXRlbGxhLnByb3h5LkNvbmRpdGlvblIKY29uZGl0aW9ucxIrCgZhY3Rpb24YBi'
    'ABKA4yEy5uaXRlbGxhLkFjdGlvblR5cGVSBmFjdGlvbhIlCg50YXJnZXRfYmFja2VuZBgHIAEo'
    'CVINdGFyZ2V0QmFja2VuZBI9CgpyYXRlX2xpbWl0GAggASgLMh4ubml0ZWxsYS5wcm94eS5SYX'
    'RlTGltaXRDb25maWdSCXJhdGVMaW1pdBI+Cg1tb2NrX3Jlc3BvbnNlGAkgASgLMhkubml0ZWxs'
    'YS5wcm94eS5Nb2NrQ29uZmlnUgxtb2NrUmVzcG9uc2USHgoKZXhwcmVzc2lvbhgKIAEoCVIKZX'
    'hwcmVzc2lvbg==');

@$core.Deprecated('Use conditionDescriptor instead')
const Condition$json = {
  '1': 'Condition',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.nitella.ConditionType',
      '10': 'type'
    },
    {'1': 'op', '3': 2, '4': 1, '5': 14, '6': '.nitella.Operator', '10': 'op'},
    {'1': 'value', '3': 3, '4': 1, '5': 9, '10': 'value'},
    {'1': 'negate', '3': 4, '4': 1, '5': 8, '10': 'negate'},
  ],
};

/// Descriptor for `Condition`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conditionDescriptor = $convert.base64Decode(
    'CglDb25kaXRpb24SKgoEdHlwZRgBIAEoDjIWLm5pdGVsbGEuQ29uZGl0aW9uVHlwZVIEdHlwZR'
    'IhCgJvcBgCIAEoDjIRLm5pdGVsbGEuT3BlcmF0b3JSAm9wEhQKBXZhbHVlGAMgASgJUgV2YWx1'
    'ZRIWCgZuZWdhdGUYBCABKAhSBm5lZ2F0ZQ==');

@$core.Deprecated('Use rateLimitConfigDescriptor instead')
const RateLimitConfig$json = {
  '1': 'RateLimitConfig',
  '2': [
    {'1': 'max_connections', '3': 1, '4': 1, '5': 5, '10': 'maxConnections'},
    {'1': 'interval_seconds', '3': 2, '4': 1, '5': 5, '10': 'intervalSeconds'},
    {'1': 'auto_block', '3': 3, '4': 1, '5': 8, '10': 'autoBlock'},
    {
      '1': 'block_duration_seconds',
      '3': 4,
      '4': 1,
      '5': 5,
      '10': 'blockDurationSeconds'
    },
    {
      '1': 'block_steps_seconds',
      '3': 5,
      '4': 3,
      '5': 5,
      '10': 'blockStepsSeconds'
    },
    {
      '1': 'count_only_failures',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'countOnlyFailures'
    },
    {
      '1': 'failure_duration_threshold',
      '3': 7,
      '4': 1,
      '5': 5,
      '10': 'failureDurationThreshold'
    },
  ],
};

/// Descriptor for `RateLimitConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rateLimitConfigDescriptor = $convert.base64Decode(
    'Cg9SYXRlTGltaXRDb25maWcSJwoPbWF4X2Nvbm5lY3Rpb25zGAEgASgFUg5tYXhDb25uZWN0aW'
    '9ucxIpChBpbnRlcnZhbF9zZWNvbmRzGAIgASgFUg9pbnRlcnZhbFNlY29uZHMSHQoKYXV0b19i'
    'bG9jaxgDIAEoCFIJYXV0b0Jsb2NrEjQKFmJsb2NrX2R1cmF0aW9uX3NlY29uZHMYBCABKAVSFG'
    'Jsb2NrRHVyYXRpb25TZWNvbmRzEi4KE2Jsb2NrX3N0ZXBzX3NlY29uZHMYBSADKAVSEWJsb2Nr'
    'U3RlcHNTZWNvbmRzEi4KE2NvdW50X29ubHlfZmFpbHVyZXMYBiABKAhSEWNvdW50T25seUZhaW'
    'x1cmVzEjwKGmZhaWx1cmVfZHVyYXRpb25fdGhyZXNob2xkGAcgASgFUhhmYWlsdXJlRHVyYXRp'
    'b25UaHJlc2hvbGQ=');

@$core.Deprecated('Use mockConfigDescriptor instead')
const MockConfig$json = {
  '1': 'MockConfig',
  '2': [
    {
      '1': 'preset',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.nitella.MockPreset',
      '10': 'preset'
    },
    {'1': 'protocol', '3': 2, '4': 1, '5': 9, '10': 'protocol'},
    {'1': 'payload', '3': 3, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'delay_ms', '3': 4, '4': 1, '5': 5, '10': 'delayMs'},
  ],
};

/// Descriptor for `MockConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mockConfigDescriptor = $convert.base64Decode(
    'CgpNb2NrQ29uZmlnEisKBnByZXNldBgBIAEoDjITLm5pdGVsbGEuTW9ja1ByZXNldFIGcHJlc2'
    'V0EhoKCHByb3RvY29sGAIgASgJUghwcm90b2NvbBIYCgdwYXlsb2FkGAMgASgMUgdwYXlsb2Fk'
    'EhkKCGRlbGF5X21zGAQgASgFUgdkZWxheU1z');

@$core.Deprecated('Use addRuleRequestDescriptor instead')
const AddRuleRequest$json = {
  '1': 'AddRuleRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {
      '1': 'rule',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.nitella.proxy.Rule',
      '10': 'rule'
    },
  ],
};

/// Descriptor for `AddRuleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addRuleRequestDescriptor = $convert.base64Decode(
    'Cg5BZGRSdWxlUmVxdWVzdBIZCghwcm94eV9pZBgBIAEoCVIHcHJveHlJZBInCgRydWxlGAIgAS'
    'gLMhMubml0ZWxsYS5wcm94eS5SdWxlUgRydWxl');

@$core.Deprecated('Use removeRuleRequestDescriptor instead')
const RemoveRuleRequest$json = {
  '1': 'RemoveRuleRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'rule_id', '3': 2, '4': 1, '5': 9, '10': 'ruleId'},
  ],
};

/// Descriptor for `RemoveRuleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeRuleRequestDescriptor = $convert.base64Decode(
    'ChFSZW1vdmVSdWxlUmVxdWVzdBIZCghwcm94eV9pZBgBIAEoCVIHcHJveHlJZBIXCgdydWxlX2'
    'lkGAIgASgJUgZydWxlSWQ=');

@$core.Deprecated('Use listRulesRequestDescriptor instead')
const ListRulesRequest$json = {
  '1': 'ListRulesRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `ListRulesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRulesRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0UnVsZXNSZXF1ZXN0EhkKCHByb3h5X2lkGAEgASgJUgdwcm94eUlk');

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
  ],
};

/// Descriptor for `ListRulesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRulesResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0UnVsZXNSZXNwb25zZRIpCgVydWxlcxgBIAMoCzITLm5pdGVsbGEucHJveHkuUnVsZV'
    'IFcnVsZXM=');

@$core.Deprecated('Use listProxiesRequestDescriptor instead')
const ListProxiesRequest$json = {
  '1': 'ListProxiesRequest',
};

/// Descriptor for `ListProxiesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProxiesRequestDescriptor =
    $convert.base64Decode('ChJMaXN0UHJveGllc1JlcXVlc3Q=');

@$core.Deprecated('Use listProxiesResponseDescriptor instead')
const ListProxiesResponse$json = {
  '1': 'ListProxiesResponse',
  '2': [
    {
      '1': 'proxies',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.proxy.ProxyStatus',
      '10': 'proxies'
    },
  ],
};

/// Descriptor for `ListProxiesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProxiesResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0UHJveGllc1Jlc3BvbnNlEjQKB3Byb3hpZXMYASADKAsyGi5uaXRlbGxhLnByb3h5Ll'
    'Byb3h5U3RhdHVzUgdwcm94aWVz');

@$core.Deprecated('Use blockIPRequestDescriptor instead')
const BlockIPRequest$json = {
  '1': 'BlockIPRequest',
  '2': [
    {'1': 'ip', '3': 1, '4': 1, '5': 9, '10': 'ip'},
    {'1': 'duration_seconds', '3': 2, '4': 1, '5': 3, '10': 'durationSeconds'},
    {'1': 'reason', '3': 3, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `BlockIPRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockIPRequestDescriptor = $convert.base64Decode(
    'Cg5CbG9ja0lQUmVxdWVzdBIOCgJpcBgBIAEoCVICaXASKQoQZHVyYXRpb25fc2Vjb25kcxgCIA'
    'EoA1IPZHVyYXRpb25TZWNvbmRzEhYKBnJlYXNvbhgDIAEoCVIGcmVhc29u');

@$core.Deprecated('Use allowIPRequestDescriptor instead')
const AllowIPRequest$json = {
  '1': 'AllowIPRequest',
  '2': [
    {'1': 'ip', '3': 1, '4': 1, '5': 9, '10': 'ip'},
    {'1': 'duration_seconds', '3': 2, '4': 1, '5': 3, '10': 'durationSeconds'},
  ],
};

/// Descriptor for `AllowIPRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List allowIPRequestDescriptor = $convert.base64Decode(
    'Cg5BbGxvd0lQUmVxdWVzdBIOCgJpcBgBIAEoCVICaXASKQoQZHVyYXRpb25fc2Vjb25kcxgCIA'
    'EoA1IPZHVyYXRpb25TZWNvbmRz');

@$core.Deprecated('Use globalRuleDescriptor instead')
const GlobalRule$json = {
  '1': 'GlobalRule',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'source_ip', '3': 3, '4': 1, '5': 9, '10': 'sourceIp'},
    {
      '1': 'action',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.nitella.ActionType',
      '10': 'action'
    },
    {
      '1': 'expires_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiresAt'
    },
    {
      '1': 'created_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `GlobalRule`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List globalRuleDescriptor = $convert.base64Decode(
    'CgpHbG9iYWxSdWxlEg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEhsKCXNvdX'
    'JjZV9pcBgDIAEoCVIIc291cmNlSXASKwoGYWN0aW9uGAQgASgOMhMubml0ZWxsYS5BY3Rpb25U'
    'eXBlUgZhY3Rpb24SOQoKZXhwaXJlc19hdBgFIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3'
    'RhbXBSCWV4cGlyZXNBdBI5CgpjcmVhdGVkX2F0GAYgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRp'
    'bWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use listGlobalRulesRequestDescriptor instead')
const ListGlobalRulesRequest$json = {
  '1': 'ListGlobalRulesRequest',
};

/// Descriptor for `ListGlobalRulesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listGlobalRulesRequestDescriptor =
    $convert.base64Decode('ChZMaXN0R2xvYmFsUnVsZXNSZXF1ZXN0');

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
    {'1': 'rule_id', '3': 1, '4': 1, '5': 9, '10': 'ruleId'},
  ],
};

/// Descriptor for `RemoveGlobalRuleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeGlobalRuleRequestDescriptor =
    $convert.base64Decode(
        'ChdSZW1vdmVHbG9iYWxSdWxlUmVxdWVzdBIXCgdydWxlX2lkGAEgASgJUgZydWxlSWQ=');

@$core.Deprecated('Use removeGlobalRuleResponseDescriptor instead')
const RemoveGlobalRuleResponse$json = {
  '1': 'RemoveGlobalRuleResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `RemoveGlobalRuleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeGlobalRuleResponseDescriptor =
    $convert.base64Decode(
        'ChhSZW1vdmVHbG9iYWxSdWxlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIjCg'
        '1lcnJvcl9tZXNzYWdlGAIgASgJUgxlcnJvck1lc3NhZ2U=');

@$core.Deprecated('Use streamConnectionsRequestDescriptor instead')
const StreamConnectionsRequest$json = {
  '1': 'StreamConnectionsRequest',
  '2': [
    {'1': 'active_only', '3': 1, '4': 1, '5': 8, '10': 'activeOnly'},
    {'1': 'viewer_pubkey', '3': 2, '4': 1, '5': 12, '10': 'viewerPubkey'},
  ],
};

/// Descriptor for `StreamConnectionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamConnectionsRequestDescriptor =
    $convert.base64Decode(
        'ChhTdHJlYW1Db25uZWN0aW9uc1JlcXVlc3QSHwoLYWN0aXZlX29ubHkYASABKAhSCmFjdGl2ZU'
        '9ubHkSIwoNdmlld2VyX3B1YmtleRgCIAEoDFIMdmlld2VyUHVia2V5');

@$core.Deprecated('Use connectionEventDescriptor instead')
const ConnectionEvent$json = {
  '1': 'ConnectionEvent',
  '2': [
    {'1': 'conn_id', '3': 1, '4': 1, '5': 9, '10': 'connId'},
    {'1': 'source_ip', '3': 2, '4': 1, '5': 9, '10': 'sourceIp'},
    {'1': 'source_port', '3': 3, '4': 1, '5': 5, '10': 'sourcePort'},
    {'1': 'target_addr', '3': 4, '4': 1, '5': 9, '10': 'targetAddr'},
    {
      '1': 'event_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.nitella.proxy.EventType',
      '10': 'eventType'
    },
    {'1': 'timestamp', '3': 6, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'rule_matched', '3': 7, '4': 1, '5': 9, '10': 'ruleMatched'},
    {
      '1': 'action_taken',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.nitella.ActionType',
      '10': 'actionTaken'
    },
    {'1': 'bytes_in', '3': 9, '4': 1, '5': 3, '10': 'bytesIn'},
    {'1': 'bytes_out', '3': 10, '4': 1, '5': 3, '10': 'bytesOut'},
    {
      '1': 'geo',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.nitella.GeoInfo',
      '10': 'geo'
    },
  ],
};

/// Descriptor for `ConnectionEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List connectionEventDescriptor = $convert.base64Decode(
    'Cg9Db25uZWN0aW9uRXZlbnQSFwoHY29ubl9pZBgBIAEoCVIGY29ubklkEhsKCXNvdXJjZV9pcB'
    'gCIAEoCVIIc291cmNlSXASHwoLc291cmNlX3BvcnQYAyABKAVSCnNvdXJjZVBvcnQSHwoLdGFy'
    'Z2V0X2FkZHIYBCABKAlSCnRhcmdldEFkZHISNwoKZXZlbnRfdHlwZRgFIAEoDjIYLm5pdGVsbG'
    'EucHJveHkuRXZlbnRUeXBlUglldmVudFR5cGUSHAoJdGltZXN0YW1wGAYgASgDUgl0aW1lc3Rh'
    'bXASIQoMcnVsZV9tYXRjaGVkGAcgASgJUgtydWxlTWF0Y2hlZBI2CgxhY3Rpb25fdGFrZW4YCC'
    'ABKA4yEy5uaXRlbGxhLkFjdGlvblR5cGVSC2FjdGlvblRha2VuEhkKCGJ5dGVzX2luGAkgASgD'
    'UgdieXRlc0luEhsKCWJ5dGVzX291dBgKIAEoA1IIYnl0ZXNPdXQSIgoDZ2VvGAsgASgLMhAubm'
    'l0ZWxsYS5HZW9JbmZvUgNnZW8=');

@$core.Deprecated('Use streamMetricsRequestDescriptor instead')
const StreamMetricsRequest$json = {
  '1': 'StreamMetricsRequest',
  '2': [
    {'1': 'interval_seconds', '3': 1, '4': 1, '5': 5, '10': 'intervalSeconds'},
    {'1': 'viewer_pubkey', '3': 2, '4': 1, '5': 12, '10': 'viewerPubkey'},
  ],
};

/// Descriptor for `StreamMetricsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamMetricsRequestDescriptor = $convert.base64Decode(
    'ChRTdHJlYW1NZXRyaWNzUmVxdWVzdBIpChBpbnRlcnZhbF9zZWNvbmRzGAEgASgFUg9pbnRlcn'
    'ZhbFNlY29uZHMSIwoNdmlld2VyX3B1YmtleRgCIAEoDFIMdmlld2VyUHVia2V5');

@$core.Deprecated('Use metricsSampleDescriptor instead')
const MetricsSample$json = {
  '1': 'MetricsSample',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'active_conns', '3': 2, '4': 1, '5': 3, '10': 'activeConns'},
    {'1': 'total_conns', '3': 3, '4': 1, '5': 3, '10': 'totalConns'},
    {'1': 'bytes_in_rate', '3': 4, '4': 1, '5': 3, '10': 'bytesInRate'},
    {'1': 'bytes_out_rate', '3': 5, '4': 1, '5': 3, '10': 'bytesOutRate'},
    {'1': 'blocked_total', '3': 6, '4': 1, '5': 3, '10': 'blockedTotal'},
  ],
};

/// Descriptor for `MetricsSample`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List metricsSampleDescriptor = $convert.base64Decode(
    'Cg1NZXRyaWNzU2FtcGxlEhwKCXRpbWVzdGFtcBgBIAEoA1IJdGltZXN0YW1wEiEKDGFjdGl2ZV'
    '9jb25ucxgCIAEoA1ILYWN0aXZlQ29ubnMSHwoLdG90YWxfY29ubnMYAyABKANSCnRvdGFsQ29u'
    'bnMSIgoNYnl0ZXNfaW5fcmF0ZRgEIAEoA1ILYnl0ZXNJblJhdGUSJAoOYnl0ZXNfb3V0X3JhdG'
    'UYBSABKANSDGJ5dGVzT3V0UmF0ZRIjCg1ibG9ja2VkX3RvdGFsGAYgASgDUgxibG9ja2VkVG90'
    'YWw=');

@$core.Deprecated('Use encryptedStreamPayloadDescriptor instead')
const EncryptedStreamPayload$json = {
  '1': 'EncryptedStreamPayload',
  '2': [
    {
      '1': 'encrypted',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.nitella.EncryptedPayload',
      '10': 'encrypted'
    },
    {'1': 'payload_type', '3': 2, '4': 1, '5': 9, '10': 'payloadType'},
  ],
};

/// Descriptor for `EncryptedStreamPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encryptedStreamPayloadDescriptor = $convert.base64Decode(
    'ChZFbmNyeXB0ZWRTdHJlYW1QYXlsb2FkEjcKCWVuY3J5cHRlZBgBIAEoCzIZLm5pdGVsbGEuRW'
    '5jcnlwdGVkUGF5bG9hZFIJZW5jcnlwdGVkEiEKDHBheWxvYWRfdHlwZRgCIAEoCVILcGF5bG9h'
    'ZFR5cGU=');

@$core.Deprecated('Use activeConnectionDescriptor instead')
const ActiveConnection$json = {
  '1': 'ActiveConnection',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'source_ip', '3': 2, '4': 1, '5': 9, '10': 'sourceIp'},
    {'1': 'source_port', '3': 3, '4': 1, '5': 5, '10': 'sourcePort'},
    {'1': 'dest_addr', '3': 4, '4': 1, '5': 9, '10': 'destAddr'},
    {
      '1': 'start_time',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startTime'
    },
    {'1': 'bytes_in', '3': 6, '4': 1, '5': 3, '10': 'bytesIn'},
    {'1': 'bytes_out', '3': 7, '4': 1, '5': 3, '10': 'bytesOut'},
    {'1': 'geo', '3': 8, '4': 1, '5': 11, '6': '.nitella.GeoInfo', '10': 'geo'},
  ],
};

/// Descriptor for `ActiveConnection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activeConnectionDescriptor = $convert.base64Decode(
    'ChBBY3RpdmVDb25uZWN0aW9uEg4KAmlkGAEgASgJUgJpZBIbCglzb3VyY2VfaXAYAiABKAlSCH'
    'NvdXJjZUlwEh8KC3NvdXJjZV9wb3J0GAMgASgFUgpzb3VyY2VQb3J0EhsKCWRlc3RfYWRkchgE'
    'IAEoCVIIZGVzdEFkZHISOQoKc3RhcnRfdGltZRgFIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW'
    '1lc3RhbXBSCXN0YXJ0VGltZRIZCghieXRlc19pbhgGIAEoA1IHYnl0ZXNJbhIbCglieXRlc19v'
    'dXQYByABKANSCGJ5dGVzT3V0EiIKA2dlbxgIIAEoCzIQLm5pdGVsbGEuR2VvSW5mb1IDZ2Vv');

@$core.Deprecated('Use getActiveConnectionsRequestDescriptor instead')
const GetActiveConnectionsRequest$json = {
  '1': 'GetActiveConnectionsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'proxy_id', '3': 2, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `GetActiveConnectionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getActiveConnectionsRequestDescriptor =
    $convert.base64Decode(
        'ChtHZXRBY3RpdmVDb25uZWN0aW9uc1JlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlkEh'
        'kKCHByb3h5X2lkGAIgASgJUgdwcm94eUlk');

@$core.Deprecated('Use getActiveConnectionsResponseDescriptor instead')
const GetActiveConnectionsResponse$json = {
  '1': 'GetActiveConnectionsResponse',
  '2': [
    {
      '1': 'connections',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.proxy.ActiveConnection',
      '10': 'connections'
    },
  ],
};

/// Descriptor for `GetActiveConnectionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getActiveConnectionsResponseDescriptor =
    $convert.base64Decode(
        'ChxHZXRBY3RpdmVDb25uZWN0aW9uc1Jlc3BvbnNlEkEKC2Nvbm5lY3Rpb25zGAEgAygLMh8ubm'
        'l0ZWxsYS5wcm94eS5BY3RpdmVDb25uZWN0aW9uUgtjb25uZWN0aW9ucw==');

@$core.Deprecated('Use closeConnectionRequestDescriptor instead')
const CloseConnectionRequest$json = {
  '1': 'CloseConnectionRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'conn_id', '3': 2, '4': 1, '5': 9, '10': 'connId'},
  ],
};

/// Descriptor for `CloseConnectionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List closeConnectionRequestDescriptor =
    $convert.base64Decode(
        'ChZDbG9zZUNvbm5lY3Rpb25SZXF1ZXN0EhkKCHByb3h5X2lkGAEgASgJUgdwcm94eUlkEhcKB2'
        'Nvbm5faWQYAiABKAlSBmNvbm5JZA==');

@$core.Deprecated('Use closeConnectionResponseDescriptor instead')
const CloseConnectionResponse$json = {
  '1': 'CloseConnectionResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `CloseConnectionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List closeConnectionResponseDescriptor =
    $convert.base64Decode(
        'ChdDbG9zZUNvbm5lY3Rpb25SZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEiMKDW'
        'Vycm9yX21lc3NhZ2UYAiABKAlSDGVycm9yTWVzc2FnZQ==');

@$core.Deprecated('Use closeAllConnectionsRequestDescriptor instead')
const CloseAllConnectionsRequest$json = {
  '1': 'CloseAllConnectionsRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
  ],
};

/// Descriptor for `CloseAllConnectionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List closeAllConnectionsRequestDescriptor =
    $convert.base64Decode(
        'ChpDbG9zZUFsbENvbm5lY3Rpb25zUmVxdWVzdBIZCghwcm94eV9pZBgBIAEoCVIHcHJveHlJZA'
        '==');

@$core.Deprecated('Use closeAllConnectionsResponseDescriptor instead')
const CloseAllConnectionsResponse$json = {
  '1': 'CloseAllConnectionsResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `CloseAllConnectionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List closeAllConnectionsResponseDescriptor =
    $convert.base64Decode(
        'ChtDbG9zZUFsbENvbm5lY3Rpb25zUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcx'
        'IjCg1lcnJvcl9tZXNzYWdlGAIgASgJUgxlcnJvck1lc3NhZ2U=');

@$core.Deprecated('Use getIPStatsRequestDescriptor instead')
const GetIPStatsRequest$json = {
  '1': 'GetIPStatsRequest',
  '2': [
    {'1': 'limit', '3': 1, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'offset', '3': 2, '4': 1, '5': 5, '10': 'offset'},
    {'1': 'source_ip_filter', '3': 3, '4': 1, '5': 9, '10': 'sourceIpFilter'},
    {'1': 'country_filter', '3': 4, '4': 1, '5': 9, '10': 'countryFilter'},
    {'1': 'sort_by', '3': 5, '4': 1, '5': 9, '10': 'sortBy'},
  ],
};

/// Descriptor for `GetIPStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getIPStatsRequestDescriptor = $convert.base64Decode(
    'ChFHZXRJUFN0YXRzUmVxdWVzdBIUCgVsaW1pdBgBIAEoBVIFbGltaXQSFgoGb2Zmc2V0GAIgAS'
    'gFUgZvZmZzZXQSKAoQc291cmNlX2lwX2ZpbHRlchgDIAEoCVIOc291cmNlSXBGaWx0ZXISJQoO'
    'Y291bnRyeV9maWx0ZXIYBCABKAlSDWNvdW50cnlGaWx0ZXISFwoHc29ydF9ieRgFIAEoCVIGc2'
    '9ydEJ5');

@$core.Deprecated('Use iPStatsResultDescriptor instead')
const IPStatsResult$json = {
  '1': 'IPStatsResult',
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
    {'1': 'total_duration_ms', '3': 7, '4': 1, '5': 3, '10': 'totalDurationMs'},
    {'1': 'blocked_count', '3': 8, '4': 1, '5': 3, '10': 'blockedCount'},
    {'1': 'allowed_count', '3': 9, '4': 1, '5': 3, '10': 'allowedCount'},
    {'1': 'geo_country', '3': 10, '4': 1, '5': 9, '10': 'geoCountry'},
    {'1': 'geo_city', '3': 11, '4': 1, '5': 9, '10': 'geoCity'},
    {'1': 'geo_isp', '3': 12, '4': 1, '5': 9, '10': 'geoIsp'},
    {'1': 'recency_weight', '3': 13, '4': 1, '5': 1, '10': 'recencyWeight'},
  ],
};

/// Descriptor for `IPStatsResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List iPStatsResultDescriptor = $convert.base64Decode(
    'Cg1JUFN0YXRzUmVzdWx0EhsKCXNvdXJjZV9pcBgBIAEoCVIIc291cmNlSXASOQoKZmlyc3Rfc2'
    'VlbhgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWZpcnN0U2VlbhI3CglsYXN0'
    'X3NlZW4YAyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUghsYXN0U2VlbhIpChBjb2'
    '5uZWN0aW9uX2NvdW50GAQgASgDUg9jb25uZWN0aW9uQ291bnQSJAoOdG90YWxfYnl0ZXNfaW4Y'
    'BSABKANSDHRvdGFsQnl0ZXNJbhImCg90b3RhbF9ieXRlc19vdXQYBiABKANSDXRvdGFsQnl0ZX'
    'NPdXQSKgoRdG90YWxfZHVyYXRpb25fbXMYByABKANSD3RvdGFsRHVyYXRpb25NcxIjCg1ibG9j'
    'a2VkX2NvdW50GAggASgDUgxibG9ja2VkQ291bnQSIwoNYWxsb3dlZF9jb3VudBgJIAEoA1IMYW'
    'xsb3dlZENvdW50Eh8KC2dlb19jb3VudHJ5GAogASgJUgpnZW9Db3VudHJ5EhkKCGdlb19jaXR5'
    'GAsgASgJUgdnZW9DaXR5EhcKB2dlb19pc3AYDCABKAlSBmdlb0lzcBIlCg5yZWNlbmN5X3dlaW'
    'dodBgNIAEoAVINcmVjZW5jeVdlaWdodA==');

@$core.Deprecated('Use getIPStatsResponseDescriptor instead')
const GetIPStatsResponse$json = {
  '1': 'GetIPStatsResponse',
  '2': [
    {
      '1': 'stats',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.proxy.IPStatsResult',
      '10': 'stats'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 3, '10': 'totalCount'},
  ],
};

/// Descriptor for `GetIPStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getIPStatsResponseDescriptor = $convert.base64Decode(
    'ChJHZXRJUFN0YXRzUmVzcG9uc2USMgoFc3RhdHMYASADKAsyHC5uaXRlbGxhLnByb3h5LklQU3'
    'RhdHNSZXN1bHRSBXN0YXRzEh8KC3RvdGFsX2NvdW50GAIgASgDUgp0b3RhbENvdW50');

@$core.Deprecated('Use getGeoStatsRequestDescriptor instead')
const GetGeoStatsRequest$json = {
  '1': 'GetGeoStatsRequest',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'offset', '3': 3, '4': 1, '5': 5, '10': 'offset'},
  ],
};

/// Descriptor for `GetGeoStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGeoStatsRequestDescriptor = $convert.base64Decode(
    'ChJHZXRHZW9TdGF0c1JlcXVlc3QSEgoEdHlwZRgBIAEoCVIEdHlwZRIUCgVsaW1pdBgCIAEoBV'
    'IFbGltaXQSFgoGb2Zmc2V0GAMgASgFUgZvZmZzZXQ=');

@$core.Deprecated('Use geoStatsResultDescriptor instead')
const GeoStatsResult$json = {
  '1': 'GeoStatsResult',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
    {'1': 'connection_count', '3': 3, '4': 1, '5': 3, '10': 'connectionCount'},
    {'1': 'unique_ips', '3': 4, '4': 1, '5': 3, '10': 'uniqueIps'},
    {'1': 'total_bytes_in', '3': 5, '4': 1, '5': 3, '10': 'totalBytesIn'},
    {'1': 'total_bytes_out', '3': 6, '4': 1, '5': 3, '10': 'totalBytesOut'},
    {'1': 'blocked_count', '3': 7, '4': 1, '5': 3, '10': 'blockedCount'},
  ],
};

/// Descriptor for `GeoStatsResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List geoStatsResultDescriptor = $convert.base64Decode(
    'Cg5HZW9TdGF0c1Jlc3VsdBISCgR0eXBlGAEgASgJUgR0eXBlEhQKBXZhbHVlGAIgASgJUgV2YW'
    'x1ZRIpChBjb25uZWN0aW9uX2NvdW50GAMgASgDUg9jb25uZWN0aW9uQ291bnQSHQoKdW5pcXVl'
    'X2lwcxgEIAEoA1IJdW5pcXVlSXBzEiQKDnRvdGFsX2J5dGVzX2luGAUgASgDUgx0b3RhbEJ5dG'
    'VzSW4SJgoPdG90YWxfYnl0ZXNfb3V0GAYgASgDUg10b3RhbEJ5dGVzT3V0EiMKDWJsb2NrZWRf'
    'Y291bnQYByABKANSDGJsb2NrZWRDb3VudA==');

@$core.Deprecated('Use getGeoStatsResponseDescriptor instead')
const GetGeoStatsResponse$json = {
  '1': 'GetGeoStatsResponse',
  '2': [
    {
      '1': 'stats',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.proxy.GeoStatsResult',
      '10': 'stats'
    },
  ],
};

/// Descriptor for `GetGeoStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGeoStatsResponseDescriptor = $convert.base64Decode(
    'ChNHZXRHZW9TdGF0c1Jlc3BvbnNlEjMKBXN0YXRzGAEgAygLMh0ubml0ZWxsYS5wcm94eS5HZW'
    '9TdGF0c1Jlc3VsdFIFc3RhdHM=');

@$core.Deprecated('Use getStatsSummaryRequestDescriptor instead')
const GetStatsSummaryRequest$json = {
  '1': 'GetStatsSummaryRequest',
};

/// Descriptor for `GetStatsSummaryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatsSummaryRequestDescriptor =
    $convert.base64Decode('ChZHZXRTdGF0c1N1bW1hcnlSZXF1ZXN0');

@$core.Deprecated('Use statsSummaryResponseDescriptor instead')
const StatsSummaryResponse$json = {
  '1': 'StatsSummaryResponse',
  '2': [
    {
      '1': 'total_connections',
      '3': 1,
      '4': 1,
      '5': 3,
      '10': 'totalConnections'
    },
    {'1': 'total_bytes_in', '3': 2, '4': 1, '5': 3, '10': 'totalBytesIn'},
    {'1': 'total_bytes_out', '3': 3, '4': 1, '5': 3, '10': 'totalBytesOut'},
    {'1': 'unique_ips', '3': 4, '4': 1, '5': 3, '10': 'uniqueIps'},
    {'1': 'unique_countries', '3': 5, '4': 1, '5': 3, '10': 'uniqueCountries'},
    {'1': 'blocked_total', '3': 6, '4': 1, '5': 3, '10': 'blockedTotal'},
    {'1': 'allowed_total', '3': 7, '4': 1, '5': 3, '10': 'allowedTotal'},
    {
      '1': 'active_connections',
      '3': 8,
      '4': 1,
      '5': 3,
      '10': 'activeConnections'
    },
    {'1': 'proxy_count', '3': 9, '4': 1, '5': 5, '10': 'proxyCount'},
    {
      '1': 'timestamp',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `StatsSummaryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statsSummaryResponseDescriptor = $convert.base64Decode(
    'ChRTdGF0c1N1bW1hcnlSZXNwb25zZRIrChF0b3RhbF9jb25uZWN0aW9ucxgBIAEoA1IQdG90YW'
    'xDb25uZWN0aW9ucxIkCg50b3RhbF9ieXRlc19pbhgCIAEoA1IMdG90YWxCeXRlc0luEiYKD3Rv'
    'dGFsX2J5dGVzX291dBgDIAEoA1INdG90YWxCeXRlc091dBIdCgp1bmlxdWVfaXBzGAQgASgDUg'
    'l1bmlxdWVJcHMSKQoQdW5pcXVlX2NvdW50cmllcxgFIAEoA1IPdW5pcXVlQ291bnRyaWVzEiMK'
    'DWJsb2NrZWRfdG90YWwYBiABKANSDGJsb2NrZWRUb3RhbBIjCg1hbGxvd2VkX3RvdGFsGAcgAS'
    'gDUgxhbGxvd2VkVG90YWwSLQoSYWN0aXZlX2Nvbm5lY3Rpb25zGAggASgDUhFhY3RpdmVDb25u'
    'ZWN0aW9ucxIfCgtwcm94eV9jb3VudBgJIAEoBVIKcHJveHlDb3VudBI4Cgl0aW1lc3RhbXAYCi'
    'ABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use resolveApprovalRequestDescriptor instead')
const ResolveApprovalRequest$json = {
  '1': 'ResolveApprovalRequest',
  '2': [
    {'1': 'req_id', '3': 1, '4': 1, '5': 9, '10': 'reqId'},
    {
      '1': 'action',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.nitella.ApprovalActionType',
      '10': 'action'
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
    {'1': 'reason', '3': 5, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `ResolveApprovalRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolveApprovalRequestDescriptor = $convert.base64Decode(
    'ChZSZXNvbHZlQXBwcm92YWxSZXF1ZXN0EhUKBnJlcV9pZBgBIAEoCVIFcmVxSWQSMwoGYWN0aW'
    '9uGAIgASgOMhsubml0ZWxsYS5BcHByb3ZhbEFjdGlvblR5cGVSBmFjdGlvbhJFCg5yZXRlbnRp'
    'b25fbW9kZRgDIAEoDjIeLm5pdGVsbGEuQXBwcm92YWxSZXRlbnRpb25Nb2RlUg1yZXRlbnRpb2'
    '5Nb2RlEikKEGR1cmF0aW9uX3NlY29uZHMYBCABKANSD2R1cmF0aW9uU2Vjb25kcxIWCgZyZWFz'
    'b24YBSABKAlSBnJlYXNvbg==');

@$core.Deprecated('Use resolveApprovalResponseDescriptor instead')
const ResolveApprovalResponse$json = {
  '1': 'ResolveApprovalResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `ResolveApprovalResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolveApprovalResponseDescriptor =
    $convert.base64Decode(
        'ChdSZXNvbHZlQXBwcm92YWxSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEiMKDW'
        'Vycm9yX21lc3NhZ2UYAiABKAlSDGVycm9yTWVzc2FnZQ==');

@$core.Deprecated('Use activeApprovalDescriptor instead')
const ActiveApproval$json = {
  '1': 'ActiveApproval',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'source_ip', '3': 2, '4': 1, '5': 9, '10': 'sourceIp'},
    {'1': 'rule_id', '3': 3, '4': 1, '5': 9, '10': 'ruleId'},
    {'1': 'proxy_id', '3': 4, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'tls_session_id', '3': 5, '4': 1, '5': 9, '10': 'tlsSessionId'},
    {'1': 'allowed', '3': 6, '4': 1, '5': 8, '10': 'allowed'},
    {
      '1': 'created_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'expires_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiresAt'
    },
    {'1': 'bytes_in', '3': 9, '4': 1, '5': 3, '10': 'bytesIn'},
    {'1': 'bytes_out', '3': 10, '4': 1, '5': 3, '10': 'bytesOut'},
    {'1': 'blocked_count', '3': 11, '4': 1, '5': 3, '10': 'blockedCount'},
    {'1': 'conn_ids', '3': 12, '4': 3, '5': 9, '10': 'connIds'},
    {'1': 'geo_country', '3': 13, '4': 1, '5': 9, '10': 'geoCountry'},
    {'1': 'geo_city', '3': 14, '4': 1, '5': 9, '10': 'geoCity'},
    {'1': 'geo_isp', '3': 15, '4': 1, '5': 9, '10': 'geoIsp'},
  ],
};

/// Descriptor for `ActiveApproval`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activeApprovalDescriptor = $convert.base64Decode(
    'Cg5BY3RpdmVBcHByb3ZhbBIQCgNrZXkYASABKAlSA2tleRIbCglzb3VyY2VfaXAYAiABKAlSCH'
    'NvdXJjZUlwEhcKB3J1bGVfaWQYAyABKAlSBnJ1bGVJZBIZCghwcm94eV9pZBgEIAEoCVIHcHJv'
    'eHlJZBIkCg50bHNfc2Vzc2lvbl9pZBgFIAEoCVIMdGxzU2Vzc2lvbklkEhgKB2FsbG93ZWQYBi'
    'ABKAhSB2FsbG93ZWQSOQoKY3JlYXRlZF9hdBgHIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1l'
    'c3RhbXBSCWNyZWF0ZWRBdBI5CgpleHBpcmVzX2F0GAggASgLMhouZ29vZ2xlLnByb3RvYnVmLl'
    'RpbWVzdGFtcFIJZXhwaXJlc0F0EhkKCGJ5dGVzX2luGAkgASgDUgdieXRlc0luEhsKCWJ5dGVz'
    'X291dBgKIAEoA1IIYnl0ZXNPdXQSIwoNYmxvY2tlZF9jb3VudBgLIAEoA1IMYmxvY2tlZENvdW'
    '50EhkKCGNvbm5faWRzGAwgAygJUgdjb25uSWRzEh8KC2dlb19jb3VudHJ5GA0gASgJUgpnZW9D'
    'b3VudHJ5EhkKCGdlb19jaXR5GA4gASgJUgdnZW9DaXR5EhcKB2dlb19pc3AYDyABKAlSBmdlb0'
    'lzcA==');

@$core.Deprecated('Use listActiveApprovalsRequestDescriptor instead')
const ListActiveApprovalsRequest$json = {
  '1': 'ListActiveApprovalsRequest',
  '2': [
    {'1': 'proxy_id', '3': 1, '4': 1, '5': 9, '10': 'proxyId'},
    {'1': 'source_ip', '3': 2, '4': 1, '5': 9, '10': 'sourceIp'},
  ],
};

/// Descriptor for `ListActiveApprovalsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listActiveApprovalsRequestDescriptor =
    $convert.base64Decode(
        'ChpMaXN0QWN0aXZlQXBwcm92YWxzUmVxdWVzdBIZCghwcm94eV9pZBgBIAEoCVIHcHJveHlJZB'
        'IbCglzb3VyY2VfaXAYAiABKAlSCHNvdXJjZUlw');

@$core.Deprecated('Use listActiveApprovalsResponseDescriptor instead')
const ListActiveApprovalsResponse$json = {
  '1': 'ListActiveApprovalsResponse',
  '2': [
    {
      '1': 'approvals',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.proxy.ActiveApproval',
      '10': 'approvals'
    },
  ],
};

/// Descriptor for `ListActiveApprovalsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listActiveApprovalsResponseDescriptor =
    $convert.base64Decode(
        'ChtMaXN0QWN0aXZlQXBwcm92YWxzUmVzcG9uc2USOwoJYXBwcm92YWxzGAEgAygLMh0ubml0ZW'
        'xsYS5wcm94eS5BY3RpdmVBcHByb3ZhbFIJYXBwcm92YWxz');

@$core.Deprecated('Use cancelApprovalRequestDescriptor instead')
const CancelApprovalRequest$json = {
  '1': 'CancelApprovalRequest',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'close_connections',
      '3': 2,
      '4': 1,
      '5': 8,
      '10': 'closeConnections'
    },
  ],
};

/// Descriptor for `CancelApprovalRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelApprovalRequestDescriptor = $convert.base64Decode(
    'ChVDYW5jZWxBcHByb3ZhbFJlcXVlc3QSEAoDa2V5GAEgASgJUgNrZXkSKwoRY2xvc2VfY29ubm'
    'VjdGlvbnMYAiABKAhSEGNsb3NlQ29ubmVjdGlvbnM=');

@$core.Deprecated('Use cancelApprovalResponseDescriptor instead')
const CancelApprovalResponse$json = {
  '1': 'CancelApprovalResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'error_message', '3': 2, '4': 1, '5': 9, '10': 'errorMessage'},
    {
      '1': 'connections_closed',
      '3': 3,
      '4': 1,
      '5': 5,
      '10': 'connectionsClosed'
    },
  ],
};

/// Descriptor for `CancelApprovalResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelApprovalResponseDescriptor = $convert.base64Decode(
    'ChZDYW5jZWxBcHByb3ZhbFJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSIwoNZX'
    'Jyb3JfbWVzc2FnZRgCIAEoCVIMZXJyb3JNZXNzYWdlEi0KEmNvbm5lY3Rpb25zX2Nsb3NlZBgD'
    'IAEoBVIRY29ubmVjdGlvbnNDbG9zZWQ=');

@$core.Deprecated('Use sendCommandRequestDescriptor instead')
const SendCommandRequest$json = {
  '1': 'SendCommandRequest',
  '2': [
    {
      '1': 'encrypted',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.nitella.EncryptedPayload',
      '10': 'encrypted'
    },
    {'1': 'viewer_pubkey', '3': 2, '4': 1, '5': 12, '10': 'viewerPubkey'},
  ],
};

/// Descriptor for `SendCommandRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendCommandRequestDescriptor = $convert.base64Decode(
    'ChJTZW5kQ29tbWFuZFJlcXVlc3QSNwoJZW5jcnlwdGVkGAEgASgLMhkubml0ZWxsYS5FbmNyeX'
    'B0ZWRQYXlsb2FkUgllbmNyeXB0ZWQSIwoNdmlld2VyX3B1YmtleRgCIAEoDFIMdmlld2VyUHVi'
    'a2V5');

@$core.Deprecated('Use sendCommandResponseDescriptor instead')
const SendCommandResponse$json = {
  '1': 'SendCommandResponse',
  '2': [
    {
      '1': 'encrypted',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.nitella.EncryptedPayload',
      '10': 'encrypted'
    },
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {'1': 'error_message', '3': 3, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `SendCommandResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendCommandResponseDescriptor = $convert.base64Decode(
    'ChNTZW5kQ29tbWFuZFJlc3BvbnNlEjcKCWVuY3J5cHRlZBgBIAEoCzIZLm5pdGVsbGEuRW5jcn'
    'lwdGVkUGF5bG9hZFIJZW5jcnlwdGVkEhYKBnN0YXR1cxgCIAEoCVIGc3RhdHVzEiMKDWVycm9y'
    'X21lc3NhZ2UYAyABKAlSDGVycm9yTWVzc2FnZQ==');
