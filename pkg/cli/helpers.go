// Package cli provides common CLI utilities for nitella commands.
package cli

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"
)

// DefaultAPITimeout is the default timeout for API calls.
const DefaultAPITimeout = 5 * time.Second

// WithTimeout creates a context with the specified timeout.
func WithTimeout(timeout time.Duration) (context.Context, context.CancelFunc) {
	return context.WithTimeout(context.Background(), timeout)
}

// WithAPITimeout creates a context with the default API timeout (5 seconds).
func WithAPITimeout() (context.Context, context.CancelFunc) {
	return WithTimeout(DefaultAPITimeout)
}

// RequireArgs validates that args has at least min elements.
// If not, it prints the usage message and returns false.
func RequireArgs(args []string, min int, usage string) bool {
	if len(args) < min {
		fmt.Println(usage)
		return false
	}
	return true
}

// ParseDuration parses a string as an int64 duration in seconds.
// If the string is empty or parsing fails, returns defaultVal.
// Returns an error only if parsing fails on a non-empty string (for warning purposes).
func ParseDuration(s string, defaultVal int64) (int64, error) {
	if s == "" {
		return defaultVal, nil
	}
	d, err := strconv.ParseInt(s, 10, 64)
	if err != nil {
		return defaultVal, fmt.Errorf("invalid duration '%s'", s)
	}
	return d, nil
}

// SuccessResponse is an interface for responses that have success/error fields.
type SuccessResponse interface {
	GetSuccess() bool
	GetErrorMessage() string
}

// CheckResponse checks if a response indicates success.
// If not successful, it prints the error message and returns false.
func CheckResponse(resp SuccessResponse) bool {
	if !resp.GetSuccess() {
		fmt.Printf("Failed: %s\n", resp.GetErrorMessage())
		return false
	}
	return true
}

// CheckResponseWithField checks if a response indicates success using explicit values.
// This is useful for responses that use different field names (e.g., Error vs ErrorMessage).
func CheckResponseWithField(success bool, errMsg string) bool {
	if !success {
		fmt.Printf("Failed: %s\n", errMsg)
		return false
	}
	return true
}

// WaitForShutdown blocks until SIGINT or SIGTERM is received,
// then calls the cleanup function.
func WaitForShutdown(cleanup func()) {
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGINT, syscall.SIGTERM)
	<-sigCh
	if cleanup != nil {
		cleanup()
	}
}

// WaitForShutdownContext cancels the context when SIGINT or SIGTERM is received.
// It also registers signal cleanup so the goroutine doesn't leak.
func WaitForShutdownContext(ctx context.Context, cancel context.CancelFunc) {
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGINT)
	go func() {
		select {
		case <-sigCh:
			cancel()
		case <-ctx.Done():
		}
		signal.Stop(sigCh)
	}()
}
