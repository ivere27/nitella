package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	commonpb "github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/local"
	"github.com/ivere27/nitella/pkg/cli"
	"github.com/ivere27/nitella/pkg/config"
	"github.com/ivere27/nitella/pkg/shell"
)

// startBackgroundAlertStream starts a background goroutine that streams approval
// requests from the backend using StreamApprovals.
func (h *HubCLI) startBackgroundAlertStream() {
	if h.alertStreamRunning {
		return
	}

	// Initial connection check
	cfg := h.loadHubConfig()
	if err := h.connectToHub(cfg); err != nil {
		return
	}

	ctx, cancel := context.WithCancel(context.Background())
	h.alertStreamCancel = cancel
	h.alertStreamRunning = true

	go func() {
		defer func() {
			h.alertStreamRunning = false
			h.alertStreamCancel = nil
		}()

		stream, err := client.StreamApprovals(ctx, &pb.StreamApprovalsRequest{})
		if err != nil {
			return
		}

		for {
			req, err := stream.Recv()
			if err != nil {
				return
			}
			h.handleApprovalCallback(req)
		}
	}()
}

// handleApprovalCallback processes an approval request received from the backend stream.
func (h *HubCLI) handleApprovalCallback(req *pb.ApprovalRequest) {
	// Build display info
	info := AlertInfo{
		ID:       req.RequestId,
		NodeID:   req.NodeId,
		Severity: "APPROVAL_REQUEST",
		Source:   "HUB",
	}
	if req.Timestamp != nil {
		info.Timestamp = req.Timestamp.AsTime()
	} else {
		info.Timestamp = time.Now()
	}

	info.SourceIP = req.SourceIp
	info.DestAddr = req.DestAddr
	info.ProxyID = req.ProxyId

	if req.Geo != nil {
		info.GeoCountry = req.Geo.Country
		info.GeoCity = req.Geo.City
		info.GeoISP = req.Geo.Isp
	}

	displayAlert(info)
}

// stopBackgroundAlertStream stops the background alert streaming
func (h *HubCLI) stopBackgroundAlertStream() {
	if h.alertStreamCancel != nil {
		h.alertStreamCancel()
	}
}

// AlertInfo contains unified alert display information.
type AlertInfo struct {
	ID         string
	NodeID     string
	Severity   string
	Timestamp  time.Time
	Source     string // "HUB" or "P2P"
	SourceIP   string
	DestAddr   string
	ProxyID    string
	GeoCountry string
	GeoCity    string
	GeoISP     string
}

// displayAlert shows an alert notification with unified formatting.
func displayAlert(info AlertInfo) {
	ts := info.Timestamp.Format("15:04:05")
	color := "\033[1;33m" // yellow for HUB
	if info.Source == "P2P" {
		color = "\033[1;35m" // magenta for P2P
	}

	var sb strings.Builder
	sb.WriteString(fmt.Sprintf("%s[%s] %s ALERT: %s\033[0m\n", color, ts, info.Source, sanitizeForTerminal(info.Severity)))
	shortID := sanitizeForTerminal(shortApprovalRequestID(info.ID))
	sb.WriteString(fmt.Sprintf("  ID:     %s\n", shortID))
	sb.WriteString(fmt.Sprintf("  Node:   %s\n", sanitizeForTerminal(info.NodeID)))
	sb.WriteString(fmt.Sprintf("  Type:   \033[1;36mCONNECTION APPROVAL REQUEST (%s)\033[0m\n", info.Source))

	if info.SourceIP != "" {
		sb.WriteString(fmt.Sprintf("  Source: %s\n", sanitizeForTerminal(info.SourceIP)))
	}
	if info.DestAddr != "" {
		sb.WriteString(fmt.Sprintf("  Dest:   %s\n", sanitizeForTerminal(info.DestAddr)))
	}
	if info.ProxyID != "" {
		sb.WriteString(fmt.Sprintf("  Proxy:  %s\n", sanitizeForTerminal(info.ProxyID)))
	}
	if info.GeoCountry != "" {
		geo := "  Geo:    " + sanitizeForTerminal(info.GeoCountry)
		if info.GeoCity != "" {
			geo += ", " + sanitizeForTerminal(info.GeoCity)
		}
		sb.WriteString(geo + "\n")
	}
	if info.GeoISP != "" {
		sb.WriteString(fmt.Sprintf("  ISP:    %s\n", sanitizeForTerminal(info.GeoISP)))
	}

	sb.WriteString(fmt.Sprintf("  \033[1;32m→ approve [once|cache] %s [duration]\033[0m  or  \033[1;31m→ deny [once|cache] %s [duration]\033[0m", shortID, shortID))

	shell.NotifyActive(sb.String())
}

func (h *HubCLI) cmdHubPending(args []string) {
	if h.ensureHubConnected() == nil {
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	resp, err := client.GetApprovalsSnapshot(ctx, &pb.GetApprovalsSnapshotRequest{
		IncludeHistory: false,
	})
	if err != nil {
		fmt.Printf("Error listing pending approvals snapshot: %v\n", err)
		return
	}

	if len(resp.PendingRequests) == 0 {
		fmt.Println("No pending approval requests.")
		return
	}

	fmt.Printf("\nPending Approval Requests (%d):\n", len(resp.PendingRequests))
	fmt.Println(strings.Repeat("-", 80))
	for _, req := range resp.PendingRequests {
		ts := "unknown"
		if req.Timestamp != nil {
			ts = req.Timestamp.AsTime().Format("2006-01-02 15:04:05")
		}
		fmt.Printf("ID: %s\n", shortApprovalRequestID(req.GetRequestId()))
		fmt.Printf("  Node:   %s\n", req.NodeId)
		fmt.Printf("  Time:   %s\n", ts)
		if req.SourceIp != "" {
			fmt.Printf("  Source: %s\n", req.SourceIp)
		}
		if req.DestAddr != "" {
			fmt.Printf("  Dest:   %s\n", req.DestAddr)
		}
		if req.Geo != nil && req.Geo.Country != "" {
			fmt.Printf("  Geo:    %s\n", req.Geo.Country)
		}
		fmt.Println()
	}
	fmt.Println("Use 'approve [once|cache] <id> [duration]' or 'deny [once|cache] <id> [duration]' to respond.")
}

func (h *HubCLI) cmdHubAlerts(args []string) {
	if h.ensureHubConnected() == nil {
		return
	}

	fmt.Println("Streaming alerts from Hub (Ctrl+C to stop)...")
	fmt.Println("When an approval request appears, use 'approve [once|cache] <id> [duration]' or 'deny [once|cache] <id> [duration]'.")
	fmt.Println()

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Handle Ctrl+C
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGINT)
	go func() {
		<-sigCh
		fmt.Println("\nStopping alert stream...")
		cancel()
	}()
	defer signal.Stop(sigCh)

	stream, err := client.StreamApprovals(ctx, &pb.StreamApprovalsRequest{})
	if err != nil {
		fmt.Printf("Error starting approval stream: %v\n", err)
		return
	}

	for {
		req, err := stream.Recv()
		if err != nil {
			if ctx.Err() != nil {
				break
			}
			fmt.Printf("Stream error: %v\n", err)
			break
		}
		h.handleApprovalCallback(req)
	}

	fmt.Println("Alert stream stopped.")
}

func formatRetentionChoice(mode commonpb.ApprovalRetentionMode, duration int64) string {
	switch mode {
	case commonpb.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CONNECTION_ONLY:
		if duration <= 0 {
			return "once (until close)"
		}
		return fmt.Sprintf("once (max %ds)", duration)
	default:
		return fmt.Sprintf("cache (%ds)", duration)
	}
}

func parseRetentionKeyword(arg string) (commonpb.ApprovalRetentionMode, bool) {
	switch strings.ToLower(strings.TrimSpace(arg)) {
	case "once", "single", "conn", "connection":
		return commonpb.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CONNECTION_ONLY, true
	case "cache", "cached":
		return commonpb.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CACHE, true
	default:
		return commonpb.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_UNSPECIFIED, false
	}
}

// executeApprovalDecision handles both approve and deny actions via the backend.
func (h *HubCLI) executeApprovalDecision(requestID string, decision pb.ApprovalDecision, retentionMode commonpb.ApprovalRetentionMode, duration int64, reason string) {
	if h.ensureHubConnected() == nil {
		return
	}

	resolvedID, err := h.resolveApprovalRequestID(requestID)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if decision == pb.ApprovalDecision_APPROVAL_DECISION_APPROVE {
		resp, err := client.ResolveApprovalDecision(ctx, &pb.ResolveApprovalDecisionRequest{
			RequestId:       resolvedID,
			Decision:        pb.ApprovalDecision_APPROVAL_DECISION_APPROVE,
			RetentionMode:   retentionMode,
			DurationSeconds: duration,
		})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		if !resp.Success {
			fmt.Printf("Error: %s\n", resp.Error)
			return
		}
		fmt.Printf("Approved request: %s (%s) [E2E encrypted]\n", shortApprovalRequestID(resolvedID), formatRetentionChoice(retentionMode, duration))
	} else {
		resp, err := client.ResolveApprovalDecision(ctx, &pb.ResolveApprovalDecisionRequest{
			RequestId:       resolvedID,
			Decision:        pb.ApprovalDecision_APPROVAL_DECISION_DENY,
			RetentionMode:   retentionMode,
			DurationSeconds: duration,
			DenyBlockType:   pb.DenyBlockType_DENY_BLOCK_TYPE_NONE,
		})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		if !resp.Success {
			fmt.Printf("Error: %s\n", resp.Error)
			return
		}
		fmt.Printf("Denied request: %s (%s, reason: %s) [E2E encrypted]\n", shortApprovalRequestID(resolvedID), formatRetentionChoice(retentionMode, duration), reason)
	}
}

func shortApprovalRequestID(requestID string) string {
	requestID = strings.TrimSpace(requestID)
	if requestID == "" {
		return ""
	}
	if idx := strings.LastIndex(requestID, ":"); idx >= 0 && idx+1 < len(requestID) {
		return requestID[idx+1:]
	}
	return requestID
}

func (h *HubCLI) resolveApprovalRequestID(input string) (string, error) {
	input = strings.TrimSpace(input)
	if input == "" {
		return "", fmt.Errorf("request_id is required")
	}
	if strings.Contains(input, ":") {
		return input, nil
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	snapshot, err := client.GetApprovalsSnapshot(ctx, &pb.GetApprovalsSnapshotRequest{
		IncludeHistory: false,
	})
	if err != nil {
		return "", fmt.Errorf("failed to resolve request ID %q: %w", input, err)
	}

	matches := make([]string, 0, 1)
	for _, req := range snapshot.GetPendingRequests() {
		if req == nil {
			continue
		}
		fullID := strings.TrimSpace(req.GetRequestId())
		if fullID == "" {
			continue
		}
		if fullID == input || shortApprovalRequestID(fullID) == input {
			matches = append(matches, fullID)
		}
	}

	if len(matches) == 1 {
		return matches[0], nil
	}
	if len(matches) > 1 {
		return "", fmt.Errorf("ambiguous request ID %q; use full ID (node:request_id)", input)
	}
	return "", fmt.Errorf("request not found: %s", input)
}

func (h *HubCLI) cmdHubApprove(args []string) {
	if !cli.RequireArgs(args, 1, "Usage: approve [once|cache] <request_id|id> [duration]  (e.g. 10s, 1m, 10m, 1h, 1d, 1w, 1y)") {
		return
	}

	mode := commonpb.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CACHE
	requestArgIdx := 0
	if parsedMode, ok := parseRetentionKeyword(args[0]); ok {
		mode = parsedMode
		requestArgIdx = 1
	}
	if len(args) <= requestArgIdx {
		fmt.Println("Usage: approve [once|cache] <request_id|id> [duration]")
		return
	}

	duration := int64(0)
	if mode == commonpb.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CACHE {
		duration = h.defaultApproveDurationSeconds()
	}

	if len(args) > requestArgIdx+1 {
		d, err := cli.ParseDuration(args[requestArgIdx+1], duration)
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		duration = d
	}
	h.executeApprovalDecision(args[requestArgIdx], pb.ApprovalDecision_APPROVAL_DECISION_APPROVE, mode, duration, "")
}

func (h *HubCLI) defaultApproveDurationSeconds() int64 {
	fallback := int64(config.DefaultApprovalDurationSeconds)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	resp, err := client.GetApprovalsSnapshot(ctx, &pb.GetApprovalsSnapshotRequest{
		IncludeHistory: false,
	})
	if err != nil || resp == nil {
		return fallback
	}
	if resp.DefaultApproveDurationSeconds < -1 {
		return fallback
	}
	return resp.DefaultApproveDurationSeconds
}

func (h *HubCLI) cmdHubDeny(args []string) {
	if !cli.RequireArgs(args, 1, "Usage: deny [once|cache] <request_id|id> [duration] [reason]") {
		return
	}

	mode := commonpb.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CONNECTION_ONLY
	requestArgIdx := 0
	if parsedMode, ok := parseRetentionKeyword(args[0]); ok {
		mode = parsedMode
		requestArgIdx = 1
	}
	if len(args) <= requestArgIdx {
		fmt.Println("Usage: deny [once|cache] <request_id|id> [duration] [reason]")
		return
	}

	duration := int64(0)
	reasonStartIdx := requestArgIdx + 1
	if mode == commonpb.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CACHE {
		duration = h.defaultApproveDurationSeconds()
		if len(args) > requestArgIdx+1 {
			if d, err := cli.ParseDuration(args[requestArgIdx+1], duration); err == nil {
				duration = d
				reasonStartIdx = requestArgIdx + 2
			}
		}
	}

	reason := "Denied via CLI"
	if len(args) > reasonStartIdx {
		reason = strings.Join(args[reasonStartIdx:], " ")
	}
	h.executeApprovalDecision(args[requestArgIdx], pb.ApprovalDecision_APPROVAL_DECISION_DENY, mode, duration, reason)
}
