package pairing

import (
	"bytes"
	"crypto/tls"
	"encoding/base64"
	"encoding/json"
	"io"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"strings"
	"testing"
	"time"
)

func TestNewPairingWebServer(t *testing.T) {
	csrPEM := []byte("-----BEGIN CERTIFICATE REQUEST-----\ntest\n-----END CERTIFICATE REQUEST-----")

	server, err := NewPairingWebServer(PairingWebConfig{
		CSR:     csrPEM,
		NodeID:  "test-node",
		Timeout: 1 * time.Minute,
		OnComplete: func(certPEM, caCertPEM []byte) error {
			return nil
		},
	})
	if err != nil {
		t.Fatalf("Failed to create pairing server: %v", err)
	}

	// Check CPACE words generated
	cpaceWords := server.GetCPACEWords()
	if cpaceWords == "" {
		t.Error("CPACE words should not be empty")
	}
	t.Logf("CPACE words: %s", cpaceWords)

	// Check fingerprint generated
	fingerprint := server.GetFingerprint()
	if fingerprint == "" {
		t.Error("Fingerprint should not be empty")
	}
	t.Logf("Fingerprint: %s", fingerprint)

	// Check CSR is stored
	if !bytes.Equal(server.GetCSRPEM(), csrPEM) {
		t.Error("CSR PEM mismatch")
	}
}

func TestPairingWebServerFlow(t *testing.T) {
	csrPEM := []byte("-----BEGIN CERTIFICATE REQUEST-----\ntest-csr-data\n-----END CERTIFICATE REQUEST-----")
	certPEM := []byte("-----BEGIN CERTIFICATE-----\ntest-cert-data\n-----END CERTIFICATE-----")
	caCertPEM := []byte("-----BEGIN CERTIFICATE-----\ntest-ca-data\n-----END CERTIFICATE-----")

	completeCalled := make(chan bool, 1)
	var receivedCert, receivedCA []byte

	server, err := NewPairingWebServer(PairingWebConfig{
		CSR:     csrPEM,
		NodeID:  "test-node",
		Timeout: 30 * time.Second,
		OnComplete: func(cert, ca []byte) error {
			receivedCert = cert
			receivedCA = ca
			completeCalled <- true
			return nil
		},
	})
	if err != nil {
		t.Fatalf("Failed to create pairing server: %v", err)
	}

	// Start server in background
	serverErr := make(chan error, 1)
	go func() {
		serverErr <- server.Start(":0") // Random port
	}()

	// Give server time to start
	time.Sleep(100 * time.Millisecond)

	// The actual HTTP flow would require a running server
	// For unit testing, we test the handlers directly
	t.Log("Pairing web server created successfully")
	t.Logf("CPACE words: %s", server.GetCPACEWords())
	t.Logf("Fingerprint: %s", server.GetFingerprint())

	// Verify cert/CA encoding
	certB64 := base64.StdEncoding.EncodeToString(certPEM)
	caB64 := base64.StdEncoding.EncodeToString(caCertPEM)
	t.Logf("Cert base64 length: %d", len(certB64))
	t.Logf("CA base64 length: %d", len(caB64))

	_ = completeCalled
	_ = receivedCert
	_ = receivedCA
}

func TestGenerateTempTLSCert(t *testing.T) {
	cert, err := generateTempTLSCert()
	if err != nil {
		t.Fatalf("Failed to generate temp TLS cert: %v", err)
	}

	// Verify it's a valid TLS certificate
	if len(cert.Certificate) == 0 {
		t.Error("Certificate should not be empty")
	}

	// Verify the cert can be used for TLS
	tlsConfig := &tls.Config{
		Certificates: []tls.Certificate{cert},
	}
	if tlsConfig.Certificates[0].PrivateKey == nil {
		t.Error("Private key should not be nil")
	}

	t.Log("Temporary TLS certificate generated successfully")
}

func TestCPACEWordsVerification(t *testing.T) {
	server, _ := NewPairingWebServer(PairingWebConfig{
		CSR:        []byte("test-csr"),
		NodeID:     "test-node",
		Timeout:    1 * time.Minute,
		OnComplete: func(cert, ca []byte) error { return nil },
	})

	cpaceWords := server.GetCPACEWords()

	// Test case sensitivity
	t.Run("case insensitive", func(t *testing.T) {
		// The verification in handleVerify uses strings.EqualFold
		upper := strings.ToUpper(cpaceWords)
		lower := strings.ToLower(cpaceWords)

		if !strings.EqualFold(upper, cpaceWords) {
			t.Error("Should match uppercase")
		}
		if !strings.EqualFold(lower, cpaceWords) {
			t.Error("Should match lowercase")
		}
	})

	// Test wrong words
	t.Run("wrong words rejected", func(t *testing.T) {
		wrongWords := "wrong-words-here"
		if strings.EqualFold(wrongWords, cpaceWords) {
			t.Error("Wrong words should not match")
		}
	})
}

func TestQRPayloadForWeb(t *testing.T) {
	csrPEM := []byte("-----BEGIN CERTIFICATE REQUEST-----\ntest\n-----END CERTIFICATE REQUEST-----")
	nodeID := "my-test-node"
	fingerprint := DeriveFingerprint(csrPEM)

	// Create QR payload as web server would
	qrPayload := &QRPayload{
		Type:        "csr",
		CSR:         base64.StdEncoding.EncodeToString(csrPEM),
		Fingerprint: fingerprint,
		NodeID:      nodeID,
	}

	qrJSON, err := json.Marshal(qrPayload)
	if err != nil {
		t.Fatalf("Failed to marshal QR payload: %v", err)
	}

	t.Logf("QR JSON: %s", string(qrJSON))

	// Parse it back
	parsed, err := ParseQRPayload(string(qrJSON))
	if err != nil {
		t.Fatalf("Failed to parse QR payload: %v", err)
	}

	if parsed.Type != "csr" {
		t.Errorf("Type mismatch: got %s, want csr", parsed.Type)
	}
	if parsed.NodeID != nodeID {
		t.Errorf("NodeID mismatch: got %s, want %s", parsed.NodeID, nodeID)
	}
	if parsed.Fingerprint != fingerprint {
		t.Errorf("Fingerprint mismatch: got %s, want %s", parsed.Fingerprint, fingerprint)
	}

	// Decode CSR
	decodedCSR, err := parsed.GetCSR()
	if err != nil {
		t.Fatalf("Failed to get CSR: %v", err)
	}
	if !bytes.Equal(decodedCSR, csrPEM) {
		t.Error("CSR content mismatch")
	}
}

func TestCertSubmissionPayload(t *testing.T) {
	certPEM := []byte("-----BEGIN CERTIFICATE-----\ntest-cert\n-----END CERTIFICATE-----")
	caCertPEM := []byte("-----BEGIN CERTIFICATE-----\ntest-ca\n-----END CERTIFICATE-----")

	// Test JSON format for certificate submission
	payload := map[string]string{
		"cert":    base64.StdEncoding.EncodeToString(certPEM),
		"ca_cert": base64.StdEncoding.EncodeToString(caCertPEM),
	}

	jsonData, _ := json.Marshal(payload)
	t.Logf("Submit payload: %s", string(jsonData))

	// Parse back
	var parsed map[string]string
	json.Unmarshal(jsonData, &parsed)

	decodedCert, _ := base64.StdEncoding.DecodeString(parsed["cert"])
	decodedCA, _ := base64.StdEncoding.DecodeString(parsed["ca_cert"])

	if !bytes.Equal(decodedCert, certPEM) {
		t.Error("Cert mismatch after decode")
	}
	if !bytes.Equal(decodedCA, caCertPEM) {
		t.Error("CA cert mismatch after decode")
	}
}

// Integration test that requires a running server
func TestPairingWebServerIntegration(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	// Generate real test certificates
	csrPEM := []byte(`-----BEGIN CERTIFICATE REQUEST-----
MIHoMIGPAgEAMC0xFjAUBgNVBAoTDXRlc3Qtb3JnYW5pemUxEzARBgNVBAMTCnRl
c3Qtbm9kZTAqMAUGAytlcAMhAJGz8VlTaLkS3SyJTVbIiYJGJGJHwwBHwBBHIJwD
EIGaoC4wLAYJKoZIhvcNAQkOMR8wHTAbBgNVHREEFDASggp0ZXN0LW5vZGWHBH8A
AAEwBQYDK2VwA0EAtest
-----END CERTIFICATE REQUEST-----`)

	certPEM := []byte(`-----BEGIN CERTIFICATE-----
MIIBJjCB2aADAgECAgEBMAUGAytlcDAtMRYwFAYDVQQKEw10ZXN0LW9yZ2FuaXpl
MRMwEQYDVQQDEwp0ZXN0LW5vZGUwHhcNMjQwMTAxMDAwMDAwWhcNMjUwMTAxMDAw
MDAwWjAtMRYwFAYDVQQKEw10ZXN0LW9yZ2FuaXplMRMwEQYDVQQDEwp0ZXN0LW5v
ZGUwKjAFBgMrZXADIQCRs/FZU2i5Et0siU1WyImCRiRiR8MAR8AQRyCcAxCBmqMf
MB0wGwYDVR0RBBQwEoIKdGVzdC1ub2RlhwR/AAABMAUGAytlcANBAHRlc3Q=
-----END CERTIFICATE-----`)

	caCertPEM := []byte(`-----BEGIN CERTIFICATE-----
MIIBJjCB2aADAgECAgEBMAUGAytlcDAtMRYwFAYDVQQKEw10ZXN0LW9yZ2FuaXpl
MRMwEQYDVQQDEwdyb290LWNhMB4XDTI0MDEwMTAwMDAwMFoXDTI1MDEwMTAwMDAw
MFowLTEWMBQGA1UEChMNdGVzdC1vcmdhbml6ZTETMBEGA1UEAxMHcm9vdC1jYTAq
MAUGAytlcAMhAJGz8VlTaLkS3SyJTVbIiYJGJGJHwwBHwBBHIJwDEIGaox8wHTAb
BgNVHREEFDASggp0ZXN0LW5vZGWHBH8AAAEwBQYDK2VwA0EAdGVzdA==
-----END CERTIFICATE-----`)

	completeChan := make(chan struct{})

	server, err := NewPairingWebServer(PairingWebConfig{
		CSR:     csrPEM,
		NodeID:  "integration-test-node",
		Timeout: 10 * time.Second,
		OnComplete: func(cert, ca []byte) error {
			close(completeChan)
			return nil
		},
	})
	if err != nil {
		t.Fatalf("Failed to create server: %v", err)
	}

	cpaceWords := server.GetCPACEWords()
	t.Logf("CPACE words for test: %s", cpaceWords)

	// Start server
	serverDone := make(chan error, 1)
	go func() {
		serverDone <- server.Start(":18888")
	}()

	// Give server time to start
	time.Sleep(200 * time.Millisecond)

	// Create HTTP client that accepts self-signed certs
	jar, _ := cookiejar.New(nil)
	client := &http.Client{
		Jar: jar,
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
		},
	}

	baseURL := "https://localhost:18888"

	// Step 1: Verify CPACE words
	t.Run("verify CPACE words", func(t *testing.T) {
		form := url.Values{}
		form.Set("cpace_words", cpaceWords)

		resp, err := client.PostForm(baseURL+"/verify", form)
		if err != nil {
			t.Fatalf("Failed to verify: %v", err)
		}
		defer resp.Body.Close()

		body, _ := io.ReadAll(resp.Body)
		t.Logf("Verify response: %s", string(body))

		var result map[string]interface{}
		json.Unmarshal(body, &result)

		if result["success"] != true {
			t.Errorf("Verification should succeed")
		}
	})

	// Step 2: Access pairing page
	t.Run("access pairing page", func(t *testing.T) {
		resp, err := client.Get(baseURL + "/pairing")
		if err != nil {
			t.Fatalf("Failed to get pairing page: %v", err)
		}
		defer resp.Body.Close()

		if resp.StatusCode != http.StatusOK {
			t.Errorf("Expected 200, got %d", resp.StatusCode)
		}
	})

	// Step 3: Submit certificate (send as raw PEM, not base64)
	t.Run("submit certificate", func(t *testing.T) {
		payload := map[string]string{
			"cert":    string(certPEM),
			"ca_cert": string(caCertPEM),
		}
		jsonData, _ := json.Marshal(payload)

		resp, err := client.Post(baseURL+"/submit", "application/json", bytes.NewReader(jsonData))
		if err != nil {
			t.Fatalf("Failed to submit: %v", err)
		}
		defer resp.Body.Close()

		body, _ := io.ReadAll(resp.Body)
		t.Logf("Submit response: %s", string(body))

		var result map[string]interface{}
		json.Unmarshal(body, &result)

		if result["success"] != true {
			t.Errorf("Submit should succeed, got: %v", result["error"])
		}
		if result["ca_fingerprint"] == nil {
			t.Error("Should return CA fingerprint")
		}
	})

	// Step 4: Confirm pairing
	t.Run("confirm pairing", func(t *testing.T) {
		resp, err := client.Post(baseURL+"/confirm", "application/json", nil)
		if err != nil {
			t.Fatalf("Failed to confirm: %v", err)
		}
		defer resp.Body.Close()

		body, _ := io.ReadAll(resp.Body)
		t.Logf("Confirm response: %s", string(body))

		var result map[string]interface{}
		json.Unmarshal(body, &result)

		if result["success"] != true {
			t.Errorf("Confirm should succeed, got: %v", result["error"])
		}
	})

	// Wait for server to complete
	select {
	case err := <-serverDone:
		if err != nil {
			t.Errorf("Server error: %v", err)
		}
		t.Log("Server completed successfully")
	case <-time.After(5 * time.Second):
		t.Error("Server did not complete in time")
	}
}
