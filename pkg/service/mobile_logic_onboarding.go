package service

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"strings"
	"time"

	pb "github.com/ivere27/nitella/pkg/api/local"
	"github.com/ivere27/nitella/pkg/core"
)

const hubTrustChallengeTTL = 5 * time.Minute

type hubTrustChallengeSession struct {
	hubAddress         string
	challenge          *pb.HubTrustChallenge
	expiresAt          int64
	inviteCode         string
	token              string
	skipRegistration   bool
	biometricPublicKey []byte
}

// OnboardHub performs Hub onboarding as a single business flow:
// connect -> (optional TOFU challenge/confirm) -> register user.
func (s *MobileLogicService) OnboardHub(ctx context.Context, req *pb.OnboardHubRequest) (*pb.OnboardHubResponse, error) {
	hubAddr := strings.TrimSpace(req.GetHubAddress())
	if hubAddr == "" {
		s.mu.RLock()
		if s.settings != nil && s.settings.HubAddress != "" {
			hubAddr = s.settings.HubAddress
		} else {
			hubAddr = s.hubAddr
		}
		s.mu.RUnlock()
	}
	if hubAddr == "" {
		return &pb.OnboardHubResponse{
			Stage:   pb.OnboardHubResponse_STAGE_FAILED,
			Success: false,
			Error:   "hub address not specified",
		}, nil
	}

	if req.GetPersistSettings() {
		inviteCode := strings.TrimSpace(req.GetInviteCode())
		s.mu.Lock()
		s.hubAddr = hubAddr
		if s.settings != nil {
			s.settings.HubAddress = hubAddr
			s.settings.HubInviteCode = inviteCode
		}
		if err := s.saveSettings(); err != nil {
			s.mu.Unlock()
			return &pb.OnboardHubResponse{
				Stage:      pb.OnboardHubResponse_STAGE_FAILED,
				Success:    false,
				HubAddress: hubAddr,
				Error:      "failed to persist onboarding settings: " + err.Error(),
			}, nil
		}
		s.mu.Unlock()
	}

	var connectWith []byte
	if req.GetTrustPromptAccepted() {
		challenge, challengeErr := s.takeHubTrustChallenge(hubAddr, req.GetTrustChallengeId())
		if challengeErr != nil {
			return &pb.OnboardHubResponse{
				Stage:      pb.OnboardHubResponse_STAGE_FAILED,
				Success:    false,
				HubAddress: hubAddr,
				Error:      challengeErr.Error(),
			}, nil
		}
		connectWith = append([]byte(nil), challenge.GetCaPem()...)

		probe, err := core.ProbeHubCA(hubAddr)
		if err != nil {
			return &pb.OnboardHubResponse{
				Stage:      pb.OnboardHubResponse_STAGE_FAILED,
				Success:    false,
				HubAddress: hubAddr,
				Error:      "failed to verify current hub certificate: " + err.Error(),
			}, nil
		}

		if fp := normalizeFingerprint(challenge.GetFingerprint()); fp != "" && fp != normalizeFingerprint(probe.Fingerprint) {
			return &pb.OnboardHubResponse{
				Stage:      pb.OnboardHubResponse_STAGE_FAILED,
				Success:    false,
				HubAddress: hubAddr,
				Error:      "hub certificate fingerprint mismatch",
			}, nil
		}
		if eh := strings.TrimSpace(challenge.GetEmojiHash()); eh != "" && eh != strings.TrimSpace(probe.EmojiHash) {
			return &pb.OnboardHubResponse{
				Stage:      pb.OnboardHubResponse_STAGE_FAILED,
				Success:    false,
				HubAddress: hubAddr,
				Error:      "hub certificate emoji hash mismatch",
			}, nil
		}
		if !samePEM(connectWith, probe.CaPEM) {
			return &pb.OnboardHubResponse{
				Stage:      pb.OnboardHubResponse_STAGE_FAILED,
				Success:    false,
				HubAddress: hubAddr,
				Error:      "trusted CA does not match current hub certificate",
			}, nil
		}
	}

	connResp, err := s.ConnectToHub(ctx, &pb.ConnectToHubRequest{
		HubAddress: hubAddr,
		HubCaPem:   connectWith,
		Token:      req.GetToken(),
	})
	if err != nil {
		return &pb.OnboardHubResponse{
			Stage:      pb.OnboardHubResponse_STAGE_FAILED,
			Success:    false,
			HubAddress: hubAddr,
			Error:      err.Error(),
		}, nil
	}
	if !connResp.Success {
		if looksLikeHubTrustFailure(connResp.Error) {
			caResp, fetchErr := s.FetchHubCA(ctx, &pb.FetchHubCARequest{HubAddress: hubAddr})
			if fetchErr == nil && caResp != nil && caResp.Success {
				challenge, challengeErr := s.createHubTrustChallenge(hubAddr, caResp, req)
				if challengeErr != nil {
					return &pb.OnboardHubResponse{
						Stage:      pb.OnboardHubResponse_STAGE_FAILED,
						Success:    false,
						HubAddress: hubAddr,
						Error:      "failed to create trust challenge: " + challengeErr.Error(),
						Connected:  false,
						Registered: false,
					}, nil
				}

				return &pb.OnboardHubResponse{
					Stage:          pb.OnboardHubResponse_STAGE_NEEDS_TRUST,
					Success:        false,
					HubAddress:     hubAddr,
					Error:          connResp.Error,
					Connected:      false,
					Registered:     false,
					TrustChallenge: challenge,
				}, nil
			}
		}
		return &pb.OnboardHubResponse{
			Stage:      pb.OnboardHubResponse_STAGE_FAILED,
			Success:    false,
			HubAddress: hubAddr,
			Error:      connResp.Error,
			Connected:  false,
			Registered: false,
		}, nil
	}

	if req.GetSkipRegistration() {
		return &pb.OnboardHubResponse{
			Stage:      pb.OnboardHubResponse_STAGE_COMPLETED,
			Success:    true,
			HubAddress: hubAddr,
			Connected:  true,
			Registered: false,
		}, nil
	}

	inviteCode := strings.TrimSpace(req.GetInviteCode())
	if inviteCode == "" {
		s.mu.RLock()
		if s.settings != nil {
			inviteCode = strings.TrimSpace(s.settings.GetHubInviteCode())
		}
		s.mu.RUnlock()
	}
	if inviteCode == "" {
		inviteCode = "NITELLA"
	}
	regResp, err := s.RegisterUser(ctx, &pb.RegisterUserRequest{
		InviteCode:         inviteCode,
		BiometricPublicKey: req.GetBiometricPublicKey(),
	})
	if err != nil {
		return &pb.OnboardHubResponse{
			Stage:      pb.OnboardHubResponse_STAGE_FAILED,
			Success:    false,
			HubAddress: hubAddr,
			Connected:  true,
			Registered: false,
			Error:      err.Error(),
		}, nil
	}
	if !regResp.Success {
		return &pb.OnboardHubResponse{
			Stage:      pb.OnboardHubResponse_STAGE_FAILED,
			Success:    false,
			HubAddress: hubAddr,
			Connected:  true,
			Registered: false,
			Error:      regResp.Error,
		}, nil
	}

	return &pb.OnboardHubResponse{
		Stage:      pb.OnboardHubResponse_STAGE_COMPLETED,
		Success:    true,
		HubAddress: hubAddr,
		Connected:  true,
		Registered: true,
		UserId:     regResp.UserId,
		Tier:       regResp.Tier,
		MaxNodes:   regResp.MaxNodes,
	}, nil
}

// EnsureHubConnected performs onboarding connection flow without registration.
// If already connected, it returns the current Hub status immediately.
func (s *MobileLogicService) EnsureHubConnected(ctx context.Context, req *pb.EnsureHubConnectedRequest) (*pb.OnboardHubResponse, error) {
	status, err := s.GetHubStatus(ctx, nil)
	if err == nil && status != nil && status.GetConnected() {
		return &pb.OnboardHubResponse{
			Stage:      pb.OnboardHubResponse_STAGE_COMPLETED,
			Success:    true,
			HubAddress: status.GetHubAddress(),
			Connected:  true,
			Registered: strings.TrimSpace(status.GetUserId()) != "",
			UserId:     status.GetUserId(),
			Tier:       status.GetTier(),
			MaxNodes:   status.GetMaxNodes(),
		}, nil
	}

	return s.OnboardHub(ctx, &pb.OnboardHubRequest{
		HubAddress:       req.GetHubAddress(),
		Token:            req.GetToken(),
		SkipRegistration: true,
		PersistSettings:  req.GetPersistSettings(),
	})
}

// EnsureHubRegistered performs onboarding with registration using backend defaults/state.
// If already connected and registered, it returns immediately.
func (s *MobileLogicService) EnsureHubRegistered(ctx context.Context, req *pb.EnsureHubRegisteredRequest) (*pb.OnboardHubResponse, error) {
	status, err := s.GetHubStatus(ctx, nil)
	if err == nil && status != nil && status.GetConnected() && strings.TrimSpace(status.GetUserId()) != "" {
		return &pb.OnboardHubResponse{
			Stage:      pb.OnboardHubResponse_STAGE_COMPLETED,
			Success:    true,
			HubAddress: status.GetHubAddress(),
			Connected:  true,
			Registered: true,
			UserId:     status.GetUserId(),
			Tier:       status.GetTier(),
			MaxNodes:   status.GetMaxNodes(),
		}, nil
	}

	return s.OnboardHub(ctx, &pb.OnboardHubRequest{
		HubAddress:         req.GetHubAddress(),
		InviteCode:         req.GetInviteCode(),
		Token:              req.GetToken(),
		BiometricPublicKey: req.GetBiometricPublicKey(),
		PersistSettings:    req.GetPersistSettings(),
	})
}

// ResolveHubTrustChallenge consumes a pending trust challenge and resumes onboarding.
// This keeps TOFU continuation context in backend instead of clients.
func (s *MobileLogicService) ResolveHubTrustChallenge(ctx context.Context, req *pb.ResolveHubTrustChallengeRequest) (*pb.OnboardHubResponse, error) {
	challengeID := strings.TrimSpace(req.GetChallengeId())
	if challengeID == "" {
		return &pb.OnboardHubResponse{
			Stage:   pb.OnboardHubResponse_STAGE_FAILED,
			Success: false,
			Error:   "challenge_id is required",
		}, nil
	}

	s.mu.Lock()
	s.cleanExpiredHubTrustChallengesLocked()
	session, exists := s.hubTrustChallenges[challengeID]
	var hubAddr, inviteCode, token string
	var skipRegistration bool
	var biometricPublicKey []byte
	if exists && session != nil {
		hubAddr = strings.TrimSpace(session.hubAddress)
		inviteCode = session.inviteCode
		token = session.token
		skipRegistration = session.skipRegistration
		biometricPublicKey = append([]byte(nil), session.biometricPublicKey...)
	}
	s.mu.Unlock()

	if !exists || session == nil || session.challenge == nil {
		return &pb.OnboardHubResponse{
			Stage:      pb.OnboardHubResponse_STAGE_FAILED,
			Success:    false,
			HubAddress: hubAddr,
			Error:      "trust challenge not found or expired",
			Connected:  false,
			Registered: false,
		}, nil
	}

	if !req.GetAccepted() {
		s.mu.Lock()
		delete(s.hubTrustChallenges, challengeID)
		s.mu.Unlock()
		return &pb.OnboardHubResponse{
			Stage:      pb.OnboardHubResponse_STAGE_FAILED,
			Success:    false,
			HubAddress: hubAddr,
			Error:      "hub certificate rejected by user",
			Connected:  false,
			Registered: false,
		}, nil
	}

	return s.OnboardHub(ctx, &pb.OnboardHubRequest{
		HubAddress:          hubAddr,
		InviteCode:          inviteCode,
		Token:               token,
		BiometricPublicKey:  biometricPublicKey,
		TrustPromptAccepted: true,
		TrustChallengeId:    challengeID,
		SkipRegistration:    skipRegistration,
	})
}

func looksLikeHubTrustFailure(errMsg string) bool {
	msg := strings.ToLower(strings.TrimSpace(errMsg))
	if msg == "" {
		return false
	}
	return strings.Contains(msg, "x509") ||
		strings.Contains(msg, "certificate") ||
		strings.Contains(msg, "tls") ||
		strings.Contains(msg, "transport") ||
		strings.Contains(msg, "authentication handshake failed")
}

func normalizeFingerprint(fp string) string {
	clean := strings.TrimSpace(strings.ToLower(fp))
	return strings.ReplaceAll(clean, ":", "")
}

func samePEM(a, b []byte) bool {
	return strings.TrimSpace(string(a)) == strings.TrimSpace(string(b))
}

func (s *MobileLogicService) createHubTrustChallenge(hubAddr string, caResp *pb.FetchHubCAResponse, req *pb.OnboardHubRequest) (*pb.HubTrustChallenge, error) {
	if caResp == nil || len(caResp.GetCaPem()) == 0 {
		return nil, fmt.Errorf("missing CA data")
	}

	idBytes := make([]byte, 16)
	if _, err := rand.Read(idBytes); err != nil {
		return nil, fmt.Errorf("failed to generate challenge id: %w", err)
	}
	challengeID := hex.EncodeToString(idBytes)

	challenge := &pb.HubTrustChallenge{
		CaPem:       append([]byte(nil), caResp.GetCaPem()...),
		Fingerprint: caResp.GetFingerprint(),
		EmojiHash:   caResp.GetEmojiHash(),
		Subject:     caResp.GetSubject(),
		Expires:     caResp.GetExpires(),
		ChallengeId: challengeID,
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	s.cleanExpiredHubTrustChallengesLocked()
	inviteCode := ""
	token := ""
	skipRegistration := false
	var biometricPublicKey []byte
	if req != nil {
		inviteCode = strings.TrimSpace(req.GetInviteCode())
		token = req.GetToken()
		skipRegistration = req.GetSkipRegistration()
		biometricPublicKey = append([]byte(nil), req.GetBiometricPublicKey()...)
	}
	s.hubTrustChallenges[challengeID] = &hubTrustChallengeSession{
		hubAddress:         strings.TrimSpace(hubAddr),
		challenge:          challenge,
		expiresAt:          time.Now().Add(hubTrustChallengeTTL).Unix(),
		inviteCode:         inviteCode,
		token:              token,
		skipRegistration:   skipRegistration,
		biometricPublicKey: biometricPublicKey,
	}

	return challenge, nil
}

func (s *MobileLogicService) takeHubTrustChallenge(hubAddr, challengeID string) (*pb.HubTrustChallenge, error) {
	challengeID = strings.TrimSpace(challengeID)
	if challengeID == "" {
		return nil, fmt.Errorf("trust_challenge_id is required when trust_prompt_accepted is true")
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	s.cleanExpiredHubTrustChallengesLocked()

	session, exists := s.hubTrustChallenges[challengeID]
	if !exists || session == nil || session.challenge == nil {
		return nil, fmt.Errorf("trust challenge not found or expired")
	}
	delete(s.hubTrustChallenges, challengeID)

	if strings.TrimSpace(session.hubAddress) != strings.TrimSpace(hubAddr) {
		return nil, fmt.Errorf("trust challenge is for a different hub address")
	}

	return &pb.HubTrustChallenge{
		CaPem:       append([]byte(nil), session.challenge.GetCaPem()...),
		Fingerprint: session.challenge.GetFingerprint(),
		EmojiHash:   session.challenge.GetEmojiHash(),
		Subject:     session.challenge.GetSubject(),
		Expires:     session.challenge.GetExpires(),
		ChallengeId: session.challenge.GetChallengeId(),
	}, nil
}

func (s *MobileLogicService) cleanExpiredHubTrustChallengesLocked() {
	now := time.Now().Unix()
	for challengeID, session := range s.hubTrustChallenges {
		if session == nil || now > session.expiresAt {
			delete(s.hubTrustChallenges, challengeID)
		}
	}
}

func cloneHubTrustChallenge(challenge *pb.HubTrustChallenge) *pb.HubTrustChallenge {
	if challenge == nil {
		return nil
	}
	return &pb.HubTrustChallenge{
		CaPem:       append([]byte(nil), challenge.GetCaPem()...),
		Fingerprint: challenge.GetFingerprint(),
		EmojiHash:   challenge.GetEmojiHash(),
		Subject:     challenge.GetSubject(),
		Expires:     challenge.GetExpires(),
		ChallengeId: challenge.GetChallengeId(),
	}
}

// pendingHubTrustChallengeLocked returns an active pending challenge, prioritizing
// the provided hub address when present.
func (s *MobileLogicService) pendingHubTrustChallengeLocked(hubAddr string) *pb.HubTrustChallenge {
	now := time.Now().Unix()
	normalizedHubAddr := strings.TrimSpace(hubAddr)
	var fallback *pb.HubTrustChallenge

	for _, session := range s.hubTrustChallenges {
		if session == nil || session.challenge == nil || now > session.expiresAt {
			continue
		}
		challenge := cloneHubTrustChallenge(session.challenge)
		if challenge == nil {
			continue
		}
		if normalizedHubAddr != "" && strings.TrimSpace(session.hubAddress) == normalizedHubAddr {
			return challenge
		}
		if fallback == nil {
			fallback = challenge
		}
	}
	return fallback
}
