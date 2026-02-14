package server

import (
	"context"
	"log"
	"time"

	"github.com/google/uuid"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	pb "github.com/ivere27/nitella/pkg/api/hub"
	"github.com/ivere27/nitella/pkg/hub/model"
)

// ============================================================================
// AuthServer - Authentication service
// ============================================================================

type AuthServer struct {
	pb.UnimplementedAuthServiceServer
	hub *HubServer
}

func (s *AuthServer) RegisterUser(ctx context.Context, req *pb.RegisterUserRequest) (*pb.RegisterUserResponse, error) {
	// Validate invite code
	if req.InviteCode != "" {
		invite, err := s.hub.store.GetInviteCode(req.InviteCode)
		if err != nil {
			return nil, status.Error(codes.InvalidArgument, "Invalid invite code")
		}
		if err := s.hub.store.ConsumeInviteCode(req.InviteCode); err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "Invite code error: %v", err)
		}

		// Create user with tier from invite
		// BlindIndex is required to be unique - if not provided, generate from UUID
		blindIndex := req.BlindIndex
		if blindIndex == "" {
			blindIndex = uuid.New().String()
		}
		user := &model.User{
			ID:         uuid.New().String(),
			BlindIndex: blindIndex,
			Tier:       invite.TierID,
			InviteCode: req.InviteCode,
			CreatedAt:  time.Now(),
		}
		if err := s.hub.store.SaveUser(user); err != nil {
			return nil, status.Errorf(codes.Internal, "Failed to create user: %v", err)
		}

		// Log registration (Secure & Concise)
		shortBlind := user.BlindIndex
		if len(shortBlind) > 8 {
			shortBlind = shortBlind[:8] + "..."
		}
		log.Printf("[Auth] New User Registered (Tier: %s, ID: %s...)", invite.TierID, shortBlind)

		// Generate tokens
		token, err := s.hub.tokenManager.GenerateMobileToken(user.ID, "")
		if err != nil {
			return nil, status.Errorf(codes.Internal, "Failed to generate token: %v", err)
		}

		tierCfg := s.hub.tierConfig.GetTierOrDefault(invite.TierID)

		return &pb.RegisterUserResponse{
			UserId:       user.ID,
			Tier:         invite.TierID,
			MaxNodes:     int32(tierCfg.MaxNodes),
			JwtToken:     token,
			RefreshToken: token, // Using same token for now
		}, nil
	}

	return nil, status.Error(codes.InvalidArgument, "Invite code required")
}

func (s *AuthServer) RegisterDevice(ctx context.Context, req *pb.RegisterDeviceRequest) (*pb.Empty, error) {
	// Zero-Trust: Use FCM topic (blind) instead of UserID
	// The FCMTopic should be derived from user's secret on the client side
	fcmTopic := req.UserId // TODO: Rename field in proto to fcm_topic
	token := &model.FCMToken{
		Token:      req.FcmToken,
		FCMTopic:   fcmTopic,
		DeviceType: req.DeviceType,
		UpdatedAt:  time.Now(),
	}
	s.hub.store.SaveFCMToken(token)
	return &pb.Empty{}, nil
}

func (s *AuthServer) UpdateLicense(ctx context.Context, req *pb.UpdateLicenseRequest) (*pb.UpdateLicenseResponse, error) {
	routingToken := req.GetRoutingToken()
	if routingToken == "" {
		return nil, status.Error(codes.InvalidArgument, "routing_token is required")
	}

	// Look up tier from license key prefix
	tierID, tierCfg := s.hub.getTierByLicenseKey(req.GetLicenseKey())

	// Update routing token's tier
	info, err := s.hub.store.GetRoutingTokenInfo(routingToken)
	if err != nil {
		return nil, status.Error(codes.NotFound, "routing token not found")
	}

	info.LicenseKey = req.GetLicenseKey()
	info.Tier = tierID
	if err := s.hub.store.SaveRoutingTokenInfo(info); err != nil {
		return nil, status.Errorf(codes.Internal, "failed to update license: %v", err)
	}

	maxNodes := tierCfg.MaxNodes
	if maxNodes == 0 {
		maxNodes = -1 // -1 indicates unlimited
	}

	return &pb.UpdateLicenseResponse{
		Tier:     tierID,
		MaxNodes: int32(maxNodes),
		Valid:    true,
	}, nil
}
