package service

import (
	"context"
	"fmt"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/local"
	pbProxy "github.com/ivere27/nitella/pkg/api/proxy"
	"google.golang.org/protobuf/proto"
)

// RestartListeners restarts proxy listeners on a node.
func (s *MobileLogicService) RestartListeners(ctx context.Context, req *pb.RestartListenersNodeRequest) (*pbProxy.RestartListenersResponse, error) {
	if req.NodeId == "" {
		return &pbProxy.RestartListenersResponse{
			Success:      false,
			ErrorMessage: "node_id is required",
		}, nil
	}

	result, err := s.sendNodeRuntimeCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_RESTART_LISTENERS, nil)
	if err != nil {
		return &pbProxy.RestartListenersResponse{
			Success:      false,
			ErrorMessage: err.Error(),
		}, nil
	}
	if result.Status != "OK" {
		return &pbProxy.RestartListenersResponse{
			Success:      false,
			ErrorMessage: result.ErrorMessage,
		}, nil
	}

	resp := &pbProxy.RestartListenersResponse{Success: true}
	if len(result.ResponsePayload) > 0 {
		if err := proto.Unmarshal(result.ResponsePayload, resp); err != nil {
			return &pbProxy.RestartListenersResponse{
				Success:      false,
				ErrorMessage: fmt.Sprintf("failed to parse response: %v", err),
			}, nil
		}
	}

	return resp, nil
}

// ConfigureGeoIP configures GeoIP settings on a node.
func (s *MobileLogicService) ConfigureGeoIP(ctx context.Context, req *pb.ConfigureGeoIPNodeRequest) (*pbProxy.ConfigureGeoIPResponse, error) {
	if req.NodeId == "" {
		return &pbProxy.ConfigureGeoIPResponse{
			Success: false,
			Error:   "node_id is required",
		}, nil
	}
	if req.Config == nil {
		return &pbProxy.ConfigureGeoIPResponse{
			Success: false,
			Error:   "config is required",
		}, nil
	}

	result, err := s.sendNodeRuntimeCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_CONFIGURE_GEOIP, req.Config)
	if err != nil {
		return &pbProxy.ConfigureGeoIPResponse{
			Success: false,
			Error:   err.Error(),
		}, nil
	}
	if result.Status != "OK" {
		return &pbProxy.ConfigureGeoIPResponse{
			Success: false,
			Error:   result.ErrorMessage,
		}, nil
	}

	resp := &pbProxy.ConfigureGeoIPResponse{Success: true}
	if len(result.ResponsePayload) > 0 {
		if err := proto.Unmarshal(result.ResponsePayload, resp); err != nil {
			return &pbProxy.ConfigureGeoIPResponse{
				Success: false,
				Error:   fmt.Sprintf("failed to parse response: %v", err),
			}, nil
		}
	}

	return resp, nil
}

// GetGeoIPStatus gets current GeoIP status from a node.
func (s *MobileLogicService) GetGeoIPStatus(ctx context.Context, req *pb.GetGeoIPStatusNodeRequest) (*pbProxy.GetGeoIPStatusResponse, error) {
	if req.NodeId == "" {
		return nil, fmt.Errorf("node_id is required")
	}

	result, err := s.sendNodeRuntimeCommand(ctx, req.NodeId, pbHub.CommandType_COMMAND_TYPE_GET_GEOIP_STATUS, &pbProxy.GetGeoIPStatusRequest{})
	if err != nil {
		return nil, err
	}
	if result.Status != "OK" {
		return nil, fmt.Errorf("failed to get geoip status: %s", result.ErrorMessage)
	}

	resp := &pbProxy.GetGeoIPStatusResponse{}
	if len(result.ResponsePayload) > 0 {
		if err := proto.Unmarshal(result.ResponsePayload, resp); err != nil {
			return nil, fmt.Errorf("failed to parse response: %w", err)
		}
	}

	return resp, nil
}

// sendNodeRuntimeCommand sends runtime-control commands to either direct or hub-connected nodes.
func (s *MobileLogicService) sendNodeRuntimeCommand(ctx context.Context, nodeID string, cmdType pbHub.CommandType, req proto.Message) (*pbHub.CommandResult, error) {
	s.mu.RLock()
	node, exists := s.nodes[nodeID]
	mobileClient := s.mobileClient
	s.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("node not found: %s", nodeID)
	}

	// Handle direct nodes
	if s.isDirectNode(nodeID) {
		return s.secureDirectCommand(ctx, nodeID, cmdType, req)
	}

	if !node.Online && mobileClient == nil {
		return nil, fmt.Errorf("node is offline")
	}

	var payload []byte
	if req != nil {
		var err error
		payload, err = proto.Marshal(req)
		if err != nil {
			return nil, fmt.Errorf("marshal request: %w", err)
		}
	}

	return s.sendCommand(ctx, nodeID, cmdType, payload)
}
