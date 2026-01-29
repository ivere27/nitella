package shell

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"strings"
	"time"
	"unicode"

	"golang.org/x/term"
)

// CompletionProvider provides context-aware tab completion suggestions.
type CompletionProvider interface {
	// GetSuggestions returns completion options based on the previous word and full context.
	GetSuggestions(prev string, parts []string) []string
}

// REPL provides an interactive command line with tab completion.
type REPL struct {
	Prompt     string
	Completion CompletionProvider
	history    []string
	historyIdx int
	lastCtrlC  time.Time
}

// NewREPL creates a new REPL with the given prompt and completion provider.
func NewREPL(prompt string, completion CompletionProvider) *REPL {
	return &REPL{
		Prompt:     prompt,
		Completion: completion,
		history:    make([]string, 0),
		historyIdx: -1,
	}
}

// errCtrlCExit is returned when user double-presses Ctrl+C
var errCtrlCExit = fmt.Errorf("ctrl-c exit")

// Run starts the REPL loop, calling handler for each command.
func (r *REPL) Run(handler func(string) error) {
	fd := int(os.Stdin.Fd())
	if !term.IsTerminal(fd) {
		// Fallback to basic scanner if not a terminal
		scanner := bufio.NewScanner(os.Stdin)
		fmt.Print(r.Prompt)
		for scanner.Scan() {
			line := strings.TrimSpace(scanner.Text())
			if line == "" {
				fmt.Print(r.Prompt)
				continue
			}
			if line == "exit" || line == "quit" {
				return
			}
			handler(line)
			fmt.Print(r.Prompt)
		}
		return
	}

	oldState, err := term.MakeRaw(fd)
	if err != nil {
		fmt.Printf("Error entering raw mode: %v\n", err)
		return
	}
	defer term.Restore(fd, oldState)

	for {
		line, err := r.readLine()
		if err != nil {
			if err == io.EOF || err == errCtrlCExit {
				fmt.Print("\r\n")
				return
			}
			break
		}

		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}

		// Add to history
		if len(r.history) == 0 || r.history[len(r.history)-1] != line {
			r.history = append(r.history, line)
		}
		r.historyIdx = len(r.history)

		if line == "exit" || line == "quit" {
			break
		}

		// Restore cooked mode for execution
		term.Restore(fd, oldState)

		if err := handler(line); err != nil {
			fmt.Printf("Error: %v\n", err)
		}

		// Re-enter raw mode
		term.MakeRaw(fd)
	}
}

// readLine reads a line with full editing support
func (r *REPL) readLine() (string, error) {
	var line []rune
	pos := 0
	savedLine := ""

	r.printPrompt(line, pos)

	buf := make([]byte, 32)
	for {
		n, err := os.Stdin.Read(buf)
		if err != nil {
			return "", err
		}

		i := 0
		for i < n {
			b := buf[i]
			i++

			switch b {
			case 0x03: // Ctrl+C
				now := time.Now()
				if now.Sub(r.lastCtrlC) < 500*time.Millisecond {
					// Double Ctrl+C - exit
					fmt.Print("^C\r\n")
					return "", errCtrlCExit
				}
				r.lastCtrlC = now
				fmt.Print("^C (Press Ctrl+C again to exit)\r\n")
				line = nil
				pos = 0
				r.printPrompt(line, pos)

			case 0x04: // Ctrl+D
				if len(line) == 0 {
					return "", io.EOF
				}

			case 0x0D, 0x0A: // Enter
				fmt.Print("\r\n")
				return string(line), nil

			case 0x7F, 0x08: // Backspace
				if pos > 0 {
					line = append(line[:pos-1], line[pos:]...)
					pos--
					r.printPrompt(line, pos)
				}

			case 0x17: // Ctrl+W - delete word backward
				if pos > 0 {
					newPos := r.findWordStart(line, pos)
					line = append(line[:newPos], line[pos:]...)
					pos = newPos
					r.printPrompt(line, pos)
				}

			case 0x15: // Ctrl+U - delete to start
				line = line[pos:]
				pos = 0
				r.printPrompt(line, pos)

			case 0x0B: // Ctrl+K - delete to end
				line = line[:pos]
				r.printPrompt(line, pos)

			case 0x01: // Ctrl+A - go to start
				pos = 0
				r.printPrompt(line, pos)

			case 0x05: // Ctrl+E - go to end
				pos = len(line)
				r.printPrompt(line, pos)

			case 0x0C: // Ctrl+L - clear screen
				fmt.Print("\x1b[2J\x1b[H")
				r.printPrompt(line, pos)

			case 0x09: // Tab - autocomplete
				line, pos = r.autoComplete(line, pos)
				r.printPrompt(line, pos)

			case 0x1B: // Escape sequence
				if i >= n {
					continue
				}

				// Alt+Backspace (ESC + DEL or ESC + BS) - delete word backward
				if buf[i] == 0x7F || buf[i] == 0x08 {
					i++
					if pos > 0 {
						newPos := r.findWordStart(line, pos)
						line = append(line[:newPos], line[pos:]...)
						pos = newPos
						r.printPrompt(line, pos)
					}
					continue
				}

				if buf[i] != '[' {
					i++
					continue
				}
				i++

				// Parse escape sequence
				seq := ""
				for i < n && ((buf[i] >= '0' && buf[i] <= '9') || buf[i] == ';') {
					seq += string(buf[i])
					i++
				}
				if i >= n {
					continue
				}
				finalByte := buf[i]
				i++

				switch finalByte {
				case 'A': // Up arrow
					if r.historyIdx > 0 {
						if r.historyIdx == len(r.history) {
							savedLine = string(line)
						}
						r.historyIdx--
						line = []rune(r.history[r.historyIdx])
						pos = len(line)
						r.printPrompt(line, pos)
					}

				case 'B': // Down arrow
					if r.historyIdx < len(r.history) {
						r.historyIdx++
						if r.historyIdx == len(r.history) {
							line = []rune(savedLine)
						} else {
							line = []rune(r.history[r.historyIdx])
						}
						pos = len(line)
						r.printPrompt(line, pos)
					}

				case 'C': // Right arrow
					if seq == "1;5" || seq == "1;3" {
						// Ctrl+Right or Alt+Right - move to next word
						pos = r.findWordEnd(line, pos)
					} else {
						if pos < len(line) {
							pos++
						}
					}
					r.printPrompt(line, pos)

				case 'D': // Left arrow
					if seq == "1;5" || seq == "1;3" {
						// Ctrl+Left or Alt+Left - move to previous word
						pos = r.findWordStart(line, pos)
					} else {
						if pos > 0 {
							pos--
						}
					}
					r.printPrompt(line, pos)

				case 'H': // Home
					pos = 0
					r.printPrompt(line, pos)

				case 'F': // End
					pos = len(line)
					r.printPrompt(line, pos)

				case '~':
					switch seq {
					case "1": // Home
						pos = 0
						r.printPrompt(line, pos)
					case "3": // Delete
						if pos < len(line) {
							line = append(line[:pos], line[pos+1:]...)
							r.printPrompt(line, pos)
						}
					case "4": // End
						pos = len(line)
						r.printPrompt(line, pos)
					}
				}

			default:
				if b >= 0x20 && b < 0x7F {
					// Printable ASCII - skip leading whitespace
					if len(line) == 0 && (b == ' ' || b == '\t') {
						continue
					}
					line = append(line[:pos], append([]rune{rune(b)}, line[pos:]...)...)
					pos++
					r.printPrompt(line, pos)
				} else if b >= 0xC0 {
					// UTF-8 multi-byte sequence
					width := 1
					if b >= 0xF0 {
						width = 4
					} else if b >= 0xE0 {
						width = 3
					} else if b >= 0xC0 {
						width = 2
					}
					if i+width-1 <= n {
						ch, _ := decodeUTF8(buf[i-1 : i-1+width])
						line = append(line[:pos], append([]rune{ch}, line[pos:]...)...)
						pos++
						i += width - 1
						r.printPrompt(line, pos)
					}
				}
			}
		}
	}
}

// findWordStart finds the start of the current/previous word
func (r *REPL) findWordStart(line []rune, pos int) int {
	if pos == 0 {
		return 0
	}
	// Skip whitespace going backward
	i := pos - 1
	for i > 0 && unicode.IsSpace(line[i]) {
		i--
	}
	// Skip word characters going backward
	for i > 0 && !unicode.IsSpace(line[i-1]) {
		i--
	}
	return i
}

// findWordEnd finds the end of the current/next word
func (r *REPL) findWordEnd(line []rune, pos int) int {
	if pos >= len(line) {
		return len(line)
	}
	// Skip whitespace going forward
	i := pos
	for i < len(line) && unicode.IsSpace(line[i]) {
		i++
	}
	// Skip word characters going forward
	for i < len(line) && !unicode.IsSpace(line[i]) {
		i++
	}
	return i
}

// printPrompt clears line and redraws prompt with cursor at correct position
func (r *REPL) printPrompt(line []rune, pos int) {
	// Move cursor to start, clear line, print prompt + line, position cursor
	fmt.Printf("\r\x1b[K%s%s", r.Prompt, string(line))
	// Move cursor to correct position
	if pos < len(line) {
		fmt.Printf("\x1b[%dD", len(line)-pos)
	}
}

// autoComplete handles tab completion
func (r *REPL) autoComplete(line []rune, pos int) ([]rune, int) {
	if r.Completion == nil {
		return line, pos
	}

	// Work with runes for correct Unicode handling
	lineRunes := line[:pos]
	lineStr := string(lineRunes)
	parts := strings.Fields(lineStr)
	isNewWord := pos > 0 && unicode.IsSpace(line[pos-1])

	var cur, prev string
	var curRuneLen int
	if isNewWord {
		cur = ""
		curRuneLen = 0
		if len(parts) > 0 {
			prev = parts[len(parts)-1]
		}
	} else {
		if len(parts) > 0 {
			cur = parts[len(parts)-1]
			curRuneLen = len([]rune(cur))
		}
		if len(parts) > 1 {
			prev = parts[len(parts)-2]
		}
	}

	options := r.Completion.GetSuggestions(prev, parts)

	var matches []string
	for _, opt := range options {
		if strings.HasPrefix(opt, cur) {
			matches = append(matches, opt)
		}
	}

	if len(matches) == 0 {
		return line, pos
	}

	if len(matches) == 1 {
		// Build new line using runes
		prefixRunes := lineRunes[:pos-curRuneLen]
		suffixRunes := line[pos:]
		matchRunes := []rune(matches[0])
		newLine := append(prefixRunes, matchRunes...)
		newLine = append(newLine, ' ')
		newLine = append(newLine, suffixRunes...)
		newPos := len(prefixRunes) + len(matchRunes) + 1
		return newLine, newPos
	}

	// Multiple matches - show options
	fmt.Print("\r\n")
	for _, m := range matches {
		fmt.Print(m + "  ")
	}
	fmt.Print("\r\n")

	// Calculate longest common prefix
	lcp := matches[0]
	for _, s := range matches[1:] {
		lcp = commonPrefix(lcp, s)
	}

	if len([]rune(lcp)) > curRuneLen {
		prefixRunes := lineRunes[:pos-curRuneLen]
		suffixRunes := line[pos:]
		lcpRunes := []rune(lcp)
		newLine := append(prefixRunes, lcpRunes...)
		newLine = append(newLine, suffixRunes...)
		newPos := len(prefixRunes) + len(lcpRunes)
		return newLine, newPos
	}

	return line, pos
}

func commonPrefix(a, b string) string {
	if len(a) > len(b) {
		a, b = b, a
	}
	for i := 0; i < len(a); i++ {
		if a[i] != b[i] {
			return a[:i]
		}
	}
	return a
}

func decodeUTF8(b []byte) (rune, int) {
	if len(b) == 0 {
		return 0, 0
	}
	if b[0] < 0x80 {
		return rune(b[0]), 1
	}
	if b[0] < 0xC0 {
		return 0, 1
	}
	if b[0] < 0xE0 {
		if len(b) < 2 {
			return 0, 1
		}
		return rune(b[0]&0x1F)<<6 | rune(b[1]&0x3F), 2
	}
	if b[0] < 0xF0 {
		if len(b) < 3 {
			return 0, 1
		}
		return rune(b[0]&0x0F)<<12 | rune(b[1]&0x3F)<<6 | rune(b[2]&0x3F), 3
	}
	if len(b) < 4 {
		return 0, 1
	}
	return rune(b[0]&0x07)<<18 | rune(b[1]&0x3F)<<12 | rune(b[2]&0x3F)<<6 | rune(b[3]&0x3F), 4
}

// StartREPL is a convenience function to start a REPL with the given prompt and handler.
// It uses a simple completion provider that can be configured via SetCompletions.
func StartREPL(prompt string, handler func(string) error, completions CompletionProvider) {
	repl := NewREPL(prompt, completions)
	repl.Run(handler)
}
