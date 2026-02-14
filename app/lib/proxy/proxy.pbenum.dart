// This is a generated file - do not edit.
//
// Generated from proxy/proxy.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class HealthCheckType extends $pb.ProtobufEnum {
  static const HealthCheckType HEALTH_CHECK_TYPE_UNSPECIFIED =
      HealthCheckType._(
          0, _omitEnumNames ? '' : 'HEALTH_CHECK_TYPE_UNSPECIFIED');
  static const HealthCheckType HEALTH_CHECK_TYPE_TCP =
      HealthCheckType._(1, _omitEnumNames ? '' : 'HEALTH_CHECK_TYPE_TCP');
  static const HealthCheckType HEALTH_CHECK_TYPE_HTTP =
      HealthCheckType._(2, _omitEnumNames ? '' : 'HEALTH_CHECK_TYPE_HTTP');
  static const HealthCheckType HEALTH_CHECK_TYPE_HTTPS =
      HealthCheckType._(3, _omitEnumNames ? '' : 'HEALTH_CHECK_TYPE_HTTPS');

  static const $core.List<HealthCheckType> values = <HealthCheckType>[
    HEALTH_CHECK_TYPE_UNSPECIFIED,
    HEALTH_CHECK_TYPE_TCP,
    HEALTH_CHECK_TYPE_HTTP,
    HEALTH_CHECK_TYPE_HTTPS,
  ];

  static final $core.List<HealthCheckType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static HealthCheckType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const HealthCheckType._(super.value, super.name);
}

class ClientAuthType extends $pb.ProtobufEnum {
  static const ClientAuthType CLIENT_AUTH_AUTO =
      ClientAuthType._(0, _omitEnumNames ? '' : 'CLIENT_AUTH_AUTO');
  static const ClientAuthType CLIENT_AUTH_NONE =
      ClientAuthType._(1, _omitEnumNames ? '' : 'CLIENT_AUTH_NONE');
  static const ClientAuthType CLIENT_AUTH_REQUEST =
      ClientAuthType._(2, _omitEnumNames ? '' : 'CLIENT_AUTH_REQUEST');
  static const ClientAuthType CLIENT_AUTH_REQUIRE =
      ClientAuthType._(3, _omitEnumNames ? '' : 'CLIENT_AUTH_REQUIRE');

  static const $core.List<ClientAuthType> values = <ClientAuthType>[
    CLIENT_AUTH_AUTO,
    CLIENT_AUTH_NONE,
    CLIENT_AUTH_REQUEST,
    CLIENT_AUTH_REQUIRE,
  ];

  static final $core.List<ClientAuthType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ClientAuthType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ClientAuthType._(super.value, super.name);
}

class HealthStatus extends $pb.ProtobufEnum {
  static const HealthStatus HEALTH_STATUS_UNKNOWN =
      HealthStatus._(0, _omitEnumNames ? '' : 'HEALTH_STATUS_UNKNOWN');
  static const HealthStatus HEALTH_STATUS_HEALTHY =
      HealthStatus._(1, _omitEnumNames ? '' : 'HEALTH_STATUS_HEALTHY');
  static const HealthStatus HEALTH_STATUS_UNHEALTHY =
      HealthStatus._(2, _omitEnumNames ? '' : 'HEALTH_STATUS_UNHEALTHY');
  static const HealthStatus HEALTH_STATUS_STARTING =
      HealthStatus._(3, _omitEnumNames ? '' : 'HEALTH_STATUS_STARTING');

  static const $core.List<HealthStatus> values = <HealthStatus>[
    HEALTH_STATUS_UNKNOWN,
    HEALTH_STATUS_HEALTHY,
    HEALTH_STATUS_UNHEALTHY,
    HEALTH_STATUS_STARTING,
  ];

  static final $core.List<HealthStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static HealthStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const HealthStatus._(super.value, super.name);
}

class EventType extends $pb.ProtobufEnum {
  static const EventType EVENT_TYPE_UNSPECIFIED =
      EventType._(0, _omitEnumNames ? '' : 'EVENT_TYPE_UNSPECIFIED');
  static const EventType EVENT_TYPE_CONNECTED =
      EventType._(1, _omitEnumNames ? '' : 'EVENT_TYPE_CONNECTED');
  static const EventType EVENT_TYPE_CLOSED =
      EventType._(2, _omitEnumNames ? '' : 'EVENT_TYPE_CLOSED');
  static const EventType EVENT_TYPE_BLOCKED =
      EventType._(3, _omitEnumNames ? '' : 'EVENT_TYPE_BLOCKED');
  static const EventType EVENT_TYPE_PENDING_APPROVAL =
      EventType._(4, _omitEnumNames ? '' : 'EVENT_TYPE_PENDING_APPROVAL');
  static const EventType EVENT_TYPE_APPROVED =
      EventType._(5, _omitEnumNames ? '' : 'EVENT_TYPE_APPROVED');

  static const $core.List<EventType> values = <EventType>[
    EVENT_TYPE_UNSPECIFIED,
    EVENT_TYPE_CONNECTED,
    EVENT_TYPE_CLOSED,
    EVENT_TYPE_BLOCKED,
    EVENT_TYPE_PENDING_APPROVAL,
    EVENT_TYPE_APPROVED,
  ];

  static final $core.List<EventType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static EventType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EventType._(super.value, super.name);
}

class ConfigureGeoIPRequest_Mode extends $pb.ProtobufEnum {
  static const ConfigureGeoIPRequest_Mode MODE_LOCAL_DB =
      ConfigureGeoIPRequest_Mode._(0, _omitEnumNames ? '' : 'MODE_LOCAL_DB');
  static const ConfigureGeoIPRequest_Mode MODE_REMOTE_API =
      ConfigureGeoIPRequest_Mode._(1, _omitEnumNames ? '' : 'MODE_REMOTE_API');

  static const $core.List<ConfigureGeoIPRequest_Mode> values =
      <ConfigureGeoIPRequest_Mode>[
    MODE_LOCAL_DB,
    MODE_REMOTE_API,
  ];

  static final $core.List<ConfigureGeoIPRequest_Mode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static ConfigureGeoIPRequest_Mode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ConfigureGeoIPRequest_Mode._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
