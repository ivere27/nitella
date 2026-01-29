package shell

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"syscall"
	"time"

	"golang.org/x/term"
)

// FormatBytes formats bytes into human-readable string (KB, MB, GB, etc.)
func FormatBytes(b int64) string {
	const unit = 1024
	if b < unit {
		return fmt.Sprintf("%d B", b)
	}
	div, exp := int64(unit), 0
	for n := b / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %cB", float64(b)/float64(div), "KMGTPE"[exp])
}

// FormatDuration formats duration into human-readable string (e.g., "2d 5h 30m")
func FormatDuration(d time.Duration) string {
	days := int(d.Hours() / 24)
	hours := int(d.Hours()) % 24
	mins := int(d.Minutes()) % 60

	if days > 0 {
		return fmt.Sprintf("%dd %dh %dm", days, hours, mins)
	}
	if hours > 0 {
		return fmt.Sprintf("%dh %dm", hours, mins)
	}
	return fmt.Sprintf("%dm", mins)
}

// Truncate truncates a string to maxLen, adding "..." if truncated.
func Truncate(s string, maxLen int) string {
	if len(s) <= maxLen {
		return s
	}
	if maxLen < 4 {
		return s[:maxLen]
	}
	return s[:maxLen-3] + "..."
}

// PromptConfirm prompts the user for a yes/no confirmation.
// Returns true if user confirms with "y" or "yes".
// Requires interactive TTY unless NITELLA_CLI_TEST_MODE=1.
func PromptConfirm(msg string) bool {
	// Bypass for testing
	if os.Getenv("NITELLA_CLI_TEST_MODE") == "1" {
		return true
	}

	// Anti-Scripting: Require TTY
	if !term.IsTerminal(int(syscall.Stdin)) {
		fmt.Println(Red + "Error: Security prompt requires interactive terminal (TTY)." + Reset)
		fmt.Println("Automated inputs (pipes, scripts) are blocked for security.")
		return false
	}

	fmt.Printf("%s [y/N]: ", msg)
	scanner := bufio.NewScanner(os.Stdin)
	if scanner.Scan() {
		input := strings.ToLower(strings.TrimSpace(scanner.Text()))
		return input == "y" || input == "yes"
	}
	return false
}

// PromptInput prompts the user for input with the given message.
func PromptInput(msg string) string {
	fmt.Print(msg)
	reader := bufio.NewReader(os.Stdin)
	input, _ := reader.ReadString('\n')
	return strings.TrimSpace(input)
}

// PromptPassword prompts for a password without echoing.
func PromptPassword(msg string) (string, error) {
	fmt.Print(msg)
	password, err := term.ReadPassword(int(syscall.Stdin))
	fmt.Println() // New line after password input
	if err != nil {
		return "", err
	}
	return string(password), nil
}

// ClearScreen clears the terminal screen.
func ClearScreen() {
	fmt.Print("\033[H\033[2J")
}

// Contains checks if a string slice contains the given item.
func Contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}

// stripANSI removes ANSI escape codes from a string.
func stripANSI(s string) string {
	result := strings.Builder{}
	inEscape := false
	for _, r := range s {
		if r == '\x1b' {
			inEscape = true
			continue
		}
		if inEscape {
			if (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') {
				inEscape = false
			}
			continue
		}
		result.WriteRune(r)
	}
	return result.String()
}

// visibleLen returns the visible length of a string (excluding ANSI codes).
func visibleLen(s string) int {
	return len(stripANSI(s))
}

// PrintTable prints a simple table with headers and rows.
func PrintTable(headers []string, rows [][]string) {
	// Calculate column widths (using visible length, not raw length)
	widths := make([]int, len(headers))
	for i, h := range headers {
		widths[i] = visibleLen(h)
	}
	for _, row := range rows {
		for i, cell := range row {
			if i < len(widths) && visibleLen(cell) > widths[i] {
				widths[i] = visibleLen(cell)
			}
		}
	}

	// Print headers
	for i, h := range headers {
		fmt.Printf("%-*s  ", widths[i], h)
	}
	fmt.Println()

	// Print separator
	for _, w := range widths {
		fmt.Print(strings.Repeat("-", w) + "  ")
	}
	fmt.Println()

	// Print rows
	for _, row := range rows {
		for i, cell := range row {
			if i < len(widths) {
				// Pad based on visible length difference
				padding := widths[i] - visibleLen(cell)
				fmt.Print(cell + strings.Repeat(" ", padding) + "  ")
			}
		}
		fmt.Println()
	}
}

// SimpleCompletion is a simple completion provider using a static map.
type SimpleCompletion struct {
	RootCommands []string
	SubCommands  map[string][]string
}

// GetSuggestions implements CompletionProvider.
func (c *SimpleCompletion) GetSuggestions(prev string, parts []string) []string {
	if prev == "" && len(parts) <= 1 {
		return c.RootCommands
	}

	if subs, ok := c.SubCommands[prev]; ok {
		return subs
	}

	return []string{}
}
