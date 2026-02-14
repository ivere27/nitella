package service

import (
	"strings"
	"testing"

	pb "github.com/ivere27/nitella/pkg/api/local"
)

func TestRequireRoutableNode(t *testing.T) {
	direct := &pb.NodeInfo{
		NodeId:   "direct-1",
		ConnType: pb.NodeConnectionType_NODE_CONNECTION_TYPE_DIRECT,
	}
	isDirect, err := requireRoutableNode(direct, nil, true)
	if err != nil {
		t.Fatalf("direct node should be routable, got error: %v", err)
	}
	if !isDirect {
		t.Fatalf("expected direct node classification")
	}

	offlineHubNode := &pb.NodeInfo{
		NodeId: "hub-offline",
		Online: false,
	}
	_, err = requireRoutableNode(offlineHubNode, nil, false)
	if err == nil || !strings.Contains(err.Error(), "offline") {
		t.Fatalf("expected offline error, got: %v", err)
	}

	onlineHubNode := &pb.NodeInfo{
		NodeId: "hub-online",
		Online: true,
	}
	_, err = requireRoutableNode(onlineHubNode, nil, true)
	if err == nil || !strings.Contains(err.Error(), "not connected to Hub") {
		t.Fatalf("expected not connected error, got: %v", err)
	}

	isDirect, err = requireRoutableNode(onlineHubNode, nil, false)
	if err != nil {
		t.Fatalf("expected routable hub node when hub is optional, got: %v", err)
	}
	if isDirect {
		t.Fatalf("expected hub node classification")
	}
}
