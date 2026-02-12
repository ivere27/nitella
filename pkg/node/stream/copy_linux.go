//go:build linux

package stream

import (
	"io"
	"net"
	"sync/atomic"
	"syscall"
)

// Define Splice flags if not available in syscall package on some archs/versions
const (
	SPLICE_F_MOVE     = 0x01
	SPLICE_F_NONBLOCK = 0x02
	SPLICE_F_MORE     = 0x04
	SPLICE_F_GIFT     = 0x08
)

// SpliceProxy copies data from src to dst using the Linux splice syscall (Zero-Copy).
// It bypasses userspace memory, reducing CPU usage and GC pressure.
//
// Returns the number of bytes copied and any error occurred.
func SpliceProxy(dst io.Writer, src io.Reader, written *int64) (int64, error) {
	// 1. Unwrap to get raw file descriptors
	// We need *net.TCPConn to access the SyscallConn
	srcTCP, srcOK := asTCPConn(src)
	dstTCP, dstOK := asTCPConn(dst)

	// If either side is not a TCP connection (e.g. TLS, Mock, Buffer), fallback to userspace copy
	if !srcOK || !dstOK {
		return UserspaceCopy(dst, src, written)
	}

	// 2. Get Raw FDs
	srcRC, err := srcTCP.SyscallConn()
	if err != nil {
		return UserspaceCopy(dst, src, written)
	}
	dstRC, err := dstTCP.SyscallConn()
	if err != nil {
		return UserspaceCopy(dst, src, written)
	}

	var total int64
	var errS error

	// 3. Create a pipe for splicing
	// splice() moves data: FD_IN -> PIPE -> FD_OUT
	// We need a temporary pipe.
	var pipe [2]int
	if err := syscall.Pipe2(pipe[:], syscall.O_CLOEXEC|syscall.O_NONBLOCK); err != nil {
		return UserspaceCopy(dst, src, written)
	}
	defer syscall.Close(pipe[0])
	defer syscall.Close(pipe[1])

	// Max splice size (usually 1MB or pipe size 64KB)
	const maxSplice = 1 << 20

	// We need to handle the loop manually since we are using raw FDs
	// and need to respect Go's non-blocking I/O runtime (epoll).
	for {
		var n int64
		var readErr, writeErr error

		// Step A: Splice from SRC to PIPE
		readErr = srcRC.Read(func(fd uintptr) bool {
			n, errS = syscall.Splice(int(fd), nil, pipe[1], nil, maxSplice, SPLICE_F_MOVE|SPLICE_F_NONBLOCK)
			if errS == syscall.EAGAIN {
				return false // Wait for read readiness
			}
			return true
		})

		if readErr != nil {
			return total, readErr
		}
		if errS != nil {
			return total, errS
		}
		if n == 0 {
			// EOF
			return total, nil
		}

		// Step B: Splice from PIPE to DST
		// We must write all 'n' bytes we just read into the pipe
		remain := n
		for remain > 0 {
			var writtenChunk int64 // Define outside closure to capture result
			
			writeErr = dstRC.Write(func(fd uintptr) bool {
				writtenChunk, errS = syscall.Splice(pipe[0], nil, int(fd), nil, int(remain), SPLICE_F_MOVE|SPLICE_F_NONBLOCK)
				if errS == syscall.EAGAIN {
					return false // Wait for write readiness
				}
				return true
			})

			if writeErr != nil {
				return total, writeErr
			}
			if errS != nil {
				return total, errS
			}
			remain -= int64(writtenChunk)
		}

		// Update stats
		total += n
		if written != nil {
			atomic.AddInt64(written, n)
		}
	}
}

// asTCPConn attempts to extract the underlying *net.TCPConn
func asTCPConn(i interface{}) (*net.TCPConn, bool) {
	// Handle wrapped interfaces (like CountingReader)
	// This requires the wrapper to expose the underlying connection or Unwrapper interface
	// For now, we check direct type assertions.
	// In the future, we should add an Unwrap() method to CountingReader.
	switch v := i.(type) {
	case *net.TCPConn:
		return v, true
	default:
		return nil, false
	}
}