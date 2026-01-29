package mockproto

import (
	"math/rand/v2"
	"net"
	"time"
)

// RandomDelay sleeps for a random duration between minMs and maxMs
func RandomDelay(minMs, maxMs int) {
	if minMs >= maxMs {
		time.Sleep(time.Duration(minMs) * time.Millisecond)
		return
	}
	delta := maxMs - minMs
	r := rand.IntN(delta)
	time.Sleep(time.Duration(minMs+r) * time.Millisecond)
}

// Tarpit manages increasing delays for DDoS-like mocking
type Tarpit struct {
	Delay time.Duration
	Step  time.Duration
	Max   time.Duration
}

func NewTarpit(startMs, stepMs, maxMs int) *Tarpit {
	return &Tarpit{
		Delay: time.Duration(startMs) * time.Millisecond,
		Step:  time.Duration(stepMs) * time.Millisecond,
		Max:   time.Duration(maxMs) * time.Millisecond,
	}
}

func (t *Tarpit) Sleep() {
	time.Sleep(t.Delay)
	t.Delay += t.Step
	if t.Delay > t.Max {
		t.Delay = t.Max
	}
}

// DripWrite sends data byte-by-byte with a delay
func DripWrite(conn net.Conn, data []byte, intervalMs int) error {
	interval := time.Duration(intervalMs) * time.Millisecond
	for _, b := range data {
		if _, err := conn.Write([]byte{b}); err != nil {
			return err
		}
		if interval > 0 {
			time.Sleep(interval)
		}
	}
	return nil
}

// HoldOpen keeps a connection open indefinitely but with proper timeouts
// to prevent goroutine leaks from idle connections
func HoldOpen(conn net.Conn) {
	// Read until error (client disconnects)
	// We don't care about the data
	buf := make([]byte, 1024)
	for {
		// Set read deadline to prevent indefinite blocking
		// 5 minute timeout - long enough for tarpit, short enough to clean up dead connections
		conn.SetReadDeadline(time.Now().Add(5 * time.Minute))
		if _, err := conn.Read(buf); err != nil {
			return
		}
		// Slow down read loop to avoid CPU spin if client spams
		time.Sleep(1 * time.Second)
	}
}
