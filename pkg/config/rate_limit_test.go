package config

import (
	"testing"

	"gopkg.in/yaml.v3"
)

func TestYAMLRateLimitToProto(t *testing.T) {
	var cfg YAMLConfig
	if err := yaml.Unmarshal([]byte(`
entryPoints:
  web:
    address: ":8080"
    rateLimit:
      maxConnections: 3
      intervalSeconds: 60
      autoBlock: true
      blockDurationSeconds: 1800
      blockStepsSeconds: [1800, 3600]
      countOnlyFailures: true
      failureDurationThreshold: 20
tcp:
  routers: {}
  services: {}
`), &cfg); err != nil {
		t.Fatalf("yaml.Unmarshal failed: %v", err)
	}

	got, err := cfg.EntryPoints["web"].RateLimit.ToProto()
	if err != nil {
		t.Fatalf("ToProto failed: %v", err)
	}
	if got == nil {
		t.Fatal("ToProto returned nil")
	}
	if got.MaxConnections != 3 ||
		got.IntervalSeconds != 60 ||
		!got.AutoBlock ||
		got.BlockDurationSeconds != 1800 ||
		!got.CountOnlyFailures ||
		got.FailureDurationThreshold != 20 {
		t.Fatalf("unexpected rate limit config: %+v", got)
	}
	if len(got.BlockStepsSeconds) != 2 || got.BlockStepsSeconds[0] != 1800 || got.BlockStepsSeconds[1] != 3600 {
		t.Fatalf("unexpected block steps: %+v", got.BlockStepsSeconds)
	}
}

func TestYAMLRateLimitDefaults(t *testing.T) {
	max := int32(3)
	countOnly := true
	got, err := (&RateLimitConfig{
		MaxConnections:    &max,
		CountOnlyFailures: &countOnly,
	}).ToProto()
	if err != nil {
		t.Fatalf("ToProto failed: %v", err)
	}
	if got.IntervalSeconds != 60 || !got.AutoBlock || got.BlockDurationSeconds != 600 || got.FailureDurationThreshold != 1 {
		t.Fatalf("defaults not applied: %+v", got)
	}
}

func TestYAMLRateLimitRejectsFailureThresholdWithoutFailureOnlyMode(t *testing.T) {
	max := int32(3)
	threshold := int32(20)
	_, err := (&RateLimitConfig{
		MaxConnections:           &max,
		FailureDurationThreshold: &threshold,
	}).ToProto()
	if err == nil {
		t.Fatal("expected validation error")
	}
}
