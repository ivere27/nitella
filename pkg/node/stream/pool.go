package stream

import (
	"sync"
)

// bufferPool recycles byte slices to reduce GC pressure.
// We use 32KB buffers, which match the default io.Copy buffer size
// and fit well within CPU L1/L2 caches.
var bufferPool = sync.Pool{
	New: func() interface{} {
		// 32KB buffer
		return make([]byte, 32*1024)
	},
}

// GetBuffer returns a buffer from the pool.
func GetBuffer() []byte {
	return bufferPool.Get().([]byte)
}

// PutBuffer returns a buffer to the pool.
func PutBuffer(b []byte) {
	bufferPool.Put(b)
}
