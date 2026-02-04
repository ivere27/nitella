package pairing

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"html/template"
	"math/big"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"
)

// PairingWebServer serves the pairing web UI
type PairingWebServer struct {
	csrPEM      []byte
	nodeID      string
	cpaceWords  string
	fingerprint string
	timeout     time.Duration
	onComplete  func(certPEM, caCertPEM []byte) error

	server     *http.Server
	tempCert   tls.Certificate
	mu         sync.Mutex
	completed  bool
	resultChan chan error

	// Pending certificates waiting for user confirmation
	pendingCert []byte
	pendingCA   []byte

	// Server-side session storage for proper validation
	validSessions   map[string]time.Time // token -> expiry time
	sessionsMu      sync.RWMutex
}

// PairingWebConfig configures the pairing web server
type PairingWebConfig struct {
	CSR        []byte
	NodeID     string
	Timeout    time.Duration
	Certificate *tls.Certificate // Optional: Use this cert instead of generating temp one
	OnComplete func(certPEM, caCertPEM []byte) error
}

// NewPairingWebServer creates a new pairing web server
func NewPairingWebServer(cfg PairingWebConfig) (*PairingWebServer, error) {
	if cfg.Timeout == 0 {
		cfg.Timeout = 3 * time.Minute
	}

	// Generate CPACE words
	cpaceWords, err := GeneratePairingCode()
	if err != nil {
		return nil, fmt.Errorf("failed to generate CPACE words: %w", err)
	}

	// Use provided certificate or generate temporary self-signed TLS certificate
	var tempCert tls.Certificate
	if cfg.Certificate != nil {
		tempCert = *cfg.Certificate
	} else {
		var err error
		tempCert, err = generateTempTLSCert()
		if err != nil {
			return nil, fmt.Errorf("failed to generate temp TLS cert: %w", err)
		}
	}

	fingerprint := DeriveFingerprint(cfg.CSR)

	return &PairingWebServer{
		csrPEM:        cfg.CSR,
		nodeID:        cfg.NodeID,
		cpaceWords:    cpaceWords,
		fingerprint:   fingerprint,
		timeout:       cfg.Timeout,
		onComplete:    cfg.OnComplete,
		tempCert:      tempCert,
		resultChan:    make(chan error, 1),
		validSessions: make(map[string]time.Time), // Initialize session storage
	}, nil
}

// GetCPACEWords returns the CPACE words for authentication
func (s *PairingWebServer) GetCPACEWords() string {
	return s.cpaceWords
}

// GetFingerprint returns the CSR fingerprint
func (s *PairingWebServer) GetFingerprint() string {
	return s.fingerprint
}

// GetCSRPEM returns the CSR in PEM format
func (s *PairingWebServer) GetCSRPEM() []byte {
	return s.csrPEM
}

// GetCertificate returns the server's TLS certificate (Leaf)
func (s *PairingWebServer) GetCertificate() *x509.Certificate {
	if len(s.tempCert.Certificate) == 0 {
		return nil
	}
	cert, _ := x509.ParseCertificate(s.tempCert.Certificate[0])
	return cert
}

// Start starts the pairing web server and blocks until complete or timeout
func (s *PairingWebServer) Start(addr string) error {
	mux := http.NewServeMux()
	mux.HandleFunc("/", s.handleIndex)
	mux.HandleFunc("/verify", s.handleVerify)
	mux.HandleFunc("/pairing", s.handlePairing)
	mux.HandleFunc("/submit", s.handleSubmit)
	mux.HandleFunc("/confirm", s.handleConfirm)
	mux.HandleFunc("/qr.png", s.handleQRImage)

	tlsConfig := &tls.Config{
		Certificates: []tls.Certificate{s.tempCert},
		MinVersion:   tls.VersionTLS13,
	}

	s.server = &http.Server{
		Addr:      addr,
		Handler:   mux,
		TLSConfig: tlsConfig,
	}

	// Start timeout timer
	go func() {
		time.Sleep(s.timeout)
		s.mu.Lock()
		if !s.completed {
			s.resultChan <- fmt.Errorf("pairing timeout after %v", s.timeout)
		}
		s.mu.Unlock()
	}()

	// Start server in goroutine
	listener, err := net.Listen("tcp", addr)
	if err != nil {
		return fmt.Errorf("failed to listen: %w", err)
	}

	tlsListener := tls.NewListener(listener, tlsConfig)

	go func() {
		if err := s.server.Serve(tlsListener); err != http.ErrServerClosed {
			s.resultChan <- fmt.Errorf("server error: %w", err)
		}
	}()

	// Wait for completion or error
	err = <-s.resultChan

	// Shutdown server
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	s.server.Shutdown(ctx)

	return err
}

// handleIndex shows the CPACE words entry page
func (s *PairingWebServer) handleIndex(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	tmpl := template.Must(template.New("index").Parse(indexHTML))
	tmpl.Execute(w, nil)
}

// handleVerify verifies CPACE words
func (s *PairingWebServer) handleVerify(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	r.ParseForm()
	words := strings.TrimSpace(r.FormValue("cpace_words"))

	if !strings.EqualFold(words, s.cpaceWords) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": false,
			"error":   "Invalid CPACE words",
		})
		return
	}

	// Generate session token
	tokenBytes := make([]byte, 32)
	if _, err := rand.Read(tokenBytes); err != nil {
		http.Error(w, "Security error: CSPRNG unavailable", http.StatusInternalServerError)
		return
	}
	token := hex.EncodeToString(tokenBytes)

	// Store token server-side with expiry
	s.sessionsMu.Lock()
	s.validSessions[token] = time.Now().Add(10 * time.Minute) // 10 min expiry
	s.sessionsMu.Unlock()

	http.SetCookie(w, &http.Cookie{
		Name:     "pairing_session",
		Value:    token,
		Path:     "/",
		HttpOnly: true,
		Secure:   true,
		SameSite: http.SameSiteStrictMode,
	})

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":  true,
		"redirect": "/pairing",
	})
}

// validateSession checks if a session token is valid server-side
func (s *PairingWebServer) validateSession(r *http.Request) bool {
	cookie, err := r.Cookie("pairing_session")
	if err != nil || cookie.Value == "" {
		return false
	}

	s.sessionsMu.RLock()
	expiry, exists := s.validSessions[cookie.Value]
	s.sessionsMu.RUnlock()

	if !exists {
		return false
	}

	if time.Now().After(expiry) {
		// Expired, clean up
		s.sessionsMu.Lock()
		delete(s.validSessions, cookie.Value)
		s.sessionsMu.Unlock()
		return false
	}

	return true
}

// handlePairing shows the pairing page with QR code
func (s *PairingWebServer) handlePairing(w http.ResponseWriter, r *http.Request) {
	// Validate session server-side
	if !s.validateSession(r) {
		http.Redirect(w, r, "/", http.StatusFound)
		return
	}

	// Create QR payload
	qrPayload := &QRPayload{
		Type:        "csr",
		CSR:         base64.StdEncoding.EncodeToString(s.csrPEM),
		Fingerprint: s.fingerprint,
		NodeID:      s.nodeID,
	}
	qrJSON, _ := json.Marshal(qrPayload)

	data := map[string]interface{}{
		"NodeID":      s.nodeID,
		"Fingerprint": s.fingerprint,
		"QRData":      string(qrJSON),
		"CSRPEM":      string(s.csrPEM),
	}

	tmpl := template.Must(template.New("pairing").Parse(pairingHTML))
	tmpl.Execute(w, data)
}

// handleSubmit handles certificate submission
func (s *PairingWebServer) handleSubmit(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Validate session server-side
	if !s.validateSession(r) {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var req struct {
		Cert   string `json:"cert"`
		CACert string `json:"ca_cert"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": false,
			"error":   "Invalid JSON",
		})
		return
	}

	// Decode certificates
	certPEM, err := base64.StdEncoding.DecodeString(req.Cert)
	if err != nil {
		// Try as raw PEM
		certPEM = []byte(req.Cert)
	}

	caCertPEM, err := base64.StdEncoding.DecodeString(req.CACert)
	if err != nil {
		// Try as raw PEM
		caCertPEM = []byte(req.CACert)
	}

	// Validate certificate
	block, _ := pem.Decode(certPEM)
	if block == nil {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": false,
			"error":   "Invalid certificate PEM",
		})
		return
	}

	// Validate CA certificate
	caBlock, _ := pem.Decode(caCertPEM)
	if caBlock == nil {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": false,
			"error":   "Invalid CA certificate PEM",
		})
		return
	}

	// Calculate CA fingerprint for verification
	caFingerprint := DeriveFingerprint(caCertPEM)
	caHash := sha256.Sum256(caCertPEM)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":       true,
		"ca_fingerprint": caFingerprint,
		"ca_hash":       hex.EncodeToString(caHash[:16]),
		"confirm_url":  "/confirm",
	})

	// Store pending certs for confirmation
	s.mu.Lock()
	s.pendingCert = certPEM
	s.pendingCA = caCertPEM
	s.mu.Unlock()
}


// handleConfirm handles the final confirmation of certificate pairing
func (s *PairingWebServer) handleConfirm(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Validate session server-side (prevents auth bypass)
	if !s.validateSession(r) {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	if s.completed {
		http.Error(w, "Already completed", http.StatusBadRequest)
		return
	}

	if s.pendingCert == nil || s.pendingCA == nil {
		http.Error(w, "No pending certificate", http.StatusBadRequest)
		return
	}

	// Call completion handler
	if err := s.onComplete(s.pendingCert, s.pendingCA); err != nil {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		})
		return
	}

	s.completed = true

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": "Pairing complete!",
	})

	// Signal completion
	s.resultChan <- nil
}

// handleQRImage generates QR code as PNG image
func (s *PairingWebServer) handleQRImage(w http.ResponseWriter, r *http.Request) {
	// Validate session server-side
	if !s.validateSession(r) {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	qrPayload := &QRPayload{
		Type:        "csr",
		CSR:         base64.StdEncoding.EncodeToString(s.csrPEM),
		Fingerprint: s.fingerprint,
		NodeID:      s.nodeID,
	}
	qrJSON, _ := json.Marshal(qrPayload)

	// Generate QR code PNG
	png, err := GenerateQRPNG(string(qrJSON))
	if err != nil {
		http.Error(w, "Failed to generate QR", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "image/png")
	w.Write(png)
}


// Add these fields to the struct (they were referenced but not declared)
// We need to update the struct definition above

// generateTempTLSCert generates a temporary self-signed TLS certificate
func generateTempTLSCert() (tls.Certificate, error) {
	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		return tls.Certificate{}, err
	}

	serialNumber, err := rand.Int(rand.Reader, new(big.Int).Lsh(big.NewInt(1), 128))
	if err != nil {
		return tls.Certificate{}, fmt.Errorf("CSPRNG unavailable: %w", err)
	}

	template := &x509.Certificate{
		SerialNumber: serialNumber,
		Subject: pkix.Name{
			CommonName:   "nitellad-pairing",
			Organization: []string{"Nitella Pairing"},
		},
		NotBefore:             time.Now(),
		NotAfter:              time.Now().Add(1 * time.Hour), // Short-lived
		KeyUsage:              x509.KeyUsageDigitalSignature | x509.KeyUsageKeyEncipherment,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		BasicConstraintsValid: true,
		IPAddresses:           []net.IP{net.ParseIP("127.0.0.1"), net.ParseIP("::1")},
		DNSNames:              []string{"localhost"},
	}

	certDER, err := x509.CreateCertificate(rand.Reader, template, template, pub, priv)
	if err != nil {
		return tls.Certificate{}, err
	}

	certPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: certDER})
	keyBytes, _ := x509.MarshalPKCS8PrivateKey(priv)
	keyPEM := pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: keyBytes})

	return tls.X509KeyPair(certPEM, keyPEM)
}

// GenerateQRPNG generates a QR code as PNG bytes
func GenerateQRPNG(data string) ([]byte, error) {
	// Use a simple QR library - for now return placeholder
	// In production, use github.com/skip2/go-qrcode
	return nil, fmt.Errorf("QR PNG generation not implemented - use terminal QR")
}

// HTML Templates (embedded)
const indexHTML = `<!DOCTYPE html>
<html>
<head>
    <title>Nitella Node Pairing</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: #1a1a2e;
            color: #eee;
            margin: 0;
            padding: 20px;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .container {
            background: #16213e;
            border-radius: 12px;
            padding: 40px;
            max-width: 400px;
            width: 100%;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }
        h1 {
            margin: 0 0 10px 0;
            font-size: 24px;
            text-align: center;
        }
        .subtitle {
            color: #888;
            text-align: center;
            margin-bottom: 30px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #aaa;
        }
        input[type="text"] {
            width: 100%;
            padding: 12px;
            border: 2px solid #333;
            border-radius: 8px;
            background: #0f0f23;
            color: #fff;
            font-size: 18px;
            text-align: center;
            letter-spacing: 2px;
        }
        input:focus {
            outline: none;
            border-color: #4a9eff;
        }
        button {
            width: 100%;
            padding: 14px;
            margin-top: 20px;
            border: none;
            border-radius: 8px;
            background: #4a9eff;
            color: #fff;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
        }
        button:hover { background: #3a8eef; }
        button:disabled { background: #555; cursor: not-allowed; }
        .error {
            color: #ff6b6b;
            text-align: center;
            margin-top: 15px;
            display: none;
        }
        .warning {
            background: #2d2d44;
            border-left: 4px solid #ffa500;
            padding: 12px;
            margin-bottom: 20px;
            font-size: 14px;
            border-radius: 0 8px 8px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Node Pairing</h1>
        <p class="subtitle">Enter CPACE words from terminal</p>

        <div class="warning">
            Check <code>docker logs</code> for the CPACE words
        </div>

        <form id="verifyForm">
            <label for="cpace">CPACE Words</label>
            <input type="text" id="cpace" name="cpace_words"
                   placeholder="e.g., 7-tiger-castle" autocomplete="off" required>
            <button type="submit">Verify</button>
        </form>

        <p class="error" id="error"></p>
    </div>

    <script>
        document.getElementById('verifyForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            const btn = e.target.querySelector('button');
            const error = document.getElementById('error');
            btn.disabled = true;
            error.style.display = 'none';

            try {
                const resp = await fetch('/verify', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: new URLSearchParams(new FormData(e.target))
                });
                const data = await resp.json();

                if (data.success) {
                    window.location.href = data.redirect;
                } else {
                    error.textContent = data.error;
                    error.style.display = 'block';
                }
            } catch (err) {
                error.textContent = 'Connection error';
                error.style.display = 'block';
            }
            btn.disabled = false;
        });
    </script>
</body>
</html>`

const pairingHTML = `<!DOCTYPE html>
<html>
<head>
    <title>Nitella Node Pairing</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: #1a1a2e;
            color: #eee;
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            background: #16213e;
            border-radius: 12px;
            padding: 30px;
            max-width: 600px;
            margin: 0 auto;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }
        h1 { margin: 0 0 20px 0; text-align: center; }
        .fingerprint {
            background: #0f0f23;
            padding: 15px;
            border-radius: 8px;
            text-align: center;
            font-size: 32px;
            margin-bottom: 20px;
        }
        .qr-container {
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            margin-bottom: 20px;
        }
        .qr-container pre {
            font-size: 6px;
            line-height: 6px;
            color: #000;
            margin: 0;
        }
        .section-title {
            color: #888;
            font-size: 14px;
            margin-bottom: 10px;
        }
        textarea {
            width: 100%;
            height: 150px;
            padding: 12px;
            border: 2px solid #333;
            border-radius: 8px;
            background: #0f0f23;
            color: #fff;
            font-family: monospace;
            font-size: 12px;
            resize: vertical;
        }
        textarea:focus {
            outline: none;
            border-color: #4a9eff;
        }
        button {
            width: 100%;
            padding: 14px;
            margin-top: 15px;
            border: none;
            border-radius: 8px;
            background: #4a9eff;
            color: #fff;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
        }
        button:hover { background: #3a8eef; }
        button:disabled { background: #555; cursor: not-allowed; }
        .info { color: #888; font-size: 13px; margin-top: 10px; }
        .error { color: #ff6b6b; margin-top: 15px; display: none; }
        .success { color: #4ade80; margin-top: 15px; display: none; }

        /* Verification modal */
        .modal {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.8);
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }
        .modal.active { display: flex; }
        .modal-content {
            background: #16213e;
            padding: 30px;
            border-radius: 12px;
            max-width: 400px;
            text-align: center;
        }
        .modal h2 { margin: 0 0 20px 0; color: #ffa500; }
        .modal .fingerprint { font-size: 40px; }
        .modal .hash { font-family: monospace; color: #888; font-size: 12px; word-break: break-all; }
        .modal-buttons { display: flex; gap: 10px; margin-top: 20px; }
        .modal-buttons button { flex: 1; }
        .btn-cancel { background: #555; }
        .btn-cancel:hover { background: #666; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Node Pairing</h1>

        <p class="section-title">Node: {{.NodeID}}</p>

        <div class="fingerprint">
            CSR: {{.Fingerprint}}
        </div>

        <div class="qr-container">
            <p style="color:#333; margin:0 0 10px 0;">Scan with nitella CLI</p>
            <div id="qrcode"></div>
        </div>

        <p class="section-title">Or paste signed certificate + CA:</p>
        <textarea id="certInput" placeholder='{"cert": "-----BEGIN CERTIFICATE-----...", "ca_cert": "-----BEGIN CERTIFICATE-----..."}'></textarea>

        <p class="info">
            Use <code>nitella hub sign-csr</code> to sign the CSR, then paste the result above.
        </p>

        <button id="submitBtn" onclick="submitCert()">Submit Certificate</button>

        <p class="error" id="error"></p>
        <p class="success" id="success"></p>
    </div>

    <!-- Verification Modal -->
    <div class="modal" id="verifyModal">
        <div class="modal-content">
            <h2>Verify CA Fingerprint</h2>
            <p>Confirm this matches your CLI's CA:</p>
            <div class="fingerprint" id="caFingerprint"></div>
            <p class="hash" id="caHash"></p>
            <p style="color:#ffa500; margin-top:15px;">
                If this does NOT match, click Cancel!
            </p>
            <div class="modal-buttons">
                <button class="btn-cancel" onclick="cancelPairing()">Cancel</button>
                <button onclick="confirmPairing()">Confirm</button>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.3/build/qrcode.min.js"></script>
    <script>
        // Generate QR code
        const qrData = {{.QRData}};
        QRCode.toCanvas(document.createElement('canvas'), qrData, {
            width: 200,
            margin: 2,
            color: { dark: '#000', light: '#fff' }
        }, function(error, canvas) {
            if (!error) {
                document.getElementById('qrcode').appendChild(canvas);
            }
        });

        let pendingConfirm = false;

        async function submitCert() {
            const btn = document.getElementById('submitBtn');
            const error = document.getElementById('error');
            const success = document.getElementById('success');
            const input = document.getElementById('certInput').value.trim();

            error.style.display = 'none';
            success.style.display = 'none';
            btn.disabled = true;

            try {
                let payload;
                try {
                    payload = JSON.parse(input);
                } catch {
                    // Try to parse as PEM directly
                    if (input.includes('-----BEGIN CERTIFICATE-----')) {
                        error.textContent = 'Please provide JSON with both cert and ca_cert';
                        error.style.display = 'block';
                        btn.disabled = false;
                        return;
                    }
                    throw new Error('Invalid JSON format');
                }

                const resp = await fetch('/submit', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify(payload)
                });
                const data = await resp.json();

                if (data.success) {
                    // Show verification modal
                    document.getElementById('caFingerprint').textContent = data.ca_fingerprint;
                    document.getElementById('caHash').textContent = 'Hash: ' + data.ca_hash;
                    document.getElementById('verifyModal').classList.add('active');
                    pendingConfirm = true;
                } else {
                    error.textContent = data.error;
                    error.style.display = 'block';
                }
            } catch (err) {
                error.textContent = err.message || 'Connection error';
                error.style.display = 'block';
            }
            btn.disabled = false;
        }

        function cancelPairing() {
            document.getElementById('verifyModal').classList.remove('active');
            pendingConfirm = false;
        }

        async function confirmPairing() {
            const modal = document.getElementById('verifyModal');
            const success = document.getElementById('success');
            const error = document.getElementById('error');

            try {
                const resp = await fetch('/confirm', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'}
                });
                const data = await resp.json();

                modal.classList.remove('active');

                if (data.success) {
                    success.textContent = 'Pairing complete! Node is now connected.';
                    success.style.display = 'block';
                    document.getElementById('submitBtn').disabled = true;
                    document.getElementById('certInput').disabled = true;
                } else {
                    error.textContent = data.error;
                    error.style.display = 'block';
                }
            } catch (err) {
                modal.classList.remove('active');
                error.textContent = 'Connection error';
                error.style.display = 'block';
            }
        }
    </script>
</body>
</html>`
