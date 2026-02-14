package service

import (
	"context"

	pb "github.com/ivere27/nitella/pkg/api/local"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/emptypb"
)

// ===========================================================================
// P2P Management
// ===========================================================================

// GetP2PStatus returns the current P2P connection status.
func (s *MobileLogicService) GetP2PStatus(ctx context.Context, _ *emptypb.Empty) (*pb.P2PStatus, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	if err := s.requireIdentity(); err != nil {
		return &pb.P2PStatus{Enabled: false}, nil
	}

	return s.buildP2PStatusLocked(), nil
}

// GetP2PSettingsSnapshot returns current P2P runtime status + persisted settings.
func (s *MobileLogicService) GetP2PSettingsSnapshot(ctx context.Context, _ *emptypb.Empty) (*pb.P2PSettingsSnapshot, error) {
	_ = ctx

	s.mu.RLock()
	defer s.mu.RUnlock()

	status := &pb.P2PStatus{Enabled: false}
	if err := s.requireIdentity(); err == nil {
		status = s.buildP2PStatusLocked()
	}

	settings := &pb.Settings{}
	if s.settings != nil {
		settings = proto.Clone(s.settings).(*pb.Settings)
	}

	return &pb.P2PSettingsSnapshot{
		Status:   status,
		Settings: settings,
	}, nil
}

// StreamP2PStatus streams P2P status changes.
func (s *MobileLogicService) StreamP2PStatus(_ *emptypb.Empty, stream pb.MobileLogicService_StreamP2PStatusServer) error {
	s.mu.RLock()
	if err := s.requireIdentity(); err != nil {
		s.mu.RUnlock()
		return err
	}
	s.mu.RUnlock()

	ch := make(chan *pb.P2PStatus, 10)
	s.p2pStatusStreamsMu.Lock()
	s.p2pStatusStreams = append(s.p2pStatusStreams, ch)
	s.p2pStatusStreamsMu.Unlock()

	defer func() {
		s.p2pStatusStreamsMu.Lock()
		for i, c := range s.p2pStatusStreams {
			if c == ch {
				s.p2pStatusStreams = append(s.p2pStatusStreams[:i], s.p2pStatusStreams[i+1:]...)
				break
			}
		}
		s.p2pStatusStreamsMu.Unlock()
		close(ch)
	}()

	// Send initial status
	s.mu.RLock()
	initial := s.buildP2PStatusLocked()
	s.mu.RUnlock()
	if err := stream.Send(initial); err != nil {
		return err
	}

	for {
		select {
		case <-stream.Context().Done():
			return nil
		case status := <-ch:
			if err := stream.Send(status); err != nil {
				return err
			}
		}
	}
}

// StreamP2PStatusInternal is used by FFI for polling-based streaming.
func (s *MobileLogicService) StreamP2PStatusInternal(ctx context.Context, _ *emptypb.Empty) (*pb.P2PStatus, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	if err := s.requireIdentity(); err != nil {
		return nil, err
	}

	return s.buildP2PStatusLocked(), nil
}

// SetP2PMode sets the P2P connection mode.
func (s *MobileLogicService) SetP2PMode(ctx context.Context, req *pb.SetP2PModeRequest) (*emptypb.Empty, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if err := s.requireIdentity(); err != nil {
		return nil, err
	}

	if s.settings == nil {
		s.settings = defaultSettings()
	}

	// Store P2P mode in settings (both now use common.P2PMode)
	s.settings.P2PMode = req.Mode
	s.saveSettings()

	// Re-initialize transport if needed
	if s.hubConnected {
		s.initP2PTransportLocked()
	}

	s.notifyP2PStatusStreamsLocked()

	return &emptypb.Empty{}, nil
}

// buildP2PStatusLocked builds P2PStatus message.
// Caller MUST hold s.mu.RLock() or s.mu.Lock().
func (s *MobileLogicService) buildP2PStatusLocked() *pb.P2PStatus {
	enabled := s.p2pTransport != nil
	var activeConns int32
	var connectedNodes []string

	if enabled {
		connectedNodes = s.p2pTransport.GetConnectedNodes()
		activeConns = int32(len(connectedNodes))
	}

	return &pb.P2PStatus{
		Enabled:           enabled,
		Mode:              s.settings.GetP2PMode(),
		ActiveConnections: activeConns,
		ConnectedNodes:    connectedNodes,
	}
}

// notifyP2PStatusStreamsLocked notifies all P2P status streams.
// Caller MUST hold s.mu.RLock() or s.mu.Lock().
func (s *MobileLogicService) notifyP2PStatusStreamsLocked() {
	status := s.buildP2PStatusLocked()

	s.p2pStatusStreamsMu.RLock()
	defer s.p2pStatusStreamsMu.RUnlock()

	for _, ch := range s.p2pStatusStreams {
		select {
		case ch <- status:
		default:
		}
	}
}
