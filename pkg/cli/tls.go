package cli

import (
	"crypto/x509"
	"fmt"
	"os"
)

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
