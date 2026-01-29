package geoip

import (
	"context"
	"net"

	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/geoip"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
)

type GrpcServer struct {
	pb.UnimplementedGeoIPServiceServer
	manager *Manager
}

func NewGrpcServer(m *Manager) *GrpcServer {
	return &GrpcServer{manager: m}
}

func (s *GrpcServer) Lookup(ctx context.Context, req *pb.LookupRequest) (*pbCommon.GeoInfo, error) {
	if net.ParseIP(req.Ip) == nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid IP address: %s", req.Ip)
	}
	info, err := s.manager.Lookup(ctx, req.Ip)
	if err != nil {
		return nil, err
	}
	return info, nil
}

func (s *GrpcServer) GetStatus(ctx context.Context, req *emptypb.Empty) (*pb.ServiceStatus, error) {
	return s.manager.GetStatus(), nil
}

func Register(s *grpc.Server, srv *GrpcServer) {
	pb.RegisterGeoIPServiceServer(s, srv)
}
