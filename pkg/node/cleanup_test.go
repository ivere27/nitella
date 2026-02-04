package node

import (
	"sync/atomic"
	"testing"
	"time"
)

func TestCleanupManager_Basic(t *testing.T) {
	cm := NewCleanupManager(10 * time.Millisecond)

	var counter int32
	cm.Register("test-task", 50*time.Millisecond, func() {
		atomic.AddInt32(&counter, 1)
	})

	cm.Start()
	defer cm.Stop()

	// Wait for task to run at least twice
	time.Sleep(150 * time.Millisecond)

	count := atomic.LoadInt32(&counter)
	if count < 2 {
		t.Errorf("Expected task to run at least 2 times, got %d", count)
	}
}

func TestCleanupManager_MultipleTasksDifferentIntervals(t *testing.T) {
	cm := NewCleanupManager(10 * time.Millisecond)

	var fastCounter, slowCounter int32
	cm.Register("fast-task", 30*time.Millisecond, func() {
		atomic.AddInt32(&fastCounter, 1)
	})
	cm.Register("slow-task", 100*time.Millisecond, func() {
		atomic.AddInt32(&slowCounter, 1)
	})

	cm.Start()
	defer cm.Stop()

	time.Sleep(250 * time.Millisecond)

	fast := atomic.LoadInt32(&fastCounter)
	slow := atomic.LoadInt32(&slowCounter)

	// Fast task should run more often than slow task
	if fast <= slow {
		t.Errorf("Fast task (%d) should run more often than slow task (%d)", fast, slow)
	}

	// Slow task should run at least twice
	if slow < 2 {
		t.Errorf("Slow task should run at least 2 times, got %d", slow)
	}
}

func TestCleanupManager_TaskTimeout(t *testing.T) {
	cm := NewCleanupManager(10 * time.Millisecond)
	cm.SetTaskTimeout(50 * time.Millisecond)

	var completed int32
	cm.Register("slow-task", 20*time.Millisecond, func() {
		time.Sleep(30 * time.Millisecond) // Under timeout
		atomic.AddInt32(&completed, 1)
	})

	cm.Start()
	defer cm.Stop()

	time.Sleep(100 * time.Millisecond)

	count := atomic.LoadInt32(&completed)
	if count < 1 {
		t.Errorf("Task should have completed at least once, got %d", count)
	}
}

func TestCleanupManager_StopIsGraceful(t *testing.T) {
	cm := NewCleanupManager(10 * time.Millisecond)

	var counter int32
	cm.Register("test-task", 20*time.Millisecond, func() {
		atomic.AddInt32(&counter, 1)
	})

	cm.Start()

	// Let some tasks run
	time.Sleep(100 * time.Millisecond)

	// Stop should return quickly (not hang)
	done := make(chan struct{})
	go func() {
		cm.Stop()
		close(done)
	}()

	select {
	case <-done:
		// Good - Stop returned
	case <-time.After(1 * time.Second):
		t.Error("Stop() took too long, possible hang")
	}

	// Tasks should have run
	count := atomic.LoadInt32(&counter)
	if count < 2 {
		t.Errorf("Expected at least 2 task runs, got %d", count)
	}
}

func TestCleanupManager_Stats(t *testing.T) {
	cm := NewCleanupManager(10 * time.Millisecond)

	cm.Register("task-a", 100*time.Millisecond, func() {})
	cm.Register("task-b", 200*time.Millisecond, func() {})

	stats := cm.Stats()
	if len(stats) != 2 {
		t.Errorf("Expected 2 tasks in stats, got %d", len(stats))
	}

	// Check task names
	names := make(map[string]bool)
	for _, s := range stats {
		names[s["name"].(string)] = true
	}
	if !names["task-a"] || !names["task-b"] {
		t.Errorf("Expected task-a and task-b in stats, got %v", names)
	}
}

func TestCleanupManager_RegisterAfterStart(t *testing.T) {
	cm := NewCleanupManager(10 * time.Millisecond)
	cm.Start()
	defer cm.Stop()

	var counter int32
	// Register after start should work
	cm.Register("late-task", 30*time.Millisecond, func() {
		atomic.AddInt32(&counter, 1)
	})

	time.Sleep(100 * time.Millisecond)

	count := atomic.LoadInt32(&counter)
	if count < 2 {
		t.Errorf("Late-registered task should run at least 2 times, got %d", count)
	}
}
