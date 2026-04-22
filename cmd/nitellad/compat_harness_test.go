package main

import (
	"encoding/json"
	"io"
	"net"
	"os"
	"sort"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	hubpb "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/node"
	"google.golang.org/protobuf/proto"
)

type compatCase struct {
	Name         string      `json:"name"`
	Command      string      `json:"command"`
	Status       string      `json:"status"`
	ErrorMessage string      `json:"error_message"`
	PayloadType  string      `json:"payload_type"`
	Payload      interface{} `json:"payload"`
}

type compatIDs struct {
	directProxy  string
	appliedProxy string
	rule         string
	reloadRule   string
	extendedRule string
}

func TestCompatHarnessDumpGo(t *testing.T) {
	outPath := os.Getenv("NITELLA_COMPAT_DUMP")
	if outPath == "" {
		t.Skip("set NITELLA_COMPAT_DUMP to write Go compatibility output")
	}

	oldNodeDataDir := nodeDataDir
	nodeDataDir = t.TempDir()
	t.Cleanup(func() { nodeDataDir = oldNodeDataDir })

	appliedMu.Lock()
	oldApplied := appliedProxies
	appliedProxies = make(map[string]*AppliedProxy)
	appliedMu.Unlock()
	t.Cleanup(func() {
		appliedMu.Lock()
		appliedProxies = oldApplied
		appliedMu.Unlock()
	})

	pm := node.NewProxyManager(node.ListenerModeFfi)
	pm.SetApprovalManager(node.NewApprovalManager(nil))
	t.Cleanup(pm.Close)

	var ids compatIDs
	var cases []compatCase

	cases = append(cases, goCompatStatsCase(t, pm, "status_empty", hubpb.CommandType_COMMAND_TYPE_STATUS, nil, &ids))

	createReq := &pb.CreateProxyRequest{
		Name:          "compat-direct",
		ListenAddr:    "127.0.0.1:0",
		DefaultAction: common.ActionType_ACTION_TYPE_ALLOW,
	}
	createPayload := mustMarshalCompat(t, createReq)
	createRaw, createStatus, createErr := goCompatCommand(pm, hubpb.CommandType_COMMAND_TYPE_CREATE_PROXY, createPayload)
	var createResp pb.CreateProxyResponse
	mustUnmarshalCompat(t, createRaw, &createResp)
	if createResp.ProxyId == "" {
		t.Fatalf("create proxy returned empty proxy id")
	}
	ids.directProxy = createResp.ProxyId
	cases = append(cases, compatCase{
		Name:         "create_proxy",
		Command:      hubpb.CommandType_COMMAND_TYPE_CREATE_PROXY.String(),
		Status:       createStatus,
		ErrorMessage: createErr,
		PayloadType:  "CreateProxyResponse",
		Payload:      normalizeCreateProxyResponseCompat(&createResp, &ids),
	})

	cases = append(cases, goCompatStatsCase(t, pm, "status_after_create", hubpb.CommandType_COMMAND_TYPE_STATUS, nil, &ids))
	cases = append(cases, goCompatStatsCase(t, pm, "metrics_after_create", hubpb.CommandType_COMMAND_TYPE_GET_METRICS, nil, &ids))
	cases = append(cases, goCompatStatsCase(t, pm, "stats_control_after_create", hubpb.CommandType_COMMAND_TYPE_STATS_CONTROL, nil, &ids))
	cases = append(cases, goCompatListProxiesCase(t, pm, "list_after_create", &ids))

	addRuleReq := &pb.AddRuleRequest{
		ProxyId: ids.directProxy,
		Rule: &pb.Rule{
			Name:     "allow-local",
			Priority: 100,
			Enabled:  true,
			Action:   common.ActionType_ACTION_TYPE_ALLOW,
			Conditions: []*pb.Condition{{
				Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
				Op:    common.Operator_OPERATOR_EQ,
				Value: "127.0.0.1",
			}},
			RateLimit: &pb.RateLimitConfig{
				MaxConnections:           2,
				IntervalSeconds:          10,
				AutoBlock:                true,
				BlockDurationSeconds:     30,
				BlockStepsSeconds:        []int32{30, 60},
				CountOnlyFailures:        true,
				FailureDurationThreshold: 3,
			},
		},
	}
	addRuleRaw, addRuleStatus, addRuleErr := goCompatCommand(pm, hubpb.CommandType_COMMAND_TYPE_ADD_RULE, mustMarshalCompat(t, addRuleReq))
	var addedRule pb.Rule
	mustUnmarshalCompat(t, addRuleRaw, &addedRule)
	if addedRule.Id == "" {
		t.Fatalf("add rule returned empty rule id")
	}
	ids.rule = addedRule.Id
	cases = append(cases, compatCase{
		Name:         "add_rule",
		Command:      hubpb.CommandType_COMMAND_TYPE_ADD_RULE.String(),
		Status:       addRuleStatus,
		ErrorMessage: addRuleErr,
		PayloadType:  "Rule",
		Payload:      normalizeRuleCompat(&addedRule, &ids),
	})

	listRulesRaw, listRulesStatus, listRulesErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_LIST_RULES,
		mustMarshalCompat(t, &pb.ListRulesRequest{ProxyId: ids.directProxy}),
	)
	var listRulesResp pb.ListRulesResponse
	mustUnmarshalCompat(t, listRulesRaw, &listRulesResp)
	cases = append(cases, compatCase{
		Name:         "list_rules",
		Command:      hubpb.CommandType_COMMAND_TYPE_LIST_RULES.String(),
		Status:       listRulesStatus,
		ErrorMessage: listRulesErr,
		PayloadType:  "ListRulesResponse",
		Payload:      normalizeListRulesResponseCompat(&listRulesResp, &ids),
	})

	disableRaw, disableStatus, disableErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_DISABLE_PROXY,
		mustMarshalCompat(t, &pb.DisableProxyRequest{ProxyId: ids.directProxy}),
	)
	var disableResp pb.DisableProxyResponse
	mustUnmarshalCompat(t, disableRaw, &disableResp)
	cases = append(cases, compatCase{
		Name:         "disable_proxy",
		Command:      hubpb.CommandType_COMMAND_TYPE_DISABLE_PROXY.String(),
		Status:       disableStatus,
		ErrorMessage: disableErr,
		PayloadType:  "DisableProxyResponse",
		Payload:      normalizeDisableProxyResponseCompat(&disableResp),
	})
	cases = append(cases, goCompatListProxiesCase(t, pm, "list_after_disable", &ids))

	enableRaw, enableStatus, enableErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_ENABLE_PROXY,
		mustMarshalCompat(t, &pb.EnableProxyRequest{ProxyId: ids.directProxy}),
	)
	var enableResp pb.EnableProxyResponse
	mustUnmarshalCompat(t, enableRaw, &enableResp)
	cases = append(cases, compatCase{
		Name:         "enable_proxy",
		Command:      hubpb.CommandType_COMMAND_TYPE_ENABLE_PROXY.String(),
		Status:       enableStatus,
		ErrorMessage: enableErr,
		PayloadType:  "EnableProxyResponse",
		Payload:      normalizeEnableProxyResponseCompat(&enableResp),
	})
	cases = append(cases, goCompatListProxiesCase(t, pm, "list_after_enable", &ids))

	updateRaw, updateStatus, updateErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_UPDATE_PROXY,
		mustMarshalCompat(t, &pb.UpdateProxyRequest{
			ProxyId:        ids.directProxy,
			DefaultBackend: "127.0.0.1:9",
		}),
	)
	var updateResp pb.UpdateProxyResponse
	mustUnmarshalCompat(t, updateRaw, &updateResp)
	cases = append(cases, compatCase{
		Name:         "update_proxy_backend",
		Command:      hubpb.CommandType_COMMAND_TYPE_UPDATE_PROXY.String(),
		Status:       updateStatus,
		ErrorMessage: updateErr,
		PayloadType:  "UpdateProxyResponse",
		Payload:      normalizeUpdateProxyResponseCompat(&updateResp),
	})

	ids.reloadRule = "compat-reload-rule"
	ids.extendedRule = "compat-extended-rule"
	reloadRaw, reloadStatus, reloadErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_RELOAD_RULES,
		mustMarshalCompat(t, &pb.ReloadRulesRequest{Rules: []*pb.Rule{{
			Id:       ids.reloadRule,
			Name:     "reload-block",
			Priority: 200,
			Enabled:  true,
			Action:   common.ActionType_ACTION_TYPE_BLOCK,
			Conditions: []*pb.Condition{{
				Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
				Op:    common.Operator_OPERATOR_EQ,
				Value: "10.0.0.1",
			}},
		}, {
			Id:         ids.extendedRule,
			Name:       "extended-cidr-negated-rate",
			Priority:   150,
			Enabled:    true,
			Action:     common.ActionType_ACTION_TYPE_ALLOW,
			Expression: "SourceIP(`10.10.0.0/16`) && !GeoISP(`Example ISP`)",
			Conditions: []*pb.Condition{{
				Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
				Op:    common.Operator_OPERATOR_CIDR,
				Value: "10.10.0.0/16",
			}, {
				Type:   common.ConditionType_CONDITION_TYPE_GEO_ISP,
				Op:     common.Operator_OPERATOR_CONTAINS,
				Value:  "Example ISP",
				Negate: true,
			}, {
				Type:  common.ConditionType_CONDITION_TYPE_TLS_CN,
				Op:    common.Operator_OPERATOR_EQ,
				Value: "node.example",
			}},
			RateLimit: &pb.RateLimitConfig{
				MaxConnections:       3,
				IntervalSeconds:      15,
				AutoBlock:            true,
				BlockDurationSeconds: 45,
			},
		}}}),
	)
	var reloadResp pb.ReloadRulesResponse
	mustUnmarshalCompat(t, reloadRaw, &reloadResp)
	cases = append(cases, compatCase{
		Name:         "reload_rules",
		Command:      hubpb.CommandType_COMMAND_TYPE_RELOAD_RULES.String(),
		Status:       reloadStatus,
		ErrorMessage: reloadErr,
		PayloadType:  "ReloadRulesResponse",
		Payload:      normalizeReloadRulesResponseCompat(&reloadResp),
	})
	cases = append(cases, goCompatListRulesCase(t, pm, "list_rules_after_reload", &ids))

	restartRaw, restartStatus, restartErr := goCompatCommand(pm, hubpb.CommandType_COMMAND_TYPE_RESTART_LISTENERS, nil)
	var restartResp pb.RestartListenersResponse
	mustUnmarshalCompat(t, restartRaw, &restartResp)
	cases = append(cases, compatCase{
		Name:         "restart_listeners",
		Command:      hubpb.CommandType_COMMAND_TYPE_RESTART_LISTENERS.String(),
		Status:       restartStatus,
		ErrorMessage: restartErr,
		PayloadType:  "RestartListenersResponse",
		Payload:      normalizeRestartListenersResponseCompat(&restartResp),
	})
	cases = append(cases, goCompatListProxiesCase(t, pm, "list_after_restart", &ids))

	getConnsRaw, getConnsStatus, getConnsErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_GET_ACTIVE_CONNECTIONS,
		mustMarshalCompat(t, &pb.GetActiveConnectionsRequest{ProxyId: ids.directProxy}),
	)
	var getConnsResp pb.GetActiveConnectionsResponse
	mustUnmarshalCompat(t, getConnsRaw, &getConnsResp)
	cases = append(cases, compatCase{
		Name:         "get_active_connections_empty",
		Command:      hubpb.CommandType_COMMAND_TYPE_GET_ACTIVE_CONNECTIONS.String(),
		Status:       getConnsStatus,
		ErrorMessage: getConnsErr,
		PayloadType:  "GetActiveConnectionsResponse",
		Payload:      normalizeGetActiveConnectionsResponseCompat(&getConnsResp),
	})

	closeAllRaw, closeAllStatus, closeAllErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_CLOSE_ALL_CONNECTIONS,
		mustMarshalCompat(t, &pb.CloseAllConnectionsRequest{ProxyId: ids.directProxy}),
	)
	var closeAllResp pb.CloseAllConnectionsResponse
	mustUnmarshalCompat(t, closeAllRaw, &closeAllResp)
	cases = append(cases, compatCase{
		Name:         "close_all_connections_empty",
		Command:      hubpb.CommandType_COMMAND_TYPE_CLOSE_ALL_CONNECTIONS.String(),
		Status:       closeAllStatus,
		ErrorMessage: closeAllErr,
		PayloadType:  "CloseAllConnectionsResponse",
		Payload:      normalizeCloseAllConnectionsResponseCompat(&closeAllResp),
	})

	closeRaw, closeStatus, closeErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_CLOSE_CONNECTION,
		mustMarshalCompat(t, &pb.CloseConnectionRequest{ProxyId: ids.directProxy}),
	)
	cases = append(cases, compatCase{
		Name:         "close_connection_missing_conn_id",
		Command:      hubpb.CommandType_COMMAND_TYPE_CLOSE_CONNECTION.String(),
		Status:       closeStatus,
		ErrorMessage: closeErr,
		PayloadType:  "Empty",
		Payload:      normalizeEmptyPayloadCompat(closeRaw),
	})

	closeUnknownRaw, closeUnknownStatus, closeUnknownErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_CLOSE_CONNECTION,
		mustMarshalCompat(t, &pb.CloseConnectionRequest{ProxyId: ids.directProxy, ConnId: "missing-conn"}),
	)
	cases = append(cases, compatCase{
		Name:         "close_connection_unknown_conn_id",
		Command:      hubpb.CommandType_COMMAND_TYPE_CLOSE_CONNECTION.String(),
		Status:       closeUnknownStatus,
		ErrorMessage: closeUnknownErr,
		PayloadType:  "Empty",
		Payload:      normalizeEmptyPayloadCompat(closeUnknownRaw),
	})

	liveBackendAddr := goCompatStartEchoBackend(t)
	liveCreateRaw, liveCreateStatus, liveCreateErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_CREATE_PROXY,
		mustMarshalCompat(t, &pb.CreateProxyRequest{
			Name:           "compat-live",
			ListenAddr:     "127.0.0.1:0",
			DefaultBackend: liveBackendAddr,
			DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
		}),
	)
	var liveCreateResp pb.CreateProxyResponse
	mustUnmarshalCompat(t, liveCreateRaw, &liveCreateResp)
	if liveCreateResp.ProxyId == "" {
		t.Fatalf("create live proxy returned empty proxy id")
	}
	t.Cleanup(func() { _ = pm.RemoveProxy(liveCreateResp.ProxyId) })
	cases = append(cases, compatCase{
		Name:         "create_live_proxy",
		Command:      hubpb.CommandType_COMMAND_TYPE_CREATE_PROXY.String(),
		Status:       liveCreateStatus,
		ErrorMessage: liveCreateErr,
		PayloadType:  "CreateProxyResponse",
		Payload:      normalizeCreateProxyResponseCompat(&liveCreateResp, &ids),
	})

	liveStatus, err := pm.GetStatus(liveCreateResp.ProxyId)
	if err != nil {
		t.Fatalf("get live proxy status: %v", err)
	}
	liveConn, err := net.Dial("tcp", liveStatus.ListenAddr)
	if err != nil {
		t.Fatalf("dial live proxy %s: %v", liveStatus.ListenAddr, err)
	}
	defer liveConn.Close()
	goCompatRoundTrip(t, liveConn)
	goCompatWaitForConnections(t, pm, liveCreateResp.ProxyId, 1)

	liveConnsRaw, liveConnsStatus, liveConnsErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_GET_ACTIVE_CONNECTIONS,
		mustMarshalCompat(t, &pb.GetActiveConnectionsRequest{ProxyId: liveCreateResp.ProxyId}),
	)
	var liveConnsResp pb.GetActiveConnectionsResponse
	mustUnmarshalCompat(t, liveConnsRaw, &liveConnsResp)
	if len(liveConnsResp.Connections) == 0 {
		t.Fatalf("live proxy has no active connection")
	}
	liveConnID := liveConnsResp.Connections[0].Id
	cases = append(cases, compatCase{
		Name:         "get_active_connections_live",
		Command:      hubpb.CommandType_COMMAND_TYPE_GET_ACTIVE_CONNECTIONS.String(),
		Status:       liveConnsStatus,
		ErrorMessage: liveConnsErr,
		PayloadType:  "GetActiveConnectionsResponse",
		Payload:      normalizeActiveConnectionsDetailedCompat(&liveConnsResp),
	})

	closeLiveRaw, closeLiveStatus, closeLiveErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_CLOSE_CONNECTION,
		mustMarshalCompat(t, &pb.CloseConnectionRequest{ProxyId: liveCreateResp.ProxyId, ConnId: liveConnID}),
	)
	var closeLiveResp pb.CloseConnectionResponse
	mustUnmarshalCompat(t, closeLiveRaw, &closeLiveResp)
	cases = append(cases, compatCase{
		Name:         "close_connection_live",
		Command:      hubpb.CommandType_COMMAND_TYPE_CLOSE_CONNECTION.String(),
		Status:       closeLiveStatus,
		ErrorMessage: closeLiveErr,
		PayloadType:  "CloseConnectionResponse",
		Payload:      normalizeCloseConnectionResponseCompat(&closeLiveResp),
	})
	goCompatWaitForConnections(t, pm, liveCreateResp.ProxyId, 0)

	liveAfterCloseRaw, liveAfterCloseStatus, liveAfterCloseErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_GET_ACTIVE_CONNECTIONS,
		mustMarshalCompat(t, &pb.GetActiveConnectionsRequest{ProxyId: liveCreateResp.ProxyId}),
	)
	var liveAfterCloseResp pb.GetActiveConnectionsResponse
	mustUnmarshalCompat(t, liveAfterCloseRaw, &liveAfterCloseResp)
	cases = append(cases, compatCase{
		Name:         "get_active_connections_after_close_live",
		Command:      hubpb.CommandType_COMMAND_TYPE_GET_ACTIVE_CONNECTIONS.String(),
		Status:       liveAfterCloseStatus,
		ErrorMessage: liveAfterCloseErr,
		PayloadType:  "GetActiveConnectionsResponse",
		Payload:      normalizeGetActiveConnectionsResponseCompat(&liveAfterCloseResp),
	})
	if err := pm.RemoveProxy(liveCreateResp.ProxyId); err != nil {
		t.Fatalf("remove live proxy: %v", err)
	}

	cases = append(cases, goCompatListActiveApprovalsCase(t, pm, "list_active_approvals_empty"))

	approvalBytesIn := int64(11)
	approvalBytesOut := int64(17)
	const approvalSourceIP = "192.0.2.44"
	const approvalRuleID = "compat-approval-rule"
	pm.Approval.AddToCacheWithGeo(approvalSourceIP, approvalRuleID, ids.directProxy, "", true, time.Hour, "US", "New York", "Compat ISP")
	pm.Approval.SetConnID(approvalSourceIP, approvalRuleID, "", "compat-approval-conn", &approvalBytesIn, &approvalBytesOut)
	cases = append(cases, goCompatListActiveApprovalsDetailedCase(t, pm, "list_active_approvals_seeded", &ids, &pb.ListActiveApprovalsRequest{}))
	cases = append(cases, goCompatListActiveApprovalsDetailedCase(t, pm, "list_active_approvals_filter_source", &ids, &pb.ListActiveApprovalsRequest{SourceIp: approvalSourceIP}))
	cases = append(cases, goCompatListActiveApprovalsDetailedCase(t, pm, "list_active_approvals_filter_miss", &ids, &pb.ListActiveApprovalsRequest{SourceIp: "198.51.100.200"}))

	cancelSeedRaw, cancelSeedStatus, cancelSeedErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_CANCEL_APPROVAL,
		mustMarshalCompat(t, &pb.CancelApprovalRequest{Key: approvalSourceIP + node.KeySeparator + approvalRuleID}),
	)
	var cancelSeedResp pb.CancelApprovalResponse
	mustUnmarshalCompat(t, cancelSeedRaw, &cancelSeedResp)
	cases = append(cases, compatCase{
		Name:         "cancel_approval_seeded",
		Command:      hubpb.CommandType_COMMAND_TYPE_CANCEL_APPROVAL.String(),
		Status:       cancelSeedStatus,
		ErrorMessage: cancelSeedErr,
		PayloadType:  "CancelApprovalResponse",
		Payload:      normalizeCancelApprovalResponseCompat(&cancelSeedResp),
	})
	cases = append(cases, goCompatListActiveApprovalsCase(t, pm, "list_active_approvals_after_cancel_seeded"))

	cancelRaw, cancelStatus, cancelErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_CANCEL_APPROVAL,
		mustMarshalCompat(t, &pb.CancelApprovalRequest{Key: "bad-key"}),
	)
	var cancelResp pb.CancelApprovalResponse
	mustUnmarshalCompat(t, cancelRaw, &cancelResp)
	cases = append(cases, compatCase{
		Name:         "cancel_approval_invalid_key",
		Command:      hubpb.CommandType_COMMAND_TYPE_CANCEL_APPROVAL.String(),
		Status:       cancelStatus,
		ErrorMessage: cancelErr,
		PayloadType:  "CancelApprovalResponse",
		Payload:      normalizeCancelApprovalResponseCompat(&cancelResp),
	})

	cases = append(cases, goCompatGetGeoIPStatusCase(t, pm, "get_geoip_status_initial"))

	lookupRaw, lookupStatus, lookupErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_LOOKUP_IP,
		mustMarshalCompat(t, &pb.LookupIPRequest{Ip: "127.0.0.1"}),
	)
	var lookupResp pb.LookupIPResponse
	mustUnmarshalCompat(t, lookupRaw, &lookupResp)
	cases = append(cases, compatCase{
		Name:         "lookup_ip_loopback",
		Command:      hubpb.CommandType_COMMAND_TYPE_LOOKUP_IP.String(),
		Status:       lookupStatus,
		ErrorMessage: lookupErr,
		PayloadType:  "LookupIPResponse",
		Payload:      normalizeLookupIPResponseCompat(&lookupResp),
	})

	blockRaw, blockStatus, blockErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_BLOCK_IP,
		mustMarshalCompat(t, &pb.BlockIPRequest{Ip: "203.0.113.7", DurationSeconds: 60}),
	)
	cases = append(cases, compatCase{
		Name:         "block_ip",
		Command:      hubpb.CommandType_COMMAND_TYPE_BLOCK_IP.String(),
		Status:       blockStatus,
		ErrorMessage: blockErr,
		PayloadType:  "Empty",
		Payload:      normalizeEmptyPayloadCompat(blockRaw),
	})
	cases = append(cases, goCompatListGlobalRulesCase(t, pm, "list_global_rules_after_block"))

	allowRaw, allowStatus, allowErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_ALLOW_IP,
		mustMarshalCompat(t, &pb.AllowIPRequest{Ip: "198.51.100.9", DurationSeconds: 120}),
	)
	cases = append(cases, compatCase{
		Name:         "allow_ip",
		Command:      hubpb.CommandType_COMMAND_TYPE_ALLOW_IP.String(),
		Status:       allowStatus,
		ErrorMessage: allowErr,
		PayloadType:  "Empty",
		Payload:      normalizeEmptyPayloadCompat(allowRaw),
	})
	cases = append(cases, goCompatListGlobalRulesCase(t, pm, "list_global_rules_after_allow"))

	removeGlobalRaw, removeGlobalStatus, removeGlobalErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_REMOVE_GLOBAL_RULE,
		mustMarshalCompat(t, &pb.RemoveGlobalRuleRequest{RuleId: "global-block-203.0.113.7"}),
	)
	var removeGlobalResp pb.RemoveGlobalRuleResponse
	mustUnmarshalCompat(t, removeGlobalRaw, &removeGlobalResp)
	cases = append(cases, compatCase{
		Name:         "remove_global_rule",
		Command:      hubpb.CommandType_COMMAND_TYPE_REMOVE_GLOBAL_RULE.String(),
		Status:       removeGlobalStatus,
		ErrorMessage: removeGlobalErr,
		PayloadType:  "RemoveGlobalRuleResponse",
		Payload:      normalizeRemoveGlobalRuleResponseCompat(&removeGlobalResp),
	})
	cases = append(cases, goCompatListGlobalRulesCase(t, pm, "list_global_rules_after_remove"))

	deleteRaw, deleteStatus, deleteErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_DELETE_PROXY,
		mustMarshalCompat(t, &pb.DeleteProxyRequest{ProxyId: ids.directProxy}),
	)
	var deleteResp pb.DeleteProxyResponse
	mustUnmarshalCompat(t, deleteRaw, &deleteResp)
	cases = append(cases, compatCase{
		Name:         "delete_proxy",
		Command:      hubpb.CommandType_COMMAND_TYPE_DELETE_PROXY.String(),
		Status:       deleteStatus,
		ErrorMessage: deleteErr,
		PayloadType:  "DeleteProxyResponse",
		Payload:      normalizeDeleteProxyResponseCompat(&deleteResp),
	})
	cases = append(cases, goCompatListProxiesCase(t, pm, "list_after_delete", &ids))

	applyReq := &pb.ApplyProxyRequest{
		ProxyId:     "compat-template-proxy",
		RevisionNum: 7,
		ConfigYaml: `entryPoints:
  main:
    address: 127.0.0.1:0
    defaultAction: allow
tcp:
  routers:
    main:
      entryPoints: [main]
      service: backend
  services:
    backend:
      address: 127.0.0.1:9
`,
		ConfigHash: "compat-template-hash",
	}
	applyRaw, applyStatus, applyErr := goCompatCommand(pm, hubpb.CommandType_COMMAND_TYPE_APPLY_PROXY, mustMarshalCompat(t, applyReq))
	var applyResp pb.ApplyProxyResponse
	mustUnmarshalCompat(t, applyRaw, &applyResp)
	ids.appliedProxy = applyReq.ProxyId
	cases = append(cases, compatCase{
		Name:         "apply_proxy_template",
		Command:      hubpb.CommandType_COMMAND_TYPE_APPLY_PROXY.String(),
		Status:       applyStatus,
		ErrorMessage: applyErr,
		PayloadType:  "ApplyProxyResponse",
		Payload:      normalizeApplyProxyResponseCompat(&applyResp),
	})

	cases = append(cases, goCompatGetAppliedCase(t, pm, "get_applied_after_apply", &ids))

	unapplyRaw, unapplyStatus, unapplyErr := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_UNAPPLY_PROXY,
		mustMarshalCompat(t, &pb.DeleteProxyRequest{ProxyId: ids.appliedProxy}),
	)
	var unapplyResp pb.DeleteProxyResponse
	mustUnmarshalCompat(t, unapplyRaw, &unapplyResp)
	cases = append(cases, compatCase{
		Name:         "unapply_proxy",
		Command:      hubpb.CommandType_COMMAND_TYPE_UNAPPLY_PROXY.String(),
		Status:       unapplyStatus,
		ErrorMessage: unapplyErr,
		PayloadType:  "DeleteProxyResponse",
		Payload:      normalizeDeleteProxyResponseCompat(&unapplyResp),
	})
	cases = append(cases, goCompatGetAppliedCase(t, pm, "get_applied_after_unapply", &ids))

	data, err := json.MarshalIndent(cases, "", "  ")
	if err != nil {
		t.Fatalf("marshal compat cases: %v", err)
	}
	data = append(data, '\n')
	if err := os.WriteFile(outPath, data, 0644); err != nil {
		t.Fatalf("write compat output: %v", err)
	}
}

func goCompatCommand(pm *node.ProxyManager, cmd hubpb.CommandType, payload []byte) ([]byte, string, string) {
	out, err := handleHubCommandInternal(pm, cmd.String(), payload)
	if err != nil {
		return nil, "ERROR", err.Error()
	}
	return out, "OK", ""
}

func goCompatStatsCase(t *testing.T, pm *node.ProxyManager, name string, cmd hubpb.CommandType, payload []byte, ids *compatIDs) compatCase {
	t.Helper()
	raw, status, errMsg := goCompatCommand(pm, cmd, payload)
	var resp pb.StatsSummaryResponse
	mustUnmarshalCompat(t, raw, &resp)
	return compatCase{
		Name:         name,
		Command:      cmd.String(),
		Status:       status,
		ErrorMessage: errMsg,
		PayloadType:  "StatsSummaryResponse",
		Payload:      normalizeStatsSummaryCompat(&resp),
	}
}

func goCompatListProxiesCase(t *testing.T, pm *node.ProxyManager, name string, ids *compatIDs) compatCase {
	t.Helper()
	raw, status, errMsg := goCompatCommand(pm, hubpb.CommandType_COMMAND_TYPE_LIST_PROXIES, nil)
	var resp pb.ListProxiesResponse
	mustUnmarshalCompat(t, raw, &resp)
	return compatCase{
		Name:         name,
		Command:      hubpb.CommandType_COMMAND_TYPE_LIST_PROXIES.String(),
		Status:       status,
		ErrorMessage: errMsg,
		PayloadType:  "ListProxiesResponse",
		Payload:      normalizeListProxiesResponseCompat(&resp, ids),
	}
}

func goCompatGetAppliedCase(t *testing.T, pm *node.ProxyManager, name string, ids *compatIDs) compatCase {
	t.Helper()
	raw, status, errMsg := goCompatCommand(pm, hubpb.CommandType_COMMAND_TYPE_GET_APPLIED, nil)
	var resp pb.GetAppliedProxiesResponse
	mustUnmarshalCompat(t, raw, &resp)
	return compatCase{
		Name:         name,
		Command:      hubpb.CommandType_COMMAND_TYPE_GET_APPLIED.String(),
		Status:       status,
		ErrorMessage: errMsg,
		PayloadType:  "GetAppliedProxiesResponse",
		Payload:      normalizeGetAppliedResponseCompat(&resp, ids),
	}
}

func goCompatListRulesCase(t *testing.T, pm *node.ProxyManager, name string, ids *compatIDs) compatCase {
	t.Helper()
	raw, status, errMsg := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_LIST_RULES,
		mustMarshalCompat(t, &pb.ListRulesRequest{ProxyId: ids.directProxy}),
	)
	var resp pb.ListRulesResponse
	mustUnmarshalCompat(t, raw, &resp)
	return compatCase{
		Name:         name,
		Command:      hubpb.CommandType_COMMAND_TYPE_LIST_RULES.String(),
		Status:       status,
		ErrorMessage: errMsg,
		PayloadType:  "ListRulesResponse",
		Payload:      normalizeListRulesResponseCompat(&resp, ids),
	}
}

func goCompatListGlobalRulesCase(t *testing.T, pm *node.ProxyManager, name string) compatCase {
	t.Helper()
	raw, status, errMsg := goCompatCommand(pm, hubpb.CommandType_COMMAND_TYPE_LIST_GLOBAL_RULES, nil)
	var resp pb.ListGlobalRulesResponse
	mustUnmarshalCompat(t, raw, &resp)
	return compatCase{
		Name:         name,
		Command:      hubpb.CommandType_COMMAND_TYPE_LIST_GLOBAL_RULES.String(),
		Status:       status,
		ErrorMessage: errMsg,
		PayloadType:  "ListGlobalRulesResponse",
		Payload:      normalizeListGlobalRulesResponseCompat(&resp),
	}
}

func goCompatListActiveApprovalsCase(t *testing.T, pm *node.ProxyManager, name string) compatCase {
	t.Helper()
	raw, status, errMsg := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_LIST_ACTIVE_APPROVALS,
		mustMarshalCompat(t, &pb.ListActiveApprovalsRequest{}),
	)
	var resp pb.ListActiveApprovalsResponse
	mustUnmarshalCompat(t, raw, &resp)
	return compatCase{
		Name:         name,
		Command:      hubpb.CommandType_COMMAND_TYPE_LIST_ACTIVE_APPROVALS.String(),
		Status:       status,
		ErrorMessage: errMsg,
		PayloadType:  "ListActiveApprovalsResponse",
		Payload:      normalizeListActiveApprovalsResponseCompat(&resp),
	}
}

func goCompatGetGeoIPStatusCase(t *testing.T, pm *node.ProxyManager, name string) compatCase {
	t.Helper()
	raw, status, errMsg := goCompatCommand(pm, hubpb.CommandType_COMMAND_TYPE_GET_GEOIP_STATUS, nil)
	var resp pb.GetGeoIPStatusResponse
	mustUnmarshalCompat(t, raw, &resp)
	return compatCase{
		Name:         name,
		Command:      hubpb.CommandType_COMMAND_TYPE_GET_GEOIP_STATUS.String(),
		Status:       status,
		ErrorMessage: errMsg,
		PayloadType:  "GetGeoIPStatusResponse",
		Payload:      normalizeGetGeoIPStatusResponseCompat(&resp),
	}
}

func goCompatListActiveApprovalsDetailedCase(t *testing.T, pm *node.ProxyManager, name string, ids *compatIDs, req *pb.ListActiveApprovalsRequest) compatCase {
	t.Helper()
	raw, status, errMsg := goCompatCommand(
		pm,
		hubpb.CommandType_COMMAND_TYPE_LIST_ACTIVE_APPROVALS,
		mustMarshalCompat(t, req),
	)
	var resp pb.ListActiveApprovalsResponse
	mustUnmarshalCompat(t, raw, &resp)
	return compatCase{
		Name:         name,
		Command:      hubpb.CommandType_COMMAND_TYPE_LIST_ACTIVE_APPROVALS.String(),
		Status:       status,
		ErrorMessage: errMsg,
		PayloadType:  "ListActiveApprovalsResponse",
		Payload:      normalizeListActiveApprovalsDetailedCompat(&resp, ids),
	}
}

func goCompatStartEchoBackend(t *testing.T) string {
	t.Helper()
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("listen echo backend: %v", err)
	}
	t.Cleanup(func() { _ = ln.Close() })
	go func() {
		for {
			conn, err := ln.Accept()
			if err != nil {
				return
			}
			go func(c net.Conn) {
				defer c.Close()
				_, _ = io.Copy(c, c)
			}(conn)
		}
	}()
	return ln.Addr().String()
}

func goCompatRoundTrip(t *testing.T, conn net.Conn) {
	t.Helper()
	if err := conn.SetDeadline(time.Now().Add(2 * time.Second)); err != nil {
		t.Fatalf("set live connection deadline: %v", err)
	}
	if _, err := conn.Write([]byte("ping")); err != nil {
		t.Fatalf("write live connection: %v", err)
	}
	buf := make([]byte, 4)
	if _, err := io.ReadFull(conn, buf); err != nil {
		t.Fatalf("read live connection: %v", err)
	}
	if string(buf) != "ping" {
		t.Fatalf("unexpected live connection echo: %q", string(buf))
	}
	if err := conn.SetDeadline(time.Time{}); err != nil {
		t.Fatalf("clear live connection deadline: %v", err)
	}
}

func goCompatWaitForConnections(t *testing.T, pm *node.ProxyManager, proxyID string, want int) {
	t.Helper()
	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) {
		if got := len(pm.GetActiveConnections(proxyID)); got == want {
			return
		}
		time.Sleep(10 * time.Millisecond)
	}
	t.Fatalf("timed out waiting for %d active connections on %s, got %d", want, proxyID, len(pm.GetActiveConnections(proxyID)))
}

func mustMarshalCompat(t *testing.T, msg proto.Message) []byte {
	t.Helper()
	data, err := proto.Marshal(msg)
	if err != nil {
		t.Fatalf("marshal %T: %v", msg, err)
	}
	return data
}

func mustUnmarshalCompat(t *testing.T, data []byte, msg proto.Message) {
	t.Helper()
	if err := proto.Unmarshal(data, msg); err != nil {
		t.Fatalf("unmarshal %T: %v", msg, err)
	}
}

func normalizeStatsSummaryCompat(resp *pb.StatsSummaryResponse) map[string]interface{} {
	return map[string]interface{}{
		"total_connections":  resp.TotalConnections,
		"active_connections": resp.ActiveConnections,
		"total_bytes_in":     resp.TotalBytesIn,
		"total_bytes_out":    resp.TotalBytesOut,
		"proxy_count":        resp.ProxyCount,
	}
}

func normalizeCreateProxyResponseCompat(resp *pb.CreateProxyResponse, ids *compatIDs) map[string]interface{} {
	return map[string]interface{}{
		"success":       resp.Success,
		"error_message": resp.ErrorMessage,
		"proxy_id":      canonicalProxyIDCompat(resp.ProxyId, ids),
	}
}

func normalizeDeleteProxyResponseCompat(resp *pb.DeleteProxyResponse) map[string]interface{} {
	return map[string]interface{}{
		"success":       resp.Success,
		"error_message": resp.ErrorMessage,
	}
}

func normalizeDisableProxyResponseCompat(resp *pb.DisableProxyResponse) map[string]interface{} {
	return map[string]interface{}{
		"success":       resp.Success,
		"error_message": resp.ErrorMessage,
	}
}

func normalizeEnableProxyResponseCompat(resp *pb.EnableProxyResponse) map[string]interface{} {
	return map[string]interface{}{
		"success":       resp.Success,
		"error_message": resp.ErrorMessage,
	}
}

func normalizeUpdateProxyResponseCompat(resp *pb.UpdateProxyResponse) map[string]interface{} {
	return map[string]interface{}{
		"success":       resp.Success,
		"error_message": resp.ErrorMessage,
	}
}

func normalizeReloadRulesResponseCompat(resp *pb.ReloadRulesResponse) map[string]interface{} {
	return map[string]interface{}{
		"success":       resp.Success,
		"rules_loaded":  resp.RulesLoaded,
		"error_message": resp.ErrorMessage,
	}
}

func normalizeRestartListenersResponseCompat(resp *pb.RestartListenersResponse) map[string]interface{} {
	return map[string]interface{}{
		"success":         resp.Success,
		"restarted_count": resp.RestartedCount,
		"error_message":   resp.ErrorMessage,
	}
}

func normalizeGetActiveConnectionsResponseCompat(resp *pb.GetActiveConnectionsResponse) map[string]interface{} {
	return map[string]interface{}{"connections": len(resp.Connections)}
}

func normalizeCloseAllConnectionsResponseCompat(resp *pb.CloseAllConnectionsResponse) map[string]interface{} {
	return map[string]interface{}{
		"success":       resp.Success,
		"error_message": resp.ErrorMessage,
	}
}

func normalizeCloseConnectionResponseCompat(resp *pb.CloseConnectionResponse) map[string]interface{} {
	return map[string]interface{}{
		"success":       resp.Success,
		"error_message": resp.ErrorMessage,
	}
}

func normalizeActiveConnectionsDetailedCompat(resp *pb.GetActiveConnectionsResponse) map[string]interface{} {
	connections := make([]map[string]interface{}, 0, len(resp.Connections))
	for _, conn := range resp.Connections {
		destAddr := ""
		if conn.DestAddr != "" {
			destAddr = "<dest_addr>"
		}
		connections = append(connections, map[string]interface{}{
			"source_ip":          conn.SourceIp,
			"dest_addr":          destAddr,
			"bytes_in_positive":  conn.BytesIn > 0,
			"bytes_out_positive": conn.BytesOut > 0,
		})
	}
	sort.Slice(connections, func(i, j int) bool {
		return connections[i]["source_ip"].(string) < connections[j]["source_ip"].(string)
	})
	return map[string]interface{}{
		"connections": len(resp.Connections),
		"items":       connections,
	}
}

func normalizeListActiveApprovalsResponseCompat(resp *pb.ListActiveApprovalsResponse) map[string]interface{} {
	return map[string]interface{}{"approvals": len(resp.Approvals)}
}

func normalizeListActiveApprovalsDetailedCompat(resp *pb.ListActiveApprovalsResponse, ids *compatIDs) map[string]interface{} {
	approvals := make([]map[string]interface{}, 0, len(resp.Approvals))
	for _, approval := range resp.Approvals {
		approvals = append(approvals, map[string]interface{}{
			"source_ip":     approval.SourceIp,
			"rule_id":       approval.RuleId,
			"proxy_id":      canonicalProxyIDCompat(approval.ProxyId, ids),
			"allowed":       approval.Allowed,
			"bytes_in":      approval.BytesIn,
			"bytes_out":     approval.BytesOut,
			"geo_country":   approval.GeoCountry,
			"geo_city":      approval.GeoCity,
			"geo_isp":       approval.GeoIsp,
			"blocked_count": approval.BlockedCount,
			"conn_ids":      len(approval.ConnIds),
		})
	}
	sort.Slice(approvals, func(i, j int) bool {
		if approvals[i]["source_ip"].(string) == approvals[j]["source_ip"].(string) {
			return approvals[i]["rule_id"].(string) < approvals[j]["rule_id"].(string)
		}
		return approvals[i]["source_ip"].(string) < approvals[j]["source_ip"].(string)
	})
	return map[string]interface{}{
		"approvals": len(resp.Approvals),
		"items":     approvals,
	}
}

func normalizeCancelApprovalResponseCompat(resp *pb.CancelApprovalResponse) map[string]interface{} {
	return map[string]interface{}{
		"success":            resp.Success,
		"error_message":      resp.ErrorMessage,
		"connections_closed": resp.ConnectionsClosed,
	}
}

func normalizeGetGeoIPStatusResponseCompat(resp *pb.GetGeoIPStatusResponse) map[string]interface{} {
	return map[string]interface{}{
		"enabled":      resp.Enabled,
		"mode":         resp.Mode,
		"city_db_path": resp.CityDbPath,
		"isp_db_path":  resp.IspDbPath,
		"provider":     resp.Provider,
		"strategy":     resp.Strategy,
	}
}

func normalizeLookupIPResponseCompat(resp *pb.LookupIPResponse) map[string]interface{} {
	geo := resp.Geo
	if geo == nil {
		geo = &common.GeoInfo{}
	}
	return map[string]interface{}{
		"cached":       resp.Cached,
		"country":      geo.Country,
		"city":         geo.City,
		"isp":          geo.Isp,
		"country_code": geo.CountryCode,
		"source":       geo.Source,
	}
}

func normalizeRemoveGlobalRuleResponseCompat(resp *pb.RemoveGlobalRuleResponse) map[string]interface{} {
	return map[string]interface{}{
		"success":       resp.Success,
		"error_message": resp.ErrorMessage,
	}
}

func normalizeEmptyPayloadCompat(raw []byte) map[string]interface{} {
	return map[string]interface{}{"len": len(raw)}
}

func normalizeApplyProxyResponseCompat(resp *pb.ApplyProxyResponse) map[string]interface{} {
	return map[string]interface{}{
		"success":       resp.Success,
		"error_message": resp.ErrorMessage,
	}
}

func normalizeListProxiesResponseCompat(resp *pb.ListProxiesResponse, ids *compatIDs) map[string]interface{} {
	proxies := make([]map[string]interface{}, 0, len(resp.Proxies))
	for _, proxy := range resp.Proxies {
		proxies = append(proxies, normalizeProxyStatusCompat(proxy, ids))
	}
	sort.Slice(proxies, func(i, j int) bool {
		return proxies[i]["proxy_id"].(string) < proxies[j]["proxy_id"].(string)
	})
	return map[string]interface{}{"proxies": proxies}
}

func normalizeProxyStatusCompat(resp *pb.ProxyStatus, ids *compatIDs) map[string]interface{} {
	listenAddr := ""
	if resp.ListenAddr != "" {
		listenAddr = "<listen_addr>"
	}
	return map[string]interface{}{
		"proxy_id":        canonicalProxyIDCompat(resp.ProxyId, ids),
		"running":         resp.Running,
		"listen_addr":     listenAddr,
		"default_backend": resp.DefaultBackend,
		"default_action":  int32(resp.DefaultAction),
		"default_mock":    int32(resp.DefaultMock),
		"fallback_action": int32(resp.FallbackAction),
		"fallback_mock":   int32(resp.FallbackMock),
	}
}

func normalizeListRulesResponseCompat(resp *pb.ListRulesResponse, ids *compatIDs) map[string]interface{} {
	rules := make([]map[string]interface{}, 0, len(resp.Rules))
	for _, rule := range resp.Rules {
		rules = append(rules, normalizeRuleCompat(rule, ids))
	}
	sort.Slice(rules, func(i, j int) bool {
		return rules[i]["id"].(string) < rules[j]["id"].(string)
	})
	return map[string]interface{}{"rules": rules}
}

func normalizeRuleCompat(rule *pb.Rule, ids *compatIDs) map[string]interface{} {
	conditions := make([]map[string]interface{}, 0, len(rule.Conditions))
	for _, condition := range rule.Conditions {
		conditions = append(conditions, map[string]interface{}{
			"type":   int32(condition.Type),
			"op":     int32(condition.Op),
			"value":  condition.Value,
			"negate": condition.Negate,
		})
	}
	sort.Slice(conditions, func(i, j int) bool {
		return conditions[i]["value"].(string) < conditions[j]["value"].(string)
	})
	return map[string]interface{}{
		"id":             canonicalRuleIDCompat(rule.Id, ids),
		"name":           rule.Name,
		"priority":       rule.Priority,
		"enabled":        rule.Enabled,
		"action":         int32(rule.Action),
		"target_backend": rule.TargetBackend,
		"expression":     rule.Expression,
		"conditions":     conditions,
		"rate_limit":     normalizeRateLimitCompat(rule.RateLimit),
	}
}

func normalizeRateLimitCompat(rateLimit *pb.RateLimitConfig) interface{} {
	if rateLimit == nil {
		return nil
	}
	blockSteps := rateLimit.BlockStepsSeconds
	if blockSteps == nil {
		blockSteps = []int32{}
	}
	return map[string]interface{}{
		"max_connections":            rateLimit.MaxConnections,
		"interval_seconds":           rateLimit.IntervalSeconds,
		"auto_block":                 rateLimit.AutoBlock,
		"block_duration_seconds":     rateLimit.BlockDurationSeconds,
		"block_steps_seconds":        blockSteps,
		"count_only_failures":        rateLimit.CountOnlyFailures,
		"failure_duration_threshold": rateLimit.FailureDurationThreshold,
	}
}

func normalizeGetAppliedResponseCompat(resp *pb.GetAppliedProxiesResponse, ids *compatIDs) map[string]interface{} {
	proxies := make([]map[string]interface{}, 0, len(resp.Proxies))
	for _, proxy := range resp.Proxies {
		proxies = append(proxies, map[string]interface{}{
			"proxy_id":      canonicalProxyIDCompat(proxy.ProxyId, ids),
			"revision_num":  proxy.RevisionNum,
			"status":        proxy.Status,
			"error_message": proxy.ErrorMessage,
		})
	}
	sort.Slice(proxies, func(i, j int) bool {
		return proxies[i]["proxy_id"].(string) < proxies[j]["proxy_id"].(string)
	})
	return map[string]interface{}{"proxies": proxies}
}

func normalizeListGlobalRulesResponseCompat(resp *pb.ListGlobalRulesResponse) map[string]interface{} {
	rules := make([]map[string]interface{}, 0, len(resp.Rules))
	for _, rule := range resp.Rules {
		rules = append(rules, map[string]interface{}{
			"id":        rule.Id,
			"name":      rule.Name,
			"source_ip": rule.SourceIp,
			"action":    int32(rule.Action),
			"expires":   rule.ExpiresAt != nil,
		})
	}
	sort.Slice(rules, func(i, j int) bool {
		return rules[i]["id"].(string) < rules[j]["id"].(string)
	})
	return map[string]interface{}{"rules": rules}
}

func canonicalProxyIDCompat(id string, ids *compatIDs) string {
	switch id {
	case "":
		return ""
	case ids.directProxy:
		return "<direct-proxy>"
	case ids.appliedProxy:
		return "<applied-proxy>"
	default:
		return "<proxy>"
	}
}

func canonicalRuleIDCompat(id string, ids *compatIDs) string {
	if id == "" {
		return ""
	}
	if id == ids.reloadRule {
		return "<reload-rule>"
	}
	if id == ids.extendedRule {
		return "<extended-rule>"
	}
	if id == ids.rule {
		return "<rule>"
	}
	return "<rule>"
}
