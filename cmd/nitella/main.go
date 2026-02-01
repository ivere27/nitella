package main

import (
	"bufio"
	"context"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"path/filepath"
	"strconv"
	"strings"
	"syscall"
	"time"

	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/identity"
	"github.com/ivere27/nitella/pkg/shell"
	"golang.org/x/term"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"
	"google.golang.org/protobuf/types/known/emptypb"

	pb "github.com/ivere27/nitella/pkg/api/proxy"
)

var (
	serverAddr string
	authToken  string
	client     pb.ProxyControlServiceClient
	conn       *grpc.ClientConn

	// Mode flags
	localMode bool // Connect to local nitellad instead of Hub

	// Identity
	cliIdentity *identity.Identity
	dataDir     string
	passphrase  string // Passphrase for encrypting private key
	kdfProfile  string // KDF profile: default, server, secure
)

func main() {
	// Default data directory
	homeDir, _ := os.UserHomeDir()
	defaultDataDir := filepath.Join(homeDir, ".nitella")

	// Mode flags - Hub is default, --local for nitellad
	flag.BoolVar(&localMode, "local", false, "Connect to local nitellad instead of Hub")
	flag.StringVar(&dataDir, "data-dir", defaultDataDir, "Data directory for identity and configuration")
	flag.StringVar(&passphrase, "passphrase", os.Getenv("NITELLA_PASSPHRASE"), "Passphrase for key encryption (env: NITELLA_PASSPHRASE)")
	flag.StringVar(&kdfProfile, "kdf-profile", os.Getenv("NITELLA_KDF_PROFILE"), "KDF security profile: default, server, secure (env: NITELLA_KDF_PROFILE)")

	// Local mode flags (only used with --local)
	addr := flag.String("addr", "localhost:50051", "Local nitellad server address (with --local)")
	token := flag.String("token", os.Getenv("NITELLA_TOKEN"), "Authentication token for local nitellad (env: NITELLA_TOKEN)")

	// Hub mode flags
	flag.StringVar(&hubAddress, "hub", os.Getenv("NITELLA_HUB"), "Hub server address (env: NITELLA_HUB)")
	flag.StringVar(&hubToken, "hub-token", os.Getenv("NITELLA_HUB_TOKEN"), "Hub authentication token (env: NITELLA_HUB_TOKEN)")
	flag.StringVar(&stunServer, "stun", os.Getenv("NITELLA_STUN"), "STUN server URL for P2P (env: NITELLA_STUN)")

	flag.Parse()

	// Initialize identity (required for both modes, but especially for Hub)
	if err := initIdentity(); err != nil {
		fmt.Printf("Failed to initialize identity: %v\n", err)
		os.Exit(1)
	}

	// Check for command-line args (single command mode)
	args := flag.Args()

	if localMode {
		// Local mode: connect to nitellad
		serverAddr = *addr
		authToken = *token

		if authToken == "" {
			fmt.Println("Warning: No token provided. Use --token or set NITELLA_TOKEN environment variable.")
		}

		var err error
		conn, err = grpc.NewClient(serverAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err != nil {
			fmt.Printf("Failed to connect to %s: %v\n", serverAddr, err)
			os.Exit(1)
		}
		defer conn.Close()

		client = pb.NewProxyControlServiceClient(conn)

		// Validate token by making a test call
		ctx, cancel := context.WithTimeout(authCtx(), 3*time.Second)
		_, err = client.ListProxies(ctx, &pb.ListProxiesRequest{})
		cancel()
		if err != nil {
			if strings.Contains(err.Error(), "Unauthenticated") {
				fmt.Println("Error: Authentication failed. Check your token.")
				os.Exit(1)
			}
			fmt.Printf("Error: Failed to connect to %s: %v\n", serverAddr, err)
			os.Exit(1)
		}

		if len(args) > 0 {
			handleCommand(strings.Join(args, " "))
			return
		}

		// Interactive shell for local mode
		fmt.Printf("Nitella CLI (Local Mode) - Connected to %s\n", serverAddr)
		fmt.Println("Type 'help' for available commands, 'exit' to quit.")
		fmt.Println()

		shell.StartREPL("nitella> ", func(line string) error {
			handleCommand(line)
			return nil
		}, newCompletion())

	} else {
		// Hub mode (default)
		if len(args) > 0 {
			handleHubCommand(args)
			return
		}

		// Interactive shell for Hub mode
		fmt.Println("Nitella CLI - Hub Mode")
		fmt.Printf("Identity: %s\n", cliIdentity.EmojiHash)
		fmt.Printf("Fingerprint: %s...%s\n", cliIdentity.Fingerprint[:8], cliIdentity.Fingerprint[len(cliIdentity.Fingerprint)-8:])
		fmt.Println()
		fmt.Println("Type 'help' for available commands, 'exit' to quit.")
		fmt.Println()

		shell.StartREPL("nitella> ", func(line string) error {
			parts := strings.Fields(line)
			if len(parts) == 0 {
				return nil
			}

			cmd := parts[0]
			cmdArgs := parts[1:]

			switch cmd {
			case "help":
				printHubModeHelp()
			case "exit", "quit":
				os.Exit(0)
			case "identity":
				cmdIdentity(cmdArgs)
			default:
				// All other commands go to Hub handler
				handleHubCommand(parts)
			}
			return nil
		}, newHubCompletion())
	}
}

// initIdentity initializes or loads the CLI identity
func initIdentity() error {
	cfg := identity.DefaultConfig(dataDir, "nitella-cli")

	// Parse KDF profile
	if kdfProfile == "" {
		kdfProfile = "default"
	}
	kdfParams, err := nitellacrypto.GetKDFProfile(kdfProfile)
	if err != nil {
		return err
	}
	cfg.KDFParams = kdfParams

	// Check if stdin is a terminal (for interactive prompts)
	isTerminal := term.IsTerminal(int(syscall.Stdin))

	// Check if key already exists
	keyExists := identity.KeyExists(dataDir)

	if keyExists {
		// Existing identity - check if encrypted and get passphrase if needed
		encrypted, err := identity.IsKeyEncrypted(dataDir)
		if err != nil {
			return fmt.Errorf("failed to check key encryption: %w", err)
		}

		if encrypted && passphrase == "" {
			if !isTerminal {
				return fmt.Errorf("passphrase required for encrypted key (set NITELLA_PASSPHRASE or use --passphrase)")
			}
			// Need to prompt for passphrase
			fmt.Print("Enter passphrase: ")
			passphraseBytes, err := term.ReadPassword(int(syscall.Stdin))
			fmt.Println()
			if err != nil {
				return fmt.Errorf("failed to read passphrase: %w", err)
			}
			passphrase = string(passphraseBytes)
			nitellacrypto.Wipe(passphraseBytes) // Wipe passphrase bytes from memory
		}

		cfg.Passphrase = passphrase
		cliIdentity, _, err = identity.LoadOrCreate(cfg)
		if err != nil {
			if strings.Contains(err.Error(), "message authentication failed") {
				return fmt.Errorf("incorrect passphrase")
			}
			return err
		}
		return nil
	}

	// New identity - prompt for passphrase (unless provided via flag/env or non-interactive)
	if passphrase == "" && isTerminal && !passphraseExplicitlySet() {
		newPassphrase, err := promptNewPassphrase()
		if err != nil {
			return err
		}
		cfg.Passphrase = newPassphrase
	} else {
		cfg.Passphrase = passphrase
		// Show passphrase strength warning for flag/env provided passphrase
		if passphrase != "" {
			showPassphraseStrength(passphrase, false) // false = don't ask, just warn
		}
	}

	var isNew bool
	cliIdentity, isNew, err = identity.LoadOrCreate(cfg)
	if err != nil {
		return err
	}

	if isNew {
		// First launch - display mnemonic and emoji hash
		fmt.Println()
		fmt.Println("╔══════════════════════════════════════════════════════════════════╗")
		fmt.Println("║                    NITELLA IDENTITY CREATED                       ║")
		fmt.Println("╚══════════════════════════════════════════════════════════════════╝")
		fmt.Println()
		fmt.Println("Your identity has been created with a BIP-39 mnemonic phrase.")
		fmt.Println("IMPORTANT: Write down and securely store this mnemonic!")
		fmt.Println()
		fmt.Println("┌──────────────────────────────────────────────────────────────────┐")
		fmt.Printf("│ Mnemonic: %-55s │\n", cliIdentity.Mnemonic)
		fmt.Println("└──────────────────────────────────────────────────────────────────┘")
		fmt.Println()
		fmt.Printf("Emoji Hash:   %s\n", cliIdentity.EmojiHash)
		fmt.Printf("Fingerprint:  %s\n", cliIdentity.Fingerprint)
		fmt.Println()
		fmt.Println("The emoji hash provides visual verification of your identity.")
		fmt.Println("When pairing with Hub, verify the emoji hash matches on both ends.")
		fmt.Println()
		if cfg.Passphrase != "" {
			fmt.Printf("Private key encrypted with %s\n", kdfParams.String())
		} else {
			fmt.Println("Private key is NOT encrypted (no passphrase set).")
		}
		fmt.Printf("Identity saved to: %s\n", dataDir)
		fmt.Println()
	}

	return nil
}

// showPassphraseStrength displays passphrase strength analysis
func showPassphraseStrength(pass string, interactive bool) bool {
	check := nitellacrypto.CheckPassphrase(pass)

	fmt.Println()
	fmt.Println("Passphrase Security Analysis:")
	fmt.Println(check.FormatStrengthReport())
	fmt.Println()

	if check.Strength == nitellacrypto.StrengthWeak && interactive {
		fmt.Print("Continue with weak passphrase? (y/N): ")
		reader := bufio.NewReader(os.Stdin)
		response, _ := reader.ReadString('\n')
		response = strings.TrimSpace(strings.ToLower(response))
		return response == "y" || response == "yes"
	}

	return true // Non-interactive: just warn, don't block
}

// passphraseExplicitlySet checks if --passphrase flag or NITELLA_PASSPHRASE env was explicitly provided
func passphraseExplicitlySet() bool {
	// Check if NITELLA_PASSPHRASE environment variable is set (even if empty)
	if _, ok := os.LookupEnv("NITELLA_PASSPHRASE"); ok {
		return true
	}
	// Check if --passphrase flag was explicitly passed in command line
	for _, arg := range os.Args[1:] {
		if arg == "--passphrase" || strings.HasPrefix(arg, "--passphrase=") {
			return true
		}
	}
	return false
}

// promptNewPassphrase prompts user to set a passphrase for new identity
func promptNewPassphrase() (string, error) {
	reader := bufio.NewReader(os.Stdin)

	fmt.Print("Enter passphrase for key encryption (empty for no encryption): ")
	pass1Bytes, err := term.ReadPassword(int(syscall.Stdin))
	fmt.Println()
	if err != nil {
		return "", fmt.Errorf("failed to read passphrase: %w", err)
	}

	if len(pass1Bytes) == 0 {
		// Empty passphrase - confirm
		fmt.Print("No passphrase entered. Continue without encryption? (y/N): ")
		confirm, _ := reader.ReadString('\n')
		confirm = strings.TrimSpace(strings.ToLower(confirm))
		if confirm != "y" && confirm != "yes" {
			// Ask again
			return promptNewPassphrase()
		}
		return "", nil
	}

	// Check passphrase strength before confirming
	tempPass := string(pass1Bytes)
	if !showPassphraseStrength(tempPass, true) {
		nitellacrypto.Wipe(pass1Bytes)
		return promptNewPassphrase()
	}

	// Confirm passphrase
	fmt.Print("Confirm passphrase: ")
	pass2Bytes, err := term.ReadPassword(int(syscall.Stdin))
	fmt.Println()
	if err != nil {
		nitellacrypto.Wipe(pass1Bytes)
		return "", fmt.Errorf("failed to read passphrase: %w", err)
	}

	// Compare as bytes (avoid creating strings until necessary)
	if len(pass1Bytes) != len(pass2Bytes) {
		nitellacrypto.Wipe(pass1Bytes)
		nitellacrypto.Wipe(pass2Bytes)
		fmt.Println("Passphrases do not match. Please try again.")
		return promptNewPassphrase()
	}
	match := true
	for i := range pass1Bytes {
		if pass1Bytes[i] != pass2Bytes[i] {
			match = false
			break
		}
	}
	nitellacrypto.Wipe(pass2Bytes) // Always wipe pass2

	if !match {
		nitellacrypto.Wipe(pass1Bytes)
		fmt.Println("Passphrases do not match. Please try again.")
		return promptNewPassphrase()
	}

	// Convert to string and wipe bytes
	result := string(pass1Bytes)
	nitellacrypto.Wipe(pass1Bytes)
	return result, nil
}

// cmdIdentity handles identity commands
func cmdIdentity(args []string) {
	if len(args) == 0 {
		fmt.Println("\nIdentity Information:")
		fmt.Printf("  Emoji Hash:   %s\n", cliIdentity.EmojiHash)
		fmt.Printf("  Fingerprint:  %s\n", cliIdentity.Fingerprint)
		fmt.Printf("  Data Dir:     %s\n", dataDir)
		fmt.Println()
		fmt.Println("Commands:")
		fmt.Println("  identity show-mnemonic  - Display recovery mnemonic (SENSITIVE)")
		fmt.Println("  identity export-ca      - Export Root CA certificate")
		fmt.Println()
		return
	}

	switch args[0] {
	case "show-mnemonic":
		fmt.Println()
		fmt.Println("WARNING: Your mnemonic phrase is sensitive. Do not share it!")
		fmt.Println()
		fmt.Printf("Mnemonic: %s\n", cliIdentity.Mnemonic)
		fmt.Println()

	case "export-ca":
		caPath := filepath.Join(dataDir, "root_ca.crt")
		fmt.Printf("Root CA Certificate: %s\n", caPath)
		fmt.Println()
		fmt.Println("Use this certificate to verify your identity when:")
		fmt.Println("  - Registering with Hub")
		fmt.Println("  - Pairing with nitellad nodes")
		fmt.Println()

	default:
		fmt.Printf("Unknown identity command: %s\n", args[0])
	}
}

// newHubCompletion creates tab completion for Hub mode
func newHubCompletion() *shell.SimpleCompletion {
	return &shell.SimpleCompletion{
		RootCommands: []string{
			"config", "login", "register", "status", "nodes", "node",
			"approvals", "approve", "deny", "templates", "proxy", "send",
			"identity", "help", "exit",
		},
		SubCommands: map[string][]string{
			"config":    {"set"},
			"node":      {"status", "rules", "metrics"},
			"templates": {"sync", "push"},
			"proxy":     {"import", "list", "show", "edit", "export", "delete", "validate", "push", "pull", "history", "diff", "flush", "apply", "status", "unapply"},
			"identity":  {"show-mnemonic", "export-ca"},
		},
	}
}

func printHubModeHelp() {
	fmt.Print(`
Nitella CLI - Hub Mode Commands:

Identity:
  identity                       - Show identity information
  identity show-mnemonic         - Display recovery mnemonic (SENSITIVE)
  identity export-ca             - Export Root CA certificate

Hub Connection:
  config                         - Show/set Hub configuration
  config set <key> <value>       - Set configuration (hub_address, token)
  login                          - Login to Hub (interactive)
  register                       - Register this CLI with Hub
  status                         - Show Hub connection status

Node Management:
  nodes                          - List registered nodes
  node <node_id>                 - Select a node for commands
  node <node_id> status          - Show node status
  node <node_id> rules           - List node rules
  node <node_id> metrics         - Stream node metrics

Approvals:
  approvals                      - List pending approvals
  approve <request_id>           - Approve a pending request
  deny <request_id>              - Deny a pending request

Templates:
  templates                      - List available templates
  templates sync <node_id>       - Sync templates to a node
  templates push <node_id> <id>  - Push template to node

Commands:
  send <node_id> <command>       - Send command to node (via Hub relay)

Other:
  help                           - Show this help
  exit                           - Exit shell

Local Mode:
  Use --local flag to connect directly to nitellad instead of Hub.
  Example: nitella --local --addr localhost:50051
`)
}

// newCompletion creates tab completion for local nitella commands.
func newCompletion() *shell.SimpleCompletion {
	return &shell.SimpleCompletion{
		RootCommands: []string{
			"status", "list", "ls", "proxy", "rule", "conn", "connections",
			"block", "allow", "stream", "metrics", "restart",
			"geoip", "lookup", "help", "exit",
		},
		SubCommands: map[string][]string{
			"proxy":       {"create", "delete", "enable", "disable", "update"},
			"rule":        {"list", "add", "remove"},
			"conn":        {"close", "closeall"},
			"connections": {"close", "closeall"},
			"geoip":       {"status", "config"},
			"config":      {"local", "remote", "set"},
			"add":         {"allow", "block"},
		},
	}
}

func handleCommand(input string) {
	parts := strings.Fields(input)
	if len(parts) == 0 {
		return
	}

	cmd := parts[0]
	args := parts[1:]

	switch cmd {
	case "help":
		printHelp()
	case "exit", "quit":
		os.Exit(0)
	case "status":
		cmdStatus(args)
	case "list", "ls":
		cmdListProxies()
	case "proxy":
		cmdProxy(args)
	case "rule":
		cmdRule(args)
	case "conn", "connections":
		cmdConnections(args)
	case "block":
		cmdBlockIP(args)
	case "allow":
		cmdAllowIP(args)
	case "stream":
		cmdStream()
	case "metrics":
		cmdMetrics(args)
	case "restart":
		cmdRestart()
	case "geoip":
		cmdGeoIP(args)
	case "lookup":
		cmdLookupIP(args)
	default:
		fmt.Printf("Unknown command: %s. Type 'help' for available commands.\n", cmd)
	}
}

func printHelp() {
	fmt.Print(`
Nitella CLI (Local Mode) Commands:
  status [proxy_id]            - Show proxy status
  list, ls                     - List all proxies

  proxy create <addr> <backend> [name]  - Create a new proxy
  proxy delete <proxy_id>      - Delete a proxy
  proxy enable <proxy_id>      - Enable a disabled proxy
  proxy disable <proxy_id>     - Disable a proxy (stops listening)
  proxy update <proxy_id> [options]    - Update proxy settings
    Options: --backend <addr>, --name <name>

  rule list <proxy_id>         - List rules for a proxy
  rule add <proxy_id> <action> <ip>  - Add a rule (action: allow/block)
  rule remove <proxy_id> <rule_id>   - Remove a rule

  conn [proxy_id]              - List active connections
  conn close <proxy_id> <conn_id>    - Close a connection
  conn closeall <proxy_id>     - Close all connections

  block <ip>                   - Quick block an IP (all proxies)
  allow <ip>                   - Quick allow an IP (all proxies)

  geoip status                 - Show GeoIP service status
  geoip config local <city_db> [isp_db]  - Configure local MaxMind DB
  geoip config remote <provider>         - Configure remote API provider
  lookup <ip>                  - Lookup GeoIP information for an IP

  stream                       - Stream connection events
  metrics [interval]           - Stream metrics (default: 1 second interval)
  restart                      - Restart all proxy listeners

  help                         - Show this help
  exit                         - Exit shell

Hub Mode (default):
  Run without --local flag to use Hub mode.
  Example: nitella
`)
}

func authCtx() context.Context {
	ctx := context.Background()
	if authToken != "" {
		ctx = metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+authToken)
	}
	return ctx
}

func cmdStatus(args []string) {
	proxyID := ""
	if len(args) > 0 {
		proxyID = args[0]
	}

	ctx, cancel := context.WithTimeout(authCtx(), 5*time.Second)
	defer cancel()

	if proxyID == "" {
		// List all proxies status
		resp, err := client.ListProxies(ctx, &pb.ListProxiesRequest{})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		if len(resp.Proxies) == 0 {
			fmt.Println("No proxies running.")
			return
		}
		fmt.Printf("\n%-36s  %-20s  %-8s  %-10s  %-10s\n", "ID", "Address", "Status", "Active", "Total")
		fmt.Println(strings.Repeat("-", 90))
		for _, p := range resp.Proxies {
			status := "stopped"
			if p.Running {
				status = "running"
			}
			fmt.Printf("%-36s  %-20s  %-8s  %-10d  %-10d\n",
				p.ProxyId, p.ListenAddr, status, p.ActiveConnections, p.TotalConnections)
		}
		fmt.Println()
	} else {
		resp, err := client.GetStatus(ctx, &pb.GetStatusRequest{ProxyId: proxyID})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		fmt.Printf("\nProxy Status: %s\n", proxyID)
		fmt.Printf("  Running:           %v\n", resp.Running)
		fmt.Printf("  Listen Address:    %s\n", resp.ListenAddr)
		fmt.Printf("  Default Backend:   %s\n", resp.DefaultBackend)
		fmt.Printf("  Active Connections: %d\n", resp.ActiveConnections)
		fmt.Printf("  Total Connections: %d\n", resp.TotalConnections)
		fmt.Printf("  Bytes In:          %d\n", resp.BytesIn)
		fmt.Printf("  Bytes Out:         %d\n", resp.BytesOut)
		fmt.Printf("  Uptime:            %ds\n", resp.UptimeSeconds)
		fmt.Println()
	}
}

func cmdListProxies() {
	cmdStatus(nil)
}

func cmdProxy(args []string) {
	if len(args) == 0 {
		fmt.Println("Usage: proxy <create|delete|enable|disable|update> ...")
		return
	}

	ctx, cancel := context.WithTimeout(authCtx(), 5*time.Second)
	defer cancel()

	switch args[0] {
	case "create":
		if len(args) < 3 {
			fmt.Println("Usage: proxy create <listen_addr> <backend_addr> [name]")
			return
		}
		name := "cli-proxy"
		if len(args) > 3 {
			name = args[3]
		}
		resp, err := client.CreateProxy(ctx, &pb.CreateProxyRequest{
			ListenAddr:     args[1],
			DefaultBackend: args[2],
			Name:           name,
		})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		if !resp.Success {
			fmt.Printf("Failed: %s\n", resp.ErrorMessage)
			return
		}
		fmt.Printf("Proxy created: %s\n", resp.ProxyId)

	case "delete":
		if len(args) < 2 {
			fmt.Println("Usage: proxy delete <proxy_id>")
			return
		}
		resp, err := client.DeleteProxy(ctx, &pb.DeleteProxyRequest{ProxyId: args[1]})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		if !resp.Success {
			fmt.Printf("Failed: %s\n", resp.ErrorMessage)
			return
		}
		fmt.Println("Proxy deleted.")

	case "enable":
		if len(args) < 2 {
			fmt.Println("Usage: proxy enable <proxy_id>")
			return
		}
		resp, err := client.EnableProxy(ctx, &pb.EnableProxyRequest{ProxyId: args[1]})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		if !resp.Success {
			fmt.Printf("Failed: %s\n", resp.ErrorMessage)
			return
		}
		fmt.Println("Proxy enabled.")

	case "disable":
		if len(args) < 2 {
			fmt.Println("Usage: proxy disable <proxy_id>")
			return
		}
		resp, err := client.DisableProxy(ctx, &pb.DisableProxyRequest{ProxyId: args[1]})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		if !resp.Success {
			fmt.Printf("Failed: %s\n", resp.ErrorMessage)
			return
		}
		fmt.Println("Proxy disabled.")

	case "update":
		if len(args) < 2 {
			fmt.Println("Usage: proxy update <proxy_id> [--backend <addr>] [--name <name>]")
			return
		}
		proxyID := args[1]
		req := &pb.UpdateProxyRequest{ProxyId: proxyID}

		// Parse optional flags
		for i := 2; i < len(args); i++ {
			switch args[i] {
			case "--backend":
				if i+1 < len(args) {
					req.DefaultBackend = args[i+1]
					i++
				}
			case "--name":
				if i+1 < len(args) {
					req.Name = args[i+1]
					i++
				}
			}
		}

		resp, err := client.UpdateProxy(ctx, req)
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		if !resp.Success {
			fmt.Printf("Failed: %s\n", resp.ErrorMessage)
			return
		}
		fmt.Println("Proxy updated.")

	default:
		fmt.Println("Usage: proxy <create|delete|enable|disable|update> ...")
	}
}

func cmdRule(args []string) {
	if len(args) == 0 {
		fmt.Println("Usage: rule <list|add|remove> ...")
		return
	}

	ctx, cancel := context.WithTimeout(authCtx(), 5*time.Second)
	defer cancel()

	switch args[0] {
	case "list":
		if len(args) < 2 {
			fmt.Println("Usage: rule list <proxy_id>")
			return
		}
		resp, err := client.ListRules(ctx, &pb.ListRulesRequest{ProxyId: args[1]})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		if len(resp.Rules) == 0 {
			fmt.Println("No rules configured.")
			return
		}
		fmt.Printf("\n%-36s  %-20s  %-8s  %-8s  %-8s\n", "ID", "Name", "Priority", "Action", "Enabled")
		fmt.Println(strings.Repeat("-", 90))
		for _, r := range resp.Rules {
			fmt.Printf("%-36s  %-20s  %-8d  %-8s  %-8v\n",
				r.Id, truncate(r.Name, 20), r.Priority, r.Action.String(), r.Enabled)
		}
		fmt.Println()

	case "add":
		if len(args) < 4 {
			fmt.Println("Usage: rule add <proxy_id> <allow|block> <ip>")
			return
		}
		proxyID := args[1]
		action := strings.ToLower(args[2])
		ip := args[3]

		var actionType pb.Rule
		switch action {
		case "allow":
			actionType.Action = 1 // ACTION_TYPE_ALLOW
		case "block":
			actionType.Action = 2 // ACTION_TYPE_BLOCK
		default:
			fmt.Println("Action must be 'allow' or 'block'")
			return
		}

		rule := &pb.Rule{
			Name:     fmt.Sprintf("CLI %s %s", action, ip),
			Priority: 100,
			Enabled:  true,
			Action:   actionType.Action,
			Conditions: []*pb.Condition{
				{
					Type:  1, // SOURCE_IP
					Op:    1, // EQ
					Value: ip,
				},
			},
		}

		resp, err := client.AddRule(ctx, &pb.AddRuleRequest{
			ProxyId: proxyID,
			Rule:    rule,
		})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		fmt.Printf("Rule added: %s\n", resp.Id)

	case "remove":
		if len(args) < 3 {
			fmt.Println("Usage: rule remove <proxy_id> <rule_id>")
			return
		}
		_, err := client.RemoveRule(ctx, &pb.RemoveRuleRequest{
			ProxyId: args[1],
			RuleId:  args[2],
		})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		fmt.Println("Rule removed.")

	default:
		fmt.Println("Usage: rule <list|add|remove> ...")
	}
}

func cmdConnections(args []string) {
	ctx, cancel := context.WithTimeout(authCtx(), 5*time.Second)
	defer cancel()

	if len(args) >= 1 {
		switch args[0] {
		case "close":
			if len(args) < 3 {
				fmt.Println("Usage: conn close <proxy_id> <conn_id>")
				return
			}
			resp, err := client.CloseConnection(ctx, &pb.CloseConnectionRequest{
				ProxyId: args[1],
				ConnId:  args[2],
			})
			if err != nil {
				fmt.Printf("Error: %v\n", err)
				return
			}
			if !resp.Success {
				fmt.Printf("Failed: %s\n", resp.ErrorMessage)
				return
			}
			fmt.Println("Connection closed.")
			return

		case "closeall":
			// closeall [proxy_id] - if no proxy_id, close all connections on all proxies
			proxyID := ""
			if len(args) >= 2 {
				proxyID = args[1]
			}

			if proxyID != "" {
				// Close all connections on specific proxy
				resp, err := client.CloseAllConnections(ctx, &pb.CloseAllConnectionsRequest{
					ProxyId: proxyID,
				})
				if err != nil {
					fmt.Printf("Error: %v\n", err)
					return
				}
				if !resp.Success {
					fmt.Printf("Failed: %s\n", resp.ErrorMessage)
					return
				}
				fmt.Println("All connections closed on proxy", proxyID)
			} else {
				// Close all connections on all proxies
				proxies, err := client.ListProxies(ctx, &pb.ListProxiesRequest{})
				if err != nil {
					fmt.Printf("Error listing proxies: %v\n", err)
					return
				}
				closed := 0
				for _, p := range proxies.Proxies {
					resp, err := client.CloseAllConnections(ctx, &pb.CloseAllConnectionsRequest{
						ProxyId: p.ProxyId,
					})
					if err == nil && resp.Success {
						closed++
					}
				}
				fmt.Printf("Closed all connections on %d proxies.\n", closed)
			}
			return
		}
	}

	// List connections
	proxyID := ""
	if len(args) > 0 {
		proxyID = args[0]
	}

	resp, err := client.GetActiveConnections(ctx, &pb.GetActiveConnectionsRequest{
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

	fmt.Printf("\n%-36s  %-15s  %-20s  %-10s  %-10s\n", "ID", "Source IP", "Destination", "Bytes In", "Bytes Out")
	fmt.Println(strings.Repeat("-", 100))
	for _, c := range resp.Connections {
		fmt.Printf("%-36s  %-15s  %-20s  %-10d  %-10d\n",
			c.Id, c.SourceIp, c.DestAddr, c.BytesIn, c.BytesOut)
	}
	fmt.Println()
}

func cmdBlockIP(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: block <ip>")
		return
	}

	ctx, cancel := context.WithTimeout(authCtx(), 5*time.Second)
	defer cancel()

	duration := int64(0)
	if len(args) > 1 {
		d, _ := strconv.ParseInt(args[1], 10, 64)
		duration = d
	}

	_, err := client.BlockIP(ctx, &pb.BlockIPRequest{
		Ip:              args[0],
		DurationSeconds: duration,
	})
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}
	fmt.Printf("IP %s blocked.\n", args[0])
}

func cmdAllowIP(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: allow <ip>")
		return
	}

	ctx, cancel := context.WithTimeout(authCtx(), 5*time.Second)
	defer cancel()

	duration := int64(0)
	if len(args) > 1 {
		d, _ := strconv.ParseInt(args[1], 10, 64)
		duration = d
	}

	_, err := client.AllowIP(ctx, &pb.AllowIPRequest{
		Ip:              args[0],
		DurationSeconds: duration,
	})
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}
	fmt.Printf("IP %s allowed.\n", args[0])
}

func cmdStream() {
	fmt.Println("Streaming connection events (Ctrl+C to stop)...")

	// Create cancellable context for Ctrl+C
	ctx, cancel := context.WithCancel(authCtx())
	defer cancel()

	// Handle Ctrl+C
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGINT)
	go func() {
		<-sigCh
		cancel()
	}()
	defer signal.Stop(sigCh)

	stream, err := client.StreamConnections(ctx, &pb.StreamConnectionsRequest{})
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	for {
		event, err := stream.Recv()
		if err != nil {
			if ctx.Err() != nil {
				fmt.Println("\nStopped.")
				return
			}
			fmt.Printf("Stream ended: %v\n", err)
			return
		}
		fmt.Printf("[%s] %s:%d -> %s | Action: %s\n",
			event.EventType.String(),
			event.SourceIp, event.SourcePort,
			event.TargetAddr,
			event.ActionTaken.String())
	}
}

func cmdMetrics(args []string) {
	interval := int32(1)
	if len(args) > 0 {
		if i, err := strconv.Atoi(args[0]); err == nil && i > 0 {
			interval = int32(i)
		}
	}

	fmt.Printf("Streaming metrics every %d second(s) (Ctrl+C to stop)...\n", interval)
	fmt.Printf("\n%-20s  %-12s  %-12s  %-15s  %-15s\n", "Timestamp", "Active", "Total", "Bytes In/s", "Bytes Out/s")
	fmt.Println(strings.Repeat("-", 80))

	// Create cancellable context for Ctrl+C
	ctx, cancel := context.WithCancel(authCtx())
	defer cancel()

	// Handle Ctrl+C
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGINT)
	go func() {
		<-sigCh
		cancel()
	}()
	defer signal.Stop(sigCh)

	stream, err := client.StreamMetrics(ctx, &pb.StreamMetricsRequest{IntervalSeconds: interval})
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	for {
		sample, err := stream.Recv()
		if err != nil {
			if ctx.Err() != nil {
				fmt.Println("\nStopped.")
				return
			}
			fmt.Printf("Stream ended: %v\n", err)
			return
		}
		ts := time.Unix(sample.Timestamp, 0).Format("2006-01-02 15:04:05")
		fmt.Printf("%-20s  %-12d  %-12d  %-15s  %-15s\n",
			ts,
			sample.ActiveConns,
			sample.TotalConns,
			formatBytes(sample.BytesInRate),
			formatBytes(sample.BytesOutRate))
	}
}

func cmdRestart() {
	ctx, cancel := context.WithTimeout(authCtx(), 30*time.Second)
	defer cancel()

	fmt.Println("Restarting all proxy listeners...")
	resp, err := client.RestartListeners(ctx, &emptypb.Empty{})
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}
	if !resp.Success {
		fmt.Printf("Failed: %s\n", resp.ErrorMessage)
		return
	}
	fmt.Printf("Restarted %d listeners.\n", resp.RestartedCount)
}

func formatBytes(b int64) string {
	const unit = 1024
	if b < unit {
		return fmt.Sprintf("%d B", b)
	}
	div, exp := int64(unit), 0
	for n := b / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %cB", float64(b)/float64(div), "KMGTPE"[exp])
}

func truncate(s string, maxLen int) string {
	if len(s) <= maxLen {
		return s
	}
	return s[:maxLen-3] + "..."
}

func cmdGeoIP(args []string) {
	if len(args) == 0 {
		fmt.Println("Usage: geoip <status|config> ...")
		return
	}

	ctx, cancel := context.WithTimeout(authCtx(), 5*time.Second)
	defer cancel()

	switch args[0] {
	case "status":
		resp, err := client.GetGeoIPStatus(ctx, &pb.GetGeoIPStatusRequest{})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		fmt.Println("\nGeoIP Status:")
		fmt.Printf("  Enabled:    %v\n", resp.Enabled)
		fmt.Printf("  Mode:       %s\n", resp.Mode)
		if resp.CityDbPath != "" {
			fmt.Printf("  City DB:    %s\n", resp.CityDbPath)
		}
		if resp.IspDbPath != "" {
			fmt.Printf("  ISP DB:     %s\n", resp.IspDbPath)
		}
		if resp.Provider != "" {
			fmt.Printf("  Provider:   %s\n", resp.Provider)
		}
		if len(resp.Strategy) > 0 {
			fmt.Printf("  Strategy:   %v\n", resp.Strategy)
		}
		fmt.Printf("  Cache Hits: %d\n", resp.CacheHits)
		fmt.Printf("  Cache Miss: %d\n", resp.CacheMisses)
		fmt.Println()

	case "config":
		if len(args) < 2 {
			fmt.Println("Usage: geoip config <local|remote> ...")
			return
		}

		switch args[1] {
		case "local":
			if len(args) < 3 {
				fmt.Println("Usage: geoip config local <city_db_path> [isp_db_path]")
				return
			}
			req := &pb.ConfigureGeoIPRequest{
				Mode:       pb.ConfigureGeoIPRequest_MODE_LOCAL_DB,
				CityDbPath: args[2],
			}
			if len(args) > 3 {
				req.IspDbPath = args[3]
			}
			resp, err := client.ConfigureGeoIP(ctx, req)
			if err != nil {
				fmt.Printf("Error: %v\n", err)
				return
			}
			if !resp.Success {
				fmt.Printf("Failed: %s\n", resp.Error)
				return
			}
			fmt.Println("GeoIP configured with local databases.")

		case "remote":
			if len(args) < 3 {
				fmt.Println("Usage: geoip config remote <provider_url> [api_key]")
				return
			}
			req := &pb.ConfigureGeoIPRequest{
				Mode:     pb.ConfigureGeoIPRequest_MODE_REMOTE_API,
				Provider: args[2],
			}
			if len(args) > 3 {
				req.ApiKey = args[3]
			}
			resp, err := client.ConfigureGeoIP(ctx, req)
			if err != nil {
				fmt.Printf("Error: %v\n", err)
				return
			}
			if !resp.Success {
				fmt.Printf("Failed: %s\n", resp.Error)
				return
			}
			fmt.Println("GeoIP configured with remote provider.")

		default:
			fmt.Println("Usage: geoip config <local|remote> ...")
		}

	default:
		fmt.Println("Usage: geoip <status|config> ...")
	}
}

func cmdLookupIP(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: lookup <ip>")
		return
	}

	ctx, cancel := context.WithTimeout(authCtx(), 10*time.Second)
	defer cancel()

	resp, err := client.LookupIP(ctx, &pb.LookupIPRequest{Ip: args[0]})
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	// Check if lookup actually returned data
	if resp.Geo == nil || (resp.Geo.Country == "" && resp.Geo.CountryCode == "") {
		fmt.Printf("\nGeoIP Lookup Failed: %s\n", args[0])
		fmt.Println("  No GeoIP data available.")
		fmt.Println("  Check GeoIP configuration with 'geoip status'")
		fmt.Println()
		return
	}

	fmt.Printf("\nGeoIP Lookup: %s\n", args[0])
	fmt.Printf("  Country:      %s (%s)\n", resp.Geo.Country, resp.Geo.CountryCode)
	if resp.Geo.City != "" {
		fmt.Printf("  City:         %s\n", resp.Geo.City)
	}
	if resp.Geo.Region != "" {
		fmt.Printf("  Region:       %s (%s)\n", resp.Geo.RegionName, resp.Geo.Region)
	}
	if resp.Geo.Timezone != "" {
		fmt.Printf("  Timezone:     %s\n", resp.Geo.Timezone)
	}
	if resp.Geo.Latitude != 0 || resp.Geo.Longitude != 0 {
		fmt.Printf("  Coordinates:  %.4f, %.4f\n", resp.Geo.Latitude, resp.Geo.Longitude)
	}
	if resp.Geo.Isp != "" {
		fmt.Printf("  ISP:          %s\n", resp.Geo.Isp)
	}
	if resp.Geo.Org != "" {
		fmt.Printf("  Organization: %s\n", resp.Geo.Org)
	}
	if resp.Geo.As != "" {
		fmt.Printf("  AS:           %s\n", resp.Geo.As)
	}
	fmt.Printf("  Lookup Time:  %dms\n", resp.LookupTimeMs)
	fmt.Printf("  Cached:       %v\n", resp.Cached)
	fmt.Println()
}
