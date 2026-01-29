package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"strings"

	pb "github.com/ivere27/nitella/pkg/api/geoip"
	"github.com/ivere27/nitella/pkg/shell"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"
	"google.golang.org/protobuf/types/known/emptypb"
)

var (
	adminAddr = flag.String("addr", "localhost:50053", "GeoIP admin server address")
	token     = flag.String("token", os.Getenv("GEOIP_TOKEN"), "Admin authentication token (env: GEOIP_TOKEN)")
)

// Client holds gRPC client
type Client struct {
	conn  *grpc.ClientConn
	admin pb.GeoIPAdminServiceClient
	token string
}

func main() {
	flag.Parse()

	if *token == "" {
		fmt.Fprintln(os.Stderr, "Error: --token is required")
		fmt.Fprintln(os.Stderr, "Usage: geoip --addr localhost:50053 --token YOUR_TOKEN")
		os.Exit(1)
	}

	client, err := NewClient(*adminAddr, *token)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to connect: %v\n", err)
		os.Exit(1)
	}
	defer client.Close()

	// Verify token on startup
	if err := client.Verify(); err != nil {
		fmt.Fprintf(os.Stderr, "Authentication failed: %v\n", err)
		os.Exit(1)
	}

	// If args provided, run single command
	args := flag.Args()
	if len(args) > 0 {
		if err := client.RunCommand(strings.Join(args, " ")); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
		return
	}

	// Interactive REPL
	fmt.Println("GeoIP Admin CLI - Type 'help' for commands, 'exit' to quit")
	shell.StartREPL("geoip> ", func(line string) error {
		return client.RunCommand(line)
	}, newCompletion())
}

// NewClient creates a new gRPC client.
func NewClient(addr, token string) (*Client, error) {
	opts := []grpc.DialOption{grpc.WithTransportCredentials(insecure.NewCredentials())}

	conn, err := grpc.NewClient(addr, opts...)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to admin server: %w", err)
	}

	return &Client{
		conn:  conn,
		admin: pb.NewGeoIPAdminServiceClient(conn),
		token: token,
	}, nil
}

// Close closes connections.
func (c *Client) Close() {
	c.conn.Close()
}

// Verify checks if the token is valid by calling an authenticated endpoint.
func (c *Client) Verify() error {
	_, err := c.admin.GetStatus(c.ctx(), &emptypb.Empty{})
	return err
}

// ctx creates a context with auth token.
func (c *Client) ctx() context.Context {
	md := metadata.Pairs("authorization", "Bearer "+c.token)
	return metadata.NewOutgoingContext(context.Background(), md)
}

// RunCommand executes a CLI command.
func (c *Client) RunCommand(line string) error {
	parts := strings.Fields(line)
	if len(parts) == 0 {
		return nil
	}

	cmd := parts[0]
	args := parts[1:]

	switch cmd {
	case "help":
		printHelp()
	case "lookup":
		return c.cmdLookup(args)
	case "status":
		return c.cmdStatus()
	case "provider":
		return c.cmdProvider(args)
	case "localdb":
		return c.cmdLocalDB(args)
	case "cache":
		return c.cmdCache(args)
	case "strategy":
		return c.cmdStrategy(args)
	case "config":
		return c.cmdConfig(args)
	default:
		return fmt.Errorf("unknown command: %s (try 'help')", cmd)
	}

	return nil
}

func printHelp() {
	fmt.Print(`
GeoIP Admin CLI Commands:
  lookup <ip>                    - Lookup IP geolocation
  status                         - Show server status

  provider list                  - List all providers
  provider add <name> <url>      - Add HTTP provider
  provider remove <name>         - Remove provider
  provider enable <name>         - Enable provider
  provider disable <name>        - Disable provider
  provider stats [name]          - Show provider statistics
  provider order <n1> <n2> ...   - Reorder providers

  localdb load <city> [isp]      - Load MaxMind databases
  localdb unload                 - Unload local databases
  localdb status                 - Show local DB status

  cache stats                    - Show cache statistics
  cache clear [l1|l2|all]        - Clear cache layers
  cache settings                 - Show cache settings

  strategy show                  - Show current strategy
  strategy set <l1,l2,local,...> - Set lookup order

  config reload                  - Reload configuration
  config save                    - Save configuration

  help                           - Show this help
  exit                           - Exit shell
`)
}

// newCompletion creates tab completion.
func newCompletion() *shell.SimpleCompletion {
	return &shell.SimpleCompletion{
		RootCommands: []string{
			"lookup", "status", "provider", "localdb", "cache",
			"strategy", "config", "help", "exit",
		},
		SubCommands: map[string][]string{
			"provider": {"list", "add", "remove", "enable", "disable", "stats", "order"},
			"localdb":  {"load", "unload", "status"},
			"cache":    {"stats", "clear", "settings"},
			"strategy": {"show", "set"},
			"config":   {"reload", "save"},
			"clear":    {"l1", "l2", "all"},
		},
	}
}
