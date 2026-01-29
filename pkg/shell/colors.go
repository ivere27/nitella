// Package shell provides common utilities for CLI shells.
package shell

// ANSI Color Codes
const (
	Reset  = "\033[0m"
	Red    = "\033[31m"
	Green  = "\033[32m"
	Yellow = "\033[33m"
	Blue   = "\033[34m"
	Purple = "\033[35m"
	Cyan   = "\033[36m"
	Gray   = "\033[37m"
	Bold   = "\033[1m"
	Dim    = "\033[2m"
)

// Colorize wraps text with the given color code.
func Colorize(color, text string) string {
	return color + text + Reset
}

// Success returns green text.
func Success(text string) string {
	return Green + text + Reset
}

// Error returns red text.
func Error(text string) string {
	return Red + text + Reset
}

// Warning returns yellow text.
func Warning(text string) string {
	return Yellow + text + Reset
}

// Info returns cyan text.
func Info(text string) string {
	return Cyan + text + Reset
}

// Header returns bold text.
func Header(text string) string {
	return Bold + text + Reset
}
