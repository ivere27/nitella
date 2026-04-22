package config

import (
	"fmt"

	pb "github.com/ivere27/nitella/pkg/api/proxy"
)

// RateLimitConfig is the YAML-facing form of proxy.RateLimitConfig.
// Pointer fields let validation distinguish omitted values from explicit zeroes.
type RateLimitConfig struct {
	MaxConnections           *int32  `yaml:"maxConnections,omitempty"`
	IntervalSeconds          *int32  `yaml:"intervalSeconds,omitempty"`
	AutoBlock                *bool   `yaml:"autoBlock,omitempty"`
	BlockDurationSeconds     *int32  `yaml:"blockDurationSeconds,omitempty"`
	BlockStepsSeconds        []int32 `yaml:"blockStepsSeconds,omitempty"`
	CountOnlyFailures        *bool   `yaml:"countOnlyFailures,omitempty"`
	FailureDurationThreshold *int32  `yaml:"failureDurationThreshold,omitempty"`
}

// ToProto validates and converts YAML rate-limit settings into the runtime
// protobuf config. A nil or empty YAML rateLimit block means "disabled".
func (c *RateLimitConfig) ToProto() (*pb.RateLimitConfig, error) {
	if c == nil || !c.hasAnySetting() {
		return nil, nil
	}

	if c.MaxConnections == nil || *c.MaxConnections <= 0 {
		return nil, fmt.Errorf("rateLimit.maxConnections must be greater than 0")
	}

	intervalSeconds := int32(60)
	if c.IntervalSeconds != nil {
		if *c.IntervalSeconds <= 0 {
			return nil, fmt.Errorf("rateLimit.intervalSeconds must be greater than 0")
		}
		intervalSeconds = *c.IntervalSeconds
	}

	autoBlock := true
	if c.AutoBlock != nil {
		autoBlock = *c.AutoBlock
	}

	blockSteps := append([]int32(nil), c.BlockStepsSeconds...)
	for _, step := range blockSteps {
		if step < 0 {
			return nil, fmt.Errorf("rateLimit.blockStepsSeconds cannot contain negative values")
		}
	}

	blockDurationSeconds := int32(0)
	if autoBlock && len(blockSteps) == 0 {
		blockDurationSeconds = 600
	}
	if c.BlockDurationSeconds != nil {
		if *c.BlockDurationSeconds < 0 {
			return nil, fmt.Errorf("rateLimit.blockDurationSeconds cannot be negative")
		}
		blockDurationSeconds = *c.BlockDurationSeconds
	}

	countOnlyFailures := false
	if c.CountOnlyFailures != nil {
		countOnlyFailures = *c.CountOnlyFailures
	}

	failureDurationThreshold := int32(0)
	if c.FailureDurationThreshold != nil && !countOnlyFailures {
		return nil, fmt.Errorf("rateLimit.failureDurationThreshold requires rateLimit.countOnlyFailures=true")
	}
	if countOnlyFailures {
		failureDurationThreshold = 1
		if c.FailureDurationThreshold != nil {
			if *c.FailureDurationThreshold < 0 {
				return nil, fmt.Errorf("rateLimit.failureDurationThreshold cannot be negative")
			}
			failureDurationThreshold = *c.FailureDurationThreshold
		}
	}

	return &pb.RateLimitConfig{
		MaxConnections:           *c.MaxConnections,
		IntervalSeconds:          intervalSeconds,
		AutoBlock:                autoBlock,
		BlockDurationSeconds:     blockDurationSeconds,
		BlockStepsSeconds:        blockSteps,
		CountOnlyFailures:        countOnlyFailures,
		FailureDurationThreshold: failureDurationThreshold,
	}, nil
}

func (c *RateLimitConfig) hasAnySetting() bool {
	return c.MaxConnections != nil ||
		c.IntervalSeconds != nil ||
		c.AutoBlock != nil ||
		c.BlockDurationSeconds != nil ||
		len(c.BlockStepsSeconds) > 0 ||
		c.CountOnlyFailures != nil ||
		c.FailureDurationThreshold != nil
}
