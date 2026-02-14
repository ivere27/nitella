// This is a generated file - do not edit.
//
// Generated from hub/hub_mobile.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class PakeMessage_MessageType extends $pb.ProtobufEnum {
  static const PakeMessage_MessageType MESSAGE_TYPE_UNSPECIFIED =
      PakeMessage_MessageType._(
          0, _omitEnumNames ? '' : 'MESSAGE_TYPE_UNSPECIFIED');
  static const PakeMessage_MessageType MESSAGE_TYPE_SPAKE2_INIT =
      PakeMessage_MessageType._(
          1, _omitEnumNames ? '' : 'MESSAGE_TYPE_SPAKE2_INIT');
  static const PakeMessage_MessageType MESSAGE_TYPE_SPAKE2_REPLY =
      PakeMessage_MessageType._(
          2, _omitEnumNames ? '' : 'MESSAGE_TYPE_SPAKE2_REPLY');
  static const PakeMessage_MessageType MESSAGE_TYPE_ENCRYPTED =
      PakeMessage_MessageType._(
          3, _omitEnumNames ? '' : 'MESSAGE_TYPE_ENCRYPTED');
  static const PakeMessage_MessageType MESSAGE_TYPE_ERROR =
      PakeMessage_MessageType._(4, _omitEnumNames ? '' : 'MESSAGE_TYPE_ERROR');

  static const $core.List<PakeMessage_MessageType> values =
      <PakeMessage_MessageType>[
    MESSAGE_TYPE_UNSPECIFIED,
    MESSAGE_TYPE_SPAKE2_INIT,
    MESSAGE_TYPE_SPAKE2_REPLY,
    MESSAGE_TYPE_ENCRYPTED,
    MESSAGE_TYPE_ERROR,
  ];

  static final $core.List<PakeMessage_MessageType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static PakeMessage_MessageType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PakeMessage_MessageType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
