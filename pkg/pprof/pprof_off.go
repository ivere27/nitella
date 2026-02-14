//go:build !pprof

package pprof

// Start is a no-op when built without the pprof tag.
func Start(port int) {}
