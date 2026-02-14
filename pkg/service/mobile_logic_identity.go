package service

import (
	"context"
	"crypto/ed25519"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	pb "github.com/ivere27/nitella/pkg/api/local"
	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"github.com/ivere27/nitella/pkg/identity"
	"google.golang.org/protobuf/types/known/emptypb"
)

// ===========================================================================
// Identity Management
// ===========================================================================

// GetIdentity returns the current identity status.
func (s *MobileLogicService) GetIdentity(ctx context.Context, _ *emptypb.Empty) (*pb.IdentityInfo, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	return s.buildIdentityInfo(), nil
}

// CreateIdentity creates a new identity with a generated BIP-39 mnemonic.
func (s *MobileLogicService) CreateIdentity(ctx context.Context, req *pb.CreateIdentityRequest) (*pb.CreateIdentityResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Check if identity already exists
	if identity.KeyExists(s.dataDir) {
		return &pb.CreateIdentityResponse{
			Success: false,
			Error:   "identity already exists",
		}, nil
	}

	commonName := req.CommonName
	if commonName == "" {
		commonName = "Nitella"
	}
	if err := validatePassphrasePolicy(req.GetPassphrase(), req.GetAllowWeakPassphrase()); err != nil {
		return &pb.CreateIdentityResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	// Create identity config
	cfg := identity.DefaultConfig(s.dataDir, commonName)
	cfg.Passphrase = req.Passphrase
	cfg.ForceCreate = true

	// Create new identity
	id, created, err := identity.LoadOrCreate(cfg)
	if err != nil {
		return &pb.CreateIdentityResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to create identity: %v", err),
		}, nil
	}

	if !created {
		return &pb.CreateIdentityResponse{
			Success: false,
			Error:   "identity already exists",
		}, nil
	}

	s.identity = id
	s.identityLock = false
	if s.ctrl != nil {
		s.ctrl.SetIdentity(id)
	}

	// Capture mnemonic for one-time display, then wipe from memory
	mnemonic := id.Mnemonic
	id.Mnemonic = ""

	return &pb.CreateIdentityResponse{
		Success:  true,
		Mnemonic: mnemonic, // Show only once, already wiped from identity
		Identity: s.buildIdentityInfo(),
	}, nil
}

// RestoreIdentity restores an identity from an existing BIP-39 mnemonic.
func (s *MobileLogicService) RestoreIdentity(ctx context.Context, req *pb.RestoreIdentityRequest) (*pb.RestoreIdentityResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Check if identity already exists
	if identity.KeyExists(s.dataDir) {
		return &pb.RestoreIdentityResponse{
			Success: false,
			Error:   "identity already exists, delete first to restore",
		}, nil
	}

	// Validate mnemonic
	if !identity.ValidateMnemonic(req.Mnemonic) {
		return &pb.RestoreIdentityResponse{
			Success: false,
			Error:   "invalid mnemonic phrase",
		}, nil
	}

	commonName := req.CommonName
	if commonName == "" {
		commonName = "Nitella"
	}
	if err := validatePassphrasePolicy(req.GetPassphrase(), req.GetAllowWeakPassphrase()); err != nil {
		return &pb.RestoreIdentityResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}

	// Create identity config
	cfg := identity.DefaultConfig(s.dataDir, commonName)
	cfg.Passphrase = req.Passphrase
	cfg.ForceCreate = true

	// Restore from mnemonic
	id, err := identity.CreateFromMnemonic(req.Mnemonic, cfg)
	if err != nil {
		return &pb.RestoreIdentityResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to restore identity: %v", err),
		}, nil
	}

	// Save the identity
	if err := s.saveIdentity(id, req.Passphrase); err != nil {
		return &pb.RestoreIdentityResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to save identity: %v", err),
		}, nil
	}

	s.identity = id
	s.identityLock = false
	if s.ctrl != nil {
		s.ctrl.SetIdentity(id)
	}

	return &pb.RestoreIdentityResponse{
		Success:  true,
		Identity: s.buildIdentityInfo(),
	}, nil
}

// ImportIdentity imports an identity from certificate and key PEM content.
func (s *MobileLogicService) ImportIdentity(ctx context.Context, req *pb.ImportIdentityRequest) (*pb.ImportIdentityResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Check if identity already exists
	if identity.KeyExists(s.dataDir) {
		return &pb.ImportIdentityResponse{
			Success: false,
			Error:   "identity already exists, delete first to import",
		}, nil
	}

	// Validate inputs
	if req.CertPem == "" {
		return &pb.ImportIdentityResponse{
			Success: false,
			Error:   "certificate PEM is required",
		}, nil
	}
	if req.KeyPem == "" {
		return &pb.ImportIdentityResponse{
			Success: false,
			Error:   "private key PEM is required",
		}, nil
	}

	// Import identity from PEM
	id, err := identity.ImportFromPEM([]byte(req.CertPem), []byte(req.KeyPem), req.KeyPassphrase)
	if err != nil {
		return &pb.ImportIdentityResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to import identity: %v", err),
		}, nil
	}

	// Save the identity (unencrypted, user can change passphrase later)
	if err := s.saveIdentity(id, ""); err != nil {
		return &pb.ImportIdentityResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to save identity: %v", err),
		}, nil
	}

	s.identity = id
	s.identityLock = false
	if s.ctrl != nil {
		s.ctrl.SetIdentity(id)
	}

	return &pb.ImportIdentityResponse{
		Success:  true,
		Identity: s.buildIdentityInfo(),
	}, nil
}

// UnlockIdentity unlocks an encrypted identity with a passphrase.
func (s *MobileLogicService) UnlockIdentity(ctx context.Context, req *pb.UnlockIdentityRequest) (*pb.UnlockIdentityResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.identity != nil && !s.identityLock {
		return &pb.UnlockIdentityResponse{
			Success:  true,
			Identity: s.buildIdentityInfo(),
		}, nil
	}

	// Try to load with passphrase
	id, err := identity.LoadWithPassphrase(s.dataDir, req.Passphrase)
	if err != nil {
		return &pb.UnlockIdentityResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to unlock: %v", err),
		}, nil
	}

	s.identity = id
	s.identityLock = false
	if s.ctrl != nil {
		s.ctrl.SetIdentity(id)
	}

	// Initialize P2P Transport with new identity
	if s.mobileClient != nil {
		s.initP2PTransportLocked()
	}

	// Reload nodes now that we have the identity
	if err := s.loadNodes(); err != nil && s.debugMode {
		log.Printf("warning: failed to reload nodes after unlock: %v\n", err)
	}

	// Reload direct nodes now that encrypted direct tokens can be decrypted.
	// Clear existing direct clients first to avoid stale in-memory tokens.
	if s.directNodes != nil {
		s.directNodes.closeAll()
	}
	if err := s.loadDirectNodes(ctx); err != nil && s.debugMode {
		log.Printf("warning: failed to reload direct nodes after unlock: %v\n", err)
	}

	return &pb.UnlockIdentityResponse{
		Success:  true,
		Identity: s.buildIdentityInfo(),
	}, nil
}

// LockIdentity clears the identity from memory.
func (s *MobileLogicService) LockIdentity(ctx context.Context, _ *emptypb.Empty) (*emptypb.Empty, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Check if key is encrypted (can only lock if encrypted)
	encrypted, err := identity.IsKeyEncrypted(s.dataDir)
	if err == nil && !encrypted {
		// Key is not encrypted, don't lock
		return &emptypb.Empty{}, nil
	}

	// Clear identity from memory
	s.identity = nil
	s.identityLock = true
	if s.ctrl != nil {
		s.ctrl.SetIdentity(nil)
	}

	// Shut down P2P transport
	if s.p2pTransport != nil {
		if err := s.p2pTransport.Close(); err != nil && s.debugMode {
			log.Printf("warning: p2p transport close error: %v", err)
		}
		s.p2pTransport = nil
		s.ctrl.SetP2PTransport(nil)
	}

	// Disconnect from Hub
	if s.hubConn != nil {
		s.hubConn.Close()
		s.hubConn = nil
		s.mobileClient = nil
		s.authClient = nil
		s.pairingClient = nil
		s.hubConnected = false
	}

	return &emptypb.Empty{}, nil
}

// ChangePassphrase changes the passphrase for the identity key.
func (s *MobileLogicService) ChangePassphrase(ctx context.Context, req *pb.ChangePassphraseRequest) (*emptypb.Empty, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if err := s.requireIdentity(); err != nil {
		return nil, err
	}

	// Verify old passphrase by trying to load
	_, err := identity.LoadWithPassphrase(s.dataDir, req.OldPassphrase)
	if err != nil {
		return nil, fmt.Errorf("incorrect old passphrase")
	}
	if err := validatePassphrasePolicy(req.GetNewPassphrase(), req.GetAllowWeakPassphrase()); err != nil {
		return nil, err
	}

	// Re-encrypt with new passphrase
	if err := s.saveIdentity(s.identity, req.NewPassphrase); err != nil {
		return nil, fmt.Errorf("failed to save with new passphrase: %v", err)
	}

	return &emptypb.Empty{}, nil
}

// EvaluatePassphrase returns backend-owned passphrase strength analysis.
func (s *MobileLogicService) EvaluatePassphrase(ctx context.Context, req *pb.EvaluatePassphraseRequest) (*pb.EvaluatePassphraseResponse, error) {
	check := nitellacrypto.CheckPassphrase(req.GetPassphrase())
	if check == nil {
		return &pb.EvaluatePassphraseResponse{
			Strength:   pb.PassphraseStrength_PASSPHRASE_STRENGTH_UNSPECIFIED,
			ShouldWarn: true,
			Message:    "passphrase check failed",
		}, nil
	}

	_ = ctx
	return &pb.EvaluatePassphraseResponse{
		Strength:    toPBPassphraseStrength(check.Strength),
		Entropy:     check.Entropy,
		Message:     check.Message,
		CrackTime:   check.CrackTime,
		GpuScenario: check.GPUScenario,
		ShouldWarn:  check.Strength == nitellacrypto.StrengthWeak,
		Report:      check.FormatStrengthReport(),
	}, nil
}

// ResetIdentity deletes the identity and all associated data from disk and memory.
func (s *MobileLogicService) ResetIdentity(ctx context.Context, _ *emptypb.Empty) (*emptypb.Empty, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// 1. Cancel alert streams
	if s.alertStreamCancel != nil {
		s.alertStreamCancel()
		s.alertStreamCancel = nil
	}

	// 2. Close P2P transport
	if s.p2pTransport != nil {
		s.p2pTransport.Close()
		s.p2pTransport = nil
		s.ctrl.SetP2PTransport(nil)
	}

	// 3. Disconnect from Hub
	if s.hubConn != nil {
		s.hubConn.Close()
		s.hubConn = nil
		s.mobileClient = nil
		s.authClient = nil
		s.pairingClient = nil
		s.hubConnected = false
		s.hubTokenProv = nil
		s.savedHubJWT = ""
	}

	// 4. Close direct node connections
	if s.directNodes != nil {
		s.directNodes.closeAll()
		s.directNodes = nil
	}

	// 5. Delete identity files from disk
	for _, name := range []string{"root_ca.crt", "root_ca.key"} {
		p := filepath.Join(s.dataDir, name)
		os.Remove(p)
	}

	// 6. Delete nodes directory
	os.RemoveAll(filepath.Join(s.dataDir, "nodes"))

	// 7. Delete templates directory
	os.RemoveAll(filepath.Join(s.dataDir, "templates"))

	// 8. Delete settings
	os.Remove(filepath.Join(s.dataDir, "settings.json"))
	os.Remove(filepath.Join(s.dataDir, "hub_session.json"))
	os.Remove(filepath.Join(s.dataDir, "approvals", "history.json"))
	os.RemoveAll(filepath.Join(s.dataDir, "approvals"))

	// 9. Clear in-memory state
	s.identity = nil
	s.identityLock = false
	if s.ctrl != nil {
		s.ctrl.SetIdentity(nil)
	}
	s.nodes = make(map[string]*pb.NodeInfo)
	s.nodePublicKeys = make(map[string]ed25519.PublicKey)
	s.pairingSessions = make(map[string]*pairingSession)
	s.templates = make(map[string]*pb.Template)
	s.settings = defaultSettings()
	s.pendingApprovalsMu.Lock()
	s.pendingApprovals = make(map[string]*pb.ApprovalRequest)
	s.pendingApprovalsMu.Unlock()
	s.approvalHistoryMu.Lock()
	s.approvalHistory = make([]*pb.ApprovalHistoryEntry, 0)
	s.approvalHistoryMu.Unlock()
	s.hubAddr = ""
	s.hubCAPEM = nil
	s.hubCertPin = ""
	s.fcmToken = ""

	log.Println("Identity and all associated data have been reset")
	return &emptypb.Empty{}, nil
}

// saveIdentity saves the identity to disk with optional encryption.
func (s *MobileLogicService) saveIdentity(id *identity.Identity, passphrase string) error {
	// Save certificate (unencrypted)
	certPath := filepath.Join(s.dataDir, "root_ca.crt")
	if err := writeFile(certPath, id.RootCertPEM, 0644); err != nil {
		return fmt.Errorf("failed to save certificate: %w", err)
	}

	// Save key (encrypted if passphrase provided)
	keyPath := filepath.Join(s.dataDir, "root_ca.key")
	keyPEM, err := nitellacrypto.EncryptPrivateKeyToPEM(id.RootKey, passphrase)
	if err != nil {
		return fmt.Errorf("failed to encrypt key: %w", err)
	}
	if err := writeFile(keyPath, keyPEM, 0600); err != nil {
		return fmt.Errorf("failed to save key: %w", err)
	}

	return nil
}

// writeFile is a helper to write data to a file with given permissions.
func writeFile(path string, data []byte, perm os.FileMode) error {
	return os.WriteFile(path, data, perm)
}

func toPBPassphraseStrength(strength nitellacrypto.PassphraseStrength) pb.PassphraseStrength {
	switch strength {
	case nitellacrypto.StrengthWeak:
		return pb.PassphraseStrength_PASSPHRASE_STRENGTH_WEAK
	case nitellacrypto.StrengthFair:
		return pb.PassphraseStrength_PASSPHRASE_STRENGTH_FAIR
	case nitellacrypto.StrengthStrong:
		return pb.PassphraseStrength_PASSPHRASE_STRENGTH_STRONG
	default:
		return pb.PassphraseStrength_PASSPHRASE_STRENGTH_UNSPECIFIED
	}
}

func validatePassphrasePolicy(passphrase string, allowWeak bool) error {
	trimmed := strings.TrimSpace(passphrase)
	if trimmed == "" {
		return nil
	}

	check := nitellacrypto.CheckPassphrase(passphrase)
	if check == nil {
		return fmt.Errorf("failed to evaluate passphrase policy")
	}
	if check.Strength == nitellacrypto.StrengthWeak && !allowWeak {
		return fmt.Errorf("weak passphrase requires explicit confirmation")
	}
	return nil
}
