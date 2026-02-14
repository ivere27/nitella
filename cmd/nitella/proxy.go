package main

import (
	"bufio"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"os"
	"os/exec"
	"sort"
	"strings"
	"time"

	pb "github.com/ivere27/nitella/pkg/api/local"
	"github.com/ivere27/nitella/pkg/cli"
)

// ProxyMeta stores metadata for a local proxy config
type ProxyMeta struct {
	ID          string    `yaml:"id" json:"id"`
	Name        string    `yaml:"name" json:"name"`
	Description string    `yaml:"description,omitempty" json:"description,omitempty"`
	CreatedAt   time.Time `yaml:"created_at" json:"created_at"`
	UpdatedAt   time.Time `yaml:"updated_at" json:"updated_at"`
	SyncedAt    time.Time `yaml:"synced_at,omitempty" json:"synced_at,omitempty"`
	RevisionNum int64     `yaml:"revision_num,omitempty" json:"revision_num,omitempty"`
	ConfigHash  string    `yaml:"config_hash,omitempty" json:"config_hash,omitempty"`
}

func fromLocalProxy(pbMeta *pb.LocalProxyConfig) *ProxyMeta {
	if pbMeta == nil {
		return nil
	}
	meta := &ProxyMeta{
		ID:          pbMeta.ProxyId,
		Name:        pbMeta.Name,
		Description: pbMeta.Description,
		RevisionNum: pbMeta.RevisionNum,
		ConfigHash:  pbMeta.ConfigHash,
	}
	if pbMeta.CreatedAt != nil {
		meta.CreatedAt = pbMeta.CreatedAt.AsTime()
	}
	if pbMeta.UpdatedAt != nil {
		meta.UpdatedAt = pbMeta.UpdatedAt.AsTime()
	}
	if pbMeta.SyncedAt != nil {
		meta.SyncedAt = pbMeta.SyncedAt.AsTime()
	}
	return meta
}

// loadProxyIndex loads local proxy metadata from MobileLogicService.
func loadProxyIndex() (map[string]*ProxyMeta, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	resp, err := client.ListLocalProxyConfigs(ctx, &pb.ListLocalProxyConfigsRequest{})
	if err != nil {
		return nil, err
	}

	index := make(map[string]*ProxyMeta, len(resp.Proxies))
	for _, p := range resp.Proxies {
		meta := fromLocalProxy(p)
		if meta != nil {
			index[meta.ID] = meta
		}
	}
	return index, nil
}

func getLocalProxy(proxyID string) (*ProxyMeta, string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	resp, err := client.GetLocalProxyConfig(ctx, &pb.GetLocalProxyConfigRequest{ProxyId: proxyID})
	if err != nil {
		return nil, "", err
	}
	if !resp.Success {
		return nil, "", fmt.Errorf("%s", resp.Error)
	}
	return fromLocalProxy(resp.Proxy), resp.ConfigYaml, nil
}

func saveLocalProxy(proxyID, name, description, content string) (*ProxyMeta, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	resp, err := client.SaveLocalProxyConfig(ctx, &pb.SaveLocalProxyConfigRequest{
		ProxyId:     proxyID,
		Name:        name,
		Description: description,
		ConfigYaml:  content,
	})
	if err != nil {
		return nil, err
	}
	if !resp.Success {
		return nil, fmt.Errorf("%s", resp.Error)
	}
	return fromLocalProxy(resp.Proxy), nil
}

// findProxyByPrefix finds a proxy by ID prefix (convenience)
func findProxyByPrefix(prefix string) (*ProxyMeta, error) {
	index, err := loadProxyIndex()
	if err != nil {
		return nil, err
	}

	var matches []*ProxyMeta
	for id, meta := range index {
		if strings.HasPrefix(id, prefix) {
			matches = append(matches, meta)
		}
	}

	if len(matches) == 0 {
		return nil, fmt.Errorf("no proxy found with ID prefix: %s", prefix)
	}
	if len(matches) > 1 {
		return nil, fmt.Errorf("ambiguous ID prefix: %s (matches %d proxies)", prefix, len(matches))
	}

	return matches[0], nil
}

// resolveProxyID resolves a local prefix to full proxy ID.
// If no local match exists, it falls back to the provided value directly.
func resolveProxyID(idOrPrefix string) (string, error) {
	meta, err := findProxyByPrefix(idOrPrefix)
	if err == nil {
		return meta.ID, nil
	}
	if strings.Contains(err.Error(), "ambiguous") {
		return "", err
	}
	return idOrPrefix, nil
}

// hashConfig computes SHA256 of config content
func hashConfig(content []byte) string {
	h := sha256.Sum256(content)
	return hex.EncodeToString(h[:])
}

// cmdHubProxy handles proxy commands
func cmdHubProxy(args []string) {
	if len(args) == 0 {
		printProxyHelp()
		return
	}

	switch args[0] {
	case "import":
		cmdProxyImport(args[1:])
	case "list", "ls":
		cmdProxyList(args[1:])
	case "show":
		cmdProxyShow(args[1:])
	case "edit":
		cmdProxyEdit(args[1:])
	case "export":
		cmdProxyExport(args[1:])
	case "delete", "rm":
		cmdProxyDelete(args[1:])
	case "validate":
		cmdProxyValidate(args[1:])
	case "push":
		cmdProxyPush(args[1:])
	case "pull":
		cmdProxyPull(args[1:])
	case "history":
		cmdProxyHistory(args[1:])
	case "diff":
		cmdProxyDiff(args[1:])
	case "flush":
		cmdProxyFlush(args[1:])
	case "apply":
		cmdProxyApply(args[1:])
	case "status":
		cmdProxyStatus(args[1:])
	case "unapply":
		cmdProxyUnapply(args[1:])
	default:
		fmt.Printf("Unknown proxy command: %s\n", args[0])
		printProxyHelp()
	}
}

func printProxyHelp() {
	fmt.Print(`
Proxy Management Commands:

Local Management:
  proxy import <file.yaml> [--name "name"]   Import YAML file as proxy config
  proxy list [--local|--remote|--all]        List proxies
  proxy show <proxy-id> [--revision N]       Show proxy details
  proxy edit <proxy-id>                      Edit proxy (opens $EDITOR)
  proxy export <proxy-id> [--output file]    Export to file
  proxy delete <proxy-id> [--remote]         Delete proxy
  proxy validate <proxy-id>                  Validate proxy config

Hub Sync:
  proxy push <proxy-id> [-m "message"]       Push to Hub
  proxy pull <proxy-id> [--revision N]       Pull from Hub
  proxy history <proxy-id>                   View revision history
  proxy diff <proxy-id> [--rev1 N --rev2 M]  Diff revisions
  proxy flush <proxy-id> [--keep N]          Flush old revisions

Apply to Node:
  proxy apply <proxy-id> <node-id>           Apply proxy to node
  proxy status <node-id>                     Show applied proxies
  proxy unapply <proxy-id> <node-id>         Remove proxy from node

EXAMPLES:
  # Create a new proxy from a YAML file
  nitella proxy import ./config/proxy.yaml --name "My Web Proxy"

  # Push changes to the Hub
  nitella proxy push <proxy-id> -m "Updated firewall rules"
`)
}

func cmdProxyImport(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy import <file.yaml> [--name \"name\"]")
		return
	}

	filePath := args[0]
	name := ""

	// Parse optional flags
	for i := 1; i < len(args); i++ {
		if args[i] == "--name" && i+1 < len(args) {
			name = args[i+1]
			i++
		}
	}

	content, err := os.ReadFile(filePath)
	if err != nil {
		fmt.Printf("Error reading file: %v\n", err)
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	resp, err := client.ImportLocalProxyConfig(ctx, &pb.ImportLocalProxyConfigRequest{
		ConfigData: content,
		SourceName: filePath,
		Name:       name,
	})
	if err != nil {
		fmt.Printf("Error importing proxy: %v\n", err)
		return
	}
	if !resp.Success || resp.Proxy == nil {
		errMsg := resp.Error
		if errMsg == "" {
			errMsg = "unknown error"
		}
		fmt.Printf("Error importing proxy: %s\n", errMsg)
		return
	}

	fmt.Printf("Created proxy %s\n", resp.Proxy.ProxyId)
	fmt.Printf("  Name: %s\n", resp.Proxy.Name)
	fmt.Println("  Stored in MobileLogicService local storage")
}

func cmdProxyList(args []string) {
	showLocal := true
	showRemote := false

	for _, arg := range args {
		switch arg {
		case "--local":
			showLocal = true
			showRemote = false
		case "--remote":
			showLocal = false
			showRemote = true
		case "--all":
			showLocal = true
			showRemote = true
		}
	}

	if showLocal {
		index, err := loadProxyIndex()
		if err != nil {
			fmt.Printf("Error loading index: %v\n", err)
			return
		}

		if len(index) == 0 {
			fmt.Println("No local proxies. Use 'proxy import' to add one.")
		} else {
			tbl := cli.NewTable(
				cli.Column{Header: "ID", Width: 36},
				cli.Column{Header: "NAME", Width: 30},
				cli.Column{Header: "STATUS", Width: 10},
				cli.Column{Header: "REV", Width: 6},
				cli.Column{Header: "LAST MODIFIED", Width: 16},
			)
			tbl.PrintHeader()

			// Sort by name
			var proxies []*ProxyMeta
			for _, p := range index {
				proxies = append(proxies, p)
			}
			sort.Slice(proxies, func(i, j int) bool {
				return proxies[i].Name < proxies[j].Name
			})

			for _, p := range proxies {
				status := "local"
				if p.RevisionNum > 0 {
					status = "synced"
				}
				rev := "-"
				if p.RevisionNum > 0 {
					rev = fmt.Sprintf("%d", p.RevisionNum)
				}
				modified := p.UpdatedAt.Format("2006-01-02 15:04")
				tbl.PrintRow(p.ID, truncate(p.Name, 30), status, rev, modified)
			}
			tbl.PrintFooter()
		}
	}

	if showRemote {
		if hubCLI.ensureHubConnected() == nil {
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		resp, err := client.ListProxyConfigs(ctx, &pb.ListProxyConfigsRequest{})
		if err != nil {
			fmt.Printf("Error listing remote proxies: %v\n", err)
			return
		}

		if len(resp.Proxies) == 0 {
			fmt.Println("\nNo remote proxies on Hub.")
		} else {
			fmt.Printf("\nRemote Proxies on Hub:\n")
			fmt.Printf("%-36s  %-6s  %-10s  %s\n", "ID", "REV", "SIZE", "LAST UPDATED")
			fmt.Println(strings.Repeat("-", 75))

			for _, p := range resp.Proxies {
				updated := "-"
				if p.UpdatedAt != nil {
					updated = p.UpdatedAt.AsTime().Format("2006-01-02 15:04")
				}
				fmt.Printf("%-36s  %-6d  %-10s  %s\n",
					p.ProxyId, p.LatestRevision,
					formatSize(int64(p.TotalSizeBytes)), updated)
			}
			fmt.Println()
		}
	}
}

func cmdProxyShow(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy show <proxy-id>")
		return
	}

	meta, content, err := getLocalProxy(args[0])
	if err != nil {
		fmt.Printf("Error reading proxy: %v\n", err)
		return
	}
	if meta == nil {
		fmt.Println("Error reading proxy: missing metadata")
		return
	}

	fmt.Printf("\nProxy: %s\n", meta.ID)
	fmt.Printf("  Name: %s\n", meta.Name)
	if meta.Description != "" {
		fmt.Printf("  Description: %s\n", meta.Description)
	}
	fmt.Printf("  Created: %s\n", meta.CreatedAt.Format(time.RFC3339))
	fmt.Printf("  Modified: %s\n", meta.UpdatedAt.Format(time.RFC3339))
	if meta.RevisionNum > 0 {
		fmt.Printf("  Hub Revision: %d\n", meta.RevisionNum)
		fmt.Printf("  Last Synced: %s\n", meta.SyncedAt.Format(time.RFC3339))
	}
	fmt.Println("\n--- Content ---")
	fmt.Println(content)
}

func cmdProxyEdit(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy edit <proxy-id>")
		return
	}

	// Get editor
	editor := os.Getenv("EDITOR")
	if editor == "" {
		editor = os.Getenv("VISUAL")
	}
	if editor == "" {
		// Try common editors
		for _, e := range []string{"vim", "vi", "nano", "code"} {
			if _, err := exec.LookPath(e); err == nil {
				editor = e
				break
			}
		}
	}

	if editor == "" {
		fmt.Println("No editor found. Set $EDITOR environment variable.")
		return
	}

	meta, currentContent, err := getLocalProxy(args[0])
	if err != nil {
		fmt.Printf("Error reading proxy: %v\n", err)
		return
	}
	if meta == nil {
		fmt.Println("Error reading proxy: missing metadata")
		return
	}

	tmpFile, err := os.CreateTemp("", "nitella-proxy-*.yaml")
	if err != nil {
		fmt.Printf("Error creating temp file: %v\n", err)
		return
	}
	tmpPath := tmpFile.Name()
	_ = tmpFile.Close()
	defer os.Remove(tmpPath)

	if err := os.WriteFile(tmpPath, []byte(currentContent), 0600); err != nil {
		fmt.Printf("Error writing temp file: %v\n", err)
		return
	}

	beforeHash := hashConfig([]byte(currentContent))

	// Open editor
	cmd := exec.Command(editor, tmpPath)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		fmt.Printf("Error running editor: %v\n", err)
		return
	}

	// Check if file changed
	afterContent, err := os.ReadFile(tmpPath)
	if err != nil {
		fmt.Printf("Error reading file: %v\n", err)
		return
	}

	afterHash := hashConfig(afterContent)
	if beforeHash == afterHash {
		fmt.Println("No changes made.")
		return
	}

	if _, err := saveLocalProxy(meta.ID, meta.Name, meta.Description, string(afterContent)); err != nil {
		fmt.Printf("Error saving proxy: %v\n", err)
		return
	}

	fmt.Println("Proxy updated.")
}

func cmdProxyExport(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy export <proxy-id> [--output file.yaml]")
		return
	}

	// Parse output flag
	outputPath := ""
	for i := 1; i < len(args); i++ {
		if (args[i] == "--output" || args[i] == "-o") && i+1 < len(args) {
			outputPath = args[i+1]
			i++
		}
	}

	_, content, err := getLocalProxy(args[0])
	if err != nil {
		fmt.Printf("Error reading proxy: %v\n", err)
		return
	}

	if outputPath == "" {
		// Print to stdout
		fmt.Println(content)
	} else {
		if err := os.WriteFile(outputPath, []byte(content), 0644); err != nil {
			fmt.Printf("Error writing file: %v\n", err)
			return
		}
		fmt.Printf("Exported to: %s\n", outputPath)
	}
}

func cmdProxyDelete(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy delete <proxy-id> [--remote] [--force]")
		return
	}

	meta, _, err := getLocalProxy(args[0])
	if err != nil {
		fmt.Printf("Error reading proxy: %v\n", err)
		return
	}
	if meta == nil {
		fmt.Println("Error reading proxy: missing metadata")
		return
	}

	deleteRemote := false
	force := false
	for _, arg := range args[1:] {
		if arg == "--remote" {
			deleteRemote = true
		}
		if arg == "--force" || arg == "-f" {
			force = true
		}
	}

	// Confirm deletion
	if !force {
		fmt.Printf("Delete proxy '%s' (%s)? [y/N] ", meta.Name, meta.ID[:8])
		reader := bufio.NewReader(os.Stdin)
		response, _ := reader.ReadString('\n')
		response = strings.TrimSpace(strings.ToLower(response))
		if response != "y" && response != "yes" {
			fmt.Println("Cancelled.")
			return
		}
	}

	ctxLocal, cancelLocal := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancelLocal()
	localResp, err := client.DeleteLocalProxyConfig(ctxLocal, &pb.DeleteLocalProxyConfigRequest{ProxyId: meta.ID})
	if err != nil {
		fmt.Printf("Error deleting local proxy: %v\n", err)
		return
	}
	if !localResp.Success {
		fmt.Printf("Error deleting local proxy: %s\n", localResp.Error)
		return
	}

	fmt.Printf("Deleted local proxy: %s\n", meta.ID)

	// Delete from Hub if requested
	if deleteRemote && meta.RevisionNum > 0 {
		if hubCLI.ensureHubConnected() == nil {
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		_, err := client.DeleteProxyConfig(ctx, &pb.DeleteProxyConfigRequest{ProxyId: meta.ID})
		if err != nil {
			fmt.Printf("Error deleting from Hub: %v\n", err)
			return
		}

		fmt.Println("Deleted from Hub.")
	}
}

func cmdProxyValidate(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy validate <proxy-id>")
		return
	}

	meta, _, err := getLocalProxy(args[0])
	if err != nil {
		fmt.Printf("Error reading proxy: %v\n", err)
		return
	}
	if meta == nil {
		fmt.Println("Error reading proxy: missing metadata")
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	resp, err := client.ValidateLocalProxyConfig(ctx, &pb.ValidateLocalProxyConfigRequest{
		ProxyId: meta.ID,
	})
	if err != nil {
		fmt.Printf("Error validating proxy: %v\n", err)
		return
	}
	if !resp.Success {
		fmt.Printf("Error validating proxy: %s\n", resp.Error)
		return
	}

	// Verify checksum
	if resp.ChecksumOk {
		fmt.Println("Checksum: OK")
	} else {
		fmt.Printf("Checksum: FAILED - %s\n", resp.ChecksumError)
	}

	if !resp.HeaderOk {
		fmt.Printf("Header: FAILED - %s\n", resp.HeaderError)
		return
	}
	fmt.Printf("Header: OK (type=%s, version=v%d)\n", resp.HeaderType, resp.HeaderVersion)

	if !resp.YamlOk {
		fmt.Printf("YAML: FAILED - %s\n", resp.YamlError)
		return
	}
	fmt.Println("YAML: OK")

	// Check required sections
	printSectionResult("entryPoints", resp.HasEntryPoints)
	printSectionResult("tcp", resp.HasTcp)

	fmt.Println("\nValidation complete.")
}

func printSectionResult(section string, present bool) {
	if present {
		fmt.Printf("Section '%s': OK\n", section)
	} else {
		fmt.Printf("Section '%s': MISSING\n", section)
	}
}

func cmdProxyPush(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy push <proxy-id> [-m \"message\"]")
		return
	}

	meta, _, err := getLocalProxy(args[0])
	if err != nil {
		fmt.Printf("Error reading proxy: %v\n", err)
		return
	}
	if meta == nil {
		fmt.Println("Error reading proxy: missing metadata")
		return
	}

	// Parse message flag
	message := ""
	for i := 1; i < len(args); i++ {
		if args[i] == "-m" && i+1 < len(args) {
			message = args[i+1]
			i++
		}
	}

	if message == "" {
		message = fmt.Sprintf("Updated %s", time.Now().Format("2006-01-02 15:04"))
	}

	if hubCLI.ensureHubConnected() == nil {
		return
	}

	// Backend orchestrates local read + encryption + push + local metadata update.
	ctxPush, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	result, err := client.PushLocalProxyRevision(ctxPush, &pb.PushLocalProxyRevisionRequest{
		ProxyId:       meta.ID,
		CommitMessage: message,
	})
	if err != nil {
		fmt.Printf("Error pushing revision: %v\n", err)
		return
	}
	if !result.Success {
		fmt.Printf("Error pushing revision: %s\n", result.Error)
		return
	}

	explicitPushState := result.GetRemotePushed() ||
		result.GetLocalMetadataUpdated() ||
		strings.TrimSpace(result.GetLocalMetadataError()) != ""
	remotePushed := result.GetRemotePushed()
	if !explicitPushState {
		// Backward compatibility: older backends only had Success=true for a real push.
		remotePushed = true
	}

	if remotePushed {
		fmt.Printf("Pushed revision %d to Hub\n", result.RevisionNum)
		fmt.Printf("  Revisions: %d/%d\n", result.RevisionsKept, result.RevisionsLimit)
		if result.StorageLimitKb > 0 {
			fmt.Printf("  Storage: %dKB/%dKB\n", result.StorageUsedKb, result.StorageLimitKb)
		}
	} else {
		if result.RevisionNum > 0 {
			fmt.Printf("No changes to push (already at revision %d)\n", result.RevisionNum)
		} else {
			fmt.Println("No changes to push")
		}
	}
	if result.GetRemotePushed() && !result.GetLocalMetadataUpdated() {
		localErr := strings.TrimSpace(result.GetLocalMetadataError())
		if localErr == "" {
			localErr = strings.TrimSpace(result.GetError())
		}
		if localErr != "" {
			fmt.Printf("  Warning: local metadata not updated: %s\n", localErr)
		} else {
			fmt.Println("  Warning: local metadata not updated")
		}
	} else if strings.TrimSpace(result.Error) != "" {
		fmt.Printf("  Note: %s\n", result.Error)
	}
}

func cmdProxyPull(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy pull <proxy-id> [--revision N]")
		return
	}

	proxyID := strings.TrimSpace(args[0])
	if proxyID == "" {
		fmt.Println("Usage: proxy pull <proxy-id> [--revision N]")
		return
	}
	revisionNum := int64(0) // 0 = latest

	for i := 1; i < len(args); i++ {
		if args[i] == "--revision" && i+1 < len(args) {
			fmt.Sscanf(args[i+1], "%d", &revisionNum)
			i++
		}
	}

	// Connect to Hub
	if hubCLI.ensureHubConnected() == nil {
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	fmt.Println("Decrypting configuration...")
	rev, err := client.PullProxyRevision(ctx, &pb.PullProxyRevisionRequest{
		ProxyId:     proxyID,
		RevisionNum: revisionNum,
		StoreLocal:  true,
	})
	if err != nil {
		fmt.Printf("Error getting revision: %v\n", err)
		return
	}
	if !rev.Success {
		fmt.Printf("Error getting revision: %s\n", rev.Error)
		return
	}

	fmt.Printf("Pulled revision %d\n", rev.RevisionNum)
	fmt.Printf("  Name: %s\n", rev.Name)
	fmt.Println("  Stored in MobileLogicService local storage")
}

func cmdProxyHistory(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy history <proxy-id>")
		return
	}

	proxyID := strings.TrimSpace(args[0])
	if proxyID == "" {
		fmt.Println("Usage: proxy history <proxy-id>")
		return
	}
	proxyName := proxyID
	if meta, _, err := getLocalProxy(proxyID); err == nil && meta != nil {
		proxyID = meta.ID
		if meta.Name != "" {
			proxyName = meta.Name
		}
	}

	if hubCLI.ensureHubConnected() == nil {
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	resp, err := client.ListProxyRevisions(ctx, &pb.ListProxyRevisionsRequest{ProxyId: proxyID})
	if err != nil {
		fmt.Printf("Error listing revisions: %v\n", err)
		return
	}

	if len(resp.Revisions) == 0 {
		fmt.Println("No revisions found on Hub.")
		return
	}

	fmt.Printf("\nRevision history for %s:\n", proxyName)
	fmt.Printf("%-6s  %-10s  %s\n", "REV", "SIZE", "DATE")
	fmt.Println(strings.Repeat("-", 40))

	for _, r := range resp.Revisions {
		date := ""
		if r.CreatedAt != nil {
			date = r.CreatedAt.AsTime().Format("2006-01-02 15:04:05")
		}
		fmt.Printf("%-6d  %-10s  %s\n", r.RevisionNum, formatSize(int64(r.SizeBytes)), date)
	}
	fmt.Println()
}

func cmdProxyDiff(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy diff <proxy-id> [--rev1 N --rev2 M]")
		return
	}

	proxyID := strings.TrimSpace(args[0])
	if proxyID == "" {
		fmt.Println("Usage: proxy diff <proxy-id> [--rev1 N --rev2 M]")
		return
	}

	// Parse revision flags
	rev1 := int64(0) // Will be second-latest or local
	rev2 := int64(0) // Will be latest

	for i := 1; i < len(args); i++ {
		switch args[i] {
		case "--rev1":
			if i+1 < len(args) {
				fmt.Sscanf(args[i+1], "%d", &rev1)
				i++
			}
		case "--rev2":
			if i+1 < len(args) {
				fmt.Sscanf(args[i+1], "%d", &rev2)
				i++
			}
		}
	}

	if hubCLI.ensureHubConnected() == nil {
		return
	}

	req := &pb.DiffProxyRevisionsRequest{
		ProxyId: proxyID,
	}
	if rev1 == 0 && rev2 == 0 {
		req.LocalVsLatest = true
	} else {
		req.RevisionNumA = rev1
		req.RevisionNumB = rev2
	}

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()

	resp, err := client.DiffProxyRevisions(ctx, req)
	if err != nil {
		fmt.Printf("Error getting proxy diff: %v\n", err)
		return
	}
	if !resp.Success {
		fmt.Printf("Error getting proxy diff: %s\n", resp.Error)
		return
	}
	if !resp.HasDifferences || strings.TrimSpace(resp.UnifiedDiff) == "" {
		fmt.Println("No differences found.")
		return
	}

	fmt.Print(resp.UnifiedDiff)
	if !strings.HasSuffix(resp.UnifiedDiff, "\n") {
		fmt.Println()
	}
}

func cmdProxyFlush(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy flush <proxy-id> [--keep N]")
		return
	}

	proxyID := strings.TrimSpace(args[0])
	if proxyID == "" {
		fmt.Println("Usage: proxy flush <proxy-id> [--keep N]")
		return
	}

	keepCount := int32(1) // Default: keep only latest
	for i := 1; i < len(args); i++ {
		if args[i] == "--keep" && i+1 < len(args) {
			fmt.Sscanf(args[i+1], "%d", &keepCount)
			i++
		}
	}

	if hubCLI.ensureHubConnected() == nil {
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	result, err := client.FlushProxyRevisions(ctx, &pb.FlushProxyRevisionsRequest{
		ProxyId:   proxyID,
		KeepCount: keepCount,
	})
	if err != nil {
		fmt.Printf("Error flushing revisions: %v\n", err)
		return
	}

	fmt.Printf("Flushed %d revisions, %d remaining\n", result.DeletedCount, result.RemainingCount)
}

func cmdProxyApply(args []string) {
	if len(args) < 2 {
		fmt.Println("Usage: proxy apply <proxy-id> <node-id> [--revision N]")
		return
	}

	proxyID := strings.TrimSpace(args[0])
	if proxyID == "" {
		fmt.Println("Usage: proxy apply <proxy-id> <node-id> [--revision N]")
		return
	}
	nodeID := args[1]

	revisionNum := int64(0) // 0 = latest
	for i := 2; i < len(args); i++ {
		if args[i] == "--revision" && i+1 < len(args) {
			fmt.Sscanf(args[i+1], "%d", &revisionNum)
			i++
		}
	}

	// Connect to Hub
	if hubCLI.ensureHubConnected() == nil {
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Apply proxy to node via backend (backend resolves latest/explicit revision).
	fmt.Println("Sending to node via Hub...")
	resp, err := client.ApplyProxyToNode(ctx, &pb.ApplyProxyToNodeRequest{
		ProxyId:     proxyID,
		NodeId:      nodeID,
		RevisionNum: revisionNum,
	})
	if err != nil {
		fmt.Printf("Error applying proxy: %v\n", err)
		return
	}

	if resp.Success {
		if revisionNum > 0 {
			fmt.Printf("Applied proxy %s (requested rev %d) to node %s\n", proxyID, revisionNum, nodeID)
		} else {
			fmt.Printf("Applied proxy %s (latest revision) to node %s\n", proxyID, nodeID)
		}
	} else {
		fmt.Printf("Error applying proxy: %s\n", resp.Error)
	}
}

func cmdProxyStatus(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy status <node-id>")
		return
	}

	nodeID := args[0]

	// Connect to Hub
	if hubCLI.ensureHubConnected() == nil {
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	resp, err := client.GetAppliedProxies(ctx, &pb.GetAppliedProxiesRequest{NodeId: nodeID})
	if err != nil {
		fmt.Printf("Error getting applied proxies: %v\n", err)
		return
	}

	if len(resp.Proxies) == 0 {
		fmt.Println("No proxies applied to this node.")
		return
	}

	fmt.Printf("\nApplied proxies on node %s:\n", nodeID)
	fmt.Printf("%-12s  %-6s  %-20s  %s\n", "PROXY ID", "REV", "APPLIED AT", "STATUS")
	fmt.Println(strings.Repeat("-", 60))

	for _, p := range resp.Proxies {
		fmt.Printf("%-12s  %-6d  %-20s  %s\n",
			truncate(p.ProxyId, 12), p.RevisionNum, p.AppliedAt, p.Status)
	}
	fmt.Println()
}

func cmdProxyUnapply(args []string) {
	if len(args) < 2 {
		fmt.Println("Usage: proxy unapply <proxy-id> <node-id>")
		return
	}
	proxyID := strings.TrimSpace(args[0])
	if proxyID == "" {
		fmt.Println("Usage: proxy unapply <proxy-id> <node-id>")
		return
	}
	nodeID := args[1]

	// Connect to Hub
	if hubCLI.ensureHubConnected() == nil {
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	resp, err := client.UnapplyProxyFromNode(ctx, &pb.UnapplyProxyFromNodeRequest{
		ProxyId: proxyID,
		NodeId:  nodeID,
	})
	if err != nil {
		fmt.Printf("Error unapplying proxy: %v\n", err)
		return
	}

	if resp.Success {
		fmt.Printf("Removed proxy %s from node %s\n", proxyID, nodeID)
	} else {
		fmt.Printf("Error unapplying proxy: %s\n", resp.Error)
	}
}

// formatSize formats bytes as human-readable
func formatSize(bytes int64) string {
	const unit = 1024
	if bytes < unit {
		return fmt.Sprintf("%d B", bytes)
	}
	div, exp := int64(unit), 0
	for n := bytes / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %cB", float64(bytes)/float64(div), "KMGTPE"[exp])
}
