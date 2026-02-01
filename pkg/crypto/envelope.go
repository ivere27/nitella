package crypto

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/sha256"
	"crypto/sha512"
	"errors"
	"io"
	"math/big"

	"golang.org/x/crypto/curve25519"
	"golang.org/x/crypto/hkdf"
)

// EncryptedPayload represents a hybrid-encrypted message.
// The payload is encrypted with AES-256-GCM, using a key derived from
// an X25519 shared secret (Ephemeral Sender Key + Static Recipient Key).
type EncryptedPayload struct {
	EphemeralPubKey   []byte // X25519 Ephemeral Public Key (32 bytes)
	Nonce             []byte // 12-byte GCM nonce
	Ciphertext        []byte // AES-GCM encrypted data
	SenderFingerprint string // SHA256 of sender's certificate (optional)
	Signature         []byte // Ed25519 signature
}

// Marshal serializes the payload to a byte slice.
// Version 1 (Packed): [EphemeralPubKey(32)][Nonce(12)][Ciphertext...]
func (p *EncryptedPayload) Marshal() []byte {
	res := make([]byte, 0, 32+12+len(p.Ciphertext))
	res = append(res, p.EphemeralPubKey...)
	res = append(res, p.Nonce...)
	res = append(res, p.Ciphertext...)
	return res
}

// UnmarshalEncryptedPayload deserializes bytes into an EncryptedPayload.
func UnmarshalEncryptedPayload(data []byte) (*EncryptedPayload, error) {
	if len(data) < 32+12 {
		return nil, errors.New("data too short")
	}
	p := &EncryptedPayload{
		EphemeralPubKey: data[:32],
		Nonce:           data[32 : 32+12],
		Ciphertext:      data[32+12:],
	}
	// Copy slices to be safe
	e := make([]byte, 32)
	copy(e, p.EphemeralPubKey)
	p.EphemeralPubKey = e

	n := make([]byte, 12)
	copy(n, p.Nonce)
	p.Nonce = n

	return p, nil
}

// Encrypt encrypts plaintext using X25519 ECDH + AES-256-GCM.
func Encrypt(plaintext []byte, recipientPubKey ed25519.PublicKey) (*EncryptedPayload, error) {
	if len(recipientPubKey) != ed25519.PublicKeySize {
		return nil, errors.New("invalid recipient public key size")
	}

	// 1. Convert Ed25519 Pub Key to X25519 Peer Pub Key
	peerPubKey, err := Ed25519PublicKeyToCurve25519(recipientPubKey)
	if err != nil {
		return nil, err
	}

	// 2. Generate Ephemeral X25519 Keypair
	ephemeralPrivKey := make([]byte, curve25519.ScalarSize)
	if _, err := io.ReadFull(rand.Reader, ephemeralPrivKey); err != nil {
		return nil, err
	}
	defer Wipe(ephemeralPrivKey)

	ephemeralPubKey, err := curve25519.X25519(ephemeralPrivKey, curve25519.Basepoint)
	if err != nil {
		return nil, err
	}

	// 3. Compute Shared Secret
	sharedSecret, err := curve25519.X25519(ephemeralPrivKey, peerPubKey)
	if err != nil {
		return nil, err
	}
	defer Wipe(sharedSecret)

	// 4. Derive AES-256 Key using HKDF
	aesKey, err := deriveKey(sharedSecret, ephemeralPubKey, peerPubKey)
	if err != nil {
		return nil, err
	}
	defer Wipe(aesKey)

	// 5. Create AES-GCM cipher
	block, err := aes.NewCipher(aesKey)
	if err != nil {
		return nil, err
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}

	// 6. Generate random nonce
	nonce := make([]byte, gcm.NonceSize())
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return nil, err
	}

	// 7. Encrypt with AAD (ephemeral public key binds ciphertext to key exchange)
	ciphertext := gcm.Seal(nil, nonce, plaintext, ephemeralPubKey)

	return &EncryptedPayload{
		EphemeralPubKey: ephemeralPubKey,
		Nonce:           nonce,
		Ciphertext:      ciphertext,
	}, nil
}

// Decrypt decrypts an EncryptedPayload using the recipient's private key.
func Decrypt(payload *EncryptedPayload, recipientPrivKey ed25519.PrivateKey) ([]byte, error) {
	if payload == nil {
		return nil, errors.New("payload is nil")
	}
	if len(recipientPrivKey) != ed25519.PrivateKeySize {
		return nil, errors.New("invalid recipient private key size")
	}

	// 1. Convert Ed25519 Priv Key to X25519 Priv Key
	x25519PrivKey := Ed25519PrivateKeyToCurve25519(recipientPrivKey)
	defer Wipe(x25519PrivKey)

	// 2. Compute Shared Secret
	sharedSecret, err := curve25519.X25519(x25519PrivKey, payload.EphemeralPubKey)
	if err != nil {
		return nil, err
	}
	defer Wipe(sharedSecret)

	// 3. Derive AES-256 Key using HKDF
	myPubKey := recipientPrivKey.Public().(ed25519.PublicKey)
	myX25519PubKey, _ := Ed25519PublicKeyToCurve25519(myPubKey)

	aesKey, err := deriveKey(sharedSecret, payload.EphemeralPubKey, myX25519PubKey)
	if err != nil {
		return nil, err
	}
	defer Wipe(aesKey)

	// 4. Create AES-GCM cipher
	block, err := aes.NewCipher(aesKey)
	if err != nil {
		return nil, err
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}

	if len(payload.Nonce) != gcm.NonceSize() {
		return nil, errors.New("invalid nonce size")
	}

	// 5. Decrypt with AAD (ephemeral public key binds ciphertext to key exchange)
	plaintext, err := gcm.Open(nil, payload.Nonce, payload.Ciphertext, payload.EphemeralPubKey)
	if err != nil {
		return nil, err
	}

	return plaintext, nil
}

// EncryptWithSignature is like Encrypt but also signs the ciphertext.
func EncryptWithSignature(plaintext []byte, recipientPubKey ed25519.PublicKey, senderPrivKey ed25519.PrivateKey, senderCertFingerprint string) (*EncryptedPayload, error) {
	payload, err := Encrypt(plaintext, recipientPubKey)
	if err != nil {
		return nil, err
	}
	payload.SenderFingerprint = senderCertFingerprint

	// Sign: EphemeralPubKey + Nonce + Ciphertext
	sigInput := make([]byte, 0, len(payload.EphemeralPubKey)+len(payload.Nonce)+len(payload.Ciphertext))
	sigInput = append(sigInput, payload.EphemeralPubKey...)
	sigInput = append(sigInput, payload.Nonce...)
	sigInput = append(sigInput, payload.Ciphertext...)

	signature, err := Sign(sigInput, senderPrivKey)
	if err != nil {
		return nil, err
	}
	payload.Signature = signature

	return payload, nil
}

// VerifySignature checks if the payload was signed by the claimed sender.
func VerifySignature(payload *EncryptedPayload, senderPubKey ed25519.PublicKey) error {
	if payload == nil {
		return errors.New("payload is nil")
	}
	if len(payload.Signature) == 0 {
		return errors.New("payload is not signed")
	}

	sigInput := make([]byte, 0, len(payload.EphemeralPubKey)+len(payload.Nonce)+len(payload.Ciphertext))
	sigInput = append(sigInput, payload.EphemeralPubKey...)
	sigInput = append(sigInput, payload.Nonce...)
	sigInput = append(sigInput, payload.Ciphertext...)

	return Verify(sigInput, payload.Signature, senderPubKey)
}

// deriveKey derives an AES-256 key from the shared secret and public keys.
func deriveKey(sharedSecret, ephemeralPubKey, recipientPubKey []byte) ([]byte, error) {
	// HKDF-SHA256
	// Salt: None (or zeros)
	// Info: "nitella-x25519-aes256-gcm" + ephemeralPubKey + recipientPubKey
	info := make([]byte, 0, 32+32+30)
	info = append(info, []byte("nitella-x25519-aes256-gcm")...)
	info = append(info, ephemeralPubKey...)
	info = append(info, recipientPubKey...)

	hkdfReader := hkdf.New(sha256.New, sharedSecret, nil, info)
	key := make([]byte, 32)
	if _, err := io.ReadFull(hkdfReader, key); err != nil {
		return nil, err
	}
	return key, nil
}

// Bit manipulation for Curve25519
var (
	p, _ = new(big.Int).SetString("7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed", 16)
	one  = big.NewInt(1)
)

// Small-order points in X25519 (must be rejected to prevent key leakage)
var smallOrderPoints = [][]byte{
	{0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}, // identity
	{0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}, // order 4
	{0xec, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f}, // order 8
	{0xe0, 0xeb, 0x7a, 0x7c, 0x3b, 0x41, 0xb8, 0xae, 0x16, 0x56, 0xe3, 0xfa, 0xf1, 0x9f, 0xc4, 0x6a, 0xda, 0x09, 0x8d, 0xeb, 0x9c, 0x32, 0xb1, 0xfd, 0x86, 0x62, 0x05, 0x16, 0x5f, 0x49, 0xb8, 0x00}, // order 8
	{0x5f, 0x9c, 0x95, 0xbc, 0xa3, 0x50, 0x8c, 0x24, 0xb1, 0xd0, 0xb1, 0x55, 0x9c, 0x83, 0xef, 0x5b, 0x04, 0x44, 0x5c, 0xc4, 0x58, 0x1c, 0x8e, 0x86, 0xd8, 0x22, 0x4e, 0xdd, 0xd0, 0x9f, 0x11, 0x57}, // order 8
	{0xed, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f}, // p-1
	{0xee, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f}, // p
}

// isSmallOrderPoint checks if a point is in the small-order subgroup
func isSmallOrderPoint(point []byte) bool {
	for _, sop := range smallOrderPoints {
		if len(point) == len(sop) {
			match := true
			for i := range point {
				if point[i] != sop[i] {
					match = false
					break
				}
			}
			if match {
				return true
			}
		}
	}
	return false
}

// Ed25519PublicKeyToCurve25519 converts an Ed25519 public key to X25519 public key.
// u = (1 + y) / (1 - y)
func Ed25519PublicKeyToCurve25519(pk ed25519.PublicKey) ([]byte, error) {
	// Ed25519 public key is 32 bytes: y-coordinate (compressed).
	yBytes := make([]byte, 32)
	copy(yBytes, pk)

	// Mask high bit to get y coordinate
	yBytes[31] &= 0x7f

	y := new(big.Int).SetBytes(reverse(yBytes))

	// Denominator: 1 - y
	denom := new(big.Int).Sub(one, y)
	denom.Mod(denom, p)

	// Inverse of denominator
	denomInv := new(big.Int).ModInverse(denom, p)
	if denomInv == nil {
		return nil, errors.New("conversion failed: invalid point")
	}

	// Numerator: 1 + y
	num := new(big.Int).Add(one, y)
	num.Mod(num, p)

	// u = num * denomInv
	u := new(big.Int).Mul(num, denomInv)
	u.Mod(u, p)

	uBytes := u.Bytes()

	// Pad to 32 bytes
	ret := make([]byte, 32)

	if len(uBytes) > 32 {
		return nil, errors.New("u overflow")
	}

	// Copy into ret (little endian)
	for i := 0; i < len(uBytes); i++ {
		ret[i] = uBytes[len(uBytes)-1-i]
	}

	// Check for small-order points (prevents key leakage attacks)
	if isSmallOrderPoint(ret) {
		return nil, errors.New("rejected: small-order point")
	}

	return ret, nil
}

// Ed25519PrivateKeyToCurve25519 converts a private key.
// This is simply a SHA512 hash of the seed.
func Ed25519PrivateKeyToCurve25519(priv ed25519.PrivateKey) []byte {
	// Ed25519 private key is 64 bytes: 32 bytes seed + 32 bytes pubKey
	// To get X25519 private key, we hash the seed.
	h := sha512Sum(priv[:32])

	// Clamp (as per Curve25519 spec)
	h[0] &= 248
	h[31] &= 127
	h[31] |= 64

	// Copy result and wipe the unused upper 32 bytes of the hash
	result := make([]byte, 32)
	copy(result, h[:32])
	Wipe(h[32:]) // Wipe unused portion that still contains key material

	return result
}

func sha512Sum(b []byte) []byte {
	h := sha512.Sum512(b)
	return h[:]
}

func reverse(b []byte) []byte {
	c := make([]byte, len(b))
	for i, v := range b {
		c[len(b)-1-i] = v
	}
	return c
}
