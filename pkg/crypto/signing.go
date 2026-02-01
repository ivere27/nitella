package crypto

import (
	"crypto/ed25519"
	"crypto/x509"
	"encoding/base64"
	"encoding/pem"
	"errors"
	"fmt"
	"time"
)

// SignedPayload represents a message with its cryptographic signature
type SignedPayload struct {
	Data       []byte `json:"data"`
	Signature  []byte `json:"signature"`
	SignerCert string `json:"signer_cert"` // PEM-encoded certificate of signer
}

// Sign signs data using Ed25519 and returns the signature
func Sign(data []byte, privKey ed25519.PrivateKey) ([]byte, error) {
	if len(privKey) != ed25519.PrivateKeySize {
		return nil, errors.New("invalid private key size")
	}

	// Ed25519 is deterministic and safe for direct signing.
	return ed25519.Sign(privKey, data), nil
}

// Verify verifies the Ed25519 signature of data using the public key
func Verify(data, signature []byte, pubKey ed25519.PublicKey) error {
	if len(pubKey) != ed25519.PublicKeySize {
		return errors.New("invalid public key size")
	}

	if !ed25519.Verify(pubKey, data, signature) {
		return errors.New("signature verification failed")
	}

	return nil
}

// SignWithCert creates a SignedPayload with the signer's certificate
func SignWithCert(data []byte, privKey ed25519.PrivateKey, certPEM []byte) (*SignedPayload, error) {
	signature, err := Sign(data, privKey)
	if err != nil {
		return nil, err
	}

	return &SignedPayload{
		Data:       data,
		Signature:  signature,
		SignerCert: string(certPEM),
	}, nil
}

// VerifyWithCert verifies a SignedPayload and checks that the signer's cert is valid
// caCertPEM is the trusted CA certificate to verify the signer's certificate against
func VerifyWithCert(payload *SignedPayload, caCertPEM []byte) error {
	if payload == nil {
		return errors.New("payload is nil")
	}

	// Parse signer cert
	block, _ := pem.Decode([]byte(payload.SignerCert))
	if block == nil {
		return errors.New("failed to decode signer certificate PEM")
	}
	signerCert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return fmt.Errorf("failed to parse signer certificate: %w", err)
	}

	// Parse CA cert
	block, _ = pem.Decode(caCertPEM)
	if block == nil {
		return errors.New("failed to decode CA certificate PEM")
	}
	caCert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return fmt.Errorf("failed to parse CA certificate: %w", err)
	}

	// Verify signer cert is signed by CA
	if err := signerCert.CheckSignatureFrom(caCert); err != nil {
		return fmt.Errorf("signer certificate not signed by trusted CA: %w", err)
	}

	// Check certificate validity period
	now := time.Now()
	if now.Before(signerCert.NotBefore) {
		return fmt.Errorf("signer certificate not yet valid (NotBefore: %v)", signerCert.NotBefore)
	}
	if now.After(signerCert.NotAfter) {
		return fmt.Errorf("signer certificate has expired (NotAfter: %v)", signerCert.NotAfter)
	}

	// Check key usage allows digital signature
	if signerCert.KeyUsage != 0 && signerCert.KeyUsage&x509.KeyUsageDigitalSignature == 0 {
		return errors.New("signer certificate key usage does not allow digital signatures")
	}

	// Extract public key from signer cert
	pubKey, ok := signerCert.PublicKey.(ed25519.PublicKey)
	if !ok {
		return errors.New("signer certificate does not contain Ed25519 public key")
	}

	// Verify signature
	return Verify(payload.Data, payload.Signature, pubKey)
}

// SignBase64 signs data and returns base64-encoded signature
func SignBase64(data []byte, privKey ed25519.PrivateKey) (string, error) {
	sig, err := Sign(data, privKey)
	if err != nil {
		return "", err
	}
	return base64.StdEncoding.EncodeToString(sig), nil
}

// VerifyBase64 verifies a base64-encoded signature
func VerifyBase64(data []byte, signatureB64 string, pubKey ed25519.PublicKey) error {
	signature, err := base64.StdEncoding.DecodeString(signatureB64)
	if err != nil {
		return fmt.Errorf("failed to decode signature: %w", err)
	}
	return Verify(data, signature, pubKey)
}
