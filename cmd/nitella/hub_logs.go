package main

import (
	"context"
	"fmt"
	"time"

	pb "github.com/ivere27/nitella/pkg/api/local"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// ============================================================================
// Logs Management Commands (Admin) — uses backend (MobileLogicService)
// ============================================================================

func (h *HubCLI) cmdHubLogs(args []string) {
	if len(args) == 0 {
		printLogsHelp()
		return
	}

	if h.ensureHubConnected() == nil {
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	switch args[0] {
	case "stats":
		h.cmdLogsStats(ctx)
	case "list":
		if len(args) < 2 {
			fmt.Println("Usage: logs list <routing_token> [--node <node_id>] [--limit <n>]")
			return
		}
		h.cmdLogsList(ctx, args[1:])
	case "delete":
		if len(args) < 2 {
			fmt.Println("Usage: logs delete <routing_token> [--node <node_id>] [--before <date>] [--all]")
			return
		}
		h.cmdLogsDelete(ctx, args[1:])
	case "cleanup":
		if len(args) < 2 {
			fmt.Println("Usage: logs cleanup <days> [--dry-run]")
			return
		}
		h.cmdLogsCleanup(ctx, args[1:])
	default:
		fmt.Printf("Unknown logs command: %s\n", args[0])
		printLogsHelp()
	}
}

func printLogsHelp() {
	fmt.Print(`
Logs Management Commands (Admin):
  logs stats                          - Show logs storage statistics
  logs list <routing_token>           - List logs for a routing token
    --node <node_id>                  - Filter by node
    --limit <n>                       - Limit results (default: 100)
  logs delete <routing_token>         - Delete logs
    --node <node_id>                  - Delete only for specific node
    --before <date>                   - Delete logs before date (YYYY-MM-DD)
    --all                             - Delete all logs for routing token
  logs cleanup <days>                 - Delete logs older than N days
    --dry-run                         - Show what would be deleted
`)
}

func (h *HubCLI) cmdLogsStats(ctx context.Context) {
	resp, err := client.GetLogsStats(ctx, &pb.GetLogsStatsRequest{})
	if err != nil {
		fmt.Printf("Error getting logs stats: %v\n", err)
		return
	}

	fmt.Println("\nLogs Statistics:")
	fmt.Printf("  Total logs:     %d\n", resp.TotalLogs)
	fmt.Printf("  Total storage:  %s\n", formatBytes(resp.TotalStorageBytes))

	if resp.OldestLog != nil {
		fmt.Printf("  Oldest log:     %s\n", resp.OldestLog.AsTime().Format(time.RFC3339))
	}
	if resp.NewestLog != nil {
		fmt.Printf("  Newest log:     %s\n", resp.NewestLog.AsTime().Format(time.RFC3339))
	}

	if len(resp.LogsByRoutingToken) > 0 {
		fmt.Println("\n  By Routing Token:")
		for token, count := range resp.LogsByRoutingToken {
			storage := resp.StorageByRoutingToken[token]
			displayToken := token
			if len(token) > 20 {
				displayToken = token[:8] + "..." + token[len(token)-8:]
			}
			fmt.Printf("    %s: %d logs (%s)\n", displayToken, count, formatBytes(storage))
		}
	}
}

func (h *HubCLI) cmdLogsList(ctx context.Context, args []string) {
	routingToken := args[0]
	nodeID := ""
	limit := int32(100)

	for i := 1; i < len(args); i++ {
		switch args[i] {
		case "--node":
			if i+1 < len(args) {
				nodeID = args[i+1]
				i++
			}
		case "--limit":
			if i+1 < len(args) {
				fmt.Sscanf(args[i+1], "%d", &limit)
				i++
			}
		}
	}

	resp, err := client.ListLogs(ctx, &pb.ListLogsRequest{
		RoutingToken: routingToken,
		NodeId:       nodeID,
		PageSize:     limit,
	})
	if err != nil {
		fmt.Printf("Error listing logs: %v\n", err)
		return
	}

	fmt.Printf("\nLogs for %s (total: %d):\n", routingToken, resp.TotalCount)
	fmt.Println("  ID       | Node ID           | Timestamp           | Size")
	fmt.Println("  ---------+-------------------+---------------------+--------")

	for _, log := range resp.Logs {
		nodeDisplay := log.NodeId
		if len(nodeDisplay) > 17 {
			nodeDisplay = nodeDisplay[:14] + "..."
		}
		fmt.Printf("  %-8d | %-17s | %s | %s\n",
			log.Id,
			nodeDisplay,
			log.Timestamp.AsTime().Format("2006-01-02 15:04:05"),
			formatBytes(int64(log.EncryptedSizeBytes)),
		)
	}

	if resp.NextPageToken != "" {
		fmt.Printf("\n  (more results available, use --limit to increase)\n")
	}
}

func (h *HubCLI) cmdLogsDelete(ctx context.Context, args []string) {
	routingToken := args[0]
	nodeID := ""
	deleteAll := false
	var beforeTime time.Time

	for i := 1; i < len(args); i++ {
		switch args[i] {
		case "--node":
			if i+1 < len(args) {
				nodeID = args[i+1]
				i++
			}
		case "--before":
			if i+1 < len(args) {
				t, err := time.Parse("2006-01-02", args[i+1])
				if err != nil {
					fmt.Printf("Invalid date format: %s (use YYYY-MM-DD)\n", args[i+1])
					return
				}
				beforeTime = t
				i++
			}
		case "--all":
			deleteAll = true
		}
	}

	if !deleteAll && nodeID == "" && beforeTime.IsZero() {
		fmt.Println("Error: specify --all, --node, or --before")
		return
	}

	req := &pb.DeleteLogsRequest{
		RoutingToken: routingToken,
		NodeId:       nodeID,
		DeleteAll:    deleteAll,
	}
	if !beforeTime.IsZero() {
		req.Before = timestamppb.New(beforeTime)
	}

	resp, err := client.DeleteLogs(ctx, req)
	if err != nil {
		fmt.Printf("Error deleting logs: %v\n", err)
		return
	}

	fmt.Printf("Deleted %d logs, freed %s\n", resp.DeletedCount, formatBytes(resp.FreedBytes))
}

func (h *HubCLI) cmdLogsCleanup(ctx context.Context, args []string) {
	var days int32
	dryRun := false

	fmt.Sscanf(args[0], "%d", &days)
	if days <= 0 {
		fmt.Println("Error: days must be a positive number")
		return
	}

	for i := 1; i < len(args); i++ {
		if args[i] == "--dry-run" {
			dryRun = true
		}
	}

	resp, err := client.CleanupOldLogs(ctx, &pb.CleanupOldLogsRequest{
		OlderThanDays: days,
		DryRun:        dryRun,
	})
	if err != nil {
		fmt.Printf("Error cleaning up logs: %v\n", err)
		return
	}

	if dryRun {
		fmt.Printf("Would delete %d logs\n", resp.DeletedCount)
	} else {
		fmt.Printf("Deleted %d logs, freed %s\n", resp.DeletedCount, formatBytes(resp.FreedBytes))
	}

	if len(resp.DeletedByRoutingToken) > 0 {
		fmt.Println("\n  By Routing Token:")
		for token, count := range resp.DeletedByRoutingToken {
			displayToken := token
			if len(token) > 20 {
				displayToken = token[:8] + "..." + token[len(token)-8:]
			}
			fmt.Printf("    %s: %d logs\n", displayToken, count)
		}
	}
}
