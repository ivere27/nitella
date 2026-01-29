package health

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/config"
	"github.com/ivere27/nitella/pkg/log"
)

// ServiceStatus represents the current health of a service
type ServiceStatus struct {
	Healthy     bool
	LastChecked time.Time
	FailureCnt  int
}

// HealthChecker manages background health checks
type HealthChecker struct {
	services  map[string]config.Service
	statuses  map[string]*ServiceStatus
	cancelFns map[string]context.CancelFunc
	mu        sync.RWMutex
	stopCh    chan struct{}
	stopOnce  sync.Once

	// Callback for status changes
	onStatusChange func(service string, healthy bool, message string)
}

// NewHealthChecker creates a new checker instance
func NewHealthChecker(services map[string]config.Service) *HealthChecker {
	if services == nil {
		services = make(map[string]config.Service)
	}
	return &HealthChecker{
		services:  services,
		statuses:  make(map[string]*ServiceStatus),
		cancelFns: make(map[string]context.CancelFunc),
		stopCh:    make(chan struct{}),
	}
}

// SetStatusChangeCallback sets a callback for status changes
func (hc *HealthChecker) SetStatusChangeCallback(cb func(service string, healthy bool, message string)) {
	hc.mu.Lock()
	defer hc.mu.Unlock()
	hc.onStatusChange = cb
}

// Start begins the monitoring loops
func (hc *HealthChecker) Start() {
	hc.mu.Lock()
	defer hc.mu.Unlock()

	for name, svc := range hc.services {
		if svc.HealthCheck == nil {
			continue
		}
		hc.startMonitor(name, svc)
	}
}

// Stop halts all monitoring
func (hc *HealthChecker) Stop() {
	hc.mu.Lock()
	for _, cancel := range hc.cancelFns {
		cancel()
	}
	hc.cancelFns = make(map[string]context.CancelFunc)
	hc.mu.Unlock()

	// Use sync.Once to safely close stopCh exactly once
	hc.stopOnce.Do(func() {
		close(hc.stopCh)
	})
}

func (hc *HealthChecker) startMonitor(name string, svc config.Service) {
	// If already running, stop it first
	if cancel, ok := hc.cancelFns[name]; ok {
		cancel()
	}

	ctx, cancel := context.WithCancel(context.Background())
	hc.cancelFns[name] = cancel

	// Initialize status as healthy to avoid alerting on startup unless it fails
	hc.statuses[name] = &ServiceStatus{Healthy: true}

	go hc.monitorLoop(ctx, name, svc)
}

// AddService adds a service to monitor
func (hc *HealthChecker) AddService(name string, svc config.Service) {
	hc.mu.Lock()
	defer hc.mu.Unlock()

	hc.services[name] = svc
	if svc.HealthCheck != nil {
		hc.startMonitor(name, svc)
	}
}

// RemoveService removes a service from monitoring
func (hc *HealthChecker) RemoveService(name string) {
	hc.mu.Lock()
	defer hc.mu.Unlock()

	if cancel, ok := hc.cancelFns[name]; ok {
		cancel()
		delete(hc.cancelFns, name)
	}
	delete(hc.services, name)
	delete(hc.statuses, name)
}

func (hc *HealthChecker) monitorLoop(ctx context.Context, name string, svc config.Service) {
	cfg := svc.HealthCheck

	interval, err := time.ParseDuration(cfg.Interval)
	if err != nil {
		interval = 10 * time.Second
	}

	timeout, err := time.ParseDuration(cfg.Timeout)
	if err != nil {
		timeout = 2 * time.Second
	}

	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	log.Printf("[Health] Starting monitor for %s (%s every %s)", name, cfg.Type, interval)

	for {
		select {
		case <-ctx.Done():
			return
		case <-hc.stopCh:
			return
		case <-ticker.C:
			hc.check(name, svc.Address, cfg, timeout)
		}
	}
}

func (hc *HealthChecker) check(name, address string, cfg *config.HealthCheck, timeout time.Duration) {
	var healthy bool
	var err error

	switch cfg.Type {
	case "http", "https":
		healthy, err = checkHTTP(address, cfg.Path, cfg.ExpectedStatus, timeout)
	case "tcp":
		healthy, err = checkTCP(address, timeout)
	default:
		// Default to TCP if unknown
		healthy, err = checkTCP(address, timeout)
	}

	hc.mu.Lock()
	status, exists := hc.statuses[name]
	if !exists {
		status = &ServiceStatus{Healthy: true}
		hc.statuses[name] = status
	}

	prevHealthy := status.Healthy
	status.LastChecked = time.Now()
	callback := hc.onStatusChange

	if healthy {
		status.FailureCnt = 0
		status.Healthy = true
		if !prevHealthy {
			log.Printf("[Health] Service %s RECOVERED", name)
			hc.mu.Unlock()
			if callback != nil {
				callback(name, true, "Service is back online")
			}
			return
		}
	} else {
		status.FailureCnt++
		// Alert on 2nd consecutive failure to avoid blips
		if status.FailureCnt >= 2 && prevHealthy {
			status.Healthy = false
			log.Printf("[Health] Service %s DOWN: %v", name, err)
			hc.mu.Unlock()
			if callback != nil {
				callback(name, false, fmt.Sprintf("Service unreachable: %v", err))
			}
			return
		}
	}
	hc.mu.Unlock()
}

// GetStatus returns the health status of a service
func (hc *HealthChecker) GetStatus(name string) (bool, bool) {
	hc.mu.RLock()
	defer hc.mu.RUnlock()

	status, exists := hc.statuses[name]
	if !exists {
		return false, false
	}
	return status.Healthy, true
}

// GetAllStatuses returns all service statuses
func (hc *HealthChecker) GetAllStatuses() map[string]*ServiceStatus {
	hc.mu.RLock()
	defer hc.mu.RUnlock()

	result := make(map[string]*ServiceStatus)
	for name, status := range hc.statuses {
		result[name] = &ServiceStatus{
			Healthy:     status.Healthy,
			LastChecked: status.LastChecked,
			FailureCnt:  status.FailureCnt,
		}
	}
	return result
}

// checkTCP attempts to open a connection
func checkTCP(address string, timeout time.Duration) (bool, error) {
	conn, err := net.DialTimeout("tcp", address, timeout)
	if err != nil {
		return false, err
	}
	conn.Close()
	return true, nil
}

// checkHTTP attempts a GET request
func checkHTTP(address, path string, expectedStatus int, timeout time.Duration) (bool, error) {
	url := address
	if !strings.HasPrefix(address, "http://") && !strings.HasPrefix(address, "https://") {
		url = fmt.Sprintf("http://%s%s", address, path)
	} else {
		if strings.HasSuffix(address, "/") && strings.HasPrefix(path, "/") {
			url = fmt.Sprintf("%s%s", strings.TrimSuffix(address, "/"), path)
		} else if !strings.HasSuffix(address, "/") && !strings.HasPrefix(path, "/") {
			url = fmt.Sprintf("%s/%s", address, path)
		} else {
			url = fmt.Sprintf("%s%s", address, path)
		}
	}

	client := &http.Client{
		Timeout: timeout,
	}

	resp, err := client.Get(url)
	if err != nil {
		return false, err
	}
	defer resp.Body.Close()

	if expectedStatus > 0 && resp.StatusCode != expectedStatus {
		return false, fmt.Errorf("status %d != %d", resp.StatusCode, expectedStatus)
	}

	if expectedStatus == 0 && resp.StatusCode >= 400 {
		return false, fmt.Errorf("status %d (error)", resp.StatusCode)
	}

	return true, nil
}
