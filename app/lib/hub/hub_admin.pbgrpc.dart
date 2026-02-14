// This is a generated file - do not edit.
//
// Generated from hub/hub_admin.proto.

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

import 'hub_admin.pb.dart' as $0;
import 'hub_common.pb.dart' as $1;

export 'hub_admin.pb.dart';

@$pb.GrpcServiceName('nitella.hub.AdminService')
class AdminServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AdminServiceClient(super.channel, {super.options, super.interceptors});

  /// ===========================================================================
  /// SYSTEM OVERVIEW
  /// ===========================================================================
  $grpc.ResponseFuture<$0.SystemStats> getSystemStats(
    $0.GetSystemStatsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSystemStats, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetAuditLogResponse> getAuditLog(
    $0.GetAuditLogRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getAuditLog, request, options: options);
  }

  $grpc.ResponseFuture<$0.DatabaseStats> getDatabaseStats(
    $0.GetDatabaseStatsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDatabaseStats, request, options: options);
  }

  /// ===========================================================================
  /// USER MANAGEMENT
  /// ===========================================================================
  $grpc.ResponseFuture<$0.ListAllUsersResponse> listAllUsers(
    $0.ListAllUsersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listAllUsers, request, options: options);
  }

  $grpc.ResponseFuture<$0.UserDetails> getUserDetails(
    $0.GetUserDetailsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getUserDetails, request, options: options);
  }

  $grpc.ResponseFuture<$1.User> setUserTier(
    $0.SetUserTierRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setUserTier, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> banUser(
    $0.BanUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$banUser, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> unbanUser(
    $0.UnbanUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unbanUser, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> deleteUser(
    $0.DeleteUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteUser, request, options: options);
  }

  /// ===========================================================================
  /// NODE MANAGEMENT
  /// ===========================================================================
  $grpc.ResponseFuture<$0.ListAllNodesResponse> listAllNodes(
    $0.ListAllNodesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listAllNodes, request, options: options);
  }

  $grpc.ResponseFuture<$0.NodeDetails> getNodeDetails(
    $0.GetNodeDetailsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getNodeDetails, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> forceDisconnectNode(
    $0.ForceDisconnectNodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$forceDisconnectNode, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> deleteNode(
    $0.AdminDeleteNodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteNode, request, options: options);
  }

  /// ===========================================================================
  /// ORGANIZATION MANAGEMENT
  /// ===========================================================================
  $grpc.ResponseFuture<$0.ListOrganizationsResponse> listOrganizations(
    $0.ListOrganizationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listOrganizations, request, options: options);
  }

  $grpc.ResponseFuture<$0.OrganizationDetails> getOrganization(
    $0.GetOrganizationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getOrganization, request, options: options);
  }

  $grpc.ResponseFuture<$0.Organization> setOrganizationTier(
    $0.SetOrganizationTierRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setOrganizationTier, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> deleteOrganization(
    $0.DeleteOrganizationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteOrganization, request, options: options);
  }

  /// ===========================================================================
  /// PENDING REGISTRATION MANAGEMENT
  /// ===========================================================================
  $grpc.ResponseFuture<$0.ListPendingRegistrationsResponse>
      listPendingRegistrations(
    $0.ListPendingRegistrationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listPendingRegistrations, request,
        options: options);
  }

  $grpc.ResponseFuture<$1.Empty> forceApproveRegistration(
    $0.ForceApproveRegistrationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$forceApproveRegistration, request,
        options: options);
  }

  $grpc.ResponseFuture<$1.Empty> rejectRegistration(
    $0.RejectRegistrationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$rejectRegistration, request, options: options);
  }

  $grpc.ResponseFuture<$0.ClearStalePairingsResponse> clearStalePairings(
    $0.ClearStalePairingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$clearStalePairings, request, options: options);
  }

  /// ===========================================================================
  /// DEVICE MANAGEMENT (FCM/Push)
  /// ===========================================================================
  $grpc.ResponseFuture<$0.ListDevicesResponse> listDevices(
    $0.ListDevicesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listDevices, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListDevicesResponse> getUserDevices(
    $0.GetUserDevicesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getUserDevices, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> removeDevice(
    $0.RemoveDeviceRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeDevice, request, options: options);
  }

  /// ===========================================================================
  /// ORG INVITE MANAGEMENT
  /// ===========================================================================
  $grpc.ResponseFuture<$0.ListActiveOrgInvitesResponse> listActiveOrgInvites(
    $0.ListActiveOrgInvitesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listActiveOrgInvites, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> revokeOrgInvite(
    $0.RevokeOrgInviteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revokeOrgInvite, request, options: options);
  }

  /// ===========================================================================
  /// TEMPLATE MANAGEMENT (Encrypted blobs - metadata only)
  /// ===========================================================================
  $grpc.ResponseFuture<$0.ListUserTemplatesResponse> listUserTemplates(
    $0.ListUserTemplatesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listUserTemplates, request, options: options);
  }

  $grpc.ResponseFuture<$0.TemplateStats> getTemplateStats(
    $0.GetTemplateStatsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTemplateStats, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> deleteUserTemplates(
    $0.DeleteUserTemplatesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteUserTemplates, request, options: options);
  }

  /// ===========================================================================
  /// LICENSE/BILLING MANAGEMENT
  /// ===========================================================================
  $grpc.ResponseFuture<$0.ListLicensesResponse> listLicenses(
    $0.ListLicensesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listLicenses, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> revokeLicense(
    $0.RevokeLicenseRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revokeLicense, request, options: options);
  }

  $grpc.ResponseFuture<$0.PromoCode> createPromoCode(
    $0.CreatePromoCodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createPromoCode, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListPromoCodesResponse> listPromoCodes(
    $0.ListPromoCodesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listPromoCodes, request, options: options);
  }

  /// ===========================================================================
  /// SYSTEM CONFIGURATION
  /// ===========================================================================
  $grpc.ResponseFuture<$0.HubConfig> getConfig(
    $0.GetConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getConfig, request, options: options);
  }

  $grpc.ResponseFuture<$0.HubConfig> updateConfig(
    $0.UpdateConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateConfig, request, options: options);
  }

  /// ===========================================================================
  /// MAINTENANCE & ANNOUNCEMENTS
  /// ===========================================================================
  $grpc.ResponseFuture<$0.MaintenanceStatus> getMaintenanceStatus(
    $0.GetMaintenanceStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getMaintenanceStatus, request, options: options);
  }

  $grpc.ResponseFuture<$0.MaintenanceStatus> setMaintenanceMode(
    $0.SetMaintenanceModeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setMaintenanceMode, request, options: options);
  }

  $grpc.ResponseFuture<$0.BroadcastAnnouncementResponse> broadcastAnnouncement(
    $0.BroadcastAnnouncementRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$broadcastAnnouncement, request, options: options);
  }

  /// ===========================================================================
  /// ACTIVE STREAMS & CONNECTIONS
  /// ===========================================================================
  $grpc.ResponseFuture<$0.GetActiveStreamsResponse> getActiveStreams(
    $0.GetActiveStreamsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getActiveStreams, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetRateLimitStatusResponse> getRateLimitStatus(
    $0.GetRateLimitStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getRateLimitStatus, request, options: options);
  }

  /// ===========================================================================
  /// CERTIFICATE MANAGEMENT
  /// ===========================================================================
  $grpc.ResponseFuture<$0.ListAllRevocationsResponse> listAllRevocations(
    $0.ListAllRevocationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listAllRevocations, request, options: options);
  }

  $grpc.ResponseFuture<$0.HubCertInfo> getHubCertInfo(
    $0.GetHubCertInfoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHubCertInfo, request, options: options);
  }

  $grpc.ResponseFuture<$0.HubCertInfo> rotateHubLeafCert(
    $0.RotateHubLeafCertRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$rotateHubLeafCert, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> revokeCertificate(
    $0.RevokeCertificateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revokeCertificate, request, options: options);
  }

  /// ===========================================================================
  /// INVITE CODE MANAGEMENT
  /// ===========================================================================
  $grpc.ResponseFuture<$0.ListInviteCodesResponse> listInviteCodes(
    $0.ListInviteCodesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listInviteCodes, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> upsertInviteCode(
    $0.InviteCode request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$upsertInviteCode, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> deleteInviteCode(
    $0.DeleteInviteCodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteInviteCode, request, options: options);
  }

  $grpc.ResponseFuture<$0.InviteCode> recalculateInviteCodeUsage(
    $0.RecalculateInviteCodeUsageRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$recalculateInviteCodeUsage, request,
        options: options);
  }

  /// ===========================================================================
  /// RAW DATA ACCESS (For Security Testing / Debugging)
  /// ===========================================================================
  $grpc.ResponseFuture<$0.DumpEncryptedBlobsResponse> dumpEncryptedBlobs(
    $0.DumpEncryptedBlobsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$dumpEncryptedBlobs, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetBlindIndicesResponse> getBlindIndices(
    $0.GetBlindIndicesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getBlindIndices, request, options: options);
  }

  // method descriptors

  static final _$getSystemStats =
      $grpc.ClientMethod<$0.GetSystemStatsRequest, $0.SystemStats>(
          '/nitella.hub.AdminService/GetSystemStats',
          ($0.GetSystemStatsRequest value) => value.writeToBuffer(),
          $0.SystemStats.fromBuffer);
  static final _$getAuditLog =
      $grpc.ClientMethod<$0.GetAuditLogRequest, $0.GetAuditLogResponse>(
          '/nitella.hub.AdminService/GetAuditLog',
          ($0.GetAuditLogRequest value) => value.writeToBuffer(),
          $0.GetAuditLogResponse.fromBuffer);
  static final _$getDatabaseStats =
      $grpc.ClientMethod<$0.GetDatabaseStatsRequest, $0.DatabaseStats>(
          '/nitella.hub.AdminService/GetDatabaseStats',
          ($0.GetDatabaseStatsRequest value) => value.writeToBuffer(),
          $0.DatabaseStats.fromBuffer);
  static final _$listAllUsers =
      $grpc.ClientMethod<$0.ListAllUsersRequest, $0.ListAllUsersResponse>(
          '/nitella.hub.AdminService/ListAllUsers',
          ($0.ListAllUsersRequest value) => value.writeToBuffer(),
          $0.ListAllUsersResponse.fromBuffer);
  static final _$getUserDetails =
      $grpc.ClientMethod<$0.GetUserDetailsRequest, $0.UserDetails>(
          '/nitella.hub.AdminService/GetUserDetails',
          ($0.GetUserDetailsRequest value) => value.writeToBuffer(),
          $0.UserDetails.fromBuffer);
  static final _$setUserTier =
      $grpc.ClientMethod<$0.SetUserTierRequest, $1.User>(
          '/nitella.hub.AdminService/SetUserTier',
          ($0.SetUserTierRequest value) => value.writeToBuffer(),
          $1.User.fromBuffer);
  static final _$banUser = $grpc.ClientMethod<$0.BanUserRequest, $1.Empty>(
      '/nitella.hub.AdminService/BanUser',
      ($0.BanUserRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$unbanUser = $grpc.ClientMethod<$0.UnbanUserRequest, $1.Empty>(
      '/nitella.hub.AdminService/UnbanUser',
      ($0.UnbanUserRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$deleteUser =
      $grpc.ClientMethod<$0.DeleteUserRequest, $1.Empty>(
          '/nitella.hub.AdminService/DeleteUser',
          ($0.DeleteUserRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$listAllNodes =
      $grpc.ClientMethod<$0.ListAllNodesRequest, $0.ListAllNodesResponse>(
          '/nitella.hub.AdminService/ListAllNodes',
          ($0.ListAllNodesRequest value) => value.writeToBuffer(),
          $0.ListAllNodesResponse.fromBuffer);
  static final _$getNodeDetails =
      $grpc.ClientMethod<$0.GetNodeDetailsRequest, $0.NodeDetails>(
          '/nitella.hub.AdminService/GetNodeDetails',
          ($0.GetNodeDetailsRequest value) => value.writeToBuffer(),
          $0.NodeDetails.fromBuffer);
  static final _$forceDisconnectNode =
      $grpc.ClientMethod<$0.ForceDisconnectNodeRequest, $1.Empty>(
          '/nitella.hub.AdminService/ForceDisconnectNode',
          ($0.ForceDisconnectNodeRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$deleteNode =
      $grpc.ClientMethod<$0.AdminDeleteNodeRequest, $1.Empty>(
          '/nitella.hub.AdminService/DeleteNode',
          ($0.AdminDeleteNodeRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$listOrganizations = $grpc.ClientMethod<
          $0.ListOrganizationsRequest, $0.ListOrganizationsResponse>(
      '/nitella.hub.AdminService/ListOrganizations',
      ($0.ListOrganizationsRequest value) => value.writeToBuffer(),
      $0.ListOrganizationsResponse.fromBuffer);
  static final _$getOrganization =
      $grpc.ClientMethod<$0.GetOrganizationRequest, $0.OrganizationDetails>(
          '/nitella.hub.AdminService/GetOrganization',
          ($0.GetOrganizationRequest value) => value.writeToBuffer(),
          $0.OrganizationDetails.fromBuffer);
  static final _$setOrganizationTier =
      $grpc.ClientMethod<$0.SetOrganizationTierRequest, $0.Organization>(
          '/nitella.hub.AdminService/SetOrganizationTier',
          ($0.SetOrganizationTierRequest value) => value.writeToBuffer(),
          $0.Organization.fromBuffer);
  static final _$deleteOrganization =
      $grpc.ClientMethod<$0.DeleteOrganizationRequest, $1.Empty>(
          '/nitella.hub.AdminService/DeleteOrganization',
          ($0.DeleteOrganizationRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$listPendingRegistrations = $grpc.ClientMethod<
          $0.ListPendingRegistrationsRequest,
          $0.ListPendingRegistrationsResponse>(
      '/nitella.hub.AdminService/ListPendingRegistrations',
      ($0.ListPendingRegistrationsRequest value) => value.writeToBuffer(),
      $0.ListPendingRegistrationsResponse.fromBuffer);
  static final _$forceApproveRegistration =
      $grpc.ClientMethod<$0.ForceApproveRegistrationRequest, $1.Empty>(
          '/nitella.hub.AdminService/ForceApproveRegistration',
          ($0.ForceApproveRegistrationRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$rejectRegistration =
      $grpc.ClientMethod<$0.RejectRegistrationRequest, $1.Empty>(
          '/nitella.hub.AdminService/RejectRegistration',
          ($0.RejectRegistrationRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$clearStalePairings = $grpc.ClientMethod<
          $0.ClearStalePairingsRequest, $0.ClearStalePairingsResponse>(
      '/nitella.hub.AdminService/ClearStalePairings',
      ($0.ClearStalePairingsRequest value) => value.writeToBuffer(),
      $0.ClearStalePairingsResponse.fromBuffer);
  static final _$listDevices =
      $grpc.ClientMethod<$0.ListDevicesRequest, $0.ListDevicesResponse>(
          '/nitella.hub.AdminService/ListDevices',
          ($0.ListDevicesRequest value) => value.writeToBuffer(),
          $0.ListDevicesResponse.fromBuffer);
  static final _$getUserDevices =
      $grpc.ClientMethod<$0.GetUserDevicesRequest, $0.ListDevicesResponse>(
          '/nitella.hub.AdminService/GetUserDevices',
          ($0.GetUserDevicesRequest value) => value.writeToBuffer(),
          $0.ListDevicesResponse.fromBuffer);
  static final _$removeDevice =
      $grpc.ClientMethod<$0.RemoveDeviceRequest, $1.Empty>(
          '/nitella.hub.AdminService/RemoveDevice',
          ($0.RemoveDeviceRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$listActiveOrgInvites = $grpc.ClientMethod<
          $0.ListActiveOrgInvitesRequest, $0.ListActiveOrgInvitesResponse>(
      '/nitella.hub.AdminService/ListActiveOrgInvites',
      ($0.ListActiveOrgInvitesRequest value) => value.writeToBuffer(),
      $0.ListActiveOrgInvitesResponse.fromBuffer);
  static final _$revokeOrgInvite =
      $grpc.ClientMethod<$0.RevokeOrgInviteRequest, $1.Empty>(
          '/nitella.hub.AdminService/RevokeOrgInvite',
          ($0.RevokeOrgInviteRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$listUserTemplates = $grpc.ClientMethod<
          $0.ListUserTemplatesRequest, $0.ListUserTemplatesResponse>(
      '/nitella.hub.AdminService/ListUserTemplates',
      ($0.ListUserTemplatesRequest value) => value.writeToBuffer(),
      $0.ListUserTemplatesResponse.fromBuffer);
  static final _$getTemplateStats =
      $grpc.ClientMethod<$0.GetTemplateStatsRequest, $0.TemplateStats>(
          '/nitella.hub.AdminService/GetTemplateStats',
          ($0.GetTemplateStatsRequest value) => value.writeToBuffer(),
          $0.TemplateStats.fromBuffer);
  static final _$deleteUserTemplates =
      $grpc.ClientMethod<$0.DeleteUserTemplatesRequest, $1.Empty>(
          '/nitella.hub.AdminService/DeleteUserTemplates',
          ($0.DeleteUserTemplatesRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$listLicenses =
      $grpc.ClientMethod<$0.ListLicensesRequest, $0.ListLicensesResponse>(
          '/nitella.hub.AdminService/ListLicenses',
          ($0.ListLicensesRequest value) => value.writeToBuffer(),
          $0.ListLicensesResponse.fromBuffer);
  static final _$revokeLicense =
      $grpc.ClientMethod<$0.RevokeLicenseRequest, $1.Empty>(
          '/nitella.hub.AdminService/RevokeLicense',
          ($0.RevokeLicenseRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$createPromoCode =
      $grpc.ClientMethod<$0.CreatePromoCodeRequest, $0.PromoCode>(
          '/nitella.hub.AdminService/CreatePromoCode',
          ($0.CreatePromoCodeRequest value) => value.writeToBuffer(),
          $0.PromoCode.fromBuffer);
  static final _$listPromoCodes =
      $grpc.ClientMethod<$0.ListPromoCodesRequest, $0.ListPromoCodesResponse>(
          '/nitella.hub.AdminService/ListPromoCodes',
          ($0.ListPromoCodesRequest value) => value.writeToBuffer(),
          $0.ListPromoCodesResponse.fromBuffer);
  static final _$getConfig =
      $grpc.ClientMethod<$0.GetConfigRequest, $0.HubConfig>(
          '/nitella.hub.AdminService/GetConfig',
          ($0.GetConfigRequest value) => value.writeToBuffer(),
          $0.HubConfig.fromBuffer);
  static final _$updateConfig =
      $grpc.ClientMethod<$0.UpdateConfigRequest, $0.HubConfig>(
          '/nitella.hub.AdminService/UpdateConfig',
          ($0.UpdateConfigRequest value) => value.writeToBuffer(),
          $0.HubConfig.fromBuffer);
  static final _$getMaintenanceStatus =
      $grpc.ClientMethod<$0.GetMaintenanceStatusRequest, $0.MaintenanceStatus>(
          '/nitella.hub.AdminService/GetMaintenanceStatus',
          ($0.GetMaintenanceStatusRequest value) => value.writeToBuffer(),
          $0.MaintenanceStatus.fromBuffer);
  static final _$setMaintenanceMode =
      $grpc.ClientMethod<$0.SetMaintenanceModeRequest, $0.MaintenanceStatus>(
          '/nitella.hub.AdminService/SetMaintenanceMode',
          ($0.SetMaintenanceModeRequest value) => value.writeToBuffer(),
          $0.MaintenanceStatus.fromBuffer);
  static final _$broadcastAnnouncement = $grpc.ClientMethod<
          $0.BroadcastAnnouncementRequest, $0.BroadcastAnnouncementResponse>(
      '/nitella.hub.AdminService/BroadcastAnnouncement',
      ($0.BroadcastAnnouncementRequest value) => value.writeToBuffer(),
      $0.BroadcastAnnouncementResponse.fromBuffer);
  static final _$getActiveStreams = $grpc.ClientMethod<
          $0.GetActiveStreamsRequest, $0.GetActiveStreamsResponse>(
      '/nitella.hub.AdminService/GetActiveStreams',
      ($0.GetActiveStreamsRequest value) => value.writeToBuffer(),
      $0.GetActiveStreamsResponse.fromBuffer);
  static final _$getRateLimitStatus = $grpc.ClientMethod<
          $0.GetRateLimitStatusRequest, $0.GetRateLimitStatusResponse>(
      '/nitella.hub.AdminService/GetRateLimitStatus',
      ($0.GetRateLimitStatusRequest value) => value.writeToBuffer(),
      $0.GetRateLimitStatusResponse.fromBuffer);
  static final _$listAllRevocations = $grpc.ClientMethod<
          $0.ListAllRevocationsRequest, $0.ListAllRevocationsResponse>(
      '/nitella.hub.AdminService/ListAllRevocations',
      ($0.ListAllRevocationsRequest value) => value.writeToBuffer(),
      $0.ListAllRevocationsResponse.fromBuffer);
  static final _$getHubCertInfo =
      $grpc.ClientMethod<$0.GetHubCertInfoRequest, $0.HubCertInfo>(
          '/nitella.hub.AdminService/GetHubCertInfo',
          ($0.GetHubCertInfoRequest value) => value.writeToBuffer(),
          $0.HubCertInfo.fromBuffer);
  static final _$rotateHubLeafCert =
      $grpc.ClientMethod<$0.RotateHubLeafCertRequest, $0.HubCertInfo>(
          '/nitella.hub.AdminService/RotateHubLeafCert',
          ($0.RotateHubLeafCertRequest value) => value.writeToBuffer(),
          $0.HubCertInfo.fromBuffer);
  static final _$revokeCertificate =
      $grpc.ClientMethod<$0.RevokeCertificateRequest, $1.Empty>(
          '/nitella.hub.AdminService/RevokeCertificate',
          ($0.RevokeCertificateRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$listInviteCodes =
      $grpc.ClientMethod<$0.ListInviteCodesRequest, $0.ListInviteCodesResponse>(
          '/nitella.hub.AdminService/ListInviteCodes',
          ($0.ListInviteCodesRequest value) => value.writeToBuffer(),
          $0.ListInviteCodesResponse.fromBuffer);
  static final _$upsertInviteCode = $grpc.ClientMethod<$0.InviteCode, $1.Empty>(
      '/nitella.hub.AdminService/UpsertInviteCode',
      ($0.InviteCode value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$deleteInviteCode =
      $grpc.ClientMethod<$0.DeleteInviteCodeRequest, $1.Empty>(
          '/nitella.hub.AdminService/DeleteInviteCode',
          ($0.DeleteInviteCodeRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$recalculateInviteCodeUsage =
      $grpc.ClientMethod<$0.RecalculateInviteCodeUsageRequest, $0.InviteCode>(
          '/nitella.hub.AdminService/RecalculateInviteCodeUsage',
          ($0.RecalculateInviteCodeUsageRequest value) => value.writeToBuffer(),
          $0.InviteCode.fromBuffer);
  static final _$dumpEncryptedBlobs = $grpc.ClientMethod<
          $0.DumpEncryptedBlobsRequest, $0.DumpEncryptedBlobsResponse>(
      '/nitella.hub.AdminService/DumpEncryptedBlobs',
      ($0.DumpEncryptedBlobsRequest value) => value.writeToBuffer(),
      $0.DumpEncryptedBlobsResponse.fromBuffer);
  static final _$getBlindIndices =
      $grpc.ClientMethod<$0.GetBlindIndicesRequest, $0.GetBlindIndicesResponse>(
          '/nitella.hub.AdminService/GetBlindIndices',
          ($0.GetBlindIndicesRequest value) => value.writeToBuffer(),
          $0.GetBlindIndicesResponse.fromBuffer);
}

@$pb.GrpcServiceName('nitella.hub.AdminService')
abstract class AdminServiceBase extends $grpc.Service {
  $core.String get $name => 'nitella.hub.AdminService';

  AdminServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetSystemStatsRequest, $0.SystemStats>(
        'GetSystemStats',
        getSystemStats_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetSystemStatsRequest.fromBuffer(value),
        ($0.SystemStats value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetAuditLogRequest, $0.GetAuditLogResponse>(
            'GetAuditLog',
            getAuditLog_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetAuditLogRequest.fromBuffer(value),
            ($0.GetAuditLogResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetDatabaseStatsRequest, $0.DatabaseStats>(
            'GetDatabaseStats',
            getDatabaseStats_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetDatabaseStatsRequest.fromBuffer(value),
            ($0.DatabaseStats value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListAllUsersRequest, $0.ListAllUsersResponse>(
            'ListAllUsers',
            listAllUsers_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListAllUsersRequest.fromBuffer(value),
            ($0.ListAllUsersResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetUserDetailsRequest, $0.UserDetails>(
        'GetUserDetails',
        getUserDetails_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetUserDetailsRequest.fromBuffer(value),
        ($0.UserDetails value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetUserTierRequest, $1.User>(
        'SetUserTier',
        setUserTier_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetUserTierRequest.fromBuffer(value),
        ($1.User value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BanUserRequest, $1.Empty>(
        'BanUser',
        banUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BanUserRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnbanUserRequest, $1.Empty>(
        'UnbanUser',
        unbanUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UnbanUserRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteUserRequest, $1.Empty>(
        'DeleteUser',
        deleteUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteUserRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListAllNodesRequest, $0.ListAllNodesResponse>(
            'ListAllNodes',
            listAllNodes_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListAllNodesRequest.fromBuffer(value),
            ($0.ListAllNodesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetNodeDetailsRequest, $0.NodeDetails>(
        'GetNodeDetails',
        getNodeDetails_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetNodeDetailsRequest.fromBuffer(value),
        ($0.NodeDetails value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ForceDisconnectNodeRequest, $1.Empty>(
        'ForceDisconnectNode',
        forceDisconnectNode_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ForceDisconnectNodeRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AdminDeleteNodeRequest, $1.Empty>(
        'DeleteNode',
        deleteNode_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AdminDeleteNodeRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListOrganizationsRequest,
            $0.ListOrganizationsResponse>(
        'ListOrganizations',
        listOrganizations_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListOrganizationsRequest.fromBuffer(value),
        ($0.ListOrganizationsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetOrganizationRequest, $0.OrganizationDetails>(
            'GetOrganization',
            getOrganization_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetOrganizationRequest.fromBuffer(value),
            ($0.OrganizationDetails value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SetOrganizationTierRequest, $0.Organization>(
            'SetOrganizationTier',
            setOrganizationTier_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SetOrganizationTierRequest.fromBuffer(value),
            ($0.Organization value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteOrganizationRequest, $1.Empty>(
        'DeleteOrganization',
        deleteOrganization_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteOrganizationRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListPendingRegistrationsRequest,
            $0.ListPendingRegistrationsResponse>(
        'ListPendingRegistrations',
        listPendingRegistrations_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListPendingRegistrationsRequest.fromBuffer(value),
        ($0.ListPendingRegistrationsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ForceApproveRegistrationRequest, $1.Empty>(
            'ForceApproveRegistration',
            forceApproveRegistration_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ForceApproveRegistrationRequest.fromBuffer(value),
            ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RejectRegistrationRequest, $1.Empty>(
        'RejectRegistration',
        rejectRegistration_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RejectRegistrationRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ClearStalePairingsRequest,
            $0.ClearStalePairingsResponse>(
        'ClearStalePairings',
        clearStalePairings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ClearStalePairingsRequest.fromBuffer(value),
        ($0.ClearStalePairingsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListDevicesRequest, $0.ListDevicesResponse>(
            'ListDevices',
            listDevices_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListDevicesRequest.fromBuffer(value),
            ($0.ListDevicesResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetUserDevicesRequest, $0.ListDevicesResponse>(
            'GetUserDevices',
            getUserDevices_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetUserDevicesRequest.fromBuffer(value),
            ($0.ListDevicesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RemoveDeviceRequest, $1.Empty>(
        'RemoveDevice',
        removeDevice_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RemoveDeviceRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListActiveOrgInvitesRequest,
            $0.ListActiveOrgInvitesResponse>(
        'ListActiveOrgInvites',
        listActiveOrgInvites_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListActiveOrgInvitesRequest.fromBuffer(value),
        ($0.ListActiveOrgInvitesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RevokeOrgInviteRequest, $1.Empty>(
        'RevokeOrgInvite',
        revokeOrgInvite_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RevokeOrgInviteRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListUserTemplatesRequest,
            $0.ListUserTemplatesResponse>(
        'ListUserTemplates',
        listUserTemplates_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListUserTemplatesRequest.fromBuffer(value),
        ($0.ListUserTemplatesResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetTemplateStatsRequest, $0.TemplateStats>(
            'GetTemplateStats',
            getTemplateStats_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetTemplateStatsRequest.fromBuffer(value),
            ($0.TemplateStats value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteUserTemplatesRequest, $1.Empty>(
        'DeleteUserTemplates',
        deleteUserTemplates_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteUserTemplatesRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListLicensesRequest, $0.ListLicensesResponse>(
            'ListLicenses',
            listLicenses_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListLicensesRequest.fromBuffer(value),
            ($0.ListLicensesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RevokeLicenseRequest, $1.Empty>(
        'RevokeLicense',
        revokeLicense_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RevokeLicenseRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreatePromoCodeRequest, $0.PromoCode>(
        'CreatePromoCode',
        createPromoCode_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreatePromoCodeRequest.fromBuffer(value),
        ($0.PromoCode value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListPromoCodesRequest,
            $0.ListPromoCodesResponse>(
        'ListPromoCodes',
        listPromoCodes_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListPromoCodesRequest.fromBuffer(value),
        ($0.ListPromoCodesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetConfigRequest, $0.HubConfig>(
        'GetConfig',
        getConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetConfigRequest.fromBuffer(value),
        ($0.HubConfig value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateConfigRequest, $0.HubConfig>(
        'UpdateConfig',
        updateConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateConfigRequest.fromBuffer(value),
        ($0.HubConfig value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetMaintenanceStatusRequest,
            $0.MaintenanceStatus>(
        'GetMaintenanceStatus',
        getMaintenanceStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetMaintenanceStatusRequest.fromBuffer(value),
        ($0.MaintenanceStatus value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SetMaintenanceModeRequest, $0.MaintenanceStatus>(
            'SetMaintenanceMode',
            setMaintenanceMode_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SetMaintenanceModeRequest.fromBuffer(value),
            ($0.MaintenanceStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BroadcastAnnouncementRequest,
            $0.BroadcastAnnouncementResponse>(
        'BroadcastAnnouncement',
        broadcastAnnouncement_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.BroadcastAnnouncementRequest.fromBuffer(value),
        ($0.BroadcastAnnouncementResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetActiveStreamsRequest,
            $0.GetActiveStreamsResponse>(
        'GetActiveStreams',
        getActiveStreams_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetActiveStreamsRequest.fromBuffer(value),
        ($0.GetActiveStreamsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetRateLimitStatusRequest,
            $0.GetRateLimitStatusResponse>(
        'GetRateLimitStatus',
        getRateLimitStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetRateLimitStatusRequest.fromBuffer(value),
        ($0.GetRateLimitStatusResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListAllRevocationsRequest,
            $0.ListAllRevocationsResponse>(
        'ListAllRevocations',
        listAllRevocations_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListAllRevocationsRequest.fromBuffer(value),
        ($0.ListAllRevocationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetHubCertInfoRequest, $0.HubCertInfo>(
        'GetHubCertInfo',
        getHubCertInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetHubCertInfoRequest.fromBuffer(value),
        ($0.HubCertInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RotateHubLeafCertRequest, $0.HubCertInfo>(
        'RotateHubLeafCert',
        rotateHubLeafCert_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RotateHubLeafCertRequest.fromBuffer(value),
        ($0.HubCertInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RevokeCertificateRequest, $1.Empty>(
        'RevokeCertificate',
        revokeCertificate_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RevokeCertificateRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListInviteCodesRequest,
            $0.ListInviteCodesResponse>(
        'ListInviteCodes',
        listInviteCodes_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListInviteCodesRequest.fromBuffer(value),
        ($0.ListInviteCodesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.InviteCode, $1.Empty>(
        'UpsertInviteCode',
        upsertInviteCode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.InviteCode.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteInviteCodeRequest, $1.Empty>(
        'DeleteInviteCode',
        deleteInviteCode_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteInviteCodeRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RecalculateInviteCodeUsageRequest,
            $0.InviteCode>(
        'RecalculateInviteCodeUsage',
        recalculateInviteCodeUsage_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RecalculateInviteCodeUsageRequest.fromBuffer(value),
        ($0.InviteCode value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DumpEncryptedBlobsRequest,
            $0.DumpEncryptedBlobsResponse>(
        'DumpEncryptedBlobs',
        dumpEncryptedBlobs_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DumpEncryptedBlobsRequest.fromBuffer(value),
        ($0.DumpEncryptedBlobsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetBlindIndicesRequest,
            $0.GetBlindIndicesResponse>(
        'GetBlindIndices',
        getBlindIndices_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetBlindIndicesRequest.fromBuffer(value),
        ($0.GetBlindIndicesResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.SystemStats> getSystemStats_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetSystemStatsRequest> $request) async {
    return getSystemStats($call, await $request);
  }

  $async.Future<$0.SystemStats> getSystemStats(
      $grpc.ServiceCall call, $0.GetSystemStatsRequest request);

  $async.Future<$0.GetAuditLogResponse> getAuditLog_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetAuditLogRequest> $request) async {
    return getAuditLog($call, await $request);
  }

  $async.Future<$0.GetAuditLogResponse> getAuditLog(
      $grpc.ServiceCall call, $0.GetAuditLogRequest request);

  $async.Future<$0.DatabaseStats> getDatabaseStats_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetDatabaseStatsRequest> $request) async {
    return getDatabaseStats($call, await $request);
  }

  $async.Future<$0.DatabaseStats> getDatabaseStats(
      $grpc.ServiceCall call, $0.GetDatabaseStatsRequest request);

  $async.Future<$0.ListAllUsersResponse> listAllUsers_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListAllUsersRequest> $request) async {
    return listAllUsers($call, await $request);
  }

  $async.Future<$0.ListAllUsersResponse> listAllUsers(
      $grpc.ServiceCall call, $0.ListAllUsersRequest request);

  $async.Future<$0.UserDetails> getUserDetails_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetUserDetailsRequest> $request) async {
    return getUserDetails($call, await $request);
  }

  $async.Future<$0.UserDetails> getUserDetails(
      $grpc.ServiceCall call, $0.GetUserDetailsRequest request);

  $async.Future<$1.User> setUserTier_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetUserTierRequest> $request) async {
    return setUserTier($call, await $request);
  }

  $async.Future<$1.User> setUserTier(
      $grpc.ServiceCall call, $0.SetUserTierRequest request);

  $async.Future<$1.Empty> banUser_Pre($grpc.ServiceCall $call,
      $async.Future<$0.BanUserRequest> $request) async {
    return banUser($call, await $request);
  }

  $async.Future<$1.Empty> banUser(
      $grpc.ServiceCall call, $0.BanUserRequest request);

  $async.Future<$1.Empty> unbanUser_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UnbanUserRequest> $request) async {
    return unbanUser($call, await $request);
  }

  $async.Future<$1.Empty> unbanUser(
      $grpc.ServiceCall call, $0.UnbanUserRequest request);

  $async.Future<$1.Empty> deleteUser_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteUserRequest> $request) async {
    return deleteUser($call, await $request);
  }

  $async.Future<$1.Empty> deleteUser(
      $grpc.ServiceCall call, $0.DeleteUserRequest request);

  $async.Future<$0.ListAllNodesResponse> listAllNodes_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListAllNodesRequest> $request) async {
    return listAllNodes($call, await $request);
  }

  $async.Future<$0.ListAllNodesResponse> listAllNodes(
      $grpc.ServiceCall call, $0.ListAllNodesRequest request);

  $async.Future<$0.NodeDetails> getNodeDetails_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetNodeDetailsRequest> $request) async {
    return getNodeDetails($call, await $request);
  }

  $async.Future<$0.NodeDetails> getNodeDetails(
      $grpc.ServiceCall call, $0.GetNodeDetailsRequest request);

  $async.Future<$1.Empty> forceDisconnectNode_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ForceDisconnectNodeRequest> $request) async {
    return forceDisconnectNode($call, await $request);
  }

  $async.Future<$1.Empty> forceDisconnectNode(
      $grpc.ServiceCall call, $0.ForceDisconnectNodeRequest request);

  $async.Future<$1.Empty> deleteNode_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AdminDeleteNodeRequest> $request) async {
    return deleteNode($call, await $request);
  }

  $async.Future<$1.Empty> deleteNode(
      $grpc.ServiceCall call, $0.AdminDeleteNodeRequest request);

  $async.Future<$0.ListOrganizationsResponse> listOrganizations_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListOrganizationsRequest> $request) async {
    return listOrganizations($call, await $request);
  }

  $async.Future<$0.ListOrganizationsResponse> listOrganizations(
      $grpc.ServiceCall call, $0.ListOrganizationsRequest request);

  $async.Future<$0.OrganizationDetails> getOrganization_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetOrganizationRequest> $request) async {
    return getOrganization($call, await $request);
  }

  $async.Future<$0.OrganizationDetails> getOrganization(
      $grpc.ServiceCall call, $0.GetOrganizationRequest request);

  $async.Future<$0.Organization> setOrganizationTier_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SetOrganizationTierRequest> $request) async {
    return setOrganizationTier($call, await $request);
  }

  $async.Future<$0.Organization> setOrganizationTier(
      $grpc.ServiceCall call, $0.SetOrganizationTierRequest request);

  $async.Future<$1.Empty> deleteOrganization_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteOrganizationRequest> $request) async {
    return deleteOrganization($call, await $request);
  }

  $async.Future<$1.Empty> deleteOrganization(
      $grpc.ServiceCall call, $0.DeleteOrganizationRequest request);

  $async.Future<$0.ListPendingRegistrationsResponse>
      listPendingRegistrations_Pre($grpc.ServiceCall $call,
          $async.Future<$0.ListPendingRegistrationsRequest> $request) async {
    return listPendingRegistrations($call, await $request);
  }

  $async.Future<$0.ListPendingRegistrationsResponse> listPendingRegistrations(
      $grpc.ServiceCall call, $0.ListPendingRegistrationsRequest request);

  $async.Future<$1.Empty> forceApproveRegistration_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ForceApproveRegistrationRequest> $request) async {
    return forceApproveRegistration($call, await $request);
  }

  $async.Future<$1.Empty> forceApproveRegistration(
      $grpc.ServiceCall call, $0.ForceApproveRegistrationRequest request);

  $async.Future<$1.Empty> rejectRegistration_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RejectRegistrationRequest> $request) async {
    return rejectRegistration($call, await $request);
  }

  $async.Future<$1.Empty> rejectRegistration(
      $grpc.ServiceCall call, $0.RejectRegistrationRequest request);

  $async.Future<$0.ClearStalePairingsResponse> clearStalePairings_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ClearStalePairingsRequest> $request) async {
    return clearStalePairings($call, await $request);
  }

  $async.Future<$0.ClearStalePairingsResponse> clearStalePairings(
      $grpc.ServiceCall call, $0.ClearStalePairingsRequest request);

  $async.Future<$0.ListDevicesResponse> listDevices_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListDevicesRequest> $request) async {
    return listDevices($call, await $request);
  }

  $async.Future<$0.ListDevicesResponse> listDevices(
      $grpc.ServiceCall call, $0.ListDevicesRequest request);

  $async.Future<$0.ListDevicesResponse> getUserDevices_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetUserDevicesRequest> $request) async {
    return getUserDevices($call, await $request);
  }

  $async.Future<$0.ListDevicesResponse> getUserDevices(
      $grpc.ServiceCall call, $0.GetUserDevicesRequest request);

  $async.Future<$1.Empty> removeDevice_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RemoveDeviceRequest> $request) async {
    return removeDevice($call, await $request);
  }

  $async.Future<$1.Empty> removeDevice(
      $grpc.ServiceCall call, $0.RemoveDeviceRequest request);

  $async.Future<$0.ListActiveOrgInvitesResponse> listActiveOrgInvites_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListActiveOrgInvitesRequest> $request) async {
    return listActiveOrgInvites($call, await $request);
  }

  $async.Future<$0.ListActiveOrgInvitesResponse> listActiveOrgInvites(
      $grpc.ServiceCall call, $0.ListActiveOrgInvitesRequest request);

  $async.Future<$1.Empty> revokeOrgInvite_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RevokeOrgInviteRequest> $request) async {
    return revokeOrgInvite($call, await $request);
  }

  $async.Future<$1.Empty> revokeOrgInvite(
      $grpc.ServiceCall call, $0.RevokeOrgInviteRequest request);

  $async.Future<$0.ListUserTemplatesResponse> listUserTemplates_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListUserTemplatesRequest> $request) async {
    return listUserTemplates($call, await $request);
  }

  $async.Future<$0.ListUserTemplatesResponse> listUserTemplates(
      $grpc.ServiceCall call, $0.ListUserTemplatesRequest request);

  $async.Future<$0.TemplateStats> getTemplateStats_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetTemplateStatsRequest> $request) async {
    return getTemplateStats($call, await $request);
  }

  $async.Future<$0.TemplateStats> getTemplateStats(
      $grpc.ServiceCall call, $0.GetTemplateStatsRequest request);

  $async.Future<$1.Empty> deleteUserTemplates_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteUserTemplatesRequest> $request) async {
    return deleteUserTemplates($call, await $request);
  }

  $async.Future<$1.Empty> deleteUserTemplates(
      $grpc.ServiceCall call, $0.DeleteUserTemplatesRequest request);

  $async.Future<$0.ListLicensesResponse> listLicenses_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListLicensesRequest> $request) async {
    return listLicenses($call, await $request);
  }

  $async.Future<$0.ListLicensesResponse> listLicenses(
      $grpc.ServiceCall call, $0.ListLicensesRequest request);

  $async.Future<$1.Empty> revokeLicense_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RevokeLicenseRequest> $request) async {
    return revokeLicense($call, await $request);
  }

  $async.Future<$1.Empty> revokeLicense(
      $grpc.ServiceCall call, $0.RevokeLicenseRequest request);

  $async.Future<$0.PromoCode> createPromoCode_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreatePromoCodeRequest> $request) async {
    return createPromoCode($call, await $request);
  }

  $async.Future<$0.PromoCode> createPromoCode(
      $grpc.ServiceCall call, $0.CreatePromoCodeRequest request);

  $async.Future<$0.ListPromoCodesResponse> listPromoCodes_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListPromoCodesRequest> $request) async {
    return listPromoCodes($call, await $request);
  }

  $async.Future<$0.ListPromoCodesResponse> listPromoCodes(
      $grpc.ServiceCall call, $0.ListPromoCodesRequest request);

  $async.Future<$0.HubConfig> getConfig_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetConfigRequest> $request) async {
    return getConfig($call, await $request);
  }

  $async.Future<$0.HubConfig> getConfig(
      $grpc.ServiceCall call, $0.GetConfigRequest request);

  $async.Future<$0.HubConfig> updateConfig_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateConfigRequest> $request) async {
    return updateConfig($call, await $request);
  }

  $async.Future<$0.HubConfig> updateConfig(
      $grpc.ServiceCall call, $0.UpdateConfigRequest request);

  $async.Future<$0.MaintenanceStatus> getMaintenanceStatus_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetMaintenanceStatusRequest> $request) async {
    return getMaintenanceStatus($call, await $request);
  }

  $async.Future<$0.MaintenanceStatus> getMaintenanceStatus(
      $grpc.ServiceCall call, $0.GetMaintenanceStatusRequest request);

  $async.Future<$0.MaintenanceStatus> setMaintenanceMode_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SetMaintenanceModeRequest> $request) async {
    return setMaintenanceMode($call, await $request);
  }

  $async.Future<$0.MaintenanceStatus> setMaintenanceMode(
      $grpc.ServiceCall call, $0.SetMaintenanceModeRequest request);

  $async.Future<$0.BroadcastAnnouncementResponse> broadcastAnnouncement_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.BroadcastAnnouncementRequest> $request) async {
    return broadcastAnnouncement($call, await $request);
  }

  $async.Future<$0.BroadcastAnnouncementResponse> broadcastAnnouncement(
      $grpc.ServiceCall call, $0.BroadcastAnnouncementRequest request);

  $async.Future<$0.GetActiveStreamsResponse> getActiveStreams_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetActiveStreamsRequest> $request) async {
    return getActiveStreams($call, await $request);
  }

  $async.Future<$0.GetActiveStreamsResponse> getActiveStreams(
      $grpc.ServiceCall call, $0.GetActiveStreamsRequest request);

  $async.Future<$0.GetRateLimitStatusResponse> getRateLimitStatus_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetRateLimitStatusRequest> $request) async {
    return getRateLimitStatus($call, await $request);
  }

  $async.Future<$0.GetRateLimitStatusResponse> getRateLimitStatus(
      $grpc.ServiceCall call, $0.GetRateLimitStatusRequest request);

  $async.Future<$0.ListAllRevocationsResponse> listAllRevocations_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListAllRevocationsRequest> $request) async {
    return listAllRevocations($call, await $request);
  }

  $async.Future<$0.ListAllRevocationsResponse> listAllRevocations(
      $grpc.ServiceCall call, $0.ListAllRevocationsRequest request);

  $async.Future<$0.HubCertInfo> getHubCertInfo_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetHubCertInfoRequest> $request) async {
    return getHubCertInfo($call, await $request);
  }

  $async.Future<$0.HubCertInfo> getHubCertInfo(
      $grpc.ServiceCall call, $0.GetHubCertInfoRequest request);

  $async.Future<$0.HubCertInfo> rotateHubLeafCert_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RotateHubLeafCertRequest> $request) async {
    return rotateHubLeafCert($call, await $request);
  }

  $async.Future<$0.HubCertInfo> rotateHubLeafCert(
      $grpc.ServiceCall call, $0.RotateHubLeafCertRequest request);

  $async.Future<$1.Empty> revokeCertificate_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RevokeCertificateRequest> $request) async {
    return revokeCertificate($call, await $request);
  }

  $async.Future<$1.Empty> revokeCertificate(
      $grpc.ServiceCall call, $0.RevokeCertificateRequest request);

  $async.Future<$0.ListInviteCodesResponse> listInviteCodes_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListInviteCodesRequest> $request) async {
    return listInviteCodes($call, await $request);
  }

  $async.Future<$0.ListInviteCodesResponse> listInviteCodes(
      $grpc.ServiceCall call, $0.ListInviteCodesRequest request);

  $async.Future<$1.Empty> upsertInviteCode_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.InviteCode> $request) async {
    return upsertInviteCode($call, await $request);
  }

  $async.Future<$1.Empty> upsertInviteCode(
      $grpc.ServiceCall call, $0.InviteCode request);

  $async.Future<$1.Empty> deleteInviteCode_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteInviteCodeRequest> $request) async {
    return deleteInviteCode($call, await $request);
  }

  $async.Future<$1.Empty> deleteInviteCode(
      $grpc.ServiceCall call, $0.DeleteInviteCodeRequest request);

  $async.Future<$0.InviteCode> recalculateInviteCodeUsage_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RecalculateInviteCodeUsageRequest> $request) async {
    return recalculateInviteCodeUsage($call, await $request);
  }

  $async.Future<$0.InviteCode> recalculateInviteCodeUsage(
      $grpc.ServiceCall call, $0.RecalculateInviteCodeUsageRequest request);

  $async.Future<$0.DumpEncryptedBlobsResponse> dumpEncryptedBlobs_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DumpEncryptedBlobsRequest> $request) async {
    return dumpEncryptedBlobs($call, await $request);
  }

  $async.Future<$0.DumpEncryptedBlobsResponse> dumpEncryptedBlobs(
      $grpc.ServiceCall call, $0.DumpEncryptedBlobsRequest request);

  $async.Future<$0.GetBlindIndicesResponse> getBlindIndices_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetBlindIndicesRequest> $request) async {
    return getBlindIndices($call, await $request);
  }

  $async.Future<$0.GetBlindIndicesResponse> getBlindIndices(
      $grpc.ServiceCall call, $0.GetBlindIndicesRequest request);
}
