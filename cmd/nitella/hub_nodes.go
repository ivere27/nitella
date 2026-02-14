package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	pb "github.com/ivere27/nitella/pkg/api/local"
	"github.com/ivere27/nitella/pkg/cli"
)

func (h *HubCLI) cmdHubStatus() {
	cfg := h.ensureHubConnected()
	if cfg == nil {
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	snapshot, err := client.GetHubDashboardSnapshot(ctx, &pb.GetHubDashboardSnapshotRequest{})
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}
	overview := snapshot.GetOverview()
	if overview == nil {
		fmt.Println("Error: empty hub dashboard snapshot response")
		return
	}

	hubAddress := overview.GetHubAddress()
	if strings.TrimSpace(hubAddress) == "" {
		hubAddress = cfg.HubAddress
	}

	fmt.Println("\nHub Connection Status: Connected")
	fmt.Printf("  Hub Address:  %s\n", hubAddress)

	// Display Hub CA info if available
	if cfg.HubCAFP != "" {
		fmt.Printf("  Hub CA FP:    %s\n", cfg.HubCAFP)
		if cfg.HubCAEmoji != "" {
			fmt.Printf("  Hub CA Emoji: %s\n", cfg.HubCAEmoji)
		}
	}

	fmt.Printf("  Total nodes:  %d\n", overview.GetTotalNodes())
	fmt.Printf("  Online nodes: %d\n", overview.GetOnlineNodes())
	fmt.Println()
}

func (h *HubCLI) cmdHubNodes(args []string) {
	if h.ensureHubConnected() == nil {
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	resp, err := client.GetHubDashboardSnapshot(ctx, &pb.GetHubDashboardSnapshotRequest{})
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	if len(resp.Nodes) == 0 {
		fmt.Println("No nodes registered.")
		return
	}

	tbl := cli.NewTable(
		cli.Column{Header: "NODE ID", Width: 36},
		cli.Column{Header: "NODE CERT EMOJI", Width: 28},
		cli.Column{Header: "STATUS", Width: 12},
		cli.Column{Header: "LAST SEEN", Width: 16},
	)
	tbl.PrintHeader()
	for _, n := range resp.Nodes {
		status := "OFFLINE"
		if n.Online {
			status = "ONLINE"
		}
		lastSeen := "never"
		if n.LastSeen != nil {
			lastSeen = n.LastSeen.AsTime().Format("2006-01-02 15:04")
		}
		emojiHash := n.GetEmojiHash()
		if strings.TrimSpace(emojiHash) == "" {
			emojiHash = "-"
		}
		tbl.PrintRow(n.NodeId, emojiHash, status, lastSeen)
	}
	tbl.PrintFooter()
}

func (h *HubCLI) cmdHubNode(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: node <node_id> [status|rules|metrics|conn]")
		return
	}

	if h.ensureHubConnected() == nil {
		return
	}

	nodeID := args[0]
	subCmd := "status"
	if len(args) > 1 {
		subCmd = args[1]
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	switch subCmd {
	case "status":
		snapshot, err := client.GetNodeDetailSnapshot(ctx, &pb.GetNodeDetailSnapshotRequest{
			NodeId:               nodeID,
			IncludeRuntimeStatus: true,
		})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		node := snapshot.GetNode()
		runtime := snapshot.GetRuntimeStatus()
		if node == nil && runtime == nil {
			fmt.Println("Error: empty node detail snapshot")
			return
		}

		resolvedStatus := "OFFLINE"
		if node != nil && node.GetOnline() {
			resolvedStatus = "ONLINE"
		}
		if runtime != nil && strings.TrimSpace(runtime.GetStatus()) != "" {
			resolvedStatus = runtime.GetStatus()
		}

		lastSeen := runtime.GetLastSeen()
		if lastSeen == nil && node != nil {
			lastSeen = node.GetLastSeen()
		}
		publicIP := runtime.GetPublicIp()
		version := runtime.GetVersion()
		if version == "" && node != nil {
			version = node.GetVersion()
		}

		fmt.Printf("\nNode: %s\n", nodeID)
		fmt.Printf("  Status:       %s\n", resolvedStatus)
		if lastSeen != nil {
			fmt.Printf("  Last seen:    %s\n", lastSeen.AsTime().Format(time.RFC3339))
		}
		if publicIP != "" {
			fmt.Printf("  Public IP:    %s\n", publicIP)
		}
		if version != "" {
			fmt.Printf("  Version:      %s\n", version)
		}
		fmt.Printf("  GeoIP:        %v\n", runtime.GetGeoipEnabled())
		fmt.Println()

	case "rules":
		snapshot, err := client.GetNodeDetailSnapshot(ctx, &pb.GetNodeDetailSnapshotRequest{
			NodeId:       nodeID,
			IncludeRules: true,
		})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		rules := snapshot.GetRules()

		if len(rules) == 0 {
			fmt.Println("No rules configured.")
			return
		}

		fmt.Printf("\n%-36s  %-20s  %-8s  %-8s\n", "ID", "Name", "Priority", "Action")
		fmt.Println(strings.Repeat("-", 80))
		for _, r := range rules {
			name := r.Name
			if len(name) > 20 {
				name = name[:17] + "..."
			}
			fmt.Printf("%-36s  %-20s  %-8d  %-8s\n",
				r.Id, name, r.Priority, r.Action.String())
		}
		fmt.Println()

	case "metrics":
		fmt.Println("Streaming metrics (Ctrl+C to stop)...")

		metricsCtx, metricsCancel := context.WithCancel(context.Background())
		defer metricsCancel()

		// Handle Ctrl+C
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, os.Interrupt, syscall.SIGINT)
		go func() {
			<-sigCh
			fmt.Println("\nStopping metrics stream...")
			metricsCancel()
		}()
		defer signal.Stop(sigCh)

		stream, err := client.StreamMetrics(metricsCtx, &pb.StreamMetricsRequest{
			NodeId: nodeID,
		})
		if err != nil {
			fmt.Printf("Error starting metrics stream: %v\n", err)
			return
		}

		fmt.Printf("Streaming metrics from node %s...\n\n", nodeID)

		for {
			metrics, err := stream.Recv()
			if err != nil {
				if metricsCtx.Err() != nil {
					break
				}
				fmt.Printf("Stream error: %v\n", err)
				break
			}
			ts := time.Now().Format("15:04:05")
			fmt.Printf("[%s] Node: %s\n", ts, nodeID)
			fmt.Printf("  Connections: %d active / %d total\n",
				metrics.ActiveConnections, metrics.TotalConnections)
			fmt.Printf("  Traffic:     %s in / %s out\n",
				formatBytes(metrics.BytesIn), formatBytes(metrics.BytesOut))
			fmt.Printf("  Blocked:     %d\n", metrics.BlockedTotal)
			fmt.Println()
		}

		fmt.Println("Metrics stream stopped.")

	case "conn", "conns", "connections":
		connSubCmd := ""
		if len(args) > 2 {
			connSubCmd = args[2]
		}

		switch connSubCmd {
		case "close":
			if len(args) < 4 {
				fmt.Println("Usage: node <node_id> conn close <conn_id>")
				return
			}
			resp, err := client.CloseConnection(ctx, &pb.CloseConnectionRequest{
				NodeId:     nodeID,
				Identifier: &pb.CloseConnectionRequest_ConnId{ConnId: args[3]},
			})
			if err != nil {
				fmt.Printf("Error: %v\n", err)
				return
			}
			if !resp.Success {
				fmt.Printf("Error: %s\n", resp.Error)
				return
			}
			fmt.Println("Connection closed.")

		case "closeall":
			proxyID := ""
			if len(args) > 3 {
				proxyID = args[3]
			}
			resp, err := client.CloseAllConnections(ctx, &pb.CloseAllConnectionsRequest{
				NodeId:  nodeID,
				ProxyId: proxyID,
			})
			if err != nil {
				fmt.Printf("Error: %v\n", err)
				return
			}
			if !resp.Success {
				fmt.Printf("Error: %s\n", resp.Error)
				return
			}
			if proxyID != "" {
				fmt.Printf("All connections closed on proxy %s.\n", proxyID)
			} else {
				fmt.Println("All connections closed.")
			}

		default:
			proxyID := ""
			if connSubCmd != "" {
				proxyID = connSubCmd
			}
			resp, err := client.ListConnections(ctx, &pb.ListConnectionsRequest{
				NodeId:  nodeID,
				ProxyId: proxyID,
			})
			if err != nil {
				fmt.Printf("Error: %v\n", err)
				return
			}
			if len(resp.Connections) == 0 {
				fmt.Println("No active connections.")
				return
			}
			fmt.Printf("\nActive Connections on node %s:\n", nodeID)
			tbl := cli.NewTable(
				cli.Column{Header: "ID", Width: 36},
				cli.Column{Header: "SOURCE", Width: 22},
				cli.Column{Header: "DEST", Width: 22},
				cli.Column{Header: "IN", Width: 10},
				cli.Column{Header: "OUT", Width: 10},
			)
			tbl.PrintHeader()
			for _, c := range resp.Connections {
				source := c.SourceIp
				if c.SourcePort > 0 {
					source = fmt.Sprintf("%s:%d", c.SourceIp, c.SourcePort)
				}
				tbl.PrintRow(c.ConnId, source, c.DestAddr, formatBytes(c.BytesIn), formatBytes(c.BytesOut))
			}
			tbl.PrintFooter()
		}

	default:
		fmt.Printf("Unknown subcommand: %s\n", subCmd)
		fmt.Println("Available: status, rules, metrics, conn")
	}
}

func (h *HubCLI) cmdHubSend(args []string) {
	_ = args
	fmt.Println("The raw 'send' command is removed.")
	fmt.Println("Use typed commands instead:")
	fmt.Println("  node <node_id> status")
	fmt.Println("  node <node_id> rules")
	fmt.Println("  node <node_id> conn")
	fmt.Println("  node <node_id> metrics")
}
