package core

import (
	"bytes"
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/pem"
	"errors"
	"fmt"
	"io"
	"math/big"
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/ivere27/nitella/pkg/api/common"
	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/identity"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/protobuf/proto"
)

const rustSmokeNodeID = "rust-local"

func TestRustDirectAdminSmoke(t *testing.T) {
	ctrl, cleanup := newRustDirectSmokeController(t)
	defer cleanup()

	status, err := ctrl.GetNodeStatus(context.Background(), rustSmokeNodeID)
	if err != nil {
		t.Fatalf("GetNodeStatus: %v", err)
	}
	if status.Timestamp == nil {
		t.Fatalf("GetNodeStatus returned nil timestamp")
	}

	proxies, err := ctrl.ListProxies(context.Background(), rustSmokeNodeID)
	if err != nil {
		t.Fatalf("ListProxies: %v", err)
	}
	for _, proxy := range proxies {
		if proxy.ProxyId == "" || proxy.ListenAddr == "" {
			t.Fatalf("malformed proxy status: %#v", proxy)
		}
	}
}

func TestRustDirectProxyTrafficSmoke(t *testing.T) {
	ctrl, cleanup := newRustDirectSmokeController(t)
	defer cleanup()

	backendAddr, backendReceived, stopBackend := startEchoBackend(t)
	defer stopBackend()

	createResp, err := ctrl.CreateProxy(context.Background(), rustSmokeNodeID, &pbProxy.CreateProxyRequest{
		Name:           "rust-live-proxy-smoke",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil {
		t.Fatalf("CreateProxy: %v", err)
	}
	if !createResp.Success || createResp.ProxyId == "" {
		t.Fatalf("CreateProxy response: success=%v proxy_id=%q error=%q", createResp.Success, createResp.ProxyId, createResp.ErrorMessage)
	}
	t.Cleanup(func() {
		_ = ctrl.DisableProxy(context.Background(), rustSmokeNodeID, createResp.ProxyId)
	})

	proxyStatus := waitForRustProxyStatus(t, ctrl, createResp.ProxyId, func(st *pbProxy.ProxyStatus) bool {
		return st.Running && st.ListenAddr != "" && st.ListenAddr != "127.0.0.1:0"
	})
	proxyAddr := proxyStatus.ListenAddr

	firstPayload := []byte("nitella-rs live proxy allow")
	firstResp := tcpRoundTrip(t, proxyAddr, firstPayload)
	if want := append([]byte("echo:"), firstPayload...); !bytes.Equal(firstResp, want) {
		t.Fatalf("allow response = %q, want %q", firstResp, want)
	}
	assertBackendReceived(t, backendReceived, firstPayload)

	blockRule, err := ctrl.AddRule(context.Background(), rustSmokeNodeID, &pbProxy.AddRuleRequest{
		ProxyId: createResp.ProxyId,
		Rule: &pbProxy.Rule{
			Name:     "block-localhost-smoke",
			Priority: 1,
			Enabled:  true,
			Action:   common.ActionType_ACTION_TYPE_BLOCK,
			Conditions: []*pbProxy.Condition{{
				Type:  common.ConditionType_CONDITION_TYPE_SOURCE_IP,
				Op:    common.Operator_OPERATOR_EQ,
				Value: "127.0.0.1",
			}},
		},
	})
	if err != nil {
		t.Fatalf("AddRule block localhost: %v", err)
	}
	if blockRule.Id == "" {
		t.Fatalf("AddRule returned empty rule id")
	}

	blockedPayload := []byte("must-not-reach-backend")
	assertBlockedTCP(t, proxyAddr, blockedPayload)
	assertBackendNotReached(t, backendReceived)

	if err := ctrl.RemoveRule(context.Background(), rustSmokeNodeID, createResp.ProxyId, blockRule.Id); err != nil {
		t.Fatalf("RemoveRule: %v", err)
	}

	secondPayload := []byte("nitella-rs live proxy after remove")
	secondResp := tcpRoundTrip(t, proxyAddr, secondPayload)
	if want := append([]byte("echo:"), secondPayload...); !bytes.Equal(secondResp, want) {
		t.Fatalf("post-remove response = %q, want %q", secondResp, want)
	}
	assertBackendReceived(t, backendReceived, secondPayload)

	waitForRustProxyStatus(t, ctrl, createResp.ProxyId, func(st *pbProxy.ProxyStatus) bool {
		return st.TotalConnections >= 2 && st.BytesIn >= int64(len(firstPayload)+len(secondPayload))
	})
}

func TestRustDirectConnectionManagementSmoke(t *testing.T) {
	ctrl, cleanup := newRustDirectSmokeController(t)
	defer cleanup()

	backendAddr, backendReceived, stopBackend := startHoldBackend(t)
	defer stopBackend()

	createResp, err := ctrl.CreateProxy(context.Background(), rustSmokeNodeID, &pbProxy.CreateProxyRequest{
		Name:           "rust-connection-management-smoke",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil {
		t.Fatalf("CreateProxy connection management: %v", err)
	}
	if !createResp.Success || createResp.ProxyId == "" {
		t.Fatalf("CreateProxy connection management response: success=%v proxy_id=%q error=%q", createResp.Success, createResp.ProxyId, createResp.ErrorMessage)
	}
	t.Cleanup(func() {
		_ = ctrl.DisableProxy(context.Background(), rustSmokeNodeID, createResp.ProxyId)
	})
	proxyStatus := waitForRustProxyStatus(t, ctrl, createResp.ProxyId, func(st *pbProxy.ProxyStatus) bool {
		return st.Running && st.ListenAddr != "" && st.ListenAddr != "127.0.0.1:0"
	})

	firstConn := dialAndWriteTCP(t, proxyStatus.ListenAddr, []byte("hold-one"))
	defer firstConn.Close()
	assertBackendReceived(t, backendReceived, []byte("hold-one"))
	active := waitForActiveConnections(t, ctrl, createResp.ProxyId, 1)
	if active[0].Id == "" || active[0].DestAddr != backendAddr {
		t.Fatalf("malformed active connection: %#v", active[0])
	}
	if err := ctrl.CloseConnection(context.Background(), rustSmokeNodeID, createResp.ProxyId, active[0].Id); err != nil {
		t.Fatalf("CloseConnection: %v", err)
	}
	assertConnClosed(t, firstConn)
	waitForActiveConnections(t, ctrl, createResp.ProxyId, 0)

	secondConn := dialAndWriteTCP(t, proxyStatus.ListenAddr, []byte("hold-two"))
	defer secondConn.Close()
	thirdConn := dialAndWriteTCP(t, proxyStatus.ListenAddr, []byte("hold-three"))
	defer thirdConn.Close()
	assertBackendReceivedAll(t, backendReceived, [][]byte{
		[]byte("hold-two"),
		[]byte("hold-three"),
	})
	waitForActiveConnections(t, ctrl, createResp.ProxyId, 2)
	if err := ctrl.CloseAllConnections(context.Background(), rustSmokeNodeID, createResp.ProxyId); err != nil {
		t.Fatalf("CloseAllConnections: %v", err)
	}
	assertConnClosed(t, secondConn)
	assertConnClosed(t, thirdConn)
	waitForActiveConnections(t, ctrl, createResp.ProxyId, 0)
}

func TestRustDirectStreamSmoke(t *testing.T) {
	ctrl, cleanup := newRustDirectSmokeController(t)
	defer cleanup()

	backendAddr, _, stopBackend := startEchoBackend(t)
	defer stopBackend()

	connCtx, cancelConnStream := context.WithCancel(context.Background())
	defer cancelConnStream()
	connEvents := make(chan *pbProxy.ConnectionEvent, 16)
	streamErrs := make(chan error, 2)
	go func() {
		streamErrs <- ctrl.StreamLocalConnections(connCtx, rustSmokeNodeID, func(event *pbProxy.ConnectionEvent) {
			select {
			case connEvents <- event:
			default:
			}
		})
	}()

	metricsCtx, cancelMetricStream := context.WithCancel(context.Background())
	defer cancelMetricStream()
	metrics := make(chan *pbProxy.MetricsSample, 16)
	go func() {
		streamErrs <- ctrl.StreamLocalMetrics(metricsCtx, rustSmokeNodeID, 1, func(sample *pbProxy.MetricsSample) {
			select {
			case metrics <- sample:
			default:
			}
		})
	}()
	time.Sleep(200 * time.Millisecond)

	createResp, err := ctrl.CreateProxy(context.Background(), rustSmokeNodeID, &pbProxy.CreateProxyRequest{
		Name:           "rust-stream-smoke",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil {
		t.Fatalf("CreateProxy stream smoke: %v", err)
	}
	t.Cleanup(func() {
		_ = ctrl.DisableProxy(context.Background(), rustSmokeNodeID, createResp.ProxyId)
	})
	proxyStatus := waitForRustProxyStatus(t, ctrl, createResp.ProxyId, func(st *pbProxy.ProxyStatus) bool {
		return st.Running && st.ListenAddr != "" && st.ListenAddr != "127.0.0.1:0"
	})

	payload := []byte("stream-smoke")
	resp := tcpRoundTrip(t, proxyStatus.ListenAddr, payload)
	if want := append([]byte("echo:"), payload...); !bytes.Equal(resp, want) {
		t.Fatalf("stream smoke response = %q, want %q", resp, want)
	}

	waitForConnectionEvent(t, connEvents, pbProxy.EventType_EVENT_TYPE_CONNECTED)
	closed := waitForConnectionEvent(t, connEvents, pbProxy.EventType_EVENT_TYPE_CLOSED)
	if closed.BytesIn < int64(len(payload)) || closed.BytesOut < int64(len("echo:")+len(payload)) {
		t.Fatalf("closed event byte counters too small: %#v", closed)
	}
	waitForMetricSample(t, metrics, func(sample *pbProxy.MetricsSample) bool {
		return sample.TotalConns > 0
	})

	cancelConnStream()
	cancelMetricStream()
	select {
	case err := <-streamErrs:
		if err != nil {
			t.Fatalf("stream returned error after cancel: %v", err)
		}
	case <-time.After(2 * time.Second):
		t.Fatalf("stream did not stop after cancel")
	}
}

func TestRustDirectTLSMTLSSmoke(t *testing.T) {
	ctrl, cleanup := newRustDirectSmokeController(t)
	defer cleanup()

	backendAddr, backendReceived, stopBackend := startEchoBackend(t)
	defer stopBackend()
	certs := generateMTLSMaterial(t)

	createResp, err := ctrl.CreateProxy(context.Background(), rustSmokeNodeID, &pbProxy.CreateProxyRequest{
		Name:           "rust-mtls-smoke",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
		CertPem:        certs.serverCertPEM,
		KeyPem:         certs.serverKeyPEM,
		CaPem:          certs.caCertPEM,
		ClientAuthType: pbProxy.ClientAuthType_CLIENT_AUTH_REQUIRE,
	})
	if err != nil {
		t.Fatalf("CreateProxy mTLS: %v", err)
	}
	t.Cleanup(func() {
		_ = ctrl.DisableProxy(context.Background(), rustSmokeNodeID, createResp.ProxyId)
	})
	proxyStatus := waitForRustProxyStatus(t, ctrl, createResp.ProxyId, func(st *pbProxy.ProxyStatus) bool {
		return st.Running && st.ListenAddr != "" && st.ListenAddr != "127.0.0.1:0"
	})

	assertMTLSWithoutClientCertFails(t, proxyStatus.ListenAddr, certs.caPool)
	assertBackendNotReached(t, backendReceived)

	payload := []byte("mtls-live-proxy")
	resp := tlsRoundTrip(t, proxyStatus.ListenAddr, payload, certs.caPool, certs.clientCert)
	if want := append([]byte("echo:"), payload...); !bytes.Equal(resp, want) {
		t.Fatalf("mTLS response = %q, want %q", resp, want)
	}
	assertBackendReceived(t, backendReceived, payload)
}

func TestRustDirectHealthCheckSmoke(t *testing.T) {
	ctrl, cleanup := newRustDirectSmokeController(t)
	defer cleanup()

	backendAddr, _, stopBackend := startEchoBackend(t)

	createResp, err := ctrl.CreateProxy(context.Background(), rustSmokeNodeID, &pbProxy.CreateProxyRequest{
		Name:           "rust-health-smoke",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
		HealthCheck: &pbProxy.HealthCheckConfig{
			Interval:       "1s",
			Timeout:        "500ms",
			Type:           pbProxy.HealthCheckType_HEALTH_CHECK_TYPE_TCP,
			ExpectedStatus: 0,
		},
	})
	if err != nil {
		t.Fatalf("CreateProxy health: %v", err)
	}
	t.Cleanup(func() {
		_ = ctrl.DisableProxy(context.Background(), rustSmokeNodeID, createResp.ProxyId)
	})

	waitForRustProxyStatusTimeout(t, ctrl, createResp.ProxyId, 8*time.Second, func(st *pbProxy.ProxyStatus) bool {
		return st.HealthStatus == pbProxy.HealthStatus_HEALTH_STATUS_HEALTHY
	})

	stopBackend()
	waitForRustProxyStatusTimeout(t, ctrl, createResp.ProxyId, 8*time.Second, func(st *pbProxy.ProxyStatus) bool {
		return st.HealthStatus == pbProxy.HealthStatus_HEALTH_STATUS_UNHEALTHY
	})
}

func TestRustDirectRuntimeCommandsSmoke(t *testing.T) {
	ctrl, cleanup := newRustDirectSmokeController(t)
	defer cleanup()

	backendAddr, backendReceived, stopBackend := startEchoBackend(t)
	defer stopBackend()

	createResp, err := ctrl.CreateProxy(context.Background(), rustSmokeNodeID, &pbProxy.CreateProxyRequest{
		Name:           "rust-runtime-commands-smoke",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil {
		t.Fatalf("CreateProxy runtime commands: %v", err)
	}
	t.Cleanup(func() {
		_ = ctrl.DisableProxy(context.Background(), rustSmokeNodeID, createResp.ProxyId)
	})
	proxyStatus := waitForRustProxyStatus(t, ctrl, createResp.ProxyId, func(st *pbProxy.ProxyStatus) bool {
		return st.Running && st.ListenAddr != "" && st.ListenAddr != "127.0.0.1:0"
	})

	beforePayload := []byte("runtime-before-restart")
	beforeResp := tcpRoundTrip(t, proxyStatus.ListenAddr, beforePayload)
	if want := append([]byte("echo:"), beforePayload...); !bytes.Equal(beforeResp, want) {
		t.Fatalf("runtime pre-restart response = %q, want %q", beforeResp, want)
	}
	assertBackendReceived(t, backendReceived, beforePayload)

	var restartResp pbProxy.RestartListenersResponse
	sendRustDirectCommand(t, ctrl, pbHub.CommandType_COMMAND_TYPE_RESTART_LISTENERS, nil, &restartResp)
	if !restartResp.Success || restartResp.RestartedCount < 1 {
		t.Fatalf("RestartListeners response: success=%v restarted=%d error=%q", restartResp.Success, restartResp.RestartedCount, restartResp.ErrorMessage)
	}
	restartedStatus := waitForRustProxyStatus(t, ctrl, createResp.ProxyId, func(st *pbProxy.ProxyStatus) bool {
		return st.Running && st.ListenAddr != "" && st.ListenAddr != "127.0.0.1:0"
	})

	afterPayload := []byte("runtime-after-restart")
	afterResp := tcpRoundTrip(t, restartedStatus.ListenAddr, afterPayload)
	if want := append([]byte("echo:"), afterPayload...); !bytes.Equal(afterResp, want) {
		t.Fatalf("runtime post-restart response = %q, want %q", afterResp, want)
	}
	assertBackendReceived(t, backendReceived, afterPayload)

	geoIP := "8.8.8.8"
	geoProvider, geoRequests, stopGeoProvider := startGeoIPProvider(t, geoIP)
	defer stopGeoProvider()

	var initialGeoStatus pbProxy.GetGeoIPStatusResponse
	sendRustDirectCommand(t, ctrl, pbHub.CommandType_COMMAND_TYPE_GET_GEOIP_STATUS, nil, &initialGeoStatus)
	if !initialGeoStatus.Enabled || initialGeoStatus.Mode == "" {
		t.Fatalf("initial GeoIP status missing fields: %#v", &initialGeoStatus)
	}

	var configureResp pbProxy.ConfigureGeoIPResponse
	sendRustDirectCommand(t, ctrl, pbHub.CommandType_COMMAND_TYPE_CONFIGURE_GEOIP, &pbProxy.ConfigureGeoIPRequest{
		Mode:     pbProxy.ConfigureGeoIPRequest_MODE_REMOTE_API,
		Provider: geoProvider,
	}, &configureResp)
	if !configureResp.Success {
		t.Fatalf("ConfigureGeoIP failed: %q", configureResp.Error)
	}

	var configuredGeoStatus pbProxy.GetGeoIPStatusResponse
	sendRustDirectCommand(t, ctrl, pbHub.CommandType_COMMAND_TYPE_GET_GEOIP_STATUS, nil, &configuredGeoStatus)
	if configuredGeoStatus.Mode != "embedded" {
		t.Fatalf("configured GeoIP mode = %q, want embedded: %#v", configuredGeoStatus.Mode, &configuredGeoStatus)
	}
	if configuredGeoStatus.Provider != "" || configuredGeoStatus.CityDbPath != "" || configuredGeoStatus.IspDbPath != "" {
		t.Fatalf("configured GeoIP status should match Go's embedded response: %#v", &configuredGeoStatus)
	}

	var lookupResp pbProxy.LookupIPResponse
	sendRustDirectCommand(t, ctrl, pbHub.CommandType_COMMAND_TYPE_LOOKUP_IP, &pbProxy.LookupIPRequest{Ip: geoIP}, &lookupResp)
	geo := lookupResp.GetGeo()
	if geo == nil {
		t.Fatalf("LookupIP returned nil geo payload")
	}
	if geo.GetCountryCode() != "US" || geo.GetCountry() != "United States" || geo.GetCity() != "Mountain View" || geo.GetIsp() != "Example ISP" || geo.GetSource() != "remote" {
		t.Fatalf("LookupIP remote GeoIP mismatch: %#v", geo)
	}
	select {
	case path := <-geoRequests:
		if path != "/lookup/"+geoIP {
			t.Fatalf("GeoIP provider path = %q, want %q", path, "/lookup/"+geoIP)
		}
	case <-time.After(time.Second):
		t.Fatalf("GeoIP provider was not called")
	}
}

func TestRustDirectGeoIPLocalDBSmoke(t *testing.T) {
	ctrl, cleanup := newRustDirectSmokeController(t)
	defer cleanup()

	cityDB := geoIPTestFixturePath(t, "GeoIP2-City-Test.mmdb")
	ispDB := geoIPTestFixturePath(t, "GeoIP2-ISP-Test.mmdb")

	var configureResp pbProxy.ConfigureGeoIPResponse
	sendRustDirectCommand(t, ctrl, pbHub.CommandType_COMMAND_TYPE_CONFIGURE_GEOIP, &pbProxy.ConfigureGeoIPRequest{
		Mode:       pbProxy.ConfigureGeoIPRequest_MODE_LOCAL_DB,
		CityDbPath: cityDB,
		IspDbPath:  ispDB,
	}, &configureResp)
	if !configureResp.Success {
		t.Fatalf("ConfigureGeoIP local DB failed: %q", configureResp.Error)
	}

	var status pbProxy.GetGeoIPStatusResponse
	sendRustDirectCommand(t, ctrl, pbHub.CommandType_COMMAND_TYPE_GET_GEOIP_STATUS, nil, &status)
	if status.Mode != "embedded" {
		t.Fatalf("local GeoIP mode = %q, want embedded: %#v", status.Mode, &status)
	}
	if status.CityDbPath != "" || status.IspDbPath != "" || status.Provider != "" {
		t.Fatalf("local GeoIP status should match Go's embedded response: %#v", &status)
	}

	var cityLookup pbProxy.LookupIPResponse
	sendRustDirectCommand(t, ctrl, pbHub.CommandType_COMMAND_TYPE_LOOKUP_IP, &pbProxy.LookupIPRequest{Ip: "81.2.69.142"}, &cityLookup)
	city := cityLookup.GetGeo()
	if city == nil {
		t.Fatalf("local City lookup returned nil geo payload")
	}
	if city.GetSource() != "local-db" || city.GetCountryCode() != "GB" || city.GetCountry() != "GB" || city.GetCity() != "London" || city.GetRegionName() != "England" || city.GetTimezone() != "Europe/London" {
		t.Fatalf("local City GeoIP mismatch: %#v", city)
	}

	var ispLookup pbProxy.LookupIPResponse
	sendRustDirectCommand(t, ctrl, pbHub.CommandType_COMMAND_TYPE_LOOKUP_IP, &pbProxy.LookupIPRequest{Ip: "12.87.118.123"}, &ispLookup)
	isp := ispLookup.GetGeo()
	if isp == nil {
		t.Fatalf("local ISP lookup returned nil geo payload")
	}
	if isp.GetSource() != "local-db" || isp.GetIsp() != "AT&T Services" || isp.GetOrg() != "AT&T Worldnet Services" {
		t.Fatalf("local ISP GeoIP mismatch: %#v", isp)
	}
}

func TestRustDirectProxySoakSmoke(t *testing.T) {
	ctrl, cleanup := newRustDirectSmokeController(t)
	defer cleanup()

	backendAddr, _, stopBackend := startEchoBackend(t)
	defer stopBackend()

	createResp, err := ctrl.CreateProxy(context.Background(), rustSmokeNodeID, &pbProxy.CreateProxyRequest{
		Name:           "rust-soak-smoke",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil {
		t.Fatalf("CreateProxy soak: %v", err)
	}
	if !createResp.Success || createResp.ProxyId == "" {
		t.Fatalf("CreateProxy soak response: success=%v proxy_id=%q error=%q", createResp.Success, createResp.ProxyId, createResp.ErrorMessage)
	}
	t.Cleanup(func() {
		_ = ctrl.DisableProxy(context.Background(), rustSmokeNodeID, createResp.ProxyId)
	})
	proxyStatus := waitForRustProxyStatus(t, ctrl, createResp.ProxyId, func(st *pbProxy.ProxyStatus) bool {
		return st.Running && st.ListenAddr != "" && st.ListenAddr != "127.0.0.1:0"
	})

	const totalRequests = 160
	const workers = 8
	jobs := make(chan int, totalRequests)
	errs := make(chan error, totalRequests)
	var bytesIn int64
	var bytesOut int64

	var wg sync.WaitGroup
	for worker := 0; worker < workers; worker++ {
		wg.Add(1)
		go func(worker int) {
			defer wg.Done()
			for job := range jobs {
				payload := []byte(fmt.Sprintf("soak-%02d-%03d-%s", worker, job, strings.Repeat("x", 96)))
				resp, err := tcpRoundTripErr(proxyStatus.ListenAddr, payload, 5*time.Second)
				if err != nil {
					errs <- err
					continue
				}
				want := append([]byte("echo:"), payload...)
				if !bytes.Equal(resp, want) {
					errs <- fmt.Errorf("soak response = %q, want %q", resp, want)
					continue
				}
				atomic.AddInt64(&bytesIn, int64(len(payload)))
				atomic.AddInt64(&bytesOut, int64(len(want)))
			}
		}(worker)
	}
	for i := 0; i < totalRequests; i++ {
		jobs <- i
	}
	close(jobs)
	wg.Wait()
	close(errs)

	for err := range errs {
		if err != nil {
			t.Fatalf("soak traffic failed: %v", err)
		}
	}

	waitForRustProxyStatusTimeout(t, ctrl, createResp.ProxyId, 8*time.Second, func(st *pbProxy.ProxyStatus) bool {
		return st.TotalConnections >= totalRequests &&
			st.BytesIn >= atomic.LoadInt64(&bytesIn) &&
			st.BytesOut >= atomic.LoadInt64(&bytesOut)
	})
}

func TestRustDirectApprovalSmoke(t *testing.T) {
	ctrl, cleanup := newRustDirectSmokeController(t)
	defer cleanup()

	backendAddr, backendReceived, stopBackend := startEchoBackend(t)
	defer stopBackend()

	connCtx, cancelConnStream := context.WithCancel(context.Background())
	defer cancelConnStream()
	connEvents := make(chan *pbProxy.ConnectionEvent, 16)
	streamErrs := make(chan error, 1)
	go func() {
		streamErrs <- ctrl.StreamLocalConnections(connCtx, rustSmokeNodeID, func(event *pbProxy.ConnectionEvent) {
			select {
			case connEvents <- event:
			default:
			}
		})
	}()
	time.Sleep(200 * time.Millisecond)

	createResp, err := ctrl.CreateProxy(context.Background(), rustSmokeNodeID, &pbProxy.CreateProxyRequest{
		Name:           "rust-approval-smoke",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL,
	})
	if err != nil {
		t.Fatalf("CreateProxy approval: %v", err)
	}
	t.Cleanup(func() {
		_ = ctrl.DisableProxy(context.Background(), rustSmokeNodeID, createResp.ProxyId)
	})
	proxyStatus := waitForRustProxyStatus(t, ctrl, createResp.ProxyId, func(st *pbProxy.ProxyStatus) bool {
		return st.Running && st.ListenAddr != "" && st.ListenAddr != "127.0.0.1:0"
	})

	payload := []byte("approval-live-proxy")
	respCh := make(chan []byte, 1)
	errCh := make(chan error, 1)
	go func() {
		resp, err := tcpRoundTripErr(proxyStatus.ListenAddr, payload, 5*time.Second)
		if err != nil {
			errCh <- err
			return
		}
		respCh <- resp
	}()

	pending := waitForConnectionEvent(t, connEvents, pbProxy.EventType_EVENT_TYPE_PENDING_APPROVAL)
	if pending.ConnId == "" {
		t.Fatalf("pending approval event did not include request id: %#v", pending)
	}
	if err := ctrl.ResolveApproval(context.Background(), rustSmokeNodeID, pending.ConnId, true, 30, "smoke allow"); err != nil {
		t.Fatalf("ResolveApproval: %v", err)
	}

	select {
	case err := <-errCh:
		t.Fatalf("approval connection failed: %v", err)
	case resp := <-respCh:
		if want := append([]byte("echo:"), payload...); !bytes.Equal(resp, want) {
			t.Fatalf("approval response = %q, want %q", resp, want)
		}
	case <-time.After(5 * time.Second):
		t.Fatalf("approval connection did not complete after resolution")
	}
	assertBackendReceived(t, backendReceived, payload)

	approvals, err := ctrl.ListActiveApprovals(context.Background(), rustSmokeNodeID, createResp.ProxyId, "127.0.0.1")
	if err != nil {
		t.Fatalf("ListActiveApprovals: %v", err)
	}
	if len(approvals) != 1 || !approvals[0].Allowed || approvals[0].Key == "" {
		t.Fatalf("unexpected active approvals after allow: %#v", approvals)
	}
	if _, err := ctrl.CancelApproval(context.Background(), rustSmokeNodeID, approvals[0].Key, false); err != nil {
		t.Fatalf("CancelApproval: %v", err)
	}
	approvals, err = ctrl.ListActiveApprovals(context.Background(), rustSmokeNodeID, createResp.ProxyId, "127.0.0.1")
	if err != nil {
		t.Fatalf("ListActiveApprovals after cancel: %v", err)
	}
	if len(approvals) != 0 {
		t.Fatalf("approvals remained after cancel: %#v", approvals)
	}

	cancelConnStream()
	select {
	case err := <-streamErrs:
		if err != nil {
			t.Fatalf("approval stream returned error after cancel: %v", err)
		}
	case <-time.After(2 * time.Second):
		t.Fatalf("approval stream did not stop after cancel")
	}
}

func TestRustDirectProxyPersistenceSeed(t *testing.T) {
	backendAddr := os.Getenv("NITELLA_RS_PERSIST_BACKEND_ADDR")
	if backendAddr == "" {
		t.Skip("set NITELLA_RS_PERSIST_BACKEND_ADDR")
	}
	ctrl, cleanup := newRustDirectSmokeController(t)
	defer cleanup()

	createResp, err := ctrl.CreateProxy(context.Background(), rustSmokeNodeID, &pbProxy.CreateProxyRequest{
		Name:           "rust-persistence-smoke",
		ListenAddr:     "127.0.0.1:0",
		DefaultBackend: backendAddr,
		DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
	})
	if err != nil {
		t.Fatalf("CreateProxy persistence seed: %v", err)
	}
	if !createResp.Success || createResp.ProxyId == "" {
		t.Fatalf("CreateProxy persistence response: success=%v proxy_id=%q error=%q", createResp.Success, createResp.ProxyId, createResp.ErrorMessage)
	}

	proxyStatus := waitForRustProxyStatus(t, ctrl, createResp.ProxyId, func(st *pbProxy.ProxyStatus) bool {
		return st.Running && st.ListenAddr != "" && st.ListenAddr != "127.0.0.1:0"
	})

	payload := []byte("nitella-rs persistence seed")
	resp := tcpRoundTrip(t, proxyStatus.ListenAddr, payload)
	if want := append([]byte("echo:"), payload...); !bytes.Equal(resp, want) {
		t.Fatalf("persistence seed response = %q, want %q", resp, want)
	}
}

func TestRustConfigProxyTrafficSmoke(t *testing.T) {
	proxyAddr := os.Getenv("NITELLA_RS_CONFIG_PROXY_ADDR")
	if proxyAddr == "" {
		t.Skip("set NITELLA_RS_CONFIG_PROXY_ADDR")
	}

	payload := []byte("nitella-rs config proxy smoke")
	resp := tcpRoundTrip(t, proxyAddr, payload)
	if want := append([]byte("echo:"), payload...); !bytes.Equal(resp, want) {
		t.Fatalf("config proxy response = %q, want %q", resp, want)
	}
}

func TestRustConfigBlockProxySmoke(t *testing.T) {
	proxyAddr := os.Getenv("NITELLA_RS_CONFIG_BLOCK_PROXY_ADDR")
	if proxyAddr == "" {
		t.Skip("set NITELLA_RS_CONFIG_BLOCK_PROXY_ADDR")
	}

	payload := []byte("nitella-rs config block smoke")
	assertBlockedTCP(t, proxyAddr, payload)

	capturePath := os.Getenv("NITELLA_RS_CONFIG_BACKEND_CAPTURE")
	if capturePath == "" {
		return
	}
	time.Sleep(300 * time.Millisecond)
	content, err := os.ReadFile(capturePath)
	if err != nil {
		t.Fatalf("read config backend capture: %v", err)
	}
	if bytes.Contains(content, payload) {
		t.Fatalf("blocked config proxy forwarded payload to backend")
	}
}

func TestRustDirectProxyRestoredTrafficSmoke(t *testing.T) {
	ctrl, cleanup := newRustDirectSmokeController(t)
	defer cleanup()

	proxies, err := ctrl.ListProxies(context.Background(), rustSmokeNodeID)
	if err != nil {
		t.Fatalf("ListProxies restored: %v", err)
	}
	if len(proxies) != 1 {
		t.Fatalf("restored proxy count = %d, want 1: %#v", len(proxies), proxies)
	}
	proxy := proxies[0]
	if !proxy.Running || proxy.ListenAddr == "" {
		t.Fatalf("restored proxy not running: %#v", proxy)
	}

	payload := []byte("nitella-rs restored proxy smoke")
	resp := tcpRoundTrip(t, proxy.ListenAddr, payload)
	if want := append([]byte("echo:"), payload...); !bytes.Equal(resp, want) {
		t.Fatalf("restored proxy response = %q, want %q", resp, want)
	}
}

func newRustDirectSmokeController(t *testing.T) (*Controller, func()) {
	t.Helper()

	addr := os.Getenv("NITELLA_RS_ADMIN_ADDR")
	token := os.Getenv("NITELLA_RS_ADMIN_TOKEN")
	caPath := os.Getenv("NITELLA_RS_ADMIN_CA")
	if addr == "" || token == "" || caPath == "" {
		t.Skip("set NITELLA_RS_ADMIN_ADDR, NITELLA_RS_ADMIN_TOKEN, and NITELLA_RS_ADMIN_CA")
	}

	caPEM, err := os.ReadFile(caPath)
	if err != nil {
		t.Fatalf("read admin CA: %v", err)
	}
	nodePubKey, err := ed25519PublicKeyFromCertPEM(caPEM)
	if err != nil {
		t.Fatalf("extract node public key: %v", err)
	}

	roots := x509.NewCertPool()
	if !roots.AppendCertsFromPEM(caPEM) {
		t.Fatalf("parse admin CA")
	}

	serverName := os.Getenv("NITELLA_RS_ADMIN_TLS_SERVER_NAME")
	if serverName == "" {
		serverName = "localhost"
	}
	tlsConfig := &tls.Config{
		RootCAs:    roots,
		ServerName: serverName,
		MinVersion: tls.VersionTLS13,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	conn, err := grpc.DialContext(
		ctx,
		addr,
		grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)),
		grpc.WithBlock(),
	)
	if err != nil {
		t.Fatalf("dial Rust admin server: %v", err)
	}

	id, err := identity.Create(&identity.Config{
		CommonName: "rust-direct-admin-smoke",
		ValidYears: 1,
	})
	if err != nil {
		t.Fatalf("create identity: %v", err)
	}

	ctrl := New(Config{})
	ctrl.SetIdentity(id)
	ctrl.SetLocalConnection(rustSmokeNodeID, &LocalConnection{
		Client:     pbProxy.NewProxyControlServiceClient(conn),
		Token:      token,
		NodePubKey: nodePubKey,
	})

	return ctrl, func() { _ = conn.Close() }
}

func sendRustDirectCommand(t *testing.T, ctrl *Controller, cmdType pbHub.CommandType, payload proto.Message, out proto.Message) {
	t.Helper()

	var payloadBytes []byte
	if payload != nil {
		var err error
		payloadBytes, err = proto.Marshal(payload)
		if err != nil {
			t.Fatalf("marshal %T: %v", payload, err)
		}
	}

	ctrl.mu.RLock()
	lc := ctrl.localClients[rustSmokeNodeID]
	id := ctrl.identity
	ctrl.mu.RUnlock()
	if lc == nil {
		t.Fatalf("missing Rust direct local connection")
	}
	if id == nil || id.RootKey == nil {
		t.Fatalf("missing Rust direct test identity")
	}

	result, err := sendCommandLocal(context.Background(), lc, cmdType, payloadBytes, id.RootKey, id.Fingerprint)
	if err != nil {
		t.Fatalf("send %s: %v", cmdType.String(), err)
	}
	if result.Status != "OK" {
		t.Fatalf("%s returned status=%q error=%q", cmdType.String(), result.Status, result.ErrorMessage)
	}
	if out != nil {
		if err := proto.Unmarshal(result.ResponsePayload, out); err != nil {
			t.Fatalf("unmarshal %s response into %T: %v", cmdType.String(), out, err)
		}
	}
}

func ed25519PublicKeyFromCertPEM(certPEM []byte) (ed25519.PublicKey, error) {
	block, _ := pem.Decode(certPEM)
	if block == nil {
		return nil, fmt.Errorf("failed to decode PEM")
	}
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return nil, err
	}
	pub, ok := cert.PublicKey.(ed25519.PublicKey)
	if !ok {
		return nil, fmt.Errorf("certificate public key is not Ed25519")
	}
	return pub, nil
}

func startEchoBackend(t *testing.T) (string, <-chan []byte, func()) {
	t.Helper()

	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("listen echo backend: %v", err)
	}

	received := make(chan []byte, 16)
	done := make(chan struct{})
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		defer wg.Done()
		for {
			conn, err := ln.Accept()
			if err != nil {
				if errors.Is(err, net.ErrClosed) {
					return
				}
				select {
				case <-done:
					return
				default:
				}
				t.Logf("echo backend accept: %v", err)
				return
			}
			wg.Add(1)
			go func(conn net.Conn) {
				defer wg.Done()
				defer conn.Close()
				_ = conn.SetDeadline(time.Now().Add(3 * time.Second))
				buf := make([]byte, 4096)
				n, err := conn.Read(buf)
				if err != nil {
					return
				}
				payload := append([]byte(nil), buf[:n]...)
				select {
				case received <- payload:
				default:
				}
				_, _ = conn.Write(append([]byte("echo:"), payload...))
			}(conn)
		}
	}()

	stop := func() {
		close(done)
		_ = ln.Close()
		wg.Wait()
	}
	return ln.Addr().String(), received, stop
}

func startGeoIPProvider(t *testing.T, ip string) (string, <-chan string, func()) {
	t.Helper()

	requests := make(chan string, 4)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		select {
		case requests <- r.URL.Path:
		default:
		}
		if r.URL.Path != "/lookup/"+ip {
			http.Error(w, "unexpected GeoIP path", http.StatusNotFound)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = fmt.Fprint(w, `{"countryCode":"US","country":"United States","city":"Mountain View","isp":"Example ISP"}`)
	}))

	return server.URL + "/lookup/{ip}", requests, server.Close
}

func geoIPTestFixturePath(t *testing.T, name string) string {
	t.Helper()

	_, file, _, ok := runtime.Caller(0)
	if !ok {
		t.Fatalf("resolve test source path")
	}
	path := filepath.Clean(filepath.Join(filepath.Dir(file), "..", "..", "testdata", "geoip", name))
	if _, err := os.Stat(path); err != nil {
		t.Fatalf("GeoIP fixture %s is unavailable: %v", path, err)
	}
	return path
}

func startHoldBackend(t *testing.T) (string, <-chan []byte, func()) {
	t.Helper()

	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("listen hold backend: %v", err)
	}

	received := make(chan []byte, 16)
	done := make(chan struct{})
	var wg sync.WaitGroup
	var mu sync.Mutex
	active := map[net.Conn]struct{}{}

	wg.Add(1)
	go func() {
		defer wg.Done()
		for {
			conn, err := ln.Accept()
			if err != nil {
				if errors.Is(err, net.ErrClosed) {
					return
				}
				select {
				case <-done:
					return
				default:
				}
				t.Logf("hold backend accept: %v", err)
				return
			}
			mu.Lock()
			active[conn] = struct{}{}
			mu.Unlock()
			wg.Add(1)
			go func(conn net.Conn) {
				defer wg.Done()
				defer conn.Close()
				defer func() {
					mu.Lock()
					delete(active, conn)
					mu.Unlock()
				}()

				buf := make([]byte, 4096)
				for {
					n, err := conn.Read(buf)
					if n > 0 {
						payload := append([]byte(nil), buf[:n]...)
						select {
						case received <- payload:
						default:
						}
					}
					if err != nil {
						return
					}
				}
			}(conn)
		}
	}()

	stop := func() {
		close(done)
		_ = ln.Close()
		mu.Lock()
		for conn := range active {
			_ = conn.Close()
		}
		mu.Unlock()
		wg.Wait()
	}
	return ln.Addr().String(), received, stop
}

func tcpRoundTrip(t *testing.T, addr string, payload []byte) []byte {
	t.Helper()

	response, err := tcpRoundTripErr(addr, payload, 3*time.Second)
	if err != nil {
		t.Fatal(err)
	}
	return response
}

func tcpRoundTripErr(addr string, payload []byte, timeout time.Duration) ([]byte, error) {
	conn, err := net.DialTimeout("tcp", addr, timeout)
	if err != nil {
		return nil, fmt.Errorf("dial proxy %s: %w", addr, err)
	}
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(timeout))

	if _, err := conn.Write(payload); err != nil {
		return nil, fmt.Errorf("write proxy payload: %w", err)
	}

	response := make([]byte, len("echo:")+len(payload))
	if _, err := io.ReadFull(conn, response); err != nil {
		return nil, fmt.Errorf("read proxy response: %w", err)
	}
	return response, nil
}

func dialAndWriteTCP(t *testing.T, addr string, payload []byte) net.Conn {
	t.Helper()
	conn, err := net.DialTimeout("tcp", addr, 3*time.Second)
	if err != nil {
		t.Fatalf("dial proxy %s: %v", addr, err)
	}
	_ = conn.SetDeadline(time.Now().Add(10 * time.Second))
	if _, err := conn.Write(payload); err != nil {
		conn.Close()
		t.Fatalf("write proxy payload: %v", err)
	}
	return conn
}

func assertConnClosed(t *testing.T, conn net.Conn) {
	t.Helper()
	_ = conn.SetReadDeadline(time.Now().Add(2 * time.Second))
	buf := make([]byte, 1)
	n, err := conn.Read(buf)
	if n > 0 {
		t.Fatalf("connection returned data while expecting close: %q", buf[:n])
	}
	if err == nil {
		t.Fatalf("connection read returned no data and no error")
	}
}

func assertBlockedTCP(t *testing.T, addr string, payload []byte) {
	t.Helper()

	conn, err := net.DialTimeout("tcp", addr, 3*time.Second)
	if err != nil {
		t.Fatalf("dial blocked proxy %s: %v", addr, err)
	}
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(750 * time.Millisecond))

	_, _ = conn.Write(payload)
	buf := make([]byte, 1)
	n, err := conn.Read(buf)
	if n > 0 {
		t.Fatalf("blocked proxy returned data: %q", buf[:n])
	}
	if err == nil {
		t.Fatalf("blocked proxy read returned no data and no error")
	}
}

func assertBackendReceived(t *testing.T, received <-chan []byte, want []byte) {
	t.Helper()
	select {
	case got := <-received:
		if !bytes.Equal(got, want) {
			t.Fatalf("backend received %q, want %q", got, want)
		}
	case <-time.After(2 * time.Second):
		t.Fatalf("backend did not receive payload %q", want)
	}
}

func assertBackendReceivedAll(t *testing.T, received <-chan []byte, wants [][]byte) {
	t.Helper()

	remaining := make(map[string]int, len(wants))
	for _, want := range wants {
		remaining[string(want)]++
	}

	deadline := time.After(2 * time.Second)
	for len(remaining) > 0 {
		select {
		case got := <-received:
			key := string(got)
			count := remaining[key]
			if count == 0 {
				t.Fatalf("backend received unexpected payload %q, remaining %v", got, remaining)
			}
			if count == 1 {
				delete(remaining, key)
			} else {
				remaining[key] = count - 1
			}
		case <-deadline:
			t.Fatalf("backend did not receive expected payloads; remaining %v", remaining)
		}
	}
}

func assertBackendNotReached(t *testing.T, received <-chan []byte) {
	t.Helper()
	select {
	case got := <-received:
		t.Fatalf("backend received blocked payload %q", got)
	case <-time.After(300 * time.Millisecond):
	}
}

func waitForRustProxyStatus(t *testing.T, ctrl *Controller, proxyID string, pred func(*pbProxy.ProxyStatus) bool) *pbProxy.ProxyStatus {
	t.Helper()
	return waitForRustProxyStatusTimeout(t, ctrl, proxyID, 5*time.Second, pred)
}

func waitForRustProxyStatusTimeout(t *testing.T, ctrl *Controller, proxyID string, timeout time.Duration, pred func(*pbProxy.ProxyStatus) bool) *pbProxy.ProxyStatus {
	t.Helper()
	deadline := time.Now().Add(timeout)
	var last *pbProxy.ProxyStatus
	for time.Now().Before(deadline) {
		proxies, err := ctrl.ListProxies(context.Background(), rustSmokeNodeID)
		if err == nil {
			for _, proxy := range proxies {
				if proxy.ProxyId == proxyID {
					last = proxy
					if pred(proxy) {
						return proxy
					}
				}
			}
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("proxy %s did not reach expected status; last=%#v", proxyID, last)
	return nil
}

func waitForActiveConnections(t *testing.T, ctrl *Controller, proxyID string, want int) []*pbProxy.ActiveConnection {
	t.Helper()
	deadline := time.Now().Add(5 * time.Second)
	var last []*pbProxy.ActiveConnection
	for time.Now().Before(deadline) {
		conns, err := ctrl.GetActiveConnections(context.Background(), rustSmokeNodeID, proxyID)
		if err == nil {
			last = conns
			if len(conns) == want {
				return conns
			}
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("active connection count for %s = %d, want %d: %#v", proxyID, len(last), want, last)
	return nil
}

func waitForConnectionEvent(t *testing.T, events <-chan *pbProxy.ConnectionEvent, eventType pbProxy.EventType) *pbProxy.ConnectionEvent {
	t.Helper()
	timeout := time.After(5 * time.Second)
	for {
		select {
		case event := <-events:
			if event.GetEventType() == eventType {
				return event
			}
		case <-timeout:
			t.Fatalf("timed out waiting for connection event %s", eventType)
		}
	}
}

func waitForMetricSample(t *testing.T, metrics <-chan *pbProxy.MetricsSample, pred func(*pbProxy.MetricsSample) bool) *pbProxy.MetricsSample {
	t.Helper()
	timeout := time.After(5 * time.Second)
	for {
		select {
		case sample := <-metrics:
			if pred(sample) {
				return sample
			}
		case <-timeout:
			t.Fatalf("timed out waiting for metrics sample")
		}
	}
}

type mtlsMaterial struct {
	caCertPEM     string
	serverCertPEM string
	serverKeyPEM  string
	clientCert    tls.Certificate
	caPool        *x509.CertPool
}

func generateMTLSMaterial(t *testing.T) mtlsMaterial {
	t.Helper()
	now := time.Now()

	caPub, caKey, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatalf("generate CA key: %v", err)
	}
	caTemplate := &x509.Certificate{
		SerialNumber:          big.NewInt(1),
		Subject:               pkix.Name{CommonName: "Nitella Rust Smoke CA"},
		NotBefore:             now.Add(-time.Hour),
		NotAfter:              now.Add(24 * time.Hour),
		KeyUsage:              x509.KeyUsageCertSign | x509.KeyUsageDigitalSignature,
		BasicConstraintsValid: true,
		IsCA:                  true,
	}
	caDER, err := x509.CreateCertificate(rand.Reader, caTemplate, caTemplate, caPub, caKey)
	if err != nil {
		t.Fatalf("create CA cert: %v", err)
	}
	caCert, err := x509.ParseCertificate(caDER)
	if err != nil {
		t.Fatalf("parse CA cert: %v", err)
	}

	serverCertPEM, serverKeyPEM := signedCertPEM(t, caCert, caKey, &x509.Certificate{
		SerialNumber: big.NewInt(2),
		Subject:      pkix.Name{CommonName: "localhost"},
		DNSNames:     []string{"localhost"},
		IPAddresses:  []net.IP{net.ParseIP("127.0.0.1")},
		NotBefore:    now.Add(-time.Hour),
		NotAfter:     now.Add(24 * time.Hour),
		KeyUsage:     x509.KeyUsageDigitalSignature | x509.KeyUsageKeyEncipherment,
		ExtKeyUsage:  []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
	})
	clientCertPEM, clientKeyPEM := signedCertPEM(t, caCert, caKey, &x509.Certificate{
		SerialNumber: big.NewInt(3),
		Subject:      pkix.Name{CommonName: "nitella-rust-smoke-client"},
		NotBefore:    now.Add(-time.Hour),
		NotAfter:     now.Add(24 * time.Hour),
		KeyUsage:     x509.KeyUsageDigitalSignature,
		ExtKeyUsage:  []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth},
	})
	clientCert, err := tls.X509KeyPair([]byte(clientCertPEM), []byte(clientKeyPEM))
	if err != nil {
		t.Fatalf("parse client cert: %v", err)
	}
	caPool := x509.NewCertPool()
	if !caPool.AppendCertsFromPEM(pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: caDER})) {
		t.Fatalf("append CA cert")
	}

	return mtlsMaterial{
		caCertPEM:     string(pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: caDER})),
		serverCertPEM: serverCertPEM,
		serverKeyPEM:  serverKeyPEM,
		clientCert:    clientCert,
		caPool:        caPool,
	}
}

func signedCertPEM(t *testing.T, caCert *x509.Certificate, caKey ed25519.PrivateKey, template *x509.Certificate) (string, string) {
	t.Helper()
	pub, key, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatalf("generate leaf key: %v", err)
	}
	der, err := x509.CreateCertificate(rand.Reader, template, caCert, pub, caKey)
	if err != nil {
		t.Fatalf("create leaf cert: %v", err)
	}
	keyDER, err := x509.MarshalPKCS8PrivateKey(key)
	if err != nil {
		t.Fatalf("marshal leaf key: %v", err)
	}
	certPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: der})
	keyPEM := pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: keyDER})
	return string(certPEM), string(keyPEM)
}

func assertMTLSWithoutClientCertFails(t *testing.T, addr string, caPool *x509.CertPool) {
	t.Helper()
	conn, err := tls.DialWithDialer(&net.Dialer{Timeout: 2 * time.Second}, "tcp", addr, &tls.Config{
		RootCAs:    caPool,
		ServerName: "localhost",
		MinVersion: tls.VersionTLS13,
	})
	if err == nil {
		defer conn.Close()
		_ = conn.SetDeadline(time.Now().Add(750 * time.Millisecond))
		if _, writeErr := conn.Write([]byte("no-client-cert")); writeErr != nil {
			return
		}
		buf := make([]byte, 1)
		if n, readErr := conn.Read(buf); readErr != nil && n == 0 {
			return
		}
		t.Fatalf("mTLS proxy accepted usable connection without certificate")
	}
}

func tlsRoundTrip(t *testing.T, addr string, payload []byte, caPool *x509.CertPool, clientCert tls.Certificate) []byte {
	t.Helper()
	conn, err := tls.DialWithDialer(&net.Dialer{Timeout: 3 * time.Second}, "tcp", addr, &tls.Config{
		RootCAs:      caPool,
		ServerName:   "localhost",
		Certificates: []tls.Certificate{clientCert},
		MinVersion:   tls.VersionTLS13,
	})
	if err != nil {
		t.Fatalf("dial mTLS proxy %s: %v", addr, err)
	}
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(3 * time.Second))
	if _, err := conn.Write(payload); err != nil {
		t.Fatalf("write mTLS payload: %v", err)
	}
	response := make([]byte, len("echo:")+len(payload))
	if _, err := io.ReadFull(conn, response); err != nil {
		t.Fatalf("read mTLS response: %v", err)
	}
	return response
}
