package service

import (
	"context"
	"os"
	"runtime"
	"sort"
	"strconv"
	"strings"
	"time"

	pb "github.com/ivere27/nitella/pkg/api/local"
	"google.golang.org/protobuf/types/known/timestamppb"
)

const maxGoroutineDiffEntries = 20

type goroutineDiffSnapshot struct {
	hasBaseline bool
	prevTotal   int64
	currTotal   int64
	delta       int64
	prevAt      time.Time
	currAt      time.Time
	entries     []*pb.DebugGoroutineDiffEntry
	truncated   int32
}

// GetDebugRuntimeStats returns local runtime/process debug stats from MobileLogicService.
func (s *MobileLogicService) GetDebugRuntimeStats(ctx context.Context, _ *pb.GetDebugRuntimeStatsRequest) (*pb.DebugRuntimeStats, error) {
	_ = ctx

	var mem runtime.MemStats
	runtime.ReadMemStats(&mem)

	var totalNodes, onlineNodes int32
	var hubConnected bool
	hubState := "IDLE"
	hubAddr := ""
	startedAt := time.Time{}
	grpcConnections := make([]*pb.DebugGrpcConnection, 0, 8)

	s.mu.RLock()
	totalNodes = int32(len(s.nodes))
	for _, n := range s.nodes {
		if n != nil && n.GetOnline() {
			onlineNodes++
		}
	}
	hubConnected = s.hubConnected
	hubAddr = s.hubAddr
	if s.hubConn != nil {
		hubState = s.hubConn.GetState().String()
	}
	startedAt = s.startedAt
	directNodes := s.directNodes
	s.mu.RUnlock()

	var directConns int32
	if directNodes != nil {
		directNodes.mu.RLock()
		for _, c := range directNodes.clients {
			if c != nil && c.conn != nil {
				directConns++
			}
		}
		directNodes.mu.RUnlock()
	}

	var uptimeSeconds int64
	if !startedAt.IsZero() {
		uptimeSeconds = int64(time.Since(startedAt) / time.Second)
		if uptimeSeconds < 0 {
			uptimeSeconds = 0
		}
	}

	grpcConnections = append(grpcConnections, &pb.DebugGrpcConnection{
		Scope:     "hub",
		Address:   hubAddr,
		State:     hubState,
		Connected: hubConnected,
	})

	if directNodes != nil {
		directNodes.mu.RLock()
		for nodeID, c := range directNodes.clients {
			if c == nil {
				continue
			}
			c.mu.RLock()
			state := "IDLE"
			if c.conn != nil {
				state = c.conn.GetState().String()
			}
			grpcConnections = append(grpcConnections, &pb.DebugGrpcConnection{
				Scope:     "direct",
				NodeId:    nodeID,
				Address:   c.address,
				State:     state,
				Connected: c.isOnline && c.conn != nil,
			})
			c.mu.RUnlock()
		}
		directNodes.mu.RUnlock()
	}
	sort.Slice(grpcConnections, func(i, j int) bool {
		if grpcConnections[i].Scope != grpcConnections[j].Scope {
			return grpcConnections[i].Scope < grpcConnections[j].Scope
		}
		return grpcConnections[i].NodeId < grpcConnections[j].NodeId
	})

	s.approvalStreamsMu.RLock()
	approvalSubs := int32(len(s.approvalStreams))
	s.approvalStreamsMu.RUnlock()
	s.connStreamsMu.RLock()
	connSubs := int32(len(s.connStreams))
	s.connStreamsMu.RUnlock()
	s.p2pStatusStreamsMu.RLock()
	p2pSubs := int32(len(s.p2pStatusStreams))
	s.p2pStatusStreamsMu.RUnlock()

	diff := s.captureGoroutineDiffSnapshot(maxGoroutineDiffEntries)
	var diffPrevAt, diffCurrAt *timestamppb.Timestamp
	if !diff.prevAt.IsZero() {
		diffPrevAt = timestamppb.New(diff.prevAt)
	}
	if !diff.currAt.IsZero() {
		diffCurrAt = timestamppb.New(diff.currAt)
	}

	return &pb.DebugRuntimeStats{
		RssBytes:                    readSelfRSSBytes(),
		GoHeapAllocBytes:            int64(mem.HeapAlloc),
		GoHeapSysBytes:              int64(mem.HeapSys),
		GoSysBytes:                  int64(mem.Sys),
		GoTotalAllocBytes:           int64(mem.TotalAlloc),
		GoGcCount:                   int64(mem.NumGC),
		GoGoroutines:                int64(runtime.NumGoroutine()),
		GoCgoCalls:                  runtime.NumCgoCall(),
		GoHeapObjects:               int64(mem.HeapObjects),
		GoHeapInuseBytes:            int64(mem.HeapInuse),
		GoStackInuseBytes:           int64(mem.StackInuse),
		UptimeSeconds:               uptimeSeconds,
		HubConnected:                hubConnected,
		HubGrpcState:                hubState,
		TotalNodes:                  totalNodes,
		OnlineNodes:                 onlineNodes,
		DirectGrpcConnections:       directConns,
		GrpcConnections:             grpcConnections,
		ApprovalStreamSubscribers:   approvalSubs,
		ConnectionStreamSubscribers: connSubs,
		P2PStreamSubscribers:        p2pSubs,
		GoroutineDiffHasBaseline:    diff.hasBaseline,
		GoroutineDiffPrevTotal:      diff.prevTotal,
		GoroutineDiffCurrTotal:      diff.currTotal,
		GoroutineDiffDelta:          diff.delta,
		GoroutineDiffEntries:        diff.entries,
		GoroutineDiffPrevAt:         diffPrevAt,
		GoroutineDiffCurrAt:         diffCurrAt,
		GoroutineDiffTruncated:      diff.truncated,
	}, nil
}

func (s *MobileLogicService) captureGoroutineDiffSnapshot(maxEntries int) goroutineDiffSnapshot {
	if maxEntries <= 0 {
		maxEntries = maxGoroutineDiffEntries
	}

	currSnapshot, currTotal := collectGoroutineSnapshot()
	currAt := time.Now()

	s.goroutineDiffMu.Lock()
	defer s.goroutineDiffMu.Unlock()

	prevSnapshot := s.goroutineLastSnapshot
	prevTotal := s.goroutineLastTotal
	prevAt := s.goroutineLastAt
	hasBaseline := !prevAt.IsZero() && len(prevSnapshot) > 0

	diff := goroutineDiffSnapshot{
		hasBaseline: hasBaseline,
		prevTotal:   prevTotal,
		currTotal:   currTotal,
		delta:       currTotal - prevTotal,
		prevAt:      prevAt,
		currAt:      currAt,
	}

	if hasBaseline {
		diff.entries = buildGoroutineDiffEntries(prevSnapshot, currSnapshot)
		if len(diff.entries) > maxEntries {
			diff.truncated = int32(len(diff.entries) - maxEntries)
			diff.entries = diff.entries[:maxEntries]
		}
	} else {
		// First call initializes baseline only.
		diff.prevTotal = currTotal
		diff.delta = 0
	}

	s.goroutineLastSnapshot = currSnapshot
	s.goroutineLastTotal = currTotal
	s.goroutineLastAt = currAt

	return diff
}

func collectGoroutineSnapshot() (map[string]int32, int64) {
	buf := make([]byte, 1<<20)
	for {
		n := runtime.Stack(buf, true)
		if n < len(buf) {
			buf = buf[:n]
			break
		}
		if len(buf) >= 64<<20 {
			buf = buf[:n]
			break
		}
		buf = make([]byte, len(buf)*2)
	}

	snapshot := make(map[string]int32)
	var total int64
	for _, block := range strings.Split(string(buf), "\n\n") {
		lines := strings.Split(block, "\n")
		if len(lines) < 2 || !strings.HasPrefix(lines[0], "goroutine ") {
			continue
		}
		signature := strings.TrimSpace(lines[1])
		if signature == "" {
			signature = "<unknown>"
		}
		snapshot[signature]++
		total++
	}

	if total == 0 {
		total = int64(runtime.NumGoroutine())
	}
	return snapshot, total
}

func buildGoroutineDiffEntries(prev, curr map[string]int32) []*pb.DebugGoroutineDiffEntry {
	entries := make([]*pb.DebugGoroutineDiffEntry, 0, len(prev)+len(curr))

	for signature, currCount := range curr {
		prevCount := prev[signature]
		delta := currCount - prevCount
		if delta == 0 {
			continue
		}
		entries = append(entries, &pb.DebugGoroutineDiffEntry{
			Signature: signature,
			PrevCount: prevCount,
			CurrCount: currCount,
			Delta:     delta,
		})
	}

	for signature, prevCount := range prev {
		if _, ok := curr[signature]; ok {
			continue
		}
		entries = append(entries, &pb.DebugGoroutineDiffEntry{
			Signature: signature,
			PrevCount: prevCount,
			CurrCount: 0,
			Delta:     -prevCount,
		})
	}

	sort.Slice(entries, func(i, j int) bool {
		di := entries[i].Delta
		dj := entries[j].Delta
		ai := abs32(di)
		aj := abs32(dj)
		if ai != aj {
			return ai > aj
		}
		if di != dj {
			return di > dj
		}
		if entries[i].CurrCount != entries[j].CurrCount {
			return entries[i].CurrCount > entries[j].CurrCount
		}
		return entries[i].Signature < entries[j].Signature
	})

	return entries
}

func abs32(v int32) int32 {
	if v < 0 {
		return -v
	}
	return v
}

// readSelfRSSBytes reads RSS from Linux /proc for the current process.
// Returns 0 on non-Linux systems or when unavailable.
func readSelfRSSBytes() int64 {
	data, err := os.ReadFile("/proc/self/stat")
	if err != nil {
		return 0
	}
	fields := strings.Fields(string(data))
	if len(fields) < 24 {
		return 0
	}
	pages, err := strconv.ParseInt(fields[23], 10, 64)
	if err != nil {
		return 0
	}
	return pages * int64(os.Getpagesize())
}
