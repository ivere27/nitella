//go:build !linux

package stream

import (
	"io"
)

// SpliceProxy is a stub for non-Linux systems. It falls back to UserspaceCopy.
func SpliceProxy(dst io.Writer, src io.Reader, written *int64) (int64, error) {
	return UserspaceCopy(dst, src, written)
}
