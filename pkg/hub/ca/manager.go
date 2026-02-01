// Package ca handles Intermediate CA lease management for the Hub.
// The Hub generates ephemeral keypairs and receives signed Intermediate CA
// certificates from the Mobile Root CA, allowing it to issue user certificates.
package ca

import (
	"crypto/ed25519"
	"crypto/rand"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/pem"
	"errors"
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/crypto"
)

// Lease represents a time-bound Intermediate CA lease
type Lease struct {
	CertPEM   []byte
	Cert      *x509.Certificate
	ExpiresAt time.Time
}

// Manager handles Intermediate CA operations for the Hub.
// The Hub generates ephemeral keys and receives signed Intermediate CA
// certificates from the Mobile Root CA.
type Manager struct {
	mu sync.RWMutex

	// Ephemeral Key Pair (Rotated when lease expires)
	privKey ed25519.PrivateKey
	pubKey  ed25519.PublicKey

	// Current Active Lease (Signed by Mobile Root)
	activeLease *Lease
}

// NewManager creates a new CA Manager with a fresh ephemeral keypair.
func NewManager() (*Manager, error) {
	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		return nil, err
	}

	return &Manager{
		privKey: priv,
		pubKey:  pub,
	}, nil
}

// GenerateLeaseCSR creates a CSR for the Mobile App to sign.
// The Mobile App should use SignIntermediateCSR to sign this.
func (m *Manager) GenerateLeaseCSR(orgName string) ([]byte, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	return crypto.CreateCSR(m.privKey, "Nitella Hub Intermediate", orgName)
}

// SetLeaseCert activates the Intermediate CA with a signed certificate.
func (m *Manager) SetLeaseCert(certPEM []byte) error {
	block, _ := pem.Decode(certPEM)
	if block == nil {
		return errors.New("failed to decode cert PEM")
	}
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return err
	}

	// Validation
	if !cert.IsCA {
		return errors.New("certificate is not a CA")
	}

	// Check key match
	pubKey, ok := cert.PublicKey.(ed25519.PublicKey)
	if !ok {
		return errors.New("certificate public key is not Ed25519")
	}

	m.mu.Lock()
	defer m.mu.Unlock()

	if !pubKey.Equal(m.pubKey) {
		return errors.New("certificate public key does not match current private key")
	}

	m.activeLease = &Lease{
		CertPEM:   certPEM,
		Cert:      cert,
		ExpiresAt: cert.NotAfter,
	}

	return nil
}

// HasActiveLease returns true if there's a valid, non-expired lease.
func (m *Manager) HasActiveLease() bool {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.activeLease == nil {
		return false
	}
	return time.Now().Before(m.activeLease.ExpiresAt)
}

// GetLeaseCertPEM returns the current lease certificate PEM.
func (m *Manager) GetLeaseCertPEM() []byte {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.activeLease == nil {
		return nil
	}
	return m.activeLease.CertPEM
}

// GetLeaseExpiry returns when the current lease expires.
func (m *Manager) GetLeaseExpiry() time.Time {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.activeLease == nil {
		return time.Time{}
	}
	return m.activeLease.ExpiresAt
}

// GetPublicKey returns the current ephemeral public key.
func (m *Manager) GetPublicKey() ed25519.PublicKey {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.pubKey
}

// IssueNodeCert issues a certificate for a node from its CSR.
func (m *Manager) IssueNodeCert(csrPEM []byte, validDays int) ([]byte, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.activeLease == nil {
		return nil, errors.New("no active CA lease")
	}

	if time.Now().After(m.activeLease.ExpiresAt) {
		return nil, errors.New("active CA lease has expired")
	}

	// Use the crypto package to sign the CSR
	return crypto.SignCSR(csrPEM, m.activeLease.CertPEM, m.privKey, validDays)
}

// IssueUserCert issues a short-lived client certificate for a user.
// This is used for SSO logins and user authentication.
func (m *Manager) IssueUserCert(userPubKey ed25519.PublicKey, username string, validDuration time.Duration) ([]byte, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if m.activeLease == nil {
		return nil, errors.New("no active CA lease")
	}

	if time.Now().After(m.activeLease.ExpiresAt) {
		return nil, errors.New("active CA lease has expired")
	}

	// Generate serial number (timestamp + random for uniqueness)
	serialNumber, err := crypto.GenerateCertSerial()
	if err != nil {
		return nil, err
	}

	// Create user certificate template
	template := x509.Certificate{
		SerialNumber: serialNumber,
		Subject: pkix.Name{
			CommonName:   username,
			Organization: []string{"Nitella User"},
		},
		NotBefore:   time.Now(),
		NotAfter:    time.Now().Add(validDuration),
		KeyUsage:    x509.KeyUsageDigitalSignature,
		ExtKeyUsage: []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth},
	}

	// Ensure user cert doesn't outlive the CA
	if template.NotAfter.After(m.activeLease.Cert.NotAfter) {
		template.NotAfter = m.activeLease.Cert.NotAfter
	}

	derBytes, err := x509.CreateCertificate(rand.Reader, &template, m.activeLease.Cert, userPubKey, m.privKey)
	if err != nil {
		return nil, err
	}

	return pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: derBytes}), nil
}

// RotateKeys generates a new ephemeral keypair and invalidates the current lease.
// This should be called when the lease expires or is compromised.
func (m *Manager) RotateKeys() error {
	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		return err
	}

	m.mu.Lock()
	defer m.mu.Unlock()

	m.privKey = priv
	m.pubKey = pub
	m.activeLease = nil

	return nil
}
