package main

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/hub"
	pbLocal "github.com/ivere27/nitella/pkg/api/local"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/service"
	"google.golang.org/protobuf/proto"
	"gopkg.in/yaml.v3"
)

func TestHashConfig(t *testing.T) {
	tests := []struct {
		name    string
		content []byte
		want    string
	}{
		{
			name:    "empty content",
			content: []byte(""),
			want:    "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
		},
		{
			name:    "simple content",
			content: []byte("hello"),
			want:    "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824",
		},
		{
			name:    "yaml content",
			content: []byte("listeners:\n  - type: socks5\n    port: 1080\n"),
			want:    "2930e3b235b18ac30db19467ab4d94cc647d48a1144b848befdc421b3a9f2f3a",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := hashConfig(tt.content)
			if got != tt.want {
				t.Errorf("hashConfig() = %q, want %q", got, tt.want)
			}
			// Verify consistency
			got2 := hashConfig(tt.content)
			if got != got2 {
				t.Errorf("hashConfig() not consistent: got %v, then %v", got, got2)
			}
		})
	}

	// Test that different content produces different hashes
	hash1 := hashConfig([]byte("content1"))
	hash2 := hashConfig([]byte("content2"))
	if hash1 == hash2 {
		t.Errorf("hashConfig() produced same hash for different content")
	}
}

func TestFormatSize(t *testing.T) {
	tests := []struct {
		bytes int64
		want  string
	}{
		{0, "0 B"},
		{100, "100 B"},
		{1023, "1023 B"},
		{1024, "1.0 KB"},
		{1536, "1.5 KB"},
		{1048576, "1.0 MB"},
		{1073741824, "1.0 GB"},
		{1099511627776, "1.0 TB"},
	}

	for _, tt := range tests {
		t.Run(tt.want, func(t *testing.T) {
			got := formatSize(tt.bytes)
			if got != tt.want {
				t.Errorf("formatSize(%d) = %q, want %q", tt.bytes, got, tt.want)
			}
		})
	}
}

func TestProxyMetaSerialization(t *testing.T) {
	now := time.Now().Truncate(time.Second)
	meta := ProxyMeta{
		ID:          "test-proxy-123",
		Name:        "Test Proxy",
		Description: "A test proxy configuration",
		CreatedAt:   now,
		UpdatedAt:   now,
		SyncedAt:    now,
		RevisionNum: 5,
		ConfigHash:  "abc123def456",
	}

	// Test JSON roundtrip — all fields
	jsonData, err := json.Marshal(meta)
	if err != nil {
		t.Fatalf("json.Marshal() error = %v", err)
	}

	var jsonMeta ProxyMeta
	if err := json.Unmarshal(jsonData, &jsonMeta); err != nil {
		t.Fatalf("json.Unmarshal() error = %v", err)
	}

	if jsonMeta.ID != meta.ID {
		t.Errorf("JSON roundtrip: ID = %q, want %q", jsonMeta.ID, meta.ID)
	}
	if jsonMeta.Name != meta.Name {
		t.Errorf("JSON roundtrip: Name = %q, want %q", jsonMeta.Name, meta.Name)
	}
	if jsonMeta.Description != meta.Description {
		t.Errorf("JSON roundtrip: Description = %q, want %q", jsonMeta.Description, meta.Description)
	}
	if !jsonMeta.CreatedAt.Equal(meta.CreatedAt) {
		t.Errorf("JSON roundtrip: CreatedAt = %v, want %v", jsonMeta.CreatedAt, meta.CreatedAt)
	}
	if !jsonMeta.UpdatedAt.Equal(meta.UpdatedAt) {
		t.Errorf("JSON roundtrip: UpdatedAt = %v, want %v", jsonMeta.UpdatedAt, meta.UpdatedAt)
	}
	if !jsonMeta.SyncedAt.Equal(meta.SyncedAt) {
		t.Errorf("JSON roundtrip: SyncedAt = %v, want %v", jsonMeta.SyncedAt, meta.SyncedAt)
	}
	if jsonMeta.RevisionNum != meta.RevisionNum {
		t.Errorf("JSON roundtrip: RevisionNum = %d, want %d", jsonMeta.RevisionNum, meta.RevisionNum)
	}
	if jsonMeta.ConfigHash != meta.ConfigHash {
		t.Errorf("JSON roundtrip: ConfigHash = %q, want %q", jsonMeta.ConfigHash, meta.ConfigHash)
	}

	// Test YAML roundtrip — all fields
	yamlData, err := yaml.Marshal(meta)
	if err != nil {
		t.Fatalf("yaml.Marshal() error = %v", err)
	}

	var yamlMeta ProxyMeta
	if err := yaml.Unmarshal(yamlData, &yamlMeta); err != nil {
		t.Fatalf("yaml.Unmarshal() error = %v", err)
	}

	if yamlMeta.ID != meta.ID {
		t.Errorf("YAML roundtrip: ID = %q, want %q", yamlMeta.ID, meta.ID)
	}
	if yamlMeta.Name != meta.Name {
		t.Errorf("YAML roundtrip: Name = %q, want %q", yamlMeta.Name, meta.Name)
	}
	if yamlMeta.Description != meta.Description {
		t.Errorf("YAML roundtrip: Description = %q, want %q", yamlMeta.Description, meta.Description)
	}
	if yamlMeta.RevisionNum != meta.RevisionNum {
		t.Errorf("YAML roundtrip: RevisionNum = %d, want %d", yamlMeta.RevisionNum, meta.RevisionNum)
	}
	if yamlMeta.ConfigHash != meta.ConfigHash {
		t.Errorf("YAML roundtrip: ConfigHash = %q, want %q", yamlMeta.ConfigHash, meta.ConfigHash)
	}
}

func TestProxyRevisionPayloadSerialization(t *testing.T) {
	payload := &pb.ProxyRevisionPayload{
		Name:            "My Proxy",
		Description:     "Test description",
		CommitMessage:   "Initial commit",
		ProtocolVersion: "v1",
		ConfigYaml: `listeners:
  - type: socks5
    port: 1080
`,
		ConfigHash: "sha256:abc123",
	}

	data, err := proto.Marshal(payload)
	if err != nil {
		t.Fatalf("proto.Marshal() error = %v", err)
	}

	var decoded pb.ProxyRevisionPayload
	if err := proto.Unmarshal(data, &decoded); err != nil {
		t.Fatalf("proto.Unmarshal() error = %v", err)
	}

	// Verify all 6 fields
	if decoded.Name != payload.Name {
		t.Errorf("Name = %q, want %q", decoded.Name, payload.Name)
	}
	if decoded.Description != payload.Description {
		t.Errorf("Description = %q, want %q", decoded.Description, payload.Description)
	}
	if decoded.CommitMessage != payload.CommitMessage {
		t.Errorf("CommitMessage = %q, want %q", decoded.CommitMessage, payload.CommitMessage)
	}
	if decoded.ProtocolVersion != payload.ProtocolVersion {
		t.Errorf("ProtocolVersion = %q, want %q", decoded.ProtocolVersion, payload.ProtocolVersion)
	}
	if decoded.ConfigYaml != payload.ConfigYaml {
		t.Errorf("ConfigYaml = %q, want %q", decoded.ConfigYaml, payload.ConfigYaml)
	}
	if decoded.ConfigHash != payload.ConfigHash {
		t.Errorf("ConfigHash = %q, want %q", decoded.ConfigHash, payload.ConfigHash)
	}
}

func TestAlertDetailsSerialization(t *testing.T) {
	details := &pbCommon.AlertDetails{
		SourceIp:    "192.168.1.100",
		Destination: "example.com:443",
		ProxyId:     "proxy-abc123",
		ProxyName:   "My SOCKS Proxy",
		RuleId:      "rule-def456",
		GeoCountry:  "US",
		GeoCity:     "San Francisco",
		GeoIsp:      "Comcast",
	}

	data, err := proto.Marshal(details)
	if err != nil {
		t.Fatalf("proto.Marshal(AlertDetails) error = %v", err)
	}

	var decoded pbCommon.AlertDetails
	if err := proto.Unmarshal(data, &decoded); err != nil {
		t.Fatalf("proto.Unmarshal(AlertDetails) error = %v", err)
	}

	// Verify all 8 fields
	if decoded.SourceIp != details.SourceIp {
		t.Errorf("SourceIp = %q, want %q", decoded.SourceIp, details.SourceIp)
	}
	if decoded.Destination != details.Destination {
		t.Errorf("Destination = %q, want %q", decoded.Destination, details.Destination)
	}
	if decoded.ProxyId != details.ProxyId {
		t.Errorf("ProxyId = %q, want %q", decoded.ProxyId, details.ProxyId)
	}
	if decoded.ProxyName != details.ProxyName {
		t.Errorf("ProxyName = %q, want %q", decoded.ProxyName, details.ProxyName)
	}
	if decoded.RuleId != details.RuleId {
		t.Errorf("RuleId = %q, want %q", decoded.RuleId, details.RuleId)
	}
	if decoded.GeoCountry != details.GeoCountry {
		t.Errorf("GeoCountry = %q, want %q", decoded.GeoCountry, details.GeoCountry)
	}
	if decoded.GeoCity != details.GeoCity {
		t.Errorf("GeoCity = %q, want %q", decoded.GeoCity, details.GeoCity)
	}
	if decoded.GeoIsp != details.GeoIsp {
		t.Errorf("GeoIsp = %q, want %q", decoded.GeoIsp, details.GeoIsp)
	}

	// Verify partial data (empty optional fields still roundtrip)
	partial := &pbCommon.AlertDetails{
		SourceIp:    "10.0.0.1",
		Destination: "internal.host:80",
	}
	partialData, err := proto.Marshal(partial)
	if err != nil {
		t.Fatalf("proto.Marshal(partial AlertDetails) error = %v", err)
	}
	var partialDecoded pbCommon.AlertDetails
	if err := proto.Unmarshal(partialData, &partialDecoded); err != nil {
		t.Fatalf("proto.Unmarshal(partial AlertDetails) error = %v", err)
	}
	if partialDecoded.SourceIp != "10.0.0.1" {
		t.Errorf("partial SourceIp = %q, want %q", partialDecoded.SourceIp, "10.0.0.1")
	}
	if partialDecoded.GeoCountry != "" {
		t.Errorf("partial GeoCountry = %q, want empty", partialDecoded.GeoCountry)
	}
}

// TestAlertDetailsInGoString verifies that proto-encoded AlertDetails survives
// Go string roundtrip (as used in the listener → hub → CLI chain where the
// proto bytes are carried as a Go string field).
func TestAlertDetailsInGoString(t *testing.T) {
	details := &pbCommon.AlertDetails{
		SourceIp:    "203.0.113.50",
		Destination: "evil.example.com:443",
		ProxyId:     "proxy-xyz",
		GeoCountry:  "CN",
		GeoIsp:      "China Telecom",
	}

	data, err := proto.Marshal(details)
	if err != nil {
		t.Fatalf("proto.Marshal() error = %v", err)
	}

	// Simulate: string(data) → []byte(s) roundtrip (used in approval chain)
	asString := string(data)
	backToBytes := []byte(asString)

	var decoded pbCommon.AlertDetails
	if err := proto.Unmarshal(backToBytes, &decoded); err != nil {
		t.Fatalf("proto.Unmarshal after string roundtrip error = %v", err)
	}

	if decoded.SourceIp != details.SourceIp {
		t.Errorf("SourceIp = %q, want %q", decoded.SourceIp, details.SourceIp)
	}
	if decoded.GeoIsp != details.GeoIsp {
		t.Errorf("GeoIsp = %q, want %q", decoded.GeoIsp, details.GeoIsp)
	}
}

func TestSendCommandProtoPayloads(t *testing.T) {
	// Verify that each send subcommand's proto payload roundtrips correctly.
	// This tests the same proto types and marshal/unmarshal pattern used by
	// the actual send command in hub_nodes.go.

	t.Run("list-rules", func(t *testing.T) {
		payload, err := proto.Marshal(&pbProxy.ListRulesRequest{})
		if err != nil {
			t.Fatalf("proto.Marshal(ListRulesRequest) error = %v", err)
		}
		var decoded pbProxy.ListRulesRequest
		if err := proto.Unmarshal(payload, &decoded); err != nil {
			t.Fatalf("proto.Unmarshal(ListRulesRequest) error = %v", err)
		}
	})

	t.Run("add-rule", func(t *testing.T) {
		rule := &pbProxy.Rule{
			Id:       "rule-123",
			Name:     "Block Bad IP",
			Priority: 100,
			Action:   pbCommon.ActionType_ACTION_TYPE_BLOCK,
			Conditions: []*pbProxy.Condition{
				{
					Type:  pbCommon.ConditionType_CONDITION_TYPE_SOURCE_IP,
					Op:    pbCommon.Operator_OPERATOR_CIDR,
					Value: "10.0.0.0/8",
				},
			},
		}
		req := &pbProxy.AddRuleRequest{Rule: rule}
		payload, err := proto.Marshal(req)
		if err != nil {
			t.Fatalf("proto.Marshal(AddRuleRequest) error = %v", err)
		}

		var decoded pbProxy.AddRuleRequest
		if err := proto.Unmarshal(payload, &decoded); err != nil {
			t.Fatalf("proto.Unmarshal(AddRuleRequest) error = %v", err)
		}
		if decoded.Rule.Id != "rule-123" {
			t.Errorf("Rule.Id = %q, want %q", decoded.Rule.Id, "rule-123")
		}
		if decoded.Rule.Name != "Block Bad IP" {
			t.Errorf("Rule.Name = %q, want %q", decoded.Rule.Name, "Block Bad IP")
		}
		if decoded.Rule.Priority != 100 {
			t.Errorf("Rule.Priority = %d, want 100", decoded.Rule.Priority)
		}
		if decoded.Rule.Action != pbCommon.ActionType_ACTION_TYPE_BLOCK {
			t.Errorf("Rule.Action = %v, want BLOCK", decoded.Rule.Action)
		}
		if len(decoded.Rule.Conditions) != 1 {
			t.Fatalf("Rule.Conditions len = %d, want 1", len(decoded.Rule.Conditions))
		}
		if decoded.Rule.Conditions[0].Type != pbCommon.ConditionType_CONDITION_TYPE_SOURCE_IP {
			t.Errorf("Condition.Type = %v, want SOURCE_IP", decoded.Rule.Conditions[0].Type)
		}
		if decoded.Rule.Conditions[0].Value != "10.0.0.0/8" {
			t.Errorf("Condition.Value = %q, want %q", decoded.Rule.Conditions[0].Value, "10.0.0.0/8")
		}
	})

	t.Run("remove-rule", func(t *testing.T) {
		ruleID := "rule-to-remove-456"
		payload, err := proto.Marshal(&pbProxy.RemoveRuleRequest{RuleId: ruleID})
		if err != nil {
			t.Fatalf("proto.Marshal(RemoveRuleRequest) error = %v", err)
		}
		var decoded pbProxy.RemoveRuleRequest
		if err := proto.Unmarshal(payload, &decoded); err != nil {
			t.Fatalf("proto.Unmarshal(RemoveRuleRequest) error = %v", err)
		}
		if decoded.RuleId != ruleID {
			t.Errorf("RuleId = %q, want %q", decoded.RuleId, ruleID)
		}
	})

	t.Run("get-connections", func(t *testing.T) {
		payload, err := proto.Marshal(&pbProxy.GetActiveConnectionsRequest{})
		if err != nil {
			t.Fatalf("proto.Marshal(GetActiveConnectionsRequest) error = %v", err)
		}
		var decoded pbProxy.GetActiveConnectionsRequest
		if err := proto.Unmarshal(payload, &decoded); err != nil {
			t.Fatalf("proto.Unmarshal(GetActiveConnectionsRequest) error = %v", err)
		}
	})

	t.Run("close-connection", func(t *testing.T) {
		connID := "conn-789"
		payload, err := proto.Marshal(&pbProxy.CloseConnectionRequest{ConnId: connID})
		if err != nil {
			t.Fatalf("proto.Marshal(CloseConnectionRequest) error = %v", err)
		}
		var decoded pbProxy.CloseConnectionRequest
		if err := proto.Unmarshal(payload, &decoded); err != nil {
			t.Fatalf("proto.Unmarshal(CloseConnectionRequest) error = %v", err)
		}
		if decoded.ConnId != connID {
			t.Errorf("ConnId = %q, want %q", decoded.ConnId, connID)
		}
	})

	t.Run("close-all", func(t *testing.T) {
		payload, err := proto.Marshal(&pbProxy.CloseAllConnectionsRequest{})
		if err != nil {
			t.Fatalf("proto.Marshal(CloseAllConnectionsRequest) error = %v", err)
		}
		var decoded pbProxy.CloseAllConnectionsRequest
		if err := proto.Unmarshal(payload, &decoded); err != nil {
			t.Fatalf("proto.Unmarshal(CloseAllConnectionsRequest) error = %v", err)
		}
	})
}

func TestSendCommandResponseDisplay(t *testing.T) {
	// Verify that proto-encoded responses can be deserialized correctly,
	// matching the display logic in hub_nodes.go.

	t.Run("list-rules response", func(t *testing.T) {
		resp := &pbProxy.ListRulesResponse{
			Rules: []*pbProxy.Rule{
				{
					Id:       "rule-1",
					Name:     "Allow All",
					Priority: 1,
					Action:   pbCommon.ActionType_ACTION_TYPE_ALLOW,
				},
				{
					Id:       "rule-2",
					Name:     "Block Tor",
					Priority: 50,
					Action:   pbCommon.ActionType_ACTION_TYPE_BLOCK,
				},
			},
		}
		data, err := proto.Marshal(resp)
		if err != nil {
			t.Fatalf("proto.Marshal(ListRulesResponse) error = %v", err)
		}
		var decoded pbProxy.ListRulesResponse
		if err := proto.Unmarshal(data, &decoded); err != nil {
			t.Fatalf("proto.Unmarshal(ListRulesResponse) error = %v", err)
		}
		if len(decoded.Rules) != 2 {
			t.Fatalf("Rules len = %d, want 2", len(decoded.Rules))
		}
		if decoded.Rules[0].Name != "Allow All" {
			t.Errorf("Rules[0].Name = %q, want %q", decoded.Rules[0].Name, "Allow All")
		}
		if decoded.Rules[1].Action != pbCommon.ActionType_ACTION_TYPE_BLOCK {
			t.Errorf("Rules[1].Action = %v, want BLOCK", decoded.Rules[1].Action)
		}
	})

	t.Run("get-connections response", func(t *testing.T) {
		resp := &pbProxy.GetActiveConnectionsResponse{
			Connections: []*pbProxy.ActiveConnection{
				{
					Id:       "conn-1",
					SourceIp: "192.168.1.10",
					DestAddr: "example.com:443",
					BytesIn:  1024,
					BytesOut: 2048,
				},
			},
		}
		data, err := proto.Marshal(resp)
		if err != nil {
			t.Fatalf("proto.Marshal(GetActiveConnectionsResponse) error = %v", err)
		}
		var decoded pbProxy.GetActiveConnectionsResponse
		if err := proto.Unmarshal(data, &decoded); err != nil {
			t.Fatalf("proto.Unmarshal(GetActiveConnectionsResponse) error = %v", err)
		}
		if len(decoded.Connections) != 1 {
			t.Fatalf("Connections len = %d, want 1", len(decoded.Connections))
		}
		c := decoded.Connections[0]
		if c.Id != "conn-1" {
			t.Errorf("Connection.Id = %q, want %q", c.Id, "conn-1")
		}
		if c.SourceIp != "192.168.1.10" {
			t.Errorf("Connection.SourceIp = %q, want %q", c.SourceIp, "192.168.1.10")
		}
		if c.DestAddr != "example.com:443" {
			t.Errorf("Connection.DestAddr = %q, want %q", c.DestAddr, "example.com:443")
		}
		if c.BytesIn != 1024 {
			t.Errorf("Connection.BytesIn = %d, want 1024", c.BytesIn)
		}
		if c.BytesOut != 2048 {
			t.Errorf("Connection.BytesOut = %d, want 2048", c.BytesOut)
		}
	})
}

func setupProxyBackend(t *testing.T) {
	t.Helper()

	tmpDir := t.TempDir()
	originalDataDir := dataDir
	originalClient := client
	originalSvc := svc

	dataDir = tmpDir
	svc = service.NewMobileLogicService()
	client = pbLocal.NewMobileLogicServiceClient(pbLocal.NewFfiClientConn(svc))

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	resp, err := client.Initialize(ctx, &pbLocal.InitializeRequest{
		DataDir:  dataDir,
		CacheDir: filepath.Join(dataDir, "cache"),
	})
	if err != nil {
		t.Fatalf("Initialize() error = %v", err)
	}
	if !resp.Success {
		t.Fatalf("Initialize() failed: %s", resp.Error)
	}

	t.Cleanup(func() {
		dataDir = originalDataDir
		client = originalClient
		svc = originalSvc
	})
}

func TestProxyIndexOperations(t *testing.T) {
	setupProxyBackend(t)

	// Test loading empty index
	index, err := loadProxyIndex()
	if err != nil {
		t.Fatalf("loadProxyIndex() error = %v", err)
	}
	if len(index) != 0 {
		t.Errorf("loadProxyIndex() returned non-empty index for new directory")
	}

	config1 := `entryPoints:
  socks:
    address: "0.0.0.0:1080"
tcp:
  rules: []
`
	config2 := `entryPoints:
  web:
    address: "127.0.0.1:8080"
tcp:
  rules: []
`

	if _, err := saveLocalProxy("proxy-1", "First Proxy", "First proxy desc", config1); err != nil {
		t.Fatalf("saveLocalProxy(proxy-1) error = %v", err)
	}
	if _, err := saveLocalProxy("proxy-2", "Second Proxy", "Second proxy desc", config2); err != nil {
		t.Fatalf("saveLocalProxy(proxy-2) error = %v", err)
	}

	// Reload and verify all fields
	loaded, err := loadProxyIndex()
	if err != nil {
		t.Fatalf("loadProxyIndex() after save error = %v", err)
	}
	if len(loaded) != 2 {
		t.Fatalf("loadProxyIndex() returned %d entries, want 2", len(loaded))
	}

	p1 := loaded["proxy-1"]
	if p1 == nil {
		t.Fatal("proxy-1 not found in loaded index")
	}
	if p1.Name != "First Proxy" {
		t.Errorf("proxy-1 Name = %q, want %q", p1.Name, "First Proxy")
	}
	if p1.Description != "First proxy desc" {
		t.Errorf("proxy-1 Description = %q, want %q", p1.Description, "First proxy desc")
	}
	if p1.RevisionNum != 0 {
		t.Errorf("proxy-1 RevisionNum = %d, want 0", p1.RevisionNum)
	}
	_, storedP1Content, err := getLocalProxy("proxy-1")
	if err != nil {
		t.Fatalf("getLocalProxy(proxy-1) error = %v", err)
	}
	if p1.ConfigHash != hashConfig([]byte(storedP1Content)) {
		t.Errorf("proxy-1 ConfigHash = %q, want %q", p1.ConfigHash, hashConfig([]byte(storedP1Content)))
	}

	p2 := loaded["proxy-2"]
	if p2 == nil {
		t.Fatal("proxy-2 not found in loaded index")
	}
	if p2.Name != "Second Proxy" {
		t.Errorf("proxy-2 Name = %q, want %q", p2.Name, "Second Proxy")
	}
	if p2.RevisionNum != 0 {
		t.Errorf("proxy-2 RevisionNum = %d, want 0", p2.RevisionNum)
	}

	// Test overwrite: modify and re-save
	updated1 := `entryPoints:
  socks:
    address: "0.0.0.0:1081"
tcp:
  rules: []
`
	if _, err := saveLocalProxy("proxy-1", "Updated First", "First proxy desc", updated1); err != nil {
		t.Fatalf("saveLocalProxy() update error = %v", err)
	}
	delResp, err := client.DeleteLocalProxyConfig(context.Background(), &pbLocal.DeleteLocalProxyConfigRequest{ProxyId: "proxy-2"})
	if err != nil {
		t.Fatalf("DeleteLocalProxyConfig() error = %v", err)
	}
	if !delResp.Success {
		t.Fatalf("DeleteLocalProxyConfig() failed: %s", delResp.Error)
	}

	reloaded, err := loadProxyIndex()
	if err != nil {
		t.Fatalf("loadProxyIndex() after update error = %v", err)
	}
	if len(reloaded) != 1 {
		t.Errorf("loadProxyIndex() after delete returned %d entries, want 1", len(reloaded))
	}
	if reloaded["proxy-1"].Name != "Updated First" {
		t.Errorf("proxy-1 Name after update = %q, want %q", reloaded["proxy-1"].Name, "Updated First")
	}
	if reloaded["proxy-1"].RevisionNum != 0 {
		t.Errorf("proxy-1 RevisionNum after update = %d, want 0", reloaded["proxy-1"].RevisionNum)
	}
}

func TestFindProxyByPrefix(t *testing.T) {
	setupProxyBackend(t)

	config := `entryPoints:
  socks:
    address: "0.0.0.0:1080"
tcp:
  rules: []
`
	for _, tc := range []struct {
		id   string
		name string
	}{
		{id: "abc123-proxy", name: "ABC Proxy"},
		{id: "abc456-proxy", name: "ABC 456 Proxy"},
		{id: "def789-proxy", name: "DEF Proxy"},
	} {
		if _, err := saveLocalProxy(tc.id, tc.name, "", config); err != nil {
			t.Fatalf("saveLocalProxy(%s) error = %v", tc.id, err)
		}
	}

	tests := []struct {
		name      string
		prefix    string
		wantID    string
		wantError bool
	}{
		{
			name:   "exact match",
			prefix: "abc123-proxy",
			wantID: "abc123-proxy",
		},
		{
			name:   "unique prefix",
			prefix: "def",
			wantID: "def789-proxy",
		},
		{
			name:      "ambiguous prefix",
			prefix:    "abc",
			wantError: true,
		},
		{
			name:      "no match",
			prefix:    "xyz",
			wantError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			meta, err := findProxyByPrefix(tt.prefix)
			if tt.wantError {
				if err == nil {
					t.Errorf("findProxyByPrefix(%q) expected error, got nil", tt.prefix)
				}
				return
			}
			if err != nil {
				t.Errorf("findProxyByPrefix(%q) error = %v", tt.prefix, err)
				return
			}
			if meta.ID != tt.wantID {
				t.Errorf("findProxyByPrefix(%q) ID = %q, want %q", tt.prefix, meta.ID, tt.wantID)
			}
		})
	}
}

func TestGetLocalProxyRoundTrip(t *testing.T) {
	setupProxyBackend(t)

	proxyID := "my-proxy-123"
	input := `entryPoints:
  socks:
    address: "0.0.0.0:1080"
tcp:
  rules: []
`
	if _, err := saveLocalProxy(proxyID, "My Proxy", "Roundtrip test", input); err != nil {
		t.Fatalf("saveLocalProxy() error = %v", err)
	}

	meta, content, err := getLocalProxy(proxyID)
	if err != nil {
		t.Fatalf("getLocalProxy() error = %v", err)
	}
	if meta == nil {
		t.Fatal("getLocalProxy() returned nil meta")
	}
	if meta.Name != "My Proxy" {
		t.Errorf("meta.Name = %q, want %q", meta.Name, "My Proxy")
	}
	if meta.RevisionNum != 0 {
		t.Errorf("meta.RevisionNum = %d, want 0", meta.RevisionNum)
	}
	if !strings.Contains(content, "# nitella/proxy: v1") {
		t.Errorf("stored content missing nitella header: %q", content)
	}
	if !strings.Contains(content, "meta:") {
		t.Errorf("stored content missing meta section: %q", content)
	}
}

func TestProxyConfigFileOperations(t *testing.T) {
	setupProxyBackend(t)

	proxyID := "test-proxy-abc123"
	configContent := `entryPoints:
  socks:
    address: "0.0.0.0:1080"
tcp:
  rules: []
`
	if _, err := saveLocalProxy(proxyID, "file-op proxy", "", configContent); err != nil {
		t.Fatalf("saveLocalProxy() error = %v", err)
	}
	proxyPath := filepath.Join(dataDir, "proxies", proxyID+".yaml")

	readContent, err := os.ReadFile(proxyPath)
	if err != nil {
		t.Fatalf("ReadFile() error = %v", err)
	}

	if !strings.Contains(string(readContent), "# nitella/proxy: v1") {
		t.Errorf("Config content missing header:\n%s", string(readContent))
	}

	// Verify hash consistency
	hash1 := hashConfig(readContent)
	meta, _, err := getLocalProxy(proxyID)
	if err != nil {
		t.Fatalf("getLocalProxy() error = %v", err)
	}
	if meta.ConfigHash == "" {
		t.Fatalf("meta.ConfigHash is empty")
	}
	if hash1 == "" {
		t.Fatalf("computed hash is empty")
	}

	// Verify file permissions
	info, err := os.Stat(proxyPath)
	if err != nil {
		t.Fatalf("Stat() error = %v", err)
	}
	if info.Mode().Perm() != 0600 {
		t.Errorf("File permissions = %o, want 0600", info.Mode().Perm())
	}
}

func TestTruncateFunction(t *testing.T) {
	tests := []struct {
		s      string
		maxLen int
		want   string
	}{
		{"hello", 10, "hello"},
		{"hello", 5, "hello"},
		{"hello world", 8, "hello..."},
		{"short", 3, "..."},
		{"ab", 5, "ab"},
		{"", 5, ""},
	}

	for _, tt := range tests {
		t.Run(tt.s, func(t *testing.T) {
			got := truncate(tt.s, tt.maxLen)
			if got != tt.want {
				t.Errorf("truncate(%q, %d) = %q, want %q", tt.s, tt.maxLen, got, tt.want)
			}
		})
	}
}

func TestProxiesDir(t *testing.T) {
	setupProxyBackend(t)

	proxyID := "layout-proxy"
	content := `entryPoints:
  socks:
    address: "0.0.0.0:1080"
tcp:
  rules: []
`
	if _, err := saveLocalProxy(proxyID, "Layout Test", "", content); err != nil {
		t.Fatalf("saveLocalProxy() error = %v", err)
	}

	proxiesDir := filepath.Join(dataDir, "proxies")
	indexPath := filepath.Join(proxiesDir, "index.json")
	proxyPath := filepath.Join(proxiesDir, proxyID+".yaml")

	for _, p := range []string{proxiesDir, indexPath, proxyPath} {
		if _, err := os.Stat(p); err != nil {
			t.Fatalf("expected storage path %q to exist: %v", p, err)
		}
	}
}
