package stream

import (
	"io"
	"sync/atomic"
)

// UserspaceCopy performs a copy using a pooled userspace buffer.
// This is the fallback for non-Linux systems or non-TCP connections (TLS).
func UserspaceCopy(dst io.Writer, src io.Reader, written *int64) (int64, error) {
	buf := GetBuffer()
	defer PutBuffer(buf)

	var total int64
	for {
		nr, er := src.Read(buf)
		if nr > 0 {
			nw, ew := dst.Write(buf[0:nr])
			if nw > 0 {
				n := int64(nw)
				total += n
				if written != nil {
					atomic.AddInt64(written, n)
				}
			}
			if ew != nil {
				return total, ew
			}
			if nr != nw {
				return total, io.ErrShortWrite
			}
		}
		if er != nil {
			if er == io.EOF {
				er = nil
			}
			return total, er
		}
	}
}
