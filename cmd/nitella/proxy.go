package main

import (
	"bufio"
	"context"
	"crypto/ed25519"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/hub"
	"github.com/ivere27/nitella/pkg/config"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/hub/routing"
	"gopkg.in/yaml.v3"
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

// ProxyRevisionPayload is encrypted and stored on Hub
type ProxyRevisionPayload struct {
	Name            string `json:"name"`
	Description     string `json:"description"`
	CommitMessage   string `json:"commit_message"`
	ProtocolVersion string `json:"protocol_version"`
	ConfigYAML      string `json:"config_yaml"`
	ConfigHash      string `json:"config_hash"`
}

// getProxiesDir returns the directory for local proxy configs
func getProxiesDir() string {
	return filepath.Join(dataDir, "proxies")
}

// getProxyIndex returns the path to the proxy index file
func getProxyIndexPath() string {
	return filepath.Join(getProxiesDir(), "index.json")
}

// loadProxyIndex loads the proxy metadata index
func loadProxyIndex() (map[string]*ProxyMeta, error) {
	indexPath := getProxyIndexPath()
	data, err := os.ReadFile(indexPath)
	if err != nil {
		if os.IsNotExist(err) {
			return make(map[string]*ProxyMeta), nil
		}
		return nil, err
	}

	var index map[string]*ProxyMeta
	if err := json.Unmarshal(data, &index); err != nil {
		return nil, err
	}
	return index, nil
}

// saveProxyIndex saves the proxy metadata index
func saveProxyIndex(index map[string]*ProxyMeta) error {
	if err := os.MkdirAll(getProxiesDir(), 0700); err != nil {
		return err
	}

	data, err := json.MarshalIndent(index, "", "  ")
	if err != nil {
		return err
	}

	return os.WriteFile(getProxyIndexPath(), data, 0600)
}

// getProxyPath returns the path to a proxy config file
func getProxyPath(proxyID string) string {
	return filepath.Join(getProxiesDir(), proxyID+".yaml")
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

	// Read file
	content, err := os.ReadFile(filePath)
	if err != nil {
		fmt.Printf("Error reading file: %v\n", err)
		return
	}

	// Check for existing header
	lines := strings.SplitN(string(content), "\n", 2)
	if len(lines) == 0 {
		fmt.Println("Error: Empty file")
		return
	}

	var header *config.Header
	var configContent []byte

	// Try to parse header
	header, err = config.ParseHeader(lines[0])
	if err != nil {
		// No header - wrap with header
		fmt.Println("No nitella header found, adding proxy v1 header...")
		configContent = content
	} else {
		if header.Type != config.TypeProxy {
			fmt.Printf("Warning: File has type '%s', expected 'proxy'\n", header.Type)
		}
		if len(lines) > 1 {
			configContent = []byte(lines[1])
		}
	}

	// Parse YAML to extract meta if present
	var yamlData map[string]interface{}
	if err := yaml.Unmarshal(configContent, &yamlData); err != nil {
		fmt.Printf("Error parsing YAML: %v\n", err)
		return
	}

	// Generate proxy ID
	proxyID := uuid.New().String()

	// Extract name from meta if not provided
	if name == "" {
		if meta, ok := yamlData["meta"].(map[string]interface{}); ok {
			if n, ok := meta["name"].(string); ok {
				name = n
			}
			// Use existing ID if present
			if id, ok := meta["id"].(string); ok && id != "" {
				proxyID = id
			}
		}
	}

	if name == "" {
		name = filepath.Base(filePath)
		name = strings.TrimSuffix(name, filepath.Ext(name))
	}

	// Update or add meta section
	if yamlData["meta"] == nil {
		yamlData["meta"] = make(map[string]interface{})
	}
	meta := yamlData["meta"].(map[string]interface{})
	meta["id"] = proxyID
	meta["name"] = name
	meta["created_at"] = time.Now().Format(time.RFC3339)
	meta["updated_at"] = time.Now().Format(time.RFC3339)

	// Serialize back to YAML
	newContent, err := yaml.Marshal(yamlData)
	if err != nil {
		fmt.Printf("Error serializing YAML: %v\n", err)
		return
	}

	// Add header
	fullContent := config.WriteWithHeader(config.TypeProxy, config.VersionProxy, newContent, false)

	// Save to proxies directory
	if err := os.MkdirAll(getProxiesDir(), 0700); err != nil {
		fmt.Printf("Error creating proxies directory: %v\n", err)
		return
	}

	proxyPath := getProxyPath(proxyID)
	if err := os.WriteFile(proxyPath, fullContent, 0600); err != nil {
		fmt.Printf("Error saving proxy: %v\n", err)
		return
	}

	// Update index
	index, _ := loadProxyIndex()
	index[proxyID] = &ProxyMeta{
		ID:         proxyID,
		Name:       name,
		CreatedAt:  time.Now(),
		UpdatedAt:  time.Now(),
		ConfigHash: hashConfig(newContent),
	}

	if err := saveProxyIndex(index); err != nil {
		fmt.Printf("Error saving index: %v\n", err)
		return
	}

	fmt.Printf("Created proxy %s\n", proxyID)
	fmt.Printf("  Name: %s\n", name)
	fmt.Printf("  File: %s\n", proxyPath)
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
			fmt.Printf("\n%-12s  %-30s  %-10s  %-6s  %s\n", "ID", "NAME", "STATUS", "REV", "LAST MODIFIED")
			fmt.Println(strings.Repeat("-", 85))

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
				fmt.Printf("%-12s  %-30s  %-10s  %-6s  %s\n",
					truncate(p.ID, 12), truncate(p.Name, 30), status, rev, modified)
			}
			fmt.Println()
		}
	}

	if showRemote {
		cfg := loadHubConfig()
		if err := connectToHub(cfg); err != nil {
			fmt.Printf("Error connecting to Hub: %v\n", err)
			return
		}

		// Generate routing token
		routingToken := routing.GenerateRoutingToken(cliIdentity.Fingerprint, cliIdentity.RootKey)

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		resp, err := mobileClient.ListProxyConfigs(ctx, &pb.ListProxyConfigsRequest{
			RoutingToken: routingToken,
		})
		if err != nil {
			fmt.Printf("Error listing remote proxies: %v\n", err)
			return
		}

		if len(resp.Proxies) == 0 {
			fmt.Println("\nNo remote proxies on Hub.")
		} else {
			fmt.Printf("\nRemote Proxies on Hub:\n")
			fmt.Printf("%-12s  %-6s  %-10s  %s\n", "ID", "REV", "SIZE", "LAST UPDATED")
			fmt.Println(strings.Repeat("-", 50))

			for _, p := range resp.Proxies {
				updated := "-"
				if p.UpdatedAt != nil {
					updated = p.UpdatedAt.AsTime().Format("2006-01-02 15:04")
				}
				fmt.Printf("%-12s  %-6d  %-10s  %s\n",
					truncate(p.ProxyId, 12), p.LatestRevision,
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

	meta, err := findProxyByPrefix(args[0])
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	// Read the proxy file
	content, err := os.ReadFile(getProxyPath(meta.ID))
	if err != nil {
		fmt.Printf("Error reading proxy: %v\n", err)
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
	fmt.Println(string(content))
}

func cmdProxyEdit(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy edit <proxy-id>")
		return
	}

	meta, err := findProxyByPrefix(args[0])
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	proxyPath := getProxyPath(meta.ID)

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

	// Get file hash before edit
	beforeContent, _ := os.ReadFile(proxyPath)
	beforeHash := hashConfig(beforeContent)

	// Open editor
	cmd := exec.Command(editor, proxyPath)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		fmt.Printf("Error running editor: %v\n", err)
		return
	}

	// Check if file changed
	afterContent, err := os.ReadFile(proxyPath)
	if err != nil {
		fmt.Printf("Error reading file: %v\n", err)
		return
	}

	afterHash := hashConfig(afterContent)
	if beforeHash == afterHash {
		fmt.Println("No changes made.")
		return
	}

	// Validate new content
	if err := config.VerifyChecksum(afterContent); err != nil {
		fmt.Printf("Warning: %v\n", err)
	}

	// Update index
	index, _ := loadProxyIndex()
	if m, ok := index[meta.ID]; ok {
		m.UpdatedAt = time.Now()
		m.ConfigHash = afterHash
	}
	saveProxyIndex(index)

	fmt.Println("Proxy updated.")
}

func cmdProxyExport(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy export <proxy-id> [--output file.yaml]")
		return
	}

	meta, err := findProxyByPrefix(args[0])
	if err != nil {
		fmt.Printf("Error: %v\n", err)
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

	content, err := os.ReadFile(getProxyPath(meta.ID))
	if err != nil {
		fmt.Printf("Error reading proxy: %v\n", err)
		return
	}

	if outputPath == "" {
		// Print to stdout
		fmt.Println(string(content))
	} else {
		if err := os.WriteFile(outputPath, content, 0644); err != nil {
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

	meta, err := findProxyByPrefix(args[0])
	if err != nil {
		fmt.Printf("Error: %v\n", err)
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

	// Delete local file
	proxyPath := getProxyPath(meta.ID)
	if err := os.Remove(proxyPath); err != nil && !os.IsNotExist(err) {
		fmt.Printf("Error deleting file: %v\n", err)
		return
	}

	// Update index
	index, _ := loadProxyIndex()
	delete(index, meta.ID)
	saveProxyIndex(index)

	fmt.Printf("Deleted local proxy: %s\n", meta.ID)

	// Delete from Hub if requested
	if deleteRemote && meta.RevisionNum > 0 {
		cfg := loadHubConfig()
		if err := connectToHub(cfg); err != nil {
			fmt.Printf("Error connecting to Hub: %v\n", err)
			return
		}

		routingToken := routing.GenerateRoutingToken(cliIdentity.Fingerprint, cliIdentity.RootKey)

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		_, err := mobileClient.DeleteProxyConfig(ctx, &pb.DeleteProxyConfigRequest{
			ProxyId:      meta.ID,
			RoutingToken: routingToken,
		})
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

	meta, err := findProxyByPrefix(args[0])
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	content, err := os.ReadFile(getProxyPath(meta.ID))
	if err != nil {
		fmt.Printf("Error reading proxy: %v\n", err)
		return
	}

	// Verify checksum
	if err := config.VerifyChecksum(content); err != nil {
		fmt.Printf("Checksum: FAILED - %v\n", err)
	} else {
		fmt.Println("Checksum: OK")
	}

	// Extract and parse content
	body, header, err := config.ExtractContent(content)
	if err != nil {
		fmt.Printf("Header: FAILED - %v\n", err)
		return
	}
	fmt.Printf("Header: OK (type=%s, version=v%d)\n", header.Type, header.Version)

	// Validate YAML
	var yamlData map[string]interface{}
	if err := yaml.Unmarshal(body, &yamlData); err != nil {
		fmt.Printf("YAML: FAILED - %v\n", err)
		return
	}
	fmt.Println("YAML: OK")

	// Check required sections
	required := []string{"entryPoints", "tcp"}
	for _, section := range required {
		if _, ok := yamlData[section]; ok {
			fmt.Printf("Section '%s': OK\n", section)
		} else {
			fmt.Printf("Section '%s': MISSING\n", section)
		}
	}

	fmt.Println("\nValidation complete.")
}

func cmdProxyPush(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy push <proxy-id> [-m \"message\"]")
		return
	}

	meta, err := findProxyByPrefix(args[0])
	if err != nil {
		fmt.Printf("Error: %v\n", err)
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

	// Read proxy content
	content, err := os.ReadFile(getProxyPath(meta.ID))
	if err != nil {
		fmt.Printf("Error reading proxy: %v\n", err)
		return
	}

	// Connect to Hub
	cfg := loadHubConfig()
	if err := connectToHub(cfg); err != nil {
		fmt.Printf("Error connecting to Hub: %v\n", err)
		return
	}

	routingToken := routing.GenerateRoutingToken(cliIdentity.Fingerprint, cliIdentity.RootKey)
	ctx := context.Background()

	// Create proxy on Hub if first push
	if meta.RevisionNum == 0 {
		ctxCreate, cancel := context.WithTimeout(ctx, 10*time.Second)
		resp, err := mobileClient.CreateProxyConfig(ctxCreate, &pb.CreateProxyConfigRequest{
			ProxyId:      meta.ID,
			RoutingToken: routingToken,
		})
		cancel()

		if err != nil {
			fmt.Printf("Error creating proxy on Hub: %v\n", err)
			return
		}
		if !resp.Success {
			// May already exist
			if !strings.Contains(resp.Error, "already exists") {
				fmt.Printf("Error: %s\n", resp.Error)
				return
			}
		}
	}

	// Create payload
	payload := &ProxyRevisionPayload{
		Name:            meta.Name,
		Description:     meta.Description,
		CommitMessage:   message,
		ProtocolVersion: "v1",
		ConfigYAML:      string(content),
		ConfigHash:      hashConfig(content),
	}

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		fmt.Printf("Error serializing payload: %v\n", err)
		return
	}

	// Encrypt payload
	fmt.Println("Encrypting configuration...")
	pubKey := cliIdentity.RootKey.Public().(ed25519.PublicKey)
	encrypted, err := nitellacrypto.Encrypt(payloadBytes, pubKey)
	if err != nil {
		fmt.Printf("Error encrypting: %v\n", err)
		return
	}

	encryptedBlob := encrypted.Marshal()

	// Push revision
	ctxPush, cancel := context.WithTimeout(ctx, 30*time.Second)
	defer cancel()

	resp, err := mobileClient.PushRevision(ctxPush, &pb.PushRevisionRequest{
		ProxyId:       meta.ID,
		RoutingToken:  routingToken,
		EncryptedBlob: encryptedBlob,
		SizeBytes:     int32(len(encryptedBlob)),
	})
	if err != nil {
		fmt.Printf("Error pushing revision: %v\n", err)
		return
	}

	if !resp.Success {
		fmt.Printf("Error: %s\n", resp.Error)
		return
	}

	// Update local metadata
	index, _ := loadProxyIndex()
	if m, ok := index[meta.ID]; ok {
		m.RevisionNum = resp.RevisionNum
		m.SyncedAt = time.Now()
	}
	saveProxyIndex(index)

	fmt.Printf("Pushed revision %d to Hub\n", resp.RevisionNum)
	fmt.Printf("  Revisions: %d/%d\n", resp.RevisionsKept, resp.RevisionsLimit)
	if resp.StorageLimitKb > 0 {
		fmt.Printf("  Storage: %dKB/%dKB\n", resp.StorageUsedKb, resp.StorageLimitKb)
	}
}

func cmdProxyPull(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy pull <proxy-id> [--revision N]")
		return
	}

	proxyID := args[0]
	revisionNum := int64(0) // 0 = latest

	for i := 1; i < len(args); i++ {
		if args[i] == "--revision" && i+1 < len(args) {
			fmt.Sscanf(args[i+1], "%d", &revisionNum)
			i++
		}
	}

	// Connect to Hub
	cfg := loadHubConfig()
	if err := connectToHub(cfg); err != nil {
		fmt.Printf("Error connecting to Hub: %v\n", err)
		return
	}

	routingToken := routing.GenerateRoutingToken(cliIdentity.Fingerprint, cliIdentity.RootKey)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	resp, err := mobileClient.GetRevision(ctx, &pb.GetRevisionRequest{
		ProxyId:      proxyID,
		RoutingToken: routingToken,
		RevisionNum:  revisionNum,
	})
	if err != nil {
		fmt.Printf("Error getting revision: %v\n", err)
		return
	}

	// Decrypt payload
	fmt.Println("Decrypting configuration...")
	envelope, err := nitellacrypto.UnmarshalEncryptedPayload(resp.EncryptedBlob)
	if err != nil {
		fmt.Printf("Error parsing encrypted blob: %v\n", err)
		return
	}

	decrypted, err := nitellacrypto.Decrypt(envelope, cliIdentity.RootKey)
	if err != nil {
		fmt.Printf("Error decrypting: %v\n", err)
		return
	}

	var payload ProxyRevisionPayload
	if err := json.Unmarshal(decrypted, &payload); err != nil {
		fmt.Printf("Error parsing payload: %v\n", err)
		return
	}

	// Save to local
	if err := os.MkdirAll(getProxiesDir(), 0700); err != nil {
		fmt.Printf("Error creating directory: %v\n", err)
		return
	}

	proxyPath := getProxyPath(proxyID)
	if err := os.WriteFile(proxyPath, []byte(payload.ConfigYAML), 0600); err != nil {
		fmt.Printf("Error saving proxy: %v\n", err)
		return
	}

	// Update index
	index, _ := loadProxyIndex()
	index[proxyID] = &ProxyMeta{
		ID:          proxyID,
		Name:        payload.Name,
		Description: payload.Description,
		UpdatedAt:   time.Now(),
		SyncedAt:    time.Now(),
		RevisionNum: resp.RevisionNum,
		ConfigHash:  payload.ConfigHash,
	}
	saveProxyIndex(index)

	fmt.Printf("Pulled revision %d\n", resp.RevisionNum)
	fmt.Printf("  Name: %s\n", payload.Name)
	fmt.Printf("  File: %s\n", proxyPath)
}

func cmdProxyHistory(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy history <proxy-id>")
		return
	}

	meta, err := findProxyByPrefix(args[0])
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	cfg := loadHubConfig()
	if err := connectToHub(cfg); err != nil {
		fmt.Printf("Error connecting to Hub: %v\n", err)
		return
	}

	routingToken := routing.GenerateRoutingToken(cliIdentity.Fingerprint, cliIdentity.RootKey)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	resp, err := mobileClient.ListRevisions(ctx, &pb.ListRevisionsRequest{
		ProxyId:      meta.ID,
		RoutingToken: routingToken,
	})
	if err != nil {
		fmt.Printf("Error listing revisions: %v\n", err)
		return
	}

	if len(resp.Revisions) == 0 {
		fmt.Println("No revisions found on Hub.")
		return
	}

	fmt.Printf("\nRevision history for %s:\n", meta.Name)
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

	meta, err := findProxyByPrefix(args[0])
	if err != nil {
		fmt.Printf("Error: %v\n", err)
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

	cfg := loadHubConfig()
	if err := connectToHub(cfg); err != nil {
		fmt.Printf("Error connecting to Hub: %v\n", err)
		return
	}

	routingToken := routing.GenerateRoutingToken(cliIdentity.Fingerprint, cliIdentity.RootKey)
	ctx := context.Background()

	// If no revisions specified, diff local vs latest remote
	if rev1 == 0 && rev2 == 0 {
		// Get latest revision
		ctxGet, cancel := context.WithTimeout(ctx, 10*time.Second)
		resp, err := mobileClient.GetRevision(ctxGet, &pb.GetRevisionRequest{
			ProxyId:      meta.ID,
			RoutingToken: routingToken,
			RevisionNum:  0, // latest
		})
		cancel()
		if err != nil {
			fmt.Printf("Error getting latest revision: %v\n", err)
			return
		}

		// Decrypt remote
		envelope, err := nitellacrypto.UnmarshalEncryptedPayload(resp.EncryptedBlob)
		if err != nil {
			fmt.Printf("Error parsing envelope: %v\n", err)
			return
		}

		decrypted, err := nitellacrypto.Decrypt(envelope, cliIdentity.RootKey)
		if err != nil {
			fmt.Printf("Error decrypting: %v\n", err)
			return
		}

		var remotePayload ProxyRevisionPayload
		if err := json.Unmarshal(decrypted, &remotePayload); err != nil {
			fmt.Printf("Error parsing payload: %v\n", err)
			return
		}

		// Read local
		localContent, err := os.ReadFile(getProxyPath(meta.ID))
		if err != nil {
			fmt.Printf("Error reading local file: %v\n", err)
			return
		}

		// Show diff
		fmt.Printf("--- local (file)\n")
		fmt.Printf("+++ remote (revision %d)\n", resp.RevisionNum)
		fmt.Println()
		showUnifiedDiff(string(localContent), remotePayload.ConfigYAML)
		return
	}

	// Diff between two specific revisions
	getRevision := func(revNum int64) (*ProxyRevisionPayload, int64, error) {
		ctxGet, cancel := context.WithTimeout(ctx, 10*time.Second)
		defer cancel()

		resp, err := mobileClient.GetRevision(ctxGet, &pb.GetRevisionRequest{
			ProxyId:      meta.ID,
			RoutingToken: routingToken,
			RevisionNum:  revNum,
		})
		if err != nil {
			return nil, 0, err
		}

		envelope, err := nitellacrypto.UnmarshalEncryptedPayload(resp.EncryptedBlob)
		if err != nil {
			return nil, 0, err
		}

		decrypted, err := nitellacrypto.Decrypt(envelope, cliIdentity.RootKey)
		if err != nil {
			return nil, 0, err
		}

		var payload ProxyRevisionPayload
		if err := json.Unmarshal(decrypted, &payload); err != nil {
			return nil, 0, err
		}

		return &payload, resp.RevisionNum, nil
	}

	payload1, actualRev1, err := getRevision(rev1)
	if err != nil {
		fmt.Printf("Error getting revision %d: %v\n", rev1, err)
		return
	}

	payload2, actualRev2, err := getRevision(rev2)
	if err != nil {
		fmt.Printf("Error getting revision %d: %v\n", rev2, err)
		return
	}

	fmt.Printf("--- revision %d\n", actualRev1)
	fmt.Printf("+++ revision %d\n", actualRev2)
	fmt.Println()
	showUnifiedDiff(payload1.ConfigYAML, payload2.ConfigYAML)
}

// showUnifiedDiff displays a simple unified diff between two strings
func showUnifiedDiff(old, new string) {
	oldLines := strings.Split(old, "\n")
	newLines := strings.Split(new, "\n")

	// Simple line-by-line comparison
	// This is a basic implementation - a proper diff would use LCS algorithm
	maxLen := len(oldLines)
	if len(newLines) > maxLen {
		maxLen = len(newLines)
	}

	inDiff := false
	contextLines := 3
	diffStart := -1
	var diffBuffer []string

	flushDiff := func() {
		if len(diffBuffer) > 0 {
			fmt.Printf("@@ -%d,%d +%d,%d @@\n", diffStart+1, len(diffBuffer), diffStart+1, len(diffBuffer))
			for _, line := range diffBuffer {
				fmt.Println(line)
			}
			diffBuffer = nil
		}
	}

	for i := 0; i < maxLen; i++ {
		var oldLine, newLine string
		if i < len(oldLines) {
			oldLine = oldLines[i]
		}
		if i < len(newLines) {
			newLine = newLines[i]
		}

		if oldLine != newLine {
			if !inDiff {
				inDiff = true
				diffStart = i
				// Add context before
				start := i - contextLines
				if start < 0 {
					start = 0
				}
				for j := start; j < i; j++ {
					if j < len(oldLines) {
						diffBuffer = append(diffBuffer, " "+oldLines[j])
					}
				}
			}

			if i < len(oldLines) && oldLine != "" {
				diffBuffer = append(diffBuffer, "-"+oldLine)
			}
			if i < len(newLines) && newLine != "" {
				diffBuffer = append(diffBuffer, "+"+newLine)
			}
		} else if inDiff {
			// Add context after
			diffBuffer = append(diffBuffer, " "+oldLine)
			contextLines--
			if contextLines <= 0 {
				flushDiff()
				inDiff = false
				contextLines = 3
			}
		}
	}

	flushDiff()

	if !inDiff && len(diffBuffer) == 0 {
		fmt.Println("No differences found.")
	}
}

func cmdProxyFlush(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy flush <proxy-id> [--keep N]")
		return
	}

	meta, err := findProxyByPrefix(args[0])
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	keepCount := int32(1) // Default: keep only latest
	for i := 1; i < len(args); i++ {
		if args[i] == "--keep" && i+1 < len(args) {
			fmt.Sscanf(args[i+1], "%d", &keepCount)
			i++
		}
	}

	cfg := loadHubConfig()
	if err := connectToHub(cfg); err != nil {
		fmt.Printf("Error connecting to Hub: %v\n", err)
		return
	}

	routingToken := routing.GenerateRoutingToken(cliIdentity.Fingerprint, cliIdentity.RootKey)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	resp, err := mobileClient.FlushRevisions(ctx, &pb.FlushRevisionsRequest{
		ProxyId:      meta.ID,
		RoutingToken: routingToken,
		KeepCount:    keepCount,
	})
	if err != nil {
		fmt.Printf("Error flushing revisions: %v\n", err)
		return
	}

	if !resp.Success {
		fmt.Printf("Error: %s\n", resp.Error)
		return
	}

	fmt.Printf("Flushed %d revisions, %d remaining\n", resp.DeletedCount, resp.RemainingCount)
}

func cmdProxyApply(args []string) {
	if len(args) < 2 {
		fmt.Println("Usage: proxy apply <proxy-id> <node-id> [--revision N]")
		return
	}

	proxyIDPrefix := args[0]
	nodeID := args[1]

	revisionNum := int64(0) // 0 = latest
	for i := 2; i < len(args); i++ {
		if args[i] == "--revision" && i+1 < len(args) {
			fmt.Sscanf(args[i+1], "%d", &revisionNum)
			i++
		}
	}

	// Find local proxy
	meta, err := findProxyByPrefix(proxyIDPrefix)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	// Connect to Hub
	cfg := loadHubConfig()
	if err := connectToHub(cfg); err != nil {
		fmt.Printf("Error connecting to Hub: %v\n", err)
		return
	}

	routingToken := routing.GenerateRoutingToken(cliIdentity.Fingerprint, cliIdentity.RootKey)
	ctx := context.Background()

	// If no revision specified, check if we have it locally
	var configYAML string
	var actualRevision int64

	if revisionNum == 0 && meta.RevisionNum > 0 {
		// Use local copy
		content, err := os.ReadFile(getProxyPath(meta.ID))
		if err != nil {
			fmt.Printf("Error reading local proxy: %v\n", err)
			return
		}
		configYAML = string(content)
		actualRevision = meta.RevisionNum
	} else {
		// Fetch from Hub
		fmt.Println("Fetching proxy from Hub...")
		ctxGet, cancel := context.WithTimeout(ctx, 30*time.Second)
		resp, err := mobileClient.GetRevision(ctxGet, &pb.GetRevisionRequest{
			ProxyId:      meta.ID,
			RoutingToken: routingToken,
			RevisionNum:  revisionNum,
		})
		cancel()
		if err != nil {
			fmt.Printf("Error getting revision: %v\n", err)
			return
		}

		// Decrypt
		fmt.Println("Decrypting configuration...")
		envelope, err := nitellacrypto.UnmarshalEncryptedPayload(resp.EncryptedBlob)
		if err != nil {
			fmt.Printf("Error parsing envelope: %v\n", err)
			return
		}

		decrypted, err := nitellacrypto.Decrypt(envelope, cliIdentity.RootKey)
		if err != nil {
			fmt.Printf("Error decrypting: %v\n", err)
			return
		}

		var payload ProxyRevisionPayload
		if err := json.Unmarshal(decrypted, &payload); err != nil {
			fmt.Printf("Error parsing payload: %v\n", err)
			return
		}

		configYAML = payload.ConfigYAML
		actualRevision = resp.RevisionNum
	}

	// Create apply command payload
	applyPayload := map[string]interface{}{
		"proxy_id":     meta.ID,
		"revision_num": actualRevision,
		"config_yaml":  configYAML,
		"config_hash":  hashConfig([]byte(configYAML)),
	}

	payloadBytes, _ := json.Marshal(applyPayload)

	// Encrypt for node
	fmt.Println("Sending to node via Hub...")
	nodeRoutingToken := routing.GenerateRoutingToken(nodeID, cliIdentity.RootKey)

	encrypted, err := nitellacrypto.Encrypt(payloadBytes, cliIdentity.RootKey.Public().(ed25519.PublicKey))
	if err != nil {
		fmt.Printf("Error encrypting: %v\n", err)
		return
	}

	// Convert crypto EncryptedPayload to protobuf EncryptedPayload
	pbEncrypted := &common.EncryptedPayload{
		EphemeralPubkey: encrypted.EphemeralPubKey,
		Nonce:           encrypted.Nonce,
		Ciphertext:      encrypted.Ciphertext,
	}

	// Send command via Hub
	ctxCmd, cancel := context.WithTimeout(ctx, 30*time.Second)
	defer cancel()

	cmdResp, err := mobileClient.SendCommand(ctxCmd, &pb.CommandRequest{
		NodeId:       nodeID,
		RoutingToken: nodeRoutingToken,
		Encrypted:    pbEncrypted,
	})
	if err != nil {
		fmt.Printf("Error sending command: %v\n", err)
		return
	}

	// Check response
	if cmdResp.EncryptedData != nil && len(cmdResp.EncryptedData.Ciphertext) > 0 {
		// Convert protobuf EncryptedPayload back to crypto EncryptedPayload
		respEnvelope := &nitellacrypto.EncryptedPayload{
			EphemeralPubKey: cmdResp.EncryptedData.EphemeralPubkey,
			Nonce:           cmdResp.EncryptedData.Nonce,
			Ciphertext:      cmdResp.EncryptedData.Ciphertext,
		}
		decrypted, err := nitellacrypto.Decrypt(respEnvelope, cliIdentity.RootKey)
		if err == nil {
			var result map[string]interface{}
			if json.Unmarshal(decrypted, &result) == nil {
				status, _ := result["status"].(string)
				if status == "applied" || status == "already_applied" {
					fmt.Printf("Applied proxy %s (rev %d) to node %s\n", meta.ID, actualRevision, nodeID)
					return
				} else if status == "error" {
					errMsg, _ := result["error"].(string)
					fmt.Printf("Error: %s\n", errMsg)
					return
				}
			}
		}
	}

	fmt.Printf("Applied proxy %s (rev %d) to node %s\n", meta.ID, actualRevision, nodeID)
}

func cmdProxyStatus(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: proxy status <node-id>")
		return
	}

	nodeID := args[0]

	// Connect to Hub
	cfg := loadHubConfig()
	if err := connectToHub(cfg); err != nil {
		fmt.Printf("Error connecting to Hub: %v\n", err)
		return
	}

	nodeRoutingToken := routing.GenerateRoutingToken(nodeID, cliIdentity.RootKey)
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Create get_applied command
	cmdPayload := map[string]string{}
	payloadBytes, _ := json.Marshal(cmdPayload)

	encrypted, err := nitellacrypto.Encrypt(payloadBytes, cliIdentity.RootKey.Public().(ed25519.PublicKey))
	if err != nil {
		fmt.Printf("Error encrypting: %v\n", err)
		return
	}

	// Convert crypto EncryptedPayload to protobuf EncryptedPayload
	pbEncrypted := &common.EncryptedPayload{
		EphemeralPubkey: encrypted.EphemeralPubKey,
		Nonce:           encrypted.Nonce,
		Ciphertext:      encrypted.Ciphertext,
	}

	cmdResp, err := mobileClient.SendCommand(ctx, &pb.CommandRequest{
		NodeId:       nodeID,
		RoutingToken: nodeRoutingToken,
		Encrypted:    pbEncrypted,
	})
	if err != nil {
		fmt.Printf("Error sending command: %v\n", err)
		return
	}

	// Decrypt and display response
	if cmdResp.EncryptedData != nil && len(cmdResp.EncryptedData.Ciphertext) > 0 {
		// Convert protobuf EncryptedPayload back to crypto EncryptedPayload
		respEnvelope := &nitellacrypto.EncryptedPayload{
			EphemeralPubKey: cmdResp.EncryptedData.EphemeralPubkey,
			Nonce:           cmdResp.EncryptedData.Nonce,
			Ciphertext:      cmdResp.EncryptedData.Ciphertext,
		}

		decrypted, err := nitellacrypto.Decrypt(respEnvelope, cliIdentity.RootKey)
		if err != nil {
			fmt.Printf("Error decrypting response: %v\n", err)
			return
		}

		var result struct {
			Proxies []struct {
				ProxyID     string `json:"proxy_id"`
				RevisionNum int64  `json:"revision_num"`
				AppliedAt   string `json:"applied_at"`
				Status      string `json:"status"`
			} `json:"proxies"`
			Count int `json:"count"`
		}

		if err := json.Unmarshal(decrypted, &result); err != nil {
			fmt.Printf("Error parsing result: %v\n", err)
			return
		}

		if result.Count == 0 {
			fmt.Println("No proxies applied to this node.")
			return
		}

		fmt.Printf("\nApplied proxies on node %s:\n", nodeID)
		fmt.Printf("%-12s  %-6s  %-20s  %s\n", "PROXY ID", "REV", "APPLIED AT", "STATUS")
		fmt.Println(strings.Repeat("-", 60))

		for _, p := range result.Proxies {
			fmt.Printf("%-12s  %-6d  %-20s  %s\n",
				truncate(p.ProxyID, 12), p.RevisionNum, p.AppliedAt, p.Status)
		}
		fmt.Println()
		return
	}

	fmt.Println("No response from node.")
}

func cmdProxyUnapply(args []string) {
	if len(args) < 2 {
		fmt.Println("Usage: proxy unapply <proxy-id> <node-id>")
		return
	}

	proxyIDPrefix := args[0]
	nodeID := args[1]

	// Find local proxy
	meta, err := findProxyByPrefix(proxyIDPrefix)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	// Connect to Hub
	cfg := loadHubConfig()
	if err := connectToHub(cfg); err != nil {
		fmt.Printf("Error connecting to Hub: %v\n", err)
		return
	}

	nodeRoutingToken := routing.GenerateRoutingToken(nodeID, cliIdentity.RootKey)
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Create unapply command
	cmdPayload := map[string]string{
		"proxy_id": meta.ID,
	}
	payloadBytes, _ := json.Marshal(cmdPayload)

	encrypted, err := nitellacrypto.Encrypt(payloadBytes, cliIdentity.RootKey.Public().(ed25519.PublicKey))
	if err != nil {
		fmt.Printf("Error encrypting: %v\n", err)
		return
	}

	// Convert crypto EncryptedPayload to protobuf EncryptedPayload
	pbEncrypted := &common.EncryptedPayload{
		EphemeralPubkey: encrypted.EphemeralPubKey,
		Nonce:           encrypted.Nonce,
		Ciphertext:      encrypted.Ciphertext,
	}

	cmdResp, err := mobileClient.SendCommand(ctx, &pb.CommandRequest{
		NodeId:       nodeID,
		RoutingToken: nodeRoutingToken,
		Encrypted:    pbEncrypted,
	})
	if err != nil {
		fmt.Printf("Error sending command: %v\n", err)
		return
	}

	// Check response
	if cmdResp.EncryptedData != nil && len(cmdResp.EncryptedData.Ciphertext) > 0 {
		// Convert protobuf EncryptedPayload back to crypto EncryptedPayload
		respEnvelope := &nitellacrypto.EncryptedPayload{
			EphemeralPubKey: cmdResp.EncryptedData.EphemeralPubkey,
			Nonce:           cmdResp.EncryptedData.Nonce,
			Ciphertext:      cmdResp.EncryptedData.Ciphertext,
		}
		decrypted, err := nitellacrypto.Decrypt(respEnvelope, cliIdentity.RootKey)
		if err == nil {
			var result map[string]interface{}
			if json.Unmarshal(decrypted, &result) == nil {
				status, _ := result["status"].(string)
				if status == "unapplied" {
					fmt.Printf("Removed proxy %s from node %s\n", meta.ID, nodeID)
					return
				} else if status == "not_found" {
					fmt.Printf("Proxy %s was not applied to node %s\n", meta.ID, nodeID)
					return
				}
			}
		}
	}

	fmt.Printf("Removed proxy %s from node %s\n", meta.ID, nodeID)
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
