package service

import (
	"context"

	pb "github.com/ivere27/nitella/pkg/api/local"
	"google.golang.org/protobuf/types/known/emptypb"
)

// GetBootstrapState returns backend-owned startup state for thin clients.
func (s *MobileLogicService) GetBootstrapState(ctx context.Context, _ *emptypb.Empty) (*pb.BootstrapStateResponse, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	identity := s.buildIdentityInfo()
	resp := &pb.BootstrapStateResponse{
		IdentityExists: identity.GetExists(),
		IdentityLocked: identity.GetLocked(),
	}
	if s.settings != nil {
		resp.RequireBiometric = s.settings.GetRequireBiometric()
	}

	switch {
	case !resp.GetIdentityExists():
		resp.Stage = pb.BootstrapStage_BOOTSTRAP_STAGE_SETUP_NEEDED
	case resp.GetRequireBiometric() || resp.GetIdentityLocked():
		resp.Stage = pb.BootstrapStage_BOOTSTRAP_STAGE_AUTH_NEEDED
	default:
		resp.Stage = pb.BootstrapStage_BOOTSTRAP_STAGE_READY
	}

	_ = ctx
	return resp, nil
}
