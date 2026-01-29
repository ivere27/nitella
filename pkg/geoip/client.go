package geoip

import (
	"context"
	"fmt"

	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/geoip"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"
	"google.golang.org/protobuf/types/known/emptypb"
)

// GeoIPClient is the interface for GeoIP lookups (embedded or remote).
type GeoIPClient interface {
	Lookup(ctx context.Context, ip string) (*pbCommon.GeoInfo, error)
	GetStatus(ctx context.Context) (*pb.ServiceStatus, error)
	Close() error
}

// GeoIPAdminClient is the interface for GeoIP admin operations.
type GeoIPAdminClient interface {
	LoadLocalDB(ctx context.Context, cityPath, ispPath string) error
	SetStrategy(ctx context.Context, steps []string) error
	InitL2Cache(ctx context.Context, path string, ttlHours int) error
	GetCacheStats(ctx context.Context) (*pb.CacheStats, error)
	ClearCache(ctx context.Context, layer pb.CacheLayer) error
	Close() error
}

// ============================================================================
// Embedded Client (Direct Manager Access)
// ============================================================================

// EmbeddedClient is an embedded GeoIP client using direct manager access.
type EmbeddedClient struct {
	manager *Manager
}

// NewEmbeddedClient creates an embedded GeoIP client.
func NewEmbeddedClient(manager *Manager) *EmbeddedClient {
	return &EmbeddedClient{manager: manager}
}

// Lookup performs IP geolocation lookup directly via manager.
func (c *EmbeddedClient) Lookup(ctx context.Context, ip string) (*pbCommon.GeoInfo, error) {
	return c.manager.Lookup(ctx, ip)
}

// GetStatus returns service status directly via manager.
func (c *EmbeddedClient) GetStatus(ctx context.Context) (*pb.ServiceStatus, error) {
	return c.manager.GetStatus(), nil
}

// Close is a no-op for embedded client.
func (c *EmbeddedClient) Close() error {
	return nil
}

// ============================================================================
// gRPC Client (Remote Mode)
// ============================================================================

// RemoteClient is a remote GeoIP client using gRPC.
type RemoteClient struct {
	conn   *grpc.ClientConn
	client pb.GeoIPServiceClient
}

// NewRemoteClient creates a remote GeoIP client.
func NewRemoteClient(addr string) (*RemoteClient, error) {
	conn, err := grpc.NewClient(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, fmt.Errorf("failed to connect to GeoIP server: %w", err)
	}

	return &RemoteClient{
		conn:   conn,
		client: pb.NewGeoIPServiceClient(conn),
	}, nil
}

// Lookup performs IP geolocation lookup via gRPC.
func (c *RemoteClient) Lookup(ctx context.Context, ip string) (*pbCommon.GeoInfo, error) {
	return c.client.Lookup(ctx, &pb.LookupRequest{Ip: ip})
}

// GetStatus returns service status via gRPC.
func (c *RemoteClient) GetStatus(ctx context.Context) (*pb.ServiceStatus, error) {
	return c.client.GetStatus(ctx, &emptypb.Empty{})
}

// Close closes the gRPC connection.
func (c *RemoteClient) Close() error {
	if c.conn != nil {
		return c.conn.Close()
	}
	return nil
}

// ============================================================================
// Remote Admin Client
// ============================================================================

// RemoteAdminClient is a remote GeoIP admin client using gRPC.
type RemoteAdminClient struct {
	conn   *grpc.ClientConn
	client pb.GeoIPAdminServiceClient
	token  string
}

// NewRemoteAdminClient creates a remote GeoIP admin client.
func NewRemoteAdminClient(addr string, token string) (*RemoteAdminClient, error) {
	conn, err := grpc.NewClient(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, fmt.Errorf("failed to connect to GeoIP admin server: %w", err)
	}

	return &RemoteAdminClient{
		conn:   conn,
		client: pb.NewGeoIPAdminServiceClient(conn),
		token:  token,
	}, nil
}

// authCtx returns a context with the authorization token.
func (c *RemoteAdminClient) authCtx(ctx context.Context) context.Context {
	return metadata.AppendToOutgoingContext(ctx, "authorization", c.token)
}

// LoadLocalDB loads MaxMind databases via gRPC.
func (c *RemoteAdminClient) LoadLocalDB(ctx context.Context, cityPath, ispPath string) error {
	_, err := c.client.LoadLocalDB(c.authCtx(ctx), &pb.LoadLocalDBRequest{
		CityDbPath: cityPath,
		IspDbPath:  ispPath,
	})
	return err
}

// SetStrategy sets the lookup strategy via gRPC.
func (c *RemoteAdminClient) SetStrategy(ctx context.Context, steps []string) error {
	_, err := c.client.SetStrategy(c.authCtx(ctx), &pb.SetStrategyRequest{Steps: steps})
	return err
}

// InitL2Cache initializes L2 cache via gRPC.
func (c *RemoteAdminClient) InitL2Cache(ctx context.Context, path string, ttlHours int) error {
	_, err := c.client.UpdateCacheSettings(c.authCtx(ctx), &pb.UpdateCacheSettingsRequest{
		L2Enabled:  true,
		L2Path:     path,
		L2TtlHours: int32(ttlHours),
	})
	return err
}

// GetCacheStats returns cache statistics via gRPC.
func (c *RemoteAdminClient) GetCacheStats(ctx context.Context) (*pb.CacheStats, error) {
	return c.client.GetCacheStats(c.authCtx(ctx), &emptypb.Empty{})
}

// ClearCache clears cache layers via gRPC.
func (c *RemoteAdminClient) ClearCache(ctx context.Context, layer pb.CacheLayer) error {
	_, err := c.client.ClearCache(c.authCtx(ctx), &pb.ClearCacheRequest{Layer: layer})
	return err
}

// Close closes the gRPC connection.
func (c *RemoteAdminClient) Close() error {
	if c.conn != nil {
		return c.conn.Close()
	}
	return nil
}

// ============================================================================
// FFI Client (Zero-Copy via synurang)
// ============================================================================

// FfiClient is an FFI GeoIP client using synurang zero-copy FFI.
// This avoids serialization overhead for Go-to-Go calls.
type FfiClient struct {
	client pb.GeoIPServiceClient
}

// NewFfiClient creates an FFI GeoIP client using synurang FFI.
// The conn should be created via geoip_pb.NewFfiClientConn(ffiServer).
func NewFfiClient(conn grpc.ClientConnInterface) *FfiClient {
	return &FfiClient{
		client: pb.NewGeoIPServiceClient(conn),
	}
}

// Lookup performs IP geolocation lookup via FFI.
func (c *FfiClient) Lookup(ctx context.Context, ip string) (*pbCommon.GeoInfo, error) {
	return c.client.Lookup(ctx, &pb.LookupRequest{Ip: ip})
}

// GetStatus returns service status via FFI.
func (c *FfiClient) GetStatus(ctx context.Context) (*pb.ServiceStatus, error) {
	return c.client.GetStatus(ctx, &emptypb.Empty{})
}

// Close is a no-op for FFI client (no network connection).
func (c *FfiClient) Close() error {
	return nil
}

// ============================================================================
// Factory Functions
// ============================================================================

// NewClient creates a GeoIP client based on configuration.
// If remoteAddr is empty, creates an embedded client with the given manager.
// If remoteAddr is provided, creates a remote gRPC client.
func NewClient(remoteAddr string, manager *Manager) (GeoIPClient, error) {
	if remoteAddr != "" {
		return NewRemoteClient(remoteAddr)
	}
	if manager == nil {
		return nil, fmt.Errorf("manager required for embedded mode")
	}
	return NewEmbeddedClient(manager), nil
}
