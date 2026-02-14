package service

import (
	"fmt"
	"testing"

	pb "github.com/ivere27/nitella/pkg/api/local"
)

func makeProxyList(count int) []*pb.ProxyInfo {
	proxies := make([]*pb.ProxyInfo, 0, count)
	for i := 0; i < count; i++ {
		proxies = append(proxies, &pb.ProxyInfo{
			ProxyId: fmt.Sprintf("proxy-%02d", i),
		})
	}
	return proxies
}

func TestPaginateProxiesDefaultLimit(t *testing.T) {
	proxies := makeProxyList(8)
	paged := paginateProxies(proxies, 2, 0, 1000)
	if got, want := len(paged), 6; got != want {
		t.Fatalf("unexpected paged size: got=%d want=%d", got, want)
	}
	if got, want := paged[0].GetProxyId(), "proxy-02"; got != want {
		t.Fatalf("unexpected first item: got=%q want=%q", got, want)
	}
}

func TestPaginateProxiesClampsLimitToMax(t *testing.T) {
	proxies := makeProxyList(20)
	paged := paginateProxies(proxies, 0, 9999, 5)
	if got, want := len(paged), 5; got != want {
		t.Fatalf("unexpected paged size: got=%d want=%d", got, want)
	}
}

func TestPaginateProxiesOffsetBeyondRange(t *testing.T) {
	proxies := makeProxyList(10)
	paged := paginateProxies(proxies, 20, 5, 1000)
	if got := len(paged); got != 0 {
		t.Fatalf("expected empty page, got=%d items", got)
	}
}

func TestPaginateProxiesNegativeOffset(t *testing.T) {
	proxies := makeProxyList(10)
	paged := paginateProxies(proxies, -7, 3, 1000)
	if got, want := len(paged), 3; got != want {
		t.Fatalf("unexpected paged size: got=%d want=%d", got, want)
	}
	if got, want := paged[0].GetProxyId(), "proxy-00"; got != want {
		t.Fatalf("unexpected first item: got=%q want=%q", got, want)
	}
}
