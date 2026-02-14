package pairing

import (
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/mdp/qrterminal/v3"
)

// QRPayload represents data encoded in pairing QR codes
type QRPayload struct {
	Type        string `json:"t"` // "csr" or "cert"
	CSR         string `json:"csr,omitempty"`
	Cert        string `json:"cert,omitempty"`
	CACert      string `json:"ca,omitempty"`
	Fingerprint string `json:"fp"` // Emoji fingerprint for verification
	NodeID      string `json:"nid,omitempty"`
}

// GenerateCSRQR generates a QR code containing the CSR for offline pairing
func GenerateCSRQR(csrPEM []byte, nodeID string, w io.Writer) error {
	fp := DeriveFingerprint(csrPEM)

	payload := QRPayload{
		Type:        "csr",
		CSR:         base64.StdEncoding.EncodeToString(csrPEM),
		Fingerprint: fp,
		NodeID:      nodeID,
	}

	data, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	// Generate QR code
	config := qrterminal.Config{
		Level:          qrterminal.L,
		Writer:         w,
		HalfBlocks:     true,
		BlackChar:      qrterminal.BLACK_BLACK,
		WhiteChar:      qrterminal.WHITE_WHITE,
		WhiteBlackChar: qrterminal.WHITE_BLACK,
		BlackWhiteChar: qrterminal.BLACK_WHITE,
		QuietZone:      2,
	}
	qrterminal.GenerateWithConfig(string(data), config)

	return nil
}

// GenerateCertQR generates a QR code containing the signed certificate
func GenerateCertQR(certPEM, caCertPEM []byte, w io.Writer) error {
	fp := DeriveFingerprint(certPEM)

	payload := QRPayload{
		Type:        "cert",
		Cert:        base64.StdEncoding.EncodeToString(certPEM),
		CACert:      base64.StdEncoding.EncodeToString(caCertPEM),
		Fingerprint: fp,
	}

	data, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	config := qrterminal.Config{
		Level:          qrterminal.L,
		Writer:         w,
		HalfBlocks:     true,
		BlackChar:      qrterminal.BLACK_BLACK,
		WhiteChar:      qrterminal.WHITE_WHITE,
		WhiteBlackChar: qrterminal.WHITE_BLACK,
		BlackWhiteChar: qrterminal.BLACK_WHITE,
		QuietZone:      2,
	}
	qrterminal.GenerateWithConfig(string(data), config)

	return nil
}

// ParseQRPayload parses a QR code payload
func ParseQRPayload(data string) (*QRPayload, error) {
	var payload QRPayload
	if err := json.Unmarshal([]byte(data), &payload); err != nil {
		return nil, fmt.Errorf("invalid QR payload: %w", err)
	}
	return &payload, nil
}

// GetCSR extracts and decodes the CSR from a QR payload
func (p *QRPayload) GetCSR() ([]byte, error) {
	if p.Type != "csr" {
		return nil, fmt.Errorf("payload type is not 'csr'")
	}
	return base64.StdEncoding.DecodeString(p.CSR)
}

// GetCert extracts and decodes the certificate from a QR payload
func (p *QRPayload) GetCert() ([]byte, error) {
	if p.Type != "cert" {
		return nil, fmt.Errorf("payload type is not 'cert'")
	}
	return base64.StdEncoding.DecodeString(p.Cert)
}

// GetCACert extracts and decodes the CA certificate from a QR payload
func (p *QRPayload) GetCACert() ([]byte, error) {
	if p.CACert == "" {
		return nil, nil
	}
	return base64.StdEncoding.DecodeString(p.CACert)
}

// DeriveFingerprint derives an emoji fingerprint from certificate/CSR data
func DeriveFingerprint(data []byte) string {
	hash := sha256.Sum256(data)

	emojis := []string{
		"🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼",
		"🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔",
		"🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺",
		"🐗", "🐴", "🦄", "🐝", "🐛", "🦋", "🐌", "🐞",
		"🌸", "🌺", "🌻", "🌹", "🌷", "🌼", "🌿", "🍀",
		"🍎", "🍊", "🍋", "🍇", "🍓", "🍒", "🍑", "🥝",
		"🌙", "⭐", "🌟", "✨", "⚡", "🔥", "🌈", "☀️",
		"🎸", "🎹", "🎺", "🎷", "🥁", "🎻", "🎤", "🎧",
	}

	result := ""
	for i := 0; i < 4; i++ {
		idx := int(hash[i*2]) % len(emojis)
		result += emojis[idx]
	}

	return result
}

// PrintQRToTerminal is a convenience function to print QR to stdout
func PrintQRToTerminal(data string) {
	config := qrterminal.Config{
		Level:          qrterminal.L,
		Writer:         os.Stdout,
		HalfBlocks:     true,
		BlackChar:      qrterminal.BLACK_BLACK,
		WhiteChar:      qrterminal.WHITE_WHITE,
		WhiteBlackChar: qrterminal.WHITE_BLACK,
		BlackWhiteChar: qrterminal.BLACK_WHITE,
		QuietZone:      2,
	}
	qrterminal.GenerateWithConfig(data, config)
}

// FormatCSRInfo builds a human-readable CSR summary for display layers.
func FormatCSRInfo(csrPEM []byte, nodeID string) string {
	fp := DeriveFingerprint(csrPEM)
	var b strings.Builder
	b.WriteString("\n")
	b.WriteString("╔══════════════════════════════════════════════════════════════╗\n")
	b.WriteString("║                    NODE PAIRING REQUEST                       ║\n")
	b.WriteString("╠══════════════════════════════════════════════════════════════╣\n")
	b.WriteString(fmt.Sprintf("║  Node ID:     %-46s  ║\n", truncate(nodeID, 46)))
	b.WriteString(fmt.Sprintf("║  Fingerprint: %-46s  ║\n", fp))
	b.WriteString("╠══════════════════════════════════════════════════════════════╣\n")
	b.WriteString("║  Verify the fingerprint matches what the node displays!      ║\n")
	b.WriteString("╚══════════════════════════════════════════════════════════════╝\n")
	b.WriteString("\n")
	return b.String()
}

func truncate(s string, maxLen int) string {
	if len(s) <= maxLen {
		return s
	}
	return s[:maxLen-3] + "..."
}
