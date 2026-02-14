// This is a generated file - do not edit.
//
// Generated from geoip/geoip.proto.

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

@$core.Deprecated('Use cacheLayerDescriptor instead')
const CacheLayer$json = {
  '1': 'CacheLayer',
  '2': [
    {'1': 'CACHE_LAYER_ALL', '2': 0},
    {'1': 'CACHE_LAYER_L1', '2': 1},
    {'1': 'CACHE_LAYER_L2', '2': 2},
  ],
};

/// Descriptor for `CacheLayer`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List cacheLayerDescriptor = $convert.base64Decode(
    'CgpDYWNoZUxheWVyEhMKD0NBQ0hFX0xBWUVSX0FMTBAAEhIKDkNBQ0hFX0xBWUVSX0wxEAESEg'
    'oOQ0FDSEVfTEFZRVJfTDIQAg==');

@$core.Deprecated('Use lookupRequestDescriptor instead')
const LookupRequest$json = {
  '1': 'LookupRequest',
  '2': [
    {'1': 'ip', '3': 1, '4': 1, '5': 9, '10': 'ip'},
  ],
};

/// Descriptor for `LookupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lookupRequestDescriptor =
    $convert.base64Decode('Cg1Mb29rdXBSZXF1ZXN0Eg4KAmlwGAEgASgJUgJpcA==');

@$core.Deprecated('Use serviceStatusDescriptor instead')
const ServiceStatus$json = {
  '1': 'ServiceStatus',
  '2': [
    {'1': 'ready', '3': 1, '4': 1, '5': 8, '10': 'ready'},
    {'1': 'l1_cache_size', '3': 2, '4': 1, '5': 3, '10': 'l1CacheSize'},
    {'1': 'l2_cache_size', '3': 3, '4': 1, '5': 3, '10': 'l2CacheSize'},
    {'1': 'active_providers', '3': 4, '4': 3, '5': 9, '10': 'activeProviders'},
    {'1': 'strategy', '3': 5, '4': 1, '5': 9, '10': 'strategy'},
    {'1': 'local_db_loaded', '3': 6, '4': 1, '5': 8, '10': 'localDbLoaded'},
    {'1': 'l2_ttl_hours', '3': 7, '4': 1, '5': 5, '10': 'l2TtlHours'},
  ],
};

/// Descriptor for `ServiceStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serviceStatusDescriptor = $convert.base64Decode(
    'Cg1TZXJ2aWNlU3RhdHVzEhQKBXJlYWR5GAEgASgIUgVyZWFkeRIiCg1sMV9jYWNoZV9zaXplGA'
    'IgASgDUgtsMUNhY2hlU2l6ZRIiCg1sMl9jYWNoZV9zaXplGAMgASgDUgtsMkNhY2hlU2l6ZRIp'
    'ChBhY3RpdmVfcHJvdmlkZXJzGAQgAygJUg9hY3RpdmVQcm92aWRlcnMSGgoIc3RyYXRlZ3kYBS'
    'ABKAlSCHN0cmF0ZWd5EiYKD2xvY2FsX2RiX2xvYWRlZBgGIAEoCFINbG9jYWxEYkxvYWRlZBIg'
    'CgxsMl90dGxfaG91cnMYByABKAVSCmwyVHRsSG91cnM=');

@$core.Deprecated('Use loadLocalDBRequestDescriptor instead')
const LoadLocalDBRequest$json = {
  '1': 'LoadLocalDBRequest',
  '2': [
    {'1': 'city_db_path', '3': 1, '4': 1, '5': 9, '10': 'cityDbPath'},
    {'1': 'isp_db_path', '3': 2, '4': 1, '5': 9, '10': 'ispDbPath'},
  ],
};

/// Descriptor for `LoadLocalDBRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loadLocalDBRequestDescriptor = $convert.base64Decode(
    'ChJMb2FkTG9jYWxEQlJlcXVlc3QSIAoMY2l0eV9kYl9wYXRoGAEgASgJUgpjaXR5RGJQYXRoEh'
    '4KC2lzcF9kYl9wYXRoGAIgASgJUglpc3BEYlBhdGg=');

@$core.Deprecated('Use localDBStatusDescriptor instead')
const LocalDBStatus$json = {
  '1': 'LocalDBStatus',
  '2': [
    {'1': 'loaded', '3': 1, '4': 1, '5': 8, '10': 'loaded'},
    {'1': 'city_db_path', '3': 2, '4': 1, '5': 9, '10': 'cityDbPath'},
    {'1': 'isp_db_path', '3': 3, '4': 1, '5': 9, '10': 'ispDbPath'},
    {'1': 'city_db_size', '3': 4, '4': 1, '5': 3, '10': 'cityDbSize'},
    {'1': 'isp_db_size', '3': 5, '4': 1, '5': 3, '10': 'ispDbSize'},
  ],
};

/// Descriptor for `LocalDBStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List localDBStatusDescriptor = $convert.base64Decode(
    'Cg1Mb2NhbERCU3RhdHVzEhYKBmxvYWRlZBgBIAEoCFIGbG9hZGVkEiAKDGNpdHlfZGJfcGF0aB'
    'gCIAEoCVIKY2l0eURiUGF0aBIeCgtpc3BfZGJfcGF0aBgDIAEoCVIJaXNwRGJQYXRoEiAKDGNp'
    'dHlfZGJfc2l6ZRgEIAEoA1IKY2l0eURiU2l6ZRIeCgtpc3BfZGJfc2l6ZRgFIAEoA1IJaXNwRG'
    'JTaXpl');

@$core.Deprecated('Use providerNameRequestDescriptor instead')
const ProviderNameRequest$json = {
  '1': 'ProviderNameRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `ProviderNameRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List providerNameRequestDescriptor = $convert
    .base64Decode('ChNQcm92aWRlck5hbWVSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWU=');

@$core.Deprecated('Use listProvidersResponseDescriptor instead')
const ListProvidersResponse$json = {
  '1': 'ListProvidersResponse',
  '2': [
    {
      '1': 'providers',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.geoip.ProviderInfo',
      '10': 'providers'
    },
  ],
};

/// Descriptor for `ListProvidersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProvidersResponseDescriptor = $convert.base64Decode(
    'ChVMaXN0UHJvdmlkZXJzUmVzcG9uc2USOQoJcHJvdmlkZXJzGAEgAygLMhsubml0ZWxsYS5nZW'
    '9pcC5Qcm92aWRlckluZm9SCXByb3ZpZGVycw==');

@$core.Deprecated('Use providerInfoDescriptor instead')
const ProviderInfo$json = {
  '1': 'ProviderInfo',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
    {'1': 'enabled', '3': 3, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'priority', '3': 4, '4': 1, '5': 5, '10': 'priority'},
    {
      '1': 'field_mapping',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.nitella.geoip.FieldMapping',
      '10': 'fieldMapping'
    },
    {
      '1': 'stats',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.nitella.geoip.ProviderStats',
      '10': 'stats'
    },
  ],
};

/// Descriptor for `ProviderInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List providerInfoDescriptor = $convert.base64Decode(
    'CgxQcm92aWRlckluZm8SEgoEbmFtZRgBIAEoCVIEbmFtZRIQCgN1cmwYAiABKAlSA3VybBIYCg'
    'dlbmFibGVkGAMgASgIUgdlbmFibGVkEhoKCHByaW9yaXR5GAQgASgFUghwcmlvcml0eRJACg1m'
    'aWVsZF9tYXBwaW5nGAUgASgLMhsubml0ZWxsYS5nZW9pcC5GaWVsZE1hcHBpbmdSDGZpZWxkTW'
    'FwcGluZxIyCgVzdGF0cxgGIAEoCzIcLm5pdGVsbGEuZ2VvaXAuUHJvdmlkZXJTdGF0c1IFc3Rh'
    'dHM=');

@$core.Deprecated('Use addProviderRequestDescriptor instead')
const AddProviderRequest$json = {
  '1': 'AddProviderRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
    {'1': 'priority', '3': 3, '4': 1, '5': 5, '10': 'priority'},
    {
      '1': 'field_mapping',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.nitella.geoip.FieldMapping',
      '10': 'fieldMapping'
    },
  ],
};

/// Descriptor for `AddProviderRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addProviderRequestDescriptor = $convert.base64Decode(
    'ChJBZGRQcm92aWRlclJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIQCgN1cmwYAiABKAlSA3'
    'VybBIaCghwcmlvcml0eRgDIAEoBVIIcHJpb3JpdHkSQAoNZmllbGRfbWFwcGluZxgEIAEoCzIb'
    'Lm5pdGVsbGEuZ2VvaXAuRmllbGRNYXBwaW5nUgxmaWVsZE1hcHBpbmc=');

@$core.Deprecated('Use removeProviderRequestDescriptor instead')
const RemoveProviderRequest$json = {
  '1': 'RemoveProviderRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `RemoveProviderRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeProviderRequestDescriptor =
    $convert.base64Decode(
        'ChVSZW1vdmVQcm92aWRlclJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZQ==');

@$core.Deprecated('Use updateProviderRequestDescriptor instead')
const UpdateProviderRequest$json = {
  '1': 'UpdateProviderRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
    {'1': 'priority', '3': 3, '4': 1, '5': 5, '10': 'priority'},
    {
      '1': 'field_mapping',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.nitella.geoip.FieldMapping',
      '10': 'fieldMapping'
    },
    {'1': 'enabled', '3': 5, '4': 1, '5': 8, '10': 'enabled'},
  ],
};

/// Descriptor for `UpdateProviderRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProviderRequestDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVQcm92aWRlclJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIQCgN1cmwYAiABKA'
    'lSA3VybBIaCghwcmlvcml0eRgDIAEoBVIIcHJpb3JpdHkSQAoNZmllbGRfbWFwcGluZxgEIAEo'
    'CzIbLm5pdGVsbGEuZ2VvaXAuRmllbGRNYXBwaW5nUgxmaWVsZE1hcHBpbmcSGAoHZW5hYmxlZB'
    'gFIAEoCFIHZW5hYmxlZA==');

@$core.Deprecated('Use reorderProvidersRequestDescriptor instead')
const ReorderProvidersRequest$json = {
  '1': 'ReorderProvidersRequest',
  '2': [
    {'1': 'provider_names', '3': 1, '4': 3, '5': 9, '10': 'providerNames'},
  ],
};

/// Descriptor for `ReorderProvidersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reorderProvidersRequestDescriptor =
    $convert.base64Decode(
        'ChdSZW9yZGVyUHJvdmlkZXJzUmVxdWVzdBIlCg5wcm92aWRlcl9uYW1lcxgBIAMoCVINcHJvdm'
        'lkZXJOYW1lcw==');

@$core.Deprecated('Use providerStatsDescriptor instead')
const ProviderStats$json = {
  '1': 'ProviderStats',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'lookup_count', '3': 2, '4': 1, '5': 3, '10': 'lookupCount'},
    {'1': 'success_count', '3': 3, '4': 1, '5': 3, '10': 'successCount'},
    {'1': 'error_count', '3': 4, '4': 1, '5': 3, '10': 'errorCount'},
    {'1': 'total_latency_ms', '3': 5, '4': 1, '5': 3, '10': 'totalLatencyMs'},
    {'1': 'avg_latency_ms', '3': 6, '4': 1, '5': 3, '10': 'avgLatencyMs'},
    {'1': 'last_used_unix', '3': 7, '4': 1, '5': 3, '10': 'lastUsedUnix'},
    {'1': 'last_error', '3': 8, '4': 1, '5': 9, '10': 'lastError'},
  ],
};

/// Descriptor for `ProviderStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List providerStatsDescriptor = $convert.base64Decode(
    'Cg1Qcm92aWRlclN0YXRzEhIKBG5hbWUYASABKAlSBG5hbWUSIQoMbG9va3VwX2NvdW50GAIgAS'
    'gDUgtsb29rdXBDb3VudBIjCg1zdWNjZXNzX2NvdW50GAMgASgDUgxzdWNjZXNzQ291bnQSHwoL'
    'ZXJyb3JfY291bnQYBCABKANSCmVycm9yQ291bnQSKAoQdG90YWxfbGF0ZW5jeV9tcxgFIAEoA1'
    'IOdG90YWxMYXRlbmN5TXMSJAoOYXZnX2xhdGVuY3lfbXMYBiABKANSDGF2Z0xhdGVuY3lNcxIk'
    'Cg5sYXN0X3VzZWRfdW5peBgHIAEoA1IMbGFzdFVzZWRVbml4Eh0KCmxhc3RfZXJyb3IYCCABKA'
    'lSCWxhc3RFcnJvcg==');

@$core.Deprecated('Use fieldMappingDescriptor instead')
const FieldMapping$json = {
  '1': 'FieldMapping',
  '2': [
    {'1': 'country', '3': 1, '4': 3, '5': 9, '10': 'country'},
    {'1': 'country_code', '3': 2, '4': 3, '5': 9, '10': 'countryCode'},
    {'1': 'region', '3': 3, '4': 3, '5': 9, '10': 'region'},
    {'1': 'region_name', '3': 4, '4': 3, '5': 9, '10': 'regionName'},
    {'1': 'city', '3': 5, '4': 3, '5': 9, '10': 'city'},
    {'1': 'zip', '3': 6, '4': 3, '5': 9, '10': 'zip'},
    {'1': 'timezone', '3': 7, '4': 3, '5': 9, '10': 'timezone'},
    {'1': 'latitude', '3': 8, '4': 3, '5': 9, '10': 'latitude'},
    {'1': 'longitude', '3': 9, '4': 3, '5': 9, '10': 'longitude'},
    {'1': 'isp', '3': 10, '4': 3, '5': 9, '10': 'isp'},
    {'1': 'org', '3': 11, '4': 3, '5': 9, '10': 'org'},
    {'1': 'as', '3': 12, '4': 3, '5': 9, '10': 'as'},
  ],
};

/// Descriptor for `FieldMapping`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldMappingDescriptor = $convert.base64Decode(
    'CgxGaWVsZE1hcHBpbmcSGAoHY291bnRyeRgBIAMoCVIHY291bnRyeRIhCgxjb3VudHJ5X2NvZG'
    'UYAiADKAlSC2NvdW50cnlDb2RlEhYKBnJlZ2lvbhgDIAMoCVIGcmVnaW9uEh8KC3JlZ2lvbl9u'
    'YW1lGAQgAygJUgpyZWdpb25OYW1lEhIKBGNpdHkYBSADKAlSBGNpdHkSEAoDemlwGAYgAygJUg'
    'N6aXASGgoIdGltZXpvbmUYByADKAlSCHRpbWV6b25lEhoKCGxhdGl0dWRlGAggAygJUghsYXRp'
    'dHVkZRIcCglsb25naXR1ZGUYCSADKAlSCWxvbmdpdHVkZRIQCgNpc3AYCiADKAlSA2lzcBIQCg'
    'NvcmcYCyADKAlSA29yZxIOCgJhcxgMIAMoCVICYXM=');

@$core.Deprecated('Use cacheStatsDescriptor instead')
const CacheStats$json = {
  '1': 'CacheStats',
  '2': [
    {'1': 'l1_size', '3': 1, '4': 1, '5': 3, '10': 'l1Size'},
    {'1': 'l1_capacity', '3': 2, '4': 1, '5': 3, '10': 'l1Capacity'},
    {'1': 'l1_hits', '3': 3, '4': 1, '5': 3, '10': 'l1Hits'},
    {'1': 'l1_misses', '3': 4, '4': 1, '5': 3, '10': 'l1Misses'},
    {'1': 'l2_size', '3': 5, '4': 1, '5': 3, '10': 'l2Size'},
    {'1': 'l2_enabled', '3': 6, '4': 1, '5': 8, '10': 'l2Enabled'},
    {'1': 'l2_path', '3': 7, '4': 1, '5': 9, '10': 'l2Path'},
    {'1': 'l2_hits', '3': 8, '4': 1, '5': 3, '10': 'l2Hits'},
    {'1': 'l2_misses', '3': 9, '4': 1, '5': 3, '10': 'l2Misses'},
    {'1': 'l2_ttl_hours', '3': 10, '4': 1, '5': 5, '10': 'l2TtlHours'},
  ],
};

/// Descriptor for `CacheStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cacheStatsDescriptor = $convert.base64Decode(
    'CgpDYWNoZVN0YXRzEhcKB2wxX3NpemUYASABKANSBmwxU2l6ZRIfCgtsMV9jYXBhY2l0eRgCIA'
    'EoA1IKbDFDYXBhY2l0eRIXCgdsMV9oaXRzGAMgASgDUgZsMUhpdHMSGwoJbDFfbWlzc2VzGAQg'
    'ASgDUghsMU1pc3NlcxIXCgdsMl9zaXplGAUgASgDUgZsMlNpemUSHQoKbDJfZW5hYmxlZBgGIA'
    'EoCFIJbDJFbmFibGVkEhcKB2wyX3BhdGgYByABKAlSBmwyUGF0aBIXCgdsMl9oaXRzGAggASgD'
    'UgZsMkhpdHMSGwoJbDJfbWlzc2VzGAkgASgDUghsMk1pc3NlcxIgCgxsMl90dGxfaG91cnMYCi'
    'ABKAVSCmwyVHRsSG91cnM=');

@$core.Deprecated('Use clearCacheRequestDescriptor instead')
const ClearCacheRequest$json = {
  '1': 'ClearCacheRequest',
  '2': [
    {
      '1': 'layer',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.nitella.geoip.CacheLayer',
      '10': 'layer'
    },
  ],
};

/// Descriptor for `ClearCacheRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clearCacheRequestDescriptor = $convert.base64Decode(
    'ChFDbGVhckNhY2hlUmVxdWVzdBIvCgVsYXllchgBIAEoDjIZLm5pdGVsbGEuZ2VvaXAuQ2FjaG'
    'VMYXllclIFbGF5ZXI=');

@$core.Deprecated('Use cacheSettingsDescriptor instead')
const CacheSettings$json = {
  '1': 'CacheSettings',
  '2': [
    {'1': 'l1_capacity', '3': 1, '4': 1, '5': 5, '10': 'l1Capacity'},
    {'1': 'l1_ttl_hours', '3': 2, '4': 1, '5': 5, '10': 'l1TtlHours'},
    {'1': 'l2_enabled', '3': 3, '4': 1, '5': 8, '10': 'l2Enabled'},
    {'1': 'l2_path', '3': 4, '4': 1, '5': 9, '10': 'l2Path'},
    {'1': 'l2_ttl_hours', '3': 5, '4': 1, '5': 5, '10': 'l2TtlHours'},
  ],
};

/// Descriptor for `CacheSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cacheSettingsDescriptor = $convert.base64Decode(
    'Cg1DYWNoZVNldHRpbmdzEh8KC2wxX2NhcGFjaXR5GAEgASgFUgpsMUNhcGFjaXR5EiAKDGwxX3'
    'R0bF9ob3VycxgCIAEoBVIKbDFUdGxIb3VycxIdCgpsMl9lbmFibGVkGAMgASgIUglsMkVuYWJs'
    'ZWQSFwoHbDJfcGF0aBgEIAEoCVIGbDJQYXRoEiAKDGwyX3R0bF9ob3VycxgFIAEoBVIKbDJUdG'
    'xIb3Vycw==');

@$core.Deprecated('Use updateCacheSettingsRequestDescriptor instead')
const UpdateCacheSettingsRequest$json = {
  '1': 'UpdateCacheSettingsRequest',
  '2': [
    {'1': 'l1_capacity', '3': 1, '4': 1, '5': 5, '10': 'l1Capacity'},
    {'1': 'l1_ttl_hours', '3': 2, '4': 1, '5': 5, '10': 'l1TtlHours'},
    {'1': 'l2_enabled', '3': 3, '4': 1, '5': 8, '10': 'l2Enabled'},
    {'1': 'l2_path', '3': 4, '4': 1, '5': 9, '10': 'l2Path'},
    {'1': 'l2_ttl_hours', '3': 5, '4': 1, '5': 5, '10': 'l2TtlHours'},
  ],
};

/// Descriptor for `UpdateCacheSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateCacheSettingsRequestDescriptor = $convert.base64Decode(
    'ChpVcGRhdGVDYWNoZVNldHRpbmdzUmVxdWVzdBIfCgtsMV9jYXBhY2l0eRgBIAEoBVIKbDFDYX'
    'BhY2l0eRIgCgxsMV90dGxfaG91cnMYAiABKAVSCmwxVHRsSG91cnMSHQoKbDJfZW5hYmxlZBgD'
    'IAEoCFIJbDJFbmFibGVkEhcKB2wyX3BhdGgYBCABKAlSBmwyUGF0aBIgCgxsMl90dGxfaG91cn'
    'MYBSABKAVSCmwyVHRsSG91cnM=');

@$core.Deprecated('Use strategyResponseDescriptor instead')
const StrategyResponse$json = {
  '1': 'StrategyResponse',
  '2': [
    {'1': 'steps', '3': 1, '4': 3, '5': 9, '10': 'steps'},
    {'1': 'timeout_ms', '3': 2, '4': 1, '5': 5, '10': 'timeoutMs'},
  ],
};

/// Descriptor for `StrategyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List strategyResponseDescriptor = $convert.base64Decode(
    'ChBTdHJhdGVneVJlc3BvbnNlEhQKBXN0ZXBzGAEgAygJUgVzdGVwcxIdCgp0aW1lb3V0X21zGA'
    'IgASgFUgl0aW1lb3V0TXM=');

@$core.Deprecated('Use setStrategyRequestDescriptor instead')
const SetStrategyRequest$json = {
  '1': 'SetStrategyRequest',
  '2': [
    {'1': 'steps', '3': 1, '4': 3, '5': 9, '10': 'steps'},
    {'1': 'timeout_ms', '3': 2, '4': 1, '5': 5, '10': 'timeoutMs'},
  ],
};

/// Descriptor for `SetStrategyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setStrategyRequestDescriptor = $convert.base64Decode(
    'ChJTZXRTdHJhdGVneVJlcXVlc3QSFAoFc3RlcHMYASADKAlSBXN0ZXBzEh0KCnRpbWVvdXRfbX'
    'MYAiABKAVSCXRpbWVvdXRNcw==');
