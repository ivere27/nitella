// This is a generated file - do not edit.
//
// Generated from geoip/geoip.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class CacheLayer extends $pb.ProtobufEnum {
  static const CacheLayer CACHE_LAYER_ALL =
      CacheLayer._(0, _omitEnumNames ? '' : 'CACHE_LAYER_ALL');
  static const CacheLayer CACHE_LAYER_L1 =
      CacheLayer._(1, _omitEnumNames ? '' : 'CACHE_LAYER_L1');
  static const CacheLayer CACHE_LAYER_L2 =
      CacheLayer._(2, _omitEnumNames ? '' : 'CACHE_LAYER_L2');

  static const $core.List<CacheLayer> values = <CacheLayer>[
    CACHE_LAYER_ALL,
    CACHE_LAYER_L1,
    CACHE_LAYER_L2,
  ];

  static final $core.List<CacheLayer?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static CacheLayer? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CacheLayer._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
