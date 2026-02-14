package service

import (
	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/local"
	"github.com/ivere27/nitella/pkg/config"
)

const defaultApproveDurationSeconds int64 = config.DefaultApprovalDurationSeconds
const defaultApprovalsPollIntervalSeconds int32 = 5
const defaultStatsPollIntervalSeconds int32 = 5

var defaultApproveDurationOptions = []int64{
	0,     // once/session
	10,    // 10 seconds
	60,    // 1 minute
	300,   // 5 minutes (default)
	600,   // 10 minutes
	3600,  // 1 hour
	86400, // 24 hours
	-1,    // permanent
}

var defaultDenyBlockOptions = []pb.DenyBlockType{
	pb.DenyBlockType_DENY_BLOCK_TYPE_NONE,
	pb.DenyBlockType_DENY_BLOCK_TYPE_IP,
	pb.DenyBlockType_DENY_BLOCK_TYPE_ISP,
}

func approvalDurationOptions() []int64 {
	return append([]int64(nil), defaultApproveDurationOptions...)
}

func denyBlockOptions() []pb.DenyBlockType {
	return append([]pb.DenyBlockType(nil), defaultDenyBlockOptions...)
}

func approvalsPollIntervalSeconds() int32 {
	return defaultApprovalsPollIntervalSeconds
}

func statsPollIntervalSeconds() int32 {
	return defaultStatsPollIntervalSeconds
}

func defaultRuleComposerPolicy() *pb.RuleComposerPolicy {
	return &pb.RuleComposerPolicy{
		ConditionPolicies: []*pb.RuleComposerConditionPolicy{
			{
				ConditionType:   common.ConditionType_CONDITION_TYPE_SOURCE_IP,
				Operators:       []common.Operator{common.Operator_OPERATOR_EQ, common.Operator_OPERATOR_CIDR},
				DefaultOperator: common.Operator_OPERATOR_EQ,
				ValueHint:       "192.168.1.0/24 or 10.0.0.1",
			},
			{
				ConditionType:   common.ConditionType_CONDITION_TYPE_GEO_COUNTRY,
				Operators:       []common.Operator{common.Operator_OPERATOR_EQ},
				DefaultOperator: common.Operator_OPERATOR_EQ,
				ValueHint:       "US, KR, JP, CN, etc.",
			},
			{
				ConditionType:   common.ConditionType_CONDITION_TYPE_GEO_CITY,
				Operators:       []common.Operator{common.Operator_OPERATOR_EQ, common.Operator_OPERATOR_CONTAINS, common.Operator_OPERATOR_REGEX},
				DefaultOperator: common.Operator_OPERATOR_CONTAINS,
				ValueHint:       "Seoul, Tokyo, New York, etc.",
			},
			{
				ConditionType:   common.ConditionType_CONDITION_TYPE_GEO_ISP,
				Operators:       []common.Operator{common.Operator_OPERATOR_EQ, common.Operator_OPERATOR_CONTAINS, common.Operator_OPERATOR_REGEX},
				DefaultOperator: common.Operator_OPERATOR_CONTAINS,
				ValueHint:       "Cloudflare, AWS, Korea Telecom, etc.",
			},
			{
				ConditionType:   common.ConditionType_CONDITION_TYPE_TLS_PRESENT,
				Operators:       []common.Operator{common.Operator_OPERATOR_EQ},
				DefaultOperator: common.Operator_OPERATOR_EQ,
				ValueHint:       "true or false",
			},
			{
				ConditionType:   common.ConditionType_CONDITION_TYPE_TLS_CN,
				Operators:       []common.Operator{common.Operator_OPERATOR_EQ, common.Operator_OPERATOR_CONTAINS, common.Operator_OPERATOR_REGEX},
				DefaultOperator: common.Operator_OPERATOR_CONTAINS,
				ValueHint:       "client.example.com",
			},
			{
				ConditionType:   common.ConditionType_CONDITION_TYPE_TLS_CA,
				Operators:       []common.Operator{common.Operator_OPERATOR_EQ, common.Operator_OPERATOR_CONTAINS, common.Operator_OPERATOR_REGEX},
				DefaultOperator: common.Operator_OPERATOR_CONTAINS,
				ValueHint:       "My Root CA",
			},
			{
				ConditionType:   common.ConditionType_CONDITION_TYPE_TLS_OU,
				Operators:       []common.Operator{common.Operator_OPERATOR_EQ, common.Operator_OPERATOR_CONTAINS, common.Operator_OPERATOR_REGEX},
				DefaultOperator: common.Operator_OPERATOR_CONTAINS,
				ValueHint:       "Engineering, DevOps, etc.",
			},
			{
				ConditionType:   common.ConditionType_CONDITION_TYPE_TLS_SAN,
				Operators:       []common.Operator{common.Operator_OPERATOR_EQ, common.Operator_OPERATOR_CONTAINS, common.Operator_OPERATOR_REGEX},
				DefaultOperator: common.Operator_OPERATOR_CONTAINS,
				ValueHint:       "admin@example.com or *.internal",
			},
			{
				ConditionType:   common.ConditionType_CONDITION_TYPE_TLS_FINGERPRINT,
				Operators:       []common.Operator{common.Operator_OPERATOR_EQ, common.Operator_OPERATOR_CONTAINS, common.Operator_OPERATOR_REGEX},
				DefaultOperator: common.Operator_OPERATOR_EQ,
				ValueHint:       "SHA256:abc123...",
			},
			{
				ConditionType:   common.ConditionType_CONDITION_TYPE_TLS_SERIAL,
				Operators:       []common.Operator{common.Operator_OPERATOR_EQ, common.Operator_OPERATOR_CONTAINS, common.Operator_OPERATOR_REGEX},
				DefaultOperator: common.Operator_OPERATOR_CONTAINS,
				ValueHint:       "00A1B2...",
			},
			{
				ConditionType:   common.ConditionType_CONDITION_TYPE_TIME_RANGE,
				Operators:       []common.Operator{common.Operator_OPERATOR_EQ},
				DefaultOperator: common.Operator_OPERATOR_EQ,
				ValueHint:       "Mon-Fri 09:00-17:00",
			},
		},
		AllowedActions: []common.ActionType{
			common.ActionType_ACTION_TYPE_ALLOW,
			common.ActionType_ACTION_TYPE_BLOCK,
			common.ActionType_ACTION_TYPE_MOCK,
			common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL,
		},
		DefaultPriority: 100,
	}
}
