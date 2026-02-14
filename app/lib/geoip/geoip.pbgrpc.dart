// This is a generated file - do not edit.
//
// Generated from geoip/geoip.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $2;

import '../common/common.pb.dart' as $1;
import 'geoip.pb.dart' as $0;

export 'geoip.pb.dart';

/// GeoIPService provides public IP geolocation lookups
@$pb.GrpcServiceName('nitella.geoip.GeoIPService')
class GeoIPServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  GeoIPServiceClient(super.channel, {super.options, super.interceptors});

  /// Lookup resolves an IP to geographical info
  $grpc.ResponseFuture<$1.GeoInfo> lookup(
    $0.LookupRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$lookup, request, options: options);
  }

  /// GetStatus returns the health and stats of the service
  $grpc.ResponseFuture<$0.ServiceStatus> getStatus(
    $2.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getStatus, request, options: options);
  }

  // method descriptors

  static final _$lookup = $grpc.ClientMethod<$0.LookupRequest, $1.GeoInfo>(
      '/nitella.geoip.GeoIPService/Lookup',
      ($0.LookupRequest value) => value.writeToBuffer(),
      $1.GeoInfo.fromBuffer);
  static final _$getStatus = $grpc.ClientMethod<$2.Empty, $0.ServiceStatus>(
      '/nitella.geoip.GeoIPService/GetStatus',
      ($2.Empty value) => value.writeToBuffer(),
      $0.ServiceStatus.fromBuffer);
}

@$pb.GrpcServiceName('nitella.geoip.GeoIPService')
abstract class GeoIPServiceBase extends $grpc.Service {
  $core.String get $name => 'nitella.geoip.GeoIPService';

  GeoIPServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.LookupRequest, $1.GeoInfo>(
        'Lookup',
        lookup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LookupRequest.fromBuffer(value),
        ($1.GeoInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.Empty, $0.ServiceStatus>(
        'GetStatus',
        getStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.Empty.fromBuffer(value),
        ($0.ServiceStatus value) => value.writeToBuffer()));
  }

  $async.Future<$1.GeoInfo> lookup_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LookupRequest> $request) async {
    return lookup($call, await $request);
  }

  $async.Future<$1.GeoInfo> lookup(
      $grpc.ServiceCall call, $0.LookupRequest request);

  $async.Future<$0.ServiceStatus> getStatus_Pre(
      $grpc.ServiceCall $call, $async.Future<$2.Empty> $request) async {
    return getStatus($call, await $request);
  }

  $async.Future<$0.ServiceStatus> getStatus(
      $grpc.ServiceCall call, $2.Empty request);
}

/// GeoIPAdminService provides administrative operations (requires token auth)
@$pb.GrpcServiceName('nitella.geoip.GeoIPAdminService')
class GeoIPAdminServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  GeoIPAdminServiceClient(super.channel, {super.options, super.interceptors});

  /// Lookup resolves an IP to geographical info
  $grpc.ResponseFuture<$1.GeoInfo> lookup(
    $0.LookupRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$lookup, request, options: options);
  }

  /// GetStatus returns the health and stats of the service
  $grpc.ResponseFuture<$0.ServiceStatus> getStatus(
    $2.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getStatus, request, options: options);
  }

  /// LoadLocalDB loads MaxMind database files
  $grpc.ResponseFuture<$2.Empty> loadLocalDB(
    $0.LoadLocalDBRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$loadLocalDB, request, options: options);
  }

  /// UnloadLocalDB unloads the local database
  $grpc.ResponseFuture<$2.Empty> unloadLocalDB(
    $2.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unloadLocalDB, request, options: options);
  }

  /// GetLocalDBStatus returns the status of the local database
  $grpc.ResponseFuture<$0.LocalDBStatus> getLocalDBStatus(
    $2.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getLocalDBStatus, request, options: options);
  }

  /// ListProviders returns all configured providers with stats
  $grpc.ResponseFuture<$0.ListProvidersResponse> listProviders(
    $2.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listProviders, request, options: options);
  }

  /// AddProvider adds a new HTTP provider
  $grpc.ResponseFuture<$0.ProviderInfo> addProvider(
    $0.AddProviderRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addProvider, request, options: options);
  }

  /// RemoveProvider removes a provider by name
  $grpc.ResponseFuture<$2.Empty> removeProvider(
    $0.RemoveProviderRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeProvider, request, options: options);
  }

  /// UpdateProvider updates an existing provider
  $grpc.ResponseFuture<$0.ProviderInfo> updateProvider(
    $0.UpdateProviderRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateProvider, request, options: options);
  }

  /// ReorderProviders changes the provider priority order
  $grpc.ResponseFuture<$0.ListProvidersResponse> reorderProviders(
    $0.ReorderProvidersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$reorderProviders, request, options: options);
  }

  /// EnableProvider enables a disabled provider
  $grpc.ResponseFuture<$2.Empty> enableProvider(
    $0.ProviderNameRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$enableProvider, request, options: options);
  }

  /// DisableProvider disables a provider without removing it
  $grpc.ResponseFuture<$2.Empty> disableProvider(
    $0.ProviderNameRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$disableProvider, request, options: options);
  }

  /// GetProviderStats returns detailed statistics for a provider
  $grpc.ResponseFuture<$0.ProviderStats> getProviderStats(
    $0.ProviderNameRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getProviderStats, request, options: options);
  }

  /// GetCacheStats returns cache statistics
  $grpc.ResponseFuture<$0.CacheStats> getCacheStats(
    $2.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getCacheStats, request, options: options);
  }

  /// ClearCache clears specified cache layers
  $grpc.ResponseFuture<$2.Empty> clearCache(
    $0.ClearCacheRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$clearCache, request, options: options);
  }

  /// GetCacheSettings returns current cache settings
  $grpc.ResponseFuture<$0.CacheSettings> getCacheSettings(
    $2.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getCacheSettings, request, options: options);
  }

  /// UpdateCacheSettings updates cache configuration
  $grpc.ResponseFuture<$0.CacheSettings> updateCacheSettings(
    $0.UpdateCacheSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateCacheSettings, request, options: options);
  }

  /// VacuumL2 optimizes the L2 cache database
  $grpc.ResponseFuture<$2.Empty> vacuumL2(
    $2.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$vacuumL2, request, options: options);
  }

  /// GetStrategy returns the current lookup strategy
  $grpc.ResponseFuture<$0.StrategyResponse> getStrategy(
    $2.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getStrategy, request, options: options);
  }

  /// SetStrategy sets the lookup strategy order
  $grpc.ResponseFuture<$0.StrategyResponse> setStrategy(
    $0.SetStrategyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setStrategy, request, options: options);
  }

  /// ReloadConfig reloads configuration from file
  $grpc.ResponseFuture<$2.Empty> reloadConfig(
    $2.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$reloadConfig, request, options: options);
  }

  /// SaveConfig saves current configuration to file
  $grpc.ResponseFuture<$2.Empty> saveConfig(
    $2.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$saveConfig, request, options: options);
  }

  // method descriptors

  static final _$lookup = $grpc.ClientMethod<$0.LookupRequest, $1.GeoInfo>(
      '/nitella.geoip.GeoIPAdminService/Lookup',
      ($0.LookupRequest value) => value.writeToBuffer(),
      $1.GeoInfo.fromBuffer);
  static final _$getStatus = $grpc.ClientMethod<$2.Empty, $0.ServiceStatus>(
      '/nitella.geoip.GeoIPAdminService/GetStatus',
      ($2.Empty value) => value.writeToBuffer(),
      $0.ServiceStatus.fromBuffer);
  static final _$loadLocalDB =
      $grpc.ClientMethod<$0.LoadLocalDBRequest, $2.Empty>(
          '/nitella.geoip.GeoIPAdminService/LoadLocalDB',
          ($0.LoadLocalDBRequest value) => value.writeToBuffer(),
          $2.Empty.fromBuffer);
  static final _$unloadLocalDB = $grpc.ClientMethod<$2.Empty, $2.Empty>(
      '/nitella.geoip.GeoIPAdminService/UnloadLocalDB',
      ($2.Empty value) => value.writeToBuffer(),
      $2.Empty.fromBuffer);
  static final _$getLocalDBStatus =
      $grpc.ClientMethod<$2.Empty, $0.LocalDBStatus>(
          '/nitella.geoip.GeoIPAdminService/GetLocalDBStatus',
          ($2.Empty value) => value.writeToBuffer(),
          $0.LocalDBStatus.fromBuffer);
  static final _$listProviders =
      $grpc.ClientMethod<$2.Empty, $0.ListProvidersResponse>(
          '/nitella.geoip.GeoIPAdminService/ListProviders',
          ($2.Empty value) => value.writeToBuffer(),
          $0.ListProvidersResponse.fromBuffer);
  static final _$addProvider =
      $grpc.ClientMethod<$0.AddProviderRequest, $0.ProviderInfo>(
          '/nitella.geoip.GeoIPAdminService/AddProvider',
          ($0.AddProviderRequest value) => value.writeToBuffer(),
          $0.ProviderInfo.fromBuffer);
  static final _$removeProvider =
      $grpc.ClientMethod<$0.RemoveProviderRequest, $2.Empty>(
          '/nitella.geoip.GeoIPAdminService/RemoveProvider',
          ($0.RemoveProviderRequest value) => value.writeToBuffer(),
          $2.Empty.fromBuffer);
  static final _$updateProvider =
      $grpc.ClientMethod<$0.UpdateProviderRequest, $0.ProviderInfo>(
          '/nitella.geoip.GeoIPAdminService/UpdateProvider',
          ($0.UpdateProviderRequest value) => value.writeToBuffer(),
          $0.ProviderInfo.fromBuffer);
  static final _$reorderProviders =
      $grpc.ClientMethod<$0.ReorderProvidersRequest, $0.ListProvidersResponse>(
          '/nitella.geoip.GeoIPAdminService/ReorderProviders',
          ($0.ReorderProvidersRequest value) => value.writeToBuffer(),
          $0.ListProvidersResponse.fromBuffer);
  static final _$enableProvider =
      $grpc.ClientMethod<$0.ProviderNameRequest, $2.Empty>(
          '/nitella.geoip.GeoIPAdminService/EnableProvider',
          ($0.ProviderNameRequest value) => value.writeToBuffer(),
          $2.Empty.fromBuffer);
  static final _$disableProvider =
      $grpc.ClientMethod<$0.ProviderNameRequest, $2.Empty>(
          '/nitella.geoip.GeoIPAdminService/DisableProvider',
          ($0.ProviderNameRequest value) => value.writeToBuffer(),
          $2.Empty.fromBuffer);
  static final _$getProviderStats =
      $grpc.ClientMethod<$0.ProviderNameRequest, $0.ProviderStats>(
          '/nitella.geoip.GeoIPAdminService/GetProviderStats',
          ($0.ProviderNameRequest value) => value.writeToBuffer(),
          $0.ProviderStats.fromBuffer);
  static final _$getCacheStats = $grpc.ClientMethod<$2.Empty, $0.CacheStats>(
      '/nitella.geoip.GeoIPAdminService/GetCacheStats',
      ($2.Empty value) => value.writeToBuffer(),
      $0.CacheStats.fromBuffer);
  static final _$clearCache =
      $grpc.ClientMethod<$0.ClearCacheRequest, $2.Empty>(
          '/nitella.geoip.GeoIPAdminService/ClearCache',
          ($0.ClearCacheRequest value) => value.writeToBuffer(),
          $2.Empty.fromBuffer);
  static final _$getCacheSettings =
      $grpc.ClientMethod<$2.Empty, $0.CacheSettings>(
          '/nitella.geoip.GeoIPAdminService/GetCacheSettings',
          ($2.Empty value) => value.writeToBuffer(),
          $0.CacheSettings.fromBuffer);
  static final _$updateCacheSettings =
      $grpc.ClientMethod<$0.UpdateCacheSettingsRequest, $0.CacheSettings>(
          '/nitella.geoip.GeoIPAdminService/UpdateCacheSettings',
          ($0.UpdateCacheSettingsRequest value) => value.writeToBuffer(),
          $0.CacheSettings.fromBuffer);
  static final _$vacuumL2 = $grpc.ClientMethod<$2.Empty, $2.Empty>(
      '/nitella.geoip.GeoIPAdminService/VacuumL2',
      ($2.Empty value) => value.writeToBuffer(),
      $2.Empty.fromBuffer);
  static final _$getStrategy =
      $grpc.ClientMethod<$2.Empty, $0.StrategyResponse>(
          '/nitella.geoip.GeoIPAdminService/GetStrategy',
          ($2.Empty value) => value.writeToBuffer(),
          $0.StrategyResponse.fromBuffer);
  static final _$setStrategy =
      $grpc.ClientMethod<$0.SetStrategyRequest, $0.StrategyResponse>(
          '/nitella.geoip.GeoIPAdminService/SetStrategy',
          ($0.SetStrategyRequest value) => value.writeToBuffer(),
          $0.StrategyResponse.fromBuffer);
  static final _$reloadConfig = $grpc.ClientMethod<$2.Empty, $2.Empty>(
      '/nitella.geoip.GeoIPAdminService/ReloadConfig',
      ($2.Empty value) => value.writeToBuffer(),
      $2.Empty.fromBuffer);
  static final _$saveConfig = $grpc.ClientMethod<$2.Empty, $2.Empty>(
      '/nitella.geoip.GeoIPAdminService/SaveConfig',
      ($2.Empty value) => value.writeToBuffer(),
      $2.Empty.fromBuffer);
}

@$pb.GrpcServiceName('nitella.geoip.GeoIPAdminService')
abstract class GeoIPAdminServiceBase extends $grpc.Service {
  $core.String get $name => 'nitella.geoip.GeoIPAdminService';

  GeoIPAdminServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.LookupRequest, $1.GeoInfo>(
        'Lookup',
        lookup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LookupRequest.fromBuffer(value),
        ($1.GeoInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.Empty, $0.ServiceStatus>(
        'GetStatus',
        getStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.Empty.fromBuffer(value),
        ($0.ServiceStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LoadLocalDBRequest, $2.Empty>(
        'LoadLocalDB',
        loadLocalDB_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.LoadLocalDBRequest.fromBuffer(value),
        ($2.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.Empty, $2.Empty>(
        'UnloadLocalDB',
        unloadLocalDB_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.Empty.fromBuffer(value),
        ($2.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.Empty, $0.LocalDBStatus>(
        'GetLocalDBStatus',
        getLocalDBStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.Empty.fromBuffer(value),
        ($0.LocalDBStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.Empty, $0.ListProvidersResponse>(
        'ListProviders',
        listProviders_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.Empty.fromBuffer(value),
        ($0.ListProvidersResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddProviderRequest, $0.ProviderInfo>(
        'AddProvider',
        addProvider_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AddProviderRequest.fromBuffer(value),
        ($0.ProviderInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RemoveProviderRequest, $2.Empty>(
        'RemoveProvider',
        removeProvider_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RemoveProviderRequest.fromBuffer(value),
        ($2.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateProviderRequest, $0.ProviderInfo>(
        'UpdateProvider',
        updateProvider_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateProviderRequest.fromBuffer(value),
        ($0.ProviderInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ReorderProvidersRequest,
            $0.ListProvidersResponse>(
        'ReorderProviders',
        reorderProviders_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ReorderProvidersRequest.fromBuffer(value),
        ($0.ListProvidersResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProviderNameRequest, $2.Empty>(
        'EnableProvider',
        enableProvider_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ProviderNameRequest.fromBuffer(value),
        ($2.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProviderNameRequest, $2.Empty>(
        'DisableProvider',
        disableProvider_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ProviderNameRequest.fromBuffer(value),
        ($2.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProviderNameRequest, $0.ProviderStats>(
        'GetProviderStats',
        getProviderStats_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ProviderNameRequest.fromBuffer(value),
        ($0.ProviderStats value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.Empty, $0.CacheStats>(
        'GetCacheStats',
        getCacheStats_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.Empty.fromBuffer(value),
        ($0.CacheStats value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ClearCacheRequest, $2.Empty>(
        'ClearCache',
        clearCache_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ClearCacheRequest.fromBuffer(value),
        ($2.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.Empty, $0.CacheSettings>(
        'GetCacheSettings',
        getCacheSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.Empty.fromBuffer(value),
        ($0.CacheSettings value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UpdateCacheSettingsRequest, $0.CacheSettings>(
            'UpdateCacheSettings',
            updateCacheSettings_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UpdateCacheSettingsRequest.fromBuffer(value),
            ($0.CacheSettings value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.Empty, $2.Empty>(
        'VacuumL2',
        vacuumL2_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.Empty.fromBuffer(value),
        ($2.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.Empty, $0.StrategyResponse>(
        'GetStrategy',
        getStrategy_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.Empty.fromBuffer(value),
        ($0.StrategyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetStrategyRequest, $0.StrategyResponse>(
        'SetStrategy',
        setStrategy_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetStrategyRequest.fromBuffer(value),
        ($0.StrategyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.Empty, $2.Empty>(
        'ReloadConfig',
        reloadConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.Empty.fromBuffer(value),
        ($2.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.Empty, $2.Empty>(
        'SaveConfig',
        saveConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.Empty.fromBuffer(value),
        ($2.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$1.GeoInfo> lookup_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LookupRequest> $request) async {
    return lookup($call, await $request);
  }

  $async.Future<$1.GeoInfo> lookup(
      $grpc.ServiceCall call, $0.LookupRequest request);

  $async.Future<$0.ServiceStatus> getStatus_Pre(
      $grpc.ServiceCall $call, $async.Future<$2.Empty> $request) async {
    return getStatus($call, await $request);
  }

  $async.Future<$0.ServiceStatus> getStatus(
      $grpc.ServiceCall call, $2.Empty request);

  $async.Future<$2.Empty> loadLocalDB_Pre($grpc.ServiceCall $call,
      $async.Future<$0.LoadLocalDBRequest> $request) async {
    return loadLocalDB($call, await $request);
  }

  $async.Future<$2.Empty> loadLocalDB(
      $grpc.ServiceCall call, $0.LoadLocalDBRequest request);

  $async.Future<$2.Empty> unloadLocalDB_Pre(
      $grpc.ServiceCall $call, $async.Future<$2.Empty> $request) async {
    return unloadLocalDB($call, await $request);
  }

  $async.Future<$2.Empty> unloadLocalDB(
      $grpc.ServiceCall call, $2.Empty request);

  $async.Future<$0.LocalDBStatus> getLocalDBStatus_Pre(
      $grpc.ServiceCall $call, $async.Future<$2.Empty> $request) async {
    return getLocalDBStatus($call, await $request);
  }

  $async.Future<$0.LocalDBStatus> getLocalDBStatus(
      $grpc.ServiceCall call, $2.Empty request);

  $async.Future<$0.ListProvidersResponse> listProviders_Pre(
      $grpc.ServiceCall $call, $async.Future<$2.Empty> $request) async {
    return listProviders($call, await $request);
  }

  $async.Future<$0.ListProvidersResponse> listProviders(
      $grpc.ServiceCall call, $2.Empty request);

  $async.Future<$0.ProviderInfo> addProvider_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AddProviderRequest> $request) async {
    return addProvider($call, await $request);
  }

  $async.Future<$0.ProviderInfo> addProvider(
      $grpc.ServiceCall call, $0.AddProviderRequest request);

  $async.Future<$2.Empty> removeProvider_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RemoveProviderRequest> $request) async {
    return removeProvider($call, await $request);
  }

  $async.Future<$2.Empty> removeProvider(
      $grpc.ServiceCall call, $0.RemoveProviderRequest request);

  $async.Future<$0.ProviderInfo> updateProvider_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateProviderRequest> $request) async {
    return updateProvider($call, await $request);
  }

  $async.Future<$0.ProviderInfo> updateProvider(
      $grpc.ServiceCall call, $0.UpdateProviderRequest request);

  $async.Future<$0.ListProvidersResponse> reorderProviders_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ReorderProvidersRequest> $request) async {
    return reorderProviders($call, await $request);
  }

  $async.Future<$0.ListProvidersResponse> reorderProviders(
      $grpc.ServiceCall call, $0.ReorderProvidersRequest request);

  $async.Future<$2.Empty> enableProvider_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ProviderNameRequest> $request) async {
    return enableProvider($call, await $request);
  }

  $async.Future<$2.Empty> enableProvider(
      $grpc.ServiceCall call, $0.ProviderNameRequest request);

  $async.Future<$2.Empty> disableProvider_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ProviderNameRequest> $request) async {
    return disableProvider($call, await $request);
  }

  $async.Future<$2.Empty> disableProvider(
      $grpc.ServiceCall call, $0.ProviderNameRequest request);

  $async.Future<$0.ProviderStats> getProviderStats_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ProviderNameRequest> $request) async {
    return getProviderStats($call, await $request);
  }

  $async.Future<$0.ProviderStats> getProviderStats(
      $grpc.ServiceCall call, $0.ProviderNameRequest request);

  $async.Future<$0.CacheStats> getCacheStats_Pre(
      $grpc.ServiceCall $call, $async.Future<$2.Empty> $request) async {
    return getCacheStats($call, await $request);
  }

  $async.Future<$0.CacheStats> getCacheStats(
      $grpc.ServiceCall call, $2.Empty request);

  $async.Future<$2.Empty> clearCache_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ClearCacheRequest> $request) async {
    return clearCache($call, await $request);
  }

  $async.Future<$2.Empty> clearCache(
      $grpc.ServiceCall call, $0.ClearCacheRequest request);

  $async.Future<$0.CacheSettings> getCacheSettings_Pre(
      $grpc.ServiceCall $call, $async.Future<$2.Empty> $request) async {
    return getCacheSettings($call, await $request);
  }

  $async.Future<$0.CacheSettings> getCacheSettings(
      $grpc.ServiceCall call, $2.Empty request);

  $async.Future<$0.CacheSettings> updateCacheSettings_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateCacheSettingsRequest> $request) async {
    return updateCacheSettings($call, await $request);
  }

  $async.Future<$0.CacheSettings> updateCacheSettings(
      $grpc.ServiceCall call, $0.UpdateCacheSettingsRequest request);

  $async.Future<$2.Empty> vacuumL2_Pre(
      $grpc.ServiceCall $call, $async.Future<$2.Empty> $request) async {
    return vacuumL2($call, await $request);
  }

  $async.Future<$2.Empty> vacuumL2($grpc.ServiceCall call, $2.Empty request);

  $async.Future<$0.StrategyResponse> getStrategy_Pre(
      $grpc.ServiceCall $call, $async.Future<$2.Empty> $request) async {
    return getStrategy($call, await $request);
  }

  $async.Future<$0.StrategyResponse> getStrategy(
      $grpc.ServiceCall call, $2.Empty request);

  $async.Future<$0.StrategyResponse> setStrategy_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetStrategyRequest> $request) async {
    return setStrategy($call, await $request);
  }

  $async.Future<$0.StrategyResponse> setStrategy(
      $grpc.ServiceCall call, $0.SetStrategyRequest request);

  $async.Future<$2.Empty> reloadConfig_Pre(
      $grpc.ServiceCall $call, $async.Future<$2.Empty> $request) async {
    return reloadConfig($call, await $request);
  }

  $async.Future<$2.Empty> reloadConfig(
      $grpc.ServiceCall call, $2.Empty request);

  $async.Future<$2.Empty> saveConfig_Pre(
      $grpc.ServiceCall $call, $async.Future<$2.Empty> $request) async {
    return saveConfig($call, await $request);
  }

  $async.Future<$2.Empty> saveConfig($grpc.ServiceCall call, $2.Empty request);
}
