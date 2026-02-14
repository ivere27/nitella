// This is a generated file - do not edit.
//
// Generated from local/nitella_local.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class GeoStatsType extends $pb.ProtobufEnum {
  static const GeoStatsType GEO_STATS_TYPE_UNSPECIFIED =
      GeoStatsType._(0, _omitEnumNames ? '' : 'GEO_STATS_TYPE_UNSPECIFIED');
  static const GeoStatsType GEO_STATS_TYPE_COUNTRY =
      GeoStatsType._(1, _omitEnumNames ? '' : 'GEO_STATS_TYPE_COUNTRY');
  static const GeoStatsType GEO_STATS_TYPE_CITY =
      GeoStatsType._(2, _omitEnumNames ? '' : 'GEO_STATS_TYPE_CITY');
  static const GeoStatsType GEO_STATS_TYPE_ISP =
      GeoStatsType._(3, _omitEnumNames ? '' : 'GEO_STATS_TYPE_ISP');

  static const $core.List<GeoStatsType> values = <GeoStatsType>[
    GEO_STATS_TYPE_UNSPECIFIED,
    GEO_STATS_TYPE_COUNTRY,
    GEO_STATS_TYPE_CITY,
    GEO_STATS_TYPE_ISP,
  ];

  static final $core.List<GeoStatsType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static GeoStatsType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GeoStatsType._(super.value, super.name);
}

class Theme extends $pb.ProtobufEnum {
  static const Theme THEME_UNSPECIFIED =
      Theme._(0, _omitEnumNames ? '' : 'THEME_UNSPECIFIED');
  static const Theme THEME_LIGHT =
      Theme._(1, _omitEnumNames ? '' : 'THEME_LIGHT');
  static const Theme THEME_DARK =
      Theme._(2, _omitEnumNames ? '' : 'THEME_DARK');
  static const Theme THEME_SYSTEM =
      Theme._(3, _omitEnumNames ? '' : 'THEME_SYSTEM');

  static const $core.List<Theme> values = <Theme>[
    THEME_UNSPECIFIED,
    THEME_LIGHT,
    THEME_DARK,
    THEME_SYSTEM,
  ];

  static final $core.List<Theme?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Theme? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Theme._(super.value, super.name);
}

class AlertSeverity extends $pb.ProtobufEnum {
  static const AlertSeverity ALERT_SEVERITY_UNSPECIFIED =
      AlertSeverity._(0, _omitEnumNames ? '' : 'ALERT_SEVERITY_UNSPECIFIED');
  static const AlertSeverity ALERT_SEVERITY_INFO =
      AlertSeverity._(1, _omitEnumNames ? '' : 'ALERT_SEVERITY_INFO');
  static const AlertSeverity ALERT_SEVERITY_WARNING =
      AlertSeverity._(2, _omitEnumNames ? '' : 'ALERT_SEVERITY_WARNING');
  static const AlertSeverity ALERT_SEVERITY_CRITICAL =
      AlertSeverity._(3, _omitEnumNames ? '' : 'ALERT_SEVERITY_CRITICAL');

  static const $core.List<AlertSeverity> values = <AlertSeverity>[
    ALERT_SEVERITY_UNSPECIFIED,
    ALERT_SEVERITY_INFO,
    ALERT_SEVERITY_WARNING,
    ALERT_SEVERITY_CRITICAL,
  ];

  static final $core.List<AlertSeverity?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static AlertSeverity? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AlertSeverity._(super.value, super.name);
}

class ToastType extends $pb.ProtobufEnum {
  static const ToastType TOAST_TYPE_UNSPECIFIED =
      ToastType._(0, _omitEnumNames ? '' : 'TOAST_TYPE_UNSPECIFIED');
  static const ToastType TOAST_TYPE_INFO =
      ToastType._(1, _omitEnumNames ? '' : 'TOAST_TYPE_INFO');
  static const ToastType TOAST_TYPE_SUCCESS =
      ToastType._(2, _omitEnumNames ? '' : 'TOAST_TYPE_SUCCESS');
  static const ToastType TOAST_TYPE_WARNING =
      ToastType._(3, _omitEnumNames ? '' : 'TOAST_TYPE_WARNING');
  static const ToastType TOAST_TYPE_ERROR =
      ToastType._(4, _omitEnumNames ? '' : 'TOAST_TYPE_ERROR');

  static const $core.List<ToastType> values = <ToastType>[
    TOAST_TYPE_UNSPECIFIED,
    TOAST_TYPE_INFO,
    TOAST_TYPE_SUCCESS,
    TOAST_TYPE_WARNING,
    TOAST_TYPE_ERROR,
  ];

  static final $core.List<ToastType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static ToastType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ToastType._(super.value, super.name);
}

class DeviceType extends $pb.ProtobufEnum {
  static const DeviceType DEVICE_TYPE_UNSPECIFIED =
      DeviceType._(0, _omitEnumNames ? '' : 'DEVICE_TYPE_UNSPECIFIED');
  static const DeviceType DEVICE_TYPE_ANDROID =
      DeviceType._(1, _omitEnumNames ? '' : 'DEVICE_TYPE_ANDROID');
  static const DeviceType DEVICE_TYPE_IOS =
      DeviceType._(2, _omitEnumNames ? '' : 'DEVICE_TYPE_IOS');

  static const $core.List<DeviceType> values = <DeviceType>[
    DEVICE_TYPE_UNSPECIFIED,
    DEVICE_TYPE_ANDROID,
    DEVICE_TYPE_IOS,
  ];

  static final $core.List<DeviceType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static DeviceType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DeviceType._(super.value, super.name);
}

class BootstrapStage extends $pb.ProtobufEnum {
  static const BootstrapStage BOOTSTRAP_STAGE_UNSPECIFIED =
      BootstrapStage._(0, _omitEnumNames ? '' : 'BOOTSTRAP_STAGE_UNSPECIFIED');
  static const BootstrapStage BOOTSTRAP_STAGE_SETUP_NEEDED =
      BootstrapStage._(1, _omitEnumNames ? '' : 'BOOTSTRAP_STAGE_SETUP_NEEDED');
  static const BootstrapStage BOOTSTRAP_STAGE_AUTH_NEEDED =
      BootstrapStage._(2, _omitEnumNames ? '' : 'BOOTSTRAP_STAGE_AUTH_NEEDED');
  static const BootstrapStage BOOTSTRAP_STAGE_READY =
      BootstrapStage._(3, _omitEnumNames ? '' : 'BOOTSTRAP_STAGE_READY');

  static const $core.List<BootstrapStage> values = <BootstrapStage>[
    BOOTSTRAP_STAGE_UNSPECIFIED,
    BOOTSTRAP_STAGE_SETUP_NEEDED,
    BOOTSTRAP_STAGE_AUTH_NEEDED,
    BOOTSTRAP_STAGE_READY,
  ];

  static final $core.List<BootstrapStage?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static BootstrapStage? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const BootstrapStage._(super.value, super.name);
}

class PassphraseStrength extends $pb.ProtobufEnum {
  static const PassphraseStrength PASSPHRASE_STRENGTH_UNSPECIFIED =
      PassphraseStrength._(
          0, _omitEnumNames ? '' : 'PASSPHRASE_STRENGTH_UNSPECIFIED');
  static const PassphraseStrength PASSPHRASE_STRENGTH_WEAK =
      PassphraseStrength._(1, _omitEnumNames ? '' : 'PASSPHRASE_STRENGTH_WEAK');
  static const PassphraseStrength PASSPHRASE_STRENGTH_FAIR =
      PassphraseStrength._(2, _omitEnumNames ? '' : 'PASSPHRASE_STRENGTH_FAIR');
  static const PassphraseStrength PASSPHRASE_STRENGTH_STRONG =
      PassphraseStrength._(
          3, _omitEnumNames ? '' : 'PASSPHRASE_STRENGTH_STRONG');

  static const $core.List<PassphraseStrength> values = <PassphraseStrength>[
    PASSPHRASE_STRENGTH_UNSPECIFIED,
    PASSPHRASE_STRENGTH_WEAK,
    PASSPHRASE_STRENGTH_FAIR,
    PASSPHRASE_STRENGTH_STRONG,
  ];

  static final $core.List<PassphraseStrength?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static PassphraseStrength? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PassphraseStrength._(super.value, super.name);
}

/// NodeConnectionType specifies how the mobile app connects to a node.
class NodeConnectionType extends $pb.ProtobufEnum {
  static const NodeConnectionType NODE_CONNECTION_TYPE_UNSPECIFIED =
      NodeConnectionType._(
          0, _omitEnumNames ? '' : 'NODE_CONNECTION_TYPE_UNSPECIFIED');
  static const NodeConnectionType NODE_CONNECTION_TYPE_HUB =
      NodeConnectionType._(1, _omitEnumNames ? '' : 'NODE_CONNECTION_TYPE_HUB');
  static const NodeConnectionType NODE_CONNECTION_TYPE_DIRECT =
      NodeConnectionType._(
          2, _omitEnumNames ? '' : 'NODE_CONNECTION_TYPE_DIRECT');

  static const $core.List<NodeConnectionType> values = <NodeConnectionType>[
    NODE_CONNECTION_TYPE_UNSPECIFIED,
    NODE_CONNECTION_TYPE_HUB,
    NODE_CONNECTION_TYPE_DIRECT,
  ];

  static final $core.List<NodeConnectionType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static NodeConnectionType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NodeConnectionType._(super.value, super.name);
}

class DenyBlockType extends $pb.ProtobufEnum {
  static const DenyBlockType DENY_BLOCK_TYPE_NONE =
      DenyBlockType._(0, _omitEnumNames ? '' : 'DENY_BLOCK_TYPE_NONE');
  static const DenyBlockType DENY_BLOCK_TYPE_IP =
      DenyBlockType._(1, _omitEnumNames ? '' : 'DENY_BLOCK_TYPE_IP');
  static const DenyBlockType DENY_BLOCK_TYPE_ISP =
      DenyBlockType._(2, _omitEnumNames ? '' : 'DENY_BLOCK_TYPE_ISP');

  static const $core.List<DenyBlockType> values = <DenyBlockType>[
    DENY_BLOCK_TYPE_NONE,
    DENY_BLOCK_TYPE_IP,
    DENY_BLOCK_TYPE_ISP,
  ];

  static final $core.List<DenyBlockType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static DenyBlockType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DenyBlockType._(super.value, super.name);
}

class ApprovalDecision extends $pb.ProtobufEnum {
  static const ApprovalDecision APPROVAL_DECISION_UNSPECIFIED =
      ApprovalDecision._(
          0, _omitEnumNames ? '' : 'APPROVAL_DECISION_UNSPECIFIED');
  static const ApprovalDecision APPROVAL_DECISION_APPROVE =
      ApprovalDecision._(1, _omitEnumNames ? '' : 'APPROVAL_DECISION_APPROVE');
  static const ApprovalDecision APPROVAL_DECISION_DENY =
      ApprovalDecision._(2, _omitEnumNames ? '' : 'APPROVAL_DECISION_DENY');

  static const $core.List<ApprovalDecision> values = <ApprovalDecision>[
    APPROVAL_DECISION_UNSPECIFIED,
    APPROVAL_DECISION_APPROVE,
    APPROVAL_DECISION_DENY,
  ];

  static final $core.List<ApprovalDecision?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ApprovalDecision? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ApprovalDecision._(super.value, super.name);
}

class ApprovalHistoryAction extends $pb.ProtobufEnum {
  static const ApprovalHistoryAction APPROVAL_HISTORY_ACTION_UNSPECIFIED =
      ApprovalHistoryAction._(
          0, _omitEnumNames ? '' : 'APPROVAL_HISTORY_ACTION_UNSPECIFIED');
  static const ApprovalHistoryAction APPROVAL_HISTORY_ACTION_APPROVED =
      ApprovalHistoryAction._(
          1, _omitEnumNames ? '' : 'APPROVAL_HISTORY_ACTION_APPROVED');
  static const ApprovalHistoryAction APPROVAL_HISTORY_ACTION_DENIED =
      ApprovalHistoryAction._(
          2, _omitEnumNames ? '' : 'APPROVAL_HISTORY_ACTION_DENIED');
  static const ApprovalHistoryAction APPROVAL_HISTORY_ACTION_EXPIRED =
      ApprovalHistoryAction._(
          3, _omitEnumNames ? '' : 'APPROVAL_HISTORY_ACTION_EXPIRED');

  static const $core.List<ApprovalHistoryAction> values =
      <ApprovalHistoryAction>[
    APPROVAL_HISTORY_ACTION_UNSPECIFIED,
    APPROVAL_HISTORY_ACTION_APPROVED,
    APPROVAL_HISTORY_ACTION_DENIED,
    APPROVAL_HISTORY_ACTION_EXPIRED,
  ];

  static final $core.List<ApprovalHistoryAction?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ApprovalHistoryAction? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ApprovalHistoryAction._(super.value, super.name);
}

class ConnectionEvent_EventType extends $pb.ProtobufEnum {
  static const ConnectionEvent_EventType EVENT_TYPE_UNSPECIFIED =
      ConnectionEvent_EventType._(
          0, _omitEnumNames ? '' : 'EVENT_TYPE_UNSPECIFIED');
  static const ConnectionEvent_EventType EVENT_TYPE_CONNECTED =
      ConnectionEvent_EventType._(
          1, _omitEnumNames ? '' : 'EVENT_TYPE_CONNECTED');
  static const ConnectionEvent_EventType EVENT_TYPE_CLOSED =
      ConnectionEvent_EventType._(2, _omitEnumNames ? '' : 'EVENT_TYPE_CLOSED');
  static const ConnectionEvent_EventType EVENT_TYPE_BLOCKED =
      ConnectionEvent_EventType._(
          3, _omitEnumNames ? '' : 'EVENT_TYPE_BLOCKED');
  static const ConnectionEvent_EventType EVENT_TYPE_PENDING_APPROVAL =
      ConnectionEvent_EventType._(
          4, _omitEnumNames ? '' : 'EVENT_TYPE_PENDING_APPROVAL');
  static const ConnectionEvent_EventType EVENT_TYPE_APPROVED =
      ConnectionEvent_EventType._(
          5, _omitEnumNames ? '' : 'EVENT_TYPE_APPROVED');

  static const $core.List<ConnectionEvent_EventType> values =
      <ConnectionEvent_EventType>[
    EVENT_TYPE_UNSPECIFIED,
    EVENT_TYPE_CONNECTED,
    EVENT_TYPE_CLOSED,
    EVENT_TYPE_BLOCKED,
    EVENT_TYPE_PENDING_APPROVAL,
    EVENT_TYPE_APPROVED,
  ];

  static final $core.List<ConnectionEvent_EventType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static ConnectionEvent_EventType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ConnectionEvent_EventType._(super.value, super.name);
}

class OnboardHubResponse_Stage extends $pb.ProtobufEnum {
  static const OnboardHubResponse_Stage STAGE_UNSPECIFIED =
      OnboardHubResponse_Stage._(0, _omitEnumNames ? '' : 'STAGE_UNSPECIFIED');
  static const OnboardHubResponse_Stage STAGE_COMPLETED =
      OnboardHubResponse_Stage._(1, _omitEnumNames ? '' : 'STAGE_COMPLETED');
  static const OnboardHubResponse_Stage STAGE_NEEDS_TRUST =
      OnboardHubResponse_Stage._(2, _omitEnumNames ? '' : 'STAGE_NEEDS_TRUST');
  static const OnboardHubResponse_Stage STAGE_FAILED =
      OnboardHubResponse_Stage._(3, _omitEnumNames ? '' : 'STAGE_FAILED');

  static const $core.List<OnboardHubResponse_Stage> values =
      <OnboardHubResponse_Stage>[
    STAGE_UNSPECIFIED,
    STAGE_COMPLETED,
    STAGE_NEEDS_TRUST,
    STAGE_FAILED,
  ];

  static final $core.List<OnboardHubResponse_Stage?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static OnboardHubResponse_Stage? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const OnboardHubResponse_Stage._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
