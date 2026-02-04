// Package admincert provides TLS certificate management for nitellad admin API.
// This generates a self-signed CA and server certificate for the admin gRPC API.
package admincert

import (
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
	"sync"
	"time"

	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/log"
)

// AdminCertManager handles TLS certificates for nitellad admin API.
type AdminCertManager struct {
	dataDir     string
	caPath      string
	caKeyPath   string
	certPath    string
	keyPath     string

	caCert  *x509.Certificate
	caKey   ed25519.PrivateKey
	tlsCert *tls.Certificate

	mu sync.RWMutex
}

// New creates a new AdminCertManager.
// If certificates don't exist, they are auto-generated.
func New(dataDir string) (*AdminCertManager, error) {
	m := &AdminCertManager{
		dataDir:   dataDir,
		caPath:    filepath.Join(dataDir, "admin_ca.crt"),
		caKeyPath: filepath.Join(dataDir, "admin_ca.key"),
		certPath:  filepath.Join(dataDir, "admin_server.crt"),
		keyPath:   filepath.Join(dataDir, "admin_server.key"),
	}

	// Ensure data directory exists
	if err := os.MkdirAll(dataDir, 0700); err != nil {
		return nil, fmt.Errorf("failed to create data dir: %w", err)
	}

	// Load or generate CA
	if err := m.ensureCA(); err != nil {
		return nil, fmt.Errorf("failed to ensure CA: %w", err)
	}

	// Load or generate server cert
	if err := m.ensureCert(); err != nil {
		return nil, fmt.Errorf("failed to ensure cert: %w", err)
	}

	return m, nil
}

// GetCACertPath returns path to the CA certificate file.
// Clients should use this CA to verify the server certificate.
func (m *AdminCertManager) GetCACertPath() string {
	return m.caPath
}

// GetTLSConfig returns TLS config for the admin gRPC server.
func (m *AdminCertManager) GetTLSConfig() *tls.Config {
	m.mu.RLock()
	defer m.mu.RUnlock()

	return &tls.Config{
		Certificates: []tls.Certificate{*m.tlsCert},
		MinVersion:   tls.VersionTLS13,
	}
}

// ensureCA loads or generates the CA certificate.
func (m *AdminCertManager) ensureCA() error {
	// Check if CA exists
	if _, err := os.Stat(m.caPath); err == nil {
		return m.loadCA()
	}

	return m.generateCA()
}

// loadCA loads existing CA from disk.
func (m *AdminCertManager) loadCA() error {
	certPEM, err := os.ReadFile(m.caPath)
	if err != nil {
		return fmt.Errorf("failed to read CA cert: %w", err)
	}

	keyPEM, err := os.ReadFile(m.caKeyPath)
	if err != nil {
		return fmt.Errorf("failed to read CA key: %w", err)
	}

	// Parse certificate
	block, _ := pem.Decode(certPEM)
	if block == nil {
		return fmt.Errorf("failed to decode CA cert PEM")
	}

	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return fmt.Errorf("failed to parse CA cert: %w", err)
	}

	// Parse key
	key, err := nitellacrypto.DecodePrivateKeyFromPEM(keyPEM)
	if err != nil {
		return fmt.Errorf("failed to decode CA key: %w", err)
	}

	m.caCert = cert
	m.caKey = key

	log.Printf("[AdminCert] Loaded existing CA. Valid until: %s", cert.NotAfter.Format("2006-01-02"))
	return nil
}

// generateCA creates a new CA certificate.
func (m *AdminCertManager) generateCA() error {
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

	// Create CA certificate template (10 year validity)
	tmpl := x509.Certificate{
		SerialNumber: serial,
		Subject: pkix.Name{
			CommonName:   "Nitella Admin CA",
			Organization: []string{"Nitella"},
		},
		NotBefore:             time.Now(),
		NotAfter:              time.Now().AddDate(10, 0, 0),
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

	log.Printf("[AdminCert] Generated new Admin CA. Valid until: %s", m.caCert.NotAfter.Format("2006-01-02"))
	log.Printf("[AdminCert] CA certificate saved to: %s", m.caPath)
	return nil
}

// ensureCert loads or generates the server certificate.
func (m *AdminCertManager) ensureCert() error {
	// Check if cert exists
	if _, err := os.Stat(m.certPath); err == nil {
		return m.loadCert()
	}

	return m.generateCert()
}

// loadCert loads existing server certificate from disk.
func (m *AdminCertManager) loadCert() error {
	cert, err := tls.LoadX509KeyPair(m.certPath, m.keyPath)
	if err != nil {
		return fmt.Errorf("failed to load cert: %w", err)
	}

	m.mu.Lock()
	m.tlsCert = &cert
	m.mu.Unlock()

	log.Printf("[AdminCert] Loaded existing server certificate")
	return nil
}

// generateCert creates a new server certificate signed by the CA.
func (m *AdminCertManager) generateCert() error {
	// Generate key
	priv, err := nitellacrypto.GenerateKey()
	if err != nil {
		return fmt.Errorf("failed to generate server key: %w", err)
	}

	// Generate serial
	serialLimit := new(big.Int).Lsh(big.NewInt(1), 128)
	serial, err := rand.Int(rand.Reader, serialLimit)
	if err != nil {
		return fmt.Errorf("failed to generate serial: %w", err)
	}

	// Create server certificate template (1 year validity)
	hostname, _ := os.Hostname()
	tmpl := x509.Certificate{
		SerialNumber: serial,
		Subject: pkix.Name{
			CommonName:   hostname,
			Organization: []string{"Nitella"},
		},
		NotBefore:   time.Now(),
		NotAfter:    time.Now().AddDate(1, 0, 0),
		KeyUsage:    x509.KeyUsageDigitalSignature | x509.KeyUsageKeyEncipherment,
		ExtKeyUsage: []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		DNSNames:    []string{hostname, "localhost"},
		IPAddresses: []net.IP{net.ParseIP("127.0.0.1"), net.ParseIP("::1")},
	}

	// Sign with CA
	pub := priv.Public().(ed25519.PublicKey)
	derBytes, err := x509.CreateCertificate(rand.Reader, &tmpl, m.caCert, pub, m.caKey)
	if err != nil {
		return fmt.Errorf("failed to create server cert: %w", err)
	}

	// Encode to PEM
	certPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: derBytes})
	keyPEM := nitellacrypto.EncodePrivateKeyToPEM(priv)

	// Save
	if err := os.WriteFile(m.keyPath, keyPEM, 0600); err != nil {
		return fmt.Errorf("failed to save server key: %w", err)
	}
	if err := os.WriteFile(m.certPath, certPEM, 0644); err != nil {
		return fmt.Errorf("failed to save server cert: %w", err)
	}

	// Load into TLS cert
	cert, err := tls.LoadX509KeyPair(m.certPath, m.keyPath)
	if err != nil {
		return fmt.Errorf("failed to load generated cert: %w", err)
	}

	m.mu.Lock()
	m.tlsCert = &cert
	m.mu.Unlock()

	log.Printf("[AdminCert] Generated server certificate for %s", hostname)
	return nil
}
