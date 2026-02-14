// This is a generated file - do not edit.
//
// Generated from hub/hub_common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class RegistrationStatus extends $pb.ProtobufEnum {
  static const RegistrationStatus REGISTRATION_STATUS_UNSPECIFIED =
      RegistrationStatus._(
          0, _omitEnumNames ? '' : 'REGISTRATION_STATUS_UNSPECIFIED');
  static const RegistrationStatus REGISTRATION_STATUS_PENDING =
      RegistrationStatus._(
          1, _omitEnumNames ? '' : 'REGISTRATION_STATUS_PENDING');
  static const RegistrationStatus REGISTRATION_STATUS_APPROVED =
      RegistrationStatus._(
          2, _omitEnumNames ? '' : 'REGISTRATION_STATUS_APPROVED');
  static const RegistrationStatus REGISTRATION_STATUS_REJECTED =
      RegistrationStatus._(
          3, _omitEnumNames ? '' : 'REGISTRATION_STATUS_REJECTED');

  static const $core.List<RegistrationStatus> values = <RegistrationStatus>[
    REGISTRATION_STATUS_UNSPECIFIED,
    REGISTRATION_STATUS_PENDING,
    REGISTRATION_STATUS_APPROVED,
    REGISTRATION_STATUS_REJECTED,
  ];

  static final $core.List<RegistrationStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static RegistrationStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const RegistrationStatus._(super.value, super.name);
}

class NodeStatus extends $pb.ProtobufEnum {
  static const NodeStatus NODE_STATUS_UNSPECIFIED =
      NodeStatus._(0, _omitEnumNames ? '' : 'NODE_STATUS_UNSPECIFIED');
  static const NodeStatus NODE_STATUS_OFFLINE =
      NodeStatus._(1, _omitEnumNames ? '' : 'NODE_STATUS_OFFLINE');
  static const NodeStatus NODE_STATUS_ONLINE =
      NodeStatus._(2, _omitEnumNames ? '' : 'NODE_STATUS_ONLINE');
  static const NodeStatus NODE_STATUS_BLOCKED =
      NodeStatus._(3, _omitEnumNames ? '' : 'NODE_STATUS_BLOCKED');
  static const NodeStatus NODE_STATUS_CONNECTING =
      NodeStatus._(4, _omitEnumNames ? '' : 'NODE_STATUS_CONNECTING');

  static const $core.List<NodeStatus> values = <NodeStatus>[
    NODE_STATUS_UNSPECIFIED,
    NODE_STATUS_OFFLINE,
    NODE_STATUS_ONLINE,
    NODE_STATUS_BLOCKED,
    NODE_STATUS_CONNECTING,
  ];

  static final $core.List<NodeStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static NodeStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NodeStatus._(super.value, super.name);
}

class CommandType extends $pb.ProtobufEnum {
  static const CommandType COMMAND_TYPE_UNSPECIFIED =
      CommandType._(0, _omitEnumNames ? '' : 'COMMAND_TYPE_UNSPECIFIED');
  static const CommandType COMMAND_TYPE_ADD_RULE =
      CommandType._(2, _omitEnumNames ? '' : 'COMMAND_TYPE_ADD_RULE');
  static const CommandType COMMAND_TYPE_REMOVE_RULE =
      CommandType._(3, _omitEnumNames ? '' : 'COMMAND_TYPE_REMOVE_RULE');
  static const CommandType COMMAND_TYPE_GET_ACTIVE_CONNECTIONS = CommandType._(
      4, _omitEnumNames ? '' : 'COMMAND_TYPE_GET_ACTIVE_CONNECTIONS');
  static const CommandType COMMAND_TYPE_CLOSE_CONNECTION =
      CommandType._(5, _omitEnumNames ? '' : 'COMMAND_TYPE_CLOSE_CONNECTION');
  static const CommandType COMMAND_TYPE_CLOSE_ALL_CONNECTIONS = CommandType._(
      6, _omitEnumNames ? '' : 'COMMAND_TYPE_CLOSE_ALL_CONNECTIONS');
  static const CommandType COMMAND_TYPE_STATS_CONTROL =
      CommandType._(7, _omitEnumNames ? '' : 'COMMAND_TYPE_STATS_CONTROL');
  static const CommandType COMMAND_TYPE_LIST_PROXIES =
      CommandType._(8, _omitEnumNames ? '' : 'COMMAND_TYPE_LIST_PROXIES');
  static const CommandType COMMAND_TYPE_LIST_RULES =
      CommandType._(9, _omitEnumNames ? '' : 'COMMAND_TYPE_LIST_RULES');
  static const CommandType COMMAND_TYPE_STATUS =
      CommandType._(10, _omitEnumNames ? '' : 'COMMAND_TYPE_STATUS');
  static const CommandType COMMAND_TYPE_GET_METRICS =
      CommandType._(11, _omitEnumNames ? '' : 'COMMAND_TYPE_GET_METRICS');

  /// Proxy Template Management
  static const CommandType COMMAND_TYPE_APPLY_PROXY =
      CommandType._(20, _omitEnumNames ? '' : 'COMMAND_TYPE_APPLY_PROXY');
  static const CommandType COMMAND_TYPE_UNAPPLY_PROXY =
      CommandType._(21, _omitEnumNames ? '' : 'COMMAND_TYPE_UNAPPLY_PROXY');
  static const CommandType COMMAND_TYPE_GET_APPLIED =
      CommandType._(22, _omitEnumNames ? '' : 'COMMAND_TYPE_GET_APPLIED');
  static const CommandType COMMAND_TYPE_PROXY_UPDATE =
      CommandType._(23, _omitEnumNames ? '' : 'COMMAND_TYPE_PROXY_UPDATE');

  /// Approval Workflow
  static const CommandType COMMAND_TYPE_RESOLVE_APPROVAL =
      CommandType._(30, _omitEnumNames ? '' : 'COMMAND_TYPE_RESOLVE_APPROVAL');

  /// Proxy Lifecycle (Direct gRPC SecureCommand)
  static const CommandType COMMAND_TYPE_CREATE_PROXY =
      CommandType._(40, _omitEnumNames ? '' : 'COMMAND_TYPE_CREATE_PROXY');
  static const CommandType COMMAND_TYPE_DELETE_PROXY =
      CommandType._(41, _omitEnumNames ? '' : 'COMMAND_TYPE_DELETE_PROXY');
  static const CommandType COMMAND_TYPE_ENABLE_PROXY =
      CommandType._(42, _omitEnumNames ? '' : 'COMMAND_TYPE_ENABLE_PROXY');
  static const CommandType COMMAND_TYPE_DISABLE_PROXY =
      CommandType._(43, _omitEnumNames ? '' : 'COMMAND_TYPE_DISABLE_PROXY');
  static const CommandType COMMAND_TYPE_UPDATE_PROXY =
      CommandType._(44, _omitEnumNames ? '' : 'COMMAND_TYPE_UPDATE_PROXY');
  static const CommandType COMMAND_TYPE_RESTART_LISTENERS =
      CommandType._(45, _omitEnumNames ? '' : 'COMMAND_TYPE_RESTART_LISTENERS');
  static const CommandType COMMAND_TYPE_RELOAD_RULES =
      CommandType._(46, _omitEnumNames ? '' : 'COMMAND_TYPE_RELOAD_RULES');

  /// Quick Actions (Direct gRPC SecureCommand)
  static const CommandType COMMAND_TYPE_BLOCK_IP =
      CommandType._(50, _omitEnumNames ? '' : 'COMMAND_TYPE_BLOCK_IP');
  static const CommandType COMMAND_TYPE_ALLOW_IP =
      CommandType._(51, _omitEnumNames ? '' : 'COMMAND_TYPE_ALLOW_IP');
  static const CommandType COMMAND_TYPE_LIST_GLOBAL_RULES =
      CommandType._(52, _omitEnumNames ? '' : 'COMMAND_TYPE_LIST_GLOBAL_RULES');
  static const CommandType COMMAND_TYPE_REMOVE_GLOBAL_RULE = CommandType._(
      53, _omitEnumNames ? '' : 'COMMAND_TYPE_REMOVE_GLOBAL_RULE');

  /// GeoIP (Direct gRPC SecureCommand)
  static const CommandType COMMAND_TYPE_CONFIGURE_GEOIP =
      CommandType._(60, _omitEnumNames ? '' : 'COMMAND_TYPE_CONFIGURE_GEOIP');
  static const CommandType COMMAND_TYPE_GET_GEOIP_STATUS =
      CommandType._(61, _omitEnumNames ? '' : 'COMMAND_TYPE_GET_GEOIP_STATUS');
  static const CommandType COMMAND_TYPE_LOOKUP_IP =
      CommandType._(62, _omitEnumNames ? '' : 'COMMAND_TYPE_LOOKUP_IP');

  /// Approval Management (Direct gRPC SecureCommand)
  static const CommandType COMMAND_TYPE_LIST_ACTIVE_APPROVALS = CommandType._(
      70, _omitEnumNames ? '' : 'COMMAND_TYPE_LIST_ACTIVE_APPROVALS');
  static const CommandType COMMAND_TYPE_CANCEL_APPROVAL =
      CommandType._(71, _omitEnumNames ? '' : 'COMMAND_TYPE_CANCEL_APPROVAL');

  static const $core.List<CommandType> values = <CommandType>[
    COMMAND_TYPE_UNSPECIFIED,
    COMMAND_TYPE_ADD_RULE,
    COMMAND_TYPE_REMOVE_RULE,
    COMMAND_TYPE_GET_ACTIVE_CONNECTIONS,
    COMMAND_TYPE_CLOSE_CONNECTION,
    COMMAND_TYPE_CLOSE_ALL_CONNECTIONS,
    COMMAND_TYPE_STATS_CONTROL,
    COMMAND_TYPE_LIST_PROXIES,
    COMMAND_TYPE_LIST_RULES,
    COMMAND_TYPE_STATUS,
    COMMAND_TYPE_GET_METRICS,
    COMMAND_TYPE_APPLY_PROXY,
    COMMAND_TYPE_UNAPPLY_PROXY,
    COMMAND_TYPE_GET_APPLIED,
    COMMAND_TYPE_PROXY_UPDATE,
    COMMAND_TYPE_RESOLVE_APPROVAL,
    COMMAND_TYPE_CREATE_PROXY,
    COMMAND_TYPE_DELETE_PROXY,
    COMMAND_TYPE_ENABLE_PROXY,
    COMMAND_TYPE_DISABLE_PROXY,
    COMMAND_TYPE_UPDATE_PROXY,
    COMMAND_TYPE_RESTART_LISTENERS,
    COMMAND_TYPE_RELOAD_RULES,
    COMMAND_TYPE_BLOCK_IP,
    COMMAND_TYPE_ALLOW_IP,
    COMMAND_TYPE_LIST_GLOBAL_RULES,
    COMMAND_TYPE_REMOVE_GLOBAL_RULE,
    COMMAND_TYPE_CONFIGURE_GEOIP,
    COMMAND_TYPE_GET_GEOIP_STATUS,
    COMMAND_TYPE_LOOKUP_IP,
    COMMAND_TYPE_LIST_ACTIVE_APPROVALS,
    COMMAND_TYPE_CANCEL_APPROVAL,
  ];

  static final $core.Map<$core.int, CommandType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static CommandType? valueOf($core.int value) => _byValue[value];

  const CommandType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
