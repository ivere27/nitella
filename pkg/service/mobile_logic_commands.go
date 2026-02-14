package service

import (
	"context"
	"fmt"

	pbHub "github.com/ivere27/nitella/pkg/api/hub"
	pb "github.com/ivere27/nitella/pkg/api/local"
	"google.golang.org/protobuf/proto"
)

func isDirectNodeInfo(node *pb.NodeInfo) bool {
	return node != nil && node.GetConnType() == pb.NodeConnectionType_NODE_CONNECTION_TYPE_DIRECT
}

func requireRoutableNode(node *pb.NodeInfo, mobileClient pbHub.MobileServiceClient, requireHubForHubNode bool) (bool, error) {
	isDirect := isDirectNodeInfo(node)
	if isDirect {
		return true, nil
	}
	if !node.GetOnline() && mobileClient == nil {
		return false, fmt.Errorf("node is offline")
	}
	if requireHubForHubNode && mobileClient == nil {
		return false, fmt.Errorf("not connected to Hub")
	}
	return false, nil
}

func (s *MobileLogicService) sendRoutedCommand(ctx context.Context, nodeID string, cmdType pbHub.CommandType, req proto.Message) (*pbHub.CommandResult, error) {
	if s.isDirectNode(nodeID) {
		return s.secureDirectCommand(ctx, nodeID, cmdType, req)
	}

	var payload []byte
	if req != nil {
		encoded, err := proto.Marshal(req)
		if err != nil {
			return nil, fmt.Errorf("failed to encode command payload: %w", err)
		}
		payload = encoded
	}
	return s.sendCommand(ctx, nodeID, cmdType, payload)
}
