package service

import (
	"fmt"
	"testing"

	pb "github.com/ivere27/nitella/pkg/api/local"
)

func TestPaginateConnections_DefaultLimitAndOffset(t *testing.T) {
	connections := make([]*pb.ConnectionInfo, 0, 8)
	for i := 0; i < 8; i++ {
		connections = append(connections, &pb.ConnectionInfo{ConnId: fmt.Sprintf("conn-%d", i)})
	}

	paged := paginateConnections(connections, 2, 0, 1000)
	if got, want := len(paged), 6; got != want {
		t.Fatalf("unexpected paged size: got=%d want=%d", got, want)
	}
	if got, want := paged[0].GetConnId(), "conn-2"; got != want {
		t.Fatalf("unexpected first item: got=%q want=%q", got, want)
	}
	if got, want := paged[len(paged)-1].GetConnId(), "conn-7"; got != want {
		t.Fatalf("unexpected last item: got=%q want=%q", got, want)
	}
}

func TestPaginateConnections_ClampsLimitToMax(t *testing.T) {
	connections := make([]*pb.ConnectionInfo, 0, 20)
	for i := 0; i < 20; i++ {
		connections = append(connections, &pb.ConnectionInfo{ConnId: fmt.Sprintf("conn-%d", i)})
	}

	paged := paginateConnections(connections, 0, 9999, 5)
	if got, want := len(paged), 5; got != want {
		t.Fatalf("unexpected paged size: got=%d want=%d", got, want)
	}
}

func TestPaginateConnections_OffsetOutOfRange(t *testing.T) {
	connections := []*pb.ConnectionInfo{
		{ConnId: "conn-0"},
		{ConnId: "conn-1"},
	}

	paged := paginateConnections(connections, 50, 10, 1000)
	if got := len(paged); got != 0 {
		t.Fatalf("expected empty page, got=%d items", got)
	}
}

func TestPaginateConnections_NegativeOffset(t *testing.T) {
	connections := []*pb.ConnectionInfo{
		{ConnId: "conn-0"},
		{ConnId: "conn-1"},
		{ConnId: "conn-2"},
	}

	paged := paginateConnections(connections, -5, 2, 1000)
	if got, want := len(paged), 2; got != want {
		t.Fatalf("unexpected paged size: got=%d want=%d", got, want)
	}
	if got, want := paged[0].GetConnId(), "conn-0"; got != want {
		t.Fatalf("unexpected first item: got=%q want=%q", got, want)
	}
}
