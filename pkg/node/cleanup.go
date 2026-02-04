package node

import (
	"sync"
	"time"

	"github.com/ivere27/nitella/pkg/config"
	"github.com/ivere27/nitella/pkg/log"
)

// CleanupTask represents a periodic cleanup task
type CleanupTask struct {
	Name     string
	Interval time.Duration
	Fn       func()

	lastRun time.Time
}

// CleanupManager consolidates periodic cleanup tasks into a single goroutine.
// Instead of spawning separate goroutines for each cleanup (rate limiter, global rules,
// approval cache, anti-replay, tarpit, etc.), register tasks here.
type CleanupManager struct {
	mu     sync.RWMutex
	tasks  []*CleanupTask
	stopCh chan struct{}
	wg     sync.WaitGroup

	// Tick interval - how often to check if any task needs to run
	tickInterval time.Duration

	// Task timeout - maximum time a single task can run before being considered hung
	taskTimeout time.Duration
}

// NewCleanupManager creates a new cleanup manager.
// tickInterval determines how often tasks are checked (default 1 second).
func NewCleanupManager(tickInterval time.Duration) *CleanupManager {
	if tickInterval <= 0 {
		tickInterval = 1 * time.Second
	}
	return &CleanupManager{
		tasks:        make([]*CleanupTask, 0),
		stopCh:       make(chan struct{}),
		tickInterval: tickInterval,
		taskTimeout:  config.DefaultTaskTimeout,
	}
}

// SetTaskTimeout sets the maximum time a task can run before being considered hung.
func (cm *CleanupManager) SetTaskTimeout(timeout time.Duration) {
	cm.taskTimeout = timeout
}

// Register adds a cleanup task. Can be called before or after Start().
func (cm *CleanupManager) Register(name string, interval time.Duration, fn func()) {
	cm.mu.Lock()
	defer cm.mu.Unlock()

	cm.tasks = append(cm.tasks, &CleanupTask{
		Name:     name,
		Interval: interval,
		Fn:       fn,
		lastRun:  time.Time{}, // Never run yet
	})
	log.Printf("[Cleanup] Registered task: %s (every %s)", name, interval)
}

// Start begins the cleanup loop. Call this once after registering initial tasks.
func (cm *CleanupManager) Start() {
	cm.wg.Add(1)
	go cm.loop()
	log.Printf("[Cleanup] Manager started with tick interval %s", cm.tickInterval)
}

// Stop stops the cleanup manager and waits for the goroutine to exit.
func (cm *CleanupManager) Stop() {
	close(cm.stopCh)
	cm.wg.Wait()
	log.Printf("[Cleanup] Manager stopped")
}

// loop is the main cleanup loop
func (cm *CleanupManager) loop() {
	defer cm.wg.Done()

	ticker := time.NewTicker(cm.tickInterval)
	defer ticker.Stop()

	for {
		select {
		case <-cm.stopCh:
			return
		case now := <-ticker.C:
			cm.runDueTasks(now)
		}
	}
}

// runDueTasks executes all tasks that are due
func (cm *CleanupManager) runDueTasks(now time.Time) {
	cm.mu.RLock()
	tasks := cm.tasks
	cm.mu.RUnlock()

	for _, task := range tasks {
		if now.Sub(task.lastRun) >= task.Interval {
			cm.runTaskWithTimeout(task)
			task.lastRun = now
		}
	}
}

// runTaskWithTimeout runs a task with a timeout to prevent one hung task from blocking others.
// If the task exceeds the timeout, it logs a warning but does NOT kill the task
// (Go doesn't support killing goroutines). The warning helps identify problematic tasks.
func (cm *CleanupManager) runTaskWithTimeout(task *CleanupTask) {
	done := make(chan struct{})
	go func() {
		task.Fn()
		close(done)
	}()

	select {
	case <-done:
		// Task completed normally
	case <-time.After(cm.taskTimeout):
		log.Printf("[Cleanup] WARN: Task '%s' exceeded timeout (%s) - may be hung or doing too much work",
			task.Name, cm.taskTimeout)
		// Wait for task to eventually complete (don't leak goroutine)
		<-done
	case <-cm.stopCh:
		// Manager is stopping, don't wait for task
		return
	}
}

// Stats returns current task statistics for debugging
func (cm *CleanupManager) Stats() []map[string]interface{} {
	cm.mu.RLock()
	defer cm.mu.RUnlock()

	stats := make([]map[string]interface{}, len(cm.tasks))
	now := time.Now()
	for i, task := range cm.tasks {
		stats[i] = map[string]interface{}{
			"name":        task.Name,
			"interval":    task.Interval.String(),
			"last_run":    task.lastRun,
			"next_run_in": (task.Interval - now.Sub(task.lastRun)).String(),
		}
	}
	return stats
}
