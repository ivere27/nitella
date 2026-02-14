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

	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	pbLocal "github.com/ivere27/nitella/pkg/api/local"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/cli"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	nitellaPprof "github.com/ivere27/nitella/pkg/pprof"
	"github.com/ivere27/nitella/pkg/service"
	"github.com/ivere27/nitella/pkg/shell"
	"golang.org/x/term"
	"google.golang.org/grpc/metadata"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/fieldmaskpb"
)

var (
	serverAddr string
	authToken  string

	// Mode flags
	localMode bool // Connect to local nitellad instead of Hub

	// Identity (managed by backend)
	dataDir    string
	passphrase string // Passphrase for key encryption/decryption

	// Hub mode state
	hubCLI *HubCLI

	// MobileLogicService — same Synurang dispatch path as Flutter FFI
	svc          *service.MobileLogicService
	client       pbLocal.MobileLogicServiceClient
	identityInfo *pbLocal.IdentityInfo

	// Local mode state: node ID assigned by backend
	localNodeID string

	// Hub mode flags (set via flag.StringVar, consumed by NewHubCLI)
	hubAddress            string
	hubToken              string
	stunServer            string
	overrideBackendConfig bool
)

func main() {
	configureCLILogOutput()

	// Default data directory
	homeDir, _ := os.UserHomeDir()
	defaultDataDir := filepath.Join(homeDir, ".nitella")

	// Mode flags - Hub is default, --local for nitellad
	flag.BoolVar(&localMode, "local", false, "Connect to local nitellad instead of Hub")
	flag.StringVar(&dataDir, "data-dir", defaultDataDir, "Data directory for identity and configuration")
	flag.StringVar(&passphrase, "passphrase", os.Getenv("NITELLA_PASSPHRASE"), "Passphrase for key encryption (env: NITELLA_PASSPHRASE)")

	// Local mode flags (only used with --local)
	addr := flag.String("addr", "localhost:50051", "Local nitellad server address (with --local)")
	token := flag.String("token", os.Getenv("NITELLA_TOKEN"), "Authentication token for local nitellad (env: NITELLA_TOKEN)")
	tlsCA := flag.String("tls-ca", os.Getenv("NITELLA_TLS_CA"), "Path to nitellad CA certificate for TLS verification (env: NITELLA_TLS_CA)")

	// Hub mode flags
	flag.StringVar(&hubAddress, "hub", "", "Hub server address")
	flag.StringVar(&hubToken, "hub-token", os.Getenv("NITELLA_HUB_TOKEN"), "Hub authentication token (env: NITELLA_HUB_TOKEN)")
	flag.StringVar(&stunServer, "stun", "", "STUN server URL for P2P")
	flag.BoolVar(&overrideBackendConfig, "override-backend-config", false, "Allow --hub/--stun/NITELLA_HUB/NITELLA_STUN to override backend-stored settings for this run")

	// Profiling (only effective with -tags pprof)
	pprofPort := flag.Int("pprof-port", 0, "Port for pprof HTTP server (0 = disabled, requires -tags pprof build)")

	flag.Parse()
	nitellaPprof.Start(*pprofPort)

	// Initialize MobileLogicService (same Synurang dispatch path as Flutter FFI)
	svc = service.NewMobileLogicService()
	client = pbLocal.NewMobileLogicServiceClient(pbLocal.NewFfiClientConn(svc))
	initCtx := context.Background()
	initResp, err := client.Initialize(initCtx, &pbLocal.InitializeRequest{
		DataDir:  dataDir,
		CacheDir: filepath.Join(dataDir, "cache"),
	})
	if err != nil || !initResp.Success {
		errMsg := "unknown error"
		if err != nil {
			errMsg = err.Error()
		} else if initResp.Error != "" {
			errMsg = initResp.Error
		}
		fmt.Printf("Failed to initialize backend: %s\n", errMsg)
		os.Exit(1)
	}

	identityInfo, err = bootstrapIdentity(initCtx)
	if err != nil {
		fmt.Printf("Failed to initialize identity: %v\n", err)
		os.Exit(1)
	}

	// Initialize Hub CLI state
	hubCLI = NewHubCLI(hubAddress, hubToken, stunServer, overrideBackendConfig)

	// Check for command-line args (single command mode)
	args := flag.Args()

	if localMode {
		// Local mode: connect to nitellad via backend
		serverAddr = *addr
		authToken = *token

		if authToken == "" {
			fmt.Println("Warning: No token provided. Use --token or set NITELLA_TOKEN environment variable.")
		}

		if *tlsCA == "" {
			fmt.Println("Error: --tls-ca is required for local mode")
			fmt.Println("nitellad generates CA at: <admin-data-dir>/admin_ca.crt")
			fmt.Println("Example: nitella --local --tls-ca /path/to/admin_ca.crt")
			os.Exit(1)
		}

		caPEM, err := os.ReadFile(*tlsCA)
		if err != nil {
			fmt.Printf("Failed to read CA certificate: %v\n", err)
			os.Exit(1)
		}

		// Register the local nitellad as a direct node via the backend
		addResp, err := client.AddNodeDirect(context.Background(), &pbLocal.AddNodeDirectRequest{
			Name:    "local",
			Address: *addr,
			Token:   *token,
			CaPem:   string(caPEM),
		})
		if err != nil || !addResp.Success {
			errMsg := "unknown error"
			if err != nil {
				errMsg = err.Error()
			} else if addResp.Error != "" {
				errMsg = addResp.Error
			}
			fmt.Printf("Failed to connect to %s: %s\n", *addr, errMsg)
			os.Exit(1)
		}
		localNodeID = addResp.Node.NodeId

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
			hubCLI.handleHubCommand(args)
			return
		}

		// Interactive shell for Hub mode
		fmt.Println("Nitella CLI - Hub Mode")
		fmt.Printf("Identity: %s\n", identityInfo.EmojiHash)
		fmt.Printf("Fingerprint: %s\n", shortFingerprint(identityInfo.Fingerprint))
		fmt.Println()
		fmt.Println("Type 'help' for available commands, 'exit' to quit.")
		fmt.Println()

		// Start background alert streaming (will silently fail if not connected)
		hubCLI.startBackgroundAlertStream()

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
				hubCLI.Cleanup()
				os.Exit(0)
			case "identity":
				cmdIdentity(cmdArgs)
			default:
				// All other commands go to Hub handler
				hubCLI.handleHubCommand(parts)
			}
			return nil
		}, newHubCompletion())
	}
}

// bootstrapIdentity ensures an identity exists and is unlocked via MobileLogicService RPCs.
func bootstrapIdentity(ctx context.Context) (*pbLocal.IdentityInfo, error) {
	bootstrap, err := client.GetBootstrapState(ctx, &emptypb.Empty{})
	if err != nil {
		return nil, fmt.Errorf("failed to get bootstrap state: %w", err)
	}
	if bootstrap == nil {
		return nil, fmt.Errorf("missing bootstrap state")
	}

	// Create identity if missing.
	if !bootstrap.IdentityExists {
		createPassphrase := passphrase
		isTerminal := term.IsTerminal(int(syscall.Stdin))
		if createPassphrase == "" && isTerminal && !passphraseExplicitlySet() {
			newPassphrase, err := promptNewPassphrase()
			if err != nil {
				return nil, err
			}
			createPassphrase = newPassphrase
		} else if createPassphrase != "" {
			showPassphraseStrength(createPassphrase, false)
		}

		createResp, err := client.CreateIdentity(ctx, &pbLocal.CreateIdentityRequest{
			Passphrase:          createPassphrase,
			CommonName:          "nitella-cli",
			AllowWeakPassphrase: shouldAllowWeakPassphrase(createPassphrase),
		})
		if err != nil {
			return nil, fmt.Errorf("failed to create identity: %w", err)
		}
		if !createResp.Success {
			errMsg := createResp.Error
			if errMsg == "" {
				errMsg = "unknown error"
			}
			return nil, fmt.Errorf("failed to create identity: %s", errMsg)
		}

		printCreatedIdentity(createResp.Mnemonic, createResp.Identity, createPassphrase != "")

		if createResp.Identity != nil && !createResp.Identity.Locked {
			return createResp.Identity, nil
		}

		bootstrap, err = client.GetBootstrapState(ctx, &emptypb.Empty{})
		if err != nil {
			return nil, fmt.Errorf("failed to refresh bootstrap state: %w", err)
		}
		if bootstrap == nil {
			return nil, fmt.Errorf("missing bootstrap state")
		}
	}

	// Unlock encrypted identity if needed.
	if bootstrap.IdentityLocked {
		unlockPassphrase := passphrase
		if unlockPassphrase == "" {
			if !term.IsTerminal(int(syscall.Stdin)) {
				return nil, fmt.Errorf("passphrase required for encrypted key (set NITELLA_PASSPHRASE or use --passphrase)")
			}

			fmt.Print("Enter passphrase: ")
			passphraseBytes, err := term.ReadPassword(int(syscall.Stdin))
			fmt.Println()
			if err != nil {
				return nil, fmt.Errorf("failed to read passphrase: %w", err)
			}
			unlockPassphrase = string(passphraseBytes)
			nitellacrypto.Wipe(passphraseBytes)
		}

		unlockResp, err := client.UnlockIdentity(ctx, &pbLocal.UnlockIdentityRequest{
			Passphrase: unlockPassphrase,
		})
		if err != nil {
			return nil, fmt.Errorf("failed to unlock identity: %w", err)
		}
		if !unlockResp.Success {
			errMsg := unlockResp.Error
			if errMsg == "" {
				errMsg = "unknown error"
			}
			return nil, fmt.Errorf("failed to unlock identity: %s", errMsg)
		}
		if unlockResp.Identity != nil {
			return unlockResp.Identity, nil
		}
	}

	return fetchIdentityInfo(ctx)
}

func fetchIdentityInfo(ctx context.Context) (*pbLocal.IdentityInfo, error) {
	info, err := client.GetIdentity(ctx, &emptypb.Empty{})
	if err != nil {
		return nil, err
	}
	if info == nil {
		return nil, fmt.Errorf("identity info is empty")
	}
	if !info.Exists {
		return nil, fmt.Errorf("identity does not exist")
	}
	if info.Locked {
		return nil, fmt.Errorf("identity is locked")
	}
	return info, nil
}

func printCreatedIdentity(mnemonic string, info *pbLocal.IdentityInfo, encrypted bool) {
	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════════╗")
	fmt.Println("║                    NITELLA IDENTITY CREATED                     ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════════╝")
	fmt.Println()
	fmt.Println("Your identity has been created with a BIP-39 mnemonic phrase.")
	fmt.Println("IMPORTANT: Write down and securely store this mnemonic!")
	fmt.Println()
	fmt.Println("┌──────────────────────────────────────────────────────────────────┐")
	fmt.Printf("│ Mnemonic: %-55s │\n", mnemonic)
	fmt.Println("└──────────────────────────────────────────────────────────────────┘")
	fmt.Println()
	if info != nil {
		fmt.Printf("Emoji Hash:   %s\n", info.EmojiHash)
		fmt.Printf("Fingerprint:  %s\n", info.Fingerprint)
	}
	fmt.Println()
	fmt.Println("The emoji hash provides visual verification of your identity.")
	fmt.Println("When pairing with Hub, verify the emoji hash matches on both ends.")
	fmt.Println()
	if encrypted {
		fmt.Println("Private key encrypted with passphrase.")
	} else {
		fmt.Println("Private key is NOT encrypted (no passphrase set).")
	}
	fmt.Printf("Identity saved to: %s\n", dataDir)
	fmt.Println()
}

// showPassphraseStrength displays passphrase strength analysis
func showPassphraseStrength(pass string, interactive bool) bool {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	check, err := client.EvaluatePassphrase(ctx, &pbLocal.EvaluatePassphraseRequest{
		Passphrase: pass,
	})
	if err != nil {
		fmt.Printf("Warning: unable to evaluate passphrase policy: %v\n", err)
		return true
	}

	fmt.Println()
	fmt.Println("Passphrase Security Analysis:")
	if strings.TrimSpace(check.Report) != "" {
		fmt.Println(check.Report)
	} else {
		fmt.Printf("Strength: %s\n", formatPassphraseStrength(check.GetStrength()))
		fmt.Printf("Entropy: %.1f bits\n", check.GetEntropy())
		if check.GetMessage() != "" {
			fmt.Printf("Assessment: %s\n", check.GetMessage())
		}
	}
	fmt.Println()

	if check.GetShouldWarn() && interactive {
		fmt.Print("Continue with weak passphrase? (y/N): ")
		reader := bufio.NewReader(os.Stdin)
		response, _ := reader.ReadString('\n')
		response = strings.TrimSpace(strings.ToLower(response))
		return response == "y" || response == "yes"
	}

	return true // Non-interactive: just warn, don't block
}

func formatPassphraseStrength(str pbLocal.PassphraseStrength) string {
	switch str {
	case pbLocal.PassphraseStrength_PASSPHRASE_STRENGTH_WEAK:
		return "weak"
	case pbLocal.PassphraseStrength_PASSPHRASE_STRENGTH_FAIR:
		return "fair"
	case pbLocal.PassphraseStrength_PASSPHRASE_STRENGTH_STRONG:
		return "strong"
	default:
		return "unknown"
	}
}

func shouldAllowWeakPassphrase(passphrase string) bool {
	if strings.TrimSpace(passphrase) == "" {
		return false
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	check, err := client.EvaluatePassphrase(ctx, &pbLocal.EvaluatePassphraseRequest{
		Passphrase: passphrase,
	})
	if err != nil {
		// Fail-open for acknowledgment flag so backend policy does not reject
		// when local evaluation RPC is temporarily unavailable.
		return true
	}
	return check.GetShouldWarn()
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
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	info, err := client.GetIdentity(ctx, &emptypb.Empty{})
	if err != nil {
		fmt.Printf("Error reading identity: %v\n", err)
		return
	}
	if info == nil || !info.Exists {
		fmt.Println("No identity found.")
		return
	}

	if len(args) == 0 {
		fmt.Println("\nIdentity Information:")
		if info.Locked {
			fmt.Println("  Status:       locked")
		} else {
			fmt.Printf("  Emoji Hash:   %s\n", info.EmojiHash)
			fmt.Printf("  Fingerprint:  %s\n", info.Fingerprint)
		}
		fmt.Printf("  Data Dir:     %s\n", dataDir)
		fmt.Println()
		fmt.Println("Commands:")
		fmt.Println("  identity export-ca      - Export Root CA certificate")
		fmt.Println()
		return
	}

	switch args[0] {
	case "export-ca":
		if info.Locked {
			fmt.Println("Identity is locked. Restart with --passphrase (or NITELLA_PASSPHRASE) to unlock before export.")
			return
		}
		if info.RootCertPem == "" {
			fmt.Println("Root CA certificate is not available from backend.")
			return
		}

		caPath := filepath.Join(dataDir, "root_ca.crt")
		if err := os.WriteFile(caPath, []byte(info.RootCertPem), 0644); err != nil {
			fmt.Printf("Failed to export Root CA certificate: %v\n", err)
			return
		}
		fmt.Printf("Root CA Certificate exported: %s\n", caPath)
		fmt.Println()
		fmt.Println("Use this certificate to verify your identity when:")
		fmt.Println("  - Registering with Hub")
		fmt.Println("  - Pairing with nitellad nodes")
		fmt.Println()

	default:
		fmt.Printf("Unknown identity command: %s\n", args[0])
	}
}

func shortFingerprint(fp string) string {
	if len(fp) <= 16 {
		return fp
	}
	return fp[:8] + "..." + fp[len(fp)-8:]
}

// newHubCompletion creates tab completion for Hub mode
func newHubCompletion() *shell.SimpleCompletion {
	return &shell.SimpleCompletion{
		RootCommands: []string{
			"config", "login", "register", "status", "nodes", "node",
			"alerts", "pending", "approve", "deny", "templates", "proxy",
			"identity", "pair", "debug", "help", "exit",
		},
		SubCommands: map[string][]string{
			"config":    {"set"},
			"node":      {"status", "rules", "metrics"},
			"templates": {"sync", "push"},
			"proxy":     {"import", "list", "show", "edit", "export", "delete", "validate", "push", "pull", "history", "diff", "flush", "apply", "status", "unapply"},
			"identity":  {"export-ca"},
			"debug":     {"runtime", "grpc", "goroutine"},
		},
	}
}

func printHubModeHelp() {
	fmt.Print(`
Nitella CLI - Hub Mode Commands:

Identity:
  identity                       - Show identity information
  identity export-ca             - Export Root CA certificate

Hub Connection:
  config                         - Show/set Hub configuration
  config set <key> <value>       - Set configuration (hub_address, token)
  login                          - Login to Hub (interactive)
  register [invite_code]         - Register this CLI with Hub using mTLS
  status                         - Show Hub connection status

Node Pairing (PAKE - Hub learns nothing):
  pair                           - Start pairing session, generate code
  pair-offline                   - Offline QR code pairing mode

Node Management:
  nodes                          - List registered nodes
  node <node_id>                 - Select a node for commands
  node <node_id> status          - Show node status
  node <node_id> rules           - List node rules
  node <node_id> metrics         - Stream node metrics

Alerts & Approvals (auto-streaming in background):
  alerts                         - Start manual alert streaming (foreground)
  pending                        - List pending approval requests
  approve [once|cache] <id> [duration] - Approve request
  deny [once|cache] <id> [duration] [reason] - Deny a pending request

Templates:
  templates                      - List available templates
  templates sync <node_id>       - Sync templates to a node
  templates push <node_id> <id>  - Push template to node

Debug:
  debug [runtime|grpc|goroutine] - Show local backend debug stats

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
			"block", "allow", "global-rules", "approvals", "stream", "metrics", "debug", "restart",
			"geoip", "lookup", "help", "exit",
		},
		SubCommands: map[string][]string{
			"proxy":        {"create", "delete", "enable", "disable", "update"},
			"rule":         {"list", "add", "remove"},
			"conn":         {"close", "closeall"},
			"connections":  {"close", "closeall"},
			"debug":        {"runtime", "grpc", "goroutine"},
			"geoip":        {"status", "config"},
			"config":       {"local", "remote", "set"},
			"add":          {"allow", "block"},
			"global-rules": {"list", "remove"},
			"approvals":    {"list", "cancel"},
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
	case "global-rules":
		cmdGlobalRules(args)
	case "approvals":
		cmdApprovals(args)
	case "stream":
		cmdStream()
	case "metrics":
		cmdMetrics(args)
	case "debug":
		cmdDebug(args)
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

  block <ip> [duration_seconds]  - Quick block an IP (all proxies)
  allow <ip> [duration_seconds]  - Quick allow an IP (all proxies)
  global-rules                   - List all global rules
  global-rules remove <rule_id>  - Remove a global rule
  Note: Global ALLOW prevents blocking but does NOT bypass REQUIRE_APPROVAL.
        Use per-proxy rules with action=allow to fully whitelist an IP.

  approvals                      - List active approvals
  approvals cancel <key> [-c]    - Cancel approval (-c to close connections)

  geoip status                 - Show GeoIP service status
  geoip config local <city_db> [isp_db]  - Configure local MaxMind DB
  geoip config remote <provider>         - Configure remote API provider
  lookup <ip>                  - Lookup GeoIP information for an IP

  stream                       - Stream connection events
  metrics [interval]           - Stream metrics (default: 1 second interval)
  debug [runtime|grpc|goroutine] - Show local backend debug stats
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

// authAPICtx returns a context with authentication and the default API timeout.
func authAPICtx() (context.Context, context.CancelFunc) {
	return context.WithTimeout(authCtx(), cli.DefaultAPITimeout)
}

func cmdStatus(args []string) {
	proxyID := ""
	if len(args) > 0 {
		proxyID = args[0]
	}

	ctx, cancel := authAPICtx()
	defer cancel()

	snapshot, err := client.GetProxiesSnapshot(ctx, &pbLocal.GetProxiesSnapshotRequest{
		NodeId: localNodeID,
	})
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}
	if len(snapshot.NodeSnapshots) == 0 {
		fmt.Println("No proxies running.")
		return
	}
	resp := &pbLocal.ListProxiesResponse{Proxies: snapshot.NodeSnapshots[0].Proxies}

	if proxyID == "" {
		// List all proxies status
		if len(resp.Proxies) == 0 {
			fmt.Println("No proxies running.")
			return
		}
		tbl := cli.NewTable(
			cli.Column{Header: "ID", Width: 36},
			cli.Column{Header: "Address", Width: 20},
			cli.Column{Header: "Status", Width: 8},
			cli.Column{Header: "Active", Width: 10},
			cli.Column{Header: "Total", Width: 10},
		)
		tbl.PrintHeader()
		for _, p := range resp.Proxies {
			status := "stopped"
			if p.Running {
				status = "running"
			}
			tbl.PrintRow(p.ProxyId, p.ListenAddr, status, p.ActiveConnections, p.TotalConnections)
		}
		tbl.PrintFooter()
	} else {
		var found *pbLocal.ProxyInfo
		for _, p := range resp.Proxies {
			if p.ProxyId == proxyID {
				found = p
				break
			}
		}
		if found == nil {
			fmt.Printf("Proxy not found: %s\n", proxyID)
			return
		}
		fmt.Printf("\nProxy Status: %s\n", proxyID)
		fmt.Printf("  Running:           %v\n", found.Running)
		fmt.Printf("  Listen Address:    %s\n", found.ListenAddr)
		fmt.Printf("  Default Backend:   %s\n", found.DefaultBackend)
		fmt.Printf("  Active Connections: %d\n", found.ActiveConnections)
		fmt.Printf("  Total Connections: %d\n", found.TotalConnections)
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

	ctx, cancel := authAPICtx()
	defer cancel()

	switch args[0] {
	case "create":
		if !cli.RequireArgs(args, 3, "Usage: proxy create <listen_addr> <backend_addr> [name]") {
			return
		}
		name := "cli-proxy"
		if len(args) > 3 {
			name = args[3]
		}
		resp, err := client.AddProxy(ctx, &pbLocal.AddProxyRequest{
			NodeId:         localNodeID,
			ListenAddr:     args[1],
			DefaultBackend: args[2],
			Name:           name,
		})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		fmt.Printf("Proxy created: %s\n", resp.ProxyId)

	case "delete":
		if !cli.RequireArgs(args, 2, "Usage: proxy delete <proxy_id>") {
			return
		}
		if _, err := client.RemoveProxy(ctx, &pbLocal.RemoveProxyRequest{
			NodeId:  localNodeID,
			ProxyId: args[1],
		}); err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		fmt.Println("Proxy deleted.")

	case "enable":
		if !cli.RequireArgs(args, 2, "Usage: proxy enable <proxy_id>") {
			return
		}
		if _, err := client.UpdateProxy(ctx, &pbLocal.UpdateProxyRequest{
			NodeId:     localNodeID,
			ProxyId:    args[1],
			Running:    true,
			UpdateMask: &fieldmaskpb.FieldMask{Paths: []string{"running"}},
		}); err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		fmt.Println("Proxy enabled.")

	case "disable":
		if !cli.RequireArgs(args, 2, "Usage: proxy disable <proxy_id>") {
			return
		}
		if _, err := client.UpdateProxy(ctx, &pbLocal.UpdateProxyRequest{
			NodeId:     localNodeID,
			ProxyId:    args[1],
			Running:    false,
			UpdateMask: &fieldmaskpb.FieldMask{Paths: []string{"running"}},
		}); err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		fmt.Println("Proxy disabled.")

	case "update":
		if !cli.RequireArgs(args, 2, "Usage: proxy update <proxy_id> [--backend <addr>] [--name <name>]") {
			return
		}
		proxyID := args[1]
		req := &pbLocal.UpdateProxyRequest{
			NodeId:  localNodeID,
			ProxyId: proxyID,
		}
		paths := make([]string, 0, 2)

		// Parse optional flags
		for i := 2; i < len(args); i++ {
			switch args[i] {
			case "--backend":
				if i+1 < len(args) {
					req.DefaultBackend = args[i+1]
					paths = append(paths, "default_backend")
					i++
				}
			case "--name":
				if i+1 < len(args) {
					req.Name = args[i+1]
					paths = append(paths, "name")
					i++
				}
			}
		}
		if len(paths) > 0 {
			req.UpdateMask = &fieldmaskpb.FieldMask{Paths: paths}
		}

		if _, err := client.UpdateProxy(ctx, req); err != nil {
			fmt.Printf("Error: %v\n", err)
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

	ctx, cancel := authAPICtx()
	defer cancel()

	switch args[0] {
	case "list":
		if !cli.RequireArgs(args, 2, "Usage: rule list <proxy_id>") {
			return
		}
		resp, err := client.ListRules(ctx, &pbLocal.ListRulesRequest{
			NodeId:  localNodeID,
			ProxyId: args[1],
		})
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
		if !cli.RequireArgs(args, 4, "Usage: rule add <proxy_id> <allow|block> <ip>") {
			return
		}
		proxyID := args[1]
		action := strings.ToLower(args[2])
		ip := args[3]

		var actionLabel string
		var actionErr string
		switch action {
		case "allow":
			actionLabel = "Allow"
			resp, err := client.AllowIP(ctx, &pbLocal.AllowIPRequest{
				NodeId:  localNodeID,
				ProxyId: proxyID,
				Ip:      ip,
			})
			if err != nil {
				fmt.Printf("Error: %v\n", err)
				return
			}
			if !resp.Success {
				actionErr = resp.Error
			}
		case "block":
			actionLabel = "Block"
			resp, err := client.BlockIP(ctx, &pbLocal.BlockIPRequest{
				NodeId:  localNodeID,
				ProxyId: proxyID,
				Ip:      ip,
			})
			if err != nil {
				fmt.Printf("Error: %v\n", err)
				return
			}
			if !resp.Success {
				actionErr = resp.Error
			}
		default:
			fmt.Println("Action must be 'allow' or 'block'")
			return
		}

		if actionErr != "" {
			fmt.Printf("Error: %s\n", actionErr)
			return
		}
		fmt.Printf("%s rule created for %s on proxy %s.\n", actionLabel, ip, proxyID)

	case "remove":
		if !cli.RequireArgs(args, 3, "Usage: rule remove <proxy_id> <rule_id>") {
			return
		}
		if _, err := client.RemoveRule(ctx, &pbLocal.RemoveRuleRequest{
			NodeId:  localNodeID,
			ProxyId: args[1],
			RuleId:  args[2],
		}); err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		fmt.Println("Rule removed.")

	default:
		fmt.Println("Usage: rule <list|add|remove> ...")
	}
}

func cmdConnections(args []string) {
	ctx, cancel := authAPICtx()
	defer cancel()

	if len(args) >= 1 {
		switch args[0] {
		case "close":
			if !cli.RequireArgs(args, 3, "Usage: conn close <proxy_id> <conn_id>") {
				return
			}
			resp, err := client.CloseConnection(ctx, &pbLocal.CloseConnectionRequest{
				NodeId:  localNodeID,
				ProxyId: args[1],
				Identifier: &pbLocal.CloseConnectionRequest_ConnId{
					ConnId: args[2],
				},
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
			return

		case "closeall":
			// closeall [proxy_id] - if no proxy_id, backend closes all node connections
			proxyID := ""
			if len(args) >= 2 {
				proxyID = args[1]
			}

			resp, err := client.CloseAllConnections(ctx, &pbLocal.CloseAllConnectionsRequest{
				NodeId:  localNodeID,
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
				fmt.Println("All connections closed on proxy", proxyID)
			} else {
				fmt.Println("All connections closed.")
			}
			return
		}
	}

	// List connections
	proxyID := ""
	if len(args) > 0 {
		proxyID = args[0]
	}

	resp, err := client.ListConnections(ctx, &pbLocal.ListConnectionsRequest{
		NodeId:     localNodeID,
		ProxyId:    proxyID,
		ActiveOnly: true,
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
			c.ConnId, c.SourceIp, c.DestAddr, c.BytesIn, c.BytesOut)
	}
	fmt.Println()
}

// cmdIPAction handles both block and allow IP actions.
func cmdIPAction(args []string, action string) {
	usage := fmt.Sprintf("Usage: %s <ip> [duration_seconds]", action)
	if !cli.RequireArgs(args, 1, usage) {
		return
	}

	duration := int32(0)
	if len(args) >= 2 {
		seconds, err := strconv.Atoi(args[1])
		if err != nil || seconds < 0 {
			fmt.Println("Duration must be a non-negative integer")
			return
		}
		duration = int32(seconds)
	}

	var actionType pbCommon.ActionType
	var actionPast string
	switch action {
	case "block":
		actionType = pbCommon.ActionType_ACTION_TYPE_BLOCK
		actionPast = "blocked"
	case "allow":
		actionType = pbCommon.ActionType_ACTION_TYPE_ALLOW
		actionPast = "allowed"
	default:
		fmt.Printf("Unsupported IP action: %s\n", action)
		return
	}

	ctx, cancel := authAPICtx()
	defer cancel()

	ip := args[0]

	if duration > 0 {
		resp, err := client.AddQuickRule(ctx, &pbLocal.AddQuickRuleRequest{
			NodeId:          localNodeID,
			Action:          actionType,
			ConditionType:   pbCommon.ConditionType_CONDITION_TYPE_SOURCE_IP,
			Value:           ip,
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
		fmt.Printf("IP %s %s for %ds.\n", ip, actionPast, duration)
		return
	}

	switch action {
	case "block":
		resp, err := client.BlockIP(ctx, &pbLocal.BlockIPRequest{
			NodeId: localNodeID,
			Ip:     ip,
		})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		if !resp.Success {
			fmt.Printf("Error: %s\n", resp.Error)
			return
		}
	case "allow":
		resp, err := client.AllowIP(ctx, &pbLocal.AllowIPRequest{
			NodeId: localNodeID,
			Ip:     ip,
		})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		if !resp.Success {
			fmt.Printf("Error: %s\n", resp.Error)
			return
		}
	default:
		fmt.Printf("Unsupported IP action: %s\n", action)
		return
	}

	fmt.Printf("IP %s %s.\n", ip, actionPast)
}

func cmdBlockIP(args []string) { cmdIPAction(args, "block") }
func cmdAllowIP(args []string) { cmdIPAction(args, "allow") }

func cmdGlobalRules(args []string) {
	if len(args) == 0 {
		// List all global rules
		ctx, cancel := authAPICtx()
		defer cancel()

		resp, err := client.ListGlobalRules(ctx, &pbLocal.ListGlobalRulesRequest{NodeId: localNodeID})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}

		if len(resp.Rules) == 0 {
			fmt.Println("No global rules configured.")
			return
		}

		// Calculate dynamic column widths
		widths := []int{2, 4, 9, 6, 7} // minimum: "ID", "Name", "Source IP", "Action", "Expires"
		type row struct {
			id, name, sourceIP, action, expires string
		}
		rows := make([]row, len(resp.Rules))

		for i, r := range resp.Rules {
			expires := "permanent"
			if r.ExpiresAt != nil && !r.ExpiresAt.AsTime().IsZero() {
				expires = r.ExpiresAt.AsTime().Format("2006-01-02 15:04:05")
			}
			rows[i] = row{r.Id, r.Name, r.SourceIp, r.Action.String(), expires}

			if len(r.Id) > widths[0] {
				widths[0] = len(r.Id)
			}
			if len(r.Name) > widths[1] {
				widths[1] = len(r.Name)
			}
			if len(r.SourceIp) > widths[2] {
				widths[2] = len(r.SourceIp)
			}
			if len(rows[i].action) > widths[3] {
				widths[3] = len(rows[i].action)
			}
			if len(expires) > widths[4] {
				widths[4] = len(expires)
			}
		}

		// Print header
		fmt.Println()
		fmt.Printf("%-*s  %-*s  %-*s  %-*s  %-*s\n",
			widths[0], "ID", widths[1], "Name", widths[2], "Source IP", widths[3], "Action", widths[4], "Expires")
		totalWidth := widths[0] + widths[1] + widths[2] + widths[3] + widths[4] + 8 // 8 for spacing
		fmt.Println(strings.Repeat("-", totalWidth))

		// Print rows
		for _, r := range rows {
			fmt.Printf("%-*s  %-*s  %-*s  %-*s  %-*s\n",
				widths[0], r.id, widths[1], r.name, widths[2], r.sourceIP, widths[3], r.action, widths[4], r.expires)
		}
		fmt.Println()
		return
	}

	switch args[0] {
	case "list":
		cmdGlobalRules(nil) // Call with no args to list

	case "remove":
		if !cli.RequireArgs(args, 2, "Usage: global-rules remove <rule_id>") {
			return
		}
		ctx, cancel := authAPICtx()
		defer cancel()

		resp, err := client.RemoveGlobalRule(ctx, &pbLocal.RemoveGlobalRuleRequest{
			NodeId: localNodeID,
			RuleId: args[1],
		})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		if !resp.Success {
			fmt.Printf("Error: %s\n", resp.Error)
			return
		}
		fmt.Printf("Global rule %s removed.\n", args[1])

	default:
		fmt.Println("Usage: global-rules [list|remove <rule_id>]")
	}
}

func cmdApprovals(args []string) {
	if len(args) == 0 {
		// List all pending approvals
		ctx, cancel := authAPICtx()
		defer cancel()

		resp, err := client.GetApprovalsSnapshot(ctx, &pbLocal.GetApprovalsSnapshotRequest{
			NodeId:         localNodeID,
			IncludeHistory: false,
		})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}

		if len(resp.PendingRequests) == 0 {
			fmt.Println("No pending approvals.")
			return
		}

		fmt.Printf("\nPending Approvals (%d):\n", len(resp.PendingRequests))
		fmt.Println(strings.Repeat("-", 100))
		for _, a := range resp.PendingRequests {
			timestamp := "unknown"
			if a.Timestamp != nil {
				timestamp = a.Timestamp.AsTime().Format("2006-01-02 15:04:05")
			}
			fmt.Printf("%-50s  %s -> %s  %s\n", a.RequestId, a.SourceIp, a.DestAddr, timestamp)
			if a.Geo != nil {
				fmt.Printf("  Geo: %s, %s (%s)\n", a.Geo.City, a.Geo.Country, a.Geo.Isp)
			}
			if a.ProxyId != "" {
				fmt.Printf("  Proxy: %s\n", a.ProxyId)
			}
		}
		fmt.Println()
		return
	}

	switch args[0] {
	case "list":
		cmdApprovals(nil) // Call with no args to list

	case "cancel":
		if !cli.RequireArgs(args, 2, "Usage: approvals cancel <key> [--close-connections]") {
			return
		}
		closeConns := false
		if len(args) > 2 && (args[2] == "--close-connections" || args[2] == "-c") {
			closeConns = true
		}

		ctx, cancel := authAPICtx()
		defer cancel()

		resp, err := client.ResolveApprovalDecision(ctx, &pbLocal.ResolveApprovalDecisionRequest{
			RequestId:     args[1],
			Decision:      pbLocal.ApprovalDecision_APPROVAL_DECISION_DENY,
			RetentionMode: pbCommon.ApprovalRetentionMode_APPROVAL_RETENTION_MODE_CONNECTION_ONLY,
			DenyBlockType: pbLocal.DenyBlockType_DENY_BLOCK_TYPE_NONE,
		})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}
		if !resp.Success {
			fmt.Printf("Error: %s\n", resp.Error)
			return
		}
		if closeConns {
			fmt.Println("Warning: --close-connections is not supported in typed API; request was denied only.")
		}
		fmt.Println("Approval denied.")

	default:
		fmt.Println("Usage: approvals [list|cancel <key> [--close-connections]]")
	}
}

func cmdStream() {
	fmt.Println("Streaming connection events (Ctrl+C to stop)...")

	// Create cancellable context for Ctrl+C
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Handle Ctrl+C
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGINT)
	go func() {
		<-sigCh
		cancel()
	}()
	defer signal.Stop(sigCh)

	stream, err := client.StreamConnections(ctx, &pbLocal.StreamConnectionsRequest{
		NodeId: localNodeID,
	})
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
			event.DestAddr,
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
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Handle Ctrl+C
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGINT)
	go func() {
		<-sigCh
		cancel()
	}()
	defer signal.Stop(sigCh)

	stream, err := client.StreamMetrics(ctx, &pbLocal.StreamMetricsRequest{
		NodeId:          localNodeID,
		IntervalSeconds: interval,
	})
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	for {
		metrics, err := stream.Recv()
		if err != nil {
			if ctx.Err() != nil {
				fmt.Println("\nStopped.")
				return
			}
			fmt.Printf("Stream ended: %v\n", err)
			return
		}
		ts := time.Now().Format("2006-01-02 15:04:05")
		fmt.Printf("%-20s  %-12d  %-12d  %-15s  %-15s\n",
			ts,
			metrics.ActiveConnections,
			metrics.TotalConnections,
			formatBytes(metrics.BytesIn),
			formatBytes(metrics.BytesOut))
	}
}

func cmdDebug(args []string) {
	subcmd := "runtime"
	if len(args) > 0 {
		subcmd = strings.ToLower(args[0])
	}

	switch subcmd {
	case "runtime":
		ctx, cancel := authAPICtx()
		defer cancel()

		stats, err := client.GetDebugRuntimeStats(ctx, &pbLocal.GetDebugRuntimeStatsRequest{})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}

		uptime := time.Duration(stats.UptimeSeconds) * time.Second
		rssText := "unavailable"
		if stats.RssBytes > 0 {
			rssText = fmt.Sprintf("%s (%d bytes)", formatBytes(stats.RssBytes), stats.RssBytes)
		}

		fmt.Println("\nDebug Runtime (MobileLogicService):")
		fmt.Printf("  Uptime:                 %s\n", uptime)
		fmt.Printf("  RSS:                    %s\n", rssText)
		fmt.Printf("  Go Goroutines:          %d\n", stats.GoGoroutines)
		fmt.Printf("  Go Cgo Calls:           %d\n", stats.GoCgoCalls)
		fmt.Printf("  Go GC Count:            %d\n", stats.GoGcCount)
		fmt.Printf("  Go Heap Alloc:          %s\n", formatBytes(stats.GoHeapAllocBytes))
		fmt.Printf("  Go Heap Inuse:          %s\n", formatBytes(stats.GoHeapInuseBytes))
		fmt.Printf("  Go Heap Sys:            %s\n", formatBytes(stats.GoHeapSysBytes))
		fmt.Printf("  Go Heap Objects:        %d\n", stats.GoHeapObjects)
		fmt.Printf("  Go Stack Inuse:         %s\n", formatBytes(stats.GoStackInuseBytes))
		fmt.Printf("  Go Sys:                 %s\n", formatBytes(stats.GoSysBytes))
		fmt.Printf("  Go Total Alloc:         %s\n", formatBytes(stats.GoTotalAllocBytes))
		fmt.Printf("  Hub Connected:          %v\n", stats.HubConnected)
		fmt.Printf("  Hub gRPC State:         %s\n", stats.HubGrpcState)
		fmt.Printf("  Direct gRPC Conns:      %d\n", stats.DirectGrpcConnections)
		fmt.Printf("  Nodes:                  %d total / %d online\n", stats.TotalNodes, stats.OnlineNodes)
		fmt.Printf("  Stream Subscribers:     approvals=%d conn=%d p2p=%d\n",
			stats.ApprovalStreamSubscribers,
			stats.ConnectionStreamSubscribers,
			stats.P2PStreamSubscribers)
		fmt.Println()
	case "grpc":
		ctx, cancel := authAPICtx()
		defer cancel()

		stats, err := client.GetDebugRuntimeStats(ctx, &pbLocal.GetDebugRuntimeStatsRequest{})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}

		fmt.Println("\nDebug gRPC Connections (MobileLogicService):")
		fmt.Printf("  Hub Connected:          %v\n", stats.HubConnected)
		fmt.Printf("  Direct gRPC Conns:      %d\n", stats.DirectGrpcConnections)
		fmt.Printf("  Stream Subscribers:     approvals=%d conn=%d p2p=%d\n",
			stats.ApprovalStreamSubscribers,
			stats.ConnectionStreamSubscribers,
			stats.P2PStreamSubscribers)
		fmt.Println()
		fmt.Printf("%-8s  %-26s  %-24s  %-20s  %-10s\n", "Scope", "Node", "Address", "State", "Connected")
		fmt.Println(strings.Repeat("-", 96))
		for _, c := range stats.GrpcConnections {
			nodeID := c.NodeId
			if nodeID == "" {
				nodeID = "-"
			}
			addr := c.Address
			if addr == "" {
				addr = "-"
			}
			fmt.Printf("%-8s  %-26s  %-24s  %-20s  %-10v\n",
				c.Scope, truncate(nodeID, 26), truncate(addr, 24), c.State, c.Connected)
		}
		fmt.Println()
	case "goroutine", "gdiff", "diff":
		ctx, cancel := authAPICtx()
		defer cancel()

		stats, err := client.GetDebugRuntimeStats(ctx, &pbLocal.GetDebugRuntimeStatsRequest{})
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}

		prevAt := "-"
		if stats.GoroutineDiffPrevAt != nil {
			prevAt = stats.GoroutineDiffPrevAt.AsTime().Format("2006-01-02 15:04:05")
		}
		currAt := "-"
		if stats.GoroutineDiffCurrAt != nil {
			currAt = stats.GoroutineDiffCurrAt.AsTime().Format("2006-01-02 15:04:05")
		}

		fmt.Println("\nDebug Goroutine Diff (MobileLogicService):")
		fmt.Printf("  Previous Snapshot:      %s\n", prevAt)
		fmt.Printf("  Current Snapshot:       %s\n", currAt)
		fmt.Printf("  Previous Total:         %d\n", stats.GoroutineDiffPrevTotal)
		fmt.Printf("  Current Total:          %d\n", stats.GoroutineDiffCurrTotal)
		fmt.Printf("  Delta:                  %+d\n", stats.GoroutineDiffDelta)
		if !stats.GoroutineDiffHasBaseline {
			fmt.Println()
			fmt.Println("Baseline initialized. Run `debug goroutine` again to see diffs.")
			fmt.Println()
			return
		}

		if len(stats.GoroutineDiffEntries) == 0 {
			fmt.Println("  No goroutine group changes since previous snapshot.")
			fmt.Println()
			return
		}

		fmt.Println()
		fmt.Printf("%-8s  %-8s  %-8s  %-70s\n", "Delta", "Prev", "Curr", "Signature")
		fmt.Println(strings.Repeat("-", 104))
		for _, e := range stats.GoroutineDiffEntries {
			fmt.Printf("%-8d  %-8d  %-8d  %-70s\n",
				e.Delta, e.PrevCount, e.CurrCount, truncate(e.Signature, 70))
		}
		if stats.GoroutineDiffTruncated > 0 {
			fmt.Printf("\n  ... %d more entries omitted\n", stats.GoroutineDiffTruncated)
		}
		fmt.Println()
	default:
		fmt.Println("Usage: debug [runtime|grpc|goroutine]")
	}
}

func cmdRestart() {
	ctx, cancel := context.WithTimeout(authCtx(), 30*time.Second)
	defer cancel()

	fmt.Println("Restarting all proxy listeners...")
	resp, err := client.RestartListeners(ctx, &pbLocal.RestartListenersNodeRequest{
		NodeId: localNodeID,
	})
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}
	if !cli.CheckResponseWithField(resp.Success, resp.ErrorMessage) {
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

// configureGeoIP sends a GeoIP configuration request to the server.
func configureGeoIP(ctx context.Context, mode pb.ConfigureGeoIPRequest_Mode, primary, optional, successMsg string) {
	req := &pb.ConfigureGeoIPRequest{Mode: mode}
	switch mode {
	case pb.ConfigureGeoIPRequest_MODE_LOCAL_DB:
		req.CityDbPath = primary
		req.IspDbPath = optional
	case pb.ConfigureGeoIPRequest_MODE_REMOTE_API:
		req.Provider = primary
		req.ApiKey = optional
	}

	resp, err := client.ConfigureGeoIP(ctx, &pbLocal.ConfigureGeoIPNodeRequest{
		NodeId: localNodeID,
		Config: req,
	})
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}
	if !cli.CheckResponseWithField(resp.Success, resp.Error) {
		return
	}
	fmt.Println(successMsg)
}

func cmdGeoIP(args []string) {
	if len(args) == 0 {
		fmt.Println("Usage: geoip <status|config> ...")
		return
	}

	ctx, cancel := authAPICtx()
	defer cancel()

	switch args[0] {
	case "status":
		resp, err := client.GetGeoIPStatus(ctx, &pbLocal.GetGeoIPStatusNodeRequest{
			NodeId: localNodeID,
		})
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
			if !cli.RequireArgs(args, 3, "Usage: geoip config local <city_db_path> [isp_db_path]") {
				return
			}
			optional := ""
			if len(args) > 3 {
				optional = args[3]
			}
			configureGeoIP(ctx, pb.ConfigureGeoIPRequest_MODE_LOCAL_DB, args[2], optional,
				"GeoIP configured with local databases.")

		case "remote":
			if !cli.RequireArgs(args, 3, "Usage: geoip config remote <provider_url> [api_key]") {
				return
			}
			optional := ""
			if len(args) > 3 {
				optional = args[3]
			}
			configureGeoIP(ctx, pb.ConfigureGeoIPRequest_MODE_REMOTE_API, args[2], optional,
				"GeoIP configured with remote provider.")

		default:
			fmt.Println("Usage: geoip config <local|remote> ...")
		}

	default:
		fmt.Println("Usage: geoip <status|config> ...")
	}
}

func cmdLookupIP(args []string) {
	if !cli.RequireArgs(args, 1, "Usage: lookup <ip>") {
		return
	}

	ctx, cancel := context.WithTimeout(authCtx(), 10*time.Second)
	defer cancel()

	resp, err := client.LookupIP(ctx, &pbLocal.LookupIPRequest{Ip: args[0]})
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
	fmt.Printf("  Lookup Time:  %dms\n", resp.Geo.GetLatencyMs())
	fmt.Printf("  Cached:       %v\n", resp.Cached)
	fmt.Println()
}
