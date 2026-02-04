// Package main provides the Hub admin CLI tool (hubctl).
// This CLI allows administrators to manage the Hub server,
// including user management, invite codes, and monitoring.
package main

import (
	"context"
	"crypto/ed25519"
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	hubpb "github.com/ivere27/nitella/pkg/api/hub"
	"github.com/spf13/cobra"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/metadata"
	"google.golang.org/protobuf/types/known/timestamppb"
)

var (
	// Global flags
	hubAddr   string
	adminKey  string
	tlsCert   string
	tlsKey    string
	tlsCA     string
	outputJSON   bool

	// Config file path
	configPath string
)

// Config holds hubctl configuration
type Config struct {
	HubAddress string `json:"hub_address"`
	AdminToken string `json:"admin_token"`
	TLSCert    string `json:"tls_cert,omitempty"`
	TLSKey     string `json:"tls_key,omitempty"`
	TLSCA      string `json:"tls_ca,omitempty"`
}

func main() {
	rootCmd := &cobra.Command{
		Use:   "hubctl",
		Short: "Hub administration CLI",
		Long:  `hubctl is a command-line tool for administering nitella Hub servers.`,
		PersistentPreRun: func(cmd *cobra.Command, args []string) {
			loadConfig()
		},
	}

	// Global flags
	rootCmd.PersistentFlags().StringVar(&hubAddr, "hub", "", "Hub server address (host:port)")
	rootCmd.PersistentFlags().StringVar(&adminKey, "admin-key", "", "Admin authentication key/token")
	rootCmd.PersistentFlags().StringVar(&tlsCert, "tls-cert", "", "Path to TLS certificate")
	rootCmd.PersistentFlags().StringVar(&tlsKey, "tls-key", "", "Path to TLS private key")
	rootCmd.PersistentFlags().StringVar(&tlsCA, "tls-ca", "", "Path to CA certificate (required for self-signed Hub CA)")
	rootCmd.PersistentFlags().BoolVar(&outputJSON, "json", false, "Output in JSON format")
	rootCmd.PersistentFlags().StringVar(&configPath, "config", "", "Config file path")

	// Add commands
	rootCmd.AddCommand(
		configCmd(),
		usersCmd(),
		nodesCmd(),
		inviteCmd(),
		statsCmd(),
		tokenCmd(),
	)

	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}

// loadConfig loads configuration from file or environment
func loadConfig() {
	// Determine config path
	if configPath == "" {
		home, _ := os.UserHomeDir()
		configPath = filepath.Join(home, ".hubctl", "config.json")
	}

	// Load config file if exists
	if data, err := os.ReadFile(configPath); err == nil {
		var cfg Config
		if json.Unmarshal(data, &cfg) == nil {
			if hubAddr == "" && cfg.HubAddress != "" {
				hubAddr = cfg.HubAddress
			}
			if adminKey == "" && cfg.AdminToken != "" {
				adminKey = cfg.AdminToken
			}
			if tlsCert == "" && cfg.TLSCert != "" {
				tlsCert = cfg.TLSCert
			}
			if tlsKey == "" && cfg.TLSKey != "" {
				tlsKey = cfg.TLSKey
			}
			if tlsCA == "" && cfg.TLSCA != "" {
				tlsCA = cfg.TLSCA
			}
		}
	}

	// Environment variables as fallback
	if hubAddr == "" {
		hubAddr = os.Getenv("HUB_ADDRESS")
	}
	if adminKey == "" {
		adminKey = os.Getenv("HUB_ADMIN_KEY")
	}
}

// saveConfig saves configuration to file
func saveConfig(cfg *Config) error {
	dir := filepath.Dir(configPath)
	if err := os.MkdirAll(dir, 0700); err != nil {
		return err
	}
	data, err := json.MarshalIndent(cfg, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(configPath, data, 0600)
}

// connectHub creates a gRPC connection to the Hub
func connectHub() (*grpc.ClientConn, error) {
	if hubAddr == "" {
		return nil, fmt.Errorf("hub address not specified (use --hub or configure with 'hubctl config set')")
	}

	var opts []grpc.DialOption

	// Configure TLS - Hub always uses TLS only
	if tlsCert != "" && tlsKey != "" {
		// mTLS with client certificate
		tlsConfig, err := loadTLSCredentials()
		if err != nil {
			return nil, fmt.Errorf("failed to load TLS credentials: %w", err)
		}
		opts = append(opts, grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)))
	} else if tlsCA != "" {
		// Custom CA (for self-signed Hub CA)
		caPEM, err := os.ReadFile(tlsCA)
		if err != nil {
			return nil, fmt.Errorf("failed to read CA certificate: %w", err)
		}
		caPool := x509.NewCertPool()
		if !caPool.AppendCertsFromPEM(caPEM) {
			return nil, fmt.Errorf("failed to parse CA certificate")
		}
		opts = append(opts, grpc.WithTransportCredentials(credentials.NewTLS(&tls.Config{
			RootCAs: caPool,
		})))
	} else {
		// Default: TLS with system CA pool
		opts = append(opts, grpc.WithTransportCredentials(credentials.NewTLS(&tls.Config{})))
	}

	return grpc.NewClient(hubAddr, opts...)
}

// loadTLSCredentials loads TLS credentials for mTLS
func loadTLSCredentials() (*tls.Config, error) {
	cert, err := tls.LoadX509KeyPair(tlsCert, tlsKey)
	if err != nil {
		return nil, err
	}

	config := &tls.Config{
		Certificates: []tls.Certificate{cert},
	}

	if tlsCA != "" {
		caPEM, err := os.ReadFile(tlsCA)
		if err != nil {
			return nil, err
		}
		caPool := x509.NewCertPool()
		if !caPool.AppendCertsFromPEM(caPEM) {
			return nil, fmt.Errorf("failed to parse CA certificate")
		}
		config.RootCAs = caPool
	}

	return config, nil
}

// withAdminAuth adds admin authentication to context
func withAdminAuth(ctx context.Context) context.Context {
	if adminKey != "" {
		return metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+adminKey)
	}
	return ctx
}

// configCmd returns the config command
func configCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "config",
		Short: "Manage hubctl configuration",
	}

	// config set
	setCmd := &cobra.Command{
		Use:   "set <key> <value>",
		Short: "Set a configuration value",
		Args:  cobra.ExactArgs(2),
		RunE: func(cmd *cobra.Command, args []string) error {
			// Load existing config
			var cfg Config
			if data, err := os.ReadFile(configPath); err == nil {
				json.Unmarshal(data, &cfg)
			}

			// Update value
			key, value := args[0], args[1]
			switch key {
			case "hub", "hub_address":
				cfg.HubAddress = value
			case "admin_token", "token":
				cfg.AdminToken = value
			case "tls_cert":
				cfg.TLSCert = value
			case "tls_key":
				cfg.TLSKey = value
			case "tls_ca":
				cfg.TLSCA = value
			default:
				return fmt.Errorf("unknown config key: %s", key)
			}

			if err := saveConfig(&cfg); err != nil {
				return err
			}
			fmt.Printf("Set %s = %s\n", key, value)
			return nil
		},
	}

	// config show
	showCmd := &cobra.Command{
		Use:   "show",
		Short: "Show current configuration",
		RunE: func(cmd *cobra.Command, args []string) error {
			var cfg Config
			if data, err := os.ReadFile(configPath); err == nil {
				json.Unmarshal(data, &cfg)
			}

			if outputJSON {
				data, _ := json.MarshalIndent(cfg, "", "  ")
				fmt.Println(string(data))
			} else {
				fmt.Printf("Config file: %s\n", configPath)
				fmt.Printf("Hub address: %s\n", cfg.HubAddress)
				if cfg.AdminToken != "" {
					fmt.Printf("Admin token: %s...%s\n", cfg.AdminToken[:8], cfg.AdminToken[len(cfg.AdminToken)-4:])
				}
				if cfg.TLSCert != "" {
					fmt.Printf("TLS cert: %s\n", cfg.TLSCert)
				}
			}
			return nil
		},
	}

	// config path
	pathCmd := &cobra.Command{
		Use:   "path",
		Short: "Show config file path",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Println(configPath)
		},
	}

	cmd.AddCommand(setCmd, showCmd, pathCmd)
	return cmd
}

// usersCmd returns the users command
func usersCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "users",
		Short: "Manage Hub users",
	}

	// users list
	listCmd := &cobra.Command{
		Use:   "list",
		Short: "List all users",
		RunE: func(cmd *cobra.Command, args []string) error {
			conn, err := connectHub()
			if err != nil {
				return err
			}
			defer conn.Close()

			client := hubpb.NewAdminServiceClient(conn)
			ctx, cancel := context.WithTimeout(withAdminAuth(context.Background()), 30*time.Second)
			defer cancel()

			resp, err := client.ListAllUsers(ctx, &hubpb.ListAllUsersRequest{})
			if err != nil {
				return fmt.Errorf("failed to list users: %w", err)
			}

			if outputJSON {
				data, _ := json.MarshalIndent(resp.Users, "", "  ")
				fmt.Println(string(data))
			} else {
				fmt.Printf("%-36s  %-12s  %-8s  %s\n", "USER ID", "TIER", "ROLE", "CREATED")
				fmt.Println(strings.Repeat("-", 80))
				for _, u := range resp.Users {
					created := "N/A"
					if u.CreatedAt != nil {
						created = u.CreatedAt.AsTime().Format("2006-01-02")
					}
					fmt.Printf("%-36s  %-12s  %-8s  %s\n", u.Id, u.Tier, u.Role, created)
				}
				fmt.Printf("\nTotal: %d users\n", len(resp.Users))
			}
			return nil
		},
	}

	cmd.AddCommand(listCmd)
	return cmd
}

// nodesCmd returns the nodes command
func nodesCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "nodes",
		Short: "Manage Hub nodes",
	}

	// nodes list
	listCmd := &cobra.Command{
		Use:   "list",
		Short: "List all registered nodes",
		RunE: func(cmd *cobra.Command, args []string) error {
			conn, err := connectHub()
			if err != nil {
				return err
			}
			defer conn.Close()

			client := hubpb.NewAdminServiceClient(conn)
			ctx, cancel := context.WithTimeout(withAdminAuth(context.Background()), 30*time.Second)
			defer cancel()

			resp, err := client.ListAllNodes(ctx, &hubpb.ListAllNodesRequest{})
			if err != nil {
				return fmt.Errorf("failed to list nodes: %w", err)
			}

			if outputJSON {
				data, _ := json.MarshalIndent(resp.Nodes, "", "  ")
				fmt.Println(string(data))
			} else {
				fmt.Printf("%-36s  %-10s  %-15s  %s\n", "NODE ID", "STATUS", "OWNER", "LAST SEEN")
				fmt.Println(strings.Repeat("-", 80))
				for _, n := range resp.Nodes {
					status := n.Status.String()
					lastSeen := "never"
					if n.LastSeen != nil {
						lastSeen = n.LastSeen.AsTime().Format("2006-01-02 15:04")
					}
					fmt.Printf("%-36s  %-10s  %-15s  %s\n", n.Id, status, n.OwnerId, lastSeen)
				}
				fmt.Printf("\nTotal: %d nodes\n", len(resp.Nodes))
			}
			return nil
		},
	}

	cmd.AddCommand(listCmd)
	return cmd
}

// inviteCmd returns the invite command
func inviteCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "invite",
		Short: "Manage invite codes",
	}

	// invite create
	var maxUses int
	var expiresIn string
	var tier string

	createCmd := &cobra.Command{
		Use:   "create",
		Short: "Create a new invite code",
		RunE: func(cmd *cobra.Command, args []string) error {
			conn, err := connectHub()
			if err != nil {
				return err
			}
			defer conn.Close()

			client := hubpb.NewAdminServiceClient(conn)
			ctx, cancel := context.WithTimeout(withAdminAuth(context.Background()), 30*time.Second)
			defer cancel()

			// Generate a random code if not provided
			code := fmt.Sprintf("INVITE-%d", time.Now().UnixNano()%1000000)

			inviteCode := &hubpb.InviteCode{
				Code:  code,
				Limit: int32(maxUses),
				Tier:  tier,
			}

			// Parse expiration
			if expiresIn != "" {
				duration, err := time.ParseDuration(expiresIn)
				if err != nil {
					return fmt.Errorf("invalid expiration duration: %w", err)
				}
				expiresAt := time.Now().Add(duration)
				inviteCode.ExpiresAt = timestamppb.New(expiresAt)
			}

			_, err = client.UpsertInviteCode(ctx, inviteCode)
			if err != nil {
				return fmt.Errorf("failed to create invite code: %w", err)
			}

			if outputJSON {
				data, _ := json.MarshalIndent(inviteCode, "", "  ")
				fmt.Println(string(data))
			} else {
				fmt.Printf("Invite code created: %s\n", code)
				fmt.Printf("Max uses: %d\n", maxUses)
				if inviteCode.ExpiresAt != nil {
					fmt.Printf("Expires: %s\n", inviteCode.ExpiresAt.AsTime().Format(time.RFC3339))
				}
				if tier != "" {
					fmt.Printf("Tier: %s\n", tier)
				}
			}
			return nil
		},
	}
	createCmd.Flags().IntVar(&maxUses, "max-uses", 1, "Maximum number of uses (0 = unlimited)")
	createCmd.Flags().StringVar(&expiresIn, "expires-in", "", "Expiration duration (e.g., 24h, 7d)")
	createCmd.Flags().StringVar(&tier, "tier", "", "Tier to assign to users (free, pro, business)")

	cmd.AddCommand(createCmd)
	return cmd
}

// statsCmd returns the stats command
func statsCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "stats",
		Short: "Show Hub statistics",
		RunE: func(cmd *cobra.Command, args []string) error {
			conn, err := connectHub()
			if err != nil {
				return err
			}
			defer conn.Close()

			client := hubpb.NewAdminServiceClient(conn)
			ctx, cancel := context.WithTimeout(withAdminAuth(context.Background()), 30*time.Second)
			defer cancel()

			resp, err := client.GetSystemStats(ctx, &hubpb.GetSystemStatsRequest{})
			if err != nil {
				return fmt.Errorf("failed to get stats: %w", err)
			}

			if outputJSON {
				data, _ := json.MarshalIndent(resp, "", "  ")
				fmt.Println(string(data))
			} else {
				fmt.Println("Hub Statistics")
				fmt.Println(strings.Repeat("-", 40))
				fmt.Printf("Total users:         %d\n", resp.TotalUsers)
				fmt.Printf("Total nodes:         %d\n", resp.TotalNodes)
				fmt.Printf("Online nodes:        %d\n", resp.OnlineNodes)
				fmt.Printf("Connections today:   %d\n", resp.TotalConnectionsToday)
				fmt.Printf("Blocked today:       %d\n", resp.BlockedRequestsToday)
				if len(resp.UsersByTier) > 0 {
					fmt.Println("\nUsers by tier:")
					for tier, count := range resp.UsersByTier {
						fmt.Printf("  %s: %d\n", tier, count)
					}
				}
			}
			return nil
		},
	}
	return cmd
}

// tokenCmd returns the token command
func tokenCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "token",
		Short: "Manage authentication tokens",
	}

	// token generate-admin
	generateCmd := &cobra.Command{
		Use:   "generate-admin",
		Short: "Generate an admin token (requires Hub JWT key file)",
		RunE: func(cmd *cobra.Command, args []string) error {
			// Admin tokens are generated from the Hub's JWT key file
			// The Hub generates this on startup: jwt.key in data directory
			keyPath, _ := cmd.Flags().GetString("key-file")
			if keyPath == "" {
				return fmt.Errorf("--key-file is required (path to Hub's jwt.key)")
			}

			keyData, err := os.ReadFile(keyPath)
			if err != nil {
				return fmt.Errorf("failed to read JWT key: %w", err)
			}

			// Parse the Ed25519 private key
			block, _ := pem.Decode(keyData)
			if block == nil {
				return fmt.Errorf("failed to decode PEM block")
			}

			key, err := x509.ParsePKCS8PrivateKey(block.Bytes)
			if err != nil {
				return fmt.Errorf("failed to parse private key: %w", err)
			}

			privKey, ok := key.(ed25519.PrivateKey)
			if !ok {
				return fmt.Errorf("key is not Ed25519")
			}

			// Generate a simple admin token (in production, use proper JWT library)
			fmt.Println("Admin token generation requires the Hub's JWT key.")
			fmt.Printf("Key loaded successfully (%d bytes)\n", len(privKey))
			fmt.Println("\nTo get an admin token, run the Hub with --generate-admin-token flag")
			fmt.Println("or use the Hub's admin API with proper authentication.")
			return nil
		},
	}
	generateCmd.Flags().String("key-file", "", "Path to Hub's JWT key file (jwt.key)")

	// token generate-local (offline, requires key file)
	var keyFile string
	generateLocalCmd := &cobra.Command{
		Use:   "generate-local",
		Short: "Generate admin token locally using JWT key file",
		RunE: func(cmd *cobra.Command, args []string) error {
			if keyFile == "" {
				return fmt.Errorf("--key-file is required")
			}

			// Load private key
			keyPEM, err := os.ReadFile(keyFile)
			if err != nil {
				return fmt.Errorf("failed to read key file: %w", err)
			}

			block, _ := pem.Decode(keyPEM)
			if block == nil {
				return fmt.Errorf("failed to decode PEM block")
			}

			key, err := x509.ParsePKCS8PrivateKey(block.Bytes)
			if err != nil {
				return fmt.Errorf("failed to parse private key: %w", err)
			}

			edKey, ok := key.(ed25519.PrivateKey)
			if !ok {
				return fmt.Errorf("key is not Ed25519")
			}

			// Generate token using jwt package (simplified)
			// In practice, you'd use the auth package
			_ = edKey // Would use this to sign JWT
			fmt.Println("Local token generation not yet implemented")
			fmt.Println("Use 'hubctl token generate-admin' with existing admin access")
			return nil
		},
	}
	generateLocalCmd.Flags().StringVar(&keyFile, "key-file", "", "Path to Hub's JWT key file")

	cmd.AddCommand(generateCmd, generateLocalCmd)
	return cmd
}

// formatDuration formats a duration in human-readable form
func formatDuration(d time.Duration) string {
	days := int(d.Hours()) / 24
	hours := int(d.Hours()) % 24
	minutes := int(d.Minutes()) % 60

	if days > 0 {
		return fmt.Sprintf("%dd %dh %dm", days, hours, minutes)
	}
	if hours > 0 {
		return fmt.Sprintf("%dh %dm", hours, minutes)
	}
	return fmt.Sprintf("%dm", minutes)
}
