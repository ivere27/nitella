package node

import (
	"encoding/json"
	"path/filepath"
	"testing"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
)

type rateLimitTestListener struct {
	rules []*pb.Rule
}

func (l *rateLimitTestListener) Start() error { return nil }
func (l *rateLimitTestListener) Stop() error  { return nil }
func (l *rateLimitTestListener) AddRule(rule *pb.Rule) {
	l.rules = append(l.rules, rule)
}
func (l *rateLimitTestListener) RemoveRule(ruleID string) error {
	for i, rule := range l.rules {
		if rule.Id == ruleID {
			l.rules = append(l.rules[:i], l.rules[i+1:]...)
			return nil
		}
	}
	return nil
}
func (l *rateLimitTestListener) GetRules() []*pb.Rule {
	return append([]*pb.Rule(nil), l.rules...)
}
func (l *rateLimitTestListener) GetStatus() *pb.ProxyStatus {
	return &pb.ProxyStatus{ProxyId: "proxy-a"}
}
func (l *rateLimitTestListener) Subscribe() chan *pb.ConnectionEvent {
	return make(chan *pb.ConnectionEvent, 1)
}
func (l *rateLimitTestListener) Unsubscribe(ch chan *pb.ConnectionEvent) {
	close(ch)
}
func (l *rateLimitTestListener) GetConnectionBytes(connID string) (in, out int64, ok bool) {
	return 0, 0, false
}
func (l *rateLimitTestListener) CloseConnection(proxyID, connID string) error {
	return nil
}
func (l *rateLimitTestListener) GetActiveConnections() []*ConnectionMetadata {
	return nil
}
func (l *rateLimitTestListener) CloseAllConnections() error {
	return nil
}

func TestAddRulePersistsRateLimitJSON(t *testing.T) {
	dbPath := filepath.Join(t.TempDir(), "nitella.db")
	pm := NewProxyManager(ListenerModeFfi)
	defer pm.Close()
	if err := pm.InitDB(dbPath); err != nil {
		t.Fatalf("InitDB failed: %v", err)
	}

	pm.mu.Lock()
	pm.proxies["proxy-a"] = &ManagedProxy{
		Listener: &rateLimitTestListener{},
		Model:    &ProxyModel{ID: "proxy-a", Name: "proxy-a", Enabled: true},
	}
	pm.mu.Unlock()

	_, err := pm.AddRule(&pb.AddRuleRequest{
		ProxyId: "proxy-a",
		Rule: &pb.Rule{
			Id:            "rule-rate-limit",
			Name:          "rate limit",
			Priority:      10,
			Enabled:       true,
			Action:        common.ActionType_ACTION_TYPE_ALLOW,
			TargetBackend: "127.0.0.1:9000",
			RateLimit: &pb.RateLimitConfig{
				MaxConnections:           7,
				IntervalSeconds:          11,
				AutoBlock:                true,
				BlockDurationSeconds:     60,
				BlockStepsSeconds:        []int32{60, 120},
				CountOnlyFailures:        true,
				FailureDurationThreshold: 2,
			},
		},
	})
	if err != nil {
		t.Fatalf("AddRule failed: %v", err)
	}

	var row RuleModel
	ok, err := pm.db.Where("id = ?", "rule-rate-limit").Get(&row)
	if err != nil {
		t.Fatalf("query rule_model failed: %v", err)
	}
	if !ok {
		t.Fatal("persisted rule row not found")
	}
	if row.RateLimitJSON == "" {
		t.Fatal("RateLimitJSON is empty")
	}

	var got pb.RateLimitConfig
	if err := json.Unmarshal([]byte(row.RateLimitJSON), &got); err != nil {
		t.Fatalf("RateLimitJSON did not decode: %v", err)
	}
	if got.MaxConnections != 7 || got.IntervalSeconds != 11 || !got.AutoBlock {
		t.Fatalf("unexpected rate limit config: %+v", got)
	}
}

func TestUnmarshalRateLimitJSONAllowsOmittedDefaults(t *testing.T) {
	got := unmarshalRateLimitJSON("rule-a", `{"max_connections":5,"interval_seconds":30}`)
	if got == nil {
		t.Fatal("expected rate limit config")
	}
	if got.MaxConnections != 5 || got.IntervalSeconds != 30 {
		t.Fatalf("unexpected parsed config: %+v", got)
	}
	if got.AutoBlock || len(got.BlockStepsSeconds) != 0 {
		t.Fatalf("expected omitted fields to stay at protobuf defaults: %+v", got)
	}
}

func TestUnmarshalRateLimitJSONTreatsNullAsAbsent(t *testing.T) {
	if got := unmarshalRateLimitJSON("rule-a", "null"); got != nil {
		t.Fatalf("expected null rate limit JSON to be absent, got %+v", got)
	}
	if got := unmarshalRateLimitJSON("rule-a", " \n\t "); got != nil {
		t.Fatalf("expected blank rate limit JSON to be absent, got %+v", got)
	}
}
