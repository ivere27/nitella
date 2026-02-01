package crypto

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/pem"
	"errors"
	"fmt"
	"math/big"
	"time"

	"golang.org/x/crypto/argon2"
)

// GenerateKey generates a new Ed25519 key pair.
func GenerateKey() (ed25519.PrivateKey, error) {
	_, priv, err := ed25519.GenerateKey(rand.Reader)
	return priv, err
}

// GenerateCertSerial creates a unique certificate serial number
// combining timestamp and random bytes to minimize collision risk
func GenerateCertSerial() (*big.Int, error) {
	// Use timestamp (8 bytes) + random (8 bytes) = 128 bits
	// This ensures uniqueness even if random source has issues
	timestamp := time.Now().UnixNano()
	tsBytes := big.NewInt(timestamp).Bytes()

	// Generate 8 random bytes
	randomBytes := make([]byte, 8)
	if _, err := rand.Read(randomBytes); err != nil {
		return nil, err
	}

	// Combine: timestamp || random
	serialBytes := make([]byte, 0, 16)
	// Pad timestamp to 8 bytes
	padding := make([]byte, 8-len(tsBytes))
	serialBytes = append(serialBytes, padding...)
	serialBytes = append(serialBytes, tsBytes...)
	serialBytes = append(serialBytes, randomBytes...)

	return new(big.Int).SetBytes(serialBytes), nil
}

// GenerateRootCA creates a self-signed Root CA certificate.
func GenerateRootCA(priv ed25519.PrivateKey, commonName, organization string, validYears int) ([]byte, error) {
	notBefore := time.Now()
	notAfter := notBefore.AddDate(validYears, 0, 0)

	serialNumber, err := GenerateCertSerial()
	if err != nil {
		return nil, err
	}

	pub := priv.Public().(ed25519.PublicKey)

	template := x509.Certificate{
		SerialNumber: serialNumber,
		Subject: pkix.Name{
			CommonName:   commonName,
			Organization: []string{organization},
		},
		NotBefore:             notBefore,
		NotAfter:              notAfter,
		KeyUsage:              x509.KeyUsageCertSign | x509.KeyUsageCRLSign | x509.KeyUsageDigitalSignature,
		BasicConstraintsValid: true,
		IsCA:                  true,
	}

	derBytes, err := x509.CreateCertificate(rand.Reader, &template, &template, pub, priv)
	if err != nil {
		return nil, err
	}

	return pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: derBytes}), nil
}

// CreateCSR generates a Certificate Signing Request.
func CreateCSR(priv ed25519.PrivateKey, commonName, ou string) ([]byte, error) {
	template := x509.CertificateRequest{
		Subject: pkix.Name{
			CommonName:         commonName,
			OrganizationalUnit: []string{ou},
		},
	}

	csrBytes, err := x509.CreateCertificateRequest(rand.Reader, &template, priv)
	if err != nil {
		return nil, err
	}

	return pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE REQUEST", Bytes: csrBytes}), nil
}

// SignCSR signs a CSR using the provided CA certificate and private key.
func SignCSR(csrPEM []byte, caCertPEM []byte, caPriv ed25519.PrivateKey, validDays int) ([]byte, error) {
	// 1. Parse CSR
	block, _ := pem.Decode(csrPEM)
	if block == nil {
		return nil, errors.New("failed to decode CSR PEM")
	}
	csr, err := x509.ParseCertificateRequest(block.Bytes)
	if err != nil {
		return nil, err
	}
	if err := csr.CheckSignature(); err != nil {
		return nil, err
	}

	// 2. Parse CA Cert
	block, _ = pem.Decode(caCertPEM)
	if block == nil {
		return nil, errors.New("failed to decode CA Cert PEM")
	}
	caCert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return nil, err
	}

	// 3. Create Client Certificate Template
	// Generate serial number with timestamp prefix to reduce collision risk
	// Format: [64-bit timestamp nanoseconds][64-bit random]
	serialNumber, err := GenerateCertSerial()
	if err != nil {
		return nil, err
	}

	template := x509.Certificate{
		SerialNumber: serialNumber,
		Subject:      csr.Subject,
		NotBefore:    time.Now(),
		NotAfter:     time.Now().AddDate(0, 0, validDays),
		KeyUsage:     x509.KeyUsageDigitalSignature,
		ExtKeyUsage:  []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth, x509.ExtKeyUsageServerAuth},
	}

	// 4. Sign
	derBytes, err := x509.CreateCertificate(rand.Reader, &template, caCert, csr.PublicKey, caPriv)
	if err != nil {
		return nil, err
	}

	return pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: derBytes}), nil
}

// SignIntermediateCSR signs a CSR to create an Intermediate CA certificate.
func SignIntermediateCSR(csrPEM []byte, parentCertPEM []byte, parentPriv ed25519.PrivateKey, validDays int) ([]byte, error) {
	// 1. Parse CSR
	block, _ := pem.Decode(csrPEM)
	if block == nil {
		return nil, errors.New("failed to decode CSR PEM")
	}
	csr, err := x509.ParseCertificateRequest(block.Bytes)
	if err != nil {
		return nil, err
	}
	if err := csr.CheckSignature(); err != nil {
		return nil, err
	}

	// 2. Parse Parent CA Cert
	block, _ = pem.Decode(parentCertPEM)
	if block == nil {
		return nil, errors.New("failed to decode Parent Cert PEM")
	}
	parentCert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return nil, err
	}

	// 3. Create Intermediate CA Template
	serialNumber, err := GenerateCertSerial()
	if err != nil {
		return nil, err
	}

	template := x509.Certificate{
		SerialNumber: serialNumber,
		Subject:      csr.Subject,
		NotBefore:    time.Now(),
		NotAfter:     time.Now().AddDate(0, 0, validDays),

		// CA Capabilities
		KeyUsage:              x509.KeyUsageCertSign | x509.KeyUsageCRLSign | x509.KeyUsageDigitalSignature,
		BasicConstraintsValid: true,
		IsCA:                  true,
		MaxPathLen:            0, // Restricted: Cannot sign other CAs
		MaxPathLenZero:        true,
	}

	// 4. Sign
	derBytes, err := x509.CreateCertificate(rand.Reader, &template, parentCert, csr.PublicKey, parentPriv)
	if err != nil {
		return nil, err
	}

	return pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: derBytes}), nil
}

// EncodePrivateKeyToPEM encodes a private key to PEM format using PKCS#8.
func EncodePrivateKeyToPEM(priv ed25519.PrivateKey) []byte {
	pkcs8Bytes, err := x509.MarshalPKCS8PrivateKey(priv)
	if err != nil {
		return nil
	}
	return pem.EncodeToMemory(&pem.Block{
		Type:  "PRIVATE KEY",
		Bytes: pkcs8Bytes,
	})
}

// EncodePublicKeyToPEM encodes a public key to PEM format using PKIX.
func EncodePublicKeyToPEM(pub ed25519.PublicKey) []byte {
	pkixBytes, err := x509.MarshalPKIXPublicKey(pub)
	if err != nil {
		return nil
	}
	return pem.EncodeToMemory(&pem.Block{
		Type:  "PUBLIC KEY",
		Bytes: pkixBytes,
	})
}

// DecodePrivateKeyFromPEM decodes a private key from PEM format.
func DecodePrivateKeyFromPEM(keyPEM []byte) (ed25519.PrivateKey, error) {
	block, _ := pem.Decode(keyPEM)
	if block == nil {
		return nil, errors.New("failed to decode private key PEM")
	}

	// Parse PKCS#8
	key, err := x509.ParsePKCS8PrivateKey(block.Bytes)
	if err != nil {
		return nil, err
	}
	edKey, ok := key.(ed25519.PrivateKey)
	if !ok {
		return nil, errors.New("parsed key is not an Ed25519 private key")
	}
	return edKey, nil
}

// DecodePublicKeyFromPEM decodes a public key from PEM format.
func DecodePublicKeyFromPEM(keyPEM []byte) (ed25519.PublicKey, error) {
	block, _ := pem.Decode(keyPEM)
	if block == nil {
		return nil, errors.New("failed to decode public key PEM")
	}

	// Check if it's a certificate
	if block.Type == "CERTIFICATE" {
		cert, err := x509.ParseCertificate(block.Bytes)
		if err != nil {
			return nil, fmt.Errorf("failed to parse certificate: %w", err)
		}
		edKey, ok := cert.PublicKey.(ed25519.PublicKey)
		if !ok {
			return nil, errors.New("certificate public key is not Ed25519")
		}
		return edKey, nil
	}

	// Try PKIX
	key, err := x509.ParsePKIXPublicKey(block.Bytes)
	if err != nil {
		return nil, err
	}
	edKey, ok := key.(ed25519.PublicKey)
	if !ok {
		return nil, errors.New("parsed key is not an Ed25519 public key")
	}
	return edKey, nil
}

// ============================================================================
// Passphrase-Protected Key Functions
// ============================================================================

// Encrypted key format versions
const (
	EncryptedKeyV1 = 0x01 // Original format: salt(16) + nonce(12) + ciphertext
	EncryptedKeyV2 = 0x02 // With KDF params: version(1) + kdf(9) + salt(16) + nonce(12) + ciphertext
)

// EncryptPrivateKeyToPEM encrypts a private key with a passphrase using default KDF params.
// Uses PKCS#8 format with AES-256-GCM encryption, key derived via Argon2id.
func EncryptPrivateKeyToPEM(priv ed25519.PrivateKey, passphrase string) ([]byte, error) {
	return EncryptPrivateKeyToPEMWithParams(priv, passphrase, KDFDefault)
}

// EncryptPrivateKeyToPEMWithParams encrypts a private key with configurable KDF parameters.
// Uses PKCS#8 format with AES-256-GCM encryption, key derived via Argon2id.
func EncryptPrivateKeyToPEMWithParams(priv ed25519.PrivateKey, passphrase string, kdf KDFParams) ([]byte, error) {
	if passphrase == "" {
		return EncodePrivateKeyToPEM(priv), nil
	}

	// Marshal to PKCS#8
	pkcs8Bytes, err := x509.MarshalPKCS8PrivateKey(priv)
	if err != nil {
		return nil, err
	}

	// Derive key from passphrase using Argon2id
	salt := make([]byte, 16)
	if _, err := rand.Read(salt); err != nil {
		return nil, err
	}
	key := argon2.IDKey([]byte(passphrase), salt, kdf.Time, kdf.Memory, kdf.Threads, 32)
	defer Wipe(key)

	// Encrypt with AES-256-GCM
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}

	nonce := make([]byte, gcm.NonceSize())
	if _, err := rand.Read(nonce); err != nil {
		return nil, err
	}

	ciphertext := gcm.Seal(nil, nonce, pkcs8Bytes, nil)

	// Format V2: version(1) + kdf(9) + salt(16) + nonce(12) + ciphertext
	kdfBytes := kdf.Encode()
	encrypted := make([]byte, 0, 1+len(kdfBytes)+len(salt)+len(nonce)+len(ciphertext))
	encrypted = append(encrypted, EncryptedKeyV2)
	encrypted = append(encrypted, kdfBytes...)
	encrypted = append(encrypted, salt...)
	encrypted = append(encrypted, nonce...)
	encrypted = append(encrypted, ciphertext...)

	return pem.EncodeToMemory(&pem.Block{
		Type:  "ENCRYPTED PRIVATE KEY",
		Bytes: encrypted,
	}), nil
}

// DecryptPrivateKeyFromPEM decrypts a passphrase-protected private key.
// Supports both V1 (legacy) and V2 (with KDF params) formats.
func DecryptPrivateKeyFromPEM(keyPEM []byte, passphrase string) (ed25519.PrivateKey, error) {
	block, _ := pem.Decode(keyPEM)
	if block == nil {
		return nil, errors.New("failed to decode private key PEM")
	}

	// Check if encrypted
	if block.Type == "ENCRYPTED PRIVATE KEY" {
		if passphrase == "" {
			return nil, errors.New("passphrase required for encrypted key")
		}

		data := block.Bytes
		if len(data) < 28 { // Minimum: salt(16) + nonce(12)
			return nil, errors.New("encrypted key data too short")
		}

		var salt, nonce, ciphertext []byte
		var kdf KDFParams

		// Detect format version
		if data[0] == EncryptedKeyV2 && len(data) >= 38 { // version(1) + kdf(9) + salt(16) + nonce(12)
			// V2 format with KDF params
			var err error
			kdf, err = DecodeKDFParams(data[1:10])
			if err != nil {
				return nil, fmt.Errorf("failed to decode KDF params: %w", err)
			}
			salt = data[10:26]
			nonce = data[26:38]
			ciphertext = data[38:]
		} else {
			// V1 legacy format - use default params
			kdf = KDFDefault
			salt = data[:16]
			nonce = data[16:28]
			ciphertext = data[28:]
		}

		// Derive key from passphrase using Argon2id
		key := argon2.IDKey([]byte(passphrase), salt, kdf.Time, kdf.Memory, kdf.Threads, 32)
		defer Wipe(key)

		// Decrypt with AES-256-GCM
		cipherBlock, err := aes.NewCipher(key)
		if err != nil {
			return nil, err
		}
		gcm, err := cipher.NewGCM(cipherBlock)
		if err != nil {
			return nil, err
		}

		pkcs8Bytes, err := gcm.Open(nil, nonce, ciphertext, nil)
		if err != nil {
			return nil, errors.New("decryption failed: wrong passphrase or corrupted data")
		}
		defer Wipe(pkcs8Bytes)

		// Parse PKCS#8
		key2, err := x509.ParsePKCS8PrivateKey(pkcs8Bytes)
		if err != nil {
			return nil, err
		}
		edKey, ok := key2.(ed25519.PrivateKey)
		if !ok {
			return nil, errors.New("decrypted key is not an Ed25519 private key")
		}
		return edKey, nil
	}

	// Not encrypted - use standard decode
	return DecodePrivateKeyFromPEM(keyPEM)
}

// GetEncryptedKeyKDFParams extracts KDF parameters from an encrypted key PEM.
// Returns the KDF params used, or default params for V1 format.
func GetEncryptedKeyKDFParams(keyPEM []byte) (KDFParams, error) {
	block, _ := pem.Decode(keyPEM)
	if block == nil {
		return KDFParams{}, errors.New("failed to decode PEM")
	}

	if block.Type != "ENCRYPTED PRIVATE KEY" {
		return KDFParams{}, errors.New("key is not encrypted")
	}

	data := block.Bytes
	if len(data) < 10 {
		return KDFParams{}, errors.New("encrypted key data too short")
	}

	// Check for V2 format
	if data[0] == EncryptedKeyV2 {
		return DecodeKDFParams(data[1:10])
	}

	// V1 format - return default params
	return KDFDefault, nil
}
