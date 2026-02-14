package core

import (
	"crypto/ed25519"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"net"
	"os"
	"strings"
	"time"

	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
)

// HubCAInfo contains the result of probing a Hub's CA certificate.
type HubCAInfo struct {
	CaPEM       []byte
	Fingerprint string
	EmojiHash   string
	Subject     string
	Expires     string
}

// ProbeHubCA connects to a Hub server with InsecureSkipVerify on an isolated,
// short-lived connection solely to extract the server's CA certificate for
// TOFU (Trust On First Use) verification. No application data is exchanged.
//
// The returned HubCAInfo contains the CA PEM, SHA-256 fingerprint, emoji hash,
// subject, and expiry for the user to verify before trusting.
func ProbeHubCA(hubAddr string) (*HubCAInfo, error) {
	if hubAddr == "" {
		return nil, fmt.Errorf("hub address not specified")
	}

	// Ensure host:port format for raw TLS dial
	host := hubAddr
	if !strings.Contains(host, ":") {
		host = host + ":443"
	}

	// Isolated probe connection — InsecureSkipVerify is required here because
	// we don't yet have the CA. This connection is ONLY used to capture the
	// certificate chain; no application data is exchanged.
	dialer := &net.Dialer{Timeout: 10 * time.Second}
	conn, err := tls.DialWithDialer(dialer, "tcp", host, &tls.Config{
		MinVersion:         tls.VersionTLS13,
		InsecureSkipVerify: true, // #nosec G402 — TOFU probe only, cert verified by user
	})
	if err != nil {
		return nil, fmt.Errorf("failed to probe hub: %w", err)
	}
	defer conn.Close()

	peerCerts := conn.ConnectionState().PeerCertificates
	if len(peerCerts) == 0 {
		return nil, fmt.Errorf("hub presented no certificates")
	}

	// Find the root CA (last cert in chain, or self-signed cert)
	var caCert *x509.Certificate
	for i := len(peerCerts) - 1; i >= 0; i-- {
		if peerCerts[i].IsCA {
			caCert = peerCerts[i]
			break
		}
	}
	// If no CA found, use the last cert (self-signed leaf)
	if caCert == nil {
		caCert = peerCerts[len(peerCerts)-1]
	}

	// Encode CA cert to PEM
	caPEM := pem.EncodeToMemory(&pem.Block{
		Type:  "CERTIFICATE",
		Bytes: caCert.Raw,
	})

	// Compute fingerprint and emoji hash
	fingerprint, emojiHash := CertFingerprintAndEmoji(caCert)

	return &HubCAInfo{
		CaPEM:       caPEM,
		Fingerprint: fingerprint,
		EmojiHash:   emojiHash,
		Subject:     caCert.Subject.CommonName,
		Expires:     caCert.NotAfter.Format("2006-01-02"),
	}, nil
}

// CertFingerprintAndEmoji computes the SHA-256 fingerprint and emoji hash
// of a certificate's public key. Works with both Ed25519 and non-Ed25519 keys.
func CertFingerprintAndEmoji(cert *x509.Certificate) (fingerprint string, emojiHash string) {
	if pubKey, ok := cert.PublicKey.(ed25519.PublicKey); ok {
		fpBytes, err := nitellacrypto.GetSPKIFingerprint(pubKey)
		if err != nil {
			hash := sha256.Sum256(cert.RawSubjectPublicKeyInfo)
			fingerprint = fmt.Sprintf("%x", hash)
		} else {
			fingerprint = fmt.Sprintf("%x", fpBytes)
			emojis := nitellacrypto.HashToEmojis(fpBytes)
			emojiHash = strings.Join(emojis, " ")
		}
	} else {
		// Non-Ed25519 fallback
		hash := sha256.Sum256(cert.RawSubjectPublicKeyInfo)
		fingerprint = fmt.Sprintf("%x", hash)
		emojis := nitellacrypto.HashToEmojis(hash[:])
		emojiHash = strings.Join(emojis, " ")
	}
	return
}

// LoadCertPool loads a certificate pool from a file path.
// If caFile is empty, returns the system cert pool.
func LoadCertPool(caFile string) (*x509.CertPool, error) {
	if caFile == "" {
		return x509.SystemCertPool()
	}
	caPEM, err := os.ReadFile(caFile)
	if err != nil {
		return nil, fmt.Errorf("failed to read CA certificate: %w", err)
	}
	pool := x509.NewCertPool()
	if !pool.AppendCertsFromPEM(caPEM) {
		return nil, fmt.Errorf("failed to parse CA certificate")
	}
	return pool, nil
}

// LoadCertPoolFromPEM loads a certificate pool from PEM bytes.
// If caPEM is empty, returns the system cert pool.
func LoadCertPoolFromPEM(caPEM []byte) (*x509.CertPool, error) {
	if len(caPEM) == 0 {
		return x509.SystemCertPool()
	}
	pool := x509.NewCertPool()
	if !pool.AppendCertsFromPEM(caPEM) {
		return nil, fmt.Errorf("failed to parse CA certificate")
	}
	return pool, nil
}
