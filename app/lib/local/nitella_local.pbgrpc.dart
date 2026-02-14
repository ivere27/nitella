// This is a generated file - do not edit.
//
// Generated from local/nitella_local.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;

import '../proxy/proxy.pb.dart' as $2;
import 'nitella_local.pb.dart' as $0;

export 'nitella_local.pb.dart';

@$pb.GrpcServiceName('nitella.local.MobileLogicService')
class MobileLogicServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  MobileLogicServiceClient(super.channel, {super.options, super.interceptors});

  /// Initialize the mobile backend with data directory
  $grpc.ResponseFuture<$0.InitializeResponse> initialize(
    $0.InitializeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$initialize, request, options: options);
  }

  /// Shutdown the mobile backend gracefully
  $grpc.ResponseFuture<$1.Empty> shutdown(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$shutdown, request, options: options);
  }

  /// Get backend-owned startup state for app routing (setup/auth/ready)
  $grpc.ResponseFuture<$0.BootstrapStateResponse> getBootstrapState(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getBootstrapState, request, options: options);
  }

  /// Get current identity status
  $grpc.ResponseFuture<$0.IdentityInfo> getIdentity(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getIdentity, request, options: options);
  }

  /// Create new identity with generated mnemonic
  $grpc.ResponseFuture<$0.CreateIdentityResponse> createIdentity(
    $0.CreateIdentityRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createIdentity, request, options: options);
  }

  /// Restore identity from existing mnemonic
  $grpc.ResponseFuture<$0.RestoreIdentityResponse> restoreIdentity(
    $0.RestoreIdentityRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restoreIdentity, request, options: options);
  }

  /// Import identity from certificate/key PEM files
  $grpc.ResponseFuture<$0.ImportIdentityResponse> importIdentity(
    $0.ImportIdentityRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$importIdentity, request, options: options);
  }

  /// Unlock identity with passphrase (if encrypted)
  $grpc.ResponseFuture<$0.UnlockIdentityResponse> unlockIdentity(
    $0.UnlockIdentityRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unlockIdentity, request, options: options);
  }

  /// Lock identity (clear from memory)
  $grpc.ResponseFuture<$1.Empty> lockIdentity(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$lockIdentity, request, options: options);
  }

  /// Change passphrase
  $grpc.ResponseFuture<$1.Empty> changePassphrase(
    $0.ChangePassphraseRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$changePassphrase, request, options: options);
  }

  /// Evaluate passphrase strength/policy (backend-owned security logic)
  $grpc.ResponseFuture<$0.EvaluatePassphraseResponse> evaluatePassphrase(
    $0.EvaluatePassphraseRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$evaluatePassphrase, request, options: options);
  }

  /// Delete identity and all associated data (nodes, settings, templates)
  $grpc.ResponseFuture<$1.Empty> resetIdentity(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$resetIdentity, request, options: options);
  }

  /// List all paired nodes
  $grpc.ResponseFuture<$0.ListNodesResponse> listNodes(
    $0.ListNodesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listNodes, request, options: options);
  }

  /// Get detailed info for a specific node
  $grpc.ResponseFuture<$0.NodeInfo> getNode(
    $0.GetNodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getNode, request, options: options);
  }

  /// Get node detail snapshot for status/rules/stats surfaces
  $grpc.ResponseFuture<$0.NodeDetailSnapshot> getNodeDetailSnapshot(
    $0.GetNodeDetailSnapshotRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getNodeDetailSnapshot, request, options: options);
  }

  /// Update node metadata (name, tags)
  $grpc.ResponseFuture<$0.NodeInfo> updateNode(
    $0.UpdateNodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateNode, request, options: options);
  }

  /// Remove/unpair a node
  $grpc.ResponseFuture<$1.Empty> removeNode(
    $0.RemoveNodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeNode, request, options: options);
  }

  /// Add a node with direct connection (no Hub required)
  /// Used to connect to standalone nitellad admin API
  $grpc.ResponseFuture<$0.AddNodeDirectResponse> addNodeDirect(
    $0.AddNodeDirectRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addNodeDirect, request, options: options);
  }

  /// Test connection to a direct node
  $grpc.ResponseFuture<$0.TestDirectConnectionResponse> testDirectConnection(
    $0.TestDirectConnectionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$testDirectConnection, request, options: options);
  }

  /// List proxies on a node
  $grpc.ResponseFuture<$0.ListProxiesResponse> listProxies(
    $0.ListProxiesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listProxies, request, options: options);
  }

  /// Get node+proxy snapshot for proxy surfaces
  $grpc.ResponseFuture<$0.GetProxiesSnapshotResponse> getProxiesSnapshot(
    $0.GetProxiesSnapshotRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getProxiesSnapshot, request, options: options);
  }

  /// Get proxy details
  $grpc.ResponseFuture<$0.ProxyInfo> getProxy(
    $0.GetProxyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getProxy, request, options: options);
  }

  /// Create new proxy on node
  $grpc.ResponseFuture<$0.ProxyInfo> addProxy(
    $0.AddProxyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addProxy, request, options: options);
  }

  /// Update proxy configuration
  $grpc.ResponseFuture<$0.ProxyInfo> updateProxy(
    $0.UpdateProxyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateProxy, request, options: options);
  }

  /// Enable/disable all proxies on a node in one backend-owned operation
  $grpc.ResponseFuture<$0.SetNodeProxiesRunningResponse> setNodeProxiesRunning(
    $0.SetNodeProxiesRunningRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setNodeProxiesRunning, request, options: options);
  }

  /// Remove proxy from node
  $grpc.ResponseFuture<$1.Empty> removeProxy(
    $0.RemoveProxyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeProxy, request, options: options);
  }

  /// List rules for a proxy
  $grpc.ResponseFuture<$0.ListRulesResponse> listRules(
    $0.ListRulesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listRules, request, options: options);
  }

  /// Get rule details
  $grpc.ResponseFuture<$2.Rule> getRule(
    $0.GetRuleRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getRule, request, options: options);
  }

  /// Add new rule to proxy
  $grpc.ResponseFuture<$2.Rule> addRule(
    $0.AddRuleRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addRule, request, options: options);
  }

  /// Add a quick rule with backend-owned mapping (block/allow/ip/geo shortcuts)
  $grpc.ResponseFuture<$0.AddQuickRuleResponse> addQuickRule(
    $0.AddQuickRuleRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addQuickRule, request, options: options);
  }

  /// Update existing rule
  $grpc.ResponseFuture<$2.Rule> updateRule(
    $0.UpdateRuleRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateRule, request, options: options);
  }

  /// Remove rule from proxy
  $grpc.ResponseFuture<$1.Empty> removeRule(
    $0.RemoveRuleRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeRule, request, options: options);
  }

  /// Block IP address (creates block rule)
  $grpc.ResponseFuture<$0.BlockIPResponse> blockIP(
    $0.BlockIPRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$blockIP, request, options: options);
  }

  /// Block ISP (creates block rule)
  $grpc.ResponseFuture<$0.BlockISPResponse> blockISP(
    $0.BlockISPRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$blockISP, request, options: options);
  }

  /// Block Country (creates block rule)
  $grpc.ResponseFuture<$0.BlockCountryResponse> blockCountry(
    $0.BlockCountryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$blockCountry, request, options: options);
  }

  /// Global Rules (node-level, cross-proxy runtime rules)
  $grpc.ResponseFuture<$0.AddGlobalRuleResponse> addGlobalRule(
    $0.AddGlobalRuleRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addGlobalRule, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListGlobalRulesResponse> listGlobalRules(
    $0.ListGlobalRulesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listGlobalRules, request, options: options);
  }

  $grpc.ResponseFuture<$0.RemoveGlobalRuleResponse> removeGlobalRule(
    $0.RemoveGlobalRuleRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeGlobalRule, request, options: options);
  }

  /// List pending approval requests (real-time from nodes)
  $grpc.ResponseFuture<$0.ListPendingApprovalsResponse> listPendingApprovals(
    $0.ListPendingApprovalsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listPendingApprovals, request, options: options);
  }

  /// Get pending + history snapshot for approval center views
  $grpc.ResponseFuture<$0.GetApprovalsSnapshotResponse> getApprovalsSnapshot(
    $0.GetApprovalsSnapshotRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getApprovalsSnapshot, request, options: options);
  }

  /// Approve a connection request
  $grpc.ResponseFuture<$0.ApproveRequestResponse> approveRequest(
    $0.ApproveRequestRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$approveRequest, request, options: options);
  }

  /// Deny a connection request
  $grpc.ResponseFuture<$0.DenyRequestResponse> denyRequest(
    $0.DenyRequestRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$denyRequest, request, options: options);
  }

  /// Resolve an approval request (backend-owned approve/deny orchestration)
  $grpc.ResponseFuture<$0.ResolveApprovalDecisionResponse>
      resolveApprovalDecision(
    $0.ResolveApprovalDecisionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$resolveApprovalDecision, request,
        options: options);
  }

  /// Stream approval requests in real-time
  $grpc.ResponseStream<$0.ApprovalRequest> streamApprovals(
    $0.StreamApprovalsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamApprovals, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// List approval decision history (backend-owned)
  $grpc.ResponseFuture<$0.ListApprovalHistoryResponse> listApprovalHistory(
    $0.ListApprovalHistoryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listApprovalHistory, request, options: options);
  }

  /// Clear approval decision history
  $grpc.ResponseFuture<$0.ClearApprovalHistoryResponse> clearApprovalHistory(
    $0.ClearApprovalHistoryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$clearApprovalHistory, request, options: options);
  }

  /// Get connection statistics summary
  $grpc.ResponseFuture<$0.ConnectionStats> getConnectionStats(
    $0.GetConnectionStatsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getConnectionStats, request, options: options);
  }

  /// List active connections on a node/proxy
  $grpc.ResponseFuture<$0.ListConnectionsResponse> listConnections(
    $0.ListConnectionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listConnections, request, options: options);
  }

  /// Get IP statistics
  $grpc.ResponseFuture<$0.GetIPStatsResponse> getIPStats(
    $0.GetIPStatsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getIPStats, request, options: options);
  }

  /// Get geo statistics
  $grpc.ResponseFuture<$0.GetGeoStatsResponse> getGeoStats(
    $0.GetGeoStatsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getGeoStats, request, options: options);
  }

  /// Stream connection events
  $grpc.ResponseStream<$0.ConnectionEvent> streamConnections(
    $0.StreamConnectionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamConnections, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Close a specific connection
  $grpc.ResponseFuture<$0.CloseConnectionResponse> closeConnection(
    $0.CloseConnectionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$closeConnection, request, options: options);
  }

  /// Close all connections on a proxy
  $grpc.ResponseFuture<$0.CloseAllConnectionsResponse> closeAllConnections(
    $0.CloseAllConnectionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$closeAllConnections, request, options: options);
  }

  /// Close all connections across every proxy on a node
  $grpc.ResponseFuture<$0.CloseAllNodeConnectionsResponse>
      closeAllNodeConnections(
    $0.CloseAllNodeConnectionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$closeAllNodeConnections, request,
        options: options);
  }

  /// Start PAKE pairing session (returns human-readable code)
  $grpc.ResponseFuture<$0.StartPairingResponse> startPairing(
    $0.StartPairingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$startPairing, request, options: options);
  }

  /// Join existing pairing session using code from node
  $grpc.ResponseFuture<$0.JoinPairingResponse> joinPairing(
    $0.JoinPairingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$joinPairing, request, options: options);
  }

  /// Complete PAKE pairing (after code exchange)
  $grpc.ResponseFuture<$0.CompletePairingResponse> completePairing(
    $0.CompletePairingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$completePairing, request, options: options);
  }

  /// Finalize pairing decision (approve/reject) for PAKE or offline QR sessions
  $grpc.ResponseFuture<$0.FinalizePairingResponse> finalizePairing(
    $0.FinalizePairingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$finalizePairing, request, options: options);
  }

  /// Cancel ongoing pairing session
  $grpc.ResponseFuture<$1.Empty> cancelPairing(
    $0.CancelPairingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$cancelPairing, request, options: options);
  }

  /// Generate QR code data for offline pairing
  $grpc.ResponseFuture<$0.GenerateQRCodeResponse> generateQRCode(
    $0.GenerateQRCodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$generateQRCode, request, options: options);
  }

  /// Scan and process QR code from node
  $grpc.ResponseFuture<$0.ScanQRCodeResponse> scanQRCode(
    $0.ScanQRCodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$scanQRCode, request, options: options);
  }

  /// Generate QR response (signed certificate) for node to scan
  $grpc.ResponseFuture<$0.GenerateQRReplyResponse> generateQRResponse(
    $0.GenerateQRReplyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$generateQRResponse, request, options: options);
  }

  /// List available templates
  $grpc.ResponseFuture<$0.ListTemplatesResponse> listTemplates(
    $0.ListTemplatesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listTemplates, request, options: options);
  }

  /// Get template details
  $grpc.ResponseFuture<$0.Template> getTemplate(
    $0.GetTemplateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTemplate, request, options: options);
  }

  /// Create new template from current config
  $grpc.ResponseFuture<$0.Template> createTemplate(
    $0.CreateTemplateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createTemplate, request, options: options);
  }

  /// Apply template to a node
  $grpc.ResponseFuture<$0.ApplyTemplateResponse> applyTemplate(
    $0.ApplyTemplateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$applyTemplate, request, options: options);
  }

  /// Delete a template
  $grpc.ResponseFuture<$1.Empty> deleteTemplate(
    $0.DeleteTemplateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteTemplate, request, options: options);
  }

  /// Sync templates with Hub
  $grpc.ResponseFuture<$0.SyncTemplatesResponse> syncTemplates(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$syncTemplates, request, options: options);
  }

  /// Export template as YAML (backend-owned format/policy)
  $grpc.ResponseFuture<$0.ExportTemplateYamlResponse> exportTemplateYaml(
    $0.ExportTemplateYamlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$exportTemplateYaml, request, options: options);
  }

  /// Import template from YAML (backend-owned parsing/validation)
  $grpc.ResponseFuture<$0.ImportTemplateYamlResponse> importTemplateYaml(
    $0.ImportTemplateYamlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$importTemplateYaml, request, options: options);
  }

  /// Get current settings
  $grpc.ResponseFuture<$0.Settings> getSettings(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSettings, request, options: options);
  }

  /// Get identity + hub + p2p settings snapshot for thin settings surfaces
  $grpc.ResponseFuture<$0.SettingsOverviewSnapshot> getSettingsOverviewSnapshot(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSettingsOverviewSnapshot, request,
        options: options);
  }

  /// Update settings
  $grpc.ResponseFuture<$0.Settings> updateSettings(
    $0.UpdateSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateSettings, request, options: options);
  }

  /// Register FCM token for push notifications
  $grpc.ResponseFuture<$1.Empty> registerFCMToken(
    $0.RegisterFCMTokenRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$registerFCMToken, request, options: options);
  }

  /// Unregister FCM token
  $grpc.ResponseFuture<$1.Empty> unregisterFCMToken(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unregisterFCMToken, request, options: options);
  }

  /// Connect to Hub server
  $grpc.ResponseFuture<$0.ConnectToHubResponse> connectToHub(
    $0.ConnectToHubRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$connectToHub, request, options: options);
  }

  /// Disconnect from Hub
  $grpc.ResponseFuture<$1.Empty> disconnectFromHub(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$disconnectFromHub, request, options: options);
  }

  /// Get Hub connection status
  $grpc.ResponseFuture<$0.HubStatus> getHubStatus(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHubStatus, request, options: options);
  }

  /// Get hub settings snapshot for settings/onboarding surfaces
  $grpc.ResponseFuture<$0.HubSettingsSnapshot> getHubSettingsSnapshot(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHubSettingsSnapshot, request,
        options: options);
  }

  /// Get aggregated hub/node overview for thin clients
  $grpc.ResponseFuture<$0.HubOverview> getHubOverview(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHubOverview, request, options: options);
  }

  /// Get hub dashboard snapshot for home/status surfaces
  $grpc.ResponseFuture<$0.HubDashboardSnapshot> getHubDashboardSnapshot(
    $0.GetHubDashboardSnapshotRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHubDashboardSnapshot, request,
        options: options);
  }

  /// Register user with Hub
  $grpc.ResponseFuture<$0.RegisterUserResponse> registerUser(
    $0.RegisterUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$registerUser, request, options: options);
  }

  /// Fetch Hub's CA certificate for TOFU (Trust On First Use) verification
  $grpc.ResponseFuture<$0.FetchHubCAResponse> fetchHubCA(
    $0.FetchHubCARequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$fetchHubCA, request, options: options);
  }

  /// Run Hub onboarding flow (connect + optional TOFU + register)
  $grpc.ResponseFuture<$0.OnboardHubResponse> onboardHub(
    $0.OnboardHubRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$onboardHub, request, options: options);
  }

  /// Ensure Hub connection using backend-owned defaults/state (no registration)
  $grpc.ResponseFuture<$0.OnboardHubResponse> ensureHubConnected(
    $0.EnsureHubConnectedRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$ensureHubConnected, request, options: options);
  }

  /// Ensure Hub registration using backend-owned defaults/state
  $grpc.ResponseFuture<$0.OnboardHubResponse> ensureHubRegistered(
    $0.EnsureHubRegisteredRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$ensureHubRegistered, request, options: options);
  }

  /// Resolve a pending Hub trust challenge and continue onboarding
  $grpc.ResponseFuture<$0.OnboardHubResponse> resolveHubTrustChallenge(
    $0.ResolveHubTrustChallengeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$resolveHubTrustChallenge, request,
        options: options);
  }

  /// Get current P2P connection status
  $grpc.ResponseFuture<$0.P2PStatus> getP2PStatus(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getP2PStatus, request, options: options);
  }

  /// Get P2P + settings snapshot for P2P configuration surfaces
  $grpc.ResponseFuture<$0.P2PSettingsSnapshot> getP2PSettingsSnapshot(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getP2PSettingsSnapshot, request,
        options: options);
  }

  /// Stream P2P status changes
  $grpc.ResponseStream<$0.P2PStatus> streamP2PStatus(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamP2PStatus, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Set P2P mode (auto, always, disabled)
  $grpc.ResponseFuture<$1.Empty> setP2PMode(
    $0.SetP2PModeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setP2PMode, request, options: options);
  }

  /// Lookup IP geolocation (with cache indicator)
  $grpc.ResponseFuture<$0.LookupIPResponse> lookupIP(
    $0.LookupIPRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$lookupIP, request, options: options);
  }

  /// Configure GeoIP mode/provider/database for a node
  $grpc.ResponseFuture<$2.ConfigureGeoIPResponse> configureGeoIP(
    $0.ConfigureGeoIPNodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$configureGeoIP, request, options: options);
  }

  /// Get GeoIP runtime status for a node
  $grpc.ResponseFuture<$2.GetGeoIPStatusResponse> getGeoIPStatus(
    $0.GetGeoIPStatusNodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getGeoIPStatus, request, options: options);
  }

  /// Restart proxy listeners on a node
  $grpc.ResponseFuture<$2.RestartListenersResponse> restartListeners(
    $0.RestartListenersNodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restartListeners, request, options: options);
  }

  /// List proxy configs stored locally on this device
  $grpc.ResponseFuture<$0.ListLocalProxyConfigsResponse> listLocalProxyConfigs(
    $0.ListLocalProxyConfigsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listLocalProxyConfigs, request, options: options);
  }

  /// Get local proxy config content + metadata
  $grpc.ResponseFuture<$0.GetLocalProxyConfigResponse> getLocalProxyConfig(
    $0.GetLocalProxyConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getLocalProxyConfig, request, options: options);
  }

  /// Import raw proxy file content into local storage
  $grpc.ResponseFuture<$0.ImportLocalProxyConfigResponse>
      importLocalProxyConfig(
    $0.ImportLocalProxyConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$importLocalProxyConfig, request,
        options: options);
  }

  /// Save/update local proxy config content + metadata
  $grpc.ResponseFuture<$0.SaveLocalProxyConfigResponse> saveLocalProxyConfig(
    $0.SaveLocalProxyConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$saveLocalProxyConfig, request, options: options);
  }

  /// Delete a local proxy config
  $grpc.ResponseFuture<$0.DeleteLocalProxyConfigResponse>
      deleteLocalProxyConfig(
    $0.DeleteLocalProxyConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteLocalProxyConfig, request,
        options: options);
  }

  /// Validate local proxy config (checksum/header/YAML/required sections)
  $grpc.ResponseFuture<$0.ValidateLocalProxyConfigResponse>
      validateLocalProxyConfig(
    $0.ValidateLocalProxyConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$validateLocalProxyConfig, request,
        options: options);
  }

  /// Push a proxy revision to Hub (encrypt + store)
  $grpc.ResponseFuture<$0.PushProxyRevisionResponse> pushProxyRevision(
    $0.PushProxyRevisionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pushProxyRevision, request, options: options);
  }

  /// Push locally-stored proxy revision to Hub (backend orchestration)
  $grpc.ResponseFuture<$0.PushLocalProxyRevisionResponse>
      pushLocalProxyRevision(
    $0.PushLocalProxyRevisionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pushLocalProxyRevision, request,
        options: options);
  }

  /// Pull a proxy revision from Hub (fetch + decrypt)
  $grpc.ResponseFuture<$0.PullProxyRevisionResponse> pullProxyRevision(
    $0.PullProxyRevisionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pullProxyRevision, request, options: options);
  }

  /// Diff local/remote proxy revisions in backend
  $grpc.ResponseFuture<$0.DiffProxyRevisionsResponse> diffProxyRevisions(
    $0.DiffProxyRevisionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$diffProxyRevisions, request, options: options);
  }

  /// List proxy revision history on Hub
  $grpc.ResponseFuture<$0.ListProxyRevisionsResponse> listProxyRevisions(
    $0.ListProxyRevisionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listProxyRevisions, request, options: options);
  }

  /// Flush old proxy revisions on Hub
  $grpc.ResponseFuture<$0.FlushProxyRevisionsResponse> flushProxyRevisions(
    $0.FlushProxyRevisionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$flushProxyRevisions, request, options: options);
  }

  /// List proxy configs stored on Hub
  $grpc.ResponseFuture<$0.ListProxyConfigsResponse> listProxyConfigs(
    $0.ListProxyConfigsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listProxyConfigs, request, options: options);
  }

  /// Create a proxy config entry on Hub
  $grpc.ResponseFuture<$0.CreateProxyConfigResponse> createProxyConfig(
    $0.CreateProxyConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createProxyConfig, request, options: options);
  }

  /// Delete a proxy config from Hub
  $grpc.ResponseFuture<$0.DeleteProxyConfigResponse> deleteProxyConfig(
    $0.DeleteProxyConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteProxyConfig, request, options: options);
  }

  /// Apply a proxy config to a node
  $grpc.ResponseFuture<$0.ApplyProxyToNodeResponse> applyProxyToNode(
    $0.ApplyProxyToNodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$applyProxyToNode, request, options: options);
  }

  /// Remove a proxy config from a node
  $grpc.ResponseFuture<$0.UnapplyProxyFromNodeResponse> unapplyProxyFromNode(
    $0.UnapplyProxyFromNodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unapplyProxyFromNode, request, options: options);
  }

  /// Get proxies applied on a node
  $grpc.ResponseFuture<$0.GetAppliedProxiesResponse> getAppliedProxies(
    $0.GetAppliedProxiesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getAppliedProxies, request, options: options);
  }

  /// Allow an IP address (creates allow rule)
  $grpc.ResponseFuture<$0.AllowIPResponse> allowIP(
    $0.AllowIPRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$allowIP, request, options: options);
  }

  /// Stream metrics from a node
  $grpc.ResponseStream<$0.NodeMetrics> streamMetrics(
    $0.StreamMetricsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamMetrics, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Get local runtime debug stats from MobileLogicService process
  $grpc.ResponseFuture<$0.DebugRuntimeStats> getDebugRuntimeStats(
    $0.GetDebugRuntimeStatsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDebugRuntimeStats, request, options: options);
  }

  /// Get logs storage statistics
  $grpc.ResponseFuture<$0.GetLogsStatsResponse> getLogsStats(
    $0.GetLogsStatsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getLogsStats, request, options: options);
  }

  /// List logs for a routing token
  $grpc.ResponseFuture<$0.ListLogsResponse> listLogs(
    $0.ListLogsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listLogs, request, options: options);
  }

  /// Delete logs
  $grpc.ResponseFuture<$0.DeleteLogsResponse> deleteLogs(
    $0.DeleteLogsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteLogs, request, options: options);
  }

  /// Clean up old logs
  $grpc.ResponseFuture<$0.CleanupOldLogsResponse> cleanupOldLogs(
    $0.CleanupOldLogsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$cleanupOldLogs, request, options: options);
  }

  /// Get node info directly from Hub (not via E2E command)
  $grpc.ResponseFuture<$0.GetNodeFromHubResponse> getNodeFromHub(
    $0.GetNodeFromHubRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getNodeFromHub, request, options: options);
  }

  /// Register a node with Hub using an existing certificate (after PAKE pairing)
  $grpc.ResponseFuture<$0.RegisterNodeWithHubResponse> registerNodeWithHub(
    $0.RegisterNodeWithHubRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$registerNodeWithHub, request, options: options);
  }

  // method descriptors

  static final _$initialize =
      $grpc.ClientMethod<$0.InitializeRequest, $0.InitializeResponse>(
          '/nitella.local.MobileLogicService/Initialize',
          ($0.InitializeRequest value) => value.writeToBuffer(),
          $0.InitializeResponse.fromBuffer);
  static final _$shutdown = $grpc.ClientMethod<$1.Empty, $1.Empty>(
      '/nitella.local.MobileLogicService/Shutdown',
      ($1.Empty value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$getBootstrapState =
      $grpc.ClientMethod<$1.Empty, $0.BootstrapStateResponse>(
          '/nitella.local.MobileLogicService/GetBootstrapState',
          ($1.Empty value) => value.writeToBuffer(),
          $0.BootstrapStateResponse.fromBuffer);
  static final _$getIdentity = $grpc.ClientMethod<$1.Empty, $0.IdentityInfo>(
      '/nitella.local.MobileLogicService/GetIdentity',
      ($1.Empty value) => value.writeToBuffer(),
      $0.IdentityInfo.fromBuffer);
  static final _$createIdentity =
      $grpc.ClientMethod<$0.CreateIdentityRequest, $0.CreateIdentityResponse>(
          '/nitella.local.MobileLogicService/CreateIdentity',
          ($0.CreateIdentityRequest value) => value.writeToBuffer(),
          $0.CreateIdentityResponse.fromBuffer);
  static final _$restoreIdentity =
      $grpc.ClientMethod<$0.RestoreIdentityRequest, $0.RestoreIdentityResponse>(
          '/nitella.local.MobileLogicService/RestoreIdentity',
          ($0.RestoreIdentityRequest value) => value.writeToBuffer(),
          $0.RestoreIdentityResponse.fromBuffer);
  static final _$importIdentity =
      $grpc.ClientMethod<$0.ImportIdentityRequest, $0.ImportIdentityResponse>(
          '/nitella.local.MobileLogicService/ImportIdentity',
          ($0.ImportIdentityRequest value) => value.writeToBuffer(),
          $0.ImportIdentityResponse.fromBuffer);
  static final _$unlockIdentity =
      $grpc.ClientMethod<$0.UnlockIdentityRequest, $0.UnlockIdentityResponse>(
          '/nitella.local.MobileLogicService/UnlockIdentity',
          ($0.UnlockIdentityRequest value) => value.writeToBuffer(),
          $0.UnlockIdentityResponse.fromBuffer);
  static final _$lockIdentity = $grpc.ClientMethod<$1.Empty, $1.Empty>(
      '/nitella.local.MobileLogicService/LockIdentity',
      ($1.Empty value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$changePassphrase =
      $grpc.ClientMethod<$0.ChangePassphraseRequest, $1.Empty>(
          '/nitella.local.MobileLogicService/ChangePassphrase',
          ($0.ChangePassphraseRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$evaluatePassphrase = $grpc.ClientMethod<
          $0.EvaluatePassphraseRequest, $0.EvaluatePassphraseResponse>(
      '/nitella.local.MobileLogicService/EvaluatePassphrase',
      ($0.EvaluatePassphraseRequest value) => value.writeToBuffer(),
      $0.EvaluatePassphraseResponse.fromBuffer);
  static final _$resetIdentity = $grpc.ClientMethod<$1.Empty, $1.Empty>(
      '/nitella.local.MobileLogicService/ResetIdentity',
      ($1.Empty value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$listNodes =
      $grpc.ClientMethod<$0.ListNodesRequest, $0.ListNodesResponse>(
          '/nitella.local.MobileLogicService/ListNodes',
          ($0.ListNodesRequest value) => value.writeToBuffer(),
          $0.ListNodesResponse.fromBuffer);
  static final _$getNode = $grpc.ClientMethod<$0.GetNodeRequest, $0.NodeInfo>(
      '/nitella.local.MobileLogicService/GetNode',
      ($0.GetNodeRequest value) => value.writeToBuffer(),
      $0.NodeInfo.fromBuffer);
  static final _$getNodeDetailSnapshot = $grpc.ClientMethod<
          $0.GetNodeDetailSnapshotRequest, $0.NodeDetailSnapshot>(
      '/nitella.local.MobileLogicService/GetNodeDetailSnapshot',
      ($0.GetNodeDetailSnapshotRequest value) => value.writeToBuffer(),
      $0.NodeDetailSnapshot.fromBuffer);
  static final _$updateNode =
      $grpc.ClientMethod<$0.UpdateNodeRequest, $0.NodeInfo>(
          '/nitella.local.MobileLogicService/UpdateNode',
          ($0.UpdateNodeRequest value) => value.writeToBuffer(),
          $0.NodeInfo.fromBuffer);
  static final _$removeNode =
      $grpc.ClientMethod<$0.RemoveNodeRequest, $1.Empty>(
          '/nitella.local.MobileLogicService/RemoveNode',
          ($0.RemoveNodeRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$addNodeDirect =
      $grpc.ClientMethod<$0.AddNodeDirectRequest, $0.AddNodeDirectResponse>(
          '/nitella.local.MobileLogicService/AddNodeDirect',
          ($0.AddNodeDirectRequest value) => value.writeToBuffer(),
          $0.AddNodeDirectResponse.fromBuffer);
  static final _$testDirectConnection = $grpc.ClientMethod<
          $0.TestDirectConnectionRequest, $0.TestDirectConnectionResponse>(
      '/nitella.local.MobileLogicService/TestDirectConnection',
      ($0.TestDirectConnectionRequest value) => value.writeToBuffer(),
      $0.TestDirectConnectionResponse.fromBuffer);
  static final _$listProxies =
      $grpc.ClientMethod<$0.ListProxiesRequest, $0.ListProxiesResponse>(
          '/nitella.local.MobileLogicService/ListProxies',
          ($0.ListProxiesRequest value) => value.writeToBuffer(),
          $0.ListProxiesResponse.fromBuffer);
  static final _$getProxiesSnapshot = $grpc.ClientMethod<
          $0.GetProxiesSnapshotRequest, $0.GetProxiesSnapshotResponse>(
      '/nitella.local.MobileLogicService/GetProxiesSnapshot',
      ($0.GetProxiesSnapshotRequest value) => value.writeToBuffer(),
      $0.GetProxiesSnapshotResponse.fromBuffer);
  static final _$getProxy =
      $grpc.ClientMethod<$0.GetProxyRequest, $0.ProxyInfo>(
          '/nitella.local.MobileLogicService/GetProxy',
          ($0.GetProxyRequest value) => value.writeToBuffer(),
          $0.ProxyInfo.fromBuffer);
  static final _$addProxy =
      $grpc.ClientMethod<$0.AddProxyRequest, $0.ProxyInfo>(
          '/nitella.local.MobileLogicService/AddProxy',
          ($0.AddProxyRequest value) => value.writeToBuffer(),
          $0.ProxyInfo.fromBuffer);
  static final _$updateProxy =
      $grpc.ClientMethod<$0.UpdateProxyRequest, $0.ProxyInfo>(
          '/nitella.local.MobileLogicService/UpdateProxy',
          ($0.UpdateProxyRequest value) => value.writeToBuffer(),
          $0.ProxyInfo.fromBuffer);
  static final _$setNodeProxiesRunning = $grpc.ClientMethod<
          $0.SetNodeProxiesRunningRequest, $0.SetNodeProxiesRunningResponse>(
      '/nitella.local.MobileLogicService/SetNodeProxiesRunning',
      ($0.SetNodeProxiesRunningRequest value) => value.writeToBuffer(),
      $0.SetNodeProxiesRunningResponse.fromBuffer);
  static final _$removeProxy =
      $grpc.ClientMethod<$0.RemoveProxyRequest, $1.Empty>(
          '/nitella.local.MobileLogicService/RemoveProxy',
          ($0.RemoveProxyRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$listRules =
      $grpc.ClientMethod<$0.ListRulesRequest, $0.ListRulesResponse>(
          '/nitella.local.MobileLogicService/ListRules',
          ($0.ListRulesRequest value) => value.writeToBuffer(),
          $0.ListRulesResponse.fromBuffer);
  static final _$getRule = $grpc.ClientMethod<$0.GetRuleRequest, $2.Rule>(
      '/nitella.local.MobileLogicService/GetRule',
      ($0.GetRuleRequest value) => value.writeToBuffer(),
      $2.Rule.fromBuffer);
  static final _$addRule = $grpc.ClientMethod<$0.AddRuleRequest, $2.Rule>(
      '/nitella.local.MobileLogicService/AddRule',
      ($0.AddRuleRequest value) => value.writeToBuffer(),
      $2.Rule.fromBuffer);
  static final _$addQuickRule =
      $grpc.ClientMethod<$0.AddQuickRuleRequest, $0.AddQuickRuleResponse>(
          '/nitella.local.MobileLogicService/AddQuickRule',
          ($0.AddQuickRuleRequest value) => value.writeToBuffer(),
          $0.AddQuickRuleResponse.fromBuffer);
  static final _$updateRule = $grpc.ClientMethod<$0.UpdateRuleRequest, $2.Rule>(
      '/nitella.local.MobileLogicService/UpdateRule',
      ($0.UpdateRuleRequest value) => value.writeToBuffer(),
      $2.Rule.fromBuffer);
  static final _$removeRule =
      $grpc.ClientMethod<$0.RemoveRuleRequest, $1.Empty>(
          '/nitella.local.MobileLogicService/RemoveRule',
          ($0.RemoveRuleRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$blockIP =
      $grpc.ClientMethod<$0.BlockIPRequest, $0.BlockIPResponse>(
          '/nitella.local.MobileLogicService/BlockIP',
          ($0.BlockIPRequest value) => value.writeToBuffer(),
          $0.BlockIPResponse.fromBuffer);
  static final _$blockISP =
      $grpc.ClientMethod<$0.BlockISPRequest, $0.BlockISPResponse>(
          '/nitella.local.MobileLogicService/BlockISP',
          ($0.BlockISPRequest value) => value.writeToBuffer(),
          $0.BlockISPResponse.fromBuffer);
  static final _$blockCountry =
      $grpc.ClientMethod<$0.BlockCountryRequest, $0.BlockCountryResponse>(
          '/nitella.local.MobileLogicService/BlockCountry',
          ($0.BlockCountryRequest value) => value.writeToBuffer(),
          $0.BlockCountryResponse.fromBuffer);
  static final _$addGlobalRule =
      $grpc.ClientMethod<$0.AddGlobalRuleRequest, $0.AddGlobalRuleResponse>(
          '/nitella.local.MobileLogicService/AddGlobalRule',
          ($0.AddGlobalRuleRequest value) => value.writeToBuffer(),
          $0.AddGlobalRuleResponse.fromBuffer);
  static final _$listGlobalRules =
      $grpc.ClientMethod<$0.ListGlobalRulesRequest, $0.ListGlobalRulesResponse>(
          '/nitella.local.MobileLogicService/ListGlobalRules',
          ($0.ListGlobalRulesRequest value) => value.writeToBuffer(),
          $0.ListGlobalRulesResponse.fromBuffer);
  static final _$removeGlobalRule = $grpc.ClientMethod<
          $0.RemoveGlobalRuleRequest, $0.RemoveGlobalRuleResponse>(
      '/nitella.local.MobileLogicService/RemoveGlobalRule',
      ($0.RemoveGlobalRuleRequest value) => value.writeToBuffer(),
      $0.RemoveGlobalRuleResponse.fromBuffer);
  static final _$listPendingApprovals = $grpc.ClientMethod<
          $0.ListPendingApprovalsRequest, $0.ListPendingApprovalsResponse>(
      '/nitella.local.MobileLogicService/ListPendingApprovals',
      ($0.ListPendingApprovalsRequest value) => value.writeToBuffer(),
      $0.ListPendingApprovalsResponse.fromBuffer);
  static final _$getApprovalsSnapshot = $grpc.ClientMethod<
          $0.GetApprovalsSnapshotRequest, $0.GetApprovalsSnapshotResponse>(
      '/nitella.local.MobileLogicService/GetApprovalsSnapshot',
      ($0.GetApprovalsSnapshotRequest value) => value.writeToBuffer(),
      $0.GetApprovalsSnapshotResponse.fromBuffer);
  static final _$approveRequest =
      $grpc.ClientMethod<$0.ApproveRequestRequest, $0.ApproveRequestResponse>(
          '/nitella.local.MobileLogicService/ApproveRequest',
          ($0.ApproveRequestRequest value) => value.writeToBuffer(),
          $0.ApproveRequestResponse.fromBuffer);
  static final _$denyRequest =
      $grpc.ClientMethod<$0.DenyRequestRequest, $0.DenyRequestResponse>(
          '/nitella.local.MobileLogicService/DenyRequest',
          ($0.DenyRequestRequest value) => value.writeToBuffer(),
          $0.DenyRequestResponse.fromBuffer);
  static final _$resolveApprovalDecision = $grpc.ClientMethod<
          $0.ResolveApprovalDecisionRequest,
          $0.ResolveApprovalDecisionResponse>(
      '/nitella.local.MobileLogicService/ResolveApprovalDecision',
      ($0.ResolveApprovalDecisionRequest value) => value.writeToBuffer(),
      $0.ResolveApprovalDecisionResponse.fromBuffer);
  static final _$streamApprovals =
      $grpc.ClientMethod<$0.StreamApprovalsRequest, $0.ApprovalRequest>(
          '/nitella.local.MobileLogicService/StreamApprovals',
          ($0.StreamApprovalsRequest value) => value.writeToBuffer(),
          $0.ApprovalRequest.fromBuffer);
  static final _$listApprovalHistory = $grpc.ClientMethod<
          $0.ListApprovalHistoryRequest, $0.ListApprovalHistoryResponse>(
      '/nitella.local.MobileLogicService/ListApprovalHistory',
      ($0.ListApprovalHistoryRequest value) => value.writeToBuffer(),
      $0.ListApprovalHistoryResponse.fromBuffer);
  static final _$clearApprovalHistory = $grpc.ClientMethod<
          $0.ClearApprovalHistoryRequest, $0.ClearApprovalHistoryResponse>(
      '/nitella.local.MobileLogicService/ClearApprovalHistory',
      ($0.ClearApprovalHistoryRequest value) => value.writeToBuffer(),
      $0.ClearApprovalHistoryResponse.fromBuffer);
  static final _$getConnectionStats =
      $grpc.ClientMethod<$0.GetConnectionStatsRequest, $0.ConnectionStats>(
          '/nitella.local.MobileLogicService/GetConnectionStats',
          ($0.GetConnectionStatsRequest value) => value.writeToBuffer(),
          $0.ConnectionStats.fromBuffer);
  static final _$listConnections =
      $grpc.ClientMethod<$0.ListConnectionsRequest, $0.ListConnectionsResponse>(
          '/nitella.local.MobileLogicService/ListConnections',
          ($0.ListConnectionsRequest value) => value.writeToBuffer(),
          $0.ListConnectionsResponse.fromBuffer);
  static final _$getIPStats =
      $grpc.ClientMethod<$0.GetIPStatsRequest, $0.GetIPStatsResponse>(
          '/nitella.local.MobileLogicService/GetIPStats',
          ($0.GetIPStatsRequest value) => value.writeToBuffer(),
          $0.GetIPStatsResponse.fromBuffer);
  static final _$getGeoStats =
      $grpc.ClientMethod<$0.GetGeoStatsRequest, $0.GetGeoStatsResponse>(
          '/nitella.local.MobileLogicService/GetGeoStats',
          ($0.GetGeoStatsRequest value) => value.writeToBuffer(),
          $0.GetGeoStatsResponse.fromBuffer);
  static final _$streamConnections =
      $grpc.ClientMethod<$0.StreamConnectionsRequest, $0.ConnectionEvent>(
          '/nitella.local.MobileLogicService/StreamConnections',
          ($0.StreamConnectionsRequest value) => value.writeToBuffer(),
          $0.ConnectionEvent.fromBuffer);
  static final _$closeConnection =
      $grpc.ClientMethod<$0.CloseConnectionRequest, $0.CloseConnectionResponse>(
          '/nitella.local.MobileLogicService/CloseConnection',
          ($0.CloseConnectionRequest value) => value.writeToBuffer(),
          $0.CloseConnectionResponse.fromBuffer);
  static final _$closeAllConnections = $grpc.ClientMethod<
          $0.CloseAllConnectionsRequest, $0.CloseAllConnectionsResponse>(
      '/nitella.local.MobileLogicService/CloseAllConnections',
      ($0.CloseAllConnectionsRequest value) => value.writeToBuffer(),
      $0.CloseAllConnectionsResponse.fromBuffer);
  static final _$closeAllNodeConnections = $grpc.ClientMethod<
          $0.CloseAllNodeConnectionsRequest,
          $0.CloseAllNodeConnectionsResponse>(
      '/nitella.local.MobileLogicService/CloseAllNodeConnections',
      ($0.CloseAllNodeConnectionsRequest value) => value.writeToBuffer(),
      $0.CloseAllNodeConnectionsResponse.fromBuffer);
  static final _$startPairing =
      $grpc.ClientMethod<$0.StartPairingRequest, $0.StartPairingResponse>(
          '/nitella.local.MobileLogicService/StartPairing',
          ($0.StartPairingRequest value) => value.writeToBuffer(),
          $0.StartPairingResponse.fromBuffer);
  static final _$joinPairing =
      $grpc.ClientMethod<$0.JoinPairingRequest, $0.JoinPairingResponse>(
          '/nitella.local.MobileLogicService/JoinPairing',
          ($0.JoinPairingRequest value) => value.writeToBuffer(),
          $0.JoinPairingResponse.fromBuffer);
  static final _$completePairing =
      $grpc.ClientMethod<$0.CompletePairingRequest, $0.CompletePairingResponse>(
          '/nitella.local.MobileLogicService/CompletePairing',
          ($0.CompletePairingRequest value) => value.writeToBuffer(),
          $0.CompletePairingResponse.fromBuffer);
  static final _$finalizePairing =
      $grpc.ClientMethod<$0.FinalizePairingRequest, $0.FinalizePairingResponse>(
          '/nitella.local.MobileLogicService/FinalizePairing',
          ($0.FinalizePairingRequest value) => value.writeToBuffer(),
          $0.FinalizePairingResponse.fromBuffer);
  static final _$cancelPairing =
      $grpc.ClientMethod<$0.CancelPairingRequest, $1.Empty>(
          '/nitella.local.MobileLogicService/CancelPairing',
          ($0.CancelPairingRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$generateQRCode =
      $grpc.ClientMethod<$0.GenerateQRCodeRequest, $0.GenerateQRCodeResponse>(
          '/nitella.local.MobileLogicService/GenerateQRCode',
          ($0.GenerateQRCodeRequest value) => value.writeToBuffer(),
          $0.GenerateQRCodeResponse.fromBuffer);
  static final _$scanQRCode =
      $grpc.ClientMethod<$0.ScanQRCodeRequest, $0.ScanQRCodeResponse>(
          '/nitella.local.MobileLogicService/ScanQRCode',
          ($0.ScanQRCodeRequest value) => value.writeToBuffer(),
          $0.ScanQRCodeResponse.fromBuffer);
  static final _$generateQRResponse =
      $grpc.ClientMethod<$0.GenerateQRReplyRequest, $0.GenerateQRReplyResponse>(
          '/nitella.local.MobileLogicService/GenerateQRResponse',
          ($0.GenerateQRReplyRequest value) => value.writeToBuffer(),
          $0.GenerateQRReplyResponse.fromBuffer);
  static final _$listTemplates =
      $grpc.ClientMethod<$0.ListTemplatesRequest, $0.ListTemplatesResponse>(
          '/nitella.local.MobileLogicService/ListTemplates',
          ($0.ListTemplatesRequest value) => value.writeToBuffer(),
          $0.ListTemplatesResponse.fromBuffer);
  static final _$getTemplate =
      $grpc.ClientMethod<$0.GetTemplateRequest, $0.Template>(
          '/nitella.local.MobileLogicService/GetTemplate',
          ($0.GetTemplateRequest value) => value.writeToBuffer(),
          $0.Template.fromBuffer);
  static final _$createTemplate =
      $grpc.ClientMethod<$0.CreateTemplateRequest, $0.Template>(
          '/nitella.local.MobileLogicService/CreateTemplate',
          ($0.CreateTemplateRequest value) => value.writeToBuffer(),
          $0.Template.fromBuffer);
  static final _$applyTemplate =
      $grpc.ClientMethod<$0.ApplyTemplateRequest, $0.ApplyTemplateResponse>(
          '/nitella.local.MobileLogicService/ApplyTemplate',
          ($0.ApplyTemplateRequest value) => value.writeToBuffer(),
          $0.ApplyTemplateResponse.fromBuffer);
  static final _$deleteTemplate =
      $grpc.ClientMethod<$0.DeleteTemplateRequest, $1.Empty>(
          '/nitella.local.MobileLogicService/DeleteTemplate',
          ($0.DeleteTemplateRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$syncTemplates =
      $grpc.ClientMethod<$1.Empty, $0.SyncTemplatesResponse>(
          '/nitella.local.MobileLogicService/SyncTemplates',
          ($1.Empty value) => value.writeToBuffer(),
          $0.SyncTemplatesResponse.fromBuffer);
  static final _$exportTemplateYaml = $grpc.ClientMethod<
          $0.ExportTemplateYamlRequest, $0.ExportTemplateYamlResponse>(
      '/nitella.local.MobileLogicService/ExportTemplateYaml',
      ($0.ExportTemplateYamlRequest value) => value.writeToBuffer(),
      $0.ExportTemplateYamlResponse.fromBuffer);
  static final _$importTemplateYaml = $grpc.ClientMethod<
          $0.ImportTemplateYamlRequest, $0.ImportTemplateYamlResponse>(
      '/nitella.local.MobileLogicService/ImportTemplateYaml',
      ($0.ImportTemplateYamlRequest value) => value.writeToBuffer(),
      $0.ImportTemplateYamlResponse.fromBuffer);
  static final _$getSettings = $grpc.ClientMethod<$1.Empty, $0.Settings>(
      '/nitella.local.MobileLogicService/GetSettings',
      ($1.Empty value) => value.writeToBuffer(),
      $0.Settings.fromBuffer);
  static final _$getSettingsOverviewSnapshot =
      $grpc.ClientMethod<$1.Empty, $0.SettingsOverviewSnapshot>(
          '/nitella.local.MobileLogicService/GetSettingsOverviewSnapshot',
          ($1.Empty value) => value.writeToBuffer(),
          $0.SettingsOverviewSnapshot.fromBuffer);
  static final _$updateSettings =
      $grpc.ClientMethod<$0.UpdateSettingsRequest, $0.Settings>(
          '/nitella.local.MobileLogicService/UpdateSettings',
          ($0.UpdateSettingsRequest value) => value.writeToBuffer(),
          $0.Settings.fromBuffer);
  static final _$registerFCMToken =
      $grpc.ClientMethod<$0.RegisterFCMTokenRequest, $1.Empty>(
          '/nitella.local.MobileLogicService/RegisterFCMToken',
          ($0.RegisterFCMTokenRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$unregisterFCMToken = $grpc.ClientMethod<$1.Empty, $1.Empty>(
      '/nitella.local.MobileLogicService/UnregisterFCMToken',
      ($1.Empty value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$connectToHub =
      $grpc.ClientMethod<$0.ConnectToHubRequest, $0.ConnectToHubResponse>(
          '/nitella.local.MobileLogicService/ConnectToHub',
          ($0.ConnectToHubRequest value) => value.writeToBuffer(),
          $0.ConnectToHubResponse.fromBuffer);
  static final _$disconnectFromHub = $grpc.ClientMethod<$1.Empty, $1.Empty>(
      '/nitella.local.MobileLogicService/DisconnectFromHub',
      ($1.Empty value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$getHubStatus = $grpc.ClientMethod<$1.Empty, $0.HubStatus>(
      '/nitella.local.MobileLogicService/GetHubStatus',
      ($1.Empty value) => value.writeToBuffer(),
      $0.HubStatus.fromBuffer);
  static final _$getHubSettingsSnapshot =
      $grpc.ClientMethod<$1.Empty, $0.HubSettingsSnapshot>(
          '/nitella.local.MobileLogicService/GetHubSettingsSnapshot',
          ($1.Empty value) => value.writeToBuffer(),
          $0.HubSettingsSnapshot.fromBuffer);
  static final _$getHubOverview = $grpc.ClientMethod<$1.Empty, $0.HubOverview>(
      '/nitella.local.MobileLogicService/GetHubOverview',
      ($1.Empty value) => value.writeToBuffer(),
      $0.HubOverview.fromBuffer);
  static final _$getHubDashboardSnapshot = $grpc.ClientMethod<
          $0.GetHubDashboardSnapshotRequest, $0.HubDashboardSnapshot>(
      '/nitella.local.MobileLogicService/GetHubDashboardSnapshot',
      ($0.GetHubDashboardSnapshotRequest value) => value.writeToBuffer(),
      $0.HubDashboardSnapshot.fromBuffer);
  static final _$registerUser =
      $grpc.ClientMethod<$0.RegisterUserRequest, $0.RegisterUserResponse>(
          '/nitella.local.MobileLogicService/RegisterUser',
          ($0.RegisterUserRequest value) => value.writeToBuffer(),
          $0.RegisterUserResponse.fromBuffer);
  static final _$fetchHubCA =
      $grpc.ClientMethod<$0.FetchHubCARequest, $0.FetchHubCAResponse>(
          '/nitella.local.MobileLogicService/FetchHubCA',
          ($0.FetchHubCARequest value) => value.writeToBuffer(),
          $0.FetchHubCAResponse.fromBuffer);
  static final _$onboardHub =
      $grpc.ClientMethod<$0.OnboardHubRequest, $0.OnboardHubResponse>(
          '/nitella.local.MobileLogicService/OnboardHub',
          ($0.OnboardHubRequest value) => value.writeToBuffer(),
          $0.OnboardHubResponse.fromBuffer);
  static final _$ensureHubConnected =
      $grpc.ClientMethod<$0.EnsureHubConnectedRequest, $0.OnboardHubResponse>(
          '/nitella.local.MobileLogicService/EnsureHubConnected',
          ($0.EnsureHubConnectedRequest value) => value.writeToBuffer(),
          $0.OnboardHubResponse.fromBuffer);
  static final _$ensureHubRegistered =
      $grpc.ClientMethod<$0.EnsureHubRegisteredRequest, $0.OnboardHubResponse>(
          '/nitella.local.MobileLogicService/EnsureHubRegistered',
          ($0.EnsureHubRegisteredRequest value) => value.writeToBuffer(),
          $0.OnboardHubResponse.fromBuffer);
  static final _$resolveHubTrustChallenge = $grpc.ClientMethod<
          $0.ResolveHubTrustChallengeRequest, $0.OnboardHubResponse>(
      '/nitella.local.MobileLogicService/ResolveHubTrustChallenge',
      ($0.ResolveHubTrustChallengeRequest value) => value.writeToBuffer(),
      $0.OnboardHubResponse.fromBuffer);
  static final _$getP2PStatus = $grpc.ClientMethod<$1.Empty, $0.P2PStatus>(
      '/nitella.local.MobileLogicService/GetP2PStatus',
      ($1.Empty value) => value.writeToBuffer(),
      $0.P2PStatus.fromBuffer);
  static final _$getP2PSettingsSnapshot =
      $grpc.ClientMethod<$1.Empty, $0.P2PSettingsSnapshot>(
          '/nitella.local.MobileLogicService/GetP2PSettingsSnapshot',
          ($1.Empty value) => value.writeToBuffer(),
          $0.P2PSettingsSnapshot.fromBuffer);
  static final _$streamP2PStatus = $grpc.ClientMethod<$1.Empty, $0.P2PStatus>(
      '/nitella.local.MobileLogicService/StreamP2PStatus',
      ($1.Empty value) => value.writeToBuffer(),
      $0.P2PStatus.fromBuffer);
  static final _$setP2PMode =
      $grpc.ClientMethod<$0.SetP2PModeRequest, $1.Empty>(
          '/nitella.local.MobileLogicService/SetP2PMode',
          ($0.SetP2PModeRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$lookupIP =
      $grpc.ClientMethod<$0.LookupIPRequest, $0.LookupIPResponse>(
          '/nitella.local.MobileLogicService/LookupIP',
          ($0.LookupIPRequest value) => value.writeToBuffer(),
          $0.LookupIPResponse.fromBuffer);
  static final _$configureGeoIP = $grpc.ClientMethod<
          $0.ConfigureGeoIPNodeRequest, $2.ConfigureGeoIPResponse>(
      '/nitella.local.MobileLogicService/ConfigureGeoIP',
      ($0.ConfigureGeoIPNodeRequest value) => value.writeToBuffer(),
      $2.ConfigureGeoIPResponse.fromBuffer);
  static final _$getGeoIPStatus = $grpc.ClientMethod<
          $0.GetGeoIPStatusNodeRequest, $2.GetGeoIPStatusResponse>(
      '/nitella.local.MobileLogicService/GetGeoIPStatus',
      ($0.GetGeoIPStatusNodeRequest value) => value.writeToBuffer(),
      $2.GetGeoIPStatusResponse.fromBuffer);
  static final _$restartListeners = $grpc.ClientMethod<
          $0.RestartListenersNodeRequest, $2.RestartListenersResponse>(
      '/nitella.local.MobileLogicService/RestartListeners',
      ($0.RestartListenersNodeRequest value) => value.writeToBuffer(),
      $2.RestartListenersResponse.fromBuffer);
  static final _$listLocalProxyConfigs = $grpc.ClientMethod<
          $0.ListLocalProxyConfigsRequest, $0.ListLocalProxyConfigsResponse>(
      '/nitella.local.MobileLogicService/ListLocalProxyConfigs',
      ($0.ListLocalProxyConfigsRequest value) => value.writeToBuffer(),
      $0.ListLocalProxyConfigsResponse.fromBuffer);
  static final _$getLocalProxyConfig = $grpc.ClientMethod<
          $0.GetLocalProxyConfigRequest, $0.GetLocalProxyConfigResponse>(
      '/nitella.local.MobileLogicService/GetLocalProxyConfig',
      ($0.GetLocalProxyConfigRequest value) => value.writeToBuffer(),
      $0.GetLocalProxyConfigResponse.fromBuffer);
  static final _$importLocalProxyConfig = $grpc.ClientMethod<
          $0.ImportLocalProxyConfigRequest, $0.ImportLocalProxyConfigResponse>(
      '/nitella.local.MobileLogicService/ImportLocalProxyConfig',
      ($0.ImportLocalProxyConfigRequest value) => value.writeToBuffer(),
      $0.ImportLocalProxyConfigResponse.fromBuffer);
  static final _$saveLocalProxyConfig = $grpc.ClientMethod<
          $0.SaveLocalProxyConfigRequest, $0.SaveLocalProxyConfigResponse>(
      '/nitella.local.MobileLogicService/SaveLocalProxyConfig',
      ($0.SaveLocalProxyConfigRequest value) => value.writeToBuffer(),
      $0.SaveLocalProxyConfigResponse.fromBuffer);
  static final _$deleteLocalProxyConfig = $grpc.ClientMethod<
          $0.DeleteLocalProxyConfigRequest, $0.DeleteLocalProxyConfigResponse>(
      '/nitella.local.MobileLogicService/DeleteLocalProxyConfig',
      ($0.DeleteLocalProxyConfigRequest value) => value.writeToBuffer(),
      $0.DeleteLocalProxyConfigResponse.fromBuffer);
  static final _$validateLocalProxyConfig = $grpc.ClientMethod<
          $0.ValidateLocalProxyConfigRequest,
          $0.ValidateLocalProxyConfigResponse>(
      '/nitella.local.MobileLogicService/ValidateLocalProxyConfig',
      ($0.ValidateLocalProxyConfigRequest value) => value.writeToBuffer(),
      $0.ValidateLocalProxyConfigResponse.fromBuffer);
  static final _$pushProxyRevision = $grpc.ClientMethod<
          $0.PushProxyRevisionRequest, $0.PushProxyRevisionResponse>(
      '/nitella.local.MobileLogicService/PushProxyRevision',
      ($0.PushProxyRevisionRequest value) => value.writeToBuffer(),
      $0.PushProxyRevisionResponse.fromBuffer);
  static final _$pushLocalProxyRevision = $grpc.ClientMethod<
          $0.PushLocalProxyRevisionRequest, $0.PushLocalProxyRevisionResponse>(
      '/nitella.local.MobileLogicService/PushLocalProxyRevision',
      ($0.PushLocalProxyRevisionRequest value) => value.writeToBuffer(),
      $0.PushLocalProxyRevisionResponse.fromBuffer);
  static final _$pullProxyRevision = $grpc.ClientMethod<
          $0.PullProxyRevisionRequest, $0.PullProxyRevisionResponse>(
      '/nitella.local.MobileLogicService/PullProxyRevision',
      ($0.PullProxyRevisionRequest value) => value.writeToBuffer(),
      $0.PullProxyRevisionResponse.fromBuffer);
  static final _$diffProxyRevisions = $grpc.ClientMethod<
          $0.DiffProxyRevisionsRequest, $0.DiffProxyRevisionsResponse>(
      '/nitella.local.MobileLogicService/DiffProxyRevisions',
      ($0.DiffProxyRevisionsRequest value) => value.writeToBuffer(),
      $0.DiffProxyRevisionsResponse.fromBuffer);
  static final _$listProxyRevisions = $grpc.ClientMethod<
          $0.ListProxyRevisionsRequest, $0.ListProxyRevisionsResponse>(
      '/nitella.local.MobileLogicService/ListProxyRevisions',
      ($0.ListProxyRevisionsRequest value) => value.writeToBuffer(),
      $0.ListProxyRevisionsResponse.fromBuffer);
  static final _$flushProxyRevisions = $grpc.ClientMethod<
          $0.FlushProxyRevisionsRequest, $0.FlushProxyRevisionsResponse>(
      '/nitella.local.MobileLogicService/FlushProxyRevisions',
      ($0.FlushProxyRevisionsRequest value) => value.writeToBuffer(),
      $0.FlushProxyRevisionsResponse.fromBuffer);
  static final _$listProxyConfigs = $grpc.ClientMethod<
          $0.ListProxyConfigsRequest, $0.ListProxyConfigsResponse>(
      '/nitella.local.MobileLogicService/ListProxyConfigs',
      ($0.ListProxyConfigsRequest value) => value.writeToBuffer(),
      $0.ListProxyConfigsResponse.fromBuffer);
  static final _$createProxyConfig = $grpc.ClientMethod<
          $0.CreateProxyConfigRequest, $0.CreateProxyConfigResponse>(
      '/nitella.local.MobileLogicService/CreateProxyConfig',
      ($0.CreateProxyConfigRequest value) => value.writeToBuffer(),
      $0.CreateProxyConfigResponse.fromBuffer);
  static final _$deleteProxyConfig = $grpc.ClientMethod<
          $0.DeleteProxyConfigRequest, $0.DeleteProxyConfigResponse>(
      '/nitella.local.MobileLogicService/DeleteProxyConfig',
      ($0.DeleteProxyConfigRequest value) => value.writeToBuffer(),
      $0.DeleteProxyConfigResponse.fromBuffer);
  static final _$applyProxyToNode = $grpc.ClientMethod<
          $0.ApplyProxyToNodeRequest, $0.ApplyProxyToNodeResponse>(
      '/nitella.local.MobileLogicService/ApplyProxyToNode',
      ($0.ApplyProxyToNodeRequest value) => value.writeToBuffer(),
      $0.ApplyProxyToNodeResponse.fromBuffer);
  static final _$unapplyProxyFromNode = $grpc.ClientMethod<
          $0.UnapplyProxyFromNodeRequest, $0.UnapplyProxyFromNodeResponse>(
      '/nitella.local.MobileLogicService/UnapplyProxyFromNode',
      ($0.UnapplyProxyFromNodeRequest value) => value.writeToBuffer(),
      $0.UnapplyProxyFromNodeResponse.fromBuffer);
  static final _$getAppliedProxies = $grpc.ClientMethod<
          $0.GetAppliedProxiesRequest, $0.GetAppliedProxiesResponse>(
      '/nitella.local.MobileLogicService/GetAppliedProxies',
      ($0.GetAppliedProxiesRequest value) => value.writeToBuffer(),
      $0.GetAppliedProxiesResponse.fromBuffer);
  static final _$allowIP =
      $grpc.ClientMethod<$0.AllowIPRequest, $0.AllowIPResponse>(
          '/nitella.local.MobileLogicService/AllowIP',
          ($0.AllowIPRequest value) => value.writeToBuffer(),
          $0.AllowIPResponse.fromBuffer);
  static final _$streamMetrics =
      $grpc.ClientMethod<$0.StreamMetricsRequest, $0.NodeMetrics>(
          '/nitella.local.MobileLogicService/StreamMetrics',
          ($0.StreamMetricsRequest value) => value.writeToBuffer(),
          $0.NodeMetrics.fromBuffer);
  static final _$getDebugRuntimeStats =
      $grpc.ClientMethod<$0.GetDebugRuntimeStatsRequest, $0.DebugRuntimeStats>(
          '/nitella.local.MobileLogicService/GetDebugRuntimeStats',
          ($0.GetDebugRuntimeStatsRequest value) => value.writeToBuffer(),
          $0.DebugRuntimeStats.fromBuffer);
  static final _$getLogsStats =
      $grpc.ClientMethod<$0.GetLogsStatsRequest, $0.GetLogsStatsResponse>(
          '/nitella.local.MobileLogicService/GetLogsStats',
          ($0.GetLogsStatsRequest value) => value.writeToBuffer(),
          $0.GetLogsStatsResponse.fromBuffer);
  static final _$listLogs =
      $grpc.ClientMethod<$0.ListLogsRequest, $0.ListLogsResponse>(
          '/nitella.local.MobileLogicService/ListLogs',
          ($0.ListLogsRequest value) => value.writeToBuffer(),
          $0.ListLogsResponse.fromBuffer);
  static final _$deleteLogs =
      $grpc.ClientMethod<$0.DeleteLogsRequest, $0.DeleteLogsResponse>(
          '/nitella.local.MobileLogicService/DeleteLogs',
          ($0.DeleteLogsRequest value) => value.writeToBuffer(),
          $0.DeleteLogsResponse.fromBuffer);
  static final _$cleanupOldLogs =
      $grpc.ClientMethod<$0.CleanupOldLogsRequest, $0.CleanupOldLogsResponse>(
          '/nitella.local.MobileLogicService/CleanupOldLogs',
          ($0.CleanupOldLogsRequest value) => value.writeToBuffer(),
          $0.CleanupOldLogsResponse.fromBuffer);
  static final _$getNodeFromHub =
      $grpc.ClientMethod<$0.GetNodeFromHubRequest, $0.GetNodeFromHubResponse>(
          '/nitella.local.MobileLogicService/GetNodeFromHub',
          ($0.GetNodeFromHubRequest value) => value.writeToBuffer(),
          $0.GetNodeFromHubResponse.fromBuffer);
  static final _$registerNodeWithHub = $grpc.ClientMethod<
          $0.RegisterNodeWithHubRequest, $0.RegisterNodeWithHubResponse>(
      '/nitella.local.MobileLogicService/RegisterNodeWithHub',
      ($0.RegisterNodeWithHubRequest value) => value.writeToBuffer(),
      $0.RegisterNodeWithHubResponse.fromBuffer);
}

@$pb.GrpcServiceName('nitella.local.MobileLogicService')
abstract class MobileLogicServiceBase extends $grpc.Service {
  $core.String get $name => 'nitella.local.MobileLogicService';

  MobileLogicServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.InitializeRequest, $0.InitializeResponse>(
        'Initialize',
        initialize_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.InitializeRequest.fromBuffer(value),
        ($0.InitializeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $1.Empty>(
        'Shutdown',
        shutdown_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.BootstrapStateResponse>(
        'GetBootstrapState',
        getBootstrapState_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.BootstrapStateResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.IdentityInfo>(
        'GetIdentity',
        getIdentity_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.IdentityInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateIdentityRequest,
            $0.CreateIdentityResponse>(
        'CreateIdentity',
        createIdentity_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateIdentityRequest.fromBuffer(value),
        ($0.CreateIdentityResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RestoreIdentityRequest,
            $0.RestoreIdentityResponse>(
        'RestoreIdentity',
        restoreIdentity_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RestoreIdentityRequest.fromBuffer(value),
        ($0.RestoreIdentityResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportIdentityRequest,
            $0.ImportIdentityResponse>(
        'ImportIdentity',
        importIdentity_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ImportIdentityRequest.fromBuffer(value),
        ($0.ImportIdentityResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnlockIdentityRequest,
            $0.UnlockIdentityResponse>(
        'UnlockIdentity',
        unlockIdentity_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UnlockIdentityRequest.fromBuffer(value),
        ($0.UnlockIdentityResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $1.Empty>(
        'LockIdentity',
        lockIdentity_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangePassphraseRequest, $1.Empty>(
        'ChangePassphrase',
        changePassphrase_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangePassphraseRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EvaluatePassphraseRequest,
            $0.EvaluatePassphraseResponse>(
        'EvaluatePassphrase',
        evaluatePassphrase_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.EvaluatePassphraseRequest.fromBuffer(value),
        ($0.EvaluatePassphraseResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $1.Empty>(
        'ResetIdentity',
        resetIdentity_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListNodesRequest, $0.ListNodesResponse>(
        'ListNodes',
        listNodes_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListNodesRequest.fromBuffer(value),
        ($0.ListNodesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetNodeRequest, $0.NodeInfo>(
        'GetNode',
        getNode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetNodeRequest.fromBuffer(value),
        ($0.NodeInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetNodeDetailSnapshotRequest,
            $0.NodeDetailSnapshot>(
        'GetNodeDetailSnapshot',
        getNodeDetailSnapshot_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetNodeDetailSnapshotRequest.fromBuffer(value),
        ($0.NodeDetailSnapshot value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateNodeRequest, $0.NodeInfo>(
        'UpdateNode',
        updateNode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateNodeRequest.fromBuffer(value),
        ($0.NodeInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RemoveNodeRequest, $1.Empty>(
        'RemoveNode',
        removeNode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RemoveNodeRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AddNodeDirectRequest, $0.AddNodeDirectResponse>(
            'AddNodeDirect',
            addNodeDirect_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AddNodeDirectRequest.fromBuffer(value),
            ($0.AddNodeDirectResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TestDirectConnectionRequest,
            $0.TestDirectConnectionResponse>(
        'TestDirectConnection',
        testDirectConnection_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TestDirectConnectionRequest.fromBuffer(value),
        ($0.TestDirectConnectionResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListProxiesRequest, $0.ListProxiesResponse>(
            'ListProxies',
            listProxies_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListProxiesRequest.fromBuffer(value),
            ($0.ListProxiesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetProxiesSnapshotRequest,
            $0.GetProxiesSnapshotResponse>(
        'GetProxiesSnapshot',
        getProxiesSnapshot_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetProxiesSnapshotRequest.fromBuffer(value),
        ($0.GetProxiesSnapshotResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetProxyRequest, $0.ProxyInfo>(
        'GetProxy',
        getProxy_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetProxyRequest.fromBuffer(value),
        ($0.ProxyInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddProxyRequest, $0.ProxyInfo>(
        'AddProxy',
        addProxy_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddProxyRequest.fromBuffer(value),
        ($0.ProxyInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateProxyRequest, $0.ProxyInfo>(
        'UpdateProxy',
        updateProxy_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateProxyRequest.fromBuffer(value),
        ($0.ProxyInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetNodeProxiesRunningRequest,
            $0.SetNodeProxiesRunningResponse>(
        'SetNodeProxiesRunning',
        setNodeProxiesRunning_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetNodeProxiesRunningRequest.fromBuffer(value),
        ($0.SetNodeProxiesRunningResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RemoveProxyRequest, $1.Empty>(
        'RemoveProxy',
        removeProxy_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RemoveProxyRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListRulesRequest, $0.ListRulesResponse>(
        'ListRules',
        listRules_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListRulesRequest.fromBuffer(value),
        ($0.ListRulesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetRuleRequest, $2.Rule>(
        'GetRule',
        getRule_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetRuleRequest.fromBuffer(value),
        ($2.Rule value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddRuleRequest, $2.Rule>(
        'AddRule',
        addRule_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddRuleRequest.fromBuffer(value),
        ($2.Rule value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AddQuickRuleRequest, $0.AddQuickRuleResponse>(
            'AddQuickRule',
            addQuickRule_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AddQuickRuleRequest.fromBuffer(value),
            ($0.AddQuickRuleResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateRuleRequest, $2.Rule>(
        'UpdateRule',
        updateRule_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateRuleRequest.fromBuffer(value),
        ($2.Rule value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RemoveRuleRequest, $1.Empty>(
        'RemoveRule',
        removeRule_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RemoveRuleRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BlockIPRequest, $0.BlockIPResponse>(
        'BlockIP',
        blockIP_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BlockIPRequest.fromBuffer(value),
        ($0.BlockIPResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BlockISPRequest, $0.BlockISPResponse>(
        'BlockISP',
        blockISP_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BlockISPRequest.fromBuffer(value),
        ($0.BlockISPResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.BlockCountryRequest, $0.BlockCountryResponse>(
            'BlockCountry',
            blockCountry_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.BlockCountryRequest.fromBuffer(value),
            ($0.BlockCountryResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AddGlobalRuleRequest, $0.AddGlobalRuleResponse>(
            'AddGlobalRule',
            addGlobalRule_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AddGlobalRuleRequest.fromBuffer(value),
            ($0.AddGlobalRuleResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListGlobalRulesRequest,
            $0.ListGlobalRulesResponse>(
        'ListGlobalRules',
        listGlobalRules_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListGlobalRulesRequest.fromBuffer(value),
        ($0.ListGlobalRulesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RemoveGlobalRuleRequest,
            $0.RemoveGlobalRuleResponse>(
        'RemoveGlobalRule',
        removeGlobalRule_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RemoveGlobalRuleRequest.fromBuffer(value),
        ($0.RemoveGlobalRuleResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListPendingApprovalsRequest,
            $0.ListPendingApprovalsResponse>(
        'ListPendingApprovals',
        listPendingApprovals_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListPendingApprovalsRequest.fromBuffer(value),
        ($0.ListPendingApprovalsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetApprovalsSnapshotRequest,
            $0.GetApprovalsSnapshotResponse>(
        'GetApprovalsSnapshot',
        getApprovalsSnapshot_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetApprovalsSnapshotRequest.fromBuffer(value),
        ($0.GetApprovalsSnapshotResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ApproveRequestRequest,
            $0.ApproveRequestResponse>(
        'ApproveRequest',
        approveRequest_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ApproveRequestRequest.fromBuffer(value),
        ($0.ApproveRequestResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DenyRequestRequest, $0.DenyRequestResponse>(
            'DenyRequest',
            denyRequest_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DenyRequestRequest.fromBuffer(value),
            ($0.DenyRequestResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ResolveApprovalDecisionRequest,
            $0.ResolveApprovalDecisionResponse>(
        'ResolveApprovalDecision',
        resolveApprovalDecision_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ResolveApprovalDecisionRequest.fromBuffer(value),
        ($0.ResolveApprovalDecisionResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.StreamApprovalsRequest, $0.ApprovalRequest>(
            'StreamApprovals',
            streamApprovals_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.StreamApprovalsRequest.fromBuffer(value),
            ($0.ApprovalRequest value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListApprovalHistoryRequest,
            $0.ListApprovalHistoryResponse>(
        'ListApprovalHistory',
        listApprovalHistory_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListApprovalHistoryRequest.fromBuffer(value),
        ($0.ListApprovalHistoryResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ClearApprovalHistoryRequest,
            $0.ClearApprovalHistoryResponse>(
        'ClearApprovalHistory',
        clearApprovalHistory_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ClearApprovalHistoryRequest.fromBuffer(value),
        ($0.ClearApprovalHistoryResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetConnectionStatsRequest, $0.ConnectionStats>(
            'GetConnectionStats',
            getConnectionStats_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetConnectionStatsRequest.fromBuffer(value),
            ($0.ConnectionStats value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListConnectionsRequest,
            $0.ListConnectionsResponse>(
        'ListConnections',
        listConnections_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListConnectionsRequest.fromBuffer(value),
        ($0.ListConnectionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetIPStatsRequest, $0.GetIPStatsResponse>(
        'GetIPStats',
        getIPStats_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetIPStatsRequest.fromBuffer(value),
        ($0.GetIPStatsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetGeoStatsRequest, $0.GetGeoStatsResponse>(
            'GetGeoStats',
            getGeoStats_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetGeoStatsRequest.fromBuffer(value),
            ($0.GetGeoStatsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.StreamConnectionsRequest, $0.ConnectionEvent>(
            'StreamConnections',
            streamConnections_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.StreamConnectionsRequest.fromBuffer(value),
            ($0.ConnectionEvent value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CloseConnectionRequest,
            $0.CloseConnectionResponse>(
        'CloseConnection',
        closeConnection_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CloseConnectionRequest.fromBuffer(value),
        ($0.CloseConnectionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CloseAllConnectionsRequest,
            $0.CloseAllConnectionsResponse>(
        'CloseAllConnections',
        closeAllConnections_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CloseAllConnectionsRequest.fromBuffer(value),
        ($0.CloseAllConnectionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CloseAllNodeConnectionsRequest,
            $0.CloseAllNodeConnectionsResponse>(
        'CloseAllNodeConnections',
        closeAllNodeConnections_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CloseAllNodeConnectionsRequest.fromBuffer(value),
        ($0.CloseAllNodeConnectionsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.StartPairingRequest, $0.StartPairingResponse>(
            'StartPairing',
            startPairing_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.StartPairingRequest.fromBuffer(value),
            ($0.StartPairingResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.JoinPairingRequest, $0.JoinPairingResponse>(
            'JoinPairing',
            joinPairing_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.JoinPairingRequest.fromBuffer(value),
            ($0.JoinPairingResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CompletePairingRequest,
            $0.CompletePairingResponse>(
        'CompletePairing',
        completePairing_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CompletePairingRequest.fromBuffer(value),
        ($0.CompletePairingResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FinalizePairingRequest,
            $0.FinalizePairingResponse>(
        'FinalizePairing',
        finalizePairing_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.FinalizePairingRequest.fromBuffer(value),
        ($0.FinalizePairingResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CancelPairingRequest, $1.Empty>(
        'CancelPairing',
        cancelPairing_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CancelPairingRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GenerateQRCodeRequest,
            $0.GenerateQRCodeResponse>(
        'GenerateQRCode',
        generateQRCode_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GenerateQRCodeRequest.fromBuffer(value),
        ($0.GenerateQRCodeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ScanQRCodeRequest, $0.ScanQRCodeResponse>(
        'ScanQRCode',
        scanQRCode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ScanQRCodeRequest.fromBuffer(value),
        ($0.ScanQRCodeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GenerateQRReplyRequest,
            $0.GenerateQRReplyResponse>(
        'GenerateQRResponse',
        generateQRResponse_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GenerateQRReplyRequest.fromBuffer(value),
        ($0.GenerateQRReplyResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListTemplatesRequest, $0.ListTemplatesResponse>(
            'ListTemplates',
            listTemplates_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListTemplatesRequest.fromBuffer(value),
            ($0.ListTemplatesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetTemplateRequest, $0.Template>(
        'GetTemplate',
        getTemplate_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetTemplateRequest.fromBuffer(value),
        ($0.Template value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateTemplateRequest, $0.Template>(
        'CreateTemplate',
        createTemplate_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateTemplateRequest.fromBuffer(value),
        ($0.Template value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ApplyTemplateRequest, $0.ApplyTemplateResponse>(
            'ApplyTemplate',
            applyTemplate_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ApplyTemplateRequest.fromBuffer(value),
            ($0.ApplyTemplateResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteTemplateRequest, $1.Empty>(
        'DeleteTemplate',
        deleteTemplate_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteTemplateRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.SyncTemplatesResponse>(
        'SyncTemplates',
        syncTemplates_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.SyncTemplatesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ExportTemplateYamlRequest,
            $0.ExportTemplateYamlResponse>(
        'ExportTemplateYaml',
        exportTemplateYaml_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ExportTemplateYamlRequest.fromBuffer(value),
        ($0.ExportTemplateYamlResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportTemplateYamlRequest,
            $0.ImportTemplateYamlResponse>(
        'ImportTemplateYaml',
        importTemplateYaml_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ImportTemplateYamlRequest.fromBuffer(value),
        ($0.ImportTemplateYamlResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.Settings>(
        'GetSettings',
        getSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.Settings value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.SettingsOverviewSnapshot>(
        'GetSettingsOverviewSnapshot',
        getSettingsOverviewSnapshot_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.SettingsOverviewSnapshot value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateSettingsRequest, $0.Settings>(
        'UpdateSettings',
        updateSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateSettingsRequest.fromBuffer(value),
        ($0.Settings value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RegisterFCMTokenRequest, $1.Empty>(
        'RegisterFCMToken',
        registerFCMToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RegisterFCMTokenRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $1.Empty>(
        'UnregisterFCMToken',
        unregisterFCMToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ConnectToHubRequest, $0.ConnectToHubResponse>(
            'ConnectToHub',
            connectToHub_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ConnectToHubRequest.fromBuffer(value),
            ($0.ConnectToHubResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $1.Empty>(
        'DisconnectFromHub',
        disconnectFromHub_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.HubStatus>(
        'GetHubStatus',
        getHubStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.HubStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.HubSettingsSnapshot>(
        'GetHubSettingsSnapshot',
        getHubSettingsSnapshot_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.HubSettingsSnapshot value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.HubOverview>(
        'GetHubOverview',
        getHubOverview_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.HubOverview value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetHubDashboardSnapshotRequest,
            $0.HubDashboardSnapshot>(
        'GetHubDashboardSnapshot',
        getHubDashboardSnapshot_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetHubDashboardSnapshotRequest.fromBuffer(value),
        ($0.HubDashboardSnapshot value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.RegisterUserRequest, $0.RegisterUserResponse>(
            'RegisterUser',
            registerUser_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.RegisterUserRequest.fromBuffer(value),
            ($0.RegisterUserResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FetchHubCARequest, $0.FetchHubCAResponse>(
        'FetchHubCA',
        fetchHubCA_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FetchHubCARequest.fromBuffer(value),
        ($0.FetchHubCAResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.OnboardHubRequest, $0.OnboardHubResponse>(
        'OnboardHub',
        onboardHub_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.OnboardHubRequest.fromBuffer(value),
        ($0.OnboardHubResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EnsureHubConnectedRequest,
            $0.OnboardHubResponse>(
        'EnsureHubConnected',
        ensureHubConnected_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.EnsureHubConnectedRequest.fromBuffer(value),
        ($0.OnboardHubResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EnsureHubRegisteredRequest,
            $0.OnboardHubResponse>(
        'EnsureHubRegistered',
        ensureHubRegistered_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.EnsureHubRegisteredRequest.fromBuffer(value),
        ($0.OnboardHubResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ResolveHubTrustChallengeRequest,
            $0.OnboardHubResponse>(
        'ResolveHubTrustChallenge',
        resolveHubTrustChallenge_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ResolveHubTrustChallengeRequest.fromBuffer(value),
        ($0.OnboardHubResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.P2PStatus>(
        'GetP2PStatus',
        getP2PStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.P2PStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.P2PSettingsSnapshot>(
        'GetP2PSettingsSnapshot',
        getP2PSettingsSnapshot_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.P2PSettingsSnapshot value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.P2PStatus>(
        'StreamP2PStatus',
        streamP2PStatus_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.P2PStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetP2PModeRequest, $1.Empty>(
        'SetP2PMode',
        setP2PMode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetP2PModeRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LookupIPRequest, $0.LookupIPResponse>(
        'LookupIP',
        lookupIP_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LookupIPRequest.fromBuffer(value),
        ($0.LookupIPResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ConfigureGeoIPNodeRequest,
            $2.ConfigureGeoIPResponse>(
        'ConfigureGeoIP',
        configureGeoIP_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ConfigureGeoIPNodeRequest.fromBuffer(value),
        ($2.ConfigureGeoIPResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetGeoIPStatusNodeRequest,
            $2.GetGeoIPStatusResponse>(
        'GetGeoIPStatus',
        getGeoIPStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetGeoIPStatusNodeRequest.fromBuffer(value),
        ($2.GetGeoIPStatusResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RestartListenersNodeRequest,
            $2.RestartListenersResponse>(
        'RestartListeners',
        restartListeners_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RestartListenersNodeRequest.fromBuffer(value),
        ($2.RestartListenersResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListLocalProxyConfigsRequest,
            $0.ListLocalProxyConfigsResponse>(
        'ListLocalProxyConfigs',
        listLocalProxyConfigs_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListLocalProxyConfigsRequest.fromBuffer(value),
        ($0.ListLocalProxyConfigsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetLocalProxyConfigRequest,
            $0.GetLocalProxyConfigResponse>(
        'GetLocalProxyConfig',
        getLocalProxyConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetLocalProxyConfigRequest.fromBuffer(value),
        ($0.GetLocalProxyConfigResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportLocalProxyConfigRequest,
            $0.ImportLocalProxyConfigResponse>(
        'ImportLocalProxyConfig',
        importLocalProxyConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ImportLocalProxyConfigRequest.fromBuffer(value),
        ($0.ImportLocalProxyConfigResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SaveLocalProxyConfigRequest,
            $0.SaveLocalProxyConfigResponse>(
        'SaveLocalProxyConfig',
        saveLocalProxyConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SaveLocalProxyConfigRequest.fromBuffer(value),
        ($0.SaveLocalProxyConfigResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteLocalProxyConfigRequest,
            $0.DeleteLocalProxyConfigResponse>(
        'DeleteLocalProxyConfig',
        deleteLocalProxyConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteLocalProxyConfigRequest.fromBuffer(value),
        ($0.DeleteLocalProxyConfigResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ValidateLocalProxyConfigRequest,
            $0.ValidateLocalProxyConfigResponse>(
        'ValidateLocalProxyConfig',
        validateLocalProxyConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ValidateLocalProxyConfigRequest.fromBuffer(value),
        ($0.ValidateLocalProxyConfigResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PushProxyRevisionRequest,
            $0.PushProxyRevisionResponse>(
        'PushProxyRevision',
        pushProxyRevision_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PushProxyRevisionRequest.fromBuffer(value),
        ($0.PushProxyRevisionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PushLocalProxyRevisionRequest,
            $0.PushLocalProxyRevisionResponse>(
        'PushLocalProxyRevision',
        pushLocalProxyRevision_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PushLocalProxyRevisionRequest.fromBuffer(value),
        ($0.PushLocalProxyRevisionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PullProxyRevisionRequest,
            $0.PullProxyRevisionResponse>(
        'PullProxyRevision',
        pullProxyRevision_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PullProxyRevisionRequest.fromBuffer(value),
        ($0.PullProxyRevisionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DiffProxyRevisionsRequest,
            $0.DiffProxyRevisionsResponse>(
        'DiffProxyRevisions',
        diffProxyRevisions_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DiffProxyRevisionsRequest.fromBuffer(value),
        ($0.DiffProxyRevisionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListProxyRevisionsRequest,
            $0.ListProxyRevisionsResponse>(
        'ListProxyRevisions',
        listProxyRevisions_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListProxyRevisionsRequest.fromBuffer(value),
        ($0.ListProxyRevisionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FlushProxyRevisionsRequest,
            $0.FlushProxyRevisionsResponse>(
        'FlushProxyRevisions',
        flushProxyRevisions_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.FlushProxyRevisionsRequest.fromBuffer(value),
        ($0.FlushProxyRevisionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListProxyConfigsRequest,
            $0.ListProxyConfigsResponse>(
        'ListProxyConfigs',
        listProxyConfigs_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListProxyConfigsRequest.fromBuffer(value),
        ($0.ListProxyConfigsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateProxyConfigRequest,
            $0.CreateProxyConfigResponse>(
        'CreateProxyConfig',
        createProxyConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateProxyConfigRequest.fromBuffer(value),
        ($0.CreateProxyConfigResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteProxyConfigRequest,
            $0.DeleteProxyConfigResponse>(
        'DeleteProxyConfig',
        deleteProxyConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteProxyConfigRequest.fromBuffer(value),
        ($0.DeleteProxyConfigResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ApplyProxyToNodeRequest,
            $0.ApplyProxyToNodeResponse>(
        'ApplyProxyToNode',
        applyProxyToNode_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ApplyProxyToNodeRequest.fromBuffer(value),
        ($0.ApplyProxyToNodeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnapplyProxyFromNodeRequest,
            $0.UnapplyProxyFromNodeResponse>(
        'UnapplyProxyFromNode',
        unapplyProxyFromNode_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UnapplyProxyFromNodeRequest.fromBuffer(value),
        ($0.UnapplyProxyFromNodeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetAppliedProxiesRequest,
            $0.GetAppliedProxiesResponse>(
        'GetAppliedProxies',
        getAppliedProxies_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetAppliedProxiesRequest.fromBuffer(value),
        ($0.GetAppliedProxiesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AllowIPRequest, $0.AllowIPResponse>(
        'AllowIP',
        allowIP_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AllowIPRequest.fromBuffer(value),
        ($0.AllowIPResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamMetricsRequest, $0.NodeMetrics>(
        'StreamMetrics',
        streamMetrics_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamMetricsRequest.fromBuffer(value),
        ($0.NodeMetrics value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetDebugRuntimeStatsRequest,
            $0.DebugRuntimeStats>(
        'GetDebugRuntimeStats',
        getDebugRuntimeStats_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetDebugRuntimeStatsRequest.fromBuffer(value),
        ($0.DebugRuntimeStats value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetLogsStatsRequest, $0.GetLogsStatsResponse>(
            'GetLogsStats',
            getLogsStats_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetLogsStatsRequest.fromBuffer(value),
            ($0.GetLogsStatsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListLogsRequest, $0.ListLogsResponse>(
        'ListLogs',
        listLogs_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListLogsRequest.fromBuffer(value),
        ($0.ListLogsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteLogsRequest, $0.DeleteLogsResponse>(
        'DeleteLogs',
        deleteLogs_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteLogsRequest.fromBuffer(value),
        ($0.DeleteLogsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CleanupOldLogsRequest,
            $0.CleanupOldLogsResponse>(
        'CleanupOldLogs',
        cleanupOldLogs_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CleanupOldLogsRequest.fromBuffer(value),
        ($0.CleanupOldLogsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetNodeFromHubRequest,
            $0.GetNodeFromHubResponse>(
        'GetNodeFromHub',
        getNodeFromHub_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetNodeFromHubRequest.fromBuffer(value),
        ($0.GetNodeFromHubResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RegisterNodeWithHubRequest,
            $0.RegisterNodeWithHubResponse>(
        'RegisterNodeWithHub',
        registerNodeWithHub_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RegisterNodeWithHubRequest.fromBuffer(value),
        ($0.RegisterNodeWithHubResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.InitializeResponse> initialize_Pre($grpc.ServiceCall $call,
      $async.Future<$0.InitializeRequest> $request) async {
    return initialize($call, await $request);
  }

  $async.Future<$0.InitializeResponse> initialize(
      $grpc.ServiceCall call, $0.InitializeRequest request);

  $async.Future<$1.Empty> shutdown_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return shutdown($call, await $request);
  }

  $async.Future<$1.Empty> shutdown($grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BootstrapStateResponse> getBootstrapState_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getBootstrapState($call, await $request);
  }

  $async.Future<$0.BootstrapStateResponse> getBootstrapState(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.IdentityInfo> getIdentity_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getIdentity($call, await $request);
  }

  $async.Future<$0.IdentityInfo> getIdentity(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.CreateIdentityResponse> createIdentity_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateIdentityRequest> $request) async {
    return createIdentity($call, await $request);
  }

  $async.Future<$0.CreateIdentityResponse> createIdentity(
      $grpc.ServiceCall call, $0.CreateIdentityRequest request);

  $async.Future<$0.RestoreIdentityResponse> restoreIdentity_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RestoreIdentityRequest> $request) async {
    return restoreIdentity($call, await $request);
  }

  $async.Future<$0.RestoreIdentityResponse> restoreIdentity(
      $grpc.ServiceCall call, $0.RestoreIdentityRequest request);

  $async.Future<$0.ImportIdentityResponse> importIdentity_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ImportIdentityRequest> $request) async {
    return importIdentity($call, await $request);
  }

  $async.Future<$0.ImportIdentityResponse> importIdentity(
      $grpc.ServiceCall call, $0.ImportIdentityRequest request);

  $async.Future<$0.UnlockIdentityResponse> unlockIdentity_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UnlockIdentityRequest> $request) async {
    return unlockIdentity($call, await $request);
  }

  $async.Future<$0.UnlockIdentityResponse> unlockIdentity(
      $grpc.ServiceCall call, $0.UnlockIdentityRequest request);

  $async.Future<$1.Empty> lockIdentity_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return lockIdentity($call, await $request);
  }

  $async.Future<$1.Empty> lockIdentity(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$1.Empty> changePassphrase_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChangePassphraseRequest> $request) async {
    return changePassphrase($call, await $request);
  }

  $async.Future<$1.Empty> changePassphrase(
      $grpc.ServiceCall call, $0.ChangePassphraseRequest request);

  $async.Future<$0.EvaluatePassphraseResponse> evaluatePassphrase_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.EvaluatePassphraseRequest> $request) async {
    return evaluatePassphrase($call, await $request);
  }

  $async.Future<$0.EvaluatePassphraseResponse> evaluatePassphrase(
      $grpc.ServiceCall call, $0.EvaluatePassphraseRequest request);

  $async.Future<$1.Empty> resetIdentity_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return resetIdentity($call, await $request);
  }

  $async.Future<$1.Empty> resetIdentity(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.ListNodesResponse> listNodes_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListNodesRequest> $request) async {
    return listNodes($call, await $request);
  }

  $async.Future<$0.ListNodesResponse> listNodes(
      $grpc.ServiceCall call, $0.ListNodesRequest request);

  $async.Future<$0.NodeInfo> getNode_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetNodeRequest> $request) async {
    return getNode($call, await $request);
  }

  $async.Future<$0.NodeInfo> getNode(
      $grpc.ServiceCall call, $0.GetNodeRequest request);

  $async.Future<$0.NodeDetailSnapshot> getNodeDetailSnapshot_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetNodeDetailSnapshotRequest> $request) async {
    return getNodeDetailSnapshot($call, await $request);
  }

  $async.Future<$0.NodeDetailSnapshot> getNodeDetailSnapshot(
      $grpc.ServiceCall call, $0.GetNodeDetailSnapshotRequest request);

  $async.Future<$0.NodeInfo> updateNode_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateNodeRequest> $request) async {
    return updateNode($call, await $request);
  }

  $async.Future<$0.NodeInfo> updateNode(
      $grpc.ServiceCall call, $0.UpdateNodeRequest request);

  $async.Future<$1.Empty> removeNode_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RemoveNodeRequest> $request) async {
    return removeNode($call, await $request);
  }

  $async.Future<$1.Empty> removeNode(
      $grpc.ServiceCall call, $0.RemoveNodeRequest request);

  $async.Future<$0.AddNodeDirectResponse> addNodeDirect_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AddNodeDirectRequest> $request) async {
    return addNodeDirect($call, await $request);
  }

  $async.Future<$0.AddNodeDirectResponse> addNodeDirect(
      $grpc.ServiceCall call, $0.AddNodeDirectRequest request);

  $async.Future<$0.TestDirectConnectionResponse> testDirectConnection_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.TestDirectConnectionRequest> $request) async {
    return testDirectConnection($call, await $request);
  }

  $async.Future<$0.TestDirectConnectionResponse> testDirectConnection(
      $grpc.ServiceCall call, $0.TestDirectConnectionRequest request);

  $async.Future<$0.ListProxiesResponse> listProxies_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListProxiesRequest> $request) async {
    return listProxies($call, await $request);
  }

  $async.Future<$0.ListProxiesResponse> listProxies(
      $grpc.ServiceCall call, $0.ListProxiesRequest request);

  $async.Future<$0.GetProxiesSnapshotResponse> getProxiesSnapshot_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetProxiesSnapshotRequest> $request) async {
    return getProxiesSnapshot($call, await $request);
  }

  $async.Future<$0.GetProxiesSnapshotResponse> getProxiesSnapshot(
      $grpc.ServiceCall call, $0.GetProxiesSnapshotRequest request);

  $async.Future<$0.ProxyInfo> getProxy_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetProxyRequest> $request) async {
    return getProxy($call, await $request);
  }

  $async.Future<$0.ProxyInfo> getProxy(
      $grpc.ServiceCall call, $0.GetProxyRequest request);

  $async.Future<$0.ProxyInfo> addProxy_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AddProxyRequest> $request) async {
    return addProxy($call, await $request);
  }

  $async.Future<$0.ProxyInfo> addProxy(
      $grpc.ServiceCall call, $0.AddProxyRequest request);

  $async.Future<$0.ProxyInfo> updateProxy_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateProxyRequest> $request) async {
    return updateProxy($call, await $request);
  }

  $async.Future<$0.ProxyInfo> updateProxy(
      $grpc.ServiceCall call, $0.UpdateProxyRequest request);

  $async.Future<$0.SetNodeProxiesRunningResponse> setNodeProxiesRunning_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SetNodeProxiesRunningRequest> $request) async {
    return setNodeProxiesRunning($call, await $request);
  }

  $async.Future<$0.SetNodeProxiesRunningResponse> setNodeProxiesRunning(
      $grpc.ServiceCall call, $0.SetNodeProxiesRunningRequest request);

  $async.Future<$1.Empty> removeProxy_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RemoveProxyRequest> $request) async {
    return removeProxy($call, await $request);
  }

  $async.Future<$1.Empty> removeProxy(
      $grpc.ServiceCall call, $0.RemoveProxyRequest request);

  $async.Future<$0.ListRulesResponse> listRules_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListRulesRequest> $request) async {
    return listRules($call, await $request);
  }

  $async.Future<$0.ListRulesResponse> listRules(
      $grpc.ServiceCall call, $0.ListRulesRequest request);

  $async.Future<$2.Rule> getRule_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetRuleRequest> $request) async {
    return getRule($call, await $request);
  }

  $async.Future<$2.Rule> getRule(
      $grpc.ServiceCall call, $0.GetRuleRequest request);

  $async.Future<$2.Rule> addRule_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AddRuleRequest> $request) async {
    return addRule($call, await $request);
  }

  $async.Future<$2.Rule> addRule(
      $grpc.ServiceCall call, $0.AddRuleRequest request);

  $async.Future<$0.AddQuickRuleResponse> addQuickRule_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AddQuickRuleRequest> $request) async {
    return addQuickRule($call, await $request);
  }

  $async.Future<$0.AddQuickRuleResponse> addQuickRule(
      $grpc.ServiceCall call, $0.AddQuickRuleRequest request);

  $async.Future<$2.Rule> updateRule_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateRuleRequest> $request) async {
    return updateRule($call, await $request);
  }

  $async.Future<$2.Rule> updateRule(
      $grpc.ServiceCall call, $0.UpdateRuleRequest request);

  $async.Future<$1.Empty> removeRule_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RemoveRuleRequest> $request) async {
    return removeRule($call, await $request);
  }

  $async.Future<$1.Empty> removeRule(
      $grpc.ServiceCall call, $0.RemoveRuleRequest request);

  $async.Future<$0.BlockIPResponse> blockIP_Pre($grpc.ServiceCall $call,
      $async.Future<$0.BlockIPRequest> $request) async {
    return blockIP($call, await $request);
  }

  $async.Future<$0.BlockIPResponse> blockIP(
      $grpc.ServiceCall call, $0.BlockIPRequest request);

  $async.Future<$0.BlockISPResponse> blockISP_Pre($grpc.ServiceCall $call,
      $async.Future<$0.BlockISPRequest> $request) async {
    return blockISP($call, await $request);
  }

  $async.Future<$0.BlockISPResponse> blockISP(
      $grpc.ServiceCall call, $0.BlockISPRequest request);

  $async.Future<$0.BlockCountryResponse> blockCountry_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.BlockCountryRequest> $request) async {
    return blockCountry($call, await $request);
  }

  $async.Future<$0.BlockCountryResponse> blockCountry(
      $grpc.ServiceCall call, $0.BlockCountryRequest request);

  $async.Future<$0.AddGlobalRuleResponse> addGlobalRule_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AddGlobalRuleRequest> $request) async {
    return addGlobalRule($call, await $request);
  }

  $async.Future<$0.AddGlobalRuleResponse> addGlobalRule(
      $grpc.ServiceCall call, $0.AddGlobalRuleRequest request);

  $async.Future<$0.ListGlobalRulesResponse> listGlobalRules_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListGlobalRulesRequest> $request) async {
    return listGlobalRules($call, await $request);
  }

  $async.Future<$0.ListGlobalRulesResponse> listGlobalRules(
      $grpc.ServiceCall call, $0.ListGlobalRulesRequest request);

  $async.Future<$0.RemoveGlobalRuleResponse> removeGlobalRule_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RemoveGlobalRuleRequest> $request) async {
    return removeGlobalRule($call, await $request);
  }

  $async.Future<$0.RemoveGlobalRuleResponse> removeGlobalRule(
      $grpc.ServiceCall call, $0.RemoveGlobalRuleRequest request);

  $async.Future<$0.ListPendingApprovalsResponse> listPendingApprovals_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListPendingApprovalsRequest> $request) async {
    return listPendingApprovals($call, await $request);
  }

  $async.Future<$0.ListPendingApprovalsResponse> listPendingApprovals(
      $grpc.ServiceCall call, $0.ListPendingApprovalsRequest request);

  $async.Future<$0.GetApprovalsSnapshotResponse> getApprovalsSnapshot_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetApprovalsSnapshotRequest> $request) async {
    return getApprovalsSnapshot($call, await $request);
  }

  $async.Future<$0.GetApprovalsSnapshotResponse> getApprovalsSnapshot(
      $grpc.ServiceCall call, $0.GetApprovalsSnapshotRequest request);

  $async.Future<$0.ApproveRequestResponse> approveRequest_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ApproveRequestRequest> $request) async {
    return approveRequest($call, await $request);
  }

  $async.Future<$0.ApproveRequestResponse> approveRequest(
      $grpc.ServiceCall call, $0.ApproveRequestRequest request);

  $async.Future<$0.DenyRequestResponse> denyRequest_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DenyRequestRequest> $request) async {
    return denyRequest($call, await $request);
  }

  $async.Future<$0.DenyRequestResponse> denyRequest(
      $grpc.ServiceCall call, $0.DenyRequestRequest request);

  $async.Future<$0.ResolveApprovalDecisionResponse> resolveApprovalDecision_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ResolveApprovalDecisionRequest> $request) async {
    return resolveApprovalDecision($call, await $request);
  }

  $async.Future<$0.ResolveApprovalDecisionResponse> resolveApprovalDecision(
      $grpc.ServiceCall call, $0.ResolveApprovalDecisionRequest request);

  $async.Stream<$0.ApprovalRequest> streamApprovals_Pre($grpc.ServiceCall $call,
      $async.Future<$0.StreamApprovalsRequest> $request) async* {
    yield* streamApprovals($call, await $request);
  }

  $async.Stream<$0.ApprovalRequest> streamApprovals(
      $grpc.ServiceCall call, $0.StreamApprovalsRequest request);

  $async.Future<$0.ListApprovalHistoryResponse> listApprovalHistory_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListApprovalHistoryRequest> $request) async {
    return listApprovalHistory($call, await $request);
  }

  $async.Future<$0.ListApprovalHistoryResponse> listApprovalHistory(
      $grpc.ServiceCall call, $0.ListApprovalHistoryRequest request);

  $async.Future<$0.ClearApprovalHistoryResponse> clearApprovalHistory_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ClearApprovalHistoryRequest> $request) async {
    return clearApprovalHistory($call, await $request);
  }

  $async.Future<$0.ClearApprovalHistoryResponse> clearApprovalHistory(
      $grpc.ServiceCall call, $0.ClearApprovalHistoryRequest request);

  $async.Future<$0.ConnectionStats> getConnectionStats_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetConnectionStatsRequest> $request) async {
    return getConnectionStats($call, await $request);
  }

  $async.Future<$0.ConnectionStats> getConnectionStats(
      $grpc.ServiceCall call, $0.GetConnectionStatsRequest request);

  $async.Future<$0.ListConnectionsResponse> listConnections_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListConnectionsRequest> $request) async {
    return listConnections($call, await $request);
  }

  $async.Future<$0.ListConnectionsResponse> listConnections(
      $grpc.ServiceCall call, $0.ListConnectionsRequest request);

  $async.Future<$0.GetIPStatsResponse> getIPStats_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetIPStatsRequest> $request) async {
    return getIPStats($call, await $request);
  }

  $async.Future<$0.GetIPStatsResponse> getIPStats(
      $grpc.ServiceCall call, $0.GetIPStatsRequest request);

  $async.Future<$0.GetGeoStatsResponse> getGeoStats_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetGeoStatsRequest> $request) async {
    return getGeoStats($call, await $request);
  }

  $async.Future<$0.GetGeoStatsResponse> getGeoStats(
      $grpc.ServiceCall call, $0.GetGeoStatsRequest request);

  $async.Stream<$0.ConnectionEvent> streamConnections_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamConnectionsRequest> $request) async* {
    yield* streamConnections($call, await $request);
  }

  $async.Stream<$0.ConnectionEvent> streamConnections(
      $grpc.ServiceCall call, $0.StreamConnectionsRequest request);

  $async.Future<$0.CloseConnectionResponse> closeConnection_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CloseConnectionRequest> $request) async {
    return closeConnection($call, await $request);
  }

  $async.Future<$0.CloseConnectionResponse> closeConnection(
      $grpc.ServiceCall call, $0.CloseConnectionRequest request);

  $async.Future<$0.CloseAllConnectionsResponse> closeAllConnections_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CloseAllConnectionsRequest> $request) async {
    return closeAllConnections($call, await $request);
  }

  $async.Future<$0.CloseAllConnectionsResponse> closeAllConnections(
      $grpc.ServiceCall call, $0.CloseAllConnectionsRequest request);

  $async.Future<$0.CloseAllNodeConnectionsResponse> closeAllNodeConnections_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CloseAllNodeConnectionsRequest> $request) async {
    return closeAllNodeConnections($call, await $request);
  }

  $async.Future<$0.CloseAllNodeConnectionsResponse> closeAllNodeConnections(
      $grpc.ServiceCall call, $0.CloseAllNodeConnectionsRequest request);

  $async.Future<$0.StartPairingResponse> startPairing_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StartPairingRequest> $request) async {
    return startPairing($call, await $request);
  }

  $async.Future<$0.StartPairingResponse> startPairing(
      $grpc.ServiceCall call, $0.StartPairingRequest request);

  $async.Future<$0.JoinPairingResponse> joinPairing_Pre($grpc.ServiceCall $call,
      $async.Future<$0.JoinPairingRequest> $request) async {
    return joinPairing($call, await $request);
  }

  $async.Future<$0.JoinPairingResponse> joinPairing(
      $grpc.ServiceCall call, $0.JoinPairingRequest request);

  $async.Future<$0.CompletePairingResponse> completePairing_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CompletePairingRequest> $request) async {
    return completePairing($call, await $request);
  }

  $async.Future<$0.CompletePairingResponse> completePairing(
      $grpc.ServiceCall call, $0.CompletePairingRequest request);

  $async.Future<$0.FinalizePairingResponse> finalizePairing_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.FinalizePairingRequest> $request) async {
    return finalizePairing($call, await $request);
  }

  $async.Future<$0.FinalizePairingResponse> finalizePairing(
      $grpc.ServiceCall call, $0.FinalizePairingRequest request);

  $async.Future<$1.Empty> cancelPairing_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CancelPairingRequest> $request) async {
    return cancelPairing($call, await $request);
  }

  $async.Future<$1.Empty> cancelPairing(
      $grpc.ServiceCall call, $0.CancelPairingRequest request);

  $async.Future<$0.GenerateQRCodeResponse> generateQRCode_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GenerateQRCodeRequest> $request) async {
    return generateQRCode($call, await $request);
  }

  $async.Future<$0.GenerateQRCodeResponse> generateQRCode(
      $grpc.ServiceCall call, $0.GenerateQRCodeRequest request);

  $async.Future<$0.ScanQRCodeResponse> scanQRCode_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ScanQRCodeRequest> $request) async {
    return scanQRCode($call, await $request);
  }

  $async.Future<$0.ScanQRCodeResponse> scanQRCode(
      $grpc.ServiceCall call, $0.ScanQRCodeRequest request);

  $async.Future<$0.GenerateQRReplyResponse> generateQRResponse_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GenerateQRReplyRequest> $request) async {
    return generateQRResponse($call, await $request);
  }

  $async.Future<$0.GenerateQRReplyResponse> generateQRResponse(
      $grpc.ServiceCall call, $0.GenerateQRReplyRequest request);

  $async.Future<$0.ListTemplatesResponse> listTemplates_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListTemplatesRequest> $request) async {
    return listTemplates($call, await $request);
  }

  $async.Future<$0.ListTemplatesResponse> listTemplates(
      $grpc.ServiceCall call, $0.ListTemplatesRequest request);

  $async.Future<$0.Template> getTemplate_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetTemplateRequest> $request) async {
    return getTemplate($call, await $request);
  }

  $async.Future<$0.Template> getTemplate(
      $grpc.ServiceCall call, $0.GetTemplateRequest request);

  $async.Future<$0.Template> createTemplate_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateTemplateRequest> $request) async {
    return createTemplate($call, await $request);
  }

  $async.Future<$0.Template> createTemplate(
      $grpc.ServiceCall call, $0.CreateTemplateRequest request);

  $async.Future<$0.ApplyTemplateResponse> applyTemplate_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ApplyTemplateRequest> $request) async {
    return applyTemplate($call, await $request);
  }

  $async.Future<$0.ApplyTemplateResponse> applyTemplate(
      $grpc.ServiceCall call, $0.ApplyTemplateRequest request);

  $async.Future<$1.Empty> deleteTemplate_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteTemplateRequest> $request) async {
    return deleteTemplate($call, await $request);
  }

  $async.Future<$1.Empty> deleteTemplate(
      $grpc.ServiceCall call, $0.DeleteTemplateRequest request);

  $async.Future<$0.SyncTemplatesResponse> syncTemplates_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return syncTemplates($call, await $request);
  }

  $async.Future<$0.SyncTemplatesResponse> syncTemplates(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.ExportTemplateYamlResponse> exportTemplateYaml_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ExportTemplateYamlRequest> $request) async {
    return exportTemplateYaml($call, await $request);
  }

  $async.Future<$0.ExportTemplateYamlResponse> exportTemplateYaml(
      $grpc.ServiceCall call, $0.ExportTemplateYamlRequest request);

  $async.Future<$0.ImportTemplateYamlResponse> importTemplateYaml_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ImportTemplateYamlRequest> $request) async {
    return importTemplateYaml($call, await $request);
  }

  $async.Future<$0.ImportTemplateYamlResponse> importTemplateYaml(
      $grpc.ServiceCall call, $0.ImportTemplateYamlRequest request);

  $async.Future<$0.Settings> getSettings_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getSettings($call, await $request);
  }

  $async.Future<$0.Settings> getSettings(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.SettingsOverviewSnapshot> getSettingsOverviewSnapshot_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getSettingsOverviewSnapshot($call, await $request);
  }

  $async.Future<$0.SettingsOverviewSnapshot> getSettingsOverviewSnapshot(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.Settings> updateSettings_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateSettingsRequest> $request) async {
    return updateSettings($call, await $request);
  }

  $async.Future<$0.Settings> updateSettings(
      $grpc.ServiceCall call, $0.UpdateSettingsRequest request);

  $async.Future<$1.Empty> registerFCMToken_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RegisterFCMTokenRequest> $request) async {
    return registerFCMToken($call, await $request);
  }

  $async.Future<$1.Empty> registerFCMToken(
      $grpc.ServiceCall call, $0.RegisterFCMTokenRequest request);

  $async.Future<$1.Empty> unregisterFCMToken_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return unregisterFCMToken($call, await $request);
  }

  $async.Future<$1.Empty> unregisterFCMToken(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.ConnectToHubResponse> connectToHub_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ConnectToHubRequest> $request) async {
    return connectToHub($call, await $request);
  }

  $async.Future<$0.ConnectToHubResponse> connectToHub(
      $grpc.ServiceCall call, $0.ConnectToHubRequest request);

  $async.Future<$1.Empty> disconnectFromHub_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return disconnectFromHub($call, await $request);
  }

  $async.Future<$1.Empty> disconnectFromHub(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.HubStatus> getHubStatus_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getHubStatus($call, await $request);
  }

  $async.Future<$0.HubStatus> getHubStatus(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.HubSettingsSnapshot> getHubSettingsSnapshot_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getHubSettingsSnapshot($call, await $request);
  }

  $async.Future<$0.HubSettingsSnapshot> getHubSettingsSnapshot(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.HubOverview> getHubOverview_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getHubOverview($call, await $request);
  }

  $async.Future<$0.HubOverview> getHubOverview(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.HubDashboardSnapshot> getHubDashboardSnapshot_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetHubDashboardSnapshotRequest> $request) async {
    return getHubDashboardSnapshot($call, await $request);
  }

  $async.Future<$0.HubDashboardSnapshot> getHubDashboardSnapshot(
      $grpc.ServiceCall call, $0.GetHubDashboardSnapshotRequest request);

  $async.Future<$0.RegisterUserResponse> registerUser_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RegisterUserRequest> $request) async {
    return registerUser($call, await $request);
  }

  $async.Future<$0.RegisterUserResponse> registerUser(
      $grpc.ServiceCall call, $0.RegisterUserRequest request);

  $async.Future<$0.FetchHubCAResponse> fetchHubCA_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FetchHubCARequest> $request) async {
    return fetchHubCA($call, await $request);
  }

  $async.Future<$0.FetchHubCAResponse> fetchHubCA(
      $grpc.ServiceCall call, $0.FetchHubCARequest request);

  $async.Future<$0.OnboardHubResponse> onboardHub_Pre($grpc.ServiceCall $call,
      $async.Future<$0.OnboardHubRequest> $request) async {
    return onboardHub($call, await $request);
  }

  $async.Future<$0.OnboardHubResponse> onboardHub(
      $grpc.ServiceCall call, $0.OnboardHubRequest request);

  $async.Future<$0.OnboardHubResponse> ensureHubConnected_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.EnsureHubConnectedRequest> $request) async {
    return ensureHubConnected($call, await $request);
  }

  $async.Future<$0.OnboardHubResponse> ensureHubConnected(
      $grpc.ServiceCall call, $0.EnsureHubConnectedRequest request);

  $async.Future<$0.OnboardHubResponse> ensureHubRegistered_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.EnsureHubRegisteredRequest> $request) async {
    return ensureHubRegistered($call, await $request);
  }

  $async.Future<$0.OnboardHubResponse> ensureHubRegistered(
      $grpc.ServiceCall call, $0.EnsureHubRegisteredRequest request);

  $async.Future<$0.OnboardHubResponse> resolveHubTrustChallenge_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ResolveHubTrustChallengeRequest> $request) async {
    return resolveHubTrustChallenge($call, await $request);
  }

  $async.Future<$0.OnboardHubResponse> resolveHubTrustChallenge(
      $grpc.ServiceCall call, $0.ResolveHubTrustChallengeRequest request);

  $async.Future<$0.P2PStatus> getP2PStatus_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getP2PStatus($call, await $request);
  }

  $async.Future<$0.P2PStatus> getP2PStatus(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.P2PSettingsSnapshot> getP2PSettingsSnapshot_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getP2PSettingsSnapshot($call, await $request);
  }

  $async.Future<$0.P2PSettingsSnapshot> getP2PSettingsSnapshot(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Stream<$0.P2PStatus> streamP2PStatus_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async* {
    yield* streamP2PStatus($call, await $request);
  }

  $async.Stream<$0.P2PStatus> streamP2PStatus(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$1.Empty> setP2PMode_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetP2PModeRequest> $request) async {
    return setP2PMode($call, await $request);
  }

  $async.Future<$1.Empty> setP2PMode(
      $grpc.ServiceCall call, $0.SetP2PModeRequest request);

  $async.Future<$0.LookupIPResponse> lookupIP_Pre($grpc.ServiceCall $call,
      $async.Future<$0.LookupIPRequest> $request) async {
    return lookupIP($call, await $request);
  }

  $async.Future<$0.LookupIPResponse> lookupIP(
      $grpc.ServiceCall call, $0.LookupIPRequest request);

  $async.Future<$2.ConfigureGeoIPResponse> configureGeoIP_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ConfigureGeoIPNodeRequest> $request) async {
    return configureGeoIP($call, await $request);
  }

  $async.Future<$2.ConfigureGeoIPResponse> configureGeoIP(
      $grpc.ServiceCall call, $0.ConfigureGeoIPNodeRequest request);

  $async.Future<$2.GetGeoIPStatusResponse> getGeoIPStatus_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetGeoIPStatusNodeRequest> $request) async {
    return getGeoIPStatus($call, await $request);
  }

  $async.Future<$2.GetGeoIPStatusResponse> getGeoIPStatus(
      $grpc.ServiceCall call, $0.GetGeoIPStatusNodeRequest request);

  $async.Future<$2.RestartListenersResponse> restartListeners_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RestartListenersNodeRequest> $request) async {
    return restartListeners($call, await $request);
  }

  $async.Future<$2.RestartListenersResponse> restartListeners(
      $grpc.ServiceCall call, $0.RestartListenersNodeRequest request);

  $async.Future<$0.ListLocalProxyConfigsResponse> listLocalProxyConfigs_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListLocalProxyConfigsRequest> $request) async {
    return listLocalProxyConfigs($call, await $request);
  }

  $async.Future<$0.ListLocalProxyConfigsResponse> listLocalProxyConfigs(
      $grpc.ServiceCall call, $0.ListLocalProxyConfigsRequest request);

  $async.Future<$0.GetLocalProxyConfigResponse> getLocalProxyConfig_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetLocalProxyConfigRequest> $request) async {
    return getLocalProxyConfig($call, await $request);
  }

  $async.Future<$0.GetLocalProxyConfigResponse> getLocalProxyConfig(
      $grpc.ServiceCall call, $0.GetLocalProxyConfigRequest request);

  $async.Future<$0.ImportLocalProxyConfigResponse> importLocalProxyConfig_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ImportLocalProxyConfigRequest> $request) async {
    return importLocalProxyConfig($call, await $request);
  }

  $async.Future<$0.ImportLocalProxyConfigResponse> importLocalProxyConfig(
      $grpc.ServiceCall call, $0.ImportLocalProxyConfigRequest request);

  $async.Future<$0.SaveLocalProxyConfigResponse> saveLocalProxyConfig_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SaveLocalProxyConfigRequest> $request) async {
    return saveLocalProxyConfig($call, await $request);
  }

  $async.Future<$0.SaveLocalProxyConfigResponse> saveLocalProxyConfig(
      $grpc.ServiceCall call, $0.SaveLocalProxyConfigRequest request);

  $async.Future<$0.DeleteLocalProxyConfigResponse> deleteLocalProxyConfig_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteLocalProxyConfigRequest> $request) async {
    return deleteLocalProxyConfig($call, await $request);
  }

  $async.Future<$0.DeleteLocalProxyConfigResponse> deleteLocalProxyConfig(
      $grpc.ServiceCall call, $0.DeleteLocalProxyConfigRequest request);

  $async.Future<$0.ValidateLocalProxyConfigResponse>
      validateLocalProxyConfig_Pre($grpc.ServiceCall $call,
          $async.Future<$0.ValidateLocalProxyConfigRequest> $request) async {
    return validateLocalProxyConfig($call, await $request);
  }

  $async.Future<$0.ValidateLocalProxyConfigResponse> validateLocalProxyConfig(
      $grpc.ServiceCall call, $0.ValidateLocalProxyConfigRequest request);

  $async.Future<$0.PushProxyRevisionResponse> pushProxyRevision_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PushProxyRevisionRequest> $request) async {
    return pushProxyRevision($call, await $request);
  }

  $async.Future<$0.PushProxyRevisionResponse> pushProxyRevision(
      $grpc.ServiceCall call, $0.PushProxyRevisionRequest request);

  $async.Future<$0.PushLocalProxyRevisionResponse> pushLocalProxyRevision_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PushLocalProxyRevisionRequest> $request) async {
    return pushLocalProxyRevision($call, await $request);
  }

  $async.Future<$0.PushLocalProxyRevisionResponse> pushLocalProxyRevision(
      $grpc.ServiceCall call, $0.PushLocalProxyRevisionRequest request);

  $async.Future<$0.PullProxyRevisionResponse> pullProxyRevision_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PullProxyRevisionRequest> $request) async {
    return pullProxyRevision($call, await $request);
  }

  $async.Future<$0.PullProxyRevisionResponse> pullProxyRevision(
      $grpc.ServiceCall call, $0.PullProxyRevisionRequest request);

  $async.Future<$0.DiffProxyRevisionsResponse> diffProxyRevisions_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DiffProxyRevisionsRequest> $request) async {
    return diffProxyRevisions($call, await $request);
  }

  $async.Future<$0.DiffProxyRevisionsResponse> diffProxyRevisions(
      $grpc.ServiceCall call, $0.DiffProxyRevisionsRequest request);

  $async.Future<$0.ListProxyRevisionsResponse> listProxyRevisions_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListProxyRevisionsRequest> $request) async {
    return listProxyRevisions($call, await $request);
  }

  $async.Future<$0.ListProxyRevisionsResponse> listProxyRevisions(
      $grpc.ServiceCall call, $0.ListProxyRevisionsRequest request);

  $async.Future<$0.FlushProxyRevisionsResponse> flushProxyRevisions_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.FlushProxyRevisionsRequest> $request) async {
    return flushProxyRevisions($call, await $request);
  }

  $async.Future<$0.FlushProxyRevisionsResponse> flushProxyRevisions(
      $grpc.ServiceCall call, $0.FlushProxyRevisionsRequest request);

  $async.Future<$0.ListProxyConfigsResponse> listProxyConfigs_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListProxyConfigsRequest> $request) async {
    return listProxyConfigs($call, await $request);
  }

  $async.Future<$0.ListProxyConfigsResponse> listProxyConfigs(
      $grpc.ServiceCall call, $0.ListProxyConfigsRequest request);

  $async.Future<$0.CreateProxyConfigResponse> createProxyConfig_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateProxyConfigRequest> $request) async {
    return createProxyConfig($call, await $request);
  }

  $async.Future<$0.CreateProxyConfigResponse> createProxyConfig(
      $grpc.ServiceCall call, $0.CreateProxyConfigRequest request);

  $async.Future<$0.DeleteProxyConfigResponse> deleteProxyConfig_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteProxyConfigRequest> $request) async {
    return deleteProxyConfig($call, await $request);
  }

  $async.Future<$0.DeleteProxyConfigResponse> deleteProxyConfig(
      $grpc.ServiceCall call, $0.DeleteProxyConfigRequest request);

  $async.Future<$0.ApplyProxyToNodeResponse> applyProxyToNode_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ApplyProxyToNodeRequest> $request) async {
    return applyProxyToNode($call, await $request);
  }

  $async.Future<$0.ApplyProxyToNodeResponse> applyProxyToNode(
      $grpc.ServiceCall call, $0.ApplyProxyToNodeRequest request);

  $async.Future<$0.UnapplyProxyFromNodeResponse> unapplyProxyFromNode_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UnapplyProxyFromNodeRequest> $request) async {
    return unapplyProxyFromNode($call, await $request);
  }

  $async.Future<$0.UnapplyProxyFromNodeResponse> unapplyProxyFromNode(
      $grpc.ServiceCall call, $0.UnapplyProxyFromNodeRequest request);

  $async.Future<$0.GetAppliedProxiesResponse> getAppliedProxies_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetAppliedProxiesRequest> $request) async {
    return getAppliedProxies($call, await $request);
  }

  $async.Future<$0.GetAppliedProxiesResponse> getAppliedProxies(
      $grpc.ServiceCall call, $0.GetAppliedProxiesRequest request);

  $async.Future<$0.AllowIPResponse> allowIP_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AllowIPRequest> $request) async {
    return allowIP($call, await $request);
  }

  $async.Future<$0.AllowIPResponse> allowIP(
      $grpc.ServiceCall call, $0.AllowIPRequest request);

  $async.Stream<$0.NodeMetrics> streamMetrics_Pre($grpc.ServiceCall $call,
      $async.Future<$0.StreamMetricsRequest> $request) async* {
    yield* streamMetrics($call, await $request);
  }

  $async.Stream<$0.NodeMetrics> streamMetrics(
      $grpc.ServiceCall call, $0.StreamMetricsRequest request);

  $async.Future<$0.DebugRuntimeStats> getDebugRuntimeStats_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetDebugRuntimeStatsRequest> $request) async {
    return getDebugRuntimeStats($call, await $request);
  }

  $async.Future<$0.DebugRuntimeStats> getDebugRuntimeStats(
      $grpc.ServiceCall call, $0.GetDebugRuntimeStatsRequest request);

  $async.Future<$0.GetLogsStatsResponse> getLogsStats_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetLogsStatsRequest> $request) async {
    return getLogsStats($call, await $request);
  }

  $async.Future<$0.GetLogsStatsResponse> getLogsStats(
      $grpc.ServiceCall call, $0.GetLogsStatsRequest request);

  $async.Future<$0.ListLogsResponse> listLogs_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListLogsRequest> $request) async {
    return listLogs($call, await $request);
  }

  $async.Future<$0.ListLogsResponse> listLogs(
      $grpc.ServiceCall call, $0.ListLogsRequest request);

  $async.Future<$0.DeleteLogsResponse> deleteLogs_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteLogsRequest> $request) async {
    return deleteLogs($call, await $request);
  }

  $async.Future<$0.DeleteLogsResponse> deleteLogs(
      $grpc.ServiceCall call, $0.DeleteLogsRequest request);

  $async.Future<$0.CleanupOldLogsResponse> cleanupOldLogs_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CleanupOldLogsRequest> $request) async {
    return cleanupOldLogs($call, await $request);
  }

  $async.Future<$0.CleanupOldLogsResponse> cleanupOldLogs(
      $grpc.ServiceCall call, $0.CleanupOldLogsRequest request);

  $async.Future<$0.GetNodeFromHubResponse> getNodeFromHub_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetNodeFromHubRequest> $request) async {
    return getNodeFromHub($call, await $request);
  }

  $async.Future<$0.GetNodeFromHubResponse> getNodeFromHub(
      $grpc.ServiceCall call, $0.GetNodeFromHubRequest request);

  $async.Future<$0.RegisterNodeWithHubResponse> registerNodeWithHub_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RegisterNodeWithHubRequest> $request) async {
    return registerNodeWithHub($call, await $request);
  }

  $async.Future<$0.RegisterNodeWithHubResponse> registerNodeWithHub(
      $grpc.ServiceCall call, $0.RegisterNodeWithHubRequest request);
}

@$pb.GrpcServiceName('nitella.local.MobileUIService')
class MobileUIServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  MobileUIServiceClient(super.channel, {super.options, super.interceptors});

  /// New approval request arrived
  $grpc.ResponseFuture<$1.Empty> onApprovalRequest(
    $0.ApprovalRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$onApprovalRequest, request, options: options);
  }

  /// Node status changed (online/offline)
  $grpc.ResponseFuture<$1.Empty> onNodeStatusChange(
    $0.NodeStatusChange request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$onNodeStatusChange, request, options: options);
  }

  /// Connection event (new connection, closed, blocked)
  $grpc.ResponseFuture<$1.Empty> onConnectionEvent(
    $0.ConnectionEvent request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$onConnectionEvent, request, options: options);
  }

  /// Alert notification
  $grpc.ResponseFuture<$1.Empty> onAlert(
    $0.Alert request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$onAlert, request, options: options);
  }

  /// Toast message
  $grpc.ResponseFuture<$1.Empty> onToast(
    $0.ToastMessage request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$onToast, request, options: options);
  }

  // method descriptors

  static final _$onApprovalRequest =
      $grpc.ClientMethod<$0.ApprovalRequest, $1.Empty>(
          '/nitella.local.MobileUIService/OnApprovalRequest',
          ($0.ApprovalRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$onNodeStatusChange =
      $grpc.ClientMethod<$0.NodeStatusChange, $1.Empty>(
          '/nitella.local.MobileUIService/OnNodeStatusChange',
          ($0.NodeStatusChange value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$onConnectionEvent =
      $grpc.ClientMethod<$0.ConnectionEvent, $1.Empty>(
          '/nitella.local.MobileUIService/OnConnectionEvent',
          ($0.ConnectionEvent value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$onAlert = $grpc.ClientMethod<$0.Alert, $1.Empty>(
      '/nitella.local.MobileUIService/OnAlert',
      ($0.Alert value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$onToast = $grpc.ClientMethod<$0.ToastMessage, $1.Empty>(
      '/nitella.local.MobileUIService/OnToast',
      ($0.ToastMessage value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
}

@$pb.GrpcServiceName('nitella.local.MobileUIService')
abstract class MobileUIServiceBase extends $grpc.Service {
  $core.String get $name => 'nitella.local.MobileUIService';

  MobileUIServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ApprovalRequest, $1.Empty>(
        'OnApprovalRequest',
        onApprovalRequest_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ApprovalRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.NodeStatusChange, $1.Empty>(
        'OnNodeStatusChange',
        onNodeStatusChange_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.NodeStatusChange.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ConnectionEvent, $1.Empty>(
        'OnConnectionEvent',
        onConnectionEvent_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ConnectionEvent.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Alert, $1.Empty>(
        'OnAlert',
        onAlert_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Alert.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ToastMessage, $1.Empty>(
        'OnToast',
        onToast_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ToastMessage.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$1.Empty> onApprovalRequest_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ApprovalRequest> $request) async {
    return onApprovalRequest($call, await $request);
  }

  $async.Future<$1.Empty> onApprovalRequest(
      $grpc.ServiceCall call, $0.ApprovalRequest request);

  $async.Future<$1.Empty> onNodeStatusChange_Pre($grpc.ServiceCall $call,
      $async.Future<$0.NodeStatusChange> $request) async {
    return onNodeStatusChange($call, await $request);
  }

  $async.Future<$1.Empty> onNodeStatusChange(
      $grpc.ServiceCall call, $0.NodeStatusChange request);

  $async.Future<$1.Empty> onConnectionEvent_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ConnectionEvent> $request) async {
    return onConnectionEvent($call, await $request);
  }

  $async.Future<$1.Empty> onConnectionEvent(
      $grpc.ServiceCall call, $0.ConnectionEvent request);

  $async.Future<$1.Empty> onAlert_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Alert> $request) async {
    return onAlert($call, await $request);
  }

  $async.Future<$1.Empty> onAlert($grpc.ServiceCall call, $0.Alert request);

  $async.Future<$1.Empty> onToast_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ToastMessage> $request) async {
    return onToast($call, await $request);
  }

  $async.Future<$1.Empty> onToast(
      $grpc.ServiceCall call, $0.ToastMessage request);
}
