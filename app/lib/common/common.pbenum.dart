// This is a generated file - do not edit.
//
// Generated from common/common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// ActionType defines the possible actions for rules and defaults
class ActionType extends $pb.ProtobufEnum {
  static const ActionType ACTION_TYPE_UNSPECIFIED =
      ActionType._(0, _omitEnumNames ? '' : 'ACTION_TYPE_UNSPECIFIED');
  static const ActionType ACTION_TYPE_ALLOW =
      ActionType._(1, _omitEnumNames ? '' : 'ACTION_TYPE_ALLOW');
  static const ActionType ACTION_TYPE_BLOCK =
      ActionType._(2, _omitEnumNames ? '' : 'ACTION_TYPE_BLOCK');
  static const ActionType ACTION_TYPE_MOCK =
      ActionType._(3, _omitEnumNames ? '' : 'ACTION_TYPE_MOCK');
  static const ActionType ACTION_TYPE_REQUIRE_APPROVAL =
      ActionType._(4, _omitEnumNames ? '' : 'ACTION_TYPE_REQUIRE_APPROVAL');

  static const $core.List<ActionType> values = <ActionType>[
    ACTION_TYPE_UNSPECIFIED,
    ACTION_TYPE_ALLOW,
    ACTION_TYPE_BLOCK,
    ACTION_TYPE_MOCK,
    ACTION_TYPE_REQUIRE_APPROVAL,
  ];

  static final $core.List<ActionType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static ActionType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ActionType._(super.value, super.name);
}

/// FallbackAction defines what to do when a primary action fails or is not applicable
class FallbackAction extends $pb.ProtobufEnum {
  static const FallbackAction FALLBACK_ACTION_UNSPECIFIED =
      FallbackAction._(0, _omitEnumNames ? '' : 'FALLBACK_ACTION_UNSPECIFIED');
  static const FallbackAction FALLBACK_ACTION_CLOSE =
      FallbackAction._(1, _omitEnumNames ? '' : 'FALLBACK_ACTION_CLOSE');
  static const FallbackAction FALLBACK_ACTION_MOCK =
      FallbackAction._(2, _omitEnumNames ? '' : 'FALLBACK_ACTION_MOCK');

  static const $core.List<FallbackAction> values = <FallbackAction>[
    FALLBACK_ACTION_UNSPECIFIED,
    FALLBACK_ACTION_CLOSE,
    FALLBACK_ACTION_MOCK,
  ];

  static final $core.List<FallbackAction?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static FallbackAction? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FallbackAction._(super.value, super.name);
}

/// MockPreset defines pre-configured mock responses
class MockPreset extends $pb.ProtobufEnum {
  static const MockPreset MOCK_PRESET_UNSPECIFIED =
      MockPreset._(0, _omitEnumNames ? '' : 'MOCK_PRESET_UNSPECIFIED');
  static const MockPreset MOCK_PRESET_SSH_SECURE =
      MockPreset._(1, _omitEnumNames ? '' : 'MOCK_PRESET_SSH_SECURE');
  static const MockPreset MOCK_PRESET_SSH_TARPIT =
      MockPreset._(2, _omitEnumNames ? '' : 'MOCK_PRESET_SSH_TARPIT');
  static const MockPreset MOCK_PRESET_HTTP_403 =
      MockPreset._(3, _omitEnumNames ? '' : 'MOCK_PRESET_HTTP_403');
  static const MockPreset MOCK_PRESET_HTTP_404 =
      MockPreset._(4, _omitEnumNames ? '' : 'MOCK_PRESET_HTTP_404');
  static const MockPreset MOCK_PRESET_HTTP_401 =
      MockPreset._(5, _omitEnumNames ? '' : 'MOCK_PRESET_HTTP_401');
  static const MockPreset MOCK_PRESET_REDIS_SECURE =
      MockPreset._(6, _omitEnumNames ? '' : 'MOCK_PRESET_REDIS_SECURE');
  static const MockPreset MOCK_PRESET_MYSQL_SECURE =
      MockPreset._(7, _omitEnumNames ? '' : 'MOCK_PRESET_MYSQL_SECURE');
  static const MockPreset MOCK_PRESET_MYSQL_TARPIT =
      MockPreset._(8, _omitEnumNames ? '' : 'MOCK_PRESET_MYSQL_TARPIT');
  static const MockPreset MOCK_PRESET_RDP_SECURE =
      MockPreset._(9, _omitEnumNames ? '' : 'MOCK_PRESET_RDP_SECURE');
  static const MockPreset MOCK_PRESET_TELNET_SECURE =
      MockPreset._(10, _omitEnumNames ? '' : 'MOCK_PRESET_TELNET_SECURE');
  static const MockPreset MOCK_PRESET_RAW_TARPIT =
      MockPreset._(11, _omitEnumNames ? '' : 'MOCK_PRESET_RAW_TARPIT');

  static const $core.List<MockPreset> values = <MockPreset>[
    MOCK_PRESET_UNSPECIFIED,
    MOCK_PRESET_SSH_SECURE,
    MOCK_PRESET_SSH_TARPIT,
    MOCK_PRESET_HTTP_403,
    MOCK_PRESET_HTTP_404,
    MOCK_PRESET_HTTP_401,
    MOCK_PRESET_REDIS_SECURE,
    MOCK_PRESET_MYSQL_SECURE,
    MOCK_PRESET_MYSQL_TARPIT,
    MOCK_PRESET_RDP_SECURE,
    MOCK_PRESET_TELNET_SECURE,
    MOCK_PRESET_RAW_TARPIT,
  ];

  static final $core.List<MockPreset?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 11);
  static MockPreset? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MockPreset._(super.value, super.name);
}

/// ConditionType defines the type of condition in a rule
class ConditionType extends $pb.ProtobufEnum {
  static const ConditionType CONDITION_TYPE_UNSPECIFIED =
      ConditionType._(0, _omitEnumNames ? '' : 'CONDITION_TYPE_UNSPECIFIED');
  static const ConditionType CONDITION_TYPE_SOURCE_IP =
      ConditionType._(1, _omitEnumNames ? '' : 'CONDITION_TYPE_SOURCE_IP');
  static const ConditionType CONDITION_TYPE_GEO_COUNTRY =
      ConditionType._(2, _omitEnumNames ? '' : 'CONDITION_TYPE_GEO_COUNTRY');
  static const ConditionType CONDITION_TYPE_GEO_CITY =
      ConditionType._(3, _omitEnumNames ? '' : 'CONDITION_TYPE_GEO_CITY');
  static const ConditionType CONDITION_TYPE_GEO_ISP =
      ConditionType._(4, _omitEnumNames ? '' : 'CONDITION_TYPE_GEO_ISP');
  static const ConditionType CONDITION_TYPE_TIME_RANGE =
      ConditionType._(5, _omitEnumNames ? '' : 'CONDITION_TYPE_TIME_RANGE');
  static const ConditionType CONDITION_TYPE_TLS_FINGERPRINT = ConditionType._(
      6, _omitEnumNames ? '' : 'CONDITION_TYPE_TLS_FINGERPRINT');
  static const ConditionType CONDITION_TYPE_TLS_CN =
      ConditionType._(7, _omitEnumNames ? '' : 'CONDITION_TYPE_TLS_CN');
  static const ConditionType CONDITION_TYPE_TLS_SERIAL =
      ConditionType._(8, _omitEnumNames ? '' : 'CONDITION_TYPE_TLS_SERIAL');
  static const ConditionType CONDITION_TYPE_TLS_PRESENT =
      ConditionType._(9, _omitEnumNames ? '' : 'CONDITION_TYPE_TLS_PRESENT');
  static const ConditionType CONDITION_TYPE_TLS_CA =
      ConditionType._(10, _omitEnumNames ? '' : 'CONDITION_TYPE_TLS_CA');
  static const ConditionType CONDITION_TYPE_TLS_SAN =
      ConditionType._(11, _omitEnumNames ? '' : 'CONDITION_TYPE_TLS_SAN');
  static const ConditionType CONDITION_TYPE_TLS_OU =
      ConditionType._(12, _omitEnumNames ? '' : 'CONDITION_TYPE_TLS_OU');

  static const $core.List<ConditionType> values = <ConditionType>[
    CONDITION_TYPE_UNSPECIFIED,
    CONDITION_TYPE_SOURCE_IP,
    CONDITION_TYPE_GEO_COUNTRY,
    CONDITION_TYPE_GEO_CITY,
    CONDITION_TYPE_GEO_ISP,
    CONDITION_TYPE_TIME_RANGE,
    CONDITION_TYPE_TLS_FINGERPRINT,
    CONDITION_TYPE_TLS_CN,
    CONDITION_TYPE_TLS_SERIAL,
    CONDITION_TYPE_TLS_PRESENT,
    CONDITION_TYPE_TLS_CA,
    CONDITION_TYPE_TLS_SAN,
    CONDITION_TYPE_TLS_OU,
  ];

  static final $core.List<ConditionType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 12);
  static ConditionType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ConditionType._(super.value, super.name);
}

/// Operator defines how to match the value in a condition
class Operator extends $pb.ProtobufEnum {
  static const Operator OPERATOR_UNSPECIFIED =
      Operator._(0, _omitEnumNames ? '' : 'OPERATOR_UNSPECIFIED');
  static const Operator OPERATOR_EQ =
      Operator._(1, _omitEnumNames ? '' : 'OPERATOR_EQ');
  static const Operator OPERATOR_CONTAINS =
      Operator._(2, _omitEnumNames ? '' : 'OPERATOR_CONTAINS');
  static const Operator OPERATOR_REGEX =
      Operator._(3, _omitEnumNames ? '' : 'OPERATOR_REGEX');
  static const Operator OPERATOR_CIDR =
      Operator._(4, _omitEnumNames ? '' : 'OPERATOR_CIDR');

  static const $core.List<Operator> values = <Operator>[
    OPERATOR_UNSPECIFIED,
    OPERATOR_EQ,
    OPERATOR_CONTAINS,
    OPERATOR_REGEX,
    OPERATOR_CIDR,
  ];

  static final $core.List<Operator?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static Operator? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Operator._(super.value, super.name);
}

/// SortOrder defines sorting options for statistics queries
class SortOrder extends $pb.ProtobufEnum {
  static const SortOrder SORT_LAST_SEEN_DESC =
      SortOrder._(0, _omitEnumNames ? '' : 'SORT_LAST_SEEN_DESC');
  static const SortOrder SORT_LAST_SEEN_ASC =
      SortOrder._(1, _omitEnumNames ? '' : 'SORT_LAST_SEEN_ASC');
  static const SortOrder SORT_CONNECTION_COUNT_DESC =
      SortOrder._(2, _omitEnumNames ? '' : 'SORT_CONNECTION_COUNT_DESC');
  static const SortOrder SORT_BYTES_TOTAL_DESC =
      SortOrder._(3, _omitEnumNames ? '' : 'SORT_BYTES_TOTAL_DESC');
  static const SortOrder SORT_RECENCY_WEIGHT_DESC =
      SortOrder._(4, _omitEnumNames ? '' : 'SORT_RECENCY_WEIGHT_DESC');

  static const $core.List<SortOrder> values = <SortOrder>[
    SORT_LAST_SEEN_DESC,
    SORT_LAST_SEEN_ASC,
    SORT_CONNECTION_COUNT_DESC,
    SORT_BYTES_TOTAL_DESC,
    SORT_RECENCY_WEIGHT_DESC,
  ];

  static final $core.List<SortOrder?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static SortOrder? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SortOrder._(super.value, super.name);
}

/// PemLabel defines PEM block types
class PemLabel extends $pb.ProtobufEnum {
  static const PemLabel PEM_LABEL_UNSPECIFIED =
      PemLabel._(0, _omitEnumNames ? '' : 'PEM_LABEL_UNSPECIFIED');
  static const PemLabel PEM_LABEL_CERTIFICATE =
      PemLabel._(1, _omitEnumNames ? '' : 'PEM_LABEL_CERTIFICATE');
  static const PemLabel PEM_LABEL_PUBLIC_KEY =
      PemLabel._(2, _omitEnumNames ? '' : 'PEM_LABEL_PUBLIC_KEY');
  static const PemLabel PEM_LABEL_PRIVATE_KEY =
      PemLabel._(3, _omitEnumNames ? '' : 'PEM_LABEL_PRIVATE_KEY');
  static const PemLabel PEM_LABEL_ENCRYPTED_PRIVATE_KEY =
      PemLabel._(4, _omitEnumNames ? '' : 'PEM_LABEL_ENCRYPTED_PRIVATE_KEY');

  static const $core.List<PemLabel> values = <PemLabel>[
    PEM_LABEL_UNSPECIFIED,
    PEM_LABEL_CERTIFICATE,
    PEM_LABEL_PUBLIC_KEY,
    PEM_LABEL_PRIVATE_KEY,
    PEM_LABEL_ENCRYPTED_PRIVATE_KEY,
  ];

  static final $core.List<PemLabel?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static PemLabel? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PemLabel._(super.value, super.name);
}

/// ApprovalActionType defines the user's decision for an approval request
class ApprovalActionType extends $pb.ProtobufEnum {
  static const ApprovalActionType APPROVAL_ACTION_TYPE_UNSPECIFIED =
      ApprovalActionType._(
          0, _omitEnumNames ? '' : 'APPROVAL_ACTION_TYPE_UNSPECIFIED');
  static const ApprovalActionType APPROVAL_ACTION_TYPE_ALLOW =
      ApprovalActionType._(
          1, _omitEnumNames ? '' : 'APPROVAL_ACTION_TYPE_ALLOW');
  static const ApprovalActionType APPROVAL_ACTION_TYPE_BLOCK =
      ApprovalActionType._(
          2, _omitEnumNames ? '' : 'APPROVAL_ACTION_TYPE_BLOCK');
  static const ApprovalActionType APPROVAL_ACTION_TYPE_BLOCK_ADD_RULE =
      ApprovalActionType._(
          3, _omitEnumNames ? '' : 'APPROVAL_ACTION_TYPE_BLOCK_ADD_RULE');

  static const $core.List<ApprovalActionType> values = <ApprovalActionType>[
    APPROVAL_ACTION_TYPE_UNSPECIFIED,
    APPROVAL_ACTION_TYPE_ALLOW,
    APPROVAL_ACTION_TYPE_BLOCK,
    APPROVAL_ACTION_TYPE_BLOCK_ADD_RULE,
  ];

  static final $core.List<ApprovalActionType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ApprovalActionType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ApprovalActionType._(super.value, super.name);
}

/// ApprovalRetentionMode controls whether an approval decision is cached or
/// applied only to the current pending connection.
class ApprovalRetentionMode extends $pb.ProtobufEnum {
  static const ApprovalRetentionMode APPROVAL_RETENTION_MODE_UNSPECIFIED =
      ApprovalRetentionMode._(
          0, _omitEnumNames ? '' : 'APPROVAL_RETENTION_MODE_UNSPECIFIED');
  static const ApprovalRetentionMode APPROVAL_RETENTION_MODE_CACHE =
      ApprovalRetentionMode._(
          1, _omitEnumNames ? '' : 'APPROVAL_RETENTION_MODE_CACHE');
  static const ApprovalRetentionMode APPROVAL_RETENTION_MODE_CONNECTION_ONLY =
      ApprovalRetentionMode._(
          2, _omitEnumNames ? '' : 'APPROVAL_RETENTION_MODE_CONNECTION_ONLY');

  static const $core.List<ApprovalRetentionMode> values =
      <ApprovalRetentionMode>[
    APPROVAL_RETENTION_MODE_UNSPECIFIED,
    APPROVAL_RETENTION_MODE_CACHE,
    APPROVAL_RETENTION_MODE_CONNECTION_ONLY,
  ];

  static final $core.List<ApprovalRetentionMode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ApprovalRetentionMode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ApprovalRetentionMode._(super.value, super.name);
}

/// P2PMode defines the peer-to-peer connection strategy
class P2PMode extends $pb.ProtobufEnum {
  static const P2PMode P2P_MODE_UNSPECIFIED =
      P2PMode._(0, _omitEnumNames ? '' : 'P2P_MODE_UNSPECIFIED');
  static const P2PMode P2P_MODE_AUTO =
      P2PMode._(1, _omitEnumNames ? '' : 'P2P_MODE_AUTO');
  static const P2PMode P2P_MODE_DIRECT =
      P2PMode._(2, _omitEnumNames ? '' : 'P2P_MODE_DIRECT');
  static const P2PMode P2P_MODE_HUB =
      P2PMode._(3, _omitEnumNames ? '' : 'P2P_MODE_HUB');

  static const $core.List<P2PMode> values = <P2PMode>[
    P2P_MODE_UNSPECIFIED,
    P2P_MODE_AUTO,
    P2P_MODE_DIRECT,
    P2P_MODE_HUB,
  ];

  static final $core.List<P2PMode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static P2PMode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const P2PMode._(super.value, super.name);
}

/// CryptoAlgorithm for forward compatibility
class CryptoAlgorithm extends $pb.ProtobufEnum {
  static const CryptoAlgorithm ALGO_UNKNOWN =
      CryptoAlgorithm._(0, _omitEnumNames ? '' : 'ALGO_UNKNOWN');
  static const CryptoAlgorithm ALGO_ED25519 =
      CryptoAlgorithm._(1, _omitEnumNames ? '' : 'ALGO_ED25519');

  static const $core.List<CryptoAlgorithm> values = <CryptoAlgorithm>[
    ALGO_UNKNOWN,
    ALGO_ED25519,
  ];

  static final $core.List<CryptoAlgorithm?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static CryptoAlgorithm? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CryptoAlgorithm._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
