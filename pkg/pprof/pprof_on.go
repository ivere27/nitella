//go:build pprof

package pprof

import (
	"fmt"
	"net/http"
	_ "net/http/pprof"
	"os"
	"runtime"

	"github.com/ivere27/nitella/pkg/log"
)

// Start launches a pprof HTTP server on the given port.
// If port <= 0, this is a no-op.
func Start(port int) {
	if port <= 0 {
		return
	}
	addr := fmt.Sprintf(":%d", port)

	http.HandleFunc("/debug/goroutines", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "%d", runtime.NumGoroutine())
	})

	http.HandleFunc("/debug/memstats", func(w http.ResponseWriter, r *http.Request) {
		var m runtime.MemStats
		runtime.ReadMemStats(&m)
		fmt.Fprintf(w, "Alloc: %d\n", m.Alloc)
		fmt.Fprintf(w, "TotalAlloc: %d\n", m.TotalAlloc)
		fmt.Fprintf(w, "Sys: %d\n", m.Sys)
		fmt.Fprintf(w, "HeapAlloc: %d\n", m.HeapAlloc)
		fmt.Fprintf(w, "HeapInuse: %d\n", m.HeapInuse)
		fmt.Fprintf(w, "HeapIdle: %d\n", m.HeapIdle)
		fmt.Fprintf(w, "HeapReleased: %d\n", m.HeapReleased)
		fmt.Fprintf(w, "HeapObjects: %d\n", m.HeapObjects)
		fmt.Fprintf(w, "NumGC: %d\n", m.NumGC)
		fmt.Fprintf(w, "NumGoroutine: %d\n", runtime.NumGoroutine())
		fmt.Fprintf(w, "PID: %d\n", os.Getpid())
	})

	go func() {
		log.Printf("pprof server listening on %s", addr)
		if err := http.ListenAndServe(addr, nil); err != nil {
			log.Printf("pprof server error: %v", err)
		}
	}()
}
