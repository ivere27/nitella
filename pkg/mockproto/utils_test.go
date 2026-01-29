package mockproto

import (
	"testing"
	"time"
)

func TestRandomDelay_MinMax(t *testing.T) {
	start := time.Now()
	RandomDelay(50, 100)
	elapsed := time.Since(start)

	if elapsed < 50*time.Millisecond {
		t.Errorf("Expected at least 50ms delay, got: %v", elapsed)
	}
	if elapsed > 150*time.Millisecond { // some buffer
		t.Errorf("Expected less than 150ms delay, got: %v", elapsed)
	}
}

func TestRandomDelay_MinEqualsMax(t *testing.T) {
	start := time.Now()
	RandomDelay(50, 50)
	elapsed := time.Since(start)

	if elapsed < 50*time.Millisecond {
		t.Errorf("Expected at least 50ms delay, got: %v", elapsed)
	}
}

func TestRandomDelay_MinGreaterThanMax(t *testing.T) {
	// When min >= max, should use min
	start := time.Now()
	RandomDelay(100, 50)
	elapsed := time.Since(start)

	if elapsed < 100*time.Millisecond {
		t.Errorf("Expected at least 100ms delay (min), got: %v", elapsed)
	}
}

func TestNewTarpit(t *testing.T) {
	tp := NewTarpit(100, 50, 500)

	if tp.Delay != 100*time.Millisecond {
		t.Errorf("Expected initial delay 100ms, got: %v", tp.Delay)
	}
	if tp.Step != 50*time.Millisecond {
		t.Errorf("Expected step 50ms, got: %v", tp.Step)
	}
	if tp.Max != 500*time.Millisecond {
		t.Errorf("Expected max 500ms, got: %v", tp.Max)
	}
}

func TestTarpit_Sleep(t *testing.T) {
	tp := NewTarpit(10, 10, 50)

	start := time.Now()
	tp.Sleep()
	elapsed := time.Since(start)

	if elapsed < 10*time.Millisecond {
		t.Errorf("Expected at least 10ms delay, got: %v", elapsed)
	}

	// Delay should increase
	if tp.Delay != 20*time.Millisecond {
		t.Errorf("Expected delay to increase to 20ms, got: %v", tp.Delay)
	}
}

func TestTarpit_MaxDelay(t *testing.T) {
	tp := NewTarpit(10, 100, 50)

	// First sleep: 10ms, delay becomes 110ms but capped at 50ms
	tp.Sleep()

	if tp.Delay != 50*time.Millisecond {
		t.Errorf("Expected delay to be capped at 50ms, got: %v", tp.Delay)
	}

	// Second sleep should still be capped
	tp.Sleep()
	if tp.Delay != 50*time.Millisecond {
		t.Errorf("Expected delay to remain at 50ms, got: %v", tp.Delay)
	}
}

func TestTarpit_IncreasingDelays(t *testing.T) {
	tp := NewTarpit(10, 10, 100)

	delays := []time.Duration{
		10 * time.Millisecond,
		20 * time.Millisecond,
		30 * time.Millisecond,
		40 * time.Millisecond,
	}

	for i, expected := range delays {
		if tp.Delay != expected {
			t.Errorf("Iteration %d: expected delay %v, got: %v", i, expected, tp.Delay)
		}
		tp.Sleep()
	}
}

func TestDripWrite(t *testing.T) {
	conn := newMockConn([]byte{})
	data := []byte("Hello")

	start := time.Now()
	err := DripWrite(conn, data, 5) // 5ms per byte
	elapsed := time.Since(start)

	if err != nil {
		t.Fatalf("DripWrite failed: %v", err)
	}

	// 5 bytes * 5ms = 25ms minimum
	if elapsed < 20*time.Millisecond {
		t.Errorf("Expected at least 20ms for drip write, got: %v", elapsed)
	}

	// Verify data was written
	if string(conn.writeData) != "Hello" {
		t.Errorf("Expected 'Hello', got: %s", string(conn.writeData))
	}
}

func TestDripWrite_ZeroInterval(t *testing.T) {
	conn := newMockConn([]byte{})
	data := []byte("Fast")

	err := DripWrite(conn, data, 0) // 0ms interval

	if err != nil {
		t.Fatalf("DripWrite failed: %v", err)
	}

	if string(conn.writeData) != "Fast" {
		t.Errorf("Expected 'Fast', got: %s", string(conn.writeData))
	}
}

func TestDripWrite_EmptyData(t *testing.T) {
	conn := newMockConn([]byte{})

	err := DripWrite(conn, []byte{}, 10)

	if err != nil {
		t.Fatalf("DripWrite failed: %v", err)
	}

	if len(conn.writeData) != 0 {
		t.Errorf("Expected empty write, got: %d bytes", len(conn.writeData))
	}
}

func TestDripWrite_SingleByte(t *testing.T) {
	conn := newMockConn([]byte{})

	err := DripWrite(conn, []byte("X"), 1)

	if err != nil {
		t.Fatalf("DripWrite failed: %v", err)
	}

	if string(conn.writeData) != "X" {
		t.Errorf("Expected 'X', got: %s", string(conn.writeData))
	}
}

func TestHoldOpen_ClientDisconnect(t *testing.T) {
	// HoldOpen reads until error (client disconnect)
	// Our mock conn returns error after reading all data
	// Note: HoldOpen has a 1-second sleep between reads, so we need longer timeout
	conn := newMockConn([]byte("some data"))

	done := make(chan bool)
	go func() {
		HoldOpen(conn)
		done <- true
	}()

	select {
	case <-done:
		// HoldOpen returned (client disconnected)
	case <-time.After(2 * time.Second):
		t.Error("HoldOpen did not return after client disconnect")
	}
}

func TestHoldOpen_EmptyRead(t *testing.T) {
	// Empty mock conn simulates immediate disconnect
	conn := newMockConn([]byte{})

	done := make(chan bool)
	go func() {
		HoldOpen(conn)
		done <- true
	}()

	select {
	case <-done:
		// Expected
	case <-time.After(500 * time.Millisecond):
		t.Error("HoldOpen did not return")
	}
}
