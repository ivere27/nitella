// This is a generated file - do not edit.
//
// Generated from hub/hub_admin.proto.

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

@$core.Deprecated('Use getSystemStatsRequestDescriptor instead')
const GetSystemStatsRequest$json = {
  '1': 'GetSystemStatsRequest',
};

/// Descriptor for `GetSystemStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSystemStatsRequestDescriptor =
    $convert.base64Decode('ChVHZXRTeXN0ZW1TdGF0c1JlcXVlc3Q=');

@$core.Deprecated('Use systemStatsDescriptor instead')
const SystemStats$json = {
  '1': 'SystemStats',
  '2': [
    {'1': 'total_users', '3': 1, '4': 1, '5': 5, '10': 'totalUsers'},
    {'1': 'total_nodes', '3': 2, '4': 1, '5': 5, '10': 'totalNodes'},
    {'1': 'online_nodes', '3': 3, '4': 1, '5': 5, '10': 'onlineNodes'},
    {
      '1': 'total_connections_today',
      '3': 4,
      '4': 1,
      '5': 3,
      '10': 'totalConnectionsToday'
    },
    {'1': 'total_bytes_today', '3': 5, '4': 1, '5': 3, '10': 'totalBytesToday'},
    {
      '1': 'blocked_requests_today',
      '3': 6,
      '4': 1,
      '5': 3,
      '10': 'blockedRequestsToday'
    },
    {
      '1': 'users_by_tier',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.SystemStats.UsersByTierEntry',
      '10': 'usersByTier'
    },
  ],
  '3': [SystemStats_UsersByTierEntry$json],
};

@$core.Deprecated('Use systemStatsDescriptor instead')
const SystemStats_UsersByTierEntry$json = {
  '1': 'UsersByTierEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `SystemStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemStatsDescriptor = $convert.base64Decode(
    'CgtTeXN0ZW1TdGF0cxIfCgt0b3RhbF91c2VycxgBIAEoBVIKdG90YWxVc2VycxIfCgt0b3RhbF'
    '9ub2RlcxgCIAEoBVIKdG90YWxOb2RlcxIhCgxvbmxpbmVfbm9kZXMYAyABKAVSC29ubGluZU5v'
    'ZGVzEjYKF3RvdGFsX2Nvbm5lY3Rpb25zX3RvZGF5GAQgASgDUhV0b3RhbENvbm5lY3Rpb25zVG'
    '9kYXkSKgoRdG90YWxfYnl0ZXNfdG9kYXkYBSABKANSD3RvdGFsQnl0ZXNUb2RheRI0ChZibG9j'
    'a2VkX3JlcXVlc3RzX3RvZGF5GAYgASgDUhRibG9ja2VkUmVxdWVzdHNUb2RheRJOCg11c2Vyc1'
    '9ieV90aWVyGAcgAygLMiouZG9yeXdhbGwuaHViLlN5c3RlbVN0YXRzLlVzZXJzQnlUaWVyRW50'
    'cnlSC3VzZXJzQnlUaWVyGj4KEFVzZXJzQnlUaWVyRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFA'
    'oFdmFsdWUYAiABKAVSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use getAuditLogRequestDescriptor instead')
const GetAuditLogRequest$json = {
  '1': 'GetAuditLogRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'filter_user_id', '3': 3, '4': 1, '5': 9, '10': 'filterUserId'},
    {'1': 'filter_action', '3': 4, '4': 1, '5': 9, '10': 'filterAction'},
    {
      '1': 'start_time',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startTime'
    },
    {
      '1': 'end_time',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'endTime'
    },
  ],
};

/// Descriptor for `GetAuditLogRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAuditLogRequestDescriptor = $convert.base64Decode(
    'ChJHZXRBdWRpdExvZ1JlcXVlc3QSGwoJcGFnZV9zaXplGAEgASgFUghwYWdlU2l6ZRIdCgpwYW'
    'dlX3Rva2VuGAIgASgJUglwYWdlVG9rZW4SJAoOZmlsdGVyX3VzZXJfaWQYAyABKAlSDGZpbHRl'
    'clVzZXJJZBIjCg1maWx0ZXJfYWN0aW9uGAQgASgJUgxmaWx0ZXJBY3Rpb24SOQoKc3RhcnRfdG'
    'ltZRgFIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXN0YXJ0VGltZRI1CghlbmRf'
    'dGltZRgGIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSB2VuZFRpbWU=');

@$core.Deprecated('Use getAuditLogResponseDescriptor instead')
const GetAuditLogResponse$json = {
  '1': 'GetAuditLogResponse',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.AuditEntry',
      '10': 'entries'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
  ],
};

/// Descriptor for `GetAuditLogResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAuditLogResponseDescriptor = $convert.base64Decode(
    'ChNHZXRBdWRpdExvZ1Jlc3BvbnNlEjIKB2VudHJpZXMYASADKAsyGC5kb3J5d2FsbC5odWIuQX'
    'VkaXRFbnRyeVIHZW50cmllcxImCg9uZXh0X3BhZ2VfdG9rZW4YAiABKAlSDW5leHRQYWdlVG9r'
    'ZW4=');

@$core.Deprecated('Use auditEntryDescriptor instead')
const AuditEntry$json = {
  '1': 'AuditEntry',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'action', '3': 4, '4': 1, '5': 9, '10': 'action'},
    {'1': 'target_type', '3': 5, '4': 1, '5': 9, '10': 'targetType'},
    {'1': 'target_id', '3': 6, '4': 1, '5': 9, '10': 'targetId'},
    {'1': 'ip_address', '3': 7, '4': 1, '5': 9, '10': 'ipAddress'},
    {'1': 'details', '3': 8, '4': 1, '5': 9, '10': 'details'},
  ],
};

/// Descriptor for `AuditEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List auditEntryDescriptor = $convert.base64Decode(
    'CgpBdWRpdEVudHJ5Eg4KAmlkGAEgASgJUgJpZBI4Cgl0aW1lc3RhbXAYAiABKAsyGi5nb29nbG'
    'UucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXASFwoHdXNlcl9pZBgDIAEoCVIGdXNlcklk'
    'EhYKBmFjdGlvbhgEIAEoCVIGYWN0aW9uEh8KC3RhcmdldF90eXBlGAUgASgJUgp0YXJnZXRUeX'
    'BlEhsKCXRhcmdldF9pZBgGIAEoCVIIdGFyZ2V0SWQSHQoKaXBfYWRkcmVzcxgHIAEoCVIJaXBB'
    'ZGRyZXNzEhgKB2RldGFpbHMYCCABKAlSB2RldGFpbHM=');

@$core.Deprecated('Use listAllUsersRequestDescriptor instead')
const ListAllUsersRequest$json = {
  '1': 'ListAllUsersRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'filter_tier', '3': 3, '4': 1, '5': 9, '10': 'filterTier'},
    {'1': 'filter_status', '3': 4, '4': 1, '5': 9, '10': 'filterStatus'},
  ],
};

/// Descriptor for `ListAllUsersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAllUsersRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0QWxsVXNlcnNSZXF1ZXN0EhsKCXBhZ2Vfc2l6ZRgBIAEoBVIIcGFnZVNpemUSHQoKcG'
    'FnZV90b2tlbhgCIAEoCVIJcGFnZVRva2VuEh8KC2ZpbHRlcl90aWVyGAMgASgJUgpmaWx0ZXJU'
    'aWVyEiMKDWZpbHRlcl9zdGF0dXMYBCABKAlSDGZpbHRlclN0YXR1cw==');

@$core.Deprecated('Use listAllUsersResponseDescriptor instead')
const ListAllUsersResponse$json = {
  '1': 'ListAllUsersResponse',
  '2': [
    {
      '1': 'users',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.User',
      '10': 'users'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListAllUsersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAllUsersResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0QWxsVXNlcnNSZXNwb25zZRIoCgV1c2VycxgBIAMoCzISLmRvcnl3YWxsLmh1Yi5Vc2'
    'VyUgV1c2VycxImCg9uZXh0X3BhZ2VfdG9rZW4YAiABKAlSDW5leHRQYWdlVG9rZW4SHwoLdG90'
    'YWxfY291bnQYAyABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use getUserDetailsRequestDescriptor instead')
const GetUserDetailsRequest$json = {
  '1': 'GetUserDetailsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `GetUserDetailsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUserDetailsRequestDescriptor =
    $convert.base64Decode(
        'ChVHZXRVc2VyRGV0YWlsc1JlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklk');

@$core.Deprecated('Use userDetailsDescriptor instead')
const UserDetails$json = {
  '1': 'UserDetails',
  '2': [
    {
      '1': 'user',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.nitella.hub.User',
      '10': 'user'
    },
    {'1': 'node_count', '3': 2, '4': 1, '5': 5, '10': 'nodeCount'},
    {'1': 'total_bytes_month', '3': 3, '4': 1, '5': 3, '10': 'totalBytesMonth'},
    {
      '1': 'registration_date',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'registrationDate'
    },
    {
      '1': 'nodes',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.Node',
      '10': 'nodes'
    },
  ],
};

/// Descriptor for `UserDetails`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDetailsDescriptor = $convert.base64Decode(
    'CgtVc2VyRGV0YWlscxImCgR1c2VyGAEgASgLMhIuZG9yeXdhbGwuaHViLlVzZXJSBHVzZXISHQ'
    'oKbm9kZV9jb3VudBgCIAEoBVIJbm9kZUNvdW50EioKEXRvdGFsX2J5dGVzX21vbnRoGAMgASgD'
    'Ug90b3RhbEJ5dGVzTW9udGgSRwoRcmVnaXN0cmF0aW9uX2RhdGUYBCABKAsyGi5nb29nbGUucH'
    'JvdG9idWYuVGltZXN0YW1wUhByZWdpc3RyYXRpb25EYXRlEigKBW5vZGVzGAUgAygLMhIuZG9y'
    'eXdhbGwuaHViLk5vZGVSBW5vZGVz');

@$core.Deprecated('Use setUserTierRequestDescriptor instead')
const SetUserTierRequest$json = {
  '1': 'SetUserTierRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'tier', '3': 2, '4': 1, '5': 9, '10': 'tier'},
    {'1': 'max_nodes', '3': 3, '4': 1, '5': 5, '10': 'maxNodes'},
    {
      '1': 'expires_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiresAt'
    },
  ],
};

/// Descriptor for `SetUserTierRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setUserTierRequestDescriptor = $convert.base64Decode(
    'ChJTZXRVc2VyVGllclJlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhIKBHRpZXIYAi'
    'ABKAlSBHRpZXISGwoJbWF4X25vZGVzGAMgASgFUghtYXhOb2RlcxI5CgpleHBpcmVzX2F0GAQg'
    'ASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJZXhwaXJlc0F0');

@$core.Deprecated('Use banUserRequestDescriptor instead')
const BanUserRequest$json = {
  '1': 'BanUserRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `BanUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List banUserRequestDescriptor = $convert.base64Decode(
    'Cg5CYW5Vc2VyUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSFgoGcmVhc29uGAIgAS'
    'gJUgZyZWFzb24=');

@$core.Deprecated('Use unbanUserRequestDescriptor instead')
const UnbanUserRequest$json = {
  '1': 'UnbanUserRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `UnbanUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unbanUserRequestDescriptor = $convert.base64Decode(
    'ChBVbmJhblVzZXJSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZA==');

@$core.Deprecated('Use listAllNodesRequestDescriptor instead')
const ListAllNodesRequest$json = {
  '1': 'ListAllNodesRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'filter_status', '3': 3, '4': 1, '5': 9, '10': 'filterStatus'},
    {'1': 'filter_owner_id', '3': 4, '4': 1, '5': 9, '10': 'filterOwnerId'},
  ],
};

/// Descriptor for `ListAllNodesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAllNodesRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0QWxsTm9kZXNSZXF1ZXN0EhsKCXBhZ2Vfc2l6ZRgBIAEoBVIIcGFnZVNpemUSHQoKcG'
    'FnZV90b2tlbhgCIAEoCVIJcGFnZVRva2VuEiMKDWZpbHRlcl9zdGF0dXMYAyABKAlSDGZpbHRl'
    'clN0YXR1cxImCg9maWx0ZXJfb3duZXJfaWQYBCABKAlSDWZpbHRlck93bmVySWQ=');

@$core.Deprecated('Use listAllNodesResponseDescriptor instead')
const ListAllNodesResponse$json = {
  '1': 'ListAllNodesResponse',
  '2': [
    {
      '1': 'nodes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.Node',
      '10': 'nodes'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListAllNodesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAllNodesResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0QWxsTm9kZXNSZXNwb25zZRIoCgVub2RlcxgBIAMoCzISLmRvcnl3YWxsLmh1Yi5Ob2'
    'RlUgVub2RlcxImCg9uZXh0X3BhZ2VfdG9rZW4YAiABKAlSDW5leHRQYWdlVG9rZW4SHwoLdG90'
    'YWxfY291bnQYAyABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use forceDisconnectNodeRequestDescriptor instead')
const ForceDisconnectNodeRequest$json = {
  '1': 'ForceDisconnectNodeRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `ForceDisconnectNodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forceDisconnectNodeRequestDescriptor =
    $convert.base64Decode(
        'ChpGb3JjZURpc2Nvbm5lY3ROb2RlUmVxdWVzdBIXCgdub2RlX2lkGAEgASgJUgZub2RlSWQSFg'
        'oGcmVhc29uGAIgASgJUgZyZWFzb24=');

@$core.Deprecated('Use listLicensesRequestDescriptor instead')
const ListLicensesRequest$json = {
  '1': 'ListLicensesRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListLicensesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listLicensesRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0TGljZW5zZXNSZXF1ZXN0EhsKCXBhZ2Vfc2l6ZRgBIAEoBVIIcGFnZVNpemUSHQoKcG'
    'FnZV90b2tlbhgCIAEoCVIJcGFnZVRva2Vu');

@$core.Deprecated('Use listLicensesResponseDescriptor instead')
const ListLicensesResponse$json = {
  '1': 'ListLicensesResponse',
  '2': [
    {
      '1': 'licenses',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.License',
      '10': 'licenses'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
  ],
};

/// Descriptor for `ListLicensesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listLicensesResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0TGljZW5zZXNSZXNwb25zZRIxCghsaWNlbnNlcxgBIAMoCzIVLmRvcnl3YWxsLmh1Yi'
    '5MaWNlbnNlUghsaWNlbnNlcxImCg9uZXh0X3BhZ2VfdG9rZW4YAiABKAlSDW5leHRQYWdlVG9r'
    'ZW4=');

@$core.Deprecated('Use licenseDescriptor instead')
const License$json = {
  '1': 'License',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'tier', '3': 3, '4': 1, '5': 9, '10': 'tier'},
    {'1': 'status', '3': 4, '4': 1, '5': 9, '10': 'status'},
    {
      '1': 'created_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'expires_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiresAt'
    },
  ],
};

/// Descriptor for `License`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List licenseDescriptor = $convert.base64Decode(
    'CgdMaWNlbnNlEhAKA2tleRgBIAEoCVIDa2V5EhcKB3VzZXJfaWQYAiABKAlSBnVzZXJJZBISCg'
    'R0aWVyGAMgASgJUgR0aWVyEhYKBnN0YXR1cxgEIAEoCVIGc3RhdHVzEjkKCmNyZWF0ZWRfYXQY'
    'BSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKZXhwaXJlc1'
    '9hdBgGIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWV4cGlyZXNBdA==');

@$core.Deprecated('Use revokeLicenseRequestDescriptor instead')
const RevokeLicenseRequest$json = {
  '1': 'RevokeLicenseRequest',
  '2': [
    {'1': 'license_key', '3': 1, '4': 1, '5': 9, '10': 'licenseKey'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `RevokeLicenseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeLicenseRequestDescriptor = $convert.base64Decode(
    'ChRSZXZva2VMaWNlbnNlUmVxdWVzdBIfCgtsaWNlbnNlX2tleRgBIAEoCVIKbGljZW5zZUtleR'
    'IWCgZyZWFzb24YAiABKAlSBnJlYXNvbg==');

@$core.Deprecated('Use createPromoCodeRequestDescriptor instead')
const CreatePromoCodeRequest$json = {
  '1': 'CreatePromoCodeRequest',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
    {'1': 'tier', '3': 2, '4': 1, '5': 9, '10': 'tier'},
    {'1': 'duration_days', '3': 3, '4': 1, '5': 5, '10': 'durationDays'},
    {'1': 'max_uses', '3': 4, '4': 1, '5': 5, '10': 'maxUses'},
  ],
};

/// Descriptor for `CreatePromoCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createPromoCodeRequestDescriptor = $convert.base64Decode(
    'ChZDcmVhdGVQcm9tb0NvZGVSZXF1ZXN0EhIKBGNvZGUYASABKAlSBGNvZGUSEgoEdGllchgCIA'
    'EoCVIEdGllchIjCg1kdXJhdGlvbl9kYXlzGAMgASgFUgxkdXJhdGlvbkRheXMSGQoIbWF4X3Vz'
    'ZXMYBCABKAVSB21heFVzZXM=');

@$core.Deprecated('Use promoCodeDescriptor instead')
const PromoCode$json = {
  '1': 'PromoCode',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
    {'1': 'tier', '3': 2, '4': 1, '5': 9, '10': 'tier'},
    {'1': 'duration_days', '3': 3, '4': 1, '5': 5, '10': 'durationDays'},
    {'1': 'max_uses', '3': 4, '4': 1, '5': 5, '10': 'maxUses'},
    {'1': 'current_uses', '3': 5, '4': 1, '5': 5, '10': 'currentUses'},
    {
      '1': 'expires_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiresAt'
    },
  ],
};

/// Descriptor for `PromoCode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List promoCodeDescriptor = $convert.base64Decode(
    'CglQcm9tb0NvZGUSEgoEY29kZRgBIAEoCVIEY29kZRISCgR0aWVyGAIgASgJUgR0aWVyEiMKDW'
    'R1cmF0aW9uX2RheXMYAyABKAVSDGR1cmF0aW9uRGF5cxIZCghtYXhfdXNlcxgEIAEoBVIHbWF4'
    'VXNlcxIhCgxjdXJyZW50X3VzZXMYBSABKAVSC2N1cnJlbnRVc2VzEjkKCmV4cGlyZXNfYXQYBi'
    'ABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUglleHBpcmVzQXQ=');

@$core.Deprecated('Use getConfigRequestDescriptor instead')
const GetConfigRequest$json = {
  '1': 'GetConfigRequest',
};

/// Descriptor for `GetConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getConfigRequestDescriptor =
    $convert.base64Decode('ChBHZXRDb25maWdSZXF1ZXN0');

@$core.Deprecated('Use updateConfigRequestDescriptor instead')
const UpdateConfigRequest$json = {
  '1': 'UpdateConfigRequest',
  '2': [
    {
      '1': 'config',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.nitella.hub.HubConfig',
      '10': 'config'
    },
  ],
};

/// Descriptor for `UpdateConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateConfigRequestDescriptor = $convert.base64Decode(
    'ChNVcGRhdGVDb25maWdSZXF1ZXN0Ei8KBmNvbmZpZxgBIAEoCzIXLmRvcnl3YWxsLmh1Yi5IdW'
    'JDb25maWdSBmNvbmZpZw==');

@$core.Deprecated('Use hubConfigDescriptor instead')
const HubConfig$json = {
  '1': 'HubConfig',
  '2': [
    {
      '1': 'free_tier_rate_limit',
      '3': 1,
      '4': 1,
      '5': 5,
      '10': 'freeTierRateLimit'
    },
    {
      '1': 'pro_tier_rate_limit',
      '3': 2,
      '4': 1,
      '5': 5,
      '10': 'proTierRateLimit'
    },
    {
      '1': 'business_tier_rate_limit',
      '3': 3,
      '4': 1,
      '5': 5,
      '10': 'businessTierRateLimit'
    },
    {
      '1': 'free_tier_max_nodes',
      '3': 4,
      '4': 1,
      '5': 5,
      '10': 'freeTierMaxNodes'
    },
    {
      '1': 'pro_tier_max_nodes',
      '3': 5,
      '4': 1,
      '5': 5,
      '10': 'proTierMaxNodes'
    },
    {
      '1': 'registration_enabled',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'registrationEnabled'
    },
    {
      '1': 'require_email_verification',
      '3': 7,
      '4': 1,
      '5': 8,
      '10': 'requireEmailVerification'
    },
  ],
};

/// Descriptor for `HubConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hubConfigDescriptor = $convert.base64Decode(
    'CglIdWJDb25maWcSLwoUZnJlZV90aWVyX3JhdGVfbGltaXQYASABKAVSEWZyZWVUaWVyUmF0ZU'
    'xpbWl0Ei0KE3Byb190aWVyX3JhdGVfbGltaXQYAiABKAVSEHByb1RpZXJSYXRlTGltaXQSNwoY'
    'YnVzaW5lc3NfdGllcl9yYXRlX2xpbWl0GAMgASgFUhVidXNpbmVzc1RpZXJSYXRlTGltaXQSLQ'
    'oTZnJlZV90aWVyX21heF9ub2RlcxgEIAEoBVIQZnJlZVRpZXJNYXhOb2RlcxIrChJwcm9fdGll'
    'cl9tYXhfbm9kZXMYBSABKAVSD3Byb1RpZXJNYXhOb2RlcxIxChRyZWdpc3RyYXRpb25fZW5hYm'
    'xlZBgGIAEoCFITcmVnaXN0cmF0aW9uRW5hYmxlZBI8ChpyZXF1aXJlX2VtYWlsX3ZlcmlmaWNh'
    'dGlvbhgHIAEoCFIYcmVxdWlyZUVtYWlsVmVyaWZpY2F0aW9u');

@$core.Deprecated('Use listAllRevocationsRequestDescriptor instead')
const ListAllRevocationsRequest$json = {
  '1': 'ListAllRevocationsRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListAllRevocationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAllRevocationsRequestDescriptor =
    $convert.base64Decode(
        'ChlMaXN0QWxsUmV2b2NhdGlvbnNSZXF1ZXN0EhsKCXBhZ2Vfc2l6ZRgBIAEoBVIIcGFnZVNpem'
        'USHQoKcGFnZV90b2tlbhgCIAEoCVIJcGFnZVRva2Vu');

@$core.Deprecated('Use listAllRevocationsResponseDescriptor instead')
const ListAllRevocationsResponse$json = {
  '1': 'ListAllRevocationsResponse',
  '2': [
    {
      '1': 'revocations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.RevocationEvent',
      '10': 'revocations'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
  ],
};

/// Descriptor for `ListAllRevocationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAllRevocationsResponseDescriptor =
    $convert.base64Decode(
        'ChpMaXN0QWxsUmV2b2NhdGlvbnNSZXNwb25zZRI/CgtyZXZvY2F0aW9ucxgBIAMoCzIdLmRvcn'
        'l3YWxsLmh1Yi5SZXZvY2F0aW9uRXZlbnRSC3Jldm9jYXRpb25zEiYKD25leHRfcGFnZV90b2tl'
        'bhgCIAEoCVINbmV4dFBhZ2VUb2tlbg==');

@$core.Deprecated('Use inviteCodeDescriptor instead')
const InviteCode$json = {
  '1': 'InviteCode',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'used', '3': 3, '4': 1, '5': 5, '10': 'used'},
    {
      '1': 'created_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `InviteCode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inviteCodeDescriptor = $convert.base64Decode(
    'CgpJbnZpdGVDb2RlEhIKBGNvZGUYASABKAlSBGNvZGUSFAoFbGltaXQYAiABKAVSBWxpbWl0Eh'
    'IKBHVzZWQYAyABKAVSBHVzZWQSOQoKY3JlYXRlZF9hdBgEIAEoCzIaLmdvb2dsZS5wcm90b2J1'
    'Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdA==');

@$core.Deprecated('Use deleteInviteCodeRequestDescriptor instead')
const DeleteInviteCodeRequest$json = {
  '1': 'DeleteInviteCodeRequest',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
  ],
};

/// Descriptor for `DeleteInviteCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteInviteCodeRequestDescriptor =
    $convert.base64Decode(
        'ChdEZWxldGVJbnZpdGVDb2RlUmVxdWVzdBISCgRjb2RlGAEgASgJUgRjb2Rl');

@$core.Deprecated('Use recalculateInviteCodeUsageRequestDescriptor instead')
const RecalculateInviteCodeUsageRequest$json = {
  '1': 'RecalculateInviteCodeUsageRequest',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
  ],
};

/// Descriptor for `RecalculateInviteCodeUsageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recalculateInviteCodeUsageRequestDescriptor =
    $convert.base64Decode(
        'CiFSZWNhbGN1bGF0ZUludml0ZUNvZGVVc2FnZVJlcXVlc3QSEgoEY29kZRgBIAEoCVIEY29kZQ'
        '==');

@$core.Deprecated('Use getHubCertInfoRequestDescriptor instead')
const GetHubCertInfoRequest$json = {
  '1': 'GetHubCertInfoRequest',
};

/// Descriptor for `GetHubCertInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHubCertInfoRequestDescriptor =
    $convert.base64Decode('ChVHZXRIdWJDZXJ0SW5mb1JlcXVlc3Q=');

@$core.Deprecated('Use rotateHubLeafCertRequestDescriptor instead')
const RotateHubLeafCertRequest$json = {
  '1': 'RotateHubLeafCertRequest',
  '2': [
    {'1': 'additional_sans', '3': 1, '4': 3, '5': 9, '10': 'additionalSans'},
  ],
};

/// Descriptor for `RotateHubLeafCertRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rotateHubLeafCertRequestDescriptor =
    $convert.base64Decode(
        'ChhSb3RhdGVIdWJMZWFmQ2VydFJlcXVlc3QSJwoPYWRkaXRpb25hbF9zYW5zGAEgAygJUg5hZG'
        'RpdGlvbmFsU2Fucw==');

@$core.Deprecated('Use hubCertInfoDescriptor instead')
const HubCertInfo$json = {
  '1': 'HubCertInfo',
  '2': [
    {'1': 'ca_fingerprint', '3': 1, '4': 1, '5': 9, '10': 'caFingerprint'},
    {'1': 'ca_emoji', '3': 2, '4': 1, '5': 9, '10': 'caEmoji'},
    {
      '1': 'ca_expires_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'caExpiresAt'
    },
    {'1': 'leaf_serial', '3': 4, '4': 1, '5': 9, '10': 'leafSerial'},
    {
      '1': 'leaf_expires_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'leafExpiresAt'
    },
    {
      '1': 'leaf_not_before',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'leafNotBefore'
    },
    {'1': 'leaf_dns_names', '3': 7, '4': 3, '5': 9, '10': 'leafDnsNames'},
    {'1': 'leaf_ip_addresses', '3': 8, '4': 3, '5': 9, '10': 'leafIpAddresses'},
  ],
};

/// Descriptor for `HubCertInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hubCertInfoDescriptor = $convert.base64Decode(
    'CgtIdWJDZXJ0SW5mbxIlCg5jYV9maW5nZXJwcmludBgBIAEoCVINY2FGaW5nZXJwcmludBIZCg'
    'hjYV9lbW9qaRgCIAEoCVIHY2FFbW9qaRI+Cg1jYV9leHBpcmVzX2F0GAMgASgLMhouZ29vZ2xl'
    'LnByb3RvYnVmLlRpbWVzdGFtcFILY2FFeHBpcmVzQXQSHwoLbGVhZl9zZXJpYWwYBCABKAlSCm'
    'xlYWZTZXJpYWwSQgoPbGVhZl9leHBpcmVzX2F0GAUgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRp'
    'bWVzdGFtcFINbGVhZkV4cGlyZXNBdBJCCg9sZWFmX25vdF9iZWZvcmUYBiABKAsyGi5nb29nbG'
    'UucHJvdG9idWYuVGltZXN0YW1wUg1sZWFmTm90QmVmb3JlEiQKDmxlYWZfZG5zX25hbWVzGAcg'
    'AygJUgxsZWFmRG5zTmFtZXMSKgoRbGVhZl9pcF9hZGRyZXNzZXMYCCADKAlSD2xlYWZJcEFkZH'
    'Jlc3Nlcw==');

@$core.Deprecated('Use getDatabaseStatsRequestDescriptor instead')
const GetDatabaseStatsRequest$json = {
  '1': 'GetDatabaseStatsRequest',
};

/// Descriptor for `GetDatabaseStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDatabaseStatsRequestDescriptor =
    $convert.base64Decode('ChdHZXREYXRhYmFzZVN0YXRzUmVxdWVzdA==');

@$core.Deprecated('Use databaseStatsDescriptor instead')
const DatabaseStats$json = {
  '1': 'DatabaseStats',
  '2': [
    {'1': 'db_size_bytes', '3': 1, '4': 1, '5': 3, '10': 'dbSizeBytes'},
    {'1': 'user_count', '3': 2, '4': 1, '5': 5, '10': 'userCount'},
    {'1': 'node_count', '3': 3, '4': 1, '5': 5, '10': 'nodeCount'},
    {'1': 'org_count', '3': 4, '4': 1, '5': 5, '10': 'orgCount'},
    {'1': 'device_count', '3': 5, '4': 1, '5': 5, '10': 'deviceCount'},
    {'1': 'template_count', '3': 6, '4': 1, '5': 5, '10': 'templateCount'},
    {'1': 'revocation_count', '3': 7, '4': 1, '5': 5, '10': 'revocationCount'},
    {'1': 'invite_code_count', '3': 8, '4': 1, '5': 5, '10': 'inviteCodeCount'},
    {'1': 'license_count', '3': 9, '4': 1, '5': 5, '10': 'licenseCount'},
    {
      '1': 'pending_registration_count',
      '3': 10,
      '4': 1,
      '5': 5,
      '10': 'pendingRegistrationCount'
    },
    {
      '1': 'audit_entry_count',
      '3': 11,
      '4': 1,
      '5': 5,
      '10': 'auditEntryCount'
    },
    {
      '1': 'oldest_audit_entry',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'oldestAuditEntry'
    },
    {
      '1': 'newest_audit_entry',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'newestAuditEntry'
    },
  ],
};

/// Descriptor for `DatabaseStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List databaseStatsDescriptor = $convert.base64Decode(
    'Cg1EYXRhYmFzZVN0YXRzEiIKDWRiX3NpemVfYnl0ZXMYASABKANSC2RiU2l6ZUJ5dGVzEh0KCn'
    'VzZXJfY291bnQYAiABKAVSCXVzZXJDb3VudBIdCgpub2RlX2NvdW50GAMgASgFUglub2RlQ291'
    'bnQSGwoJb3JnX2NvdW50GAQgASgFUghvcmdDb3VudBIhCgxkZXZpY2VfY291bnQYBSABKAVSC2'
    'RldmljZUNvdW50EiUKDnRlbXBsYXRlX2NvdW50GAYgASgFUg10ZW1wbGF0ZUNvdW50EikKEHJl'
    'dm9jYXRpb25fY291bnQYByABKAVSD3Jldm9jYXRpb25Db3VudBIqChFpbnZpdGVfY29kZV9jb3'
    'VudBgIIAEoBVIPaW52aXRlQ29kZUNvdW50EiMKDWxpY2Vuc2VfY291bnQYCSABKAVSDGxpY2Vu'
    'c2VDb3VudBI8ChpwZW5kaW5nX3JlZ2lzdHJhdGlvbl9jb3VudBgKIAEoBVIYcGVuZGluZ1JlZ2'
    'lzdHJhdGlvbkNvdW50EioKEWF1ZGl0X2VudHJ5X2NvdW50GAsgASgFUg9hdWRpdEVudHJ5Q291'
    'bnQSSAoSb2xkZXN0X2F1ZGl0X2VudHJ5GAwgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdG'
    'FtcFIQb2xkZXN0QXVkaXRFbnRyeRJIChJuZXdlc3RfYXVkaXRfZW50cnkYDSABKAsyGi5nb29n'
    'bGUucHJvdG9idWYuVGltZXN0YW1wUhBuZXdlc3RBdWRpdEVudHJ5');

@$core.Deprecated('Use deleteUserRequestDescriptor instead')
const DeleteUserRequest$json = {
  '1': 'DeleteUserRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'cascade', '3': 2, '4': 1, '5': 8, '10': 'cascade'},
  ],
};

/// Descriptor for `DeleteUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteUserRequestDescriptor = $convert.base64Decode(
    'ChFEZWxldGVVc2VyUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSGAoHY2FzY2FkZR'
    'gCIAEoCFIHY2FzY2FkZQ==');

@$core.Deprecated('Use getNodeDetailsRequestDescriptor instead')
const GetNodeDetailsRequest$json = {
  '1': 'GetNodeDetailsRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `GetNodeDetailsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNodeDetailsRequestDescriptor =
    $convert.base64Decode(
        'ChVHZXROb2RlRGV0YWlsc1JlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlk');

@$core.Deprecated('Use nodeDetailsDescriptor instead')
const NodeDetails$json = {
  '1': 'NodeDetails',
  '2': [
    {
      '1': 'node',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.nitella.hub.Node',
      '10': 'node'
    },
    {'1': 'owner_id', '3': 2, '4': 1, '5': 9, '10': 'ownerId'},
    {'1': 'owner_tier', '3': 3, '4': 1, '5': 9, '10': 'ownerTier'},
    {'1': 'total_bytes_month', '3': 4, '4': 1, '5': 3, '10': 'totalBytesMonth'},
    {
      '1': 'total_connections_month',
      '3': 5,
      '4': 1,
      '5': 3,
      '10': 'totalConnectionsMonth'
    },
    {
      '1': 'registration_date',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'registrationDate'
    },
    {'1': 'cert_serial', '3': 7, '4': 1, '5': 9, '10': 'certSerial'},
    {'1': 'cert_fingerprint', '3': 8, '4': 1, '5': 9, '10': 'certFingerprint'},
    {
      '1': 'cert_expires_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'certExpiresAt'
    },
    {'1': 'blind_indices', '3': 10, '4': 3, '5': 9, '10': 'blindIndices'},
    {
      '1': 'encrypted_metadata_size',
      '3': 11,
      '4': 1,
      '5': 5,
      '10': 'encryptedMetadataSize'
    },
  ],
};

/// Descriptor for `NodeDetails`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeDetailsDescriptor = $convert.base64Decode(
    'CgtOb2RlRGV0YWlscxImCgRub2RlGAEgASgLMhIuZG9yeXdhbGwuaHViLk5vZGVSBG5vZGUSGQ'
    'oIb3duZXJfaWQYAiABKAlSB293bmVySWQSHQoKb3duZXJfdGllchgDIAEoCVIJb3duZXJUaWVy'
    'EioKEXRvdGFsX2J5dGVzX21vbnRoGAQgASgDUg90b3RhbEJ5dGVzTW9udGgSNgoXdG90YWxfY2'
    '9ubmVjdGlvbnNfbW9udGgYBSABKANSFXRvdGFsQ29ubmVjdGlvbnNNb250aBJHChFyZWdpc3Ry'
    'YXRpb25fZGF0ZRgGIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSEHJlZ2lzdHJhdG'
    'lvbkRhdGUSHwoLY2VydF9zZXJpYWwYByABKAlSCmNlcnRTZXJpYWwSKQoQY2VydF9maW5nZXJw'
    'cmludBgIIAEoCVIPY2VydEZpbmdlcnByaW50EkIKD2NlcnRfZXhwaXJlc19hdBgJIAEoCzIaLm'
    'dvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSDWNlcnRFeHBpcmVzQXQSIwoNYmxpbmRfaW5kaWNl'
    'cxgKIAMoCVIMYmxpbmRJbmRpY2VzEjYKF2VuY3J5cHRlZF9tZXRhZGF0YV9zaXplGAsgASgFUh'
    'VlbmNyeXB0ZWRNZXRhZGF0YVNpemU=');

@$core.Deprecated('Use adminDeleteNodeRequestDescriptor instead')
const AdminDeleteNodeRequest$json = {
  '1': 'AdminDeleteNodeRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'revoke_cert', '3': 3, '4': 1, '5': 8, '10': 'revokeCert'},
  ],
};

/// Descriptor for `AdminDeleteNodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List adminDeleteNodeRequestDescriptor = $convert.base64Decode(
    'ChZBZG1pbkRlbGV0ZU5vZGVSZXF1ZXN0EhcKB25vZGVfaWQYASABKAlSBm5vZGVJZBIWCgZyZW'
    'Fzb24YAiABKAlSBnJlYXNvbhIfCgtyZXZva2VfY2VydBgDIAEoCFIKcmV2b2tlQ2VydA==');

@$core.Deprecated('Use organizationDescriptor instead')
const Organization$json = {
  '1': 'Organization',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tier', '3': 2, '4': 1, '5': 9, '10': 'tier'},
    {'1': 'max_members', '3': 3, '4': 1, '5': 5, '10': 'maxMembers'},
    {'1': 'member_count', '3': 4, '4': 1, '5': 5, '10': 'memberCount'},
    {'1': 'node_count', '3': 5, '4': 1, '5': 5, '10': 'nodeCount'},
    {
      '1': 'created_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'encrypted_metadata',
      '3': 7,
      '4': 1,
      '5': 12,
      '10': 'encryptedMetadata'
    },
    {
      '1': 'encrypted_metadata_size',
      '3': 8,
      '4': 1,
      '5': 5,
      '10': 'encryptedMetadataSize'
    },
  ],
};

/// Descriptor for `Organization`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List organizationDescriptor = $convert.base64Decode(
    'CgxPcmdhbml6YXRpb24SDgoCaWQYASABKAlSAmlkEhIKBHRpZXIYAiABKAlSBHRpZXISHwoLbW'
    'F4X21lbWJlcnMYAyABKAVSCm1heE1lbWJlcnMSIQoMbWVtYmVyX2NvdW50GAQgASgFUgttZW1i'
    'ZXJDb3VudBIdCgpub2RlX2NvdW50GAUgASgFUglub2RlQ291bnQSOQoKY3JlYXRlZF9hdBgGIA'
    'EoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBItChJlbmNyeXB0ZWRf'
    'bWV0YWRhdGEYByABKAxSEWVuY3J5cHRlZE1ldGFkYXRhEjYKF2VuY3J5cHRlZF9tZXRhZGF0YV'
    '9zaXplGAggASgFUhVlbmNyeXB0ZWRNZXRhZGF0YVNpemU=');

@$core.Deprecated('Use listOrganizationsRequestDescriptor instead')
const ListOrganizationsRequest$json = {
  '1': 'ListOrganizationsRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'filter_tier', '3': 3, '4': 1, '5': 9, '10': 'filterTier'},
  ],
};

/// Descriptor for `ListOrganizationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listOrganizationsRequestDescriptor = $convert.base64Decode(
    'ChhMaXN0T3JnYW5pemF0aW9uc1JlcXVlc3QSGwoJcGFnZV9zaXplGAEgASgFUghwYWdlU2l6ZR'
    'IdCgpwYWdlX3Rva2VuGAIgASgJUglwYWdlVG9rZW4SHwoLZmlsdGVyX3RpZXIYAyABKAlSCmZp'
    'bHRlclRpZXI=');

@$core.Deprecated('Use listOrganizationsResponseDescriptor instead')
const ListOrganizationsResponse$json = {
  '1': 'ListOrganizationsResponse',
  '2': [
    {
      '1': 'organizations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.Organization',
      '10': 'organizations'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListOrganizationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listOrganizationsResponseDescriptor = $convert.base64Decode(
    'ChlMaXN0T3JnYW5pemF0aW9uc1Jlc3BvbnNlEkAKDW9yZ2FuaXphdGlvbnMYASADKAsyGi5kb3'
    'J5d2FsbC5odWIuT3JnYW5pemF0aW9uUg1vcmdhbml6YXRpb25zEiYKD25leHRfcGFnZV90b2tl'
    'bhgCIAEoCVINbmV4dFBhZ2VUb2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3VudA'
    '==');

@$core.Deprecated('Use getOrganizationRequestDescriptor instead')
const GetOrganizationRequest$json = {
  '1': 'GetOrganizationRequest',
  '2': [
    {'1': 'org_id', '3': 1, '4': 1, '5': 9, '10': 'orgId'},
  ],
};

/// Descriptor for `GetOrganizationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getOrganizationRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRPcmdhbml6YXRpb25SZXF1ZXN0EhUKBm9yZ19pZBgBIAEoCVIFb3JnSWQ=');

@$core.Deprecated('Use organizationDetailsDescriptor instead')
const OrganizationDetails$json = {
  '1': 'OrganizationDetails',
  '2': [
    {
      '1': 'org',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.nitella.hub.Organization',
      '10': 'org'
    },
    {
      '1': 'members',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.User',
      '10': 'members'
    },
    {
      '1': 'nodes',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.Node',
      '10': 'nodes'
    },
    {
      '1': 'total_storage_bytes',
      '3': 4,
      '4': 1,
      '5': 3,
      '10': 'totalStorageBytes'
    },
    {'1': 'active_invites', '3': 5, '4': 1, '5': 5, '10': 'activeInvites'},
  ],
};

/// Descriptor for `OrganizationDetails`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List organizationDetailsDescriptor = $convert.base64Decode(
    'ChNPcmdhbml6YXRpb25EZXRhaWxzEiwKA29yZxgBIAEoCzIaLmRvcnl3YWxsLmh1Yi5Pcmdhbm'
    'l6YXRpb25SA29yZxIsCgdtZW1iZXJzGAIgAygLMhIuZG9yeXdhbGwuaHViLlVzZXJSB21lbWJl'
    'cnMSKAoFbm9kZXMYAyADKAsyEi5kb3J5d2FsbC5odWIuTm9kZVIFbm9kZXMSLgoTdG90YWxfc3'
    'RvcmFnZV9ieXRlcxgEIAEoA1IRdG90YWxTdG9yYWdlQnl0ZXMSJQoOYWN0aXZlX2ludml0ZXMY'
    'BSABKAVSDWFjdGl2ZUludml0ZXM=');

@$core.Deprecated('Use setOrganizationTierRequestDescriptor instead')
const SetOrganizationTierRequest$json = {
  '1': 'SetOrganizationTierRequest',
  '2': [
    {'1': 'org_id', '3': 1, '4': 1, '5': 9, '10': 'orgId'},
    {'1': 'tier', '3': 2, '4': 1, '5': 9, '10': 'tier'},
    {'1': 'max_members', '3': 3, '4': 1, '5': 5, '10': 'maxMembers'},
  ],
};

/// Descriptor for `SetOrganizationTierRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setOrganizationTierRequestDescriptor =
    $convert.base64Decode(
        'ChpTZXRPcmdhbml6YXRpb25UaWVyUmVxdWVzdBIVCgZvcmdfaWQYASABKAlSBW9yZ0lkEhIKBH'
        'RpZXIYAiABKAlSBHRpZXISHwoLbWF4X21lbWJlcnMYAyABKAVSCm1heE1lbWJlcnM=');

@$core.Deprecated('Use deleteOrganizationRequestDescriptor instead')
const DeleteOrganizationRequest$json = {
  '1': 'DeleteOrganizationRequest',
  '2': [
    {'1': 'org_id', '3': 1, '4': 1, '5': 9, '10': 'orgId'},
    {'1': 'cascade', '3': 2, '4': 1, '5': 8, '10': 'cascade'},
  ],
};

/// Descriptor for `DeleteOrganizationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteOrganizationRequestDescriptor =
    $convert.base64Decode(
        'ChlEZWxldGVPcmdhbml6YXRpb25SZXF1ZXN0EhUKBm9yZ19pZBgBIAEoCVIFb3JnSWQSGAoHY2'
        'FzY2FkZRgCIAEoCFIHY2FzY2FkZQ==');

@$core.Deprecated('Use pendingRegistrationDescriptor instead')
const PendingRegistration$json = {
  '1': 'PendingRegistration',
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
    {
      '1': 'encrypted_metadata_size',
      '3': 4,
      '4': 1,
      '5': 5,
      '10': 'encryptedMetadataSize'
    },
    {'1': 'listen_ports', '3': 5, '4': 3, '5': 5, '10': 'listenPorts'},
    {'1': 'version', '3': 6, '4': 1, '5': 9, '10': 'version'},
    {'1': 'invite_code', '3': 7, '4': 1, '5': 9, '10': 'inviteCode'},
    {'1': 'pairing_code', '3': 8, '4': 1, '5': 9, '10': 'pairingCode'},
    {
      '1': 'status',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.nitella.hub.RegistrationStatus',
      '10': 'status'
    },
    {
      '1': 'created_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'expires_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiresAt'
    },
    {'1': 'source_ip', '3': 12, '4': 1, '5': 9, '10': 'sourceIp'},
  ],
};

/// Descriptor for `PendingRegistration`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pendingRegistrationDescriptor = $convert.base64Decode(
    'ChNQZW5kaW5nUmVnaXN0cmF0aW9uEisKEXJlZ2lzdHJhdGlvbl9jb2RlGAEgASgJUhByZWdpc3'
    'RyYXRpb25Db2RlEhcKB2Nzcl9wZW0YAiABKAlSBmNzclBlbRItChJlbmNyeXB0ZWRfbWV0YWRh'
    'dGEYAyABKAxSEWVuY3J5cHRlZE1ldGFkYXRhEjYKF2VuY3J5cHRlZF9tZXRhZGF0YV9zaXplGA'
    'QgASgFUhVlbmNyeXB0ZWRNZXRhZGF0YVNpemUSIQoMbGlzdGVuX3BvcnRzGAUgAygFUgtsaXN0'
    'ZW5Qb3J0cxIYCgd2ZXJzaW9uGAYgASgJUgd2ZXJzaW9uEh8KC2ludml0ZV9jb2RlGAcgASgJUg'
    'ppbnZpdGVDb2RlEiEKDHBhaXJpbmdfY29kZRgIIAEoCVILcGFpcmluZ0NvZGUSOAoGc3RhdHVz'
    'GAkgASgOMiAuZG9yeXdhbGwuaHViLlJlZ2lzdHJhdGlvblN0YXR1c1IGc3RhdHVzEjkKCmNyZW'
    'F0ZWRfYXQYCiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoK'
    'ZXhwaXJlc19hdBgLIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWV4cGlyZXNBdB'
    'IbCglzb3VyY2VfaXAYDCABKAlSCHNvdXJjZUlw');

@$core.Deprecated('Use listPendingRegistrationsRequestDescriptor instead')
const ListPendingRegistrationsRequest$json = {
  '1': 'ListPendingRegistrationsRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'filter_status', '3': 3, '4': 1, '5': 9, '10': 'filterStatus'},
  ],
};

/// Descriptor for `ListPendingRegistrationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPendingRegistrationsRequestDescriptor =
    $convert.base64Decode(
        'Ch9MaXN0UGVuZGluZ1JlZ2lzdHJhdGlvbnNSZXF1ZXN0EhsKCXBhZ2Vfc2l6ZRgBIAEoBVIIcG'
        'FnZVNpemUSHQoKcGFnZV90b2tlbhgCIAEoCVIJcGFnZVRva2VuEiMKDWZpbHRlcl9zdGF0dXMY'
        'AyABKAlSDGZpbHRlclN0YXR1cw==');

@$core.Deprecated('Use listPendingRegistrationsResponseDescriptor instead')
const ListPendingRegistrationsResponse$json = {
  '1': 'ListPendingRegistrationsResponse',
  '2': [
    {
      '1': 'registrations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.PendingRegistration',
      '10': 'registrations'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListPendingRegistrationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPendingRegistrationsResponseDescriptor =
    $convert.base64Decode(
        'CiBMaXN0UGVuZGluZ1JlZ2lzdHJhdGlvbnNSZXNwb25zZRJHCg1yZWdpc3RyYXRpb25zGAEgAy'
        'gLMiEuZG9yeXdhbGwuaHViLlBlbmRpbmdSZWdpc3RyYXRpb25SDXJlZ2lzdHJhdGlvbnMSJgoP'
        'bmV4dF9wYWdlX3Rva2VuGAIgASgJUg1uZXh0UGFnZVRva2VuEh8KC3RvdGFsX2NvdW50GAMgAS'
        'gFUgp0b3RhbENvdW50');

@$core.Deprecated('Use forceApproveRegistrationRequestDescriptor instead')
const ForceApproveRegistrationRequest$json = {
  '1': 'ForceApproveRegistrationRequest',
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
    {'1': 'assigned_owner_id', '3': 4, '4': 1, '5': 9, '10': 'assignedOwnerId'},
  ],
};

/// Descriptor for `ForceApproveRegistrationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forceApproveRegistrationRequestDescriptor =
    $convert.base64Decode(
        'Ch9Gb3JjZUFwcHJvdmVSZWdpc3RyYXRpb25SZXF1ZXN0EisKEXJlZ2lzdHJhdGlvbl9jb2RlGA'
        'EgASgJUhByZWdpc3RyYXRpb25Db2RlEhkKCGNlcnRfcGVtGAIgASgJUgdjZXJ0UGVtEhUKBmNh'
        'X3BlbRgDIAEoCVIFY2FQZW0SKgoRYXNzaWduZWRfb3duZXJfaWQYBCABKAlSD2Fzc2lnbmVkT3'
        'duZXJJZA==');

@$core.Deprecated('Use rejectRegistrationRequestDescriptor instead')
const RejectRegistrationRequest$json = {
  '1': 'RejectRegistrationRequest',
  '2': [
    {
      '1': 'registration_code',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'registrationCode'
    },
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `RejectRegistrationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rejectRegistrationRequestDescriptor =
    $convert.base64Decode(
        'ChlSZWplY3RSZWdpc3RyYXRpb25SZXF1ZXN0EisKEXJlZ2lzdHJhdGlvbl9jb2RlGAEgASgJUh'
        'ByZWdpc3RyYXRpb25Db2RlEhYKBnJlYXNvbhgCIAEoCVIGcmVhc29u');

@$core.Deprecated('Use clearStalePairingsRequestDescriptor instead')
const ClearStalePairingsRequest$json = {
  '1': 'ClearStalePairingsRequest',
  '2': [
    {
      '1': 'older_than_minutes',
      '3': 1,
      '4': 1,
      '5': 5,
      '10': 'olderThanMinutes'
    },
  ],
};

/// Descriptor for `ClearStalePairingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clearStalePairingsRequestDescriptor =
    $convert.base64Decode(
        'ChlDbGVhclN0YWxlUGFpcmluZ3NSZXF1ZXN0EiwKEm9sZGVyX3RoYW5fbWludXRlcxgBIAEoBV'
        'IQb2xkZXJUaGFuTWludXRlcw==');

@$core.Deprecated('Use clearStalePairingsResponseDescriptor instead')
const ClearStalePairingsResponse$json = {
  '1': 'ClearStalePairingsResponse',
  '2': [
    {'1': 'cleared_count', '3': 1, '4': 1, '5': 5, '10': 'clearedCount'},
  ],
};

/// Descriptor for `ClearStalePairingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clearStalePairingsResponseDescriptor =
    $convert.base64Decode(
        'ChpDbGVhclN0YWxlUGFpcmluZ3NSZXNwb25zZRIjCg1jbGVhcmVkX2NvdW50GAEgASgFUgxjbG'
        'VhcmVkQ291bnQ=');

@$core.Deprecated('Use deviceDescriptor instead')
const Device$json = {
  '1': 'Device',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'fcm_token', '3': 3, '4': 1, '5': 9, '10': 'fcmToken'},
    {'1': 'device_type', '3': 4, '4': 1, '5': 9, '10': 'deviceType'},
    {
      '1': 'registered_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'registeredAt'
    },
    {
      '1': 'last_push_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastPushAt'
    },
    {
      '1': 'push_success_count',
      '3': 7,
      '4': 1,
      '5': 5,
      '10': 'pushSuccessCount'
    },
    {
      '1': 'push_failure_count',
      '3': 8,
      '4': 1,
      '5': 5,
      '10': 'pushFailureCount'
    },
  ],
};

/// Descriptor for `Device`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceDescriptor = $convert.base64Decode(
    'CgZEZXZpY2USDgoCaWQYASABKAlSAmlkEhcKB3VzZXJfaWQYAiABKAlSBnVzZXJJZBIbCglmY2'
    '1fdG9rZW4YAyABKAlSCGZjbVRva2VuEh8KC2RldmljZV90eXBlGAQgASgJUgpkZXZpY2VUeXBl'
    'Ej8KDXJlZ2lzdGVyZWRfYXQYBSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgxyZW'
    'dpc3RlcmVkQXQSPAoMbGFzdF9wdXNoX2F0GAYgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVz'
    'dGFtcFIKbGFzdFB1c2hBdBIsChJwdXNoX3N1Y2Nlc3NfY291bnQYByABKAVSEHB1c2hTdWNjZX'
    'NzQ291bnQSLAoScHVzaF9mYWlsdXJlX2NvdW50GAggASgFUhBwdXNoRmFpbHVyZUNvdW50');

@$core.Deprecated('Use listDevicesRequestDescriptor instead')
const ListDevicesRequest$json = {
  '1': 'ListDevicesRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'filter_type', '3': 3, '4': 1, '5': 9, '10': 'filterType'},
  ],
};

/// Descriptor for `ListDevicesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDevicesRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0RGV2aWNlc1JlcXVlc3QSGwoJcGFnZV9zaXplGAEgASgFUghwYWdlU2l6ZRIdCgpwYW'
    'dlX3Rva2VuGAIgASgJUglwYWdlVG9rZW4SHwoLZmlsdGVyX3R5cGUYAyABKAlSCmZpbHRlclR5'
    'cGU=');

@$core.Deprecated('Use listDevicesResponseDescriptor instead')
const ListDevicesResponse$json = {
  '1': 'ListDevicesResponse',
  '2': [
    {
      '1': 'devices',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.Device',
      '10': 'devices'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListDevicesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDevicesResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0RGV2aWNlc1Jlc3BvbnNlEi4KB2RldmljZXMYASADKAsyFC5kb3J5d2FsbC5odWIuRG'
    'V2aWNlUgdkZXZpY2VzEiYKD25leHRfcGFnZV90b2tlbhgCIAEoCVINbmV4dFBhZ2VUb2tlbhIf'
    'Cgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use getUserDevicesRequestDescriptor instead')
const GetUserDevicesRequest$json = {
  '1': 'GetUserDevicesRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `GetUserDevicesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUserDevicesRequestDescriptor =
    $convert.base64Decode(
        'ChVHZXRVc2VyRGV2aWNlc1JlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklk');

@$core.Deprecated('Use removeDeviceRequestDescriptor instead')
const RemoveDeviceRequest$json = {
  '1': 'RemoveDeviceRequest',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `RemoveDeviceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeDeviceRequestDescriptor = $convert.base64Decode(
    'ChNSZW1vdmVEZXZpY2VSZXF1ZXN0EhsKCWRldmljZV9pZBgBIAEoCVIIZGV2aWNlSWQSFgoGcm'
    'Vhc29uGAIgASgJUgZyZWFzb24=');

@$core.Deprecated('Use orgInviteDescriptor instead')
const OrgInvite$json = {
  '1': 'OrgInvite',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
    {'1': 'org_id', '3': 2, '4': 1, '5': 9, '10': 'orgId'},
    {'1': 'org_name', '3': 3, '4': 1, '5': 9, '10': 'orgName'},
    {'1': 'inviter_user_id', '3': 4, '4': 1, '5': 9, '10': 'inviterUserId'},
    {
      '1': 'invitee_public_key_id',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'inviteePublicKeyId'
    },
    {
      '1': 'encrypted_key_size',
      '3': 6,
      '4': 1,
      '5': 5,
      '10': 'encryptedKeySize'
    },
    {
      '1': 'passphrase_required',
      '3': 7,
      '4': 1,
      '5': 8,
      '10': 'passphraseRequired'
    },
    {
      '1': 'created_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'expires_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiresAt'
    },
    {'1': 'accepted', '3': 10, '4': 1, '5': 8, '10': 'accepted'},
  ],
};

/// Descriptor for `OrgInvite`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orgInviteDescriptor = $convert.base64Decode(
    'CglPcmdJbnZpdGUSFAoFdG9rZW4YASABKAlSBXRva2VuEhUKBm9yZ19pZBgCIAEoCVIFb3JnSW'
    'QSGQoIb3JnX25hbWUYAyABKAlSB29yZ05hbWUSJgoPaW52aXRlcl91c2VyX2lkGAQgASgJUg1p'
    'bnZpdGVyVXNlcklkEjEKFWludml0ZWVfcHVibGljX2tleV9pZBgFIAEoCVISaW52aXRlZVB1Ym'
    'xpY0tleUlkEiwKEmVuY3J5cHRlZF9rZXlfc2l6ZRgGIAEoBVIQZW5jcnlwdGVkS2V5U2l6ZRIv'
    'ChNwYXNzcGhyYXNlX3JlcXVpcmVkGAcgASgIUhJwYXNzcGhyYXNlUmVxdWlyZWQSOQoKY3JlYX'
    'RlZF9hdBgIIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgpl'
    'eHBpcmVzX2F0GAkgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJZXhwaXJlc0F0Eh'
    'oKCGFjY2VwdGVkGAogASgIUghhY2NlcHRlZA==');

@$core.Deprecated('Use listActiveOrgInvitesRequestDescriptor instead')
const ListActiveOrgInvitesRequest$json = {
  '1': 'ListActiveOrgInvitesRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'filter_org_id', '3': 3, '4': 1, '5': 9, '10': 'filterOrgId'},
  ],
};

/// Descriptor for `ListActiveOrgInvitesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listActiveOrgInvitesRequestDescriptor =
    $convert.base64Decode(
        'ChtMaXN0QWN0aXZlT3JnSW52aXRlc1JlcXVlc3QSGwoJcGFnZV9zaXplGAEgASgFUghwYWdlU2'
        'l6ZRIdCgpwYWdlX3Rva2VuGAIgASgJUglwYWdlVG9rZW4SIgoNZmlsdGVyX29yZ19pZBgDIAEo'
        'CVILZmlsdGVyT3JnSWQ=');

@$core.Deprecated('Use listActiveOrgInvitesResponseDescriptor instead')
const ListActiveOrgInvitesResponse$json = {
  '1': 'ListActiveOrgInvitesResponse',
  '2': [
    {
      '1': 'invites',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.OrgInvite',
      '10': 'invites'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListActiveOrgInvitesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listActiveOrgInvitesResponseDescriptor =
    $convert.base64Decode(
        'ChxMaXN0QWN0aXZlT3JnSW52aXRlc1Jlc3BvbnNlEjEKB2ludml0ZXMYASADKAsyFy5kb3J5d2'
        'FsbC5odWIuT3JnSW52aXRlUgdpbnZpdGVzEiYKD25leHRfcGFnZV90b2tlbhgCIAEoCVINbmV4'
        'dFBhZ2VUb2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use revokeOrgInviteRequestDescriptor instead')
const RevokeOrgInviteRequest$json = {
  '1': 'RevokeOrgInviteRequest',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `RevokeOrgInviteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeOrgInviteRequestDescriptor =
    $convert.base64Decode(
        'ChZSZXZva2VPcmdJbnZpdGVSZXF1ZXN0EhQKBXRva2VuGAEgASgJUgV0b2tlbhIWCgZyZWFzb2'
        '4YAiABKAlSBnJlYXNvbg==');

@$core.Deprecated('Use templateBlobDescriptor instead')
const TemplateBlob$json = {
  '1': 'TemplateBlob',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'org_id', '3': 3, '4': 1, '5': 9, '10': 'orgId'},
    {'1': 'encryption_type', '3': 4, '4': 1, '5': 9, '10': 'encryptionType'},
    {
      '1': 'encrypted_size_bytes',
      '3': 5,
      '4': 1,
      '5': 5,
      '10': 'encryptedSizeBytes'
    },
    {'1': 'version', '3': 6, '4': 1, '5': 3, '10': 'version'},
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
    {'1': 'expired', '3': 9, '4': 1, '5': 8, '10': 'expired'},
  ],
};

/// Descriptor for `TemplateBlob`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateBlobDescriptor = $convert.base64Decode(
    'CgxUZW1wbGF0ZUJsb2ISDgoCaWQYASABKAlSAmlkEhcKB3VzZXJfaWQYAiABKAlSBnVzZXJJZB'
    'IVCgZvcmdfaWQYAyABKAlSBW9yZ0lkEicKD2VuY3J5cHRpb25fdHlwZRgEIAEoCVIOZW5jcnlw'
    'dGlvblR5cGUSMAoUZW5jcnlwdGVkX3NpemVfYnl0ZXMYBSABKAVSEmVuY3J5cHRlZFNpemVCeX'
    'RlcxIYCgd2ZXJzaW9uGAYgASgDUgd2ZXJzaW9uEjkKCmNyZWF0ZWRfYXQYByABKAsyGi5nb29n'
    'bGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKZXhwaXJlc19hdBgIIAEoCzIaLm'
    'dvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWV4cGlyZXNBdBIYCgdleHBpcmVkGAkgASgIUgdl'
    'eHBpcmVk');

@$core.Deprecated('Use listUserTemplatesRequestDescriptor instead')
const ListUserTemplatesRequest$json = {
  '1': 'ListUserTemplatesRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 3, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListUserTemplatesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUserTemplatesRequestDescriptor = $convert.base64Decode(
    'ChhMaXN0VXNlclRlbXBsYXRlc1JlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhsKCX'
    'BhZ2Vfc2l6ZRgCIAEoBVIIcGFnZVNpemUSHQoKcGFnZV90b2tlbhgDIAEoCVIJcGFnZVRva2Vu');

@$core.Deprecated('Use listUserTemplatesResponseDescriptor instead')
const ListUserTemplatesResponse$json = {
  '1': 'ListUserTemplatesResponse',
  '2': [
    {
      '1': 'templates',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.TemplateBlob',
      '10': 'templates'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListUserTemplatesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUserTemplatesResponseDescriptor = $convert.base64Decode(
    'ChlMaXN0VXNlclRlbXBsYXRlc1Jlc3BvbnNlEjgKCXRlbXBsYXRlcxgBIAMoCzIaLmRvcnl3YW'
    'xsLmh1Yi5UZW1wbGF0ZUJsb2JSCXRlbXBsYXRlcxImCg9uZXh0X3BhZ2VfdG9rZW4YAiABKAlS'
    'DW5leHRQYWdlVG9rZW4SHwoLdG90YWxfY291bnQYAyABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use getTemplateStatsRequestDescriptor instead')
const GetTemplateStatsRequest$json = {
  '1': 'GetTemplateStatsRequest',
};

/// Descriptor for `GetTemplateStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTemplateStatsRequestDescriptor =
    $convert.base64Decode('ChdHZXRUZW1wbGF0ZVN0YXRzUmVxdWVzdA==');

@$core.Deprecated('Use templateStatsDescriptor instead')
const TemplateStats$json = {
  '1': 'TemplateStats',
  '2': [
    {'1': 'total_templates', '3': 1, '4': 1, '5': 5, '10': 'totalTemplates'},
    {
      '1': 'total_storage_bytes',
      '3': 2,
      '4': 1,
      '5': 3,
      '10': 'totalStorageBytes'
    },
    {
      '1': 'personal_templates',
      '3': 3,
      '4': 1,
      '5': 5,
      '10': 'personalTemplates'
    },
    {'1': 'org_templates', '3': 4, '4': 1, '5': 5, '10': 'orgTemplates'},
    {
      '1': 'expired_templates',
      '3': 5,
      '4': 1,
      '5': 5,
      '10': 'expiredTemplates'
    },
    {
      '1': 'templates_by_user',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.TemplateStats.TemplatesByUserEntry',
      '10': 'templatesByUser'
    },
  ],
  '3': [TemplateStats_TemplatesByUserEntry$json],
};

@$core.Deprecated('Use templateStatsDescriptor instead')
const TemplateStats_TemplatesByUserEntry$json = {
  '1': 'TemplatesByUserEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `TemplateStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List templateStatsDescriptor = $convert.base64Decode(
    'Cg1UZW1wbGF0ZVN0YXRzEicKD3RvdGFsX3RlbXBsYXRlcxgBIAEoBVIOdG90YWxUZW1wbGF0ZX'
    'MSLgoTdG90YWxfc3RvcmFnZV9ieXRlcxgCIAEoA1IRdG90YWxTdG9yYWdlQnl0ZXMSLQoScGVy'
    'c29uYWxfdGVtcGxhdGVzGAMgASgFUhFwZXJzb25hbFRlbXBsYXRlcxIjCg1vcmdfdGVtcGxhdG'
    'VzGAQgASgFUgxvcmdUZW1wbGF0ZXMSKwoRZXhwaXJlZF90ZW1wbGF0ZXMYBSABKAVSEGV4cGly'
    'ZWRUZW1wbGF0ZXMSXAoRdGVtcGxhdGVzX2J5X3VzZXIYBiADKAsyMC5kb3J5d2FsbC5odWIuVG'
    'VtcGxhdGVTdGF0cy5UZW1wbGF0ZXNCeVVzZXJFbnRyeVIPdGVtcGxhdGVzQnlVc2VyGkIKFFRl'
    'bXBsYXRlc0J5VXNlckVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgFUgV2YW'
    'x1ZToCOAE=');

@$core.Deprecated('Use deleteUserTemplatesRequestDescriptor instead')
const DeleteUserTemplatesRequest$json = {
  '1': 'DeleteUserTemplatesRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'expired_only', '3': 2, '4': 1, '5': 8, '10': 'expiredOnly'},
  ],
};

/// Descriptor for `DeleteUserTemplatesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteUserTemplatesRequestDescriptor =
    $convert.base64Decode(
        'ChpEZWxldGVVc2VyVGVtcGxhdGVzUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSIQ'
        'oMZXhwaXJlZF9vbmx5GAIgASgIUgtleHBpcmVkT25seQ==');

@$core.Deprecated('Use listPromoCodesRequestDescriptor instead')
const ListPromoCodesRequest$json = {
  '1': 'ListPromoCodesRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'include_expired', '3': 3, '4': 1, '5': 8, '10': 'includeExpired'},
  ],
};

/// Descriptor for `ListPromoCodesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPromoCodesRequestDescriptor = $convert.base64Decode(
    'ChVMaXN0UHJvbW9Db2Rlc1JlcXVlc3QSGwoJcGFnZV9zaXplGAEgASgFUghwYWdlU2l6ZRIdCg'
    'pwYWdlX3Rva2VuGAIgASgJUglwYWdlVG9rZW4SJwoPaW5jbHVkZV9leHBpcmVkGAMgASgIUg5p'
    'bmNsdWRlRXhwaXJlZA==');

@$core.Deprecated('Use listPromoCodesResponseDescriptor instead')
const ListPromoCodesResponse$json = {
  '1': 'ListPromoCodesResponse',
  '2': [
    {
      '1': 'codes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.PromoCode',
      '10': 'codes'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListPromoCodesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPromoCodesResponseDescriptor = $convert.base64Decode(
    'ChZMaXN0UHJvbW9Db2Rlc1Jlc3BvbnNlEi0KBWNvZGVzGAEgAygLMhcuZG9yeXdhbGwuaHViLl'
    'Byb21vQ29kZVIFY29kZXMSJgoPbmV4dF9wYWdlX3Rva2VuGAIgASgJUg1uZXh0UGFnZVRva2Vu'
    'Eh8KC3RvdGFsX2NvdW50GAMgASgFUgp0b3RhbENvdW50');

@$core.Deprecated('Use getMaintenanceStatusRequestDescriptor instead')
const GetMaintenanceStatusRequest$json = {
  '1': 'GetMaintenanceStatusRequest',
};

/// Descriptor for `GetMaintenanceStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMaintenanceStatusRequestDescriptor =
    $convert.base64Decode('ChtHZXRNYWludGVuYW5jZVN0YXR1c1JlcXVlc3Q=');

@$core.Deprecated('Use maintenanceStatusDescriptor instead')
const MaintenanceStatus$json = {
  '1': 'MaintenanceStatus',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'started_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startedAt'
    },
    {
      '1': 'expected_end',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expectedEnd'
    },
    {
      '1': 'reject_new_connections',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'rejectNewConnections'
    },
    {
      '1': 'allow_admin_access',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'allowAdminAccess'
    },
  ],
};

/// Descriptor for `MaintenanceStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List maintenanceStatusDescriptor = $convert.base64Decode(
    'ChFNYWludGVuYW5jZVN0YXR1cxIYCgdlbmFibGVkGAEgASgIUgdlbmFibGVkEhgKB21lc3NhZ2'
    'UYAiABKAlSB21lc3NhZ2USOQoKc3RhcnRlZF9hdBgDIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5U'
    'aW1lc3RhbXBSCXN0YXJ0ZWRBdBI9CgxleHBlY3RlZF9lbmQYBCABKAsyGi5nb29nbGUucHJvdG'
    '9idWYuVGltZXN0YW1wUgtleHBlY3RlZEVuZBI0ChZyZWplY3RfbmV3X2Nvbm5lY3Rpb25zGAUg'
    'ASgIUhRyZWplY3ROZXdDb25uZWN0aW9ucxIsChJhbGxvd19hZG1pbl9hY2Nlc3MYBiABKAhSEG'
    'FsbG93QWRtaW5BY2Nlc3M=');

@$core.Deprecated('Use setMaintenanceModeRequestDescriptor instead')
const SetMaintenanceModeRequest$json = {
  '1': 'SetMaintenanceModeRequest',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'duration_minutes', '3': 3, '4': 1, '5': 5, '10': 'durationMinutes'},
    {
      '1': 'reject_new_connections',
      '3': 4,
      '4': 1,
      '5': 8,
      '10': 'rejectNewConnections'
    },
  ],
};

/// Descriptor for `SetMaintenanceModeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setMaintenanceModeRequestDescriptor = $convert.base64Decode(
    'ChlTZXRNYWludGVuYW5jZU1vZGVSZXF1ZXN0EhgKB2VuYWJsZWQYASABKAhSB2VuYWJsZWQSGA'
    'oHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZRIpChBkdXJhdGlvbl9taW51dGVzGAMgASgFUg9kdXJh'
    'dGlvbk1pbnV0ZXMSNAoWcmVqZWN0X25ld19jb25uZWN0aW9ucxgEIAEoCFIUcmVqZWN0TmV3Q2'
    '9ubmVjdGlvbnM=');

@$core.Deprecated('Use broadcastAnnouncementRequestDescriptor instead')
const BroadcastAnnouncementRequest$json = {
  '1': 'BroadcastAnnouncementRequest',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'severity', '3': 3, '4': 1, '5': 9, '10': 'severity'},
    {'1': 'target_user_ids', '3': 4, '4': 3, '5': 9, '10': 'targetUserIds'},
    {'1': 'target_node_ids', '3': 5, '4': 3, '5': 9, '10': 'targetNodeIds'},
    {'1': 'persistent', '3': 6, '4': 1, '5': 8, '10': 'persistent'},
  ],
};

/// Descriptor for `BroadcastAnnouncementRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List broadcastAnnouncementRequestDescriptor = $convert.base64Decode(
    'ChxCcm9hZGNhc3RBbm5vdW5jZW1lbnRSZXF1ZXN0EhQKBXRpdGxlGAEgASgJUgV0aXRsZRIYCg'
    'dtZXNzYWdlGAIgASgJUgdtZXNzYWdlEhoKCHNldmVyaXR5GAMgASgJUghzZXZlcml0eRImCg90'
    'YXJnZXRfdXNlcl9pZHMYBCADKAlSDXRhcmdldFVzZXJJZHMSJgoPdGFyZ2V0X25vZGVfaWRzGA'
    'UgAygJUg10YXJnZXROb2RlSWRzEh4KCnBlcnNpc3RlbnQYBiABKAhSCnBlcnNpc3RlbnQ=');

@$core.Deprecated('Use broadcastAnnouncementResponseDescriptor instead')
const BroadcastAnnouncementResponse$json = {
  '1': 'BroadcastAnnouncementResponse',
  '2': [
    {'1': 'nodes_notified', '3': 1, '4': 1, '5': 5, '10': 'nodesNotified'},
    {'1': 'users_notified', '3': 2, '4': 1, '5': 5, '10': 'usersNotified'},
    {'1': 'devices_pushed', '3': 3, '4': 1, '5': 5, '10': 'devicesPushed'},
  ],
};

/// Descriptor for `BroadcastAnnouncementResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List broadcastAnnouncementResponseDescriptor =
    $convert.base64Decode(
        'Ch1Ccm9hZGNhc3RBbm5vdW5jZW1lbnRSZXNwb25zZRIlCg5ub2Rlc19ub3RpZmllZBgBIAEoBV'
        'INbm9kZXNOb3RpZmllZBIlCg51c2Vyc19ub3RpZmllZBgCIAEoBVINdXNlcnNOb3RpZmllZBIl'
        'Cg5kZXZpY2VzX3B1c2hlZBgDIAEoBVINZGV2aWNlc1B1c2hlZA==');

@$core.Deprecated('Use getActiveStreamsRequestDescriptor instead')
const GetActiveStreamsRequest$json = {
  '1': 'GetActiveStreamsRequest',
};

/// Descriptor for `GetActiveStreamsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getActiveStreamsRequestDescriptor =
    $convert.base64Decode('ChdHZXRBY3RpdmVTdHJlYW1zUmVxdWVzdA==');

@$core.Deprecated('Use activeStreamDescriptor instead')
const ActiveStream$json = {
  '1': 'ActiveStream',
  '2': [
    {'1': 'stream_id', '3': 1, '4': 1, '5': 9, '10': 'streamId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'node_id', '3': 3, '4': 1, '5': 9, '10': 'nodeId'},
    {'1': 'stream_type', '3': 4, '4': 1, '5': 9, '10': 'streamType'},
    {
      '1': 'started_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startedAt'
    },
    {'1': 'messages_sent', '3': 6, '4': 1, '5': 3, '10': 'messagesSent'},
    {
      '1': 'messages_received',
      '3': 7,
      '4': 1,
      '5': 3,
      '10': 'messagesReceived'
    },
    {'1': 'source_ip', '3': 8, '4': 1, '5': 9, '10': 'sourceIp'},
  ],
};

/// Descriptor for `ActiveStream`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activeStreamDescriptor = $convert.base64Decode(
    'CgxBY3RpdmVTdHJlYW0SGwoJc3RyZWFtX2lkGAEgASgJUghzdHJlYW1JZBIXCgd1c2VyX2lkGA'
    'IgASgJUgZ1c2VySWQSFwoHbm9kZV9pZBgDIAEoCVIGbm9kZUlkEh8KC3N0cmVhbV90eXBlGAQg'
    'ASgJUgpzdHJlYW1UeXBlEjkKCnN0YXJ0ZWRfYXQYBSABKAsyGi5nb29nbGUucHJvdG9idWYuVG'
    'ltZXN0YW1wUglzdGFydGVkQXQSIwoNbWVzc2FnZXNfc2VudBgGIAEoA1IMbWVzc2FnZXNTZW50'
    'EisKEW1lc3NhZ2VzX3JlY2VpdmVkGAcgASgDUhBtZXNzYWdlc1JlY2VpdmVkEhsKCXNvdXJjZV'
    '9pcBgIIAEoCVIIc291cmNlSXA=');

@$core.Deprecated('Use getActiveStreamsResponseDescriptor instead')
const GetActiveStreamsResponse$json = {
  '1': 'GetActiveStreamsResponse',
  '2': [
    {
      '1': 'streams',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.ActiveStream',
      '10': 'streams'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
    {
      '1': 'streams_by_type',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.GetActiveStreamsResponse.StreamsByTypeEntry',
      '10': 'streamsByType'
    },
  ],
  '3': [GetActiveStreamsResponse_StreamsByTypeEntry$json],
};

@$core.Deprecated('Use getActiveStreamsResponseDescriptor instead')
const GetActiveStreamsResponse_StreamsByTypeEntry$json = {
  '1': 'StreamsByTypeEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `GetActiveStreamsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getActiveStreamsResponseDescriptor = $convert.base64Decode(
    'ChhHZXRBY3RpdmVTdHJlYW1zUmVzcG9uc2USNAoHc3RyZWFtcxgBIAMoCzIaLmRvcnl3YWxsLm'
    'h1Yi5BY3RpdmVTdHJlYW1SB3N0cmVhbXMSHwoLdG90YWxfY291bnQYAiABKAVSCnRvdGFsQ291'
    'bnQSYQoPc3RyZWFtc19ieV90eXBlGAMgAygLMjkuZG9yeXdhbGwuaHViLkdldEFjdGl2ZVN0cm'
    'VhbXNSZXNwb25zZS5TdHJlYW1zQnlUeXBlRW50cnlSDXN0cmVhbXNCeVR5cGUaQAoSU3RyZWFt'
    'c0J5VHlwZUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgFUgV2YWx1ZToCOA'
    'E=');

@$core.Deprecated('Use getRateLimitStatusRequestDescriptor instead')
const GetRateLimitStatusRequest$json = {
  '1': 'GetRateLimitStatusRequest',
  '2': [
    {'1': 'filter_user_id', '3': 1, '4': 1, '5': 9, '10': 'filterUserId'},
    {'1': 'filter_tier', '3': 2, '4': 1, '5': 9, '10': 'filterTier'},
  ],
};

/// Descriptor for `GetRateLimitStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRateLimitStatusRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRSYXRlTGltaXRTdGF0dXNSZXF1ZXN0EiQKDmZpbHRlcl91c2VyX2lkGAEgASgJUgxmaW'
        'x0ZXJVc2VySWQSHwoLZmlsdGVyX3RpZXIYAiABKAlSCmZpbHRlclRpZXI=');

@$core.Deprecated('Use rateLimitEntryDescriptor instead')
const RateLimitEntry$json = {
  '1': 'RateLimitEntry',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'tier', '3': 2, '4': 1, '5': 9, '10': 'tier'},
    {
      '1': 'requests_per_second',
      '3': 3,
      '4': 1,
      '5': 5,
      '10': 'requestsPerSecond'
    },
    {'1': 'burst_size', '3': 4, '4': 1, '5': 5, '10': 'burstSize'},
    {'1': 'current_tokens', '3': 5, '4': 1, '5': 5, '10': 'currentTokens'},
    {
      '1': 'requests_last_minute',
      '3': 6,
      '4': 1,
      '5': 5,
      '10': 'requestsLastMinute'
    },
    {'1': 'throttled_count', '3': 7, '4': 1, '5': 5, '10': 'throttledCount'},
    {
      '1': 'last_request',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastRequest'
    },
  ],
};

/// Descriptor for `RateLimitEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rateLimitEntryDescriptor = $convert.base64Decode(
    'Cg5SYXRlTGltaXRFbnRyeRIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSEgoEdGllchgCIAEoCV'
    'IEdGllchIuChNyZXF1ZXN0c19wZXJfc2Vjb25kGAMgASgFUhFyZXF1ZXN0c1BlclNlY29uZBId'
    'CgpidXJzdF9zaXplGAQgASgFUglidXJzdFNpemUSJQoOY3VycmVudF90b2tlbnMYBSABKAVSDW'
    'N1cnJlbnRUb2tlbnMSMAoUcmVxdWVzdHNfbGFzdF9taW51dGUYBiABKAVSEnJlcXVlc3RzTGFz'
    'dE1pbnV0ZRInCg90aHJvdHRsZWRfY291bnQYByABKAVSDnRocm90dGxlZENvdW50Ej0KDGxhc3'
    'RfcmVxdWVzdBgIIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSC2xhc3RSZXF1ZXN0');

@$core.Deprecated('Use getRateLimitStatusResponseDescriptor instead')
const GetRateLimitStatusResponse$json = {
  '1': 'GetRateLimitStatusResponse',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.RateLimitEntry',
      '10': 'entries'
    },
    {
      '1': 'total_throttled_today',
      '3': 2,
      '4': 1,
      '5': 5,
      '10': 'totalThrottledToday'
    },
  ],
};

/// Descriptor for `GetRateLimitStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRateLimitStatusResponseDescriptor =
    $convert.base64Decode(
        'ChpHZXRSYXRlTGltaXRTdGF0dXNSZXNwb25zZRI2CgdlbnRyaWVzGAEgAygLMhwuZG9yeXdhbG'
        'wuaHViLlJhdGVMaW1pdEVudHJ5UgdlbnRyaWVzEjIKFXRvdGFsX3Rocm90dGxlZF90b2RheRgC'
        'IAEoBVITdG90YWxUaHJvdHRsZWRUb2RheQ==');

@$core.Deprecated('Use revokeCertificateRequestDescriptor instead')
const RevokeCertificateRequest$json = {
  '1': 'RevokeCertificateRequest',
  '2': [
    {'1': 'serial_number', '3': 1, '4': 1, '5': 9, '10': 'serialNumber'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'notify_nodes', '3': 3, '4': 1, '5': 8, '10': 'notifyNodes'},
  ],
};

/// Descriptor for `RevokeCertificateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeCertificateRequestDescriptor = $convert.base64Decode(
    'ChhSZXZva2VDZXJ0aWZpY2F0ZVJlcXVlc3QSIwoNc2VyaWFsX251bWJlchgBIAEoCVIMc2VyaW'
    'FsTnVtYmVyEhYKBnJlYXNvbhgCIAEoCVIGcmVhc29uEiEKDG5vdGlmeV9ub2RlcxgDIAEoCFIL'
    'bm90aWZ5Tm9kZXM=');

@$core.Deprecated('Use listInviteCodesRequestDescriptor instead')
const ListInviteCodesRequest$json = {
  '1': 'ListInviteCodesRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListInviteCodesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listInviteCodesRequestDescriptor =
    $convert.base64Decode(
        'ChZMaXN0SW52aXRlQ29kZXNSZXF1ZXN0EhsKCXBhZ2Vfc2l6ZRgBIAEoBVIIcGFnZVNpemUSHQ'
        'oKcGFnZV90b2tlbhgCIAEoCVIJcGFnZVRva2Vu');

@$core.Deprecated('Use listInviteCodesResponseDescriptor instead')
const ListInviteCodesResponse$json = {
  '1': 'ListInviteCodesResponse',
  '2': [
    {
      '1': 'codes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.InviteCode',
      '10': 'codes'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListInviteCodesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listInviteCodesResponseDescriptor = $convert.base64Decode(
    'ChdMaXN0SW52aXRlQ29kZXNSZXNwb25zZRIuCgVjb2RlcxgBIAMoCzIYLmRvcnl3YWxsLmh1Yi'
    '5JbnZpdGVDb2RlUgVjb2RlcxImCg9uZXh0X3BhZ2VfdG9rZW4YAiABKAlSDW5leHRQYWdlVG9r'
    'ZW4SHwoLdG90YWxfY291bnQYAyABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use dumpEncryptedBlobsRequestDescriptor instead')
const DumpEncryptedBlobsRequest$json = {
  '1': 'DumpEncryptedBlobsRequest',
  '2': [
    {'1': 'blob_type', '3': 1, '4': 1, '5': 9, '10': 'blobType'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'include_raw_bytes', '3': 3, '4': 1, '5': 8, '10': 'includeRawBytes'},
  ],
};

/// Descriptor for `DumpEncryptedBlobsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dumpEncryptedBlobsRequestDescriptor = $convert.base64Decode(
    'ChlEdW1wRW5jcnlwdGVkQmxvYnNSZXF1ZXN0EhsKCWJsb2JfdHlwZRgBIAEoCVIIYmxvYlR5cG'
    'USFAoFbGltaXQYAiABKAVSBWxpbWl0EioKEWluY2x1ZGVfcmF3X2J5dGVzGAMgASgIUg9pbmNs'
    'dWRlUmF3Qnl0ZXM=');

@$core.Deprecated('Use encryptedBlobInfoDescriptor instead')
const EncryptedBlobInfo$json = {
  '1': 'EncryptedBlobInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'owner_id', '3': 2, '4': 1, '5': 9, '10': 'ownerId'},
    {'1': 'blob_type', '3': 3, '4': 1, '5': 9, '10': 'blobType'},
    {'1': 'size_bytes', '3': 4, '4': 1, '5': 5, '10': 'sizeBytes'},
    {'1': 'raw_bytes', '3': 5, '4': 1, '5': 12, '10': 'rawBytes'},
    {
      '1': 'encryption_algorithm',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'encryptionAlgorithm'
    },
    {
      '1': 'created_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `EncryptedBlobInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List encryptedBlobInfoDescriptor = $convert.base64Decode(
    'ChFFbmNyeXB0ZWRCbG9iSW5mbxIOCgJpZBgBIAEoCVICaWQSGQoIb3duZXJfaWQYAiABKAlSB2'
    '93bmVySWQSGwoJYmxvYl90eXBlGAMgASgJUghibG9iVHlwZRIdCgpzaXplX2J5dGVzGAQgASgF'
    'UglzaXplQnl0ZXMSGwoJcmF3X2J5dGVzGAUgASgMUghyYXdCeXRlcxIxChRlbmNyeXB0aW9uX2'
    'FsZ29yaXRobRgGIAEoCVITZW5jcnlwdGlvbkFsZ29yaXRobRI5CgpjcmVhdGVkX2F0GAcgASgL'
    'MhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQYCC'
    'ABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQ=');

@$core.Deprecated('Use dumpEncryptedBlobsResponseDescriptor instead')
const DumpEncryptedBlobsResponse$json = {
  '1': 'DumpEncryptedBlobsResponse',
  '2': [
    {
      '1': 'blobs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.EncryptedBlobInfo',
      '10': 'blobs'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
    {'1': 'warning', '3': 3, '4': 1, '5': 9, '10': 'warning'},
  ],
};

/// Descriptor for `DumpEncryptedBlobsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dumpEncryptedBlobsResponseDescriptor =
    $convert.base64Decode(
        'ChpEdW1wRW5jcnlwdGVkQmxvYnNSZXNwb25zZRI1CgVibG9icxgBIAMoCzIfLmRvcnl3YWxsLm'
        'h1Yi5FbmNyeXB0ZWRCbG9iSW5mb1IFYmxvYnMSHwoLdG90YWxfY291bnQYAiABKAVSCnRvdGFs'
        'Q291bnQSGAoHd2FybmluZxgDIAEoCVIHd2FybmluZw==');

@$core.Deprecated('Use getBlindIndicesRequestDescriptor instead')
const GetBlindIndicesRequest$json = {
  '1': 'GetBlindIndicesRequest',
  '2': [
    {'1': 'filter_type', '3': 1, '4': 1, '5': 9, '10': 'filterType'},
  ],
};

/// Descriptor for `GetBlindIndicesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlindIndicesRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRCbGluZEluZGljZXNSZXF1ZXN0Eh8KC2ZpbHRlcl90eXBlGAEgASgJUgpmaWx0ZXJUeX'
        'Bl');

@$core.Deprecated('Use blindIndexInfoDescriptor instead')
const BlindIndexInfo$json = {
  '1': 'BlindIndexInfo',
  '2': [
    {'1': 'index_hash', '3': 1, '4': 1, '5': 9, '10': 'indexHash'},
    {'1': 'owner_type', '3': 2, '4': 1, '5': 9, '10': 'ownerType'},
    {'1': 'owner_id', '3': 3, '4': 1, '5': 9, '10': 'ownerId'},
    {'1': 'reference_count', '3': 4, '4': 1, '5': 5, '10': 'referenceCount'},
    {
      '1': 'first_seen',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'firstSeen'
    },
    {
      '1': 'last_used',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastUsed'
    },
  ],
};

/// Descriptor for `BlindIndexInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blindIndexInfoDescriptor = $convert.base64Decode(
    'Cg5CbGluZEluZGV4SW5mbxIdCgppbmRleF9oYXNoGAEgASgJUglpbmRleEhhc2gSHQoKb3duZX'
    'JfdHlwZRgCIAEoCVIJb3duZXJUeXBlEhkKCG93bmVyX2lkGAMgASgJUgdvd25lcklkEicKD3Jl'
    'ZmVyZW5jZV9jb3VudBgEIAEoBVIOcmVmZXJlbmNlQ291bnQSOQoKZmlyc3Rfc2VlbhgFIAEoCz'
    'IaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWZpcnN0U2VlbhI3CglsYXN0X3VzZWQYBiAB'
    'KAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUghsYXN0VXNlZA==');

@$core.Deprecated('Use getBlindIndicesResponseDescriptor instead')
const GetBlindIndicesResponse$json = {
  '1': 'GetBlindIndicesResponse',
  '2': [
    {
      '1': 'indices',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.nitella.hub.BlindIndexInfo',
      '10': 'indices'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
    {'1': 'warning', '3': 3, '4': 1, '5': 9, '10': 'warning'},
  ],
};

/// Descriptor for `GetBlindIndicesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlindIndicesResponseDescriptor = $convert.base64Decode(
    'ChdHZXRCbGluZEluZGljZXNSZXNwb25zZRI2CgdpbmRpY2VzGAEgAygLMhwuZG9yeXdhbGwuaH'
    'ViLkJsaW5kSW5kZXhJbmZvUgdpbmRpY2VzEh8KC3RvdGFsX2NvdW50GAIgASgFUgp0b3RhbENv'
    'dW50EhgKB3dhcm5pbmcYAyABKAlSB3dhcm5pbmc=');
