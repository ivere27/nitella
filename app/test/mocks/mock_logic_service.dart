import 'dart:async';
import 'package:grpc/grpc.dart';
import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/local/nitella_local.pbgrpc.dart' as local_grpc;
import 'package:nitella_app/common/common.pb.dart' as common;
import 'package:nitella_app/proxy/proxy.pb.dart' as proxy;
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart'
    as $empty;

typedef Empty = $empty.Empty;

/// Mock implementation of MobileLogicServiceClient for testing.
/// Uses a FakeClientChannel to avoid needing a real gRPC connection.
class MockLogicServiceClient extends local_grpc.MobileLogicServiceClient {
  // Test data
  List<local.NodeInfo> nodes = [];
  Map<String, List<local.ProxyInfo>> nodeProxies = {};
  Map<String, List<proxy.Rule>> proxyRules = {};
  List<local.ApprovalRequest> pendingApprovals = [];
  List<local.ApprovalHistoryEntry> approvalHistory = [];
  local.ConnectionStats? stats;
  local.IdentityInfo? identity;
  local.HubStatus? hubStatus;
  local.Settings? settings;

  // Error simulation
  String? simulateError;

  MockLogicServiceClient() : super(FakeClientChannel()) {
    _initTestData();
  }

  void _initTestData() {
    // Create test nodes
    nodes = [
      local.NodeInfo(
        nodeId: 'node-1',
        name: 'Test Node 1',
        emojiHash: '🔒🌟',
        online: true,
        connType: local.NodeConnectionType.NODE_CONNECTION_TYPE_HUB,
        pinned: true,
        alertsEnabled: true,
      ),
      local.NodeInfo(
        nodeId: 'node-2',
        name: 'Test Node 2',
        emojiHash: '🛡️💫',
        online: false,
        connType: local.NodeConnectionType.NODE_CONNECTION_TYPE_HUB,
        pinned: false,
        alertsEnabled: false,
      ),
    ];

    // Create test proxies
    nodeProxies['node-1'] = [
      local.ProxyInfo(
        proxyId: 'proxy-1',
        nodeId: 'node-1',
        name: 'Web Proxy',
        listenAddr: ':8080',
        defaultBackend: 'localhost:3000',
        running: true,
        defaultAction: common.ActionType.ACTION_TYPE_ALLOW,
        activeConnections: Int64(5),
        totalConnections: Int64(150),
        ruleCount: 3,
      ),
      local.ProxyInfo(
        proxyId: 'proxy-2',
        nodeId: 'node-1',
        name: 'SSH Proxy',
        listenAddr: ':2222',
        defaultBackend: 'localhost:22',
        running: false,
        defaultAction: common.ActionType.ACTION_TYPE_REQUIRE_APPROVAL,
        activeConnections: Int64(0),
        totalConnections: Int64(42),
        ruleCount: 1,
      ),
    ];

    // Create test rules with structured conditions
    proxyRules['proxy-1'] = [
      proxy.Rule(
        id: 'rule-1',
        name: 'Block China',
        priority: 100,
        action: common.ActionType.ACTION_TYPE_BLOCK,
        expression: "GeoCountry(`CN`)",
        enabled: true,
        conditions: [
          proxy.Condition(
            type: common.ConditionType.CONDITION_TYPE_GEO_COUNTRY,
            op: common.Operator.OPERATOR_EQ,
            value: 'CN',
          ),
        ],
      ),
      proxy.Rule(
        id: 'rule-2',
        name: 'Allow Private IPs',
        priority: 50,
        action: common.ActionType.ACTION_TYPE_ALLOW,
        expression: "ClientIP(`10.0.0.0/8`)",
        enabled: true,
        conditions: [
          proxy.Condition(
            type: common.ConditionType.CONDITION_TYPE_SOURCE_IP,
            op: common.Operator.OPERATOR_CIDR,
            value: '10.0.0.0/8',
          ),
        ],
      ),
      proxy.Rule(
        id: 'rule-3',
        name: 'Block Scanner ISP',
        priority: 200,
        action: common.ActionType.ACTION_TYPE_BLOCK,
        expression: "!GeoISP(`DigitalOcean`)",
        enabled: true,
        conditions: [
          proxy.Condition(
            type: common.ConditionType.CONDITION_TYPE_GEO_ISP,
            op: common.Operator.OPERATOR_EQ,
            value: 'DigitalOcean',
            negate: true,
          ),
        ],
      ),
    ];

    // Create test stats
    stats = local.ConnectionStats(
      totalConnections: Int64(100),
      activeConnections: Int64(5),
      uniqueIps: Int64(25),
      uniqueCountries: Int64(10),
      allowedTotal: Int64(90),
      blockedTotal: Int64(10),
      bytesIn: Int64(1024 * 1024 * 100),
      bytesOut: Int64(1024 * 1024 * 50),
      pendingApprovals: Int64(3),
    );

    // Create test identity
    identity = local.IdentityInfo(
      exists: true,
      locked: false,
      fingerprint: 'abc123',
      emojiHash: '🔐🎯',
    );

    // Create hub status
    hubStatus = local.HubStatus(
      connected: true,
      hubAddress: 'hub.example.com:50052',
    );

    // Create settings
    settings = local.Settings(
      hubAddress: 'hub.example.com:50052',
      autoConnectHub: true,
      notificationsEnabled: true,
      requireBiometric: true,
    );
  }

  void _checkError() {
    if (simulateError != null) {
      throw GrpcError.unknown(simulateError!);
    }
  }

  // ============ Identity ============

  @override
  ResponseFuture<local.IdentityInfo> getIdentity(Empty request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(identity!);
  }

  @override
  ResponseFuture<local.CreateIdentityResponse> createIdentity(
      local.CreateIdentityRequest request,
      {CallOptions? options}) {
    _checkError();
    identity = local.IdentityInfo(
      exists: true,
      locked: false,
      fingerprint: 'new-fingerprint',
      emojiHash: '🆕🔑',
    );
    return MockResponseFuture(local.CreateIdentityResponse(
      success: true,
      mnemonic:
          'apple banana cherry date elder fig grape honey iris jade kiwi lemon',
    ));
  }

  @override
  ResponseFuture<local.RestoreIdentityResponse> restoreIdentity(
      local.RestoreIdentityRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.RestoreIdentityResponse(success: true));
  }

  @override
  ResponseFuture<local.ImportIdentityResponse> importIdentity(
      local.ImportIdentityRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.ImportIdentityResponse(success: true));
  }

  @override
  ResponseFuture<local.UnlockIdentityResponse> unlockIdentity(
      local.UnlockIdentityRequest request,
      {CallOptions? options}) {
    _checkError();
    identity = identity!..locked = false;
    return MockResponseFuture(local.UnlockIdentityResponse(success: true));
  }

  @override
  ResponseFuture<Empty> lockIdentity(Empty request, {CallOptions? options}) {
    _checkError();
    identity = identity!..locked = true;
    return MockResponseFuture(Empty());
  }

  @override
  ResponseFuture<Empty> changePassphrase(local.ChangePassphraseRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(Empty());
  }

  @override
  ResponseFuture<local.EvaluatePassphraseResponse> evaluatePassphrase(
      local.EvaluatePassphraseRequest request,
      {CallOptions? options}) {
    _checkError();
    final passphrase = request.passphrase;
    final weak = passphrase.length < 8 || passphrase == 'password';
    return MockResponseFuture(local.EvaluatePassphraseResponse(
      strength: weak
          ? local.PassphraseStrength.PASSPHRASE_STRENGTH_WEAK
          : local.PassphraseStrength.PASSPHRASE_STRENGTH_STRONG,
      entropy: weak ? 20 : 80,
      message: weak ? 'low entropy' : 'strong',
      crackTime: weak ? 'minutes' : 'years',
      gpuScenario: weak ? 'dictionary attack' : 'nation-state',
      shouldWarn: weak,
      report: weak ? 'WEAK passphrase' : 'STRONG passphrase',
    ));
  }

  // ============ Nodes ============

  @override
  ResponseFuture<local.ListNodesResponse> listNodes(
      local.ListNodesRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.ListNodesResponse(nodes: nodes));
  }

  @override
  ResponseFuture<local.NodeInfo> getNode(local.GetNodeRequest request,
      {CallOptions? options}) {
    _checkError();
    final node = nodes.firstWhere((n) => n.nodeId == request.nodeId,
        orElse: () => throw GrpcError.notFound('Node not found'));
    return MockResponseFuture(node);
  }

  @override
  ResponseFuture<local.NodeDetailSnapshot> getNodeDetailSnapshot(
      local.GetNodeDetailSnapshotRequest request,
      {CallOptions? options}) {
    _checkError();
    final node = nodes.firstWhere((n) => n.nodeId == request.nodeId,
        orElse: () => throw GrpcError.notFound('Node not found'));

    final defaultAll = !request.includeRuntimeStatus &&
        !request.includeProxies &&
        !request.includeRules &&
        !request.includeConnectionStats;
    final includeRuntimeStatus = request.includeRuntimeStatus || defaultAll;
    final includeProxies = request.includeProxies || defaultAll;
    final includeRules = request.includeRules || defaultAll;
    final includeConnectionStats = request.includeConnectionStats || defaultAll;

    final snapshot = local.NodeDetailSnapshot(node: node);

    if (includeRuntimeStatus) {
      snapshot.runtimeStatus = local.NodeRuntimeStatus(
        status: node.online ? 'ONLINE' : 'OFFLINE',
        lastSeen: node.lastSeen,
        version: node.version,
      );
    }

    final proxies = nodeProxies[node.nodeId] ?? const <local.ProxyInfo>[];
    if (includeProxies) {
      snapshot.proxies.addAll(proxies);
    }

    if (includeRules) {
      final seen = <String>{};
      for (final p in proxies) {
        for (final r in proxyRules[p.proxyId] ?? const <proxy.Rule>[]) {
          if (r.id.isNotEmpty && seen.contains(r.id)) continue;
          if (r.id.isNotEmpty) seen.add(r.id);
          snapshot.rules.add(r);
        }
      }
    }

    if (includeConnectionStats && stats != null) {
      snapshot.connectionStats = stats!;
    }

    return MockResponseFuture(snapshot);
  }

  @override
  ResponseFuture<local.NodeInfo> updateNode(local.UpdateNodeRequest request,
      {CallOptions? options}) {
    _checkError();
    final idx = nodes.indexWhere((n) => n.nodeId == request.nodeId);
    if (idx >= 0) {
      if (request.name.isNotEmpty) nodes[idx].name = request.name;
      nodes[idx].pinned = request.pinned;
      nodes[idx].alertsEnabled = request.alertsEnabled;
    }
    return MockResponseFuture(nodes[idx]);
  }

  @override
  ResponseFuture<Empty> removeNode(local.RemoveNodeRequest request,
      {CallOptions? options}) {
    _checkError();
    nodes.removeWhere((n) => n.nodeId == request.nodeId);
    return MockResponseFuture(Empty());
  }

  // ============ Proxies ============

  @override
  ResponseFuture<local.ListProxiesResponse> listProxies(
      local.ListProxiesRequest request,
      {CallOptions? options}) {
    _checkError();
    final proxies = nodeProxies[request.nodeId] ?? [];
    return MockResponseFuture(local.ListProxiesResponse(proxies: proxies));
  }

  @override
  ResponseFuture<local.GetProxiesSnapshotResponse> getProxiesSnapshot(
      local.GetProxiesSnapshotRequest request,
      {CallOptions? options}) {
    _checkError();
    final filter = request.nodeFilter.trim().toLowerCase();
    final snapshots = <local.NodeProxiesSnapshot>[];
    var totalProxies = 0;

    for (final node in nodes) {
      if (request.nodeId.isNotEmpty && node.nodeId != request.nodeId) {
        continue;
      }
      if (filter == 'online' && !node.online) continue;
      if (filter == 'offline' && node.online) continue;

      final proxies = nodeProxies[node.nodeId] ?? [];
      totalProxies += proxies.length;
      snapshots.add(local.NodeProxiesSnapshot(
        node: node,
        proxies: proxies,
      ));
    }

    return MockResponseFuture(local.GetProxiesSnapshotResponse(
      nodeSnapshots: snapshots,
      totalNodes: snapshots.length,
      totalProxies: totalProxies,
    ));
  }

  @override
  ResponseFuture<local.ProxyInfo> getProxy(local.GetProxyRequest request,
      {CallOptions? options}) {
    _checkError();
    final proxies = nodeProxies[request.nodeId] ?? [];
    final p = proxies.firstWhere((p) => p.proxyId == request.proxyId,
        orElse: () => throw GrpcError.notFound('Proxy not found'));
    return MockResponseFuture(p);
  }

  @override
  ResponseFuture<local.ProxyInfo> addProxy(local.AddProxyRequest request,
      {CallOptions? options}) {
    _checkError();
    final newProxy = local.ProxyInfo(
      proxyId: 'proxy-${DateTime.now().millisecondsSinceEpoch}',
      nodeId: request.nodeId,
      name: request.name,
      listenAddr: request.listenAddr,
      defaultBackend: request.defaultBackend,
      defaultAction: request.defaultAction,
      running: false,
    );
    nodeProxies.putIfAbsent(request.nodeId, () => []);
    nodeProxies[request.nodeId]!.add(newProxy);
    return MockResponseFuture(newProxy);
  }

  @override
  ResponseFuture<local.ProxyInfo> updateProxy(local.UpdateProxyRequest request,
      {CallOptions? options}) {
    _checkError();
    final proxies = nodeProxies[request.nodeId] ?? [];
    final idx = proxies.indexWhere((p) => p.proxyId == request.proxyId);
    if (idx >= 0) {
      if (request.name.isNotEmpty) proxies[idx].name = request.name;
      if (request.listenAddr.isNotEmpty) {
        proxies[idx].listenAddr = request.listenAddr;
      }
      proxies[idx].running = request.running;
    }
    return MockResponseFuture(proxies[idx]);
  }

  @override
  ResponseFuture<Empty> removeProxy(local.RemoveProxyRequest request,
      {CallOptions? options}) {
    _checkError();
    nodeProxies[request.nodeId]
        ?.removeWhere((p) => p.proxyId == request.proxyId);
    return MockResponseFuture(Empty());
  }

  // ============ Rules ============

  @override
  ResponseFuture<local.ListRulesResponse> listRules(
      local.ListRulesRequest request,
      {CallOptions? options}) {
    _checkError();
    final rules = proxyRules[request.proxyId] ?? [];
    return MockResponseFuture(local.ListRulesResponse(rules: rules));
  }

  @override
  ResponseFuture<proxy.Rule> getRule(local.GetRuleRequest request,
      {CallOptions? options}) {
    _checkError();
    final rules = proxyRules[request.proxyId] ?? [];
    final rule = rules.firstWhere((r) => r.id == request.ruleId,
        orElse: () => throw GrpcError.notFound('Rule not found'));
    return MockResponseFuture(rule);
  }

  @override
  ResponseFuture<proxy.Rule> addRule(local.AddRuleRequest request,
      {CallOptions? options}) {
    _checkError();
    final newRule = request.rule
      ..id = 'rule-${DateTime.now().millisecondsSinceEpoch}';
    proxyRules.putIfAbsent(request.proxyId, () => []);
    proxyRules[request.proxyId]!.add(newRule);
    return MockResponseFuture(newRule);
  }

  @override
  ResponseFuture<local.AddQuickRuleResponse> addQuickRule(
      local.AddQuickRuleRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.AddQuickRuleResponse(
      success: true,
      ruleId: 'rule-quick-${DateTime.now().millisecondsSinceEpoch}',
      rulesCreated: 1,
    ));
  }

  @override
  ResponseFuture<proxy.Rule> updateRule(local.UpdateRuleRequest request,
      {CallOptions? options}) {
    _checkError();
    final rules = proxyRules[request.proxyId] ?? [];
    final idx = rules.indexWhere((r) => r.id == request.rule.id);
    if (idx >= 0) {
      rules[idx] = request.rule;
    }
    return MockResponseFuture(request.rule);
  }

  @override
  ResponseFuture<Empty> removeRule(local.RemoveRuleRequest request,
      {CallOptions? options}) {
    _checkError();
    proxyRules[request.proxyId]?.removeWhere((r) => r.id == request.ruleId);
    return MockResponseFuture(Empty());
  }

  @override
  ResponseFuture<local.BlockIPResponse> blockIP(local.BlockIPRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.BlockIPResponse(
      success: true,
      rulesCreated: 1,
    ));
  }

  @override
  ResponseFuture<local.AllowIPResponse> allowIP(local.AllowIPRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.AllowIPResponse(
      success: true,
      rulesCreated: 1,
    ));
  }

  @override
  ResponseFuture<local.BlockISPResponse> blockISP(local.BlockISPRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.BlockISPResponse(
      success: true,
      ruleId: 'rule-isp-1',
    ));
  }

  @override
  ResponseFuture<local.BlockCountryResponse> blockCountry(
      local.BlockCountryRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.BlockCountryResponse(
      success: true,
      ruleId: 'rule-country-1',
    ));
  }

  // ============ Approvals ============

  @override
  ResponseFuture<local.ListPendingApprovalsResponse> listPendingApprovals(
      local.ListPendingApprovalsRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(
        local.ListPendingApprovalsResponse(requests: pendingApprovals));
  }

  @override
  ResponseFuture<local.GetApprovalsSnapshotResponse> getApprovalsSnapshot(
      local.GetApprovalsSnapshotRequest request,
      {CallOptions? options}) {
    _checkError();
    final nodeId = request.nodeId;
    final filteredPending = nodeId.isEmpty
        ? pendingApprovals
        : pendingApprovals.where((r) => r.nodeId == nodeId).toList();

    final includeHistory = request.includeHistory;
    List<local.ApprovalHistoryEntry> filteredHistory = [];
    var historyTotalCount = 0;
    if (includeHistory) {
      filteredHistory = nodeId.isEmpty
          ? approvalHistory
          : approvalHistory.where((h) => h.nodeId == nodeId).toList();
      historyTotalCount = filteredHistory.length;
      final offset = request.historyOffset < 0 ? 0 : request.historyOffset;
      final defaultLimit = 100;
      final limit =
          request.historyLimit <= 0 ? defaultLimit : request.historyLimit;
      final start =
          offset > filteredHistory.length ? filteredHistory.length : offset;
      final end = (start + limit) > filteredHistory.length
          ? filteredHistory.length
          : (start + limit);
      filteredHistory = filteredHistory.sublist(start, end);
    }

    return MockResponseFuture(local.GetApprovalsSnapshotResponse(
      pendingRequests: filteredPending,
      pendingTotalCount: filteredPending.length,
      historyEntries: filteredHistory,
      historyTotalCount: includeHistory ? historyTotalCount : 0,
      approveDurationOptions: [
        Int64(0),
        Int64(10),
        Int64(60),
        Int64(300),
        Int64(600),
        Int64(3600),
        Int64(86400),
        Int64(-1),
      ],
      defaultApproveDurationSeconds: Int64(300),
      denyBlockOptions: [
        local.DenyBlockType.DENY_BLOCK_TYPE_NONE,
        local.DenyBlockType.DENY_BLOCK_TYPE_IP,
        local.DenyBlockType.DENY_BLOCK_TYPE_ISP,
      ],
    ));
  }

  @override
  ResponseFuture<local.ListApprovalHistoryResponse> listApprovalHistory(
      local.ListApprovalHistoryRequest request,
      {CallOptions? options}) {
    _checkError();
    final nodeId = request.nodeId;
    var filtered = nodeId.isEmpty
        ? approvalHistory
        : approvalHistory.where((h) => h.nodeId == nodeId).toList();
    final totalCount = filtered.length;
    final offset = request.offset < 0 ? 0 : request.offset;
    final defaultLimit = 100;
    final limit = request.limit <= 0 ? defaultLimit : request.limit;
    final start = offset > filtered.length ? filtered.length : offset;
    final end =
        (start + limit) > filtered.length ? filtered.length : (start + limit);
    filtered = filtered.sublist(start, end);
    return MockResponseFuture(local.ListApprovalHistoryResponse(
      entries: filtered,
      totalCount: totalCount,
    ));
  }

  @override
  ResponseFuture<local.ClearApprovalHistoryResponse> clearApprovalHistory(
      local.ClearApprovalHistoryRequest request,
      {CallOptions? options}) {
    _checkError();
    final deleted = approvalHistory.length;
    approvalHistory = [];
    return MockResponseFuture(local.ClearApprovalHistoryResponse(
      success: true,
      deletedCount: deleted,
    ));
  }

  @override
  ResponseFuture<local.ApproveRequestResponse> approveRequest(
      local.ApproveRequestRequest request,
      {CallOptions? options}) {
    _checkError();
    pendingApprovals.removeWhere((r) => r.requestId == request.requestId);
    return MockResponseFuture(local.ApproveRequestResponse(success: true));
  }

  @override
  ResponseFuture<local.DenyRequestResponse> denyRequest(
      local.DenyRequestRequest request,
      {CallOptions? options}) {
    _checkError();
    pendingApprovals.removeWhere((r) => r.requestId == request.requestId);
    return MockResponseFuture(local.DenyRequestResponse(success: true));
  }

  @override
  ResponseFuture<local.ResolveApprovalDecisionResponse> resolveApprovalDecision(
      local.ResolveApprovalDecisionRequest request,
      {CallOptions? options}) {
    _checkError();
    pendingApprovals.removeWhere((r) => r.requestId == request.requestId);
    return MockResponseFuture(
        local.ResolveApprovalDecisionResponse(success: true));
  }

  @override
  ResponseStream<local.ApprovalRequest> streamApprovals(
      local.StreamApprovalsRequest request,
      {CallOptions? options}) {
    throw UnimplementedError('Streaming not supported in mock');
  }

  // ============ Stats ============

  @override
  ResponseFuture<local.ConnectionStats> getConnectionStats(
      local.GetConnectionStatsRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(stats!);
  }

  @override
  ResponseFuture<local.ListConnectionsResponse> listConnections(
      local.ListConnectionsRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.ListConnectionsResponse(connections: []));
  }

  @override
  ResponseFuture<local.GetIPStatsResponse> getIPStats(
      local.GetIPStatsRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.GetIPStatsResponse(stats: [
      local.IPStats(
        sourceIp: '192.168.1.100',
        geoCountry: 'US',
        geoIsp: 'Comcast',
        connectionCount: Int64(10),
        blockedCount: Int64(1),
      ),
    ]));
  }

  @override
  ResponseFuture<local.GetGeoStatsResponse> getGeoStats(
      local.GetGeoStatsRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.GetGeoStatsResponse(stats: [
      local.GeoStats(
        value: 'US',
        connectionCount: Int64(50),
        blockedCount: Int64(5),
        uniqueIps: Int64(10),
      ),
      local.GeoStats(
        value: 'KR',
        connectionCount: Int64(30),
        blockedCount: Int64(2),
        uniqueIps: Int64(5),
      ),
    ]));
  }

  // LookupGeoIP removed — use lookupIP instead

  @override
  ResponseStream<local.ConnectionEvent> streamConnections(
      local.StreamConnectionsRequest request,
      {CallOptions? options}) {
    throw UnimplementedError('Streaming not supported in mock');
  }

  @override
  ResponseFuture<local.CloseConnectionResponse> closeConnection(
      local.CloseConnectionRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.CloseConnectionResponse(success: true));
  }

  @override
  ResponseFuture<local.CloseAllConnectionsResponse> closeAllConnections(
      local.CloseAllConnectionsRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(
        local.CloseAllConnectionsResponse(closedCount: 5));
  }

  // ============ Pairing ============

  @override
  ResponseFuture<local.StartPairingResponse> startPairing(
      local.StartPairingRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.StartPairingResponse(
      sessionId: 'session-1',
    ));
  }

  @override
  ResponseFuture<local.JoinPairingResponse> joinPairing(
      local.JoinPairingRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.JoinPairingResponse(
      success: true,
      sessionId: 'session-1',
      emojiFingerprint: '🦊🐼🛰️🔥',
      nodeName: 'mock-node',
    ));
  }

  @override
  ResponseFuture<local.CompletePairingResponse> completePairing(
      local.CompletePairingRequest request,
      {CallOptions? options}) {
    _checkError();
    final newNode = local.NodeInfo(
      nodeId: 'node-new',
      name: 'Newly Paired Node',
      online: true,
    );
    nodes.add(newNode);
    return MockResponseFuture(local.CompletePairingResponse(
      success: true,
      node: newNode,
    ));
  }

  @override
  ResponseFuture<Empty> cancelPairing(local.CancelPairingRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(Empty());
  }

  @override
  ResponseFuture<local.GenerateQRCodeResponse> generateQRCode(
      local.GenerateQRCodeRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.GenerateQRCodeResponse());
  }

  @override
  ResponseFuture<local.ScanQRCodeResponse> scanQRCode(
      local.ScanQRCodeRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.ScanQRCodeResponse(
      success: true,
      sessionId: 'scan-session-1',
      nodeId: 'mock-node',
      fingerprint: 'mock-fingerprint',
      emojiHash: '🧩🔐🐢⚡',
    ));
  }

  @override
  ResponseFuture<local.GenerateQRReplyResponse> generateQRResponse(
      local.GenerateQRReplyRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.GenerateQRReplyResponse(
      qrData: request.scanSessionId.isNotEmpty
          ? request.scanSessionId.codeUnits
          : 'mock-qr-response'.codeUnits,
    ));
  }

  @override
  ResponseFuture<local.FinalizePairingResponse> finalizePairing(
      local.FinalizePairingRequest request,
      {CallOptions? options}) {
    _checkError();
    if (!request.accepted) {
      return MockResponseFuture(local.FinalizePairingResponse(
        success: true,
        cancelled: true,
      ));
    }

    final newNode = local.NodeInfo(
      nodeId: 'node-new',
      name: 'Newly Paired Node',
      online: true,
    );
    nodes.add(newNode);

    final isOffline = request.sessionId.startsWith('scan-session');
    return MockResponseFuture(local.FinalizePairingResponse(
      success: true,
      completed: true,
      node: newNode,
      qrData: isOffline ? '{"t":"cert","nid":"node-new"}'.codeUnits : [],
    ));
  }

  // ============ Templates ============

  @override
  ResponseFuture<local.ListTemplatesResponse> listTemplates(
      local.ListTemplatesRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.ListTemplatesResponse(templates: []));
  }

  @override
  ResponseFuture<local.Template> getTemplate(local.GetTemplateRequest request,
      {CallOptions? options}) {
    _checkError();
    throw GrpcError.notFound('Template not found');
  }

  @override
  ResponseFuture<local.Template> createTemplate(
      local.CreateTemplateRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.Template(
      templateId: 'template-1',
      name: request.name,
      description: request.description,
    ));
  }

  @override
  ResponseFuture<local.ApplyTemplateResponse> applyTemplate(
      local.ApplyTemplateRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.ApplyTemplateResponse(success: true));
  }

  @override
  ResponseFuture<Empty> deleteTemplate(local.DeleteTemplateRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(Empty());
  }

  @override
  ResponseFuture<local.SyncTemplatesResponse> syncTemplates(Empty request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.SyncTemplatesResponse(
      uploaded: 0,
      downloaded: 0,
      conflicts: 0,
    ));
  }

  // ============ Settings ============

  @override
  ResponseFuture<local.Settings> getSettings(Empty request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(settings!);
  }

  @override
  ResponseFuture<local.SettingsOverviewSnapshot> getSettingsOverviewSnapshot(
      Empty request,
      {CallOptions? options}) {
    _checkError();
    final hs = hubStatus ?? local.HubStatus();
    final st = settings ?? local.Settings();
    final resolvedHubAddress =
        hs.hubAddress.isNotEmpty ? hs.hubAddress : st.hubAddress;
    final resolvedInviteCode =
        st.hubInviteCode.isNotEmpty ? st.hubInviteCode : 'NITELLA';
    return MockResponseFuture(local.SettingsOverviewSnapshot(
      identity: identity ?? local.IdentityInfo(),
      hub: local.HubSettingsSnapshot(
        status: hs,
        settings: st,
        resolvedHubAddress: resolvedHubAddress,
        resolvedInviteCode: resolvedInviteCode,
      ),
      p2p: local.P2PSettingsSnapshot(
        status: local.P2PStatus(),
        settings: st,
      ),
    ));
  }

  @override
  ResponseFuture<local.Settings> updateSettings(
      local.UpdateSettingsRequest request,
      {CallOptions? options}) {
    _checkError();
    // UpdateSettingsRequest contains a Settings object
    if (request.settings.hubAddress.isNotEmpty) {
      settings!.hubAddress = request.settings.hubAddress;
    }
    settings!.autoConnectHub = request.settings.autoConnectHub;
    settings!.notificationsEnabled = request.settings.notificationsEnabled;
    settings!.requireBiometric = request.settings.requireBiometric;
    return MockResponseFuture(settings!);
  }

  // ============ FCM ============

  @override
  ResponseFuture<Empty> registerFCMToken(local.RegisterFCMTokenRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(Empty());
  }

  @override
  ResponseFuture<Empty> unregisterFCMToken(Empty request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(Empty());
  }

  // ============ Hub ============

  @override
  ResponseFuture<local.ConnectToHubResponse> connectToHub(
      local.ConnectToHubRequest request,
      {CallOptions? options}) {
    _checkError();
    hubStatus = local.HubStatus(
      connected: true,
      hubAddress: request.hubAddress,
    );
    return MockResponseFuture(local.ConnectToHubResponse(success: true));
  }

  @override
  ResponseFuture<local.FetchHubCAResponse> fetchHubCA(
      local.FetchHubCARequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.FetchHubCAResponse(
      success: true,
      fingerprint: 'abcdef1234567890',
      emojiHash: '🔒🌐🛡️🔑',
      subject: 'Mock Hub CA',
      expires: '2027-01-01',
    ));
  }

  @override
  ResponseFuture<Empty> disconnectFromHub(Empty request,
      {CallOptions? options}) {
    _checkError();
    hubStatus = local.HubStatus(connected: false);
    return MockResponseFuture(Empty());
  }

  @override
  ResponseFuture<local.HubStatus> getHubStatus(Empty request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(hubStatus!);
  }

  @override
  ResponseFuture<local.HubSettingsSnapshot> getHubSettingsSnapshot(
      Empty request,
      {CallOptions? options}) {
    _checkError();
    final hs = hubStatus ?? local.HubStatus();
    final st = settings ?? local.Settings();
    final resolvedHubAddress =
        hs.hubAddress.isNotEmpty ? hs.hubAddress : st.hubAddress;
    final resolvedInviteCode =
        st.hubInviteCode.isNotEmpty ? st.hubInviteCode : 'NITELLA';
    return MockResponseFuture(local.HubSettingsSnapshot(
      status: hs,
      settings: st,
      resolvedHubAddress: resolvedHubAddress,
      resolvedInviteCode: resolvedInviteCode,
    ));
  }

  @override
  ResponseFuture<local.HubOverview> getHubOverview(Empty request,
      {CallOptions? options}) {
    _checkError();
    final nodesList = nodes;
    final totalNodes = nodesList.length;
    final onlineNodes = nodesList.where((n) => n.online).length;
    final pinnedNodes = nodesList.where((n) => n.pinned).length;
    final totalProxies = nodesList.fold<int>(0, (sum, n) => sum + n.proxyCount);
    final totalActiveConnections = nodesList.fold<int>(
        0,
        (sum, n) =>
            sum + (n.hasMetrics() ? n.metrics.activeConnections.toInt() : 0));

    final hs = hubStatus ?? local.HubStatus();
    return MockResponseFuture(local.HubOverview(
      hubConnected: hs.connected,
      hubAddress: hs.hubAddress,
      userId: hs.userId,
      tier: hs.tier,
      maxNodes: hs.maxNodes,
      totalNodes: totalNodes,
      onlineNodes: onlineNodes,
      pinnedNodes: pinnedNodes,
      totalProxies: totalProxies,
      totalActiveConnections: Int64(totalActiveConnections),
    ));
  }

  @override
  ResponseFuture<local.HubDashboardSnapshot> getHubDashboardSnapshot(
      local.GetHubDashboardSnapshotRequest request,
      {CallOptions? options}) {
    _checkError();
    final nodesList = nodes;

    final totalNodes = nodesList.length;
    final onlineNodes = nodesList.where((n) => n.online).length;
    final pinnedNodes = nodesList.where((n) => n.pinned).length;
    final totalProxies = nodesList.fold<int>(0, (sum, n) => sum + n.proxyCount);
    final totalActiveConnections = nodesList.fold<int>(
        0,
        (sum, n) =>
            sum + (n.hasMetrics() ? n.metrics.activeConnections.toInt() : 0));

    final filter = request.nodeFilter.trim().toLowerCase();
    final filteredNodes = nodesList.where((n) {
      if (filter == 'online') return n.online;
      if (filter == 'offline') return !n.online;
      return true;
    }).toList();
    final filteredPinnedNodes = filteredNodes.where((n) => n.pinned).toList();

    final hs = hubStatus ?? local.HubStatus();
    return MockResponseFuture(local.HubDashboardSnapshot(
      overview: local.HubOverview(
        hubConnected: hs.connected,
        hubAddress: hs.hubAddress,
        userId: hs.userId,
        tier: hs.tier,
        maxNodes: hs.maxNodes,
        totalNodes: totalNodes,
        onlineNodes: onlineNodes,
        pinnedNodes: pinnedNodes,
        totalProxies: totalProxies,
        totalActiveConnections: Int64(totalActiveConnections),
      ),
      nodes: filteredNodes,
      pinnedNodes: filteredPinnedNodes,
    ));
  }

  @override
  ResponseFuture<local.RegisterUserResponse> registerUser(
      local.RegisterUserRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.RegisterUserResponse(success: true));
  }

  @override
  ResponseFuture<local.OnboardHubResponse> onboardHub(
      local.OnboardHubRequest request,
      {CallOptions? options}) {
    _checkError();
    final hubAddress = request.hubAddress.isNotEmpty
        ? request.hubAddress
        : (settings?.hubAddress ?? '');
    hubStatus = local.HubStatus(
      connected: true,
      hubAddress: hubAddress,
      userId: 'mock-user',
      tier: 'free',
      maxNodes: 3,
    );
    return MockResponseFuture(local.OnboardHubResponse(
      stage: local.OnboardHubResponse_Stage.STAGE_COMPLETED,
      success: true,
      hubAddress: hubAddress,
      connected: true,
      registered: true,
      userId: 'mock-user',
      tier: 'free',
      maxNodes: 3,
    ));
  }

  @override
  ResponseFuture<local.OnboardHubResponse> ensureHubConnected(
      local.EnsureHubConnectedRequest request,
      {CallOptions? options}) {
    _checkError();
    final hubAddress = request.hubAddress.isNotEmpty
        ? request.hubAddress
        : (settings?.hubAddress ?? '');
    hubStatus = local.HubStatus(
      connected: true,
      hubAddress: hubAddress,
      userId: hubStatus?.userId ?? '',
      tier: hubStatus?.tier ?? '',
      maxNodes: hubStatus?.maxNodes ?? 0,
    );
    return MockResponseFuture(local.OnboardHubResponse(
      stage: local.OnboardHubResponse_Stage.STAGE_COMPLETED,
      success: true,
      hubAddress: hubAddress,
      connected: true,
      registered: (hubStatus?.userId ?? '').isNotEmpty,
      userId: hubStatus?.userId ?? '',
      tier: hubStatus?.tier ?? '',
      maxNodes: hubStatus?.maxNodes ?? 0,
    ));
  }

  @override
  ResponseFuture<local.OnboardHubResponse> ensureHubRegistered(
      local.EnsureHubRegisteredRequest request,
      {CallOptions? options}) {
    _checkError();
    final hubAddress = request.hubAddress.isNotEmpty
        ? request.hubAddress
        : (settings?.hubAddress ?? '');
    hubStatus = local.HubStatus(
      connected: true,
      hubAddress: hubAddress,
      userId: 'mock-user',
      tier: 'free',
      maxNodes: 3,
    );
    return MockResponseFuture(local.OnboardHubResponse(
      stage: local.OnboardHubResponse_Stage.STAGE_COMPLETED,
      success: true,
      hubAddress: hubAddress,
      connected: true,
      registered: true,
      userId: 'mock-user',
      tier: 'free',
      maxNodes: 3,
    ));
  }

  @override
  ResponseFuture<local.OnboardHubResponse> resolveHubTrustChallenge(
      local.ResolveHubTrustChallengeRequest request,
      {CallOptions? options}) {
    _checkError();
    if (!request.accepted) {
      return MockResponseFuture(local.OnboardHubResponse(
        stage: local.OnboardHubResponse_Stage.STAGE_FAILED,
        success: false,
        error: 'hub certificate rejected by user',
      ));
    }
    return MockResponseFuture(local.OnboardHubResponse(
      stage: local.OnboardHubResponse_Stage.STAGE_COMPLETED,
      success: true,
      connected: true,
      registered: true,
      userId: 'mock-user',
      tier: 'free',
      maxNodes: 3,
    ));
  }

  // ============ Lifecycle ============

  @override
  ResponseFuture<local.BootstrapStateResponse> getBootstrapState(Empty request,
      {CallOptions? options}) {
    _checkError();
    final id = identity ?? local.IdentityInfo(exists: true, locked: false);
    final requireBiometric = settings?.requireBiometric ?? false;
    final stage = !id.exists
        ? local.BootstrapStage.BOOTSTRAP_STAGE_SETUP_NEEDED
        : (id.locked || requireBiometric
            ? local.BootstrapStage.BOOTSTRAP_STAGE_AUTH_NEEDED
            : local.BootstrapStage.BOOTSTRAP_STAGE_READY);
    return MockResponseFuture(local.BootstrapStateResponse(
      stage: stage,
      identityExists: id.exists,
      identityLocked: id.locked,
      requireBiometric: requireBiometric,
    ));
  }

  @override
  ResponseFuture<local.InitializeResponse> initialize(
      local.InitializeRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.InitializeResponse(
      success: true,
      identityExists: true,
      identityLocked: false,
    ));
  }

  @override
  ResponseFuture<Empty> shutdown(Empty request, {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(Empty());
  }

  // ============ GeoIP ============

  @override
  ResponseFuture<local.LookupIPResponse> lookupIP(local.LookupIPRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.LookupIPResponse(
      geo: common.GeoInfo(
        country: 'United States',
        countryCode: 'US',
        city: 'San Francisco',
        isp: 'Cloudflare',
        org: 'Cloudflare Inc',
      ),
      cached: false,
    ));
  }

  // ============ Direct Connection ============

  @override
  ResponseFuture<local.AddNodeDirectResponse> addNodeDirect(
      local.AddNodeDirectRequest request,
      {CallOptions? options}) {
    _checkError();
    final newNode = local.NodeInfo(
      nodeId: 'node-direct-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Direct Node',
      online: true,
      connType: local.NodeConnectionType.NODE_CONNECTION_TYPE_DIRECT,
    );
    nodes.add(newNode);
    return MockResponseFuture(local.AddNodeDirectResponse(
      success: true,
      node: newNode,
    ));
  }

  @override
  ResponseFuture<local.TestDirectConnectionResponse> testDirectConnection(
      local.TestDirectConnectionRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.TestDirectConnectionResponse(
      success: true,
    ));
  }

  // ============ P2P ============

  @override
  ResponseFuture<local.P2PStatus> getP2PStatus(Empty request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.P2PStatus());
  }

  @override
  ResponseFuture<local.P2PSettingsSnapshot> getP2PSettingsSnapshot(
      Empty request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(local.P2PSettingsSnapshot(
      status: local.P2PStatus(),
      settings: settings ?? local.Settings(),
    ));
  }

  @override
  ResponseStream<local.P2PStatus> streamP2PStatus(Empty request,
      {CallOptions? options}) {
    throw UnimplementedError('Streaming not supported in mock');
  }

  @override
  ResponseFuture<Empty> setP2PMode(local.SetP2PModeRequest request,
      {CallOptions? options}) {
    _checkError();
    return MockResponseFuture(Empty());
  }
}

/// Fake ClientChannel that does nothing (we override all methods anyway)
class FakeClientChannel extends ClientChannel {
  FakeClientChannel()
      : super('localhost',
            options: const ChannelOptions(
                credentials: ChannelCredentials.insecure()));
}

/// Mock ResponseFuture that immediately returns a value.
class MockResponseFuture<T> implements ResponseFuture<T> {
  final T _value;

  MockResponseFuture(this._value);

  @override
  Future<Map<String, String>> get headers async => {};

  @override
  Future<Map<String, String>> get trailers async => {};

  @override
  Future<void> cancel() async {}

  @override
  Stream<T> asStream() => Stream.value(_value);

  @override
  Future<S> then<S>(FutureOr<S> Function(T value) onValue,
      {Function? onError}) {
    return Future.value(_value).then(onValue, onError: onError);
  }

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) {
    return Future.value(_value).catchError(onError, test: test);
  }

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) {
    return Future.value(_value).whenComplete(action);
  }

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) {
    return Future.value(_value).timeout(timeLimit, onTimeout: onTimeout);
  }
}
