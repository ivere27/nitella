// Package core provides shared business logic for the Nitella CLI and mobile backend.
// Both consumers are thin wrappers around Controller methods.
package core

import (
	"crypto/ed25519"
	"fmt"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
)

// CommandResult wraps the Hub CommandResult for consumer use.
type CommandResult = pbHub.CommandResult

// NodeInfo holds paired node metadata.
type NodeInfo struct {
	NodeID      string
	Name        string
	Tags        []string
	Fingerprint string
	EmojiHash   string
	Online      bool
	PublicKey   ed25519.PublicKey
}

// EventHandler receives async events from the Controller.
// Consumers implement this to handle approval requests, status changes, etc.
type EventHandler interface {
	OnApprovalRequest(nodeID string, alert *common.Alert)
	OnNodeStatusChange(nodeID string, online bool)
}

// ProxyInfo is a lightweight proxy descriptor returned by ListProxies.
type ProxyInfo = pbProxy.ProxyStatus

// Rule is the proxy rule type from the proto API.
type Rule = pbProxy.Rule

// CommandType re-exports the hub command type enum.
type CommandType = pbHub.CommandType

// ProxyConfigInfo re-exports the Hub proto type for consumer convenience.
type ProxyConfigInfo = pbHub.ProxyConfigInfo

// RevisionMeta re-exports the Hub proto type for consumer convenience.
type RevisionMeta = pbHub.RevisionMeta

// ProxyRevisionPayload re-exports the Hub proto type for consumer convenience.
type ProxyRevisionPayload = pbHub.ProxyRevisionPayload

// commandError extracts an error from a non-OK CommandResult.
func commandError(r *CommandResult) error {
	if r.ErrorMessage != "" {
		return fmt.Errorf("%s", r.ErrorMessage)
	}
	return fmt.Errorf("command failed with status: %s", r.Status)
}
