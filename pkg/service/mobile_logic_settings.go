package service

import (
	"context"
	"log"
	"strings"

	pb "github.com/ivere27/nitella/pkg/api/local"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/emptypb"
)

// ===========================================================================
// Settings
// ===========================================================================

// GetSettings returns the current settings.
func (s *MobileLogicService) GetSettings(ctx context.Context, _ *emptypb.Empty) (*pb.Settings, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	return s.settings, nil
}

// GetSettingsOverviewSnapshot returns identity + hub + p2p settings/state for thin clients.
func (s *MobileLogicService) GetSettingsOverviewSnapshot(ctx context.Context, _ *emptypb.Empty) (*pb.SettingsOverviewSnapshot, error) {
	_ = ctx

	s.mu.RLock()
	defer s.mu.RUnlock()

	identity := s.buildIdentityInfo()

	baseSettings := &pb.Settings{}
	if s.settings != nil {
		baseSettings = proto.Clone(s.settings).(*pb.Settings)
	}

	hubStatus := &pb.HubStatus{
		Connected:  s.hubConnected,
		HubAddress: s.hubAddr,
		UserId:     s.hubUserID,
		Tier:       s.hubTier,
		MaxNodes:   s.hubMaxNodes,
	}
	hubSettings := proto.Clone(baseSettings).(*pb.Settings)
	resolvedHubAddress := strings.TrimSpace(hubStatus.GetHubAddress())
	if resolvedHubAddress == "" {
		resolvedHubAddress = strings.TrimSpace(hubSettings.GetHubAddress())
	}
	resolvedInviteCode := strings.TrimSpace(hubSettings.GetHubInviteCode())
	if resolvedInviteCode == "" {
		resolvedInviteCode = "NITELLA"
	}

	p2pStatus := &pb.P2PStatus{Enabled: false}
	if err := s.requireIdentity(); err == nil {
		p2pStatus = s.buildP2PStatusLocked()
	}
	p2pSettings := proto.Clone(baseSettings).(*pb.Settings)

	return &pb.SettingsOverviewSnapshot{
		Identity: identity,
		Hub: &pb.HubSettingsSnapshot{
			Status:                hubStatus,
			Settings:              hubSettings,
			ResolvedHubAddress:    resolvedHubAddress,
			ResolvedInviteCode:    resolvedInviteCode,
			PendingTrustChallenge: s.pendingHubTrustChallengeLocked(resolvedHubAddress),
		},
		P2P: &pb.P2PSettingsSnapshot{
			Status:   p2pStatus,
			Settings: p2pSettings,
		},
	}, nil
}

// GetHubSettingsSnapshot returns hub status + settings + resolved values for thin clients.
func (s *MobileLogicService) GetHubSettingsSnapshot(ctx context.Context, _ *emptypb.Empty) (*pb.HubSettingsSnapshot, error) {
	_ = ctx

	s.mu.RLock()
	defer s.mu.RUnlock()

	status := &pb.HubStatus{
		Connected:  s.hubConnected,
		HubAddress: s.hubAddr,
		UserId:     s.hubUserID,
		Tier:       s.hubTier,
		MaxNodes:   s.hubMaxNodes,
	}

	settings := &pb.Settings{}
	if s.settings != nil {
		settings = proto.Clone(s.settings).(*pb.Settings)
	}

	resolvedHubAddress := strings.TrimSpace(status.GetHubAddress())
	if resolvedHubAddress == "" {
		resolvedHubAddress = strings.TrimSpace(settings.GetHubAddress())
	}

	resolvedInviteCode := strings.TrimSpace(settings.GetHubInviteCode())
	if resolvedInviteCode == "" {
		resolvedInviteCode = "NITELLA"
	}

	return &pb.HubSettingsSnapshot{
		Status:                status,
		Settings:              settings,
		ResolvedHubAddress:    resolvedHubAddress,
		ResolvedInviteCode:    resolvedInviteCode,
		PendingTrustChallenge: s.pendingHubTrustChallengeLocked(resolvedHubAddress),
	}, nil
}

// UpdateSettings updates settings.
func (s *MobileLogicService) UpdateSettings(ctx context.Context, req *pb.UpdateSettingsRequest) (*pb.Settings, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if req.Settings == nil {
		return s.settings, nil
	}

	oldStun := ""
	if len(s.settings.GetStunServers()) > 0 {
		oldStun = s.settings.GetStunServers()[0]
	}

	// Merge settings: if update_mask is provided, only update specified fields;
	// otherwise merge all non-zero fields from the request into current settings.
	if req.UpdateMask != nil && len(req.UpdateMask.Paths) > 0 {
		for _, path := range req.UpdateMask.Paths {
			switch path {
			case "hub_address":
				s.settings.HubAddress = req.Settings.HubAddress
			case "hub_invite_code":
				s.settings.HubInviteCode = req.Settings.HubInviteCode
			case "auto_connect_hub":
				s.settings.AutoConnectHub = req.Settings.AutoConnectHub
			case "notifications_enabled":
				s.settings.NotificationsEnabled = req.Settings.NotificationsEnabled
			case "approval_notifications":
				s.settings.ApprovalNotifications = req.Settings.ApprovalNotifications
			case "connection_notifications":
				s.settings.ConnectionNotifications = req.Settings.ConnectionNotifications
			case "alert_notifications":
				s.settings.AlertNotifications = req.Settings.AlertNotifications
			case "p2p_mode":
				s.settings.P2PMode = req.Settings.P2PMode
			case "require_biometric":
				s.settings.RequireBiometric = req.Settings.RequireBiometric
			case "auto_lock_minutes":
				s.settings.AutoLockMinutes = req.Settings.AutoLockMinutes
			case "theme":
				s.settings.Theme = req.Settings.Theme
			case "language":
				s.settings.Language = req.Settings.Language
			case "hub_ca_pem":
				s.settings.HubCaPem = req.Settings.HubCaPem
			case "hub_cert_pin":
				s.settings.HubCertPin = req.Settings.HubCertPin
			case "stun_servers":
				s.settings.StunServers = append([]string(nil), req.Settings.StunServers...)
			case "turn_server":
				s.settings.TurnServer = req.Settings.TurnServer
			case "turn_username":
				s.settings.TurnUsername = req.Settings.TurnUsername
			case "turn_password":
				s.settings.TurnPassword = req.Settings.TurnPassword
			}
		}
	} else {
		proto.Merge(s.settings, req.Settings)
	}

	// Apply settings that require immediate action
	oldHubAddr := s.hubAddr
	if s.settings.HubAddress != "" {
		s.hubAddr = s.settings.HubAddress
	}

	// Auto-reconnect to new Hub address if enabled and address changed
	if s.settings.AutoConnectHub && s.hubAddr != oldHubAddr && s.hubAddr != "" {
		// Close existing connection
		if s.hubConn != nil {
			s.hubConn.Close()
			s.hubConn = nil
			s.mobileClient = nil
			s.authClient = nil
			s.pairingClient = nil
			s.hubConnected = false
		}

		// Reconnect in background if identity is available
		// Use background context since the request context will be canceled when the RPC returns.
		if s.identity != nil {
			go s.reconnectHub(context.Background())
		}
	}

	// Apply STUN update to active transport.
	newStun := ""
	if len(s.settings.GetStunServers()) > 0 {
		newStun = s.settings.GetStunServers()[0]
	}
	if newStun != "" && newStun != oldStun && s.p2pTransport != nil {
		s.p2pTransport.SetSTUNServer(newStun)
	}

	// Persist settings to storage
	if err := s.saveSettings(); err != nil {
		// Non-fatal, log but continue
		if s.debugMode {
			log.Printf("warning: failed to save settings: %v\n", err)
		}
	}

	return s.settings, nil
}

// ===========================================================================
// FCM
// ===========================================================================

// RegisterFCMToken registers an FCM token for push notifications.
func (s *MobileLogicService) RegisterFCMToken(ctx context.Context, req *pb.RegisterFCMTokenRequest) (*emptypb.Empty, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.fcmToken = req.FcmToken
	s.fcmDeviceType = req.DeviceType

	// Skip FCM token registration - not a nitella feature
	_ = s.mobileClient // silence unused warning if needed

	return &emptypb.Empty{}, nil
}

// UnregisterFCMToken unregisters the FCM token.
func (s *MobileLogicService) UnregisterFCMToken(ctx context.Context, _ *emptypb.Empty) (*emptypb.Empty, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Skip FCM token unregistration - not a nitella feature

	s.fcmToken = ""
	s.fcmDeviceType = pb.DeviceType_DEVICE_TYPE_UNSPECIFIED

	return &emptypb.Empty{}, nil
}
