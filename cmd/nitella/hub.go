package main

import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"os"
	"regexp"
	"strings"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pbLocal "github.com/ivere27/nitella/pkg/api/local"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/fieldmaskpb"
)

// HubCLI encapsulates all Hub mode state, replacing package-level globals.
type HubCLI struct {
	// Configuration (from CLI flags)
	address              string
	token                string
	stunServer           string
	allowRuntimeOverride bool

	// Alert streaming
	alertStreamCancel  context.CancelFunc
	alertStreamRunning bool
}

// NewHubCLI creates a new HubCLI instance with the given CLI flag values.
func NewHubCLI(address, token, stunServer string, allowRuntimeOverride bool) *HubCLI {
	return &HubCLI{
		address:              address,
		token:                token,
		stunServer:           stunServer,
		allowRuntimeOverride: allowRuntimeOverride,
	}
}

// HubConfig stores Hub CLI configuration
type HubConfig struct {
	HubAddress string `json:"hub_address"`
	Token      string `json:"token,omitempty"` // Session token override (env/flag/runtime only)
	DataDir    string `json:"data_dir"`
	HubCAPEM   string `json:"hub_ca_pem,omitempty"`   // Stored Hub CA for TOFU
	HubCAFP    string `json:"hub_ca_fp,omitempty"`    // SHA256 fingerprint of Hub CA
	HubCAEmoji string `json:"hub_ca_emoji,omitempty"` // Emoji visual hash of Hub CA
	HubCertPin string `json:"hub_cert_pin,omitempty"` // SPKI pin for Hub certificate
	STUNServer string `json:"stun_server,omitempty"`  // STUN server URL for P2P
}

// Cleanup cleans up all Hub mode resources before exit
func (h *HubCLI) Cleanup() {
	h.stopBackgroundAlertStream()
}

// ansiEscapeRegex matches ANSI escape sequences
var ansiEscapeRegex = regexp.MustCompile(`\x1b\[[0-9;]*[a-zA-Z]|\x1b\][^\x07]*\x07|\x1b[PX^_][^\x1b]*\x1b\\`)

// sanitizeForTerminal removes ANSI escape sequences and control characters from untrusted input.
// This prevents "termojacking" attacks where malicious data could manipulate the terminal display.
// Preserves printable ASCII, UTF-8 characters, newlines, and tabs.
func sanitizeForTerminal(s string) string {
	// Remove ANSI escape sequences
	s = ansiEscapeRegex.ReplaceAllString(s, "")

	// Remove other control characters (keep newline, tab, and printable chars)
	var result strings.Builder
	result.Grow(len(s))
	for _, r := range s {
		if r == '\n' || r == '\t' || r >= 32 {
			result.WriteRune(r)
		}
	}
	return result.String()
}

// loadHubConfig loads Hub configuration.
// Source priority:
//  1. backend settings (canonical for Hub address + trust settings)
//  2. explicit one-shot runtime overrides (when --override-backend-config is set)
//  3. explicit CLI flags as bootstrap fallback when backend is empty
func (h *HubCLI) loadHubConfig() *HubConfig {
	cfg := &HubConfig{
		DataDir: dataDir,
	}

	// Canonical settings from backend.
	if snapshot, err := client.GetHubSettingsSnapshot(context.Background(), &emptypb.Empty{}); err == nil && snapshot != nil {
		settings := snapshot.GetSettings()
		if snapshot.GetResolvedHubAddress() != "" {
			cfg.HubAddress = snapshot.GetResolvedHubAddress()
		}
		if cfg.HubAddress == "" && settings.HubAddress != "" {
			cfg.HubAddress = settings.HubAddress
		}
		if len(settings.StunServers) > 0 && settings.StunServers[0] != "" {
			cfg.STUNServer = settings.StunServers[0]
		}
		if len(settings.HubCaPem) > 0 {
			cfg.HubCAPEM = string(settings.HubCaPem)
		}
		if settings.HubCertPin != "" {
			cfg.HubCertPin = settings.HubCertPin
		}
	}

	// Runtime values:
	// - token is always session-scoped and can come from env/flag
	// - hub/stun only come from env when override is explicitly enabled
	runtimeHubAddr := strings.TrimSpace(h.address)
	runtimeToken := strings.TrimSpace(h.token)
	runtimeSTUN := strings.TrimSpace(h.stunServer)
	if runtimeToken == "" {
		runtimeToken = strings.TrimSpace(os.Getenv("NITELLA_HUB_TOKEN"))
	}

	// Token is session-scoped by design.
	if runtimeToken != "" {
		cfg.Token = runtimeToken
	}

	if h.allowRuntimeOverride {
		if runtimeHubAddr == "" {
			runtimeHubAddr = strings.TrimSpace(os.Getenv("NITELLA_HUB"))
		}
		if runtimeSTUN == "" {
			runtimeSTUN = strings.TrimSpace(os.Getenv("NITELLA_STUN"))
		}
		if runtimeHubAddr != "" {
			cfg.HubAddress = runtimeHubAddr
		}
		if runtimeSTUN != "" {
			cfg.STUNServer = runtimeSTUN
		}
	} else {
		// No implicit env overrides: keep backend canonical unless explicit flags
		// are provided and backend has no value yet.
		if cfg.HubAddress == "" && runtimeHubAddr != "" {
			cfg.HubAddress = runtimeHubAddr
		}
		if cfg.STUNServer == "" && runtimeSTUN != "" {
			cfg.STUNServer = runtimeSTUN
		}
	}

	return cfg
}

// saveHubConfig persists Hub configuration.
// Canonical storage is backend settings/session in MobileLogicService.
func (h *HubCLI) saveHubConfig(cfg *HubConfig) error {
	_, err := client.UpdateSettings(context.Background(), &pbLocal.UpdateSettingsRequest{
		Settings: &pbLocal.Settings{
			HubAddress: cfg.HubAddress,
			HubCaPem:   []byte(cfg.HubCAPEM),
			HubCertPin: cfg.HubCertPin,
		},
		UpdateMask: &fieldmaskpb.FieldMask{
			Paths: []string{"hub_address", "hub_ca_pem", "hub_cert_pin"},
		},
	})
	if err != nil {
		return fmt.Errorf("failed to persist hub settings: %w", err)
	}

	// Token is not persisted in settings; keep runtime override only.
	h.token = cfg.Token
	return nil
}

// connectToHub establishes connection to Hub via the backend.
// TOFU and trust verification are orchestrated by MobileLogicService via OnboardHub.
func (h *HubCLI) connectToHub(cfg *HubConfig) error {
	resp, err := h.onboardHub(cfg, "", true)
	if err != nil {
		return err
	}
	if resp == nil || !resp.Connected {
		return fmt.Errorf("failed to connect to hub")
	}
	return nil
}

// onboardHub runs backend-owned onboarding flow and handles optional trust prompt.
func (h *HubCLI) onboardHub(cfg *HubConfig, inviteCode string, skipRegistration bool) (*pbLocal.OnboardHubResponse, error) {
	request := &pbLocal.OnboardHubRequest{
		HubAddress:       cfg.HubAddress,
		InviteCode:       inviteCode,
		Token:            cfg.Token,
		SkipRegistration: skipRegistration,
	}

	callOnboard := func(req *pbLocal.OnboardHubRequest) (*pbLocal.OnboardHubResponse, error) {
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()
		if req.GetSkipRegistration() {
			return client.EnsureHubConnected(ctx, &pbLocal.EnsureHubConnectedRequest{
				HubAddress:      req.GetHubAddress(),
				Token:           req.GetToken(),
				PersistSettings: req.GetPersistSettings(),
			})
		}
		return client.EnsureHubRegistered(ctx, &pbLocal.EnsureHubRegisteredRequest{
			HubAddress:         req.GetHubAddress(),
			InviteCode:         req.GetInviteCode(),
			Token:              req.GetToken(),
			BiometricPublicKey: req.GetBiometricPublicKey(),
			PersistSettings:    req.GetPersistSettings(),
		})
	}

	resp, err := callOnboard(request)
	if err != nil {
		return nil, fmt.Errorf("failed to onboard hub: %w", err)
	}
	if resp == nil {
		return nil, fmt.Errorf("empty response")
	}

	if resp.Stage == pbLocal.OnboardHubResponse_STAGE_NEEDS_TRUST {
		challenge := resp.GetTrustChallenge()
		if challenge == nil || len(challenge.GetCaPem()) == 0 {
			return nil, fmt.Errorf("hub requires trust verification but challenge is missing")
		}
		if resp.GetHubAddress() != "" {
			cfg.HubAddress = resp.GetHubAddress()
		}

		fmt.Println()
		fmt.Println("+----------------------------------------------------------+")
		fmt.Println("|    FIRST CONNECTION - VERIFY HUB IDENTITY                 |")
		fmt.Println("+----------------------------------------------------------+")
		fmt.Printf("|  Hub:        %-45s|\n", cfg.HubAddress)
		fmt.Printf("|  Subject:    %-45s|\n", challenge.GetSubject())
		fmt.Printf("|  SHA-256:    %-45s|\n", truncateStr(challenge.GetFingerprint(), 45))
		if challenge.GetEmojiHash() != "" {
			fmt.Printf("|  Emoji:      %-45s|\n", challenge.GetEmojiHash())
		}
		fmt.Printf("|  Expires:    %-45s|\n", challenge.GetExpires())
		fmt.Println("+----------------------------------------------------------+")
		fmt.Println("|  This Hub uses a self-signed certificate.                 |")
		fmt.Println("|  Verify fingerprint matches Hub operator's published      |")
		fmt.Println("|  value before accepting!                                  |")
		fmt.Println("+----------------------------------------------------------+")
		fmt.Print("Trust this Hub and continue? (yes/no): ")

		reader := bufio.NewReader(os.Stdin)
		answer, _ := reader.ReadString('\n')
		answer = strings.TrimSpace(strings.ToLower(answer))
		if answer != "yes" && answer != "y" {
			if strings.TrimSpace(challenge.GetChallengeId()) != "" {
				rejectCtx, rejectCancel := context.WithTimeout(context.Background(), 10*time.Second)
				_, _ = client.ResolveHubTrustChallenge(rejectCtx, &pbLocal.ResolveHubTrustChallengeRequest{
					ChallengeId: challenge.GetChallengeId(),
					Accepted:    false,
				})
				rejectCancel()
			}
			return nil, fmt.Errorf("hub certificate rejected by user")
		}

		cfg.HubCAPEM = string(challenge.GetCaPem())
		cfg.HubCAFP = challenge.GetFingerprint()
		cfg.HubCAEmoji = challenge.GetEmojiHash()
		if strings.TrimSpace(challenge.GetChallengeId()) == "" {
			return nil, fmt.Errorf("hub trust challenge is missing challenge_id")
		}

		resolveCtx, resolveCancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer resolveCancel()
		resp, err = client.ResolveHubTrustChallenge(resolveCtx, &pbLocal.ResolveHubTrustChallengeRequest{
			ChallengeId: challenge.GetChallengeId(),
			Accepted:    true,
		})
		if err != nil {
			return nil, fmt.Errorf("failed to onboard hub after trust confirmation: %w", err)
		}
		if resp == nil {
			return nil, fmt.Errorf("empty response after trust confirmation")
		}
	}

	if !resp.GetSuccess() {
		errMsg := strings.TrimSpace(resp.GetError())
		if errMsg == "" {
			errMsg = "unknown error"
		}
		return nil, fmt.Errorf("%s", errMsg)
	}
	if resp.GetHubAddress() != "" {
		cfg.HubAddress = resp.GetHubAddress()
	}

	return resp, nil
}

// ensureHubConnected loads config and connects to Hub.
// Returns the config on success, or nil after printing an error.
func (h *HubCLI) ensureHubConnected() *HubConfig {
	cfg := h.loadHubConfig()
	if err := h.connectToHub(cfg); err != nil {
		fmt.Printf("Error connecting to Hub: %v\n", err)
		return nil
	}
	return cfg
}

// mustMarshalJSON marshals to JSON, panics on error (for static data)
func mustMarshalJSON(v interface{}) []byte {
	b, err := json.Marshal(v)
	if err != nil {
		panic(err)
	}
	return b
}

// handleHubCommand handles hub-specific commands
func (h *HubCLI) handleHubCommand(args []string) {
	if len(args) == 0 {
		printHubHelp()
		return
	}

	switch args[0] {
	case "identity":
		cmdIdentity(args[1:])
		return
	case "config":
		h.cmdHubConfig(args[1:])
	case "login":
		h.cmdHubLogin(args[1:])
	case "register":
		h.cmdHubRegister(args[1:])
	case "status":
		h.cmdHubStatus()
	case "pair":
		h.cmdHubPair(args[1:])
	case "pair-offline":
		h.cmdHubPairOffline(args[1:])
	case "nodes":
		h.cmdHubNodes(args[1:])
	case "node":
		h.cmdHubNode(args[1:])
	case "alerts":
		h.cmdHubAlerts(args[1:])
	case "approvals", "pending":
		h.cmdHubPending(args[1:])
	case "approve":
		h.cmdHubApprove(args[1:])
	case "deny":
		h.cmdHubDeny(args[1:])
	case "proxy":
		cmdHubProxy(args[1:])
	case "send":
		h.cmdHubSend(args[1:])
	case "logs":
		h.cmdHubLogs(args[1:])
	case "debug":
		cmdDebug(args[1:])
	case "help":
		printHubHelp()
	default:
		fmt.Printf("Unknown hub command: %s. Type 'help' for available commands.\n", args[0])
	}
}

func printHubHelp() {
	fmt.Print(`
Hub Mode Commands:
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
  node <node_id>                 - Show node status
  node <node_id> status          - Show node status
  node <node_id> rules           - List node rules (E2E encrypted)
  node <node_id> metrics         - Stream node metrics
  node <node_id> conn            - List active connections
  node <node_id> conn close <id> - Close a connection
  node <node_id> conn closeall   - Close all connections

  Alerts & Approvals:
  alerts                         - Stream real-time alerts (approval requests)
  pending                        - List pending approval requests
  approve [once|cache] <id> [duration] - Approve a connection (cache default: 300s)
  deny [once|cache] <id> [duration] [reason] - Deny a connection (default: once)

  Proxy Management (E2E encrypted):
  proxy                          - Show proxy help
  proxy import <file.yaml>       - Import YAML file as proxy config
  proxy list [--local|--remote]  - List proxies
  proxy show <proxy-id>          - Show proxy details
  proxy edit <proxy-id>          - Edit proxy (opens $EDITOR)
  proxy push <proxy-id> -m "msg" - Push to Hub
  proxy pull <proxy-id>          - Pull from Hub
  proxy history <proxy-id>       - View revision history
  proxy apply <proxy-id> <node>  - Apply proxy to node
  proxy status <node-id>         - Show applied proxies on node
  proxy unapply <proxy-id> <n>   - Remove proxy from node

  Logs Management (Admin):
  logs stats                     - Show logs storage statistics
  logs list <routing_token>      - List logs for a routing token
  logs delete <routing_token>    - Delete logs for a routing token
  logs cleanup <days>            - Delete logs older than N days

  Debug:
  debug [runtime|grpc|goroutine] - Show local backend debug stats

  help                           - Show this help
`)
}

func (h *HubCLI) cmdHubConfig(args []string) {
	cfg := h.loadHubConfig()

	if len(args) == 0 {
		// Show current configuration
		fmt.Println("\nHub Configuration:")
		fmt.Printf("  Backend cfg:  MobileLogicService settings/session\n")
		fmt.Printf("  Hub address:  %s\n", cfg.HubAddress)
		if cfg.Token != "" {
			if len(cfg.Token) > 12 {
				fmt.Printf("  Token:        %s...%s\n", cfg.Token[:8], cfg.Token[len(cfg.Token)-4:])
			} else {
				fmt.Printf("  Token:        (set)\n")
			}
		} else {
			fmt.Printf("  Token:        (session-managed)\n")
		}
		fmt.Printf("  Data dir:     %s\n", cfg.DataDir)
		if cfg.HubCAPEM != "" {
			fmt.Printf("  Hub CA:       (pinned)\n")
		} else {
			fmt.Printf("  Hub CA:       (not pinned - will use TOFU)\n")
		}
		overview, overviewErr := client.GetSettingsOverviewSnapshot(context.Background(), &emptypb.Empty{})
		if overviewErr == nil && overview != nil && overview.GetP2P().GetStatus().GetEnabled() {
			fmt.Printf("  P2P:          enabled\n")
		} else {
			fmt.Printf("  P2P:          disabled\n")
		}
		fmt.Println()
		return
	}

	if args[0] == "set" && len(args) >= 3 {
		key, value := args[1], args[2]
		switch key {
		case "hub_address", "hub", "address":
			if cfg.HubAddress != value {
				cfg.HubAddress = value
				if cfg.HubCAPEM != "" {
					cfg.HubCAPEM = ""
					cfg.HubCertPin = ""
					fmt.Println("Hub address changed. Cleared pinned Hub CA (will re-verify on next connection).")
				}
			}
		case "token":
			cfg.Token = value
			h.token = value
			fmt.Println("Token set for current session. It will be persisted by backend after successful Hub auth.")
			return
		case "p2p":
			var mode common.P2PMode
			switch strings.ToLower(value) {
			case "true", "on", "1", "enable", "enabled", "auto":
				mode = common.P2PMode_P2P_MODE_AUTO
			case "false", "off", "0", "disable", "disabled":
				mode = common.P2PMode_P2P_MODE_HUB
			default:
				fmt.Printf("Invalid value for p2p: %s (use true/false)\n", value)
				return
			}
			if _, err := client.SetP2PMode(context.Background(), &pbLocal.SetP2PModeRequest{Mode: mode}); err != nil {
				fmt.Printf("Error setting P2P mode: %v\n", err)
				return
			}
			fmt.Printf("P2P %s.\n", value)
			return
		default:
			fmt.Printf("Unknown config key: %s\n", key)
			return
		}
		if err := h.saveHubConfig(cfg); err != nil {
			fmt.Printf("Error saving config: %v\n", err)
			return
		}
		fmt.Printf("Set %s = %s\n", key, value)
		return
	}

	fmt.Println("Usage: config [set <key> <value>]")
}

func (h *HubCLI) cmdHubLogin(args []string) {
	cfg := h.loadHubConfig()

	if cfg.HubAddress == "" {
		fmt.Print("Hub address: ")
		fmt.Scanln(&cfg.HubAddress)
	}

	fmt.Print("Authentication token: ")
	fmt.Scanln(&cfg.Token)

	if cfg.Token == "" {
		fmt.Println("Token is required.")
		return
	}

	// Try to connect with mTLS
	if err := h.connectToHub(cfg); err != nil {
		fmt.Printf("Login failed: %v\n", err)
		return
	}

	if err := h.saveHubConfig(cfg); err != nil {
		fmt.Printf("Error saving config: %v\n", err)
		return
	}

	fmt.Println("Login successful. Configuration saved.")
}
