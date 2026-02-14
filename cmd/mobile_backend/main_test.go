package main

import (
	"testing"

	pb "github.com/ivere27/nitella/pkg/api/local"
	"google.golang.org/protobuf/proto"
)

func TestDartUICallbackOnApprovalRequestInvokesExpectedMethod(t *testing.T) {
	originalInvoke := invokeDartFn
	t.Cleanup(func() {
		invokeDartFn = originalInvoke
	})

	var gotMethod string
	var gotPayload []byte
	invokeDartFn = func(method string, data []byte) ([]byte, error) {
		gotMethod = method
		gotPayload = append([]byte(nil), data...)
		return nil, nil
	}

	cb := &dartUICallback{}
	req := &pb.ApprovalRequest{
		RequestId: "req-1",
		NodeId:    "node-1",
		SourceIp:  "127.0.0.1",
	}
	if err := cb.OnApprovalRequest(req); err != nil {
		t.Fatalf("OnApprovalRequest returned error: %v", err)
	}

	if gotMethod != dartMethodOnApprovalRequest {
		t.Fatalf("method mismatch: got %q, want %q", gotMethod, dartMethodOnApprovalRequest)
	}

	var decoded pb.ApprovalRequest
	if err := proto.Unmarshal(gotPayload, &decoded); err != nil {
		t.Fatalf("failed to decode payload: %v", err)
	}
	if decoded.GetRequestId() != req.GetRequestId() || decoded.GetNodeId() != req.GetNodeId() {
		t.Fatalf("decoded payload mismatch: got request_id=%q node_id=%q", decoded.GetRequestId(), decoded.GetNodeId())
	}
}

func TestDartUICallbackNilInputsDoNotInvokeDart(t *testing.T) {
	originalInvoke := invokeDartFn
	t.Cleanup(func() {
		invokeDartFn = originalInvoke
	})

	invoked := 0
	invokeDartFn = func(method string, data []byte) ([]byte, error) {
		invoked++
		return nil, nil
	}

	cb := &dartUICallback{}
	if err := cb.OnApprovalRequest(nil); err != nil {
		t.Fatalf("OnApprovalRequest(nil) returned error: %v", err)
	}
	if err := cb.OnNodeStatusChange(nil); err != nil {
		t.Fatalf("OnNodeStatusChange(nil) returned error: %v", err)
	}
	if err := cb.OnConnectionEvent(nil); err != nil {
		t.Fatalf("OnConnectionEvent(nil) returned error: %v", err)
	}
	if err := cb.OnAlert(nil); err != nil {
		t.Fatalf("OnAlert(nil) returned error: %v", err)
	}
	if err := cb.OnToast(nil); err != nil {
		t.Fatalf("OnToast(nil) returned error: %v", err)
	}

	if invoked != 0 {
		t.Fatalf("expected zero Dart invocations for nil inputs, got %d", invoked)
	}
}
