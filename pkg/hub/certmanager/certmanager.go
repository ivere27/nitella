// Package certmanager handles Hub TLS certificate lifecycle with auto-rotation.
//
// Architecture:
//   - Hub CA (10 years): Long-lived trust anchor, clients trust this
//   - Leaf Cert (90 days): Short-lived server cert, auto-rotates
//
// Clients only need to trust the Hub CA once (TOFU). Leaf certs can rotate
// without any client-side changes.
package certmanager

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/pem"
	"fmt"
	"math/big"
	"net"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/log"
)

// CertManager handles Hub CA and leaf certificate lifecycle.
type CertManager struct {
	// Paths
	dataDir     string
	caPath      string
	caKeyPath   string
	leafPath    string
	leafKeyPath string

	// Hub CA (long-lived)
	caCert *x509.Certificate
	caKey  ed25519.PrivateKey

	// Leaf cert (short-lived, atomic for hot swap)
	leafCert atomic.Pointer[tls.Certificate]

	// Client CAs pool (for verifying node certificates signed by CLI CAs)
	clientCAsMu sync.RWMutex
	clientCAs   *x509.CertPool

	// Configuration
	leafValidity time.Duration
	renewBefore  time.Duration
	sans         []string
	ips          []net.IP

	// State
	cancel context.CancelFunc
}

// Config holds CertManager configuration.
type Config struct {
	DataDir      string        // Directory for cert storage
	LeafValidity time.Duration // Leaf cert validity (default: 90 days)
	RenewBefore  time.Duration // Renew this long before expiry (default: 30 days)
	SANs         []string      // Additional DNS SANs
	IPs          []net.IP      // Additional IP SANs
}

// DefaultConfig returns sensible defaults.
func DefaultConfig(dataDir string) *Config {
	return &Config{
		DataDir:      dataDir,
		LeafValidity: 90 * 24 * time.Hour, // 90 days
		RenewBefore:  30 * 24 * time.Hour, // 30 days before expiry
	}
}

// New creates a new CertManager.
func New(cfg *Config) (*CertManager, error) {
	if cfg.DataDir == "" {
		cfg.DataDir = "."
	}

	m := &CertManager{
		dataDir:     cfg.DataDir,
		caPath:      filepath.Join(cfg.DataDir, "hub_ca.crt"),
		caKeyPath:   filepath.Join(cfg.DataDir, "hub_ca.key"),
		leafPath:    filepath.Join(cfg.DataDir, "hub.crt"),
		leafKeyPath: filepath.Join(cfg.DataDir, "hub.key"),
		leafValidity: cfg.LeafValidity,
		renewBefore:  cfg.RenewBefore,
		sans:         cfg.SANs,
		ips:          cfg.IPs,
		clientCAs:   x509.NewCertPool(), // Initialize dynamic client CA pool
	}

	if m.leafValidity == 0 {
		m.leafValidity = 90 * 24 * time.Hour
	}
	if m.renewBefore == 0 {
		m.renewBefore = 30 * 24 * time.Hour
	}

	// Ensure data directory exists
	if err := os.MkdirAll(cfg.DataDir, 0700); err != nil {
		return nil, fmt.Errorf("failed to create data dir: %w", err)
	}

	// Initialize Hub CA
	if err := m.ensureCA(); err != nil {
		return nil, fmt.Errorf("failed to initialize Hub CA: %w", err)
	}

	// Initialize leaf cert
	if err := m.ensureLeafCert(); err != nil {
		return nil, fmt.Errorf("failed to initialize leaf cert: %w", err)
	}

	return m, nil
}

// Start begins the background rotation goroutine.
func (m *CertManager) Start(ctx context.Context) {
	ctx, m.cancel = context.WithCancel(ctx)
	go m.rotationLoop(ctx)
}

// Stop stops the background rotation goroutine.
func (m *CertManager) Stop() {
	if m.cancel != nil {
		m.cancel()
	}
}

// GetCertificate returns the current leaf certificate.
// This is called on every TLS handshake.
func (m *CertManager) GetCertificate(*tls.ClientHelloInfo) (*tls.Certificate, error) {
	cert := m.leafCert.Load()
	if cert == nil {
		return nil, fmt.Errorf("no certificate available")
	}
	return cert, nil
}

// GetTLSConfig returns a TLS config that uses dynamic certificate loading.
// Uses RequestClientCert to:
// - Allow PairingService connections without client certs (PAKE handles trust)
// - Request but not auto-verify client certs for NodeService (we verify in callback)
// This allows us to dynamically verify against Hub CA + CLI CAs that are added at runtime.
func (m *CertManager) GetTLSConfig() *tls.Config {
	return &tls.Config{
		GetCertificate: m.GetCertificate,
		ClientAuth:     tls.RequestClientCert, // Request but don't auto-verify
		// Use VerifyPeerCertificate for dynamic CA pool (Hub CA + CLI CAs)
		VerifyPeerCertificate: m.verifyClientCert,
		MinVersion:            tls.VersionTLS13,
	}
}

// GetStrictTLSConfig returns a TLS config that requires valid client certificates.
// Use this for services that require mTLS (e.g., NodeService-only endpoints).
func (m *CertManager) GetStrictTLSConfig() *tls.Config {
	return &tls.Config{
		GetCertificate: m.GetCertificate,
		ClientAuth:     tls.RequireAnyClientCert, // Require cert but don't auto-verify
		// Use VerifyPeerCertificate for dynamic CA pool (Hub CA + CLI CAs)
		VerifyPeerCertificate: m.verifyClientCertStrict,
		MinVersion:            tls.VersionTLS13,
	}
}

// GetCAFingerprint returns the Hub CA fingerprint for client verification.
func (m *CertManager) GetCAFingerprint() ([]byte, error) {
	if m.caCert == nil {
		return nil, fmt.Errorf("Hub CA not initialized")
	}
	pubKey, ok := m.caCert.PublicKey.(ed25519.PublicKey)
	if !ok {
		return nil, fmt.Errorf("Hub CA is not Ed25519")
	}
	return nitellacrypto.GetSPKIFingerprint(pubKey)
}

// GetCACertPEM returns the Hub CA certificate in PEM format.
func (m *CertManager) GetCACertPEM() ([]byte, error) {
	return os.ReadFile(m.caPath)
}

// GetCACert returns the Hub CA certificate.
func (m *CertManager) GetCACert() *x509.Certificate {
	return m.caCert
}

// GetCAPrivateKey returns the Hub CA private key.
func (m *CertManager) GetCAPrivateKey() ed25519.PrivateKey {
	return m.caKey
}

// AddClientCA adds a CLI CA certificate to the client CA pool.
// This allows Hub to verify node certificates signed by this CLI CA.
func (m *CertManager) AddClientCA(caPEM []byte) error {
	block, _ := pem.Decode(caPEM)
	if block == nil {
		return fmt.Errorf("failed to decode CLI CA PEM")
	}

	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return fmt.Errorf("failed to parse CLI CA: %w", err)
	}

	m.clientCAsMu.Lock()
	defer m.clientCAsMu.Unlock()

	m.clientCAs.AddCert(cert)
	log.Printf("[CertManager] Added CLI CA to client pool: %s", cert.Subject.CommonName)

	return nil
}

// verifyClientCert verifies client certificate against Hub CA and CLI CAs.
// This is used by GetTLSConfig() with VerifyClientCertIfGiven.
func (m *CertManager) verifyClientCert(rawCerts [][]byte, verifiedChains [][]*x509.Certificate) error {
	// If no client cert provided, that's OK (VerifyClientCertIfGiven)
	if len(rawCerts) == 0 {
		return nil
	}

	return m.verifyClientCertInternal(rawCerts)
}

// verifyClientCertStrict verifies client certificate - fails if not provided.
// This is used by GetStrictTLSConfig() with RequireAnyClientCert.
func (m *CertManager) verifyClientCertStrict(rawCerts [][]byte, verifiedChains [][]*x509.Certificate) error {
	if len(rawCerts) == 0 {
		return fmt.Errorf("client certificate required")
	}

	return m.verifyClientCertInternal(rawCerts)
}

// verifyClientCertInternal performs the actual certificate verification.
// Note: This is a LENIENT check - it doesn't fail if verification fails.
// The gRPC interceptors handle service-specific auth (JWT for Mobile/Auth, mTLS for Node).
// This allows CLI to connect with self-signed certs while nodes must have CLI CA certs.
func (m *CertManager) verifyClientCertInternal(rawCerts [][]byte) error {
	// Parse the client certificate
	cert, err := x509.ParseCertificate(rawCerts[0])
	if err != nil {
		// Can't parse certificate - this is a real error
		return fmt.Errorf("failed to parse client certificate: %w", err)
	}

	// Build combined root pool: Hub CA + all CLI CAs
	m.clientCAsMu.RLock()
	roots := x509.NewCertPool()
	if m.caCert != nil {
		roots.AddCert(m.caCert)
	}
	// CLI CAs are stored in clientCAs pool - try verification against it
	clientCAs := m.clientCAs
	m.clientCAsMu.RUnlock()

	// First try with Hub CA
	opts := x509.VerifyOptions{
		Roots:     roots,
		KeyUsages: []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth},
	}
	if _, err := cert.Verify(opts); err == nil {
		return nil // Verified against Hub CA
	}

	// Try with CLI CAs as roots (CLI CAs sign node certs directly)
	opts.Roots = clientCAs
	if _, err := cert.Verify(opts); err == nil {
		return nil // Verified against CLI CA
	}

	// Certificate not verified against any known CA.
	// This is OK at the TLS level - let gRPC interceptors handle service-specific auth.
	// CLI uses JWT auth (doesn't need mTLS), only NodeService requires verified mTLS.
	return nil
}

// ensureCA creates or loads the Hub CA.
func (m *CertManager) ensureCA() error {
	// Check if CA exists
	_, certErr := os.Stat(m.caPath)
	_, keyErr := os.Stat(m.caKeyPath)

	if os.IsNotExist(certErr) || os.IsNotExist(keyErr) {
		log.Println("[CertManager] Generating new Hub CA (valid for 10 years)...")
		return m.generateCA()
	}

	// Load existing CA
	return m.loadCA()
}

// generateCA creates a new Hub CA certificate.
func (m *CertManager) generateCA() error {
	// Generate key
	priv, err := nitellacrypto.GenerateKey()
	if err != nil {
		return fmt.Errorf("failed to generate CA key: %w", err)
	}

	// Generate serial
	serialLimit := new(big.Int).Lsh(big.NewInt(1), 128)
	serial, err := rand.Int(rand.Reader, serialLimit)
	if err != nil {
		return fmt.Errorf("failed to generate serial: %w", err)
	}

	// Create CA certificate template
	tmpl := x509.Certificate{
		SerialNumber: serial,
		Subject: pkix.Name{
			CommonName:   "Nitella Hub CA",
			Organization: []string{"Nitella"},
		},
		NotBefore:             time.Now(),
		NotAfter:              time.Now().AddDate(10, 0, 0), // 10 years
		KeyUsage:              x509.KeyUsageCertSign | x509.KeyUsageCRLSign,
		BasicConstraintsValid: true,
		IsCA:                  true,
		MaxPathLen:            1,
	}

	// Self-sign
	pub := priv.Public().(ed25519.PublicKey)
	derBytes, err := x509.CreateCertificate(rand.Reader, &tmpl, &tmpl, pub, priv)
	if err != nil {
		return fmt.Errorf("failed to create CA cert: %w", err)
	}

	// Encode to PEM
	certPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: derBytes})
	keyPEM := nitellacrypto.EncodePrivateKeyToPEM(priv)

	// Save with strict permissions
	if err := os.WriteFile(m.caKeyPath, keyPEM, 0600); err != nil {
		return fmt.Errorf("failed to save CA key: %w", err)
	}
	if err := os.WriteFile(m.caPath, certPEM, 0644); err != nil {
		return fmt.Errorf("failed to save CA cert: %w", err)
	}

	// Parse and store
	m.caCert, err = x509.ParseCertificate(derBytes)
	if err != nil {
		return fmt.Errorf("failed to parse CA cert: %w", err)
	}
	m.caKey = priv

	log.Printf("[CertManager] Hub CA generated. Valid until: %s", m.caCert.NotAfter.Format("2006-01-02"))
	m.logCAFingerprint()

	return nil
}

// loadCA loads existing Hub CA from disk.
func (m *CertManager) loadCA() error {
	// Load cert
	certPEM, err := os.ReadFile(m.caPath)
	if err != nil {
		return fmt.Errorf("failed to read CA cert: %w", err)
	}

	block, _ := pem.Decode(certPEM)
	if block == nil {
		return fmt.Errorf("failed to decode CA cert PEM")
	}

	m.caCert, err = x509.ParseCertificate(block.Bytes)
	if err != nil {
		return fmt.Errorf("failed to parse CA cert: %w", err)
	}

	// Load key
	keyPEM, err := os.ReadFile(m.caKeyPath)
	if err != nil {
		return fmt.Errorf("failed to read CA key: %w", err)
	}

	m.caKey, err = nitellacrypto.DecodePrivateKeyFromPEM(keyPEM)
	if err != nil {
		return fmt.Errorf("failed to decode CA key: %w", err)
	}

	log.Printf("[CertManager] Hub CA loaded. Valid until: %s", m.caCert.NotAfter.Format("2006-01-02"))
	m.logCAFingerprint()

	return nil
}

// ensureLeafCert creates or loads the leaf certificate.
func (m *CertManager) ensureLeafCert() error {
	// Check if leaf exists and is still valid
	if m.shouldRotate() {
		log.Println("[CertManager] Generating new leaf certificate...")
		return m.rotateLeafCert()
	}

	// Load existing leaf
	return m.loadLeafCert()
}

// shouldRotate returns true if the leaf cert should be rotated.
func (m *CertManager) shouldRotate() bool {
	// Check if files exist
	_, certErr := os.Stat(m.leafPath)
	_, keyErr := os.Stat(m.leafKeyPath)
	if os.IsNotExist(certErr) || os.IsNotExist(keyErr) {
		return true
	}

	// Load and check expiry
	certPEM, err := os.ReadFile(m.leafPath)
	if err != nil {
		return true
	}

	block, _ := pem.Decode(certPEM)
	if block == nil {
		return true
	}

	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return true
	}

	// Check if within renewal window
	renewTime := cert.NotAfter.Add(-m.renewBefore)
	if time.Now().After(renewTime) {
		log.Printf("[CertManager] Leaf cert expires %s, within renewal window", cert.NotAfter.Format("2006-01-02"))
		return true
	}

	return false
}

// rotateLeafCert generates a new leaf certificate signed by the Hub CA.
func (m *CertManager) rotateLeafCert() error {
	// Generate new key for leaf
	leafKey, err := nitellacrypto.GenerateKey()
	if err != nil {
		return fmt.Errorf("failed to generate leaf key: %w", err)
	}

	// Generate serial
	serialLimit := new(big.Int).Lsh(big.NewInt(1), 128)
	serial, err := rand.Int(rand.Reader, serialLimit)
	if err != nil {
		return fmt.Errorf("failed to generate serial: %w", err)
	}

	// Collect SANs
	dnsNames := []string{"localhost"}
	ipAddresses := []net.IP{net.ParseIP("127.0.0.1"), net.ParseIP("::1")}

	// Add hostname
	if hostname, err := os.Hostname(); err == nil && hostname != "" {
		dnsNames = append(dnsNames, hostname)
	}

	// Add additional DNS names from environment (comma-separated)
	if extraDNS := os.Getenv("NITELLA_CERT_DNS_NAMES"); extraDNS != "" {
		for _, name := range strings.Split(extraDNS, ",") {
			name = strings.TrimSpace(name)
			if name != "" {
				dnsNames = append(dnsNames, name)
			}
		}
	}

	// Auto-detect local IPs
	if ifaces, err := net.Interfaces(); err == nil {
		for _, iface := range ifaces {
			if iface.Flags&net.FlagUp == 0 || iface.Flags&net.FlagLoopback != 0 {
				continue
			}
			addrs, err := iface.Addrs()
			if err != nil {
				continue
			}
			for _, addr := range addrs {
				var ip net.IP
				switch v := addr.(type) {
				case *net.IPNet:
					ip = v.IP
				case *net.IPAddr:
					ip = v.IP
				}
				if ip != nil && !ip.IsLoopback() {
					ipAddresses = append(ipAddresses, ip)
				}
			}
		}
	}

	// Add configured SANs
	dnsNames = append(dnsNames, m.sans...)
	ipAddresses = append(ipAddresses, m.ips...)

	// Create leaf certificate template
	tmpl := x509.Certificate{
		SerialNumber: serial,
		Subject: pkix.Name{
			CommonName:   "Nitella Hub",
			Organization: []string{"Nitella"},
		},
		NotBefore:             time.Now(),
		NotAfter:              time.Now().Add(m.leafValidity),
		KeyUsage:              x509.KeyUsageDigitalSignature | x509.KeyUsageKeyEncipherment,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		BasicConstraintsValid: true,
		IsCA:                  false,
		DNSNames:              dnsNames,
		IPAddresses:           ipAddresses,
	}

	// Sign with Hub CA
	leafPub := leafKey.Public().(ed25519.PublicKey)
	derBytes, err := x509.CreateCertificate(rand.Reader, &tmpl, m.caCert, leafPub, m.caKey)
	if err != nil {
		return fmt.Errorf("failed to create leaf cert: %w", err)
	}

	// Encode to PEM
	certPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: derBytes})
	keyPEM := nitellacrypto.EncodePrivateKeyToPEM(leafKey)

	// Save with strict permissions
	if err := os.WriteFile(m.leafKeyPath, keyPEM, 0600); err != nil {
		return fmt.Errorf("failed to save leaf key: %w", err)
	}
	if err := os.WriteFile(m.leafPath, certPEM, 0644); err != nil {
		return fmt.Errorf("failed to save leaf cert: %w", err)
	}

	// Create tls.Certificate with full chain (leaf + Hub CA)
	// This allows clients to see the CA for TOFU verification
	tlsCert, err := tls.X509KeyPair(certPEM, keyPEM)
	if err != nil {
		return fmt.Errorf("failed to create TLS cert: %w", err)
	}
	// Append Hub CA to the chain
	tlsCert.Certificate = append(tlsCert.Certificate, m.caCert.Raw)
	m.leafCert.Store(&tlsCert)

	log.Printf("[CertManager] Leaf certificate rotated. Serial: %s, Valid until: %s",
		serial.Text(16)[:16], tmpl.NotAfter.Format("2006-01-02"))
	log.Printf("[CertManager] Leaf SANs: DNS=%v, IPs=%v", dnsNames, ipAddresses)

	return nil
}

// loadLeafCert loads existing leaf certificate from disk.
func (m *CertManager) loadLeafCert() error {
	certPEM, err := os.ReadFile(m.leafPath)
	if err != nil {
		return fmt.Errorf("failed to read leaf cert: %w", err)
	}

	keyPEM, err := os.ReadFile(m.leafKeyPath)
	if err != nil {
		return fmt.Errorf("failed to read leaf key: %w", err)
	}

	tlsCert, err := tls.X509KeyPair(certPEM, keyPEM)
	if err != nil {
		return fmt.Errorf("failed to create TLS cert: %w", err)
	}
	// Append Hub CA to the chain for TOFU verification
	tlsCert.Certificate = append(tlsCert.Certificate, m.caCert.Raw)
	m.leafCert.Store(&tlsCert)

	// Parse to get expiry info
	block, _ := pem.Decode(certPEM)
	if block != nil {
		if cert, err := x509.ParseCertificate(block.Bytes); err == nil {
			log.Printf("[CertManager] Leaf certificate loaded. Valid until: %s", cert.NotAfter.Format("2006-01-02"))
		}
	}

	return nil
}

// rotationLoop runs in the background and checks for cert rotation.
func (m *CertManager) rotationLoop(ctx context.Context) {
	// Check every 12 hours
	ticker := time.NewTicker(12 * time.Hour)
	defer ticker.Stop()

	log.Println("[CertManager] Background rotation loop started")

	for {
		select {
		case <-ticker.C:
			if m.shouldRotate() {
				log.Println("[CertManager] Auto-rotating leaf certificate...")
				if err := m.rotateLeafCert(); err != nil {
					log.Printf("[CertManager] ERROR: Failed to rotate cert: %v", err)
				}
			}
		case <-ctx.Done():
			log.Println("[CertManager] Background rotation loop stopped")
			return
		}
	}
}

// logCAFingerprint logs the Hub CA fingerprint for verification.
func (m *CertManager) logCAFingerprint() {
	fingerprint, err := m.GetCAFingerprint()
	if err != nil {
		return
	}

	emojis := nitellacrypto.HashToEmojis(fingerprint)

	log.Printf("\n"+
		"╔══════════════════════════════════════════════════════════════════╗\n"+
		"║  HUB CA FINGERPRINT (Trust This)                                 ║\n"+
		"║  HEX:    %x  ║\n"+
		"║  VISUAL: %s  %s  %s  %s                                      ║\n"+
		"╚══════════════════════════════════════════════════════════════════╝\n",
		fingerprint, emojis[0], emojis[1], emojis[2], emojis[3])
}

// ForceRotate forces an immediate rotation (for testing or manual trigger).
func (m *CertManager) ForceRotate() error {
	return m.rotateLeafCert()
}

// CertInfo holds certificate information for admin API.
type CertInfo struct {
	// Hub CA
	CAFingerprint string
	CAEmoji       []string
	CAExpiresAt   time.Time

	// Leaf Cert
	LeafSerial      string
	LeafExpiresAt   time.Time
	LeafNotBefore   time.Time
	LeafDNSNames    []string
	LeafIPAddresses []string
}

// GetCertInfo returns current certificate information.
func (m *CertManager) GetCertInfo() (*CertInfo, error) {
	info := &CertInfo{}

	// Hub CA info
	if m.caCert != nil {
		fingerprint, err := m.GetCAFingerprint()
		if err == nil {
			info.CAFingerprint = fmt.Sprintf("%x", fingerprint)
			info.CAEmoji = nitellacrypto.HashToEmojis(fingerprint)
		}
		info.CAExpiresAt = m.caCert.NotAfter
	}

	// Leaf cert info
	tlsCert := m.leafCert.Load()
	if tlsCert != nil && len(tlsCert.Certificate) > 0 {
		leafX509, err := x509.ParseCertificate(tlsCert.Certificate[0])
		if err == nil {
			info.LeafSerial = leafX509.SerialNumber.Text(16)
			info.LeafExpiresAt = leafX509.NotAfter
			info.LeafNotBefore = leafX509.NotBefore
			info.LeafDNSNames = leafX509.DNSNames
			for _, ip := range leafX509.IPAddresses {
				info.LeafIPAddresses = append(info.LeafIPAddresses, ip.String())
			}
		}
	}

	return info, nil
}

// NOTE: SignNodeCSR was removed for zero-trust architecture.
// Hub must NEVER sign node certificates. CLI/mobile app signs CSRs.
// Hub only relays certificates signed by user's own CA.
