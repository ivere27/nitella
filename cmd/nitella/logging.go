package main

import (
	"io"
	"log"
	"os"
	"strings"
	"sync"

	"github.com/ivere27/nitella/pkg/shell"
)

// replAwareLogWriter routes newline-terminated log lines to the active REPL.
// When no REPL is active (or non-interactive mode), it falls back to stderr.
type replAwareLogWriter struct {
	fallback io.Writer

	mu  sync.Mutex
	buf string
}

func newREPLAwareLogWriter(fallback io.Writer) *replAwareLogWriter {
	if fallback == nil {
		fallback = os.Stderr
	}
	return &replAwareLogWriter{fallback: fallback}
}

func (w *replAwareLogWriter) Write(p []byte) (int, error) {
	w.mu.Lock()
	defer w.mu.Unlock()

	w.buf += string(p)
	for {
		idx := strings.IndexByte(w.buf, '\n')
		if idx < 0 {
			break
		}
		line := strings.TrimSuffix(w.buf[:idx], "\r")
		w.buf = w.buf[idx+1:]
		if !shell.NotifyActive(line) {
			if _, err := io.WriteString(w.fallback, line+"\n"); err != nil {
				return len(p), err
			}
		}
	}
	return len(p), nil
}

func configureCLILogOutput() {
	log.SetOutput(newREPLAwareLogWriter(os.Stderr))
}
